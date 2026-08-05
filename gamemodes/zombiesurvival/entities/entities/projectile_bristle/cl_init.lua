-- ============================================================================
-- projectile_bristle/cl_init.lua - 荆棘投射物（客户端）
-- 负责：绘制荆棘刺模型，并在飞行过程中以固定间隔向后
--       发射橙色烟尘粒子，模拟荆棘刺的飞行轨迹
-- ============================================================================

-- 客户端加载入口（INC_CLIENT 系列约定写法）
INC_CLIENT()

-- 粒子发射间隔计时器
ENT.NextEmit = 0

-- ==== Initialize - 客户端初始化 ====
-- 覆盖为橙色外观（与服务器端初始化时的绿色区分）
function ENT:Initialize()
	self:SetColor(Color(240, 120, 30, 255))
end

-- ==== Draw - 绘制模型与飞行烟尘 ====
function ENT:Draw()
	self:DrawModel()

	-- 控制粒子发射频率（约每秒 40 次）
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.025

	local pos = self:GetPos()

	-- 创建粒子发射器
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 向后喷射的烟尘粒子：随距离渐隐、渐小，带随机旋转
	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(math.Rand(0.5, 0.6))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(2, 4))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetVelocity((self:GetVelocity():GetNormalized() * -1 + VectorRand():GetNormalized()):GetNormalized() * math.Rand(36, 48))
	particle:SetLighting(true)
	particle:SetColor(240, 120, 30)

	-- 结束发射并触发垃圾回收，避免粒子对象堆积
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
