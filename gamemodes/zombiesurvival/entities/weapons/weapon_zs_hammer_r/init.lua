INC_SERVER()

function SWEP:Reload()
	if CurTime() < self:GetNextPrimaryFire() then return end

	local owner = self:GetOwner()
	if owner:GetBarricadeGhosting() then return end

	local tr = owner:CompensatedMeleeTrace(self.MeleeRange, self.MeleeSize)
	local trent = tr.Entity
	if not trent:IsValid() or not trent:IsNailed() then return end

	local ent
	local dist

	for _, e in pairs(ents.FindByClass("prop_nail")) do
		if not e.m_PryingOut and e:GetParent() == trent then
			local edist = e:GetActualPos():DistToSqr(tr.HitPos)
			if not dist or edist < dist then
				ent = e
				dist = edist
			end
		end
	end

	if not ent or not gamemode.Call("CanRemoveNail", owner, ent) then return end

	local nailowner = ent:GetOwner()
	if nailowner:IsValid() and nailowner:IsPlayer() and nailowner ~= owner and nailowner:Team() == TEAM_HUMAN and not gamemode.Call("CanRemoveOthersNail", owner, nailowner, ent) then return end

	self:SetNextPrimaryFire(CurTime() + (#trent.Nails > 2 and 0.5 or 1))

	ent.m_PryingOut = true -- Prevents infinite loops

	self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
	self.Alternate = not self.Alternate

	owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

	owner:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".ogg")

	ent:GetParent():RemoveNail(ent, nil, self:GetOwner())
	ent:GetParent():SetPhysicsAttacker(self:GetOwner())

	if nailowner and nailowner:IsValid() and nailowner:IsPlayer() and nailowner ~= owner and nailowner:Team() == TEAM_HUMAN then
		if gamemode.Call("PlayerShouldTakeNailRemovalPenalty", owner, ent, nailowner, trent) then
			owner:GivePenalty(30)
			owner:ReflectDamage(20)
		end

		if nailowner:NearestPoint(tr.HitPos):DistToSqr(tr.HitPos) <= 589824 and (nailowner:HasWeapon("weapon_zs_hammer") or nailowner:HasWeapon("weapon_zs_electrohammer")) then --768^2
			nailowner:GiveAmmo(1, self.Primary.Ammo)
		else
			owner:GiveAmmo(1, self.Primary.Ammo)
		end
	else
		owner:GiveAmmo(1, self.Primary.Ammo)
	end
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitent:IsValid() then return end

	local owner = self:GetOwner()

	if hitent.HitByHammer and hitent:HitByHammer(self, owner, tr) then
		return
	end

	if hitent:IsNailed() then
		if owner:IsSkillActive(SKILL_BARRICADEEXPERT) then
			hitent.ReinforceEnd = CurTime() + 2
			hitent.ReinforceApplier = owner
		end

		local healstrength = self.HealStrength * GAMEMODE.NailHealthPerRepair * (owner.RepairRateMul or 1)
		local oldhealth = hitent:GetBarricadeHealth()
		if oldhealth <= 0 or oldhealth >= hitent:GetMaxBarricadeHealth() or hitent:GetBarricadeRepairs() <= 0.01 then return end

		hitent:SetBarricadeHealth(math.min(hitent:GetMaxBarricadeHealth(), hitent:GetBarricadeHealth() + math.min(hitent:GetBarricadeRepairs(), healstrength)))
		local healed = hitent:GetBarricadeHealth() - oldhealth
		hitent:SetBarricadeRepairs(math.max(hitent:GetBarricadeRepairs() - healed, 0))
		self:PlayRepairSound(hitent)
		gamemode.Call("PlayerRepairedObject", owner, hitent, healed, self)

		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(1)
		util.Effect("nailrepaired", effectdata, true, true)

		return true
	end
end

function SWEP:SecondaryAttack()
    if self:GetPrimaryAmmoCount() <= 0 or CurTime() < self:GetNextPrimaryFire() or self:GetOwner():GetBarricadeGhosting() then return end

    local owner = self:GetOwner()

    if GAMEMODE:IsClassicMode() then
        owner:PrintTranslatedMessage(HUD_PRINTCENTER, "cant_do_that_in_classic_mode")
        return
    end

    local tr = owner:CompensatedMeleeTrace(170, self.MeleeSize, nil, nil, nil, true)
    local trent = tr.Entity

    if not trent:IsValid()
    or not util.IsValidPhysicsObject(trent, tr.PhysicsBone)
    or tr.Fraction == 0
    or trent:GetMoveType() ~= MOVETYPE_VPHYSICS and not trent:GetNailFrozen()
    or trent.NoNails
    or trent:IsProjectile()
    or trent:IsNailed() and (#trent.Nails >= 8 or trent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade)
    or trent:GetMaxHealth() == 1 and trent:Health() == 0 and not trent.TotalHealth
    or trent.PreHoldCollisionGroup and (trent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS or trent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS_TRIGGER or trent.PreHoldCollisionGroup == COLLISION_GROUP_INTERACTIVE_DEBRIS)
    or not trent:IsNailed() and not trent:GetPhysicsObject():IsMoveable() then return end

    if not gamemode.Call("CanPlaceNail", owner, tr) then return end

    local count = 0
    for _, nail in pairs(trent:GetNails()) do
        if nail:GetDeployer() == owner then
            count = count + 1
            if count >= GAMEMODE.MaxNails then
                return
            end
        end
    end

    if tr.MatType == MAT_GRATE or tr.MatType == MAT_CLIP then
        owner:PrintTranslatedMessage(HUD_PRINTCENTER, "impossible")
        return
    end
    if tr.MatType == MAT_GLASS then
        owner:PrintTranslatedMessage(HUD_PRINTCENTER, "trying_to_put_nails_in_glass")
        return
    end

    for _, nail in pairs(ents.FindByClass("prop_nail")) do
        if nail:GetParent() == trent and nail:GetActualPos():DistToSqr(tr.HitPos) <= 81 then
            owner:PrintTranslatedMessage(HUD_PRINTCENTER, "too_close_to_another_nail")
            return
        end
    end

    if trent:GetBarricadeHealth() <= 0 and trent:GetMaxBarricadeHealth() > 0 then
        owner:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
        return
    end

    -- 设定维修量
    

    local aimvec = owner:GetAimVector()
    local trtwo = util.TraceLine({
        start = tr.HitPos, 
        endpos = tr.HitPos + aimvec * 24, 
        filter = table.Add({owner, trent}, GAMEMODE.CachedInvisibleEntities), 
        mask = MASK_SOLID
    })
    
    if trtwo.HitSky then return end
    
    local ent = trtwo.Entity
    if trtwo.HitWorld
    or ent:IsValid() and util.IsValidPhysicsObject(ent, trtwo.PhysicsBone) and 
       (ent:GetMoveType() == MOVETYPE_VPHYSICS or ent:GetNailFrozen()) and 
       not ent.NoNails and 
       not (not ent:IsNailed() and not ent:GetPhysicsObject():IsMoveable()) and 
       not (ent:GetMaxHealth() == 1 and ent:Health() == 0 and not ent.TotalHealth) then
    
        -- 先进行物体加固治疗
        if ent:IsNailed() then
            if owner:IsSkillActive(SKILL_BARRICADEEXPERT) then
                ent.ReinforceEnd = CurTime() + 2
                ent.ReinforceApplier = owner
            end
    
            local healstrength = self.HealStrength * GAMEMODE.NailHealthPerRepair * (owner.RepairRateMul or 1)
            local oldhealth = ent:GetBarricadeHealth()
    
            -- 确保物体需要修复
            if oldhealth <= 0 or oldhealth >= ent:GetMaxBarricadeHealth() or ent:GetBarricadeRepairs() <= 0.01 then return end
    
            -- 修复物体
            local repaired = math.min(ent:GetBarricadeRepairs(), healstrength)
            ent:SetBarricadeHealth(math.min(ent:GetMaxBarricadeHealth(), oldhealth + repaired))
            ent:SetBarricadeRepairs(math.max(ent:GetBarricadeRepairs() - repaired, 0))
    
            self:PlayRepairSound(ent)
            gamemode.Call("PlayerRepairedObject", owner, ent, repaired, self)
    
            -- 播放修复效果
            local effectdata = EffectData()
            effectdata:SetOrigin(tr.HitPos)
            effectdata:SetNormal(tr.HitNormal)
            effectdata:SetMagnitude(1)
            util.Effect("nailrepaired", effectdata, true, true)
    
            return
        end
    
        -- 进行物体钉固
        local cons = constraint.Weld(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone, 0, true)
        if not cons then return end
    
        -- 检查每局至多钉多少钉子
        local maxNailsPerPlayer = 9999
        if not ent.PlayerNailCount then
            ent.PlayerNailCount = {}  -- 初始化钉子记录
        end
    
        -- 检查当前玩家在这个物体上的钉子数量
        local playerNailCount = ent.PlayerNailCount[owner:SteamID()] or 0
        if playerNailCount >= maxNailsPerPlayer then
            return  -- 如果已经钉了4根，不能再钉
        end
    
        -- 更新该玩家在物体上的钉子数量
        ent.PlayerNailCount[owner:SteamID()] = playerNailCount + 1
    
        self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
        self.Alternate = not self.Alternate
    
        owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
        self:SetNextPrimaryFire(CurTime() + 1)
        self:TakePrimaryAmmo(1)
    
        local nail = ents.Create("prop_nail")
        if nail:IsValid() then
            nail:SetActualOffset(tr.HitPos, trent)
            nail:SetPos(tr.HitPos - aimvec * 8)
            nail:SetAngles(aimvec:Angle())
            nail:AttachTo(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone)
            nail:Spawn()
            nail:SetDeployer(owner)  -- 这里仍然保留钉子绑定到玩家，但不会影响自动维修逻辑
            cons:DeleteOnRemove(nail)
            gamemode.Call("OnNailCreated", trent, ent, nail)
    
            -- 自动维修定时器，确保钉子存活时维修仍然进行
            timer.Create("AutoRepair_" .. nail:EntIndex(), 1.15, 0, function()
                if not IsValid(nail) or not IsValid(trent) then
                    timer.Remove("AutoRepair_" .. nail:EntIndex())
                    return
                end
    
                -- 获取剩余维修量
                local repairAmount = math.min(trent:GetBarricadeRepairs(), 40)  -- 使用剩余的维修量
                local maxHealth = trent:GetMaxBarricadeHealth()
                local currentHealth = trent:GetBarricadeHealth()
    
                -- 确保不会修复超过最大生命值
                if currentHealth < maxHealth then
                    trent:SetBarricadeHealth(math.min(maxHealth, currentHealth + repairAmount))
                    trent:SetBarricadeRepairs(math.max(trent:GetBarricadeRepairs() - repairAmount, 0))  -- 减少维修量
                else
                    -- 如果物体已经修复满了，停止自动维修
                    timer.Remove("AutoRepair_" .. nail:EntIndex())
                end
            end)
    
            nail:EmitSound(string.format("weapons/melee/crowbar/crowbar_hit-%d.ogg", math.random(4)))
        end
    end
end