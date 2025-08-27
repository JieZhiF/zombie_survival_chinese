SWEP.PrintName = ""..translate.Get("weapon_zs_handgrenade")
SWEP.Description = ""..translate.Get("weapon_zs_handgrenade_description")

SWEP.Base = "weapon_zs_baseproj"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.HoldType = "revolver"

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["Python"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.CSMuzzleFlashes = true

SWEP.Primary.Sound = Sound( "Weapon_SMG1.Double" )
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 70

SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "impactmine"

GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.5
SWEP.ConeMin = 1.2

SWEP.NextZoom = 0

SWEP.ReloadSpeed = 1.4
SWEP.PointsMultiplier = 1.3
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.07)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_handgrenade_r1"), ""..translate.Get("weapon_zs_handgrenade_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.75
	wept.EntModify = function(self, ent)
		ent:SetDTBool(0, true)
	end
end)
--[[
function SWEP:EmitFireSound()
	self:EmitSound("weapons/grenade_launcher1.wav", 70, math.random(118, 124), 0.3)
	self:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav", 70, 100, 0.7, CHAN_AUTO + 20)
end
]]