-- ============================================================================
-- status_redmarrow/cl_init.lua - 红骨髓状态（客户端）
-- 负责：红骨髓僵尸的血液喷涌视觉表现——实体位置跟随拥有者眼睛，定期
--       从身体随机位置喷出血滴粒子；移除时清理拥有者身上的状态引用
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组（血液粒子需要混合绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 粒子发射节流时间戳（限频控制）
ENT.ParticleTimer = 0

-- ==== OnInitialize - 初始化：扩大渲染边界 ====
function ENT:OnInitialize()
	-- 扩大渲染边界，覆盖血液粒子的高度范围
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))
end

-- ==== Think - 每帧跟随拥有者眼睛位置，保持粒子发射器贴近玩家 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 实体位置同步到拥有者眼睛位置
	if owner:IsValid() then self:SetPos(owner:EyePos()) end
end

-- ==== OnRemove - 清理拥有者身上的状态引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	-- 拥有者记录的同类状态仍指向自身时清空引用
	if owner:IsValid() and owner[self:GetClass()] == self then
		owner[self:GetClass()] = nil
	end
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

-- ==== DrawTranslucent - 半透明渲染：定期从身体随机位置喷出血滴粒子 ====
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	-- 按 0.1 秒间隔限频，每批喷出 12 滴血
	if self.ParticleTimer < CurTime() then
		self.ParticleTimer = CurTime() + 0.1

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(24, 32)

		local pos, aa, bb
		for i = 0, 11 do
			-- 本地第一人称（看不到自己模型）时从模型包围盒内随机取点，
			-- 否则取随机骨骼位置
			if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
				aa, bb = ent:WorldSpaceAABB()
				pos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))
			else
				pos = GetRandomBonePos(ent)
			end

			-- 使用随机血溅精灵，血滴受重力下落
			local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos + VectorRand():GetNormalized() * 5)
			particle:SetDieTime(math.Rand(0.75, 0.85))
			particle:SetStartSize(11)
			particle:SetEndSize(1)
			particle:SetColor(200,30,30)
			particle:SetStartAlpha(235)
			particle:SetEndAlpha(0)
			particle:SetVelocity(ent:GetVelocity())
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(math.random(5, -5))
			particle:SetGravity(Vector(0, 0, -200))
		end

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end
