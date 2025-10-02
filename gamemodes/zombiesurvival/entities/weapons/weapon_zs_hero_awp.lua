AddCSLuaFile()

SWEP.PrintName = "'英雄' AWP"
SWEP.Description = "仅英雄使用，属于非法武器之一."

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
SWEP.Primary.BaseDamage = 85
SWEP.Primary.Damage = SWEP.Primary.BaseDamage
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.45
SWEP.ReloadDelay = SWEP.Primary.Delay

SWEP.Primary.ClipSize = 20
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

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true
SWEP.AllowQualityWeapons = false

SWEP.Knockback = 300
SWEP.Recoil = 0
SWEP.ReloadSpeed = 1.65

SWEP.TracerName = "AR2Tracer"

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true

SWEP.DamageBonus = 0
SWEP.MaxDamageBonus = 999
SWEP.DamagePerUpgrade = 400

if SERVER then
    function SWEP:Initialize()
        self.BaseClass.Initialize(self)
        self.TotalZombieDamage = 0
        self.DamageBonus = 0
        self.Primary.Damage = self.Primary.BaseDamage
    end

    function SWEP:EntityTakeDamage(ent, dmginfo)
        local owner = self:GetOwner()
        if not IsValid(owner) or owner ~= dmginfo:GetAttacker() then return end
        if not ent:IsPlayer() or ent:Team() ~= TEAM_ZOMBIE then return end

        self.TotalZombieDamage = (self.TotalZombieDamage or 0) + dmginfo:GetDamage()

        local newBonus = math.min(math.floor(self.TotalZombieDamage / self.DamagePerUpgrade), self.MaxDamageBonus)
        if newBonus > self.DamageBonus then
            self.DamageBonus = newBonus
            self.Primary.Damage = self.Primary.BaseDamage + self.DamageBonus
            -- 提示已移除，避免报错
        end
    end
end

if SERVER then
    hook.Add("EntityTakeDamage", "InfernoAUGTrackDamage", function(target, dmginfo)
        local attacker = dmginfo:GetAttacker()
        if IsValid(attacker) and attacker:IsPlayer() then
            local wep = attacker:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_zs_stm4" then
                if wep.EntityTakeDamage then
                    wep:EntityTakeDamage(target, dmginfo)
                end
            end
        end
    end)
end

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