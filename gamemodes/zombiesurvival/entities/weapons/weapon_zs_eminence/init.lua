-- ============================================================================
-- weapon_zs_eminence/init.lua - 能量弩「至圣」（Eminence）服务器端
-- 负责：指定发射的能量投射物与初始速度
-- ============================================================================

INC_SERVER()

-- 发射的能量投射物实体与初速度
SWEP.Primary.Projectile = "projectile_emi"
SWEP.Primary.ProjVelocity = 100

-- ==== PhysModify - 投射物物理属性修改钩子（默认不修改） ====
function SWEP:PhysModify(physobj)
end
