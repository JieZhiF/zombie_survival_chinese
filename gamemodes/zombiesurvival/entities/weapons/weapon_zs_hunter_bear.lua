AddCSLuaFile()

SWEP.PrintName = "'棕熊' AWP"
SWEP.Description = "聪明且充满野性的力量."

SWEP.SlotPos = 0

if CLIENT then
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.awm_parent"
	SWEP.HUD3DPos = Vector(-1.25, -3.5, -16)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02
end

sound.Add(
{
	name = "Weapon_Hunter.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitchstart = 134,
	pitchend = 10,
	sound = "weapons/awp/awp1.wav"
})

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_AWP.ClipOut")
SWEP.Primary.Sound = Sound("Weapon_Hunter.Single")
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 3
SWEP.Primary.Delay = 1.22
SWEP.ReloadDelay = SWEP.Primary.Delay

SWEP.Primary.ClipSize = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 35

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

SWEP.ConeMax = 3.35
SWEP.ConeMin = 1

SWEP.IronSightsPos = Vector(5.015, -8, 2.52)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true
SWEP.AllowQualityWeapons = false

SWEP.Knockback = 30
SWEP.Recoil = 0

SWEP.TracerName = "AR2Tracer"

function SWEP.BulletCallback(attacker, tr, dmginfo)
    local effectdata = EffectData()
    effectdata:SetOrigin(tr.HitPos)
    effectdata:SetNormal(tr.HitNormal)
    util.Effect("hit_hunter", effectdata)

    local hitEntity = tr.Entity  -- 获取被击中的实体
    if IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC()) then
        local damage = dmginfo:GetDamage()
        local baseForce = 150  -- **提高击退力度**
        local knockbackForce = damage * baseForce

        -- **确保击退方向优先前后**
        local forwardDir = attacker:GetAimVector()
        local knockbackDirection = Vector(forwardDir.x, forwardDir.y, 0)  -- 只保留 X/Y 轴，避免左右/斜向击退
        knockbackDirection:Normalize()  -- 归一化，确保方向正确

        local verticalForce = -9999  -- **降低击飞高度**

        -- 计算最终击退力
        local finalForce = (knockbackDirection * knockbackForce) + Vector(0, 0, verticalForce)

        -- 应用击退
        hitEntity:SetVelocity(finalForce)
    end
end

function SWEP:SecondaryAttack()
    -- 确保这个修改只影响 "weapon_zs_hunter_bear"
    if self:GetClass() ~= "weapon_zs_hunter_bear" then
        return
    end

    -- 过热检查
    if self.NextOverheat and CurTime() < self.NextOverheat then
        if SERVER then
            local remainingTime = math.ceil(self.NextOverheat - CurTime())
            self:GetOwner():ChatPrint("当前武器过热，不可使用致命一击！剩余冷却时间：" .. remainingTime .. " 秒")
        end
        return
    end

    if not self:CanPrimaryAttack() then return end

    local owner = self:GetOwner()

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound(self.Primary.Sound)

    local clip = self:Clip1()

    -- 伤害衰减检查（仅影响 weapon_zs_hunter_bear）
    local damageMultiplier = 1
    if self.WeakenUntil and CurTime() < self.WeakenUntil then
        damageMultiplier = 0.5
    end

    self:ShootBullets(self.Primary.Damage * damageMultiplier, self.Primary.NumShots * clip, self:GetCone())

    self:TakePrimaryAmmo(clip)
    owner:ViewPunch(clip * 0.5 * self.Recoil * Angle(math.Rand(-0.1, -0.1), math.Rand(-0.1, 0.1), 0))

    owner:SetGroundEntity(NULL)
    owner:SetVelocity(-self.Knockback * clip * owner:GetAimVector())

    self.IdleAnimation = CurTime() + self:SequenceDuration()

    -- 设置 140 秒冷却时间
    self.NextOverheat = CurTime() + 75

    -- 设置 180 秒内伤害降低
    self.WeakenUntil = CurTime() + 60
end