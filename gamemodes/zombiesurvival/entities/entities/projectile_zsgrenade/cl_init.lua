-- ============================================================================
-- projectile_zsgrenade/cl_init.lua - 手雷投射物实体（客户端）
-- 负责：手雷冒烟粒子、引信滴答音效（随寿命加速）与引信闪光提示
-- ============================================================================

INC_CLIENT()

-- 下一次滴答音效时间戳
ENT.NextTickSound = 0
-- 上次滴答音效时间（用于引信闪光判定）
ENT.LastTickSound = 0
-- 冒烟粒子的发射节流时间戳
ENT.NextEmit = 0

-- ==== Initialize - 初始化 ====
-- 同步记录爆炸倒计时（与服务器一致，供引信音效计时）
function ENT:Initialize()
	self.DieTime = CurTime() + self.LifeTime
end

-- ==== Think - 每帧逻辑 ====
-- 周期性喷出灰色烟雾；并按剩余寿命加速播放滴答声
function ENT:Think()
	local curtime = CurTime()

	-- 每 0.05 秒在手雷上方生成一个漂移烟雾粒子
	if curtime >= self.NextEmit then
		self.NextEmit = curtime + 0.05

		local pos = self:GetPos() + self:GetUp() * 8
		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(16, 24)

		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(2, 14))
		particle:SetDieTime(math.Rand(0.6, 0.74))
		particle:SetStartAlpha(math.Rand(200, 220))
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(8, 10))
		particle:SetRoll(math.Rand(-0.2, 0.2))
		particle:SetColor(50, 50, 50)

		-- 结束发射器并手动触发垃圾回收释放资源
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end

	-- 播放滴答声，间隔随剩余时间缩短而加快，音调随之升高
	if curtime >= self.NextTickSound then
		local delta = self.DieTime - curtime

		self.NextTickSound = curtime + math.max(0.2, delta * 0.25)
		self.LastTickSound = curtime
		self:EmitSound("weapons/grenade/tick1.wav", 75, math.Clamp((1 - delta / self.LifeTime) * 160, 100, 160))
	end
end

-- 引信闪光用光晕材质
local matGlow = Material("sprites/glow04_noz")

-- ==== Draw - 绘制 ====
-- 绘制手雷模型，并在滴答瞬间显示红色闪光与点光源
function ENT:Draw()
	self:DrawModel()

	-- 滴答刚发生时（0.1 秒内）叠加红色闪光提示引信位置
	if math.abs(self.LastTickSound - CurTime()) < 0.1 then
		local pos = self:GetPos() + self:GetUp() * 8

		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 16, 16, COLOR_RED)

		-- 短暂红色动态光源
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.Brightness = 0.75
			dlight.Size = 64
			dlight.Decay = 256
			dlight.DieTime = CurTime() + 0.1
		end
	end
end
