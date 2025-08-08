AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = "Pulse Turret"
SWEP.Description = "A high powered turret that can fire pulse slowing shots.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 30

SWEP.GhostStatus = "ghost_gunturret_pulse"
SWEP.DeployClass = "prop_gunturret_pulse"

SWEP.TurretAmmoType = "pulse"
SWEP.TurretAmmoStartAmount = 30
SWEP.TurretSpread = 2

SWEP.Tier = 5

SWEP.Primary.Ammo = "turret_pulse"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)