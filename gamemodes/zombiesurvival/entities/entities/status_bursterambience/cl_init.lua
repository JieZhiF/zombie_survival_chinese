-- ============================================================================
-- status_bursterambience/cl_init.lua - 爆裂者（自爆僵尸）氛围状态（客户端）
-- 负责：为拥有者循环播放呼吸音效（音调随正弦波动），并持续喷出
--       上浮的绿色毒雾粒子，警示爆裂者接近
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组，保证粒子/透明效果正确排序
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 下次粒子发射时间（节流用）
ENT.NextEmit = 0

-- ==== Initialize - 初始化：开始播放呼吸环境音 ====
function ENT:Initialize()
	self:DrawShadow(false)

	-- 循环播放低沉呼吸声
	self.AmbientSound = CreateSound(self, "npc/zombie_poison/pz_breathe_loop2.wav")
	self.AmbientSound:PlayEx(0.55, 85)
end

-- ==== OnRemove - 移除：停止呼吸音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 音效维持：随正弦波动微调音调，维持循环播放 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		-- 音调在 85±1 之间波动，制造呼吸起伏感
		self.AmbientSound:PlayEx(0.55, 85 + math.sin(RealTime()))
	end
end

-- ==== Draw - 毒雾特效：每 0.12 秒在拥有者身上喷出一缕绿色烟雾 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者失效或处于出生保护时不显示
	if not owner:IsValid() or owner.SpawnProtection then return end

	-- 以身体中心略高处为发射原点
	local pos = owner:WorldSpaceCenter()
	pos.z = pos.z + 5

	-- 每 0.12 秒发射一次，避免每帧生成粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.12

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 绿色毒雾粒子：上浮、受重力回落并碰撞反弹
	local particle = emitter:Add("particle/smokestack", pos + VectorRand() * 5)
	particle:SetDieTime(math.Rand(0.95, 1.35))
	particle:SetStartAlpha(190)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(17, 19))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-3, 3))
	particle:SetVelocity(Vector(0, 0, 45))
	particle:SetGravity(Vector(0, 0, -65))
	particle:SetCollide(true)
	particle:SetBounce(0.45)
	particle:SetAirResistance(12)
	particle:SetColor(100, 235, 100)
	particle:SetLighting(true)

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
