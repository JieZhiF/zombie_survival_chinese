AddCSLuaFile()

SWEP.Base = "weapon_zs_brassknuckles"

SWEP.PrintName = "海虎·白军浪"
SWEP.Description = "百万匹的力量！"

SWEP.ZombieOnly = true

SWEP.Primary.Delay = 0.2
SWEP.MeleeDamage = 42
SWEP.MeleeRange = 70
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 0

SWEP.SkillActive = false
SWEP.SkillEndTime = 0
SWEP.SkillCooldown = 0

function SWEP:Initialize()
    self.BaseClass.Initialize(self)
    self.OriginalMeleeDamage = self.MeleeDamage
    self.OriginalMeleeRange = self.MeleeRange
    self.OriginalDelay = self.Primary.Delay
end

function SWEP:Think()
    local ct = CurTime()
    if self.SkillActive and ct >= self.SkillEndTime then
        self:MeleeSkillEnd()
    elseif self.SkillActive and ct >= self.SkillEndTime - 5 and not self.CountdownShown then
        self.CountdownShown = true
        self:GetOwner():PrintMessage(HUD_PRINTCENTER, "极速子弹拳剩余时间：5秒")
    end
end

function SWEP:Reload()
    local ct = CurTime()
    if ct < self.SkillCooldown or self.SkillActive then return end

    self:ActivateMeleeSkill()
end

function SWEP:ActivateMeleeSkill()
    self.SkillActive = true
    self.SkillEndTime = CurTime() + 30
    self.SkillCooldown = CurTime() + 45

    self.OriginalMeleeDamage = self.MeleeDamage
    self.OriginalMeleeRange = self.MeleeRange
    self.OriginalDelay = self.Primary.Delay

    self.Primary.Delay = self.OriginalDelay * 0.25
    self.MeleeRange = 200
    self.MeleeDamage = 10

    self:GetOwner():PrintMessage(HUD_PRINTCENTER, "你发动了极速子弹拳，大幅度提升攻速和攻击范围，降低造成伤害，持续30秒。")
    self.CountdownShown = false
end

function SWEP:MeleeSkillEnd()
    self.SkillActive = false
    self.Primary.Delay = self.OriginalDelay
    self.MeleeRange = self.OriginalMeleeRange
    self.MeleeDamage = self.OriginalMeleeDamage
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    if not hitent:IsPlayer() and not self.SkillActive then
        self.MeleeDamage = 25
    end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
    if not self.SkillActive then
        self.MeleeDamage = self.OriginalMeleeDamage
    end
end

function SWEP:SetNextAttack()
    local owner = self:GetOwner()
    local armdelay = owner:GetMeleeSpeedMul()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end