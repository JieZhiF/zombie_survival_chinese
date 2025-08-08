AddCSLuaFile()

SWEP.PrintName = "疯狂屠刀"
SWEP.Description = "砍砍砍！我要彻底撕碎你！."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_lab/cleaver.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, -1), angle = Angle(90, 0, 0), size = Vector(0.8, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_lab/cleaver.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, -3.182), angle = Angle(90, 0, 0), size = Vector(0.8, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_SLASH

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true
SWEP.NoDroppedWorldModel = true
--[[SWEP.BoxPhysicsMax = Vector(8, 1, 4)
SWEP.BoxPhysicsMin = Vector(-8, -1, -4)]]

SWEP.MeleeDamage = 30
SWEP.MeleeRange = 50
SWEP.MeleeSize = 0.875
SWEP.Primary.Delay = 0.45

SWEP.WalkSpeed = SPEED_FAST

SWEP.UseMelee1 = true

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.HitDecal = "Manhackcut"
SWEP.HitAnim = ACT_VM_MISSCENTER

SWEP.Tier = 3

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.06)

SWEP.SkillActive = false
SWEP.SkillEndTime = 0
SWEP.SkillCooldown = 0

function SWEP:Initialize()
    self.BaseClass.Initialize(self)
    self.OriginalDelay = self.Primary.Delay
end

function SWEP:Think()
    local ct = CurTime()
    if self.SkillActive and ct >= self.SkillEndTime then
        self:MeleeSkillEnd()
    elseif self.SkillActive and ct >= self.SkillEndTime - 5 and not self.CountdownShown then
        self.CountdownShown = true
        self:GetOwner():PrintMessage(HUD_PRINTCENTER, "嗜血剩余时间：5秒")
    end
end

function SWEP:Reload()
    local ct = CurTime()
    if ct < self.SkillCooldown or self.SkillActive then return end

    self:ActivateMeleeSkill()
end

function SWEP:ActivateMeleeSkill()
    self.SkillActive = true
    self.SkillEndTime = CurTime() + 30
    self.SkillCooldown = CurTime() + 45

    self.OriginalDelay = self.Primary.Delay
    self.Primary.Delay = self.OriginalDelay * 0.25

    self:GetOwner():PrintMessage(HUD_PRINTCENTER, "你发动了嗜血，大幅度提升攻速，持续30秒。")
    self.CountdownShown = false
end

function SWEP:MeleeSkillEnd()
    self.SkillActive = false
    self.Primary.Delay = self.OriginalDelay
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav", 72, math.Rand(85, 95))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/knife/knife_hitwall1.wav", 72, math.Rand(75, 85))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav")
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	--[[if hitent:IsValid() and hitent:IsPlayer() and hitent:Health() <= 0 then
		-- Dismember closest limb to tr.HitPos
	end]]
end
