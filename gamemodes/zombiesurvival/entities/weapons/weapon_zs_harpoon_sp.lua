AddCSLuaFile()

SWEP.PrintName = "碎魂方天戟"

SWEP.Base = "weapon_zs_harpoon"

SWEP.MeleeDamage = 113
SWEP.MeleeRange = 104
SWEP.MeleeSize = 0.8

SWEP.BleedDamageMul = 10 / SWEP.MeleeDamage
SWEP.MeleeDamageVsProps = 200

SWEP.Primary.Delay = 0.92

SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.ThrownCount = 0 -- 记录当前投掷物数量
SWEP.MaxThrown = 4 -- 最多允许存在的投掷物数量

SWEP.Undroppable = true --禁止丢弃
SWEP.NoPickupNotification = true --禁止掉落
SWEP.NoDismantle = true --禁止拆除
SWEP.NoGlassWeapons = true --不是玻璃武器
SWEP.AllowQualityWeapons = true --禁止强化

-- 流血状态函数
local function ApplyBleedStatus(target, attacker, damage, multiplier)
    if SERVER and IsValid(target) and target:IsPlayer() then
        local bleed = target:GiveStatus("bleed")
        if IsValid(bleed) then
            bleed:AddDamage(damage * multiplier)
            if IsValid(attacker) then
                bleed.Damager = attacker
            end
        end
    end
end

function SWEP:SecondaryAttack()
    if not self:CanPrimaryAttack() then return end

    local owner = self:GetOwner()
    
    -- 检查当前投掷物数量
    if self.ThrownCount >= self.MaxThrown then
        return -- 直接禁止投掷，但不提示
    end

    local tr = owner:TraceLine(60)
    if tr.HitWorld or (tr.Entity:IsValid() and not tr.Entity:IsPlayer()) then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self:SendWeaponAnim(ACT_VM_MISSCENTER)
    owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)

    self.NextDeploy = CurTime() + 0.75

    if SERVER then
        local ent = ents.Create("projectile_harpoon_te")
        if IsValid(ent) then
            ent:SetPos(owner:GetShootPos())
            ent:SetAngles(owner:EyeAngles())
            ent:SetOwner(owner)
            ent:SetPuller(owner)
            ent.ProjDamage = self.MeleeDamage * 0.45
            ent.BaseWeapon = self:GetClass()
            ent:Spawn()
            ent.Team = owner:Team()
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetVelocityInstantaneous(owner:GetAimVector() * 700 * (owner.ObjectThrowStrengthMul or 1))
            end
        end

        -- 记录投掷数量 +1
        self.ThrownCount = self.ThrownCount + 1
    end
end

-- 近战攻击时触发流血效果
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    if SERVER and IsValid(hitent) and hitent:IsPlayer() then
        ApplyBleedStatus(hitent, self:GetOwner(), self.MeleeDamage, self.BleedDamageMul)
    end
end

-- 监听投掷物移除，减少计数
hook.Add("EntityRemoved", "TrackThrownWeapons", function(ent)
    if ent:GetClass() == "projectile_harpoon_te" and IsValid(ent:GetOwner()) then
        local wep = ent:GetOwner():GetActiveWeapon()
        if IsValid(wep) and wep.ThrownCount then
            wep.ThrownCount = math.max(0, wep.ThrownCount - 1)
        end
    end
end)