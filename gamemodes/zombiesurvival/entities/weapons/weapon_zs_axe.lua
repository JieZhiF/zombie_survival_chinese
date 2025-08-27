AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_axe")
SWEP.Description = ""..translate.Get("weapon_zs_axe_description")

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.399, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props/cs_militia/axe.mdl"
SWEP.UseHands = true    

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 45 * GAMEMODE.LabourTime
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 125

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingTime = 0.6
SWEP.SwingRotation = Angle(0, -20, -40)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.SwingHoldType = "melee"


SWEP.MeleePuch_Pitch_Up_Min = 0   -- 攻击时，视角【最少】向上抬起多少
SWEP.MeleePuch_Pitch_Up_Max = 1.1   -- 攻击时，视角【最多】向上抬起多少

SWEP.MeleePuch_Pitch_Down_Min = 0.9 -- 攻击后，视角【最少】向下回落多少
SWEP.MeleePuch_Pitch_Down_Max = 3 -- 攻击后，视角【最多】向下回落多少

-- 左右晃动 (Yaw): 正值向左, 负值向右
SWEP.MeleePuch_Yaw_Left_Min = 0.7   -- 【最少】向左偏移多少
SWEP.MeleePuch_Yaw_Left_Max = 2.4   -- 【最多】向左偏移多少

SWEP.MeleePuch_Yaw_Right_Min = 0  -- 【最少】向右偏移多少
SWEP.MeleePuch_Yaw_Right_Max = 0.4  -- 【最多】向右偏移多少

-- 旋转晃动 (Roll): 正值逆时针, 负值顺时针
SWEP.MeleePuch_Roll_CCW_Min = 0 -- 【最少】逆时针旋转多少 (Counter-Clockwise)
SWEP.MeleePuch_Roll_CCW_Max = 0 -- 【最多】逆时针旋转多少

SWEP.MeleePuch_Roll_CW_Min = 0  -- 【最少】顺时针旋转多少 (Clockwise)
SWEP.MeleePuch_Roll_CW_Max = 0  -- 【最多】顺时针旋转多少

SWEP.HitDecal = "Manhackcut"

SWEP.BlockPos = Vector(0, -8.643, -4.824)
SWEP.BlockAng = Angle(42.21, 10, 40.406)

SWEP.DefendingDamageBlockedDefault = 1.5
SWEP.DefendingDamageBlocked = 1.5

SWEP.BlockSoundPitch  = 110
SWEP.BlockHoldType = "melee2"
SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(4)..".ogg")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end
