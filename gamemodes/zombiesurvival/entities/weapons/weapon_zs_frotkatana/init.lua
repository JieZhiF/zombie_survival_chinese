-- ============================================================================
-- init.lua - 霜刃（蓄力型冰霜武士刀近战武器）服务端逻辑
-- 负责：蓄力攻击的伤害/击退倍增、腿部冰霜减速附加、命中时生成冰锥
--       （env_protrusionspike）的范围伤害
-- ============================================================================

-- 服务端 realm 守卫：仅服务端加载本文件（替代 if SERVER then 写法）
INC_SERVER()

-- ==== OnMeleeHit - 近战命中结算：蓄力加成、腿部减速与冰锥生成 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	-- 是否为蓄力（右键充能）攻击
	local secondary = self:IsCharging()

	-- 蓄力攻击时临时提升伤害与击退（乘算系数，结算后由 PostOnMeleeHit 还原）
	if secondary then
		self.OriginalMeleeDamage = self.MeleeDamage
		self.OriginalMeleeKnockBack = self.MeleeKnockBack
		self.MeleeDamage = self.MeleeDamage * self.MeleeDamageSecondaryMul
		self.MeleeKnockBack = self.MeleeKnockBack * self.MeleeKnockBackSecondaryMul
	end

	local owner = self:GetOwner()
	-- 命中玩家：追加腿部伤害（蓄力 18 / 普通 15，寒冷减速类型）
	if hitent:IsValid() and hitent:IsPlayer() then

		hitent:AddLegDamageExt(secondary and 18 or 15, owner, self, SLOWTYPE_COLD)
		-- 蓄力命中时在目标位置生成冰锥（伤害为当前近战伤害的 85%）
		if secondary then
			local ice = ents.Create("env_protrusionspike")
			if ice:IsValid() then
				ice:SetPos(hitent:GetPos())
				ice:SetOwner(owner)
				ice.Damage = self.MeleeDamage * 0.85
				ice.Team = owner:Team()
				ice:Spawn()
			end
		end
	end
	-- 蓄力且命中近乎水平的普通地面（法线朝上、世界实体）时也生成冰锥
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

-- ==== PostOnMeleeHit - 近战结算后：还原蓄力提升前的伤害与击退 ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if self:IsCharging() then
		self.MeleeDamage = self.OriginalMeleeDamage
		self.MeleeKnockBack = self.OriginalMeleeKnockBack
	end
end
