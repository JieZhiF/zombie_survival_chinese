AddCSLuaFile()

SWEP.Base = "weapon_zs_inferno"

SWEP.Primary.Damage = 80

SWEP.ConeMax = 2.5
SWEP.ConeMin = 0.8

SWEP.WalkSpeed = SPEED_ZOMBIEESCAPE_SLOW

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