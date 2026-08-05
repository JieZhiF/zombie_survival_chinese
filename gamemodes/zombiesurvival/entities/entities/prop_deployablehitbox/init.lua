-- ============================================================================
-- prop_deployablehitbox/init.lua - 可部署物命中箱（服务器）
-- 负责：建立固定盒子碰撞体（不渲染）；受击时把非人类来源的伤害转交给
--       父实体（可部署物本体）扣除生命；支持打包收起
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：建立不可见固定碰撞盒 ====
function ENT:Initialize()
	-- 命中箱不渲染、不投影
	self:DrawShadow(false)
	self:SetNoDraw(true)

	-- 按 BoxMin/BoxMax 建立盒子物理体
	self:PhysicsInitBox(self.BoxMin, self.BoxMax)

	-- 启用自定义碰撞检查（配合 ShouldNotCollide 实现穿体规则）
	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()

	-- 命中箱固定不动（位置由父实体决定）
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

-- ==== AltUse - 使用键（右键）：打包收起整个可部署物 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：把收起的回调转发给父实体 ====
function ENT:OnPackedUp(pl)
	self:GetParent():OnPackedUp(pl)
end

-- ==== OnTakeDamage - 受击处理：非人类来源的伤害转交给父实体扣除生命 ====
function ENT:OnTakeDamage(dmginfo)
	-- 忽略无伤害的事件
	if dmginfo:GetDamage() <= 0 then return end

	-- 人类造成的伤害不扣减（友军火力不破坏友方部署物）
	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		-- 转发伤害：父实体扣血并记录最后攻击者（用于仇恨/反击判定）
		local parent = self:GetParent()
		if parent and parent:IsValid() then
			parent:SetObjectHealth(parent:GetObjectHealth() - dmginfo:GetDamage())
			parent:ResetLastBarricadeAttacker(attacker, dmginfo)
		end
	end
end
