AddCSLuaFile()

SWEP.PrintName = "Origin12"
SWEP.Description = "马枪也能命中."


SWEP.SlotPos = 0

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.galil"
	SWEP.HUD3DPos = Vector(1, 0, 6)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
SWEP.Primary.Damage = 2
SWEP.Primary.NumShots = 60
SWEP.Primary.Delay = 0.28

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 9.25
SWEP.ConeMin = 8.75

SWEP.ReloadSpeed = 0.85

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 4

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)

function SWEP:SecondaryAttack()
end
