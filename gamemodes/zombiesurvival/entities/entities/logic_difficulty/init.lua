-- ============================================================================
-- logic_difficulty/init.lua - 难度调节逻辑实体（服务器）
-- 负责：供地图作者使用的逻辑实体——通过 SetZombieDamageMultiplier /
--       SetZombieSpeedMultiplier 输入调节全局僵尸伤害/速度倍率
-- ============================================================================

-- 点实体类型（无需模型与碰撞体积）
ENT.Type = "point"

-- ==== AcceptInput - 处理地图输入：设置僵尸伤害/速度倍率 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- 设置僵尸伤害倍率（调节僵尸造成的伤害）
	if name == "setzombiedamagemultiplier" then
		GAMEMODE.ZombieDamageMultiplier = tonumber(args) or 1
	-- 设置僵尸移动速度倍率
	elseif name == "setzombiespeedmultiplier" then
		GAMEMODE.ZombieSpeedMultiplier = tonumber(args) or 1
	end
end
