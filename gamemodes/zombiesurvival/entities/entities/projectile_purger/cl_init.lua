-- ============================================================================
-- projectile_purger/cl_init.lua - 净化弹投射物（客户端）
-- 负责：绘制绿色净化光粒拖尾；飞行时叠加发光精灵拖尾效果
-- ============================================================================
INC_CLIENT()

-- 飞行拖尾材质（水花效果）
local matGlow = Material("effects/splashwake1")
-- 粒子和精灵发光材质
local matGlow2 = Material("sprites/glow04_noz")
-- 零向量常量（缓存避免重复构造）
local vector_origin = vector_origin

-- ==== Draw - 客户端绘制：生成绿色粒子拖尾，飞行中附加发光精灵 ====
function ENT:Draw()
	local pos = self:GetPos()

	-- 在弹体位置生成 2 颗短命绿色光粒（随机速度扩散、渐隐）
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	for i=0, 1 do
		particle = emitter:Add(matGlow2, pos)
		particle:SetVelocity(VectorRand() * 45)
		particle:SetDieTime(0.15)
		particle:SetStartAlpha(75)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(192, 255, 130)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 弹体飞行中（有速度）时绘制三层层叠发光精灵：外圈水花、中圈绿色光晕、内核白光
	if self:GetVelocity() ~= vector_origin then
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 15, 15, Color(100, 170, 70, 100))
		render.SetMaterial(matGlow2)
		render.DrawSprite(pos, 35, 35, Color(155, 255, 100, 100))
		render.DrawSprite(pos, 25, 25, Color(255, 255, 255, 255))
	end
end
