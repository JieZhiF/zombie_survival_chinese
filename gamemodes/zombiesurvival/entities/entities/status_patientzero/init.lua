-- ============================================================================
-- status_patientzero - 患者零号状态实体（服务端）
-- 负责：持有者造成伤害时提升 15% 并概率附加虚弱/恐惧状态；持有者受劈砍/钝击伤害加重、其他伤害减轻
-- ============================================================================
INC_SERVER()

-- ==== EntityTakeDamage - 全局伤害钩子：增强持有者的输出伤害，并调整其受到的伤害 ====
function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	-- 持有者（存活僵尸）攻击他人时：伤害提升 15%
	if attacker == self:GetOwner() and attacker:IsValidLivingZombie() then
		local dmg = dmginfo:GetDamage()
		local extradamage = dmg * 0.15
		dmginfo:SetDamage(dmg + extradamage)

		-- 对人类目标造成 ≥15 伤害时有 25% 概率附加 5 秒虚弱或恐惧状态
		if ent:IsValidLivingHuman() and dmg >= 15 and math.random(4) == 1 then
			ent:GiveStatus(math.random(2) == 1 and "enfeeble" or "frightened", 5)
		end
	end

	-- 持有者自身受到人类攻击时：劈砍/钝击伤害加重 20%，其他类型伤害减轻 10%
	if ent == self:GetOwner() and attacker:IsValidHuman() then
		if bit.band(dmginfo:GetDamageType(), DMG_SLASH) == 0 and bit.band(dmginfo:GetDamageType(), DMG_CLUB) == 0 then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.9)
		else
			dmginfo:SetDamage(dmginfo:GetDamage() * 1.2)
		end
	end
end

-- ==== Think - 持有者不是存活僵尸或为 Boss 僵尸时移除本状态 ====
function ENT:Think()
	local owner = self:GetOwner()
	if not (owner:IsValidLivingZombie() and not owner:GetZombieClassTable().Boss) then self:Remove() end
end
