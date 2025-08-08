AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_rocket")
SWEP.Description = ""..translate.Get("weapon_zs_gunturret_rocket_description")

SWEP.Primary.Damage = 104

SWEP.GhostStatus = "ghost_gunturret_rocket"
SWEP.DeployClass = "prop_gunturret_rocket"
SWEP.TurretAmmoType = "impactmine"
SWEP.TurretAmmoStartAmount = 12
SWEP.TurretSpread = 1

SWEP.Primary.Ammo = "turret_rocket"

SWEP.Tier = 4

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.45)
