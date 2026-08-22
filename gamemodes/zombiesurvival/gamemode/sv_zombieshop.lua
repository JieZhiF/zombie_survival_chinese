-- 本文件负责处理僵尸玩家通过造成伤害获得变异代币（BTokens）的逻辑。
-- 当僵尸攻击障碍物或人类时，根据伤害量给予对应的代币奖励，用于在变异商店购买技能。

-- 钩子：实体受到伤害后处理僵尸的代币获取
hook.Add("PostEntityTakeDamage", "OnEntityDamaged", function(ent, dmginfo)
	-- 检查攻击者是否是僵尸阵营的玩家
	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() == TEAM_UNDEAD then
		-- 如果被攻击的实体是障碍物（有路障血量），则根据武器伤害的35%给予代币
		if ent:GetBarricadeHealth() > 0 then
			local weapon = dmginfo:GetAttacker():GetActiveWeapon()
			local tokendmg = dmginfo:GetDamage()
			local attacker = dmginfo:GetAttacker()
			if IsValid(weapon) then
				-- 获取武器的基准伤害值（近战伤害、子弹伤害或扑击伤害）
				local damage = weapon.MeleeDamage or weapon.Primary.Damage or weapon.PounceDamage or 0
				-- 如果有专门的近战对道具伤害值则使用该值
				if weapon.MeleeDamageVsProps then 
					damage = weapon.MeleeDamageVsProps
				end
				-- 按35%的比例换算为代币
				local adddmg = damage * 0.35
				-- 给予攻击者代币
				dmginfo:GetAttacker():AddTokens(adddmg)
			end
		-- 如果被攻击的是敌方玩家（人类），则按实际伤害的200%给予代币
		elseif ent:IsPlayer() and ent:IsValid() and ent:Team() ~= dmginfo:GetAttacker():Team() then
			local damage = dmginfo:GetDamage()
			local token = damage * 2
			dmginfo:GetAttacker():AddTokens(token)
		end

	end
end)
hook.Add("PlayerSay","Tokengive",function(pl,text)
	if text == "!giveme" and pl:IsAdmin() then
		pl:AddTokens(100)
	end
end)