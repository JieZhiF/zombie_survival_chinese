SWEP.PrintName = ""..translate.Get("weapon_zs_crossbow")
SWEP.Description = ""..translate.Get("weapon_zs_crossbow_description")

SWEP.Base = "weapon_zs_baseproj"

SWEP.HoldType = "crossbow"

SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
SWEP.Primary.Delay = 1.1
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 180

SWEP.Primary.ClipSize = 3
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.DefaultClip = 15

SWEP.SecondaryDelay = 0.25

SWEP.ReloadSpeed = 3.5

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.ConeMax = 0
SWEP.ConeMin = 0

SWEP.NextZoom = 0

--SWEP.ReloadSpeed = 0.85 -- Since it works with it now.

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_PROJECTILE_VELOCITY, 100)

function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/crossbow/bolt_load"..math.random(2)..".wav", 65, 100, 0.9, CHAN_WEAPON + 21)
		self:EmitSound("weapons/crossbow/reload1.wav", 65, 100, 0.9, CHAN_WEAPON + 22)
	end
end

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

function SWEP:ProcessReloadEndTime()
	local reloadspeed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()

	self:SetReloadFinish(CurTime() + self:SequenceDuration() / reloadspeed)
	if not self.DontScaleReloadSpeed then
		self:GetOwner():GetViewModel():SetPlaybackRate(reloadspeed)
	end
end

util.PrecacheSound("weapons/crossbow/bolt_load1.wav")
util.PrecacheSound("weapons/crossbow/bolt_load2.wav")
