-- ============================================================================
-- logic_winreward/init.lua - 胜利奖励逻辑实体
-- 负责：通过 Hammer 键值 winmulti 设置本局胜利经验倍率，
--       供地图作者调节胜利奖励强度
-- ============================================================================
ENT.Type = "point"

-- ==== Initialize - 空实现：点实体无需初始化 ====
function ENT:Initialize()
end

-- ==== Think - 空实现：无每帧逻辑 ====
function ENT:Think()
end

-- ==== KeyValue - 键值处理：winmulti 设置胜利经验倍率 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "winmulti" then
		GAMEMODE.WinXPMulti = tonumber(value) or 1
	end
end
