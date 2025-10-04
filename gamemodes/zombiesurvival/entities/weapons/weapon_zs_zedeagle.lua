AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_zedeagle")

SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	SWEP.IronSightsPos = Vector(-6.35, 5, 1.7)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage = 250
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.28

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"

SWEP.ConeMax = 3
SWEP.ConeMin = 1.5

SWEP.WalkSpeed = SPEED_ZOMBIEESCAPE_NORMAL
SWEP.Primary.KnockbackScale = ZE_KNOCKBACKSCALE
SWEP.Primary.DefaultClip = 9999

SWEP.AllowQualityWeapons = false

function SWEP.BulletCallback(attacker, tr, dmginfo)
    local hitEntity = tr.Entity  -- 获取被击中的实体
    if IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC()) then
        local damage = dmginfo:GetDamage()
        local baseForce = 30  -- **提高击退力度**
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