AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_boss_longsword")
SWEP.Description = "."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base+++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(-90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+++++"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 90, 0), size = Vector(0.223, 0.259, 0.196), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.743, 1.294, 3.095), angle = Angle(6.436, 0, 0), size = Vector(0.412, 0.257, 1.68), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/shoe001a", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_phx/misc/flakshell_big.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.827), angle = Angle(180, 0, 0), size = Vector(0.093, 0.012, 0.97), color = Color(223, 223, 255, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/streetsign002b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, 6.59), angle = Angle(0, 0, 0), size = Vector(0.09, 3.848, 0.09), color = Color(156, 155, 173, 255), surpresslightning = false, material = "models/props_pipes/pipesystem01a_skin1", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		["base+++++"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 90, 0), size = Vector(0.223, 0.259, 0.196), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.665, 1.264, 2.4), angle = Angle(-5.286, 16.554, -2.345), size = Vector(0.412, 0.257, 1.68), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/shoe001a", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(-90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/streetsign002b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 6.59), angle = Angle(0, 0, 0), size = Vector(0.09, 3.848, 0.09), color = Color(156, 155, 173, 255), surpresslightning = false, material = "models/props_pipes/pipesystem01a_skin1", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_phx/misc/flakshell_big.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.827), angle = Angle(180, 0, 0), size = Vector(0.093, 0.012, 0.97), color = Color(223, 223, 255, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 40
SWEP.MeleeRange = 67
SWEP.MeleeSize = 2.5

SWEP.Primary.Delay = 1.25

SWEP.Tier = 3

SWEP.WalkSpeed = SPEED_SLOW

SWEP.SwingRotation = Angle(30, -20, 10)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.65
SWEP.SwingHoldType = "melee"

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.125)

--========================
-- 技能参数
--========================
local SKILL_COOLDOWN = 120          -- 穿心剑冷却
local SKILL_DURATION = 6           -- 穿心剑持续时间
local GRAVITY_COOLDOWN = 30        -- 重力压制冷却

SWEP.LastSkill = 0
SWEP.LastGravitySkill = 0
SWEP.LastSkillNotify = 0
SWEP.LastGravityNotify = 0


function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 85))
end

function SWEP:PlayHitSound()
	self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 75)
end

function SWEP:GetTracesNumPlayers(traces)
	local numplayers = 0

	local ent
	for _, trace in pairs(traces) do
		ent = trace.Entity
		if ent and ent:IsValidPlayer() then
			numplayers = numplayers + 1
		end
	end

	return numplayers
end

function SWEP:GetDamage(numplayers, basedamage)
	basedamage = basedamage or self.MeleeDamage

	if numplayers then
		return basedamage * math.Clamp(1.25 - numplayers * 0.25, 0.5, 1)
	end

	return basedamage
end

function SWEP:MeleeSwing()
	local owner = self:GetOwner()

	owner:DoAttackEvent()
	self:SendWeaponAnim(self.MissAnim)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	local hit = false
	local tr = owner:CompensatedPenetratingMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)
	local damage = self:GetDamage(self:GetTracesNumPlayers(tr))
	local ent

	local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1 --(owner.BuffMuscular and owner:Team()==TEAM_HUMAN) and 1.2 or 1
	if owner:IsSkillActive(SKILL_LASTSTAND) then
		if owner:Health() <= owner:GetMaxHealth() * 0.25 then
			damagemultiplier = damagemultiplier * 2
		else
			damagemultiplier = damagemultiplier * 0.85
		end
	end

	for _, trace in ipairs(tr) do
		if not trace.Hit then continue end

		ent = trace.Entity

		hit = true

		local hitflesh = trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH

		if hitflesh then
			util.Decal(self.BloodDecal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)

			if SERVER then
				self:ServerHitFleshEffects(ent, trace, damagemultiplier)
			end

		end

		if ent and ent:IsValid() then
			if SERVER then
				self:ServerMeleeHitEntity(trace, ent, damagemultiplier)
			end

			self:MeleeHitEntity(trace, ent, damagemultiplier, damage)

			if SERVER then
				self:ServerMeleePostHitEntity(trace, ent, damagemultiplier)
			end

			if owner.GlassWeaponShouldBreak then break end
		end
	end

	if hit then
		self:PlayHitSound()
	else
		self:PlaySwingSound()

		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end
end

function SWEP:MeleeHitEntity(tr, hitent, damagemultiplier, damage)
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	if SERVER and hitent:IsPlayer() and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
		damagemultiplier = damagemultiplier * 3.5
		owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
	end

	damage = damage * damagemultiplier

	local dmginfo = DamageInfo()
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetAttacker(owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(self.DamageType)
	dmginfo:SetDamage(damage)
	dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 50 * owner:GetAimVector())

	local vel
	if hitent:IsPlayer() then

		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(self:GetPowerCombo() + 1)

			damage = damage + damage * (owner.MeleePowerAttackMul - 1) * (self:GetPowerCombo()/4)
			dmginfo:SetDamage(damage)

			if self:GetPowerCombo() >= 4 then
				self:SetPowerCombo(0)
				if SERVER then
					local pitch = math.Clamp(math.random(90, 110) + 15 * (1 - damage/45), 50 , 200)
					owner:EmitSound("npc/strider/strider_skewer1.wav", 75, pitch)
				end
			end
		end

		hitent:MeleeViewPunch(damage)
		if hitent:IsHeadcrab() then
			damage = damage * 2
			dmginfo:SetDamage(damage)
		end

		if SERVER then
			hitent:SetLastHitGroup(tr.HitGroup)
			if tr.HitGroup == HITGROUP_HEAD then
				hitent:SetWasHitInHead()
			end

			if hitent:WouldDieFrom(damage, tr.HitPos) then
				dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 400 * owner:GetAimVector())
			end
		end

		vel = hitent:GetVelocity()
	else
		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end

	--if not hitent.LastHeld or CurTime() >= hitent.LastHeld + 0.1 then -- Don't allow people to shoot props out of their hands
		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end

		hitent:DispatchTraceAttack(dmginfo, tr, owner:GetAimVector())

		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		-- Invalidate the engine knockback vs. players
		if vel then
			hitent:SetLocalVelocity(vel)
		end
	--end

	-- Perform our own knockback vs. players
	if hitent:IsPlayer() then
		local knockback = self.MeleeKnockBack * (owner.MeleeKnockbackMultiplier or 1)
		if knockback > 0 then
			hitent:ThrowFromPositionSetZ(tr.StartPos, knockback, nil, true)
		end

		if owner.MeleeLegDamageAdd and owner.MeleeLegDamageAdd > 0 then
			hitent:AddLegDamage(owner.MeleeLegDamageAdd)
		end
	end

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetStart(tr.StartPos)
	effectdata:SetNormal(tr.HitNormal)
	util.Effect("RagdollImpact", effectdata)
	if not tr.HitSky then
		effectdata:SetSurfaceProp(tr.SurfaceProps)
		effectdata:SetDamageType(self.DamageType)
		effectdata:SetHitBox(tr.HitBox)
		effectdata:SetEntity(hitent)
		util.Effect("Impact", effectdata)
	end
end

--========================
-- 穿心剑（按 R）
--========================
function SWEP:Reload()
    if not IsFirstTimePredicted() then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local nextReady = self.LastSkill + SKILL_COOLDOWN
    local timeLeft = math.ceil(nextReady - CurTime())

    -- 冷却检测
    if CurTime() < nextReady then
        -- 只在按一次时提示，不重复刷屏
        if CurTime() - self.LastSkillNotify > 1.0 then
            self.LastSkillNotify = CurTime()
            ply:ChatPrint("❌ [技能提示] 穿心剑冷却中，剩余 " .. timeLeft .. " 秒")
        end
        return
    end

    -- 技能激活
    self.LastSkill = CurTime()
    self.LastSkillNotify = CurTime()
    local baseWalk = ply:GetWalkSpeed()
    local baseRun = ply:GetRunSpeed()

    ply:SetNoDraw(true)
    ply:SetNWBool("Skill_Invisible", true)
    ply:SetNWBool("Skill_Invincible", true)

    ply:SetWalkSpeed(baseWalk * 2.2)
    ply:SetRunSpeed(baseRun * 2.2)

    ply:EmitSound("npc/antlion_guard/shove1.wav")
    ply:ChatPrint("⚔️ [技能提示] 穿心剑发动！")

    -- 技能持续控制
    local startTime = CurTime()
    local totalDamageSurvivors = {}
    local totalDamageEntities = {}

    -- 无敌期间忽略伤害
    hook.Add("EntityTakeDamage", "穿心剑无敌_" .. ply:EntIndex(), function(target, dmginfo)
        if target == ply and ply:GetNWBool("Skill_Invincible", false) then
            dmginfo:SetDamage(0)
            dmginfo:ScaleDamage(0)
            return true
        end
    end)

    -- 伤害循环
    timer.Create("穿心剑_" .. ply:EntIndex(), 0, 0, function()
        if not IsValid(ply) or CurTime() > startTime + SKILL_DURATION then
            -- 技能结束
            if IsValid(ply) then
                ply:SetNoDraw(false)
                ply:SetNWBool("Skill_Invisible", false)
                ply:SetNWBool("Skill_Invincible", false)
                ply:SetWalkSpeed(baseWalk)
                ply:SetRunSpeed(baseRun)
                ply:ChatPrint("🌀 [技能提示] 穿心剑结束。")
            end

            hook.Remove("EntityTakeDamage", "穿心剑无敌_" .. ply:EntIndex())
            timer.Remove("穿心剑_" .. ply:EntIndex())

            -- 冷却结束提示
            timer.Simple(SKILL_COOLDOWN, function()
                if IsValid(ply) then
                    ply:ChatPrint("✅ [技能提示] 穿心剑已准备就绪！")
                end
            end)
            return
        end

        local entities = ents.FindInSphere(ply:GetPos(), 300)
        for _, ent in ipairs(entities) do
            if ent == ply then continue end
            if not IsValid(ent) then continue end

            if ent:IsPlayer() then
                if ent:Team() == TEAM_SURVIVORS then
                    totalDamageSurvivors[ent] = (totalDamageSurvivors[ent] or 0)
                    if totalDamageSurvivors[ent] < 50 then
                        local dmg = DamageInfo()
                        dmg:SetDamage(2)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(self)
                        dmg:SetDamageForce(Vector(0, 0, 0))
                        ent:TakeDamageInfo(dmg)
                        totalDamageSurvivors[ent] = totalDamageSurvivors[ent] + 2
                    end
                else
                    totalDamageEntities[ent] = (totalDamageEntities[ent] or 0)
                    if totalDamageEntities[ent] < 50 then
                        local dmg = DamageInfo()
                        dmg:SetDamage(2)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(self)
                        dmg:SetDamageForce(Vector(0, 0, 0))
                        ent:TakeDamageInfo(dmg)
                        totalDamageEntities[ent] = totalDamageEntities[ent] + 2
                    end
                end
            else
                totalDamageEntities[ent] = (totalDamageEntities[ent] or 0)
                if totalDamageEntities[ent] < 50 then
                    local dmg = DamageInfo()
                    dmg:SetDamage(2)
                    dmg:SetAttacker(ply)
                    dmg:SetInflictor(self)
                    dmg:SetDamageForce(Vector(0, 0, 0))
                    ent:TakeDamageInfo(dmg)
                    totalDamageEntities[ent] = totalDamageEntities[ent] + 2
                end
            end
        end
    end)
end
--[[
--========================
-- 重力压制（右键）
--========================
function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local nextReady = self.LastGravitySkill + GRAVITY_COOLDOWN
    local timeLeft = math.ceil(nextReady - CurTime())

    if CurTime() < nextReady then
        if CurTime() - self.LastGravityNotify > 1.0 then
            self.LastGravityNotify = CurTime()
            ply:ChatPrint("❌ [技能提示] 重力压制冷却中，剩余 " .. timeLeft .. " 秒")
        end
        return
    end

    self.LastGravitySkill = CurTime()
    self.LastGravityNotify = CurTime()

    ply:EmitSound("physics/concrete/concrete_break2.wav")
    ply:ChatPrint("🌌 [技能提示] 重力压制发动！")

    for _, target in ipairs(player.GetAll()) do
        if target == ply then continue end
        if target:Team() == TEAM_SURVIVORS then
            target:Freeze(true)
            timer.Simple(0.5, function()
                if IsValid(target) then target:Freeze(false) end
            end)

            if not target:IsOnGround() then
                target:SetVelocity(Vector(0, 0, -1000))
            end

            target:TakeDamage(1, ply, self)
        end
    end

    timer.Simple(GRAVITY_COOLDOWN, function()
        if IsValid(ply) then
            ply:ChatPrint("✅ [技能提示] 重力压制已准备就绪！")
        end
    end)
end
--]]