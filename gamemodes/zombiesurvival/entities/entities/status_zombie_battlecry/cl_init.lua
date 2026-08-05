-- ============================================================================
-- status_zombie_battlecry/cl_init.lua - 僵尸战吼状态（客户端）
-- 负责：战吼期间的心跳音效与红色气浪粒子表现；粒子出生点随机取身体
--       骨骼位置（本地第一人称不可见自身时取模型包围盒随机点）
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流时间戳（限频控制）
ENT.ParticleTimer = 0

-- ==== OnInitialize - 初始化：扩大渲染边界并播放心跳音效 ====
function ENT:OnInitialize()
	-- 扩大渲染边界，覆盖战吼粒子的高度范围
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))

	-- 仅当战吼属于本地玩家时才播放心跳音效
	if self:GetOwner() ~= MySelf then return end
	self.AmbientSound = CreateSound(self, "player/heartbeat1.wav")
	self.AmbientSound:PlayEx(0.85, 150)
end

-- ==== OnRemove - 清理：停止心跳音效并调用基类移除逻辑 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	-- 本地玩家自己的战吼结束时停止音效
	if owner == MySelf then
		self.AmbientSound:Stop()
	end

	-- 调用基类（status__base）的 OnRemove 清理逻辑
	self.BaseClass.OnRemove(self)
end


-- 随机取玩家身体某根骨骼的世界坐标，用作粒子出生位置
local function GetRandomBonePos(pl)
	-- 非本地玩家，或本地玩家可见自身模型时：从随机骨骼取点
	if pl ~= MySelf or pl:ShouldDrawLocalPlayer() then
		local bone = pl:GetBoneMatrix(math.random(0,25))
		if bone then
			return bone:GetTranslation()
		end
	end

	-- 本地第一人称视角下退回枪口位置
	return pl:GetShootPos()
end

-- ==== DrawTranslucent - 半透明渲染：从身体随机位置冒出红色气浪粒子 ====
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end
	-- 出生保护期间不显示战吼粒子
	if ent.SpawnProtection then return end

	-- 本地玩家第一人称（看不到自己模型）时从模型包围盒内随机取点
	local pos
	if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
		local aa, bb = ent:WorldSpaceAABB()
		pos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))
	else
		pos = GetRandomBonePos(ent)
	end

	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(24, 32)

	-- 按 0.065 秒间隔限频生成红色气浪粒子
	if self.ParticleTimer <= CurTime() then
		self.ParticleTimer = CurTime() + 0.065

		local scale = MySelf:GetModelScale()

		local particle = emitter:Add("sprites/glow04_noz", pos + VectorRand():GetNormalized() * 2)
		particle:SetDieTime(0.65)
		particle:SetStartSize(12 * scale)
		particle:SetEndSize(5 * scale)
		particle:SetColor(255, 40, 0)
		particle:SetStartAlpha(90)
		particle:SetEndAlpha(0)
		particle:SetGravity(Vector(0, 0, 256))
		particle:SetVelocity(ent:GetVelocity())
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(math.random(-5, 5))

	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
