-- ============================================================================
-- status_burn/init.lua - 燃烧状态（服务器）
-- 负责：每 0.5 秒对拥有者造成灼烧伤害并衰减伤害值；拥有者死亡、入水、
--       伤害耗尽或与施放者同阵营时提前结束燃烧
-- ============================================================================
INC_SERVER()

-- ==== Think - 灼烧结算：持续造成火焰伤害并衰减，条件不符则移除 ====
function ENT:Think()
	local owner = self:GetOwner()

	-- 伤害耗尽/拥有者入水/死亡/与施放者同阵营（友军误伤保护）时结束燃烧
	if self:GetDamage() <= 0 or owner:WaterLevel() > 0 or not owner:Alive() or (owner:Team() == self.Damager:Team() and owner ~= self.Damager) then
		self:Remove()
		return
	end

	-- 本次灼烧伤害为 1~2 点（由剩余伤害值钳制而来）
	local dmg = math.Clamp(self:GetDamage(), 1, 2)

	-- 造成火焰伤害；施放者失效或与目标同阵营时以拥有者自身为伤害来源
	owner:TakeSpecialDamage(dmg, DMG_BURN, self.Damager and self.Damager:IsValid() and self.Damager:IsPlayer() and self.Damager:Team() ~= owner:Team() and self.Damager or owner, self)
	-- 伤害值逐次衰减，归零后燃烧自然结束
	self:AddDamage(-dmg)

	-- 每 0.5 秒结算一次灼烧
	self:NextThink(CurTime() + 0.5)
	return true
end
