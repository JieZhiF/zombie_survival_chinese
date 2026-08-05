-- ============================================================================
-- logic_pantsmode/init.lua - 裤子模式逻辑实体（服务器）
-- 负责：供地图作者使用的逻辑实体——通过 Enable/Disable 输入或 enabled
--       键值开关"裤子模式"（趣味彩蛋模式，对应 zs_pantsmode 开关）
-- ============================================================================

-- 点实体类型（无需模型与碰撞体积）
ENT.Type = "point"

-- ==== AcceptInput - 处理输入：按输入名启用/禁用裤子模式 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- 启用裤子模式
	if name == "enable" then
		GAMEMODE:SetPantsMode(true)
	-- 禁用裤子模式
	elseif name == "disable" then
		GAMEMODE:SetPantsMode(false)
	end
end

-- ==== KeyValue - 处理实体键值：按 enabled 初值设置裤子模式 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- 出生时按 enabled 键值（非 "0" 即启用）设置初始状态
	if key == "enabled" then
		GAMEMODE:SetPantsMode(value ~= "0")
	end
end
