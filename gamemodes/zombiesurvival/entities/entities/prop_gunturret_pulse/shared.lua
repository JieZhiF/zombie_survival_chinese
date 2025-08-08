ENT.Base = "prop_gunturret"

ENT.SWEP = "weapon_zs_gunturret_pulse"

ENT.AmmoType = "pulse"
ENT.FireDelay = 0.20
ENT.NumShots = 1
ENT.Damage = 30
ENT.PlayLoopingShootSound = false
ENT.Spread = 2
ENT.SearchDistance = 300
ENT.MaxAmmo = 300

function ENT:PlayShootSound()
	self:EmitSound("weapons/zs_rail/rail.wav", 70, math.random(80, 90), 0.86, CHAN_AUTO)
end