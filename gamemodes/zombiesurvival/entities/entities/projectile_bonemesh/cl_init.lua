-- ============================================================================
-- projectile_bonemesh/cl_init.lua - 骨网投射物（客户端）
-- 负责：放大模型并替换为血肉材质渲染骨块外观；
--       飞行过程中以固定间隔向后喷射血滴粒子，模拟骨网飞行轨迹
-- ============================================================================

-- 客户端加载入口（INC_CLIENT 系列约定写法）
INC_CLIENT()

-- 粒子发射间隔计时器
ENT.NextEmit = 0

-- ==== Initialize - 客户端初始化 ====
function ENT:Initialize()
	-- 放大骨块模型至 2.5 倍
	self:SetModelScale(2.5, 0)
	-- 替换为血肉材质（半透明肉质外观）
	self:SetMaterial("models/flesh")
end

-- ==== Draw - 绘制模型与飞行血滴 ====
function ENT:Draw()
	self:DrawModel()

	-- 飞行中（速度 ≥ 16 单位）且到发射间隔时喷射血滴
	if CurTime() >= self.NextEmit and self:GetVelocity():LengthSqr() >= 256 then
		self.NextEmit = CurTime() + 0.05

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(16, 24)

		-- 随机血喷溅精灵，缓慢向外飘散后缩小消失
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), self:GetPos())
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(8, 16))
		particle:SetDieTime(1)
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(230)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetColor(255, 0, 0)
		particle:SetLighting(true)

		-- 结束发射并触发垃圾回收，避免粒子对象堆积
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end
