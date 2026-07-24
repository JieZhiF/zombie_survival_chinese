-- ============================================================
-- 文件: mapeditor.lua
-- 作用: 共享脚本（同时在服务器和客户端运行）
-- 功能: 地图编辑器系统
--       提供一系列控制台命令，允许超级管理员在游戏中
--       动态添加、删除、移动和旋转自定义实体
--       支持保存/加载编辑好的地图配置文件
-- ============================================================

-- 以下是本文件所有函数和控制台命令的简要说明：
-- mapeditor_add —— 在准星指向位置生成指定实体
-- mapeditor_addonme —— 在玩家当前位置生成指定实体
-- mapeditor_remove —— 删除准星指向的编辑器实体
-- mapeditor_pickup —— 拾取实体并跟随准星移动
-- mapeditor_nudgeup —— 将实体向上微移
-- mapeditor_nudgeforward —— 将实体向前微移
-- mapeditor_nudgeright —— 将实体向右微移
-- mapeditor_rotateup —— 绕上方向轴旋转实体
-- mapeditor_rotateforward —— 绕前方向轴旋转实体
-- mapeditor_rotateright —— 绕右方向轴旋转实体
-- mapeditor_drop —— 放下当前拾取的实体
-- GM:LoadMapEditorFile —— 加载地图编辑器配置文件
-- GM:SaveMapEditorFile —— 保存地图编辑器配置文件
-- Deserialize —— 反序列化 SRL 格式数据
-- Serialize —— 将数据序列化为 SRL 格式

-- ============================================================
-- 全局配置
-- 设置地图编辑器文件的前缀，并创建对应的存储目录
-- ============================================================

-- 地图编辑器文件前缀（用于标识和防止冲突）
GM.MapEditorPrefix = "zs"
-- 创建以该前缀命名的地图数据目录
file.CreateDir(GM.MapEditorPrefix .. "maps")

-- ============================================================
-- 命令: mapeditor_add
-- 功能: 在玩家准星指向的位置生成一个指定类别的实体
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 实体类别名称（如 prop_dynamic）
-- ============================================================
concommand.Add("mapeditor_add", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 检查是否提供了实体类别参数
	if not arguments[1] then return end

	-- 获取玩家准星追踪到的位置
	local tr = sender:GetEyeTrace()
	-- 确认追踪到了物体
	if tr.Hit then
		-- 创建指定类别的实体
		local ent = ents.Create(string.lower(arguments[1]))
		-- 验证实体创建成功
		if ent:IsValid() then
			-- 设置实体位置为准星命中点
			ent:SetPos(tr.HitPos)
			-- 生成实体
			ent:Spawn()
			-- 将实体加入编辑器实体列表
			table.insert(GAMEMODE.MapEditorEntities, ent)
			-- 自动保存编辑状态
			GAMEMODE:SaveMapEditorFile()
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_addonme
-- 功能: 在玩家当前眼睛位置生成指定实体（视角位置）
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 实体类别名称
-- ============================================================
concommand.Add("mapeditor_addonme", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 检查是否提供了实体类别参数
	if not arguments[1] then return end

	-- 创建指定类别的实体
	local ent = ents.Create(string.lower(arguments[1]))
	-- 验证实体创建成功
	if ent:IsValid() then
		-- 设置位置为玩家眼睛位置
		ent:SetPos(sender:EyePos())
		-- 设置角度为玩家视角方向
		ent:SetAngles(sender:GetAngles())
		-- 生成实体
		ent:Spawn()
		-- 加入编辑器实体列表
		table.insert(GAMEMODE.MapEditorEntities, ent)
		-- 自动保存
		GAMEMODE:SaveMapEditorFile()
	end
end)

-- ============================================================
-- 命令: mapeditor_remove
-- 功能: 删除玩家准星指向的编辑器实体
-- 权限: 仅超级管理员可用
-- ============================================================
concommand.Add("mapeditor_remove", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星追踪到的实体
	local tr = sender:GetEyeTrace()
	-- 确认追踪到的实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 遍历编辑器实体列表查找匹配的实体
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 从列表中移除
				table.remove(GAMEMODE.MapEditorEntities, i)
				-- 从世界中删除
				ent:Remove()
			end
		end
		-- 保存编辑状态
		GAMEMODE:SaveMapEditorFile()
	end
end)

-- ============================================================
-- 内部函数: ME_Pickup
-- 功能: 在拾取模式下，持续将实体位置更新到准星指向位置
-- 由 mapeditor_pickup 命令创建的定时器循环调用
-- pl: 执行操作的玩家
-- ent: 被拾取的实体
-- uid: 玩家唯一标识（SteamID64），用于定时器管理
-- ============================================================
local function ME_Pickup(pl, ent, uid)
	-- 确认玩家和实体都有效
	if pl:IsValid() and ent:IsValid() then
		-- 从玩家眼睛位置沿瞄准方向追踪 3000 单位
		-- 将实体位置设置到追踪命中点
		ent:SetPos(util.TraceLine({start = pl:GetShootPos(), endpos = pl:GetShootPos() + pl:GetAimVector() * 3000, filter = {pl, ent}}).HitPos)
		return
	end
	-- 如果玩家或实体无效，停止拾取定时器并保存
	timer.Remove(uid .. "mapeditorpickup")
	GAMEMODE:SaveMapEditorFile()
end

-- ============================================================
-- 命令: mapeditor_pickup
-- 功能: 拾取准星指向的编辑器实体，使实体跟随准星移动
-- 权限: 仅超级管理员可用
-- 通过定时器循环更新实体位置
-- ============================================================
concommand.Add("mapeditor_pickup", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星追踪到的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找匹配
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体后，创建定时器循环更新位置
			if ent == tr.Entity then
				timer.Create(sender:SteamID64() .. "mapeditorpickup", 0.25, 0, function() ME_Pickup(sender, ent, sender:SteamID64()) end)
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_nudgeup
-- 功能: 将准星指向的实体向上微移指定距离
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 微移距离（可选，默认 1 单位）
-- ============================================================
concommand.Add("mapeditor_nudgeup", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星指向的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 获取微移距离（默认 1 单位）
				local amount = tonumber(arguments[1]) or 1
				-- 将实体沿世界 Z 轴向上移动
				ent:SetPos(ent:GetPos() + Vector(0, 0, amount))
				-- 保存编辑状态
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_nudgeforward
-- 功能: 将准星指向的实体沿自身前方微移
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 微移距离（可选，默认 1 单位）
-- ============================================================
concommand.Add("mapeditor_nudgeforward", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星指向的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 获取微移距离（默认 1 单位）
				local amount = tonumber(arguments[1]) or 1
				-- 沿实体自身前方方向移动
				ent:SetPos(ent:GetPos() + ent:GetForward() * amount)
				-- 保存编辑状态
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_nudgeright
-- 功能: 将准星指向的实体沿自身右方微移
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 微移距离（可选，默认 1 单位）
-- ============================================================
concommand.Add("mapeditor_nudgeright", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星指向的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 获取微移距离（默认 1 单位）
				local amount = tonumber(arguments[1]) or 1
				-- 沿实体自身右方方向移动
				ent:SetPos(ent:GetPos() + ent:GetRight() * amount)
				-- 保存编辑状态
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_rotateup
-- 功能: 将准星指向的实体绕自身向上的轴旋转
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 旋转角度（可选，默认 1 度）
-- ============================================================
concommand.Add("mapeditor_rotateup", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星指向的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 获取旋转角度（默认 1 度）
				local amount = tonumber(arguments[1]) or 1
				-- 获取当前角度
				local ang = ent:GetAngles()
				-- 绕实体自身的 Up 轴旋转
				ang:RotateAroundAxis(ang:Up(), amount)
				-- 应用新角度
				ent:SetAngles(ang)
				-- 保存编辑状态
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_rotateforward
-- 功能: 将准星指向的实体绕自身前方的轴旋转
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 旋转角度（可选，默认 1 度）
-- ============================================================
concommand.Add("mapeditor_rotateforward", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星指向的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 获取旋转角度（默认 1 度）
				local amount = tonumber(arguments[1]) or 1
				-- 获取当前角度
				local ang = ent:GetAngles()
				-- 绕实体自身的 Forward 轴旋转
				ang:RotateAroundAxis(ang:Forward(), amount)
				-- 应用新角度
				ent:SetAngles(ang)
				-- 保存编辑状态
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_rotateright
-- 功能: 将准星指向的实体绕自身右方的轴旋转
-- 权限: 仅超级管理员可用
-- 参数: arguments[1] —— 旋转角度（可选，默认 1 度）
-- ============================================================
concommand.Add("mapeditor_rotateright", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 获取准星指向的实体
	local tr = sender:GetEyeTrace()
	-- 确认实体有效
	if tr.Entity and tr.Entity:IsValid() then
		-- 在编辑器实体列表中查找
		for i, ent in ipairs(GAMEMODE.MapEditorEntities) do
			-- 找到目标实体
			if ent == tr.Entity then
				-- 获取旋转角度（默认 1 度）
				local amount = tonumber(arguments[1]) or 1
				-- 获取当前角度
				local ang = ent:GetAngles()
				-- 绕实体自身的 Right 轴旋转
				ang:RotateAroundAxis(ang:Right(), amount)
				-- 应用新角度
				ent:SetAngles(ang)
				-- 保存编辑状态
				GAMEMODE:SaveMapEditorFile()
				return true
			end
		end
	end
end)

-- ============================================================
-- 命令: mapeditor_drop
-- 功能: 放下当前正在拾取的实体（停止拾取模式）
-- 权限: 仅超级管理员可用
-- ============================================================
concommand.Add("mapeditor_drop", function(sender, command, arguments)
	-- 检查玩家是否是超级管理员
	if not sender:IsSuperAdmin() then return end

	-- 移除与该玩家关联的拾取定时器
	timer.Remove(sender:SteamID64() .. "mapeditorpickup")
	-- 保存当前编辑状态
	GAMEMODE:SaveMapEditorFile()
end)

-- ============================================================
-- 加载地图编辑器配置文件
-- 尝试从两个位置加载：预打包的地图配置文件和 DATA 文件系统的配置文件
-- 支持两种数据格式：SRL 序列化格式和旧版逗号分隔格式
-- ============================================================
function GM:LoadMapEditorFile()
	-- 获取当前地图名称
	local mapname = game.GetMap()

	-- 初始化编辑器实体列表
	self.MapEditorEntities = {}

	-- 用于存储读取到的文件内容
	local red

	-- 优先尝试从 LUA 文件系统加载预打包的地图配置文件
	if file.Exists(self.FolderName .. "/gamemode/prepackagedmapprofiles/" .. mapname .. ".lua", "LUA") then
		red = file.Read(self.FolderName .. "/gamemode/prepackagedmapprofiles/" .. mapname .. ".lua", "LUA")
	-- 其次尝试从 DATA 文件系统加载用户保存的配置文件
	elseif file.Exists(self.MapEditorPrefix .. "maps/" .. mapname .. ".txt", "DATA") then
		red = file.Read(self.MapEditorPrefix .. "maps/" .. mapname .. ".txt", "DATA")
	end

	-- 如果成功读取到文件内容
	if red then
		-- 判断数据格式：以 "SRL" 开头表示序列化格式
		if string.sub(red, 1, 3) == "SRL" then
			-- 反序列化数据
			for _, enttab in pairs(Deserialize(red)) do
				-- 创建实体
				local ent = ents.Create(string.lower(enttab.Class))
				-- 验证实体有效
				if ent:IsValid() then
					-- 设置位置和角度
					ent:SetPos(enttab.Position)
					ent:SetAngles(enttab.Angles)
					-- 如果有自定义键值参数，进行设置
					if enttab.KeyValues then
						ent.KeyValues = ent.KeyValues or {}
						for key, value in pairs(enttab.KeyValues) do
							ent.KeyValues[key] = value
						end
					end
					-- 生成实体
					ent:Spawn()
					-- 加入编辑器实体列表
					table.insert(self.MapEditorEntities, ent)
				end
			end
		else
			-- 旧版逗号分隔格式兼容
			for _, stuff in pairs(string.Explode(",", red)) do
				-- 按空格分割每条数据
				local expstuff = string.Explode(" ", stuff)
				-- 创建实体
				local ent = ents.Create(string.lower(expstuff[1]))
				-- 验证实体有效
				if ent:IsValid() then
					-- 从第 2-4 个字段解析位置向量
					ent:SetPos(Vector(tonumber(expstuff[2]), tonumber(expstuff[3]), tonumber(expstuff[4])))
					-- 从第 5 个字段开始解析键值对
					for i = 5, #expstuff do
						local kv = string.Explode(string.char(65533), expstuff[i])
						ent:SetKeyValue(kv[1], kv[2])
					end
					-- 生成实体
					ent:Spawn()
					-- 加入编辑器实体列表
					table.insert(self.MapEditorEntities, ent)
				end
			end
		end
	end
end

-- ============================================================
-- 保存地图编辑器配置文件
-- 将所有当前编辑器中的实体信息序列化并保存到 DATA 文件系统
-- 保存内容包括：实体类别、位置、角度和自定义键值参数
-- ============================================================
function GM:SaveMapEditorFile()
	-- 创建保存数据表
	local sav = {}
	-- 遍历所有编辑器实体
	for _, ent in pairs(self.MapEditorEntities) do
		-- 只保存有效的实体
		if ent:IsValid() then
			-- 构建实体信息表
			local enttab = {}
			enttab.Class = ent:GetClass()
			enttab.Position = ent:GetPos()
			enttab.Angles = ent:GetAngles()
			-- 如果有键值参数，一起保存
			if ent.KeyValues then
				local keyvalues = {}
				for i, key in ipairs(ent.KeyValues) do
					keyvalues[key] = ent[key]
				end
				enttab.KeyValues = keyvalues
			end
			-- 加入保存列表
			table.insert(sav, enttab)
		end
	end
	-- 序列化并写入文件（以地图前缀+地图名命名）
	file.Write(self.MapEditorPrefix .. "maps/" .. game.GetMap() .. ".txt", Serialize(sav))
end

-- ============================================================
-- 反序列化函数：将 SRL 格式的字符串解析为 Lua 数据表
-- SRL 是一种类 Lua 源码的序列化格式
-- sIn: 输入的序列化字符串
-- 返回值: 反序列化后的数据表
-- ============================================================
function Deserialize(sIn)
	-- 清空全局变量 SRL，用于接收反序列化结果
	SRL = nil

	-- 如果输入字符串为空，返回空表
	if #sIn == 0 then return {} end

	-- 如果字符串不以 "SRL=" 开头，补充前缀后执行
	if string.sub(sIn, 1, 4) ~= "SRL=" then sIn = "SRL=" .. sIn end
	-- 执行反序列化代码（将字符串作为 Lua 代码运行，结果存入 SRL 变量）
	RunString(sIn)

	-- 返回反序列化的结果
	return SRL
end

-- ============================================================
-- 允许序列化的数据类型白名单
-- 仅这些类型的值可以被序列化
-- ============================================================
local allowedtypes = {}
allowedtypes["string"] = true
allowedtypes["number"] = true
allowedtypes["table"] = true
allowedtypes["Vector"] = true
allowedtypes["Angle"] = true
allowedtypes["boolean"] = true

-- ============================================================
-- 内部递归函数：将 Lua 数据表转换为字符串表示
-- tab: 要转换的表格
-- done: 已处理过的表格引用记录（防止循环引用）
-- 返回值: 表格的字符串表示
-- ============================================================
local function MakeTable(tab, done)
	-- 积累字符串
	local str = ""
	-- 记录已处理过的表（用于检测循环引用）
	done = done or {}

	-- 判断当前表是否为顺序索引表
	local sequential = table.IsSequential(tab)

	-- 遍历表格的所有字段
	for key, value in pairs(tab) do
		-- 获取键和值的类型
		local keytype = type(key)
		local valuetype = type(value)

		-- 只序列化白名单中的类型
		if allowedtypes[keytype] and allowedtypes[valuetype] then
			-- 顺序索引表不需要键名
			if sequential then
				key = ""
			else
				-- 根据键的类型生成键的字符串表示
				if keytype == "number" or keytype == "boolean" then
					key = "[" .. tostring(key) .. "]="
				else
					key = "[" .. string.format("%q", tostring(key)) .. "]="
				end
			end

			-- 处理值
			if valuetype == "table" and not done[value] then
				-- 递归序列化子表（记录引用防止死循环）
				done[value] = true
				if type(value._serialize) == "function" then
					-- 如果有自定义序列化方法，调用它
					str = str .. key .. value:_serialize() .. ","
				else
					-- 否则递归处理
					str = str .. key .. "{" .. MakeTable(value, done) .. "},"
				end
			else
				-- 处理非表类型的值
				if valuetype == "string" then
					value = string.format("%q", value)
				elseif valuetype == "Vector" then
					value = "Vector(" .. value.x .. "," .. value.y .. "," .. value.z .. ")"
				elseif valuetype == "Angle" then
					value = "Angle(" .. value.pitch .. "," .. value.yaw .. "," .. value.roll .. ")"
				else
					value = tostring(value)
				end

				-- 追加到结果字符串
				str = str .. key .. value .. ","
			end
		end
	end

	-- 移除末尾多余的逗号
	if string.sub(str, -1) == "," then
		return string.sub(str, 1, #str - 1)
	else
		return str
	end
end

-- ============================================================
-- 序列化函数：将 Lua 数据表序列化为 SRL 格式字符串
-- tIn: 要序列化的数据表
-- bRaw: 可选参数，若为 true 则不添加 "SRL=" 前缀
-- 返回值: 序列化后的字符串
-- ============================================================
function Serialize(tIn, bRaw)
	-- 检查空表：如果既没有顺序元素也没有键值对，返回空字符串
	if #tIn == 0 then
		local empty = true
		for k in pairs(tIn) do
			empty = false
			break
		end
		if empty then
			return ""
		end
	end

	-- 根据是否原始模式决定返回格式
	if bRaw then
		return "{" .. MakeTable(tIn) .. "}"
	end

	-- 标准模式：添加 "SRL=" 前缀（用于反序列化时识别）
	return "SRL={" .. MakeTable(tIn) .. "}"
end
