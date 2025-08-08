INC_SERVER()

ENT.LifeTime = 3

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:PhysicsInitSphere(10) --self:PhysicsInitSphere(13)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(2, 0) --self:SetModelScale(2.5, 0)
	self:SetupGenericProjectile(true)

	self:SetMaterial("models/flesh")

	self.DeathTime = CurTime() + 15
	self.ExplodeTime = CurTime() + self.LifeTime
end

function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explode()
    if self.Exploded then return end
    self.Exploded = true
    self.DeathTime = 0

    local pos = self:GetPos()
    local owner = self:GetOwner()
    if not owner:IsValid() then owner = self end

    -- 伤害爆炸
    util.BlastDamageEx(self, owner, pos, 100, 15, DMG_SLASH)

    -- 特效
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect("bonemeshexplode", effectdata)

    util.Blood(pos, 150, Vector(0, 0, 1), 300, true)

    -- 残肢爆炸
    for i = 1, 4 do
        local ent = ents.CreateLimited("prop_playergib")
        if ent:IsValid() then
            ent:SetPos(pos + VectorRand() * 4)
            ent:SetAngles(VectorRand():Angle())
            ent:SetGibType(math.random(3, #GAMEMODE.HumanGibs))
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then
                phys:Wake()
                phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(120, 620))
                phys:AddAngleVelocity(VectorRand() * 360)
            end
        end
    end

    --附加功能：治疗附近僵尸（最多8个）
    local treated = 0
    for _, pl in pairs(ents.FindInSphere(pos, 90)) do
        if treated >= 8 then break end

        if pl:IsValidLivingZombie() then
            local alreadyTreated = pl.HadMeatRegen

            if not alreadyTreated then
                local zombieclasstbl = pl:GetZombieClassTable()
                local ehp = zombieclasstbl.Boss and pl:GetMaxHealth() * 0.4 or pl:GetMaxHealth() * 1.25
                if pl:Health() <= ehp then
                    local status = pl:GiveStatus("zombie_regen")
                    if status and status:IsValid() then
                        status:SetHealLeft(pl:GetMaxHealth() * 0.3) -- 回血30%
                        status.DamageReduction = 0.08  -- 8%减伤
                        pl.HadMeatRegen = true
                        treated = treated + 1
                    end
                end
            else
                -- 已获得过回血，仅给予减伤
                if not pl:GetStatus("zombie_regen") then
                    local status = pl:GiveStatus("zombie_regen")
                    if status and status:IsValid() then
                        status:SetHealLeft(0)
                        status.DamageReduction = 0.08
                        treated = treated + 1
                    end
                end
            end
        end
    end
end

-- 玩家死亡时清除 HadMeatRegen 记录
hook.Add("PlayerDeath", "ClearMeatRegenOnDeath", function(ply)
    if ply:IsValid() and ply.HadMeatRegen then
        ply.HadMeatRegen = nil
    end
end)

-- NPC 死亡时清除 HadMeatRegen 记录
hook.Add("OnNPCKilled", "ClearMeatRegenOnDeath", function(npc, attacker, inflictor)
    if npc:IsValid() and npc.HadMeatRegen then
        npc.HadMeatRegen = nil
    end
end)

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
