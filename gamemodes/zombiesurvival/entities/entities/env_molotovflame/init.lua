INC_SERVER()

ENT.TickTime = 0.45
ENT.Ticks = 12
ENT.Damage = 7

function ENT:Initialize()
	self:DrawShadow(false)

	self:Fire("burn", "", self.TickTime)
	self:Fire("kill", "", self.TickTime * self.Ticks + 0.01)

	self:DropToFloor()
end

function ENT:AcceptInput(name, activator, caller, arg)
	if name ~= "burn" then return end

	self.Ticks = self.Ticks - 1

	local owner = self:GetOwner()
	if not owner:IsValidLivingHuman() then owner = self end

	local vPos = self:GetPos()
	local ignited = {}
	for _, ent in pairs(ents.FindInSphere(vPos, self.Radius)) do
		if ent and (ent:IsValidLivingPlayer() and (ent:Team() == TEAM_UNDEAD or ent == owner)) and WorldVisible(vPos, ent:NearestPoint(vPos)) then
			ent:Ignite(2)
			ent:SetNWFloat("FireDieTime", CurTime() + 2)
			ignited[#ignited + 1] = ent

			if owner:IsValidLivingHuman() then
				ent:AddLegDamage(7)
				ent:TakeSpecialDamage(self.Damage, DMG_BURN, owner, self)
			end
		end
	end

	-- 一次性查询全部火焰实体，按父级匹配（避免对每个命中玩家重复全图查询）
	if #ignited > 0 then
		for _, fire in pairs(ents.FindByClass("entityflame")) do
			if fire:IsValid() and fire:GetParent():IsValid() then
				for _, ent in ipairs(ignited) do
					if fire:GetParent() == ent then
						fire:SetOwner(owner)
						fire:SetPhysicsAttacker(owner)
						fire.AttackerForward = owner
						break
					end
				end
			end
		end
	end

	if self.Ticks > 0 then
		self:Fire("burn", "", self.TickTime)
	end

	return true
end
