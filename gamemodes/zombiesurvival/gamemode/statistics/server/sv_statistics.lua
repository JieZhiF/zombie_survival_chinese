-- ============================================================================
-- statistics/server/sv_statistics.lua - 服务器统计追踪模块
-- 负责：按类型（武器/僵尸职业/游戏/技能）统计服务器的数据使用情况，
--       以 SRL 格式分文件持久化到 DATA/stat_tracking/ 目录；
--       每 60 秒定时保存，服务器关闭时最后保存一次；黑名单地图不统计
-- ============================================================================

-- 全局统计追踪表，挂载在 GM 命名空间下
GM.StatTracking = {}

-- 局部引用，后续统计方法都定义在该表上
local stattrack = GM.StatTracking
-- 统计数据保存目录（相对 DATA 目录）
stattrack.Folder = "stat_tracking"
-- 黑名单标记：为 true 时当前地图不参与统计
stattrack.BlackList = false

-- 统计类型常量：武器
STATTRACK_TYPE_WEAPON = 1
-- 统计类型常量：僵尸职业
STATTRACK_TYPE_ZOMBIECLASS = 2
-- 统计类型常量：游戏/回合
STATTRACK_TYPE_ROUND = 3
-- 统计类型常量：技能
STATTRACK_TYPE_SKILL = 4

-- Initialize 钩子：创建数据目录，并检测当前地图是否在统计黑名单内
hook.Add("Initialize", "ZSProfiler", function()
	-- 创建统计数据保存目录
	file.CreateDir(stattrack.Folder)

	-- 地图名包含这些关键字的图不参与统计（黑名单地图列表）
	for _, map in pairs({"tantibus", "serious_sam", "gauntlet", "high_noon", "croak"}) do
		-- 命中黑名单关键字则标记
		if string.find(game.GetMap(), map) then
			stattrack.BlackList = true
		end
	end
end)

-- 统计类型编号到名称后缀的映射（用于拼出 xxxData 数据表名与文件名）
local ttypetblnames = {
	[STATTRACK_TYPE_WEAPON] = "Weapon",
	[STATTRACK_TYPE_ZOMBIECLASS] = "ZombieClass",
	[STATTRACK_TYPE_ROUND] = "Game",
	[STATTRACK_TYPE_SKILL] = "Skill",
}

-- ==== stattrack:GetTypeTbl - 根据类型编号获取统计数据表名 ====
-- 返回 "WeaponData"/"ZombieClassData"/"GameData"/"SkillData" 之一
function stattrack:GetTypeTbl(ttype)
	return ttypetblnames[ttype] .. "Data"
end

-- ==== stattrack:GetTrackTypeStatFile - 根据类型编号获取统计数据文件路径 ====
-- 返回 DATA 目录下的文件名（小写复数形式），如 weapons.txt、zombieclasses.txt
function stattrack:GetTrackTypeStatFile(ttype)
	return self.Folder.."/".. string.lower(ttypetblnames[ttype]) .."s.txt"
end

-- 启动时从磁盘加载各类型已有的统计数据
for num, ttype in pairs(ttypetblnames) do
	local typenam = stattrack:GetTypeTbl(num)
	-- 每种类型对应一个数据表，先初始化为空表
	stattrack[typenam] = {}

	-- 文件存在则用 SRL 反序列化加载历史数据
	if file.Exists(stattrack:GetTrackTypeStatFile(num), "DATA") then
		-- 读取并反序列化（保存时数据整体存放在 "Ser" 键下）
		stattrack[typenam] = Deserialize(file.Read(stattrack:GetTrackTypeStatFile(num), "DATA"))
		-- 取出真正的统计数据部分
		stattrack[typenam] = stattrack[typenam].Ser
	end
end

-- ==== stattrack:SafeElementUpdateCreate - 安全更新统计条目 ====
-- 以 elem 为一级键、key 为二级键写入 value；elem 表不存在时自动创建
function stattrack:SafeElementUpdateCreate(type, elem, key, value)
	local typenam = self:GetTypeTbl(type)
	-- 元素表不存在时先创建空表，避免对 nil 索引赋值
	if not self[typenam][elem] then self[typenam][elem] = {} end

	self[typenam][elem][key] = value
end

-- ==== stattrack:ElementRead - 读取统计条目中的指定值 ====
-- 元素或键不存在时返回 nil
function stattrack:ElementRead(type, elem, key)
	local typenam = self:GetTypeTbl(type)
	-- 元素不存在直接返回 nil
	if not self[typenam][elem] then return end

	return self[typenam][elem][key]
end

-- ==== stattrack:IncreaseElementKV - 对统计条目做增量累加 ====
-- 黑名单地图直接返回；读取当前值（缺省 0）加上增量后写回
function stattrack:IncreaseElementKV(type, elem, key, incr)
	-- 黑名单地图不做统计
	if self.BlackList then return end

	self:SafeElementUpdateCreate(type, elem, key, (self:ElementRead(type, elem, key) or 0) + incr)
end

-- ==== stattrack:SaveStatTrackingFiles - 将所有类型的统计数据写入文件 ====
-- 以 {Ser = 数据} 的结构用 SRL 序列化保存，便于下次加载还原
function stattrack:SaveStatTrackingFiles()
	-- 遍历所有统计类型逐个写盘
	for num, ttype in pairs(ttypetblnames) do
		-- 序列化后写入对应文件
		file.Write(stattrack:GetTrackTypeStatFile(num), Serialize({Ser = self[self:GetTypeTbl(num)]}))
	end
end
-- 每 60 秒定时统计一次：记录当前手持武器与已激活技能，然后保存
timer.Create("StatTrackingSaveTimer", 60, 0, function()
	-- 获取当前所有玩家
	local allplys = player.GetAll()

	-- 统计各技能被激活的人数（用于换算技能分钟数）
	local skc = {}
	-- 遍历所有玩家
	for _,v in ipairs(allplys) do
		-- 手持武器计数 +1
		local activ = v:GetActiveWeapon()
		-- 武器有效才统计
		if activ and activ:IsValid() then
			-- 按武器类名累加持有次数
			stattrack:IncreaseElementKV(STATTRACK_TYPE_WEAPON, activ:GetClass(), "HeldWeaponSaves", 1)
		end

		-- 累加玩家当前激活的每个技能
		for i, j in pairs(v:GetActiveSkills()) do
			-- 该技能激活人数 +1
			skc[i] = (skc[i] or 0) + 1
		end
	end

	-- 将各技能激活人数计入技能统计（按分钟累加）
	for k,v in pairs(skc) do
		-- 以技能名称为键累加技能分钟数
		stattrack:IncreaseElementKV(STATTRACK_TYPE_SKILL, GAMEMODE.Skills[k].Name, "SkillMinutes", v)
	end

	-- 定时保存一次统计文件
	stattrack:SaveStatTrackingFiles()
end)
-- ShutDown 钩子：服务器关闭时最后保存一次统计数据
hook.Add("ShutDown", "StatTrack", function() stattrack:SaveStatTrackingFiles() end)
