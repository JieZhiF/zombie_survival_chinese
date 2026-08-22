-- ============================================================================
-- prop_thrownskeleton/init.lua - 被投掷的强化骷髅巢穴（服务端）
-- 负责：骨骼模型与物理；落地后变为强化骷髅的重生巢穴
-- ============================================================================

INC_SERVER()

ENT.AlwaysProjectile = true

ENT.Created = 0

-- ==== Initialize - 初始化骨骼模型与物理 ====
function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS_spine.mdl")
	self:SetColor(Color(215, 205, 190))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetModelScale(1.3, 0)
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:CollisionRulesChanged()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(1)
		phys:EnableMotion(true)
		phys:Wake()
	end

	self.Created = CurTime()

	self:Fire("kill", "", 20)
end

-- ==== Think - 落地后标记为巢穴并广播 ====
function ENT:Think()
	if not self:GetSettled() and CurTime() >= self.Created + 0.75 and self:GetVelocity():LengthSqr() <= 256 then
		self:SetSettled(true)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

		net.Start(NET_MSG.NESTBUILT)
		net.Broadcast()
	end
end

-- ==== OnTakeDamage - 被人类伤害时销毁 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	if dmginfo:GetDamage() >= 1 and not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD) then
		self:Destroy()
	end
end

-- ==== Destroy - 销毁巢穴 ====
function ENT:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	self:Fire("kill", "", 0.01)
end

-- ==== OnRemove - 移除时播放骨骼音效 ====
function ENT:OnRemove()
	if self.Destroyed then
		self:EmitSound("npc/barnacle/neck_snap1.wav", 70, math.random(135, 150))
	end
end

-- ==== UpdateTransmitState - 始终传输 ====
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
