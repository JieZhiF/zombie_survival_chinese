-- ============================================================================
-- weapon_zs_zeus/init.lua - 宙斯（服务端入口）
-- 负责：指定发射的投射物（电弧弩箭）及其初速度
-- ============================================================================
INC_SERVER()

-- 发射的投射物实体：projectile_arrow_zea（附带闪电链效果）
SWEP.Primary.Projectile = "projectile_arrow_zea"
-- 投射物初速度（单位/秒）
SWEP.Primary.ProjVelocity = 1300
