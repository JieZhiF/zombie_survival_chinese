SWEP.PrintName = ""..translate.Get("weapon_zs_frotchet")
SWEP.Description = ""..translate.Get("weapon_zs_frotchet_description")

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 142
SWEP.MeleeRange = 75
SWEP.MeleeSize = 3
SWEP.MeleeKnockBack = 240

SWEP.MeleeDamageSecondaryMul = 1.2273
SWEP.MeleeKnockBackSecondaryMul = 1.25

SWEP.Primary.Delay = 1.4
SWEP.Secondary.Delay = SWEP.Primary.Delay * 1.75

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.HitAnim = ACT_VM_MISSCENTER

SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.62
SWEP.SwingHoldType = "melee"

SWEP.SwingTimeSecondary = 0.85
SWEP.MeleeDamageSecondaryMul = 1.2273
SWEP.MeleeKnockBackSecondaryMul = 1.25
SWEP.BlockPos = Vector(3, -5, -2)
SWEP.BlockAng = Angle(0, 20, -25)

SWEP.BlockSoundPitch  = 75
SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.AllowQualityWeapons = true


-- 别忘了确保 SWEP.Secondary.Delay 存在！

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.14)

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
-- 删除 DrawMeleeHud, 添加以下配置
SWEP.HasThirdAbility = true
SWEP.ThirdAbilityConfig = {
    Icon = Material("materials/zombiesurvival/frost.png"),
    IconSize = 40,
    IconColor = Color(170, 170, 255),
    BGColor = Color(0, 0, 50, 150),
    GlowColor = Color(170, 170, 255), -- 只提供基础颜色，alpha由主函数添加
    TextLines = {
        { text = translate.Get("meleehud_rmb"), y_off = 10, color = Color(170, 170, 255) }
    },
    GetRatio = function(wep, owner, w, h)
        local r = math.max(wep:GetNextSecondaryFire() - CurTime(), 0) / wep.Secondary.Delay
        return r, h * r
    end
}