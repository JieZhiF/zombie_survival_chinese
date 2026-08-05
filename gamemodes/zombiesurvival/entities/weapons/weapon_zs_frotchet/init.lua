-- ============================================================================
-- weapon_zs_frotchet/init.lua - 寒冰短矛（服务器端）
-- 负责：近战命中结算——蓄力攻击加成、腿部减速伤害、以及地面冰刺生成
-- ============================================================================

INC_SERVER()

-- ==== OnMeleeHit - 近战命中回调 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	-- 蓄力攻击时临时提升伤害与击退
	local secondary = self:IsCharging()

	if secondary then
		self.OriginalMeleeDamage = self.MeleeDamage
		self.OriginalMeleeKnockBack = self.MeleeKnockBack
		self.MeleeDamage = self.MeleeDamage * self.MeleeDamageSecondaryMul
		self.MeleeKnockBack = self.MeleeKnockBack * self.MeleeKnockBackSecondaryMul
	end

	local owner = self:GetOwner()
	-- 命中玩家时施加腿部伤害（寒冷减速），蓄力攻击效果更强
	if hitent:IsValid() and hitent:IsPlayer() then
		hitent:AddLegDamageExt(secondary and 18 or 15, owner, self, SLOWTYPE_COLD)
	end

	-- 蓄力攻击砸到平坦地面时，在命中点生成冰刺（地对空尖刺）
	if tr.HitWorld and tr.HitNormal.z > 0.8 and hitent == Entity(0) and secondary then
		local ice = ents.Create("env_protrusionspike")
		if ice:IsValid() then
			ice:SetPos(tr.HitPos)
			ice:SetOwner(owner)
			ice.Damage = self.MeleeDamage * 0.85
			ice.Team = owner:Team()
			ice:Spawn()
		end
	end
end

-- ==== PostOnMeleeHit - 命中结算后回调（还原蓄力加成） ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	-- 还原蓄力攻击时临时修改的伤害与击退值
	if self:IsCharging() then
		self.MeleeDamage = self.OriginalMeleeDamage
		self.MeleeKnockBack = self.OriginalMeleeKnockBack
	end
end
