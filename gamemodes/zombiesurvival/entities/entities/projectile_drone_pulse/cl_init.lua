-- ============================================================================
-- projectile_drone_pulse/cl_init.lua - 无人机脉冲弹（客户端）
-- 负责：飞行时绘制蓝白发光精灵，销毁时爆发蓝色能量粒子
-- ============================================================================
INC_CLIENT()

-- 发光材质：水面涟漪光晕与光点精灵
local matGlow = Material("effects/splashwake1")
local matGlow2 = Material("sprites/glow04_noz")
-- 缓存零向量用于判断是否在飞行
local vector_origin = vector_origin

-- ==== Draw - 绘制：飞行中渲染双层发光精灵 ====
function ENT:Draw()
	-- 仅在弹体运动时显示光效（停止后不绘制）
	if self:GetVelocity() ~= vector_origin then
		-- 外层蓝色光晕 + 内层白色光点
		render.SetMaterial(matGlow)
		render.DrawSprite(self:GetPos(), 6, 7, Color(55, 100, 255, 100))
		render.SetMaterial(matGlow2)
		render.DrawSprite(self:GetPos(), 8, 8, Color(255, 255, 255, 255))
	end
end

-- ==== OnRemove - 移除时爆发 20 个蓝色能量粒子 ====
function ENT:OnRemove()
	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 向随机方向喷射 20 个短暂存活的蓝色光粒
	for i=0, 19 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 25)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(125)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(3, 4))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(100, 125, 255)
	end
	-- 结束发射器并释放内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
