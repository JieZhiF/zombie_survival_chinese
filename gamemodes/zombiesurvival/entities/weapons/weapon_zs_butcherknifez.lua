-- ============================================================================
-- weapon_zs_butcherknifez.lua - 屠夫刀（僵尸专用版，带嗜血技能）
-- 负责：僵尸屠夫刀近战属性与嗜血技能（换弹触发：攻速大幅提升 30 秒）
-- ============================================================================
AddCSLuaFile()

-- 基于屠夫刀母本（人类版屠夫刀）
SWEP.Base = "weapon_zs_butcherknife"

-- 仅限僵尸使用，近战伤害 35，并记录原始伤害供恢复
SWEP.ZombieOnly = true
SWEP.MeleeDamage = 35
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
-- 攻击间隔（秒）
SWEP.Primary.Delay = 0.45

-- 嗜血技能状态：是否激活、结束时间与冷却时间
SWEP.SkillActive = false
SWEP.SkillEndTime = 0
SWEP.SkillCooldown = 0

-- ==== Initialize - 调用母本初始化并记录原始攻击间隔 ====
function SWEP:Initialize()
    self.BaseClass.Initialize(self)
    self.OriginalDelay = self.Primary.Delay
end

-- ==== Think - 监听技能结束，并在最后 5 秒时向主人显示倒计时提醒 ====
function SWEP:Think()
    local ct = CurTime()
    if self.SkillActive and ct >= self.SkillEndTime then
        self:MeleeSkillEnd()
    elseif self.SkillActive and ct >= self.SkillEndTime - 5 and not self.CountdownShown then
        self.CountdownShown = true
        self:GetOwner():PrintMessage(HUD_PRINTCENTER, "嗜血剩余时间：5秒")
    end
end

-- ==== Reload - 换弹键触发嗜血技能（冷却结束且未激活时） ====
function SWEP:Reload()
    local ct = CurTime()
    if ct < self.SkillCooldown or self.SkillActive then return end

    self:ActivateMeleeSkill()
end

-- ==== ActivateMeleeSkill - 激活嗜血：持续 30 秒、冷却 45 秒，攻击间隔降至 25% ====
function SWEP:ActivateMeleeSkill()
    self.SkillActive = true
    self.SkillEndTime = CurTime() + 30
    self.SkillCooldown = CurTime() + 45

    self.OriginalDelay = self.Primary.Delay
    self.Primary.Delay = self.OriginalDelay * 0.25

    self:GetOwner():PrintMessage(HUD_PRINTCENTER, "你发动了嗜血，大幅度提升攻速，持续30秒。")
    self.CountdownShown = false
end

-- ==== MeleeSkillEnd - 技能结束：恢复原始攻击间隔 ====
function SWEP:MeleeSkillEnd()
    self.SkillActive = false
    self.Primary.Delay = self.OriginalDelay
end

-- ==== OnMeleeHit - 命中非玩家（木板/物体）时把伤害降为 8 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitent:IsPlayer() then
		self.MeleeDamage = 8
	end
end

-- ==== PostOnMeleeHit - 命中结算后恢复原始伤害 ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end

-- ==== SetNextAttack - 按主人攻速倍率设定下一次攻击时间 ====
function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end