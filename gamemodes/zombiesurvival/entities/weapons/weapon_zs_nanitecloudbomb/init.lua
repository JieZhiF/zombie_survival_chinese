-- ============================================================================
-- weapon_zs_nanitecloudbomb/init.lua - 纳米虫云炸弹（服务器端逻辑）
-- 负责：指定投掷出的弹体与抛投速度
-- ============================================================================
INC_SERVER()

-- 投掷出的纳米虫云弹体
SWEP.ThrownProjectile = "projectile_nanitecloudbomb"
-- 投掷时的旋转角速度
SWEP.ThrowAngVel = 30
-- 投掷初速度
SWEP.ThrowVel = 600
