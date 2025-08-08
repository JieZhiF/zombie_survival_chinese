AddCSLuaFile()

SWEP.Base = "weapon_zs_butcherknife"

SWEP.ZombieOnly = true
SWEP.MeleeDamage = 35
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.Primary.Delay = 0.45

SWEP.SkillActive = false
SWEP.SkillEndTime = 0
SWEP.SkillCooldown = 0

function SWEP:Initialize()
    self.BaseClass.Initialize(self)
    self.OriginalDelay = self.Primary.Delay
end

function SWEP:Think()
    local ct = CurTime()
    if self.SkillActive and ct >= self.SkillEndTime then
        self:MeleeSkillEnd()
    elseif self.SkillActive and ct >= self.SkillEndTime - 5 and not self.CountdownShown then
        self.CountdownShown = true
        self:GetOwner():PrintMessage(HUD_PRINTCENTER, "嗜血剩余时间：5秒")
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

    self.OriginalDelay = self.Primary.Delay
    self.Primary.Delay = self.OriginalDelay * 0.25

    self:GetOwner():PrintMessage(HUD_PRINTCENTER, "你发动了嗜血，大幅度提升攻速，持续30秒。")
    self.CountdownShown = false
end

function SWEP:MeleeSkillEnd()
    self.SkillActive = false
    self.Primary.Delay = self.OriginalDelay
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitent:IsPlayer() then
		self.MeleeDamage = 8
	end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end

function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end