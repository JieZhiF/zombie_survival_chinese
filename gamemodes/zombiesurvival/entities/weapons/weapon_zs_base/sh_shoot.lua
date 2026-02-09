-- sh_shoot.lua

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then 
        self:Reload()
        return
    end
    
    if not self:CanPrimaryAttack() then return end

    self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

    self:EmitFireSound()
    self:TakeAmmo()
    
    self.ShotCount = (self.ShotCount or 0) + 1
    
    self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
    
    self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:ShootBullets(dmg, numbul, cone)
    local owner = self:GetOwner()
    
    if not self:GetIronsights() or not self.CustomSightsAttackAnim then 
        self:SendWeaponAnimation()
    end
    
    owner:DoAttackEvent()
    

    owner:LagCompensation(true)
    owner:FireBulletsLua(
        owner:GetShootPos(), 
        owner:GetAimVector(), 
        cone, 
        numbul, 
        dmg, 
        nil, 
        self.Primary.KnockbackScale, 
        self.TracerName, 
        self.BulletCallback, 
        self.Primary.HullSize, 
        nil, 
        self.Primary.MaxDistance, 
        nil, 
        self
    )
    owner:LagCompensation(false)
    
    -- 应用新的 ARC9 风格后坐力逻辑 (定义在 sh_recoil.lua)
    self:ApplyRecoil()
end

function SWEP:CanPrimaryAttack()
    local owner = self:GetOwner()
    if owner:IsHolding() or owner:GetBarricadeGhosting() or self:GetReloadFinish() > 0 then return false end

    if self:Clip1() < self.RequiredClip then
        self:EmitSound(self.DryFireSound)
        self:SetNextPrimaryFire(CurTime() + math.max(0.25, self.Primary.Delay))
        return false
    end

    return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:GetCone()
	local owner = self:GetOwner()

	local basecone = self.ConeMin
	local conedelta = self.ConeMax - basecone

	local orphic = not owner.Orphic and 1 or self:GetIronsights() and 0.9 or 1.1
	local tiervalid = (self.Tier or 1) <= 3
	local spreadmul = (owner.AimSpreadMul or 1) - ((tiervalid and owner:HasTrinket("refinedsub")) and 0.27 or 0)

	if owner.TrueWooism then
		return (basecone + conedelta * 0.5 ^ self.ConeRamp) * spreadmul * orphic
	end

	if not owner:OnGround() or self.ConeMax == basecone then return self.ConeMax end

	local multiplier = math.min(owner:GetVelocity():Length() / self.WalkSpeed, 1) * 0.5

	local ironsightmul = 0.25 * (owner.IronsightEffMul or 1)
	local ironsightdiff = 0.25 - ironsightmul
	multiplier = multiplier + ironsightdiff

	if not owner:Crouching() then multiplier = multiplier + 0.25 end
	if not self:GetIronsights() then multiplier = multiplier + ironsightmul end

	return (basecone + conedelta * (self.FixedAccuracy and 0.6 or multiplier) ^ self.ConeRamp) * spreadmul * orphic
end


function SWEP:GetFireDelay()
    local owner = self:GetOwner()
    local baseDelay = self.Primary.Delay
    local currentDelay = baseDelay -- 初始化当前延迟为基础延迟

    -- 处理“霜冻”状态：
    -- 如果拥有者处于“frost”状态，开火延迟增加30% (乘以1.3)。
    -- 这将导致武器的射速变慢。
    if owner:GetStatus("frost") then
        currentDelay = currentDelay * 1.3
    end

    -- 处理“fastshoot”状态：
    -- 如果拥有者拥有“fastshoot”状态，开火延迟减少10% (乘以0.9)。
    -- 这将导致武器的射速加快。
    if owner:GetStatus("fastshoot") then
        currentDelay = currentDelay * 0.9
    end

    -- 返回最终修正后的开火延迟
    return currentDelay
end

SWEP.AU = 0
function SWEP:TakeAmmo()
    if self.AmmoUse then
        self.AU = (self.AU or 0) + self.AmmoUse
        if self.AU >= 1 then
            local use = math.floor(self.AU)
            self:TakePrimaryAmmo(use)
            self.AU = self.AU - use
        end
    else
        self:TakePrimaryAmmo(self.RequiredClip)
    end
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound)
end