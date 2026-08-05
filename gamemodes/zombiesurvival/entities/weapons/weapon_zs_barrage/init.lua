-- ============================================================================
-- weapon_zs_barrage/init.lua - 弹幕榴弹发射器（服务端）
-- 负责：定义弹体（弹跳手雷）与出膛速度
-- ============================================================================
INC_SERVER()

-- 弹体：弹跳手雷（可弹跳多次后爆炸）
SWEP.Primary.Projectile = "projectile_grenade_bouncy"
-- 出膛速度
SWEP.Primary.ProjVelocity = 600

-- ==== PhysModify - 弹体物理调整（空实现） ====
function SWEP:PhysModify(physobj)
end
