-- ============================================================================
-- init.lua - 点燃者武器服务端逻辑
-- 负责：定义主攻击发射的投射物类型与初速度，并给投射物施加随机的物理旋转
-- ============================================================================
INC_SERVER()

-- 主攻击发射的投射物实体（动能冲击地雷）
SWEP.Primary.Projectile = "projectile_impactmine_kin"
-- 投射物发射初速度
SWEP.Primary.ProjVelocity = 600

-- ==== PhysModify - 发射时给投射物施加随机角速度 ====
-- 使地雷在空中翻滚飞行，落地位置更具随机性
function SWEP:PhysModify(physobj)
	physobj:AddAngleVelocity(VectorRand():GetNormalized() * 90)
end
