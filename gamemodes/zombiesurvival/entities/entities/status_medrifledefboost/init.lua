-- ============================================================================
-- status_medrifledefboost/init.lua - 医疗步枪防御增益状态（服务器）
-- 负责：设定状态时长；当拥有者被僵尸攻击时削减 30% 伤害，
--       并按减掉的伤害折算为积分返还给施放者（施放者需为存活的真人人类）
-- ============================================================================
INC_SERVER()

if SERVER then
	-- ==== SetDie - 设置结束时间：0 立即结束，-1 永续，正数设定剩余时长 ====
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
end

-- ==== EntityTakeDamage - 减伤结算：僵尸伤害削减 30%，减掉部分折算积分给施放者 ====
function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	-- 只处理作用于拥有者的伤害
	if ent ~= self:GetOwner() then return end

	if attacker:IsValidZombie() then
		-- 减伤比例 30%
		local protect = 0.3

		-- 被减免的伤害值
		local dmgfraction = dmginfo:GetDamage() * protect
		-- 实际承受伤害削减为 70%
		dmginfo:SetDamage(dmginfo:GetDamage() * (1 - protect))

		-- 按医疗包积分换算率将减免伤害折算为 1.5 倍积分
		local hpperpoint = GAMEMODE.MedkitPointsPerHealth
		local points = (dmgfraction / hpperpoint) * 1.5

		-- 施放者仍存活且为真人人类时，累计其防御伤害并发放积分
		if self.Applier and self.Applier:IsValidLivingHuman() then
			self.Applier.DefenceDamage = (applier.DefenceDamage or 0) + dmgfraction
			self.Applier:AddPoints(points)
		end
	end
end
