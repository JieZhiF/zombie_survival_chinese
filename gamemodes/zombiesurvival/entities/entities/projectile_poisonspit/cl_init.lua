-- ============================================================================
-- projectile_poisonspit/cl_init.lua - 毒液吐射物（客户端）
-- 负责：将吐射物渲染为绿色，并在飞行时生成毒液拖尾粒子
-- ============================================================================
INC_CLIENT()

-- 粒子生成的节流时间戳
ENT.NextEmit = 0

-- ==== Initialize - 初始化：将吐射物着色为绿色毒液 ====
function ENT:Initialize()
	self:SetColor(Color(0, 255, 0, 255))
end

-- ==== Draw - 绘制本体并生成毒液拖尾粒子 ====
function ENT:Draw()
	self:DrawModel()

	-- 限制粒子生成频率为每 0.025 秒一次
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.025

	local pos = self:GetPos()

	-- 创建粒子发射器并设置近距离裁剪，保证粒子始终可见
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 毒液拖尾：随机寿命与起始大小，0.4~0.5 秒内淡出
	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(math.Rand(0.4, 0.5))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(3, 5))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	-- 粒子向吐射物后方飘散，方向与速度均带随机
	particle:SetVelocity((self:GetVelocity():GetNormalized() * -1 + VectorRand():GetNormalized()):GetNormalized() * math.Rand(16, 48))
	particle:SetLighting(true)
	particle:SetColor(30, 255, 30)

	-- 立即结束发射器并释放内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
