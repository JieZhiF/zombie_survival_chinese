-- ============================================================================
-- cl_init.lua - 符石传送状态（客户端）
-- 负责：播放传送蓄力音效，并沿传送方向持续发射吸入式粒子特效
-- ============================================================================
INC_CLIENT()

-- 传送蓄力的两段音效（先吸入后机械蓄力）与粒子材质
ENT.Sound1 = Sound("ambient/levels/labs/teleport_preblast_suckin1.wav")
ENT.Sound2 = Sound("ambient/levels/labs/teleport_mechanism_windup3.wav")
ENT.ParticleMaterial = "sprites/glow04_noz"

-- ==== Initialize - 初始化客户端特效 ====
-- 创建两段蓄力音效（仅本地玩家可听到），并把状态引用挂到主人身上
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	local owner = self:GetOwner()

	-- 创建传送音效对象；仅当主人是本地玩家时播放（他人听不到）
	self.TeleportingSound = CreateSound(self, self.Sound1)
	self.TeleportingSound2 = CreateSound(self, self.Sound2)
	if owner:IsValid() and owner == MySelf then
		self.TeleportingSound:PlayEx(1, 100 / (owner.SigilTeleportTimeMul or 1))
		self.TeleportingSound2:PlayEx(0.22, 245)
	end

	-- 首次附加时初始化开始时间
	if self:GetStartTime() == 0 then
		self:SetStartTime(CurTime())
	end

	-- 记录当前传送状态引用到主人，供其他系统读取
	owner.SigilTeleport = self
end

-- ==== OnRemove - 实体移除时停止所有音效 ====
function ENT:OnRemove()
	self.TeleportingSound:Stop()
	self.TeleportingSound2:Stop()
end

-- ==== Think - 每帧发射传送吸入粒子 ====
-- 仅本地玩家处理：从自身包围盒内随机点向目标符石方向发射蓝色粒子
function ENT:Think()
	local owner = self:GetOwner()
	if owner ~= LocalPlayer() then return end

	local sigil = self:GetTargetSigil()
	if not sigil or not sigil:IsValid() then return end

	-- 计算主人指向目标符石的方向
	local ownerpos = owner:GetPos()
	local sigilpos = sigil:GetPos()
	local dir = sigilpos - ownerpos
	dir:Normalize()

	-- 从主人碰撞盒内取随机起点，让粒子像从身体各处被吸走
	local aa, bb = owner:WorldSpaceAABB()
	local startpos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))

	local emitter = ParticleEmitter(startpos)
	emitter:SetNearClip(24, 32)

	-- 配置吸入粒子：朝目标符石加速飞行，逐渐变亮变大后消失
	local particle = emitter:Add(self.ParticleMaterial, startpos)
	particle:SetDieTime(math.Rand(1.5, 4))
	particle:SetVelocity(dir * math.min(1400, ownerpos:Distance(sigilpos)))
	particle:SetStartAlpha(100)
	particle:SetEndAlpha(255)
	particle:SetStartSize(math.Rand(1, 2))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-2, 2))
	if math.random(4) ~= 1 then
		self:SetParticleColor(particle)
	end

	-- 结束发射器并触发一次增量 GC（本模式性能惯例）
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	self:NextThink(CurTime() + 0.05)
	return true
end

-- ==== SetParticleColor - 给粒子设置默认蓝色 ====
function ENT:SetParticleColor(particle)
	particle:SetColor(38, 102, 255)
end

-- ==== Draw - 空实现（纯粒子效果，无模型绘制）====
function ENT:Draw()
end
