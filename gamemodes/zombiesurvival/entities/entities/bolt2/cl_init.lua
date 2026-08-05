-- ============================================================================
-- cl_init.lua - 闪电箭投射物（客户端）
-- 负责：绘制悬浮球模型与随机大小的白色发光体（视觉表现，无服务端逻辑）
-- ============================================================================
include('shared.lua')

-- ==== Initialize - 初始化客户端模型 ====
-- 载入爆炸粒子定义、设置悬浮球模型并定义白色发光颜色
function ENT:Initialize()	
game.AddParticles( "particles/chappi_explosion.pcf" )
self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
White = Color(180,180,255)
end

-- ==== Draw - 绘制模型与发光体 ====
-- 绘制模型（尺寸每帧随机缩放），并在中心叠加两层随机大小的白色光晕
function ENT:Draw()
self:DrawModel()
self.Entity:SetModelScale(math.Rand(0.3,1.2),0)
render.SetMaterial(Material("sprites/glow04_noz"))
render.DrawSprite(self.Entity:GetPos(),math.Rand(300,100),40,White)
render.DrawSprite(self.Entity:GetPos(),math.Rand(300,100),40,White)
end

