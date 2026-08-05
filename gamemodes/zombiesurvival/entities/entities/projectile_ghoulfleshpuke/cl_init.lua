-- ============================================================================
-- projectile_ghoulfleshpuke/cl_init.lua - 食尸鬼血肉呕吐物投射物（客户端）
-- 负责：设置投射物渲染颜色/材质（淡黄色），飞行时以 0.025 秒间隔
--       持续发射紫色烟雾尾迹粒子
-- ============================================================================
INC_CLIENT()

-- 下一次粒子发射的时间戳（避免每帧都发射）
ENT.NextEmit = 0

-- ==== Initialize - 初始化渲染外观：淡黄色实体颜色与海鸥材质 ====
function ENT:Initialize()
	self:SetColor(Color(255, 255, 145, 255))
	self:SetMaterial("models/seagull/seagull")
end

-- ==== Draw - 绘制模型并发射飞行尾迹粒子 ====
function ENT:Draw()
	self:DrawModel()

	-- 按 0.025 秒间隔控制粒子发射频率
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.025

	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 烟雾粒子：随机生命周期/大小，沿飞行反方向并叠加随机偏移形成拖尾
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
	particle:SetColor(190, 125, 255)

	-- 结束粒子发射并立即触发一次垃圾回收以降低粒子开销
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
