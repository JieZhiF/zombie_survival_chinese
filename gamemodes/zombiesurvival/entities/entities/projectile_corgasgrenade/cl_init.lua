-- ============================================================================
-- projectile_corgasgrenade/cl_init.lua - 腐蚀毒气手雷（客户端）
-- 负责：手雷着色渲染；毒气排放期间播放气体嘶嘶声，并持续喷出
--       向上飘散的紫色烟雾粒子（扩散半径随机）
-- ============================================================================
INC_CLIENT()

-- 下一次粒子发射的时间戳（限制特效频率）
ENT.NextEmit = 0

-- ==== Initialize - 创建气体环境音 ====
function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/gas/steam2.wav")
end

-- ==== Think - 毒气排放期间播放嘶嘶声（音调随时间轻微变化） ====
function ENT:Think()
	-- 未排放毒气时不发声
	if not self:GetGasEmit() then return end

	self.AmbientSound:PlayEx(0.80, 250 + CurTime() % 1)
end

-- ==== OnRemove - 停止气体音 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Draw - 绘制紫色手雷本体与毒气云粒子 ====
function ENT:Draw()
	-- 手雷本体染成紫色
	render.SetColorModulation(0.35, 0.26, 0.41)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)

	-- 未排放毒气时只画本体
	if not self:GetGasEmit() then return end

	local time = CurTime()

	-- 每 0.07 秒发射一轮粒子
	if time < self.NextEmit then return end
	self.NextEmit = time + 0.07

	local particle
	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	-- 紫色烟雾：向上飘升，水平方向按半径随机扩散
	local vel = Vector(0, 0, 170)
	for i=1, 7 do
		local angler = AngleRand()
		local dist = math.Rand(0, self.Radius)
		particle = emitter:Add(math.random(2) == 1 and "particle/smokesprites_0003" or "particle/smokestack", pos)
		particle:SetColor(110, 70, 110)
		particle:SetVelocity(vel * math.Rand(0.5, 1) + Vector(math.cos(angler.y) * dist, math.sin(angler.y) * dist, 0)/1.21)
		particle:SetGravity(vel * -0.95)
		particle:SetDieTime(math.Rand(1.85, 2.4))
		particle:SetStartAlpha(math.random(150, 200))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(11, 19))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetCollide(true)
	end

	-- 结束粒子发射并立即触发一次垃圾回收以降低粒子开销
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
