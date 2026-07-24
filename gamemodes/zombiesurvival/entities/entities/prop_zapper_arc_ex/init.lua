INC_SERVER()
function ENT:FindZapperTarget(pos, owner)
	local target
	local targethealth = 99999
	local isheadcrab

	for k, ent in pairs(ents.FindInSphere(pos, 500 * (owner.FieldRangeMul or 1))) do
		if ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
			isheadcrab = ent:IsHeadcrab()
			if (isheadcrab or ent:Health() < targethealth) and TrueVisibleFilters(pos, ent:NearestPoint(pos), self, ent) then
				targethealth = ent:Health()
				target = ent

				if isheadcrab then
					break
				end
			end
		end
	end

	return target
end
function ENT:HitTarget(ent, damage, owner)
	ent:AddLegDamageExt(self.LegDamage, owner, self, SLOWTYPE_PULSE)

	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end
	ent:TakeSpecialDamage(damage, DMG_SHOCK, owner, self)
	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end

	self:EmitSound("ambient/office/zap1.wav", 70, 160, 0.6, CHAN_AUTO)
end

function ENT:Think()
	if self.Destroyed then
		self:Remove()
	end

	if CurTime() < self:GetNextZap() or CurTime() < self.NextZapCheck then return end

	local curammo = self:GetAmmo()
	local owner = self:GetObjectOwner()
	if curammo >= 1 and owner:IsValid() then
		self.NextZapCheck = CurTime() + 0.4

		local pos = self:LocalToWorld(Vector(0, 0, 29))
		local target = self:FindZapperTarget(pos, owner)

		local shocked = {}
		if target then
			self:SetAmmo(curammo - 1)

			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			self:SetNextZap(CurTime() + 0.1 * (owner.FieldDelayMul or 1))
			self:HitTarget(target, self.Damage, owner)

			local effectdata = EffectData()
				effectdata:SetOrigin(target:WorldSpaceCenter())
				effectdata:SetStart(pos)
				effectdata:SetEntity(self)
			util.Effect("tracer_zapper", effectdata)

			shocked[target] = true
			for i = 1, 3 do
				local tpos = target:WorldSpaceCenter()

				for k, ent in pairs(ents.FindInSphere(tpos, 50)) do
					if not shocked[ent] and ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
						if WorldVisible(tpos, ent:NearestPoint(tpos)) then
							shocked[ent] = true
							target = ent

							timer.Simple(i * 0.15, function()
								if not ent:IsValid() or not ent:IsValidLivingZombie() or not WorldVisible(tpos, ent:NearestPoint(tpos)) then return end

								self:HitTarget(ent, self.Damage / (i + 0.5), owner)

								local worldspace = ent:WorldSpaceCenter()
								effectdata = EffectData()
									effectdata:SetOrigin(worldspace)
									effectdata:SetStart(tpos)
									effectdata:SetEntity(target)
								util.Effect("tracer_zapper", effectdata)
							end)

							break
						end
					end
				end
			end
		end
	end

	self:NextThink(CurTime())
	return true
end
