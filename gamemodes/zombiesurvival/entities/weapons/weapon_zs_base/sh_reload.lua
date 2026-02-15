-- sh_reload.lua

function SWEP:Reload()
	local owner = self:GetOwner()
	if owner:IsHolding() then return end

	if self:GetIronsights() then
		self:SetIronsights(false)
	end

	-- Custom reload function to change reload speed.
	if self:CanReload() then
		-- Store whether there's a round chambered before reloading
		self.HasChamberedRound = self:Clip1() > 0
		self.HasChamberedRoundSecondary = self:Clip2() > 0

		self.IdleAnimation = CurTime() + self:SequenceDuration()
		self:SetNextReload(self.IdleAnimation)
		self:SetReloadStart(CurTime())

		self:SendReloadAnimation()
		self:ProcessReloadEndTime()
		self:ResetRecoilState(true)
		self.last_shot_time = 0 
		self.ShotCount = 0 -- 连射计数重置
		self.IsReloadingRecoil = true
		owner:DoReloadEvent()

		self:EmitReloadSound()
	end
end

function SWEP:CanReload()
    local owner = self:GetOwner()
    return self:GetNextReload() <= CurTime() and self:GetReloadFinish() == 0 and
        (
            self:GetMaxClip1() > 0 and self:Clip1() < self:GetPrimaryClipSize() and self:ValidPrimaryAmmo() and owner:GetAmmoCount(self:GetPrimaryAmmoType()) > 0
            or self:GetMaxClip2() > 0 and self:Clip2() < self:GetMaxClip2() and self:ValidSecondaryAmmo() and owner:GetAmmoCount(self:GetSecondaryAmmoType()) > 0
        )
end

function SWEP:GetReloadSpeedMultiplier()
	local owner = self:GetOwner()

	-- 1. 获取基础和弹药特定的重装速度加成
	-- -------------------------------------------------------------------
	local ammoTypeString = self:GetPrimaryAmmoTypeString()
	local ammoSpecificModifier = nil

	-- 如果武器有主弹药类型，则构建一个针对该弹药的特定加成字符串
	-- 例如，如果弹药是 "smg_ammo"，则字符串为 "ReloadSpeedMultiplierSMG_AMMO"
	if ammoTypeString then
		ammoSpecificModifier = "ReloadSpeedMultiplier" .. string.upper(ammoTypeString)
	end

	-- 从玩家身上获取总的加成值，这会同时考虑通用加成和特定弹药加成
	local baseMultiplier = owner:GetTotalAdditiveModifier("ReloadSpeedMultiplier", ammoSpecificModifier)


	-- 2. 计算来自状态效果（如冰冻）的乘数
	-- -------------------------------------------------------------------
	local frostMultiplier = 1.0 -- 默认为1，即没有影响
	local fastReloadMultiplier = 1.0 -- 默认为1，即没有影响
	-- 如果玩家处于 "frost" 状态，则施加 0.7 倍的减速惩罚
	if owner:GetStatus("frost") then
		frostMultiplier = 0.7
	end

	if owner:GetStatus("fastreload") then
		fastReloadMultiplier = 1.2
	end

	local statusMultiplier = frostMultiplier * fastReloadMultiplier
	-- 3. 计算来自武器品质和饰品的特殊乘数
	-- -------------------------------------------------------------------
	local qualityMultiplier = 1.0 -- 默认为1，即没有影响

	-- 检查是否满足一系列特殊条件，以激活基于武器品质的加成
	local hasSuperTrinket = owner:HasTrinket("supasm")
	local isLowTier = (self.Tier or 1) <= 2
	local hasNoRemantleMod = not self.PrimaryRemantleModifier
	local hasQualityTier = self.QualityTier ~= nil

	if hasSuperTrinket and isLowTier and hasNoRemantleMod and hasQualityTier then
		-- 从全局配置中查找对应品质的加成值
		qualityMultiplier = GAMEMODE.WeaponQualities[self.QualityTier][2]
	end


	-- 4. 最终计算
	-- -------------------------------------------------------------------
	-- 将所有乘数相乘以得到最终结果
	return baseMultiplier * statusMultiplier * qualityMultiplier
end

function SWEP:ProcessReloadEndTime()
	local reloadspeed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()

	self:SetReloadFinish(CurTime() + self:SequenceDuration() / reloadspeed)
	if not self.DontScaleReloadSpeed then
		self:GetOwner():GetViewModel():SetPlaybackRate(reloadspeed)
	end
end
-- Add this new function to handle the chambered round logic
function SWEP:FinishReload()
	self:SetReloadFinish(0)
	local owner = self:GetOwner()
	
	-- Handle primary ammo reload
	if self:GetMaxClip1() > 0 and self:Clip1() < self:GetPrimaryClipSize() and self:ValidPrimaryAmmo() and owner:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
		local primaryAmmo = owner:GetAmmoCount(self:GetPrimaryAmmoType())
		local currentClip = self:Clip1()
		local maxClip = self:GetPrimaryClipSize()
		
		-- Calculate how much ammo we need
		local ammoNeeded = maxClip - currentClip
		
		-- If we had a chambered round, we can load one extra bullet
		if self.HasChamberedRound then
			ammoNeeded = ammoNeeded + 1
			maxClip = maxClip + 1
		end
		
		-- Don't take more ammo than the player has
		local ammoToTake = math.min(ammoNeeded, primaryAmmo)
		
		-- Set the new clip size
		self:SetClip1(currentClip + ammoToTake)
		
		-- Remove ammo from player's reserves
		owner:RemoveAmmo(ammoToTake, self:GetPrimaryAmmoType())
	end
	
	-- Handle secondary ammo reload
	if self:GetMaxClip2() > 0 and self:Clip2() < self:GetMaxClip2() and self:ValidSecondaryAmmo() and owner:GetAmmoCount(self:GetSecondaryAmmoType()) > 0 then
		local secondaryAmmo = owner:GetAmmoCount(self:GetSecondaryAmmoType())
		local currentClip2 = self:Clip2()
		local maxClip2 = self:GetMaxClip2()
		
		-- Calculate how much ammo we need
		local ammoNeeded2 = maxClip2 - currentClip2
		
		-- If we had a chambered round in secondary, we can load one extra bullet
		if self.HasChamberedRoundSecondary then
			ammoNeeded2 = ammoNeeded2 + 1
			maxClip2 = maxClip2 + 1
		end
		
		-- Don't take more ammo than the player has
		local ammoToTake2 = math.min(ammoNeeded2, secondaryAmmo)
		
		-- Set the new clip size
		self:SetClip2(currentClip2 + ammoToTake2)
		
		-- Remove ammo from player's reserves
		owner:RemoveAmmo(ammoToTake2, self:GetSecondaryAmmoType())
	end
	
	-- Reset the chambered round flags
	self.HasChamberedRound = false
	self.HasChamberedRoundSecondary = false
end

function SWEP:GetPrimaryClipSize()
	local owner = self:GetOwner()
	local multi = self.Primary.ClipSize/self.RequiredClip >= 8 and owner:HasTrinket("extendedmag") and 1.15 or 1

	return math.floor(self:GetMaxClip1() * multi)
end

function SWEP:EmitReloadSound()
	if self.ReloadSound and IsFirstTimePredicted() then
		self:EmitSound(self.ReloadSound, 75, 100, 1, CHAN_WEAPON + 21)
	end
end
function SWEP:EmitReloadFinishSound()
	if self.ReloadFinishSound and IsFirstTimePredicted() then
		self:EmitSound(self.ReloadFinishSound, 75, 100, 1, CHAN_WEAPON + 21)
	end
end
