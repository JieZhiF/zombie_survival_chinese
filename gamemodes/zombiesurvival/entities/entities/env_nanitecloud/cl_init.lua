-- ============================================================================
-- env_nanitecloud/cl_init.lua - 纳米虫云环境实体（客户端）
-- 负责：每秒在实体位置爆发两批纳米虫光点粒子（快速外扩的紫色虫群 +
--       缓慢漂浮的淡蓝色光点），并伴随扫描音效与环境嗡鸣
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（节流用）
ENT.NextEmit = 0
-- 本次绘制帧是否触发扫描音效（由 Draw 置位、Think 消费）
ENT.DoEmit = false

-- ==== Initialize - 初始化：创建环境嗡鸣音效 ====
function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "items/suitchargeno1.wav")
end

-- ==== Think - 音效：播放扫描音并维持环境嗡鸣 ====
function ENT:Think()
	-- 绘制帧请求的扫描音效在此消费
	if self.DoEmit then
		self.DoEmit = false

		self:EmitSound("npc/scanner/scanner_scan2.wav", 70, 50)
	end

	-- 环境嗡鸣，音调随时间缓慢漂移
	self.AmbientSound:PlayEx(0.70, 60 + CurTime() % 1)
end

-- ==== OnRemove - 移除：停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Draw - 纳米虫特效：每秒爆发一批紫色虫群与淡蓝光点粒子 ====
function ENT:Draw()
	local time = CurTime()
	local pos = self:GetPos()

	-- 每秒触发一次粒子爆发，并请求播放扫描音
	if time < self.NextEmit then return end
	self.NextEmit = time + 1
	self.DoEmit = true

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	-- 快速外扩的紫色虫群：沿随机方向高速飞散后消散
	for i=1, 95 do
		local dir = VectorRand():GetNormalized()
		particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity(dir * 205)
		particle:SetGravity(dir * -210)
		particle:SetDieTime(0.7)
		particle:SetColor(225,150,255)
		particle:SetStartAlpha(80)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(15)
		particle:SetCollide(false)
		particle:SetBounce(0)
	end

	-- 缓慢漂浮的淡蓝色光点：长时间存在并缓慢膨胀
	for i=1, 30 do
		local dir = VectorRand():GetNormalized()
		particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(math.Rand(1.8, 2.5))
		particle:SetColor(145,155,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(15)
		particle:SetEndSize(0)
		particle:SetGravity(dir * -6)
		particle:SetVelocity(dir * 5)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
