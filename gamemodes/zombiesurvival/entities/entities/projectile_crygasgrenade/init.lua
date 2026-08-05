-- ============================================================================
-- init.lua - 冷冻瓦斯手雷（服务端）：周期性腐蚀伤害与腿部冷冻减速
-- 负责：落地喷射冷冻瓦斯，按 TickTime 周期对圈内僵尸造成伤害并施加冷减速
-- ============================================================================
INC_SERVER()

-- 瓦斯喷射总次数（剩余次数，递减到 0 后停止）
ENT.Ticks = 19
-- 每次喷射对单个目标造成的伤害
ENT.Damage = 8
-- 每次喷射附加的腿部伤害（触发冷冻减速效果）
ENT.LegDamage = 13
-- 伤害结算期间的得分倍率
ENT.PointsMultiplier = 1.25

-- ==== AcceptInput - 处理腐蚀输入：对圈内目标施加伤害与减速 ====
function ENT:AcceptInput(name, activator, caller, arg)
	if name ~= "corrode" then return end

	self.Ticks = self.Ticks - 1

	-- 所有者失效时以手雷自身作为伤害来源
	local owner = self:GetOwner()
	if not owner:IsValidLivingHuman() then owner = self end

	local vPos = self:GetPos()

	-- 结算期间启用 1.25 倍得分倍率
	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end

	-- 遍历瓦斯半径内的实体：仅伤害可见的僵尸或投掷者本人
	for _, ent in pairs(ents.FindInSphere(vPos, self.Radius)) do
		if ent and (ent:IsValidLivingPlayer() and (ent:Team() == TEAM_UNDEAD or ent == owner)) and WorldVisible(vPos, ent:NearestPoint(vPos)) then
			if owner:IsValidLivingHuman() then
				ent:EmitSound("physics/glass/glass_impact_bullet"..math.random(4)..".wav", 70, 85)
				ent:TakeSpecialDamage(self.Damage, DMG_DROWN, owner, self)
				-- 施加腿部伤害并附带冷冻类减速
				ent:AddLegDamageExt(self.LegDamage, owner, self, SLOWTYPE_COLD)
			end
		end
	end

	-- 结算结束，清除得分倍率
	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end

	-- 仍有剩余喷射次数时继续调度下一轮
	if self.Ticks > 0 then
		self:Fire("corrode", "", self.TickTime)
	end

	return true
end
