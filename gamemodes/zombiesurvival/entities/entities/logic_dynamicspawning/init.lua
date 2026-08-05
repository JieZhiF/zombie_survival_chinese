-- ============================================================================
-- logic_dynamicspawning/init.lua - 动态刷怪开关逻辑实体（服务器）
-- 负责：通过 Enable/Disable 输入与 enabled 键值控制全局动态刷怪开关
--       （动态刷怪：根据玩家数量/位置动态调整僵尸出生点）
-- ============================================================================

-- 实体类型：点实体（仅存在于 Hammer 地图中，无物理模型）
ENT.Type = "point"

-- ==== AcceptInput - 处理 Enable/Disable 输入，切换动态刷怪开关 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "enable" then
		-- 启用动态刷怪
		GAMEMODE:SetDynamicSpawning(true)
	elseif name == "disable" then
		-- 禁用动态刷怪
		GAMEMODE:SetDynamicSpawning(false)
	end
end

-- ==== KeyValue - 处理地图键值 enabled：设定初始动态刷怪状态 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "enabled" then
		-- enabled 值为 "0" 时禁用，其余值（"1"）启用
		GAMEMODE:SetDynamicSpawning(value ~= "0")
	end
end
