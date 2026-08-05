-- ============================================================================
-- projectile_emi/shared.lua - 电磁脉冲投射物（共享）
-- 负责：声明 EMP 弹类型与碰撞过滤——弹体直接穿过人类玩家；预缓存
--       子投射物（projectile_emi_sub）使用的直升机炸弹模型
-- ============================================================================

-- 动画实体类型（飞行物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：EMP 弹直接穿过人类玩家 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- 预缓存直升机炸弹模型（供子投射物 projectile_emi_sub 使用）
util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
