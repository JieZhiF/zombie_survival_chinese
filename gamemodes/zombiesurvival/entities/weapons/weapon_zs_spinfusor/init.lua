-- ============================================================================
-- weapon_zs_spinfusor/init.lua - 旋转掷弹枪（服务器端）
-- 负责：指定发射的榴弹实体（projectile_disc）与出膛速度
-- ============================================================================
INC_SERVER()

-- 发射的投掷物实体：圆盘榴弹
SWEP.Primary.Projectile = "projectile_disc"
-- 出膛速度（单位/秒）
SWEP.Primary.ProjVelocity = 1500
