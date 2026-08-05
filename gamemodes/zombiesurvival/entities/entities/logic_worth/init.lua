-- ============================================================================
-- init.lua - 起始点数覆写逻辑实体（地图专用）
-- 负责：通过键值/输入覆写本局玩家的起始点数（默认 100），实现自定义开局经济
-- ============================================================================
-- 点实体类型（无模型无物理）
ENT.Type = "point"

-- ==== Initialize - 初始化 ====
-- 点实体无需初始化逻辑，空实现保持钩子存在
function ENT:Initialize()
end

-- ==== Think - 思考 ====
-- 无持续逻辑，空实现
function ENT:Think()
end

-- ==== AcceptInput - 响应 SetStartingWorth 输入 ====
-- 将输入参数写入 startingworth 键值，动态调整本局起始点数
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "setstartingworth" then
		self:SetKeyValue("startingworth", args)
	end
end

-- ==== KeyValue - 解析 startingworth 键值 ====
-- 一旦设置即覆写全局起始点数（OverrideStartingWorth 标志生效），非法值回退 100
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "startingworth" then
		GAMEMODE.OverrideStartingWorth = true
		GAMEMODE.StartingWorth = tonumber(value) or 100
	end
end
