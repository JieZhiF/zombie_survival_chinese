-- thanks garry
-- 本文件负责注册自定义的玩家出生点实体类型，供地图编辑器和游戏逻辑使用。
-- 注册了 info_player_zombie（僵尸出生点）、info_player_undead（亡灵出生点）和 info_player_human（人类出生点）。

-- 定义实体表
local ENT = {}

-- 实体类型：点实体（仅逻辑，无模型）
ENT.Type = "point"

-- 实体初始化函数（此处为空，无需额外初始化逻辑）
function ENT:Initialize()
end

-- 实体每帧思考函数（此处为空，出生点实体无需每帧逻辑）
function ENT:Think()
end

-- 处理从地图文件中读取的键值对
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- 处理 "disabled" 键：值为1表示禁用
	if key == "disabled" then
		self.Disabled = tonumber(value) == 1
	-- 处理 "active" 键：值为0表示禁用
	elseif key == "active" then
		self.Disabled = tonumber(value) == 0
	end
end

-- 处理实体接收到的输入（来自地图逻辑或 hammer 编辑器）
function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	-- "enable" 输入：启用出生点
	if name == "enable" then
		self.Disabled = false
		return true
	-- "disable" 输入：禁用出生点
	elseif name == "disable" then
		self.Disabled = true
		return true
	-- "toggle" 输入：切换启用/禁用状态
	elseif name == "toggle" then
		self.Disabled = not self.Disabled
		return true
	end
end

-- 游戏模式函数：注册所有自定义出生点实体类型
function GM:RegisterPlayerSpawnEntities()
	scripted_ents.Register(ENT, "info_player_zombie")
	scripted_ents.Register(ENT, "info_player_undead")
	scripted_ents.Register(ENT, "info_player_human")
end
