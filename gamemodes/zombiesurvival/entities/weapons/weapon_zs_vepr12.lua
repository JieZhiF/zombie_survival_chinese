AddCSLuaFile()

SWEP.PrintName = "VEPR12"
SWEP.Description = "一柱擎天！."

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
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 7
SWEP.Primary.Delay = 0.17

SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 3
SWEP.ConeMin = 2

SWEP.ReloadSpeed = 1.75

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 5


GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)

function SWEP:SecondaryAttack()
end
