-- ============================================================================
-- weapon_zs_minelayer/init.lua - 冲击地雷发射器（服务器端定义）
-- 负责：地雷投射物的生成参数与物理特性
-- ============================================================================
-- 服务器端专用（GMod 武器文件的标准服务器入口标记）
INC_SERVER()

-- 发射的投射物实体（冲击地雷）
SWEP.Primary.Projectile = "projectile_impactmine"
-- 地雷投射物初速度
SWEP.Primary.ProjVelocity = 600

-- ==== PhysModify - 调整地雷投掷时的物理状态 ====
function SWEP:PhysModify(physobj)
	-- 添加随机方向的角速度，让地雷在空中翻滚飞行
	physobj:AddAngleVelocity(VectorRand():GetNormalized() * 90)
end
