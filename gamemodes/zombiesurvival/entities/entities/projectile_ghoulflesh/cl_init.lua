-- ============================================================================
-- projectile_ghoulflesh/cl_init.lua - 食尸鬼腐肉投射物（客户端）
-- 负责：绘制黄色腐肉球本体，并沿飞行反方向持续拖出黄色烟雾尾迹
-- ============================================================================
INC_CLIENT()

-- 尾迹粒子发射节流时间戳
ENT.NextEmit = 0

-- ==== Initialize - 初始化：应用黄色调 ====
function ENT:Initialize()
	self:SetColor(Color(255, 255, 0, 255))
end

-- ==== Draw - 绘制本体并周期性发射向后飘散的黄色烟雾 ====
function ENT:Draw()
	self:DrawModel()

	-- 每 0.025 秒发射一颗尾迹粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.025

	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 配置粒子：向后（飞行反方向）混合随机偏移飘散，受光照影响
	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(math.Rand(0.4, 0.5))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(3, 5))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetVelocity((self:GetVelocity():GetNormalized() * -1 + VectorRand():GetNormalized()):GetNormalized() * math.Rand(16, 48))
	particle:SetLighting(true)
	particle:SetColor(255, 255, 0)

	-- 释放发射器并主动触发一步 GC
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
