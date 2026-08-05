-- ============================================================================
-- status_enfeeble/init.lua - 虚弱状态（服务器）
-- 负责：僵尸攻击被虚弱者时伤害放大 1.4 倍，并将多出的伤害折算后
--       记入施加者的战绩统计；提供状态持续时间设置
-- ============================================================================
INC_SERVER()

-- ==== EntityTakeDamage - 承伤放大：僵尸伤害被虚弱者时放大 DamageScale 倍 ====
function ENT:EntityTakeDamage(ent, dmginfo)
	-- 只处理状态拥有者受到的伤害
	if ent ~= self:GetOwner() then return end

	local attacker = dmginfo:GetAttacker()
	-- 仅僵尸阵营攻击者的伤害放大
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD then
		dmginfo:SetDamage(dmginfo:GetDamage() * self.DamageScale)
	end
end

-- ==== PlayerHurt - 伤害归属：把放大造成的额外伤害计入施加者战绩 ====
function ENT:PlayerHurt(victim, attacker, healthleft, damage)
	local applier = self.Applier
	-- 施加者必须是存活的僵尸，且不是本次实际攻击者，受害者是人类
	if applier and applier:IsValidLivingZombie() and applier ~= attacker and victim:IsValidLivingHuman() then
		local attributeddamage = damage
		-- 致命伤害时按实际扣除的血量计算
		if healthleft < 0 then
			attributeddamage = attributeddamage + healthleft
		end

		if attributeddamage > 0 then
			-- 折算放大倍率带来的额外伤害部分
			attributeddamage = attributeddamage - (attributeddamage / self.DamageScale)

			-- 记入施加者的击杀贡献统计与生命伤害统计
			applier.DamageDealt[TEAM_UNDEAD] = applier.DamageDealt[TEAM_UNDEAD] + attributeddamage
			applier:AddLifeHumanDamage(attributeddamage)
		end
	end
end

-- ==== SetDie - 设置状态失效时间（0=立即，-1=无限，正数=秒数） ====
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
