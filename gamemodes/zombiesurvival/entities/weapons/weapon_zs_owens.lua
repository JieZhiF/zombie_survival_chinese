AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_owens")
SWEP.Description = ""..translate.Get("weapon_zs_owens_description")

SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true  

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 14.2
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.18

SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipMultiplier = 12/10
GAMEMODE:SetupDefaultClip(SWEP.Primary)


SWEP.ConeMax = 4
SWEP.ConeMin = 2.5

SWEP.ReloadSpeed = 1

SWEP.IronSightsPos = Vector(-5.401, 0, 2.4)

SWEP.IronSightsAng = Angle(0, 0, 0)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.46, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.22, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)
