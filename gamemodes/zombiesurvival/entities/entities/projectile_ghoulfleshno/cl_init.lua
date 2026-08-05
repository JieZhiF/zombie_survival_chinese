-- ============================================================================
-- projectile_ghoulfleshno/cl_init.lua - 食尸鬼血肉投射物渲染（客户端）
-- 负责：设置粉紫血肉色调材质，并沿飞行路径持续发射烟雾粒子尾迹
-- ============================================================================
INC_CLIENT()

-- 下次发射粒子的时间戳（用于限制发射频率）
ENT.NextEmit = 0

-- ==== Initialize - 设置投射物客户端外观 ====
function ENT:Initialize()
	-- 粉紫色调，模拟腐肉外观
	self:SetColor(Color(200, 135, 165, 255))
	self:SetMaterial("models/seagull/seagull")
end

-- ==== Draw - 绘制模型并发射烟雾粒子尾迹 ====
function ENT:Draw()
	self:DrawModel()

	-- 每 0.025 秒发射一次粒子，控制性能开销
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.025

	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 创建烟雾粒子：短寿命、从全透明渐变消失、随机翻滚
	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(math.Rand(0.4, 0.5))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(3, 5))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	-- 速度方向 = 飞行反方向加随机扰动，形成向后飘散的尾迹
	particle:SetVelocity((self:GetVelocity():GetNormalized() * -1 + VectorRand():GetNormalized()):GetNormalized() * math.Rand(16, 48))
	particle:SetLighting(true)
	particle:SetColor(200, 135, 165)

	-- 结束发射器并主动触发一次 GC，避免粒子对象堆积
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
