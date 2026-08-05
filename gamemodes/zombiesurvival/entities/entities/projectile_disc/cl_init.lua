-- ============================================================================
-- cl_init.lua - 电光飞盘投射物（客户端）：发光绘制与拖尾粒子
-- 负责：以蓝色调绘制飞盘，并持续喷发发光粒子拖尾
-- ============================================================================
INC_CLIENT()

-- 发光粒子材质
local matGlow = Material("sprites/glow04_noz")

-- ==== Draw - 绘制：蓝色染色 + 发光粒子拖尾 ====
function ENT:Draw()
	-- 整体染成蓝色后绘制模型
	render.SetColorModulation(0, 0.608, 1)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)

	local pos = self:GetPos()

	-- 每帧喷发两个发光粒子
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	for i=0, 1 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(125)
		particle:SetEndAlpha(0)
		particle:SetStartSize(6)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(110, 210, 255)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Initialize - 初始化：缩小模型并关闭阴影 ====
function ENT:Initialize()
	self:SetModelScale(0.3, 0)
	self:DrawShadow(false)
end
