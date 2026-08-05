-- ============================================================================
-- projectile_mediccloudbomb - 医疗云炸弹投射物实体（客户端）
-- 负责：绘制半透明模型并叠加绿色光斑精灵，标示医疗炸弹的飞行位置
-- ============================================================================
INC_CLIENT()

-- 渲染组：透明实体
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 光斑精灵材质（叠加混合）
local matGlow = Material("sprites/light_glow02_add")
-- ==== DrawTranslucent - 绘制模型本体，并在其位置叠加绿色发光精灵 ====
function ENT:DrawTranslucent()
	self:DrawModel()

	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), 64, 64, COLOR_GREEN)
end
