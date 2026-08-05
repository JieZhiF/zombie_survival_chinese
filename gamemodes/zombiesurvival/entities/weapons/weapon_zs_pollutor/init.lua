-- ============================================================================
-- weapon_zs_pollutor/init.lua - 生化喷射枪「污染者」（Pollutor）服务器端
-- 负责：指定发射的生化投射物与初始速度
-- ============================================================================

INC_SERVER()

-- 发射的生化投射物实体与初速度（900 单位/秒）
SWEP.Primary.Projectile = "projectile_biorifle"
SWEP.Primary.ProjVelocity = 900

-- ==== PhysModify - 投射物物理属性修改钩子（默认不修改） ====
function SWEP:PhysModify(physobj)
end
