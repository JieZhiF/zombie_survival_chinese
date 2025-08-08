SWEP.PrintName = ""..translate.Get("weapon_zs_flashbomb")
SWEP.Description = ""..translate.Get("weapon_zs_flashbomb_description")

SWEP.Base = "weapon_zs_basethrown"

SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.Ammo = "flashbomb"
SWEP.Primary.Sound = Sound("weapons/pinpull.wav")

SWEP.MaxStock = 30

function SWEP:Precache()
	util.PrecacheSound("weapons/pinpull.wav")
end
