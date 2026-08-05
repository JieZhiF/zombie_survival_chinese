-- ============================================================================
-- weapon_zs_novablaster/init.lua - 脉冲手枪「新星爆破」（Nova Blaster）服务器端
-- 负责：指定发射的脉冲投射物与高速初速
-- ============================================================================

INC_SERVER()

-- 发射的脉冲投射物实体与初速度（1500 单位/秒）
SWEP.Primary.Projectile = "projectile_nova"
SWEP.Primary.ProjVelocity = 1500
