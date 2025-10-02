SWEP.PrintName = ""..translate.Get("weapon_zs_frotkatana")
SWEP.Description = ""..translate.Get("weapon_zs_frotkatana_description")

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 88
SWEP.MeleeRange = 88
SWEP.MeleeSize = 3
SWEP.MeleeKnockBack = 70



SWEP.Primary.Delay = 1
SWEP.Secondary.Delay = SWEP.Primary.Delay * 1.2

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.HitAnim = ACT_VM_MISSCENTER
 
SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.7
SWEP.SwingHoldType = "melee"

SWEP.SwingTimeSecondary = 1
SWEP.MeleeDamageSecondaryMul = 0.75
SWEP.MeleeKnockBackSecondaryMul = 0.4
SWEP.BlockPos = Vector(-22.19, -5.29, 9.319)
SWEP.BlockAng = Angle(0.732, -14.687, -66.086)

SWEP.BlockSoundPitch  = 75
SWEP.Tier = 6
SWEP.MaxStock = 2

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.06)

function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	self.ChargeSound = CreateSound(self, "nox/scatterfrost.ogg")
end

function SWEP:CanSecondaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	return self:GetNextSecondaryFire() <= CurTime() and not self:IsSwinging()
end

function SWEP:Think()
    	-- DD base (darkest days)
	if self:IsBlocking() and self:IsSwinging() or not self.Owner:KeyDown(IN_RELOAD) then
		self:SetBlocking(false)
	end

	if self:IsBlocking() and self.Owner:KeyDown(IN_RELOAD) then
	--	self.Owner:SetNWBool("ZSBlocking",false)
	self.DefendingDamageBlocked = math.max(1.5, self.DefendingDamageBlocked - 0.010 )
    else
    self.DefendingDamageBlocked = math.min(self.DefendingDamageBlockedDefault, self.DefendingDamageBlocked + 0.005 )
   	end
	
	if self:IsBlocking() and CLIENT then
		self.BlockAnim = CurTime() + 1
	end

	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if self:IsSwinging() and self:GetSwingEnd() <= CurTime() then
		self:StopSwinging()
		self:MeleeSwing()
		if self:IsCharging() then
			self:SetCharge(0)
		end
	end

	if self:IsCharging() then
		self.ChargeSound:PlayEx(1, math.min(255, 35 + (CurTime() - self:GetCharge()) * 220))
	else
		self.ChargeSound:Stop()
	end
end

function SWEP:PlaySwingSound()
	self:EmitSound("nox/sword_miss.ogg", 75, math.random(40, 45))
end

function SWEP:PlayHitSound()
	self:EmitSound("nox/frotchet_test1.ogg", 75, math.random(95, 105))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_bloody_break.wav", 80, math.random(95, 105))
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() or not self:CanSecondaryAttack() then return end
	self:SetNextAttack(true)
	self:StartSwinging(true)
end

function SWEP:SetNextAttack(secondary)
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + (secondary and self.Primary.Delay + 0.23 or self.Primary.Delay) * armdelay)
	self:SetNextSecondaryFire(CurTime() + (secondary and self.Secondary.Delay or self.Primary.Delay) * armdelay)
end

function SWEP:StartSwinging(secondary)
	local owner = self:GetOwner()

	local armdelay = owner:GetMeleeSpeedMul()
	self:SetSwingEnd(CurTime() + (secondary and self.SwingTimeSecondary or self.SwingTime) * (owner.MeleeSwingDelayMul or 1) * armdelay)
	if secondary then self:SetCharge(CurTime()) end
end

function SWEP:IsCharging()
	return self:GetCharge() > 0
end

function SWEP:SetCharge(charge)
	self:SetDTFloat(1, charge)
end

function SWEP:GetCharge()
	return self:GetDTFloat(1)
end
