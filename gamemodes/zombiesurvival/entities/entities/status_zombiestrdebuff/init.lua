-- ============================================================================
-- status_zombiestrdebuff/init.lua - 僵尸力量削弱状态（服务器）
-- 负责：拥有者（僵尸）受到人类攻击时伤害提升 25%；玩家受伤事件中将
--       这 25% 加成伤害折算记入施放者名下（积分、伤害统计与击杀归属）
-- ============================================================================
INC_SERVER()

-- ==== EntityTakeDamage - 伤害放大：僵尸受到人类攻击时伤害 ×1.25 ====
function ENT:EntityTakeDamage(ent, dmginfo)
	-- 只作用于状态拥有者
	if ent ~= self:GetOwner() then return end

	local attacker = dmginfo:GetAttacker()
	-- 攻击者为有效人类时放大伤害
	if attacker:IsValidHuman() then
		dmginfo:SetDamage(dmginfo:GetDamage() * 1.25)
	end
end

-- ==== PlayerHurt - 伤害归属：把 25% 加成伤害记入施放者名下 ====
function ENT:PlayerHurt(victim, attacker, healthleft, damage)
	local applier = self.Applier
	-- 施放者须为存活人类、非本次攻击者，且受害者为存活僵尸
	if applier and applier:IsValidLivingHuman() and applier ~= attacker and victim:IsValidLivingZombie() then
		local attributeddamage = damage
		-- 击杀溢出修正：伤害超出剩余血量时按实际有效伤害计算
		if healthleft < 0 then
			attributeddamage = attributeddamage + healthleft
		end

		if attributeddamage > 0 then
			-- 只取加成部分：总伤害减去原始伤害（总伤害 ÷ 1.25）
			attributeddamage = attributeddamage - (attributeddamage / 1.25)

			-- 累加施放者的伤害统计与受害者的伤害来源记录
			applier.DamageDealt[TEAM_HUMAN] = applier.DamageDealt[TEAM_HUMAN] + attributeddamage
			victim.DamagedBy[applier] = (victim.DamagedBy[applier] or 0) + attributeddamage

			-- 按僵尸职业点数折算积分，进入施放者的积分队列
			local points = attributeddamage / victim:GetMaxHealth() * victim:GetZombieClassTable().Points
			applier.PointQueue = applier.PointQueue + points

			-- 记录最近造成伤害的位置与时间（供飘字/击杀判定使用）
			local pos = victim:GetPos()
			pos.z = pos.z + 32
			applier.LastDamageDealtPos = pos
			applier.LastDamageDealtTime = CurTime()
		end
	end
end
