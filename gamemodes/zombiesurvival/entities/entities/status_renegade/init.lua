-- ============================================================================
-- status_renegade/init.lua - 叛徒状态结算（服务器）
-- 负责：管理状态死亡时间；伤害钩子中让拥有者（人类）的攻击伤害除以
--       僵尸伤害缩放，从而无视恐惧值减免打出全额伤害
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 设置状态死亡时间：0/空=立即结束，-1=无限期，其余=定时结束 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	else
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end

-- ==== EntityTakeDamage - 叛徒伤害钩子：抵消恐惧值对伤害的减免 ====
function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	-- 仅处理拥有者自己造成的伤害
	if attacker ~= self:GetOwner() then return end
	-- 攻击者必须是存活的人类且目标未被腐蚀：伤害除以僵尸伤害缩放
	-- （该缩放含恐惧值减免），使叛徒伤害恢复为全额
	if attacker:IsValidLivingHuman() and not ent.Corrosion then
		dmginfo:SetDamage(dmginfo:GetDamage() / GAMEMODE:GetZombieDamageScale(dmginfo:GetDamagePosition(), ent))
	end
end
