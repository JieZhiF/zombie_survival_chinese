-- ============================================================================
-- env_molotovflame/cl_init.lua - 燃烧瓶火焰环境实体（客户端）
-- 负责：火焰音效循环、粒子烟雾效果与动态光源渲染
-- ============================================================================

INC_CLIENT()

-- 粒子发射节流时间戳
ENT.NextEmit = 0
-- 是否触发一次受击尘土音效（由 Think 中周期性置位）
ENT.DoEmit = false

-- ==== Initialize - 初始化 ====
-- 创建循环火焰燃烧音效
function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")
end

-- ==== Think - 每帧逻辑 ====
-- 周期触发尘土声效，并持续播放环境火焰音
function ENT:Think()
	-- 节流标记已置位时播放一次短促的尘土音效
	if self.DoEmit then
		self.DoEmit = false

		self:EmitSound("ambient/machines/thumper_dust.wav", 70, 170)
	end

	-- 循环播放火焰音效（音量 0.8，音调随当前时间轻微波动模拟火焰跳动）
	self.AmbientSound:PlayEx(0.80, 60 + CurTime() % 1)
end

-- ==== OnRemove - 移除时 ====
-- 停止火焰音效，防止残留声音
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Draw - 渲染 ====
-- 绘制动态火光并周期性生成上升烟雾粒子
function ENT:Draw()
	local time = CurTime()
	local pos = self:GetPos()

	-- 创建暖橙色动态光源照亮周围环境
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 190
		dlight.b = 30
		dlight.Brightness = 8
		dlight.Size = self.Radius / 2
		dlight.Decay = self.Radius * 2
		dlight.DieTime = time + 0.75
	end

	-- 按间隔节流生成烟雾粒子
	if time < self.NextEmit then return end
	self.NextEmit = time + 0.65
	self.DoEmit = true

	local particle
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	-- 在火焰半径内随机位置生成 75 个扩散烟粒
	for i=1, 75 do
		local angler = AngleRand()
		local dist = math.Rand(0, self.Radius)
		particle = emitter:Add("effects/fire_cloud"..math.random(1, 2), pos + Vector(math.cos(angler.y) * dist, math.sin(angler.y) * dist, 0))
		particle:SetColor(255, 220, 140)
		particle:SetDieTime(math.Rand(1.35, 1.7))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(18, 24))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetCollide(true)
	end

	-- 结束发射器并手动触发垃圾回收以释放资源
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
