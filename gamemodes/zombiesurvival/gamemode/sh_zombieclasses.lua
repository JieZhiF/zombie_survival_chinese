-- 本文件主要负责管理游戏中的僵尸职业系统，包括注册、加载、排序、解锁条件判断以及网络同步僵尸职业的解锁状态。

-- GM.RevertableZombieClasses 备份初始的僵尸职业列表，用于在需要时恢复。
-- GM:IsClassUnlocked 检查指定的僵尸职业是否已根据游戏进度（如波数、理智值）解锁。
-- GM:ClassUnlocksUpdate 向客户端同步所有僵尸职业的解锁状态。
-- ReorderZombieClassesSort (内部函数) 用于对僵尸职业列表进行排序的比较函数。
-- GM:ReorderZombieClasses 根据预设的排序规则（如出场波数、自定义顺序）对所有僵尸职业进行排序和索引。
-- GM:RegisterZombieClass 将一个新的僵尸职业注册到系统中，并设置其基本属性。
-- GM:RevertZombieClasses 将当前的僵尸职业列表恢复到初始备份的状态。
-- GM:RegisterZombieClasses 加载、注册并处理所有僵尸职业定义文件，包括处理职业间的继承关系。

-- 可还原的僵尸职业列表备份，用于在需要时通过 RevertZombieClasses 恢复初始状态
GM.RevertableZombieClasses = {}

-- 检查指定僵尸职业是否已解锁
-- @param classname (string) 僵尸职业的名称（键名）
-- @return (boolean) 如果职业已解锁则返回 true，否则返回 false
function GM:IsClassUnlocked(classname)
	-- 根据职业名称从 ZombieClasses 表中获取对应的职业配置表
	local classtab = self.ZombieClasses[classname]
	-- 如果找不到该职业配置，则视为未解锁
	if not classtab then return false end

	-- Boss 类型职业始终处于解锁状态，无需任何条件判断
	if classtab.Boss then return true end

	-- 如果职业定义了自定义的解锁判断函数，则优先调用它
	if classtab.IsClassUnlocked then
		-- 调用职业自身的 IsClassUnlocked 方法，如果返回值不为 nil 则直接采用
		local ret = classtab:IsClassUnlocked()
		if ret ~= nil then return ret end
	end

	-- 如果职业被显式锁定（Locked == true），则未解锁
	if classtab.Locked then return false end

	-- 解锁条件判断（满足任一条件即视为解锁）：
	return classtab.Unlocked -- 1) 手动标记为已解锁
	-- 2) 当前波数 >= 职业要求的出场波数
	or classtab.Wave and self:GetWave() >= classtab.Wave
	-- 3) 在波间休息期，如果下一波 >= 职业要求的波数，也视为解锁（提前预览）
	or classtab.Wave and not self:GetWaveActive() and self:GetWave() + 1 >= classtab.Wave
	-- 4) 当启用印记系统时，根据被腐蚀的印记比例与职业要求的理智阈值比较
	or classtab.Sanity and self:GetUseSigils() and self:NumSigilsCorrupted() / self.MaxSigils >= classtab.Sanity
	-- 旧版本注释掉的逻辑：使用 SigilsDestroyed（被摧毁的印记数量）而非 NumSigilsCorrupted（被腐蚀的印记数量）
	--or classtab.Sanity and self:GetUseSigils() and self:GetSigilsDestroyed() / self.MaxSigils >= classtab.Sanity
end

-- 向指定玩家（或所有玩家）同步所有僵尸职业的解锁状态
-- @param pl (Player | nil) 如果指定玩家对象，则仅向该玩家发送；为 nil 时广播给所有玩家
function GM:ClassUnlocksUpdate(pl)
	-- 遍历按顺序排列的僵尸职业列表（索引为数字）
	for k,v in ipairs(GAMEMODE.ZombieClasses) do
		-- 开始网络消息：职业解锁状态
		net.Start(NET_MSG.CLASSUNLOCKSTATE)
			-- 写入职业的索引编号（最多 255 个职业）
			net.WriteInt(k, 8)
			-- 写入该职业的解锁状态（布尔值）
			net.WriteBool(v.Unlocked)
		-- 根据是否指定目标玩家决定发送方式
		if pl then
			net.Send(pl) -- 仅发送给指定玩家
		else
			net.Broadcast() -- 广播给所有连接的玩家
		end
	end
end

-- 僵尸职业排序比较函数（内部函数，供 table.sort 使用）
-- 排序优先级：自定义顺序(Order) > 出场波数(Wave) > 职业名称(Name) 字母顺序
-- @param a (table) 第一个职业配置表
-- @param b (table) 第二个职业配置表
-- @return (boolean) 如果 a 应该排在 b 前面则返回 true
local function ReorderZombieClassesSort(a, b)
	-- 第一优先级：如果两者中任意一个定义了 Order 字段，则按 Order 排序
	if (a.Order or b.Order) and a.Order ~= b.Order then
		-- 未设置 Order 的视为 255（排在最后）
		return (a.Order or 255) < (b.Order or 255)
	end

	-- 第二优先级：如果两者中任意一个定义了 Wave 字段，则按出场波数排序
	if (a.Wave or b.Wave) and a.Wave ~= b.Wave then
		-- 未设置 Wave 的视为 255（排在最后）
		return (a.Wave or 255) < (b.Wave or 255)
	end

	-- 第三优先级：按职业名称的字母顺序排序（作为最后的保底排序方式）
	return a.Name < b.Name
end

-- 对所有已注册的僵尸职业执行排序，并更新索引和默认职业引用
function GM:ReorderZombieClasses()
	-- 使用自定义的比较函数对数字索引的职业列表进行排序
	table.sort(self.ZombieClasses, ReorderZombieClassesSort)

	-- 排序完成后，遍历所有职业重新建立索引映射
	for k, v in pairs(self.ZombieClasses) do
		-- 只处理数字索引的条目（字符串索引的条目是名称别名映射，不在此处理）
		if type(k) == "number" then
			-- 以职业名称作为键，建立字符串索引映射，方便通过名称快速查找
			self.ZombieClasses[v.Name] = v
			-- 更新排序后的新索引位置
			v.Index = k

			-- 如果该职业被标记为默认职业，则记录其索引
			if v.IsDefault then
				self.DefaultZombieClass = k
			end
		end
	end
end

-- 注册一个新的僵尸职业到系统中
-- @param name (string) 职业名称（用作键名）
-- @param tab (table) 职业配置表，包含 Name、Wave、Points、Icon 等属性
function GM:RegisterZombieClass(name, tab)
	-- 兼容性处理：GAMEMODE 和 GM 在不同上下文中可能不同，统一获取 gamemode 对象
	local gm = GAMEMODE or GM

	-- 如果职业指定了 Wave（出场波数比例），则根据总波数将其转换为具体的波数数值
	-- 例如：Wave = 0.5, NumberOfWaves = 20 → 实际出场波数为 10
	if tab.Wave then tab.Wave = math.floor(tab.Wave * self.NumberOfWaves) end
	-- 将职业配置表添加到数字索引列表的末尾
	table.insert(gm.ZombieClasses, tab)
	-- 设置职业的索引为其在列表中的当前位置
	tab.Index = #gm.ZombieClasses
	-- 客户端环境下，设定默认的击杀图标路径（如果未自定义）
	if CLIENT then
		tab.Icon = tab.Icon or "zombiesurvival/killicons/genericundead"
	end

	-- 如果该职业被标记为默认职业，则记录其索引位置
	if tab.IsDefault then
		gm.DefaultZombieClass = tab.Index
	end

	-- 设置翻译名称：如果未指定，则使用原始名称作为翻译名称
	tab.TranslationName = tab.TranslationName or tab.Name
	-- 设置职业点数（用于职业选择时的点数消耗），默认为 0
	tab.Points = tab.Points or 0

	-- 以职业名称作为键，建立字符串索引映射，支持通过名称直接访问
	gm.ZombieClasses[name] = tab
end

-- 将当前的僵尸职业列表恢复到游戏开始时的初始备份状态
-- 用于在重置回合或重新加载配置时恢复原始的职业列表
function GM:RevertZombieClasses()
	-- 使用深拷贝从备份中恢复，避免直接引用导致后续修改影响备份数据
	self.ZombieClasses = table.Copy(self.RevertableZombieClasses)
end

-- 主加载函数：扫描僵尸职业定义文件，注册所有职业，处理继承关系，执行排序，并创建备份
function GM:RegisterZombieClasses()
	-- 初始化僵尸职业列表（空表）
	self.ZombieClasses = {}
	-- 设置默认职业索引，如果尚未设置则默认为 1
	self.DefaultZombieClass = self.DefaultZombieClass or 1

	-- 记录所有已包含（加载）的职业文件，用于后续处理继承关系
	local included = {}

	-- 扫描 zombieclasses 目录下的所有文件和子文件夹
	-- self.FolderName 是 gamemode 文件夹的名称（如 "zombiesurvival"）
	local classfiles, classdirectories = file.Find(self.FolderName.."/gamemode/zombieclasses/*", "LUA")
	-- 对文件列表和文件夹列表分别进行排序，保证加载顺序的一致性
	table.sort(classfiles)
	table.sort(classdirectories)

	-- === 第一轮：加载独立的 .lua 文件形式的职业 ===
	for i, filename in ipairs(classfiles) do
		-- 仅处理以 .lua 结尾的文件（安全检查，排除非脚本文件）
		if string.sub(filename, -4) == ".lua" then -- Just in case
			-- 创建全局临时变量 CLASS，供被引入的脚本文件填充职业配置
			CLASS = {}

			-- 向客户端声明需要传输此文件（客户端也需要加载）
			AddCSLuaFile("zombieclasses/"..filename)
			-- 服务端包含并执行此职业定义文件
			include("zombieclasses/"..filename)

			-- 检查职业脚本是否设置了 CLASS.Name（必要的职业名称）
			if CLASS.Name then
				-- 正式注册该职业到系统中
				self:RegisterZombieClass(CLASS.Name, CLASS)
			else
				-- 如果缺少名称，输出错误信息但不中断程序
				ErrorNoHalt("CLASS "..filename.." has no 'Name' member!")
			end

			-- 记录该文件已被加载，供后续继承使用
			included[filename] = CLASS
			-- 清空临时变量，避免影响下一个文件的加载
			CLASS = nil
		end
	end

	-- === 第二轮：加载文件夹形式的职业（包含 client.lua / server.lua） ===
	for i, foldername in ipairs(classdirectories) do
		-- 构建基础路径：zombieclasses/文件夹名/
		local basefn = "zombieclasses/"..foldername.."/"

		-- 创建全局临时变量 CLASS，供被引入的脚本填充
		CLASS = {}
		-- 客户端环境：加载客户端的 UI/渲染相关代码
		if CLIENT then
			include(basefn.."client.lua")
		end
		-- 服务端环境：向客户端声明需要传输 client.lua，并加载服务端逻辑
		if SERVER then
			AddCSLuaFile(basefn.."client.lua")
			include(basefn.."server.lua")
		end

		-- 检查职业是否设置了名称
		if CLASS.Name then
			self:RegisterZombieClass(CLASS.Name, CLASS)
		else
			ErrorNoHalt("CLASS "..foldername.." has no 'Name' member!")
		end

		-- 记录（以 foldername.lua 作为键，便于后续继承查找时统一后缀）
		included[foldername..".lua"] = CLASS
		CLASS = nil
	end

	-- === 第三轮：处理职业间的继承关系（Base 属性） ===
	for k, v in pairs(self.ZombieClasses) do
		-- 检查职业是否指定了基类（要继承的职业名称）
		local base = v.Base
		if base then
			-- 补全 .lua 后缀，使其与 included 表中的键一致
			base = base..".lua"
			-- 确认基类文件已被加载
			if included[base] then
				-- === 保存需要保留的属性（子类不应继承父类的这些属性） ===
				local old_BetterVersion = v.BetterVersion -- 进化版本
				local old_Infliction = v.Infliction -- 造成感染的类型
				local old_Hidden = v.Hidden -- 是否在职业选择界面隐藏
				local old_Unlocked = v.Unlocked -- 解锁状态
				local old_Disabled = v.Disabled -- 是否被禁用
				local old_Order = v.Order -- 自定义排序顺序
				local old_IsDefault = v.IsDefault -- 是否为默认职业

				-- 从基类继承所有未定义的属性（table.Inherit 只填充子类中不存在的字段）
				table.Inherit(v, included[base])

				-- 恢复子类特有的属性，确保不会被基类覆盖
				-- Don't inherit these.
				v.BetterVersion = old_BetterVersion
				v.Infliction = old_Infliction
				v.Hidden = old_Hidden
				v.Unlocked = old_Unlocked
				v.Disabled = old_Disabled
				v.Order = old_Order
				v.IsDefault = old_IsDefault
			else
				-- 基类文件不存在时输出错误提示
				ErrorNoHalt("CLASS "..tostring(v.Name).." uses base class "..base.." but it doesn't exist!")
			end
		end

		-- 如果职业的解锁条件为已解锁或波数要求为 0，则标记为已通知解锁
		-- 这样在首次加载时不会触发"新解锁"的通知提示
		if v.Unlocked or v.Wave == 0 then
			v.UnlockedNotify = true
		end
	end

	-- === 第四轮：建立 BetterVersion（进化版本）的反向引用 ===
	for k, v in pairs(self.ZombieClasses) do
		-- 如果职业指定了 BetterVersion（进化目标），且目标职业存在
		if v.BetterVersion and self.ZombieClasses[v.BetterVersion] then
			-- 在目标职业上设置 BetterVersionOf 字段，指向源职业的名称
			-- 这样可以从进化目标反向查找到哪些职业可以进化到它
			self.ZombieClasses[v.BetterVersion].BetterVersionOf = v.Name
		end
	end

	-- === 最终处理：排序并创建备份 ===
	-- 对所有职业执行排序（根据 Order、Wave、Name 等规则）
	self:ReorderZombieClasses()

	-- 在完成所有加载、继承、排序后，将当前状态深拷贝为备份
	-- 后续调用 RevertZombieClasses 时可恢复到此刻的状态
	self.RevertableZombieClasses = table.Copy(self.ZombieClasses)
end

-- === 自动执行：如果当前尚未加载僵尸职业列表，则调用注册函数 ===
-- 此判断防止在 gamemode 尚未完全初始化时过早执行注册，
-- 也确保在文件被 require 时自动完成职业的加载与注册
if not GAMEMODE or (GAMEMODE and not GAMEMODE.ZombieClasses) then
	GM:RegisterZombieClasses()
end
