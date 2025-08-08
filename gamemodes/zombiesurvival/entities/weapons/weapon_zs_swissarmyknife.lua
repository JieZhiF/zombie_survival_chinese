AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_swissarmyknife")
SWEP.Description = ""..translate.Get("weapon_zs_swissarmyknife_description")

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

    SWEP.ViewModelBoneMods={
    ["ValveBiped.Bip01_L_UpperArm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_L_Forearm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_R_UpperArm"]={scale=Vector(1,1,1),pos=Vector(0,-1,2),angle=Angle(0,0,0)},
    ["v_weapon.Knife_Handle"] = { scale = Vector(0.9, 0.9, 0.9), pos = Vector(0, 0, -1), angle = Angle(0, 0, 0)},
    ["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0.153, -0.237, 0), angle = Angle(-18.853, -43.914, 82.498) }
    }

    SWEP.CurrentHandAngle = Angle(-18.853, -43.914, 82.498)

    function SWEP:PreDrawViewModel(vm)

        if self.ShowViewModel == false then
            render.SetBlend(0)
        end

        local vm = self.Owner:GetViewModel()

        local e=self.ViewModelBoneMods["ValveBiped.Bip01_L_UpperArm"].angle
        local f=self.ViewModelBoneMods["ValveBiped.Bip01_R_UpperArm"].angle
        local cshand = self.ViewModelBoneMods["ValveBiped.Bip01_R_Hand"]
        self.CurrentHandPos = Vector(0.153, -0.237, 0)

        if self:IsBlocking() then
            -- Left Arm
            e.yaw = math.Approach(e.yaw, -30, FrameTime() * 150)
            e.pitch = math.Approach(e.pitch, 40, FrameTime() * 150)

            -- Right Arm
            f.pitch = math.Approach(f.pitch, -10, FrameTime() * 150)
            f.roll = math.Approach(f.roll, 10, FrameTime() * 30)


            -- right arm gmod cs styled
            self.CurrentHandAngle = LerpAngle(FrameTime() * 10, self.CurrentHandAngle, Angle(0,0,0))
            cshand.angle = self.CurrentHandAngle
            cshand.pos = Vector(0, 0, 0)

    elseif not self:CanPrimaryAttack() and CurTime() > (self:SequenceDuration() * CurTime()) then
            -- force gmod cs because it's shitty as hell when attacking
            self.CurrentHandAngle = LerpAngle(FrameTime() * 150, self.CurrentHandAngle, Angle(0,0,0))
            cshand.angle = self.CurrentHandAngle
            cshand.pos = Vector(0,0,0)
        else
            -- left hand - not blocking
            e.yaw = math.Approach(e.yaw, 0, FrameTime() * 250)
            e.pitch = math.Approach(e.pitch, 0, FrameTime() * 250)

            -- right arm - not blocking
            f.pitch = math.Approach(f.pitch, 0, FrameTime() * 250)
            f.roll = math.Approach(f.roll, 0, FrameTime() * 250)

            -- right hand cs:source styled - not blocking
            self.CurrentHandAngle = LerpAngle(FrameTime() * 10, self.CurrentHandAngle, Angle(-18.853, -43.914, 82.498))
            cshand.angle = self.CurrentHandAngle
            cshand.pos = Vector(0.153, -0.237, 0)
        end
    end

end


SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "knife"

SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 19
SWEP.MeleeRange = 52
SWEP.MeleeSize = 0.875

SWEP.WalkSpeed = SPEED_FASTEST

SWEP.BlockSoundPitch  = 130
SWEP.Primary.Delay = 0.85
SWEP.DefendingDamageBlocked = 1.15
SWEP.DefendingDamageBlockedDefault = 1.15
SWEP.HitDecal = "Manhackcut"

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.MissGesture = SWEP.HitGesture

SWEP.HitAnim = ACT_VM_MISSCENTER
SWEP.MissAnim = ACT_VM_PRIMARYATTACK

SWEP.NoHitSoundFlesh = true


SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.085)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/knife/knife_hitwall1.wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("weapons/knife/knife_hit"..math.random(4)..".wav")
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and not self.m_BackStabbing and math.abs(hitent:GetForward():Angle().yaw - self:GetOwner():GetForward():Angle().yaw) <= 90 then
		self.m_BackStabbing = true
		self.MeleeDamage = self.MeleeDamage * 2
	end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if self.m_BackStabbing then
		self.m_BackStabbing = false

		self.MeleeDamage = self.MeleeDamage / 2
	end
end

function SWEP:Deploy() -- had to put this function up here so it load's it first than PreDrawViewmodel

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	self:EmitSound("weapons/knife/knife_deploy1.wav")

	self.Weapon:SetNextPrimaryFire(CurTime() + 1.15) -- had to put it from 1.0 to 1.15 because if you deploy it and hold it bugs

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end
if SERVER then
	function SWEP:InitializeHoldType()
		self.ActivityTranslate = {}
		self.ActivityTranslate[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslate[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslate[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslate[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_PHYSGUN
		self.ActivityTranslate[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_KNIFE
		self.ActivityTranslate[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslate[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_KNIFE
		self.ActivityTranslate[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_KNIFE
		self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_KNIFE
	end
end
