SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.DryFireSound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Damage = 30
SWEP.Primary.KnockbackScale = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

SWEP.ConeMax = 1.5
SWEP.ConeMin = 0.5
SWEP.ConeRamp = 2

SWEP.CSMuzzleFlashes = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.RequiredClip = 1

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.HoldType = "pistol"
SWEP.IronSightsHoldType = "ar2"

SWEP.IronSightsPos = Vector(0, 0, 0)

SWEP.EmptyWhenPurchased = true
SWEP.AllowQualityWeapons = true

SWEP.Recoil = 0

SWEP.ReloadSpeed = 1.0
SWEP.FireAnimSpeed = 1.0
SWEP.SniperRifle = false
SWEP.IdleActivity = ACT_VM_IDLE
SWEP.StandOffset = -1
-- 全局开关
SWEP.Recoil_Enabled         = false -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.4  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.2  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = false
SWEP.Recoil_Progressive_Max_Multiplier = 2
SWEP.Recoil_Progressive_Shot_Increment = 0.05
SWEP.Recoil_Progressive_Reset_Time = 0.2

-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 5    -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Time   = 0.15 -- 停火后多久开始恢复
SWEP.Recoil_Recovery_Speed  = 8    -- 自动恢复的速度
SWEP.Recoil_Recovery_Percentage = 0.15 

SWEP.CooldownExtraSize = 1

SWEP.Weight = 5
SWEP.WElements = {}
SWEP.VElements = {}

function SWEP:Initialize()
	if not self:IsValid() then return end --???

	self:SetWeaponHoldType(self.HoldType)
	GAMEMODE:DoChangeDeploySpeed(self)

	-- Higher tier guns auto swap to with a higher priority than low tier ones.
	if self.Weight and self.Tier then
		self.Weight = self.Weight + self.Tier
	end

	-- Maybe we didn't want to convert the weapon to the new system...
	if self.Cone then
		self.ConeMin = self.ConeIronCrouching
		self.ConeMax = self.ConeMoving
		self.ConeRamp = 2
	end
	
	if CLIENT then
		self:CheckCustomIronSights()
		self:Anim_Initialize()
	end
	self:ResetRecoilState()
end

-- 在部署和初始化时重置状态
function SWEP:ResetRecoilState()
    self.recoil_punch = Angle(0, 0, 0)
    self.current_recoil_offset = Angle(0, 0, 0)
    self.last_frame_recoil_offset = Angle(0, 0, 0)
    self.recovery_target_angle = nil
    self.recoil_progressive_multiplier = 1.0
    self.last_shot_time = 0
end
function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then 
        self:Reload()
    end
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

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

		owner:DoReloadEvent()

		self:EmitReloadSound()
	end
end

function SWEP:GetPrimaryClipSize()
	local owner = self:GetOwner()
	local multi = self.Primary.ClipSize/self.RequiredClip >= 8 and owner:HasTrinket("extendedmag") and 1.15 or 1

	return math.floor(self:GetMaxClip1() * multi)
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

function SWEP:GetWalkSpeed()
	local owner = self:GetOwner()
	if self:GetIronsights() then
		return math.min(self.WalkSpeed, math.max(90, self.WalkSpeed * (owner.Wooism and 0.75 or 0.5)))
	end

	return self.WalkSpeed
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound)
end

function SWEP:SetIronsights(b)
	self:SetDTBool(0, b)

	if self.IronSightsHoldType then
		if b then
			self:SetWeaponHoldType(self.IronSightsHoldType)
		else
			self:SetWeaponHoldType(self.HoldType)
		end
	end

	gamemode.Call("WeaponDeployed", self:GetOwner(), self)
end

function SWEP:Deploy()
	self:SetNextReload(0)
	self:SetReloadFinish(0)

	self:ResetRecoilState()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self:SetIronsights(false)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	if CLIENT then
		self:CheckCustomIronSights()
	end

	return true
end

function SWEP:Holster()
	if CLIENT then
		self:Anim_Holster()
	end

	return true
end

SWEP.AU = 0
function SWEP:TakeAmmo()
	if self.AmmoUse then
		self.AU = self.AU + self.AmmoUse
		if self.AU >= 1 then
			local use = math.floor(self.AU)
			self:TakePrimaryAmmo(use)
			self.AU = self.AU - use
		end
	else
		self:TakePrimaryAmmo(self.RequiredClip)
	end
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

function SWEP:CanReload()
	return self:GetNextReload() <= CurTime() and self:GetReloadFinish() == 0 and
		(
			self:GetMaxClip1() > 0 and self:Clip1() < self:GetPrimaryClipSize() and self:ValidPrimaryAmmo() and self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) > 0
			or self:GetMaxClip2() > 0 and self:Clip1() < self:GetMaxClip2() and self:ValidSecondaryAmmo() and self:GetOwner():GetAmmoCount(self:GetSecondaryAmmoType()) > 0
		)
end

function SWEP:GetIronsights()
	return self:GetDTBool(0)
end

function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then return false end

	if self:Clip1() < self.RequiredClip then
		self:EmitSound(self.DryFireSound)
		self:SetNextPrimaryFire(CurTime() + math.max(0.25, self.Primary.Delay))
		return false
	end

	return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:OnRestore()
	self:SetIronsights(false)
end

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)
end

function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_RELOAD)
end
--[[
 * @description: 获取武器的最终重装速度乘数。
 * 这个值由多个因素共同决定：
 * 1. 玩家的基础重装速度加成（可能受特定弹药类型影响）。
 * 2. 玩家是否处于 "frost" (冰冻) 状态的减益效果。
 * 3. 在特定条件下（如拥有某饰品、武器等级较低），由武器品质决定的额外加成。
 * @return {number} 最终的重装速度乘数。
--]]
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

-- 这是一个辅助函数，用于在开火时施加后坐力
function SWEP:ApplyRecoil()
    if not self.Recoil_Enabled then return end

    -- 每次开火都重置恢复目标
    self.recovery_target_angle = nil

    local recoil_mult = 1.0
    if self.Recoil_Progressive_Enabled then
        if CurTime() < self.last_shot_time + self.Recoil_Progressive_Reset_Time + self:GetFireDelay() then
            self.recoil_progressive_multiplier = self.recoil_progressive_multiplier + self.Recoil_Progressive_Shot_Increment
        else
            self.recoil_progressive_multiplier = 1.0 + self.Recoil_Progressive_Shot_Increment
        end
        recoil_mult = math.min(self.recoil_progressive_multiplier, self.Recoil_Progressive_Max_Multiplier)
    end
    
    local recoil_vertical = self.Recoil_Vertical * recoil_mult
    local recoil_horizontal = math.Rand(-self.Recoil_Horizontal, self.Recoil_Horizontal) * recoil_mult
    
    self.recoil_punch:Add(Angle(-recoil_vertical, recoil_horizontal, 0))
    self.last_shot_time = CurTime()
end

function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	if not self:GetIronsights() or self.SniperRifle then 
		self:SendWeaponAnimation()
	else
		self.offset = self.StandOffset -- 如果在瞄准状态，可能用于触发不同的动画效果
	end
	owner:DoAttackEvent()
	if self.Recoil > 0 then
		local r = math.Rand(0.8, 1)
		owner:ViewPunch(Angle(r * -self.Recoil, 0, (1 - r) * (math.random(2) == 1 and -1 or 1) * self.Recoil))
	end

	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end

	owner:LagCompensation(true)
	owner:FireBulletsLua(owner:GetShootPos(), owner:GetAimVector(), cone, numbul, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false)
	self:ApplyRecoil()
	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end
end

local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]      	= ACT_HL2MP_IDLE_DUEL,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA
}

function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ActIndex[ t ]

	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal) (from "..self:GetClass()..")\n" )
		t = "normal"
		index = ActIndex[ t ]
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM_IDLE ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= index+9

	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end

	-- these two aren't defined in ACTs for whatever reason
	if t == "knife" or t == "melee2" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = nil
	end
end

SWEP:SetWeaponHoldType("pistol")

function SWEP:TranslateActivity(act)
	if self:GetIronsights() and self.ActivityTranslateIronSights then
		return self.ActivityTranslateIronSights[act] or -1
	end

	return self.ActivityTranslate and self.ActivityTranslate[act] or -1
end
