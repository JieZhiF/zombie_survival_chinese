AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_assault")
SWEP.Description = ""..translate.Get("weapon_zs_gunturret_assault_description")

SWEP.Primary.Damage = 22.5

SWEP.GhostStatus = "ghost_gunturret_assault"
SWEP.DeployClass = "prop_gunturret_assault"

SWEP.TurretAmmoType = "ar2"
SWEP.TurretAmmoStartAmount = 100
SWEP.TurretSpread = 2

SWEP.Tier = 4

SWEP.Primary.Ammo = "turret_assault"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)
