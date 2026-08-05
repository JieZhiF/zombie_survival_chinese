-- ============================================================================
-- status_frostshadeshield/init.lua - 冰霜护盾状态结算（服务器）
-- 负责：护盾展开状态机：展开完成时构建物理实体，结束/被打碎时销毁并
--       计算拥有者的下次冷却；护盾自动回血；逐帧跟随拥有者前方
-- ============================================================================
INC_SERVER()

-- ==== Think - 每帧驱动护盾展开/销毁状态机、回血与跟随 ====
function ENT:Think()
	local fCurTime = CurTime()
	local owner = self:GetOwner()

	if owner:IsValid() then
		-- 结束条件：完全展开阶段超时、拥有者死亡/变为人类阵营、或护盾被打碎
		-- 此时按受损程度计算额外冷却（打碎为固定 12 秒，否则 2 秒+损坏时长）
		if self:GetStateEndTime() <= fCurTime and self:GetState() == 1 or not owner:Alive() or owner:Team() ~= TEAM_UNDEAD or self.Destroyed then
			local extraduration = (1 - self:GetObjectHealth()/self:GetMaxObjectHealth()) * 10
			owner.NextShield = fCurTime + (self.Destroyed and 12 or (2 + extraduration))
			self:Remove()
			return
		-- 展开阶段超时且尚未构建：赋予实体碰撞（静态 VPhysics），完成展开
		elseif self:GetStateEndTime() <= fCurTime and self:GetState() == 0 and not self.Constructed then
			self:PhysicsInit(SOLID_VPHYSICS)

			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
			end

			self:EmitSound("physics/glass/glass_impact_bullet3.wav", 70, 75)
			self.Constructed = true
		end

		-- 完全展开阶段：解除实体碰撞并播放碎裂音效（护盾进入结束演出）
		if self:GetState() == 1 and self.Constructed then
			self:PhysicsInit(SOLID_NONE)
			self:EmitSound("physics/glass/glass_pottery_break4.wav", 70, 110)

			self.Constructed = false
		end

		-- 周期性回血：每 0.4 秒回复 15 点护盾血量（不超过上限；受击后延迟生效）
		if fCurTime >= self.NextHeal and self.DamageTaken ~= 150 then
			self.NextHeal = fCurTime + 0.4

			if self:GetObjectHealth() < self:GetMaxObjectHealth() then
				self:SetObjectHealth(math.min(self:GetObjectHealth() + 15, self:GetMaxObjectHealth()))
			end
		end

		-- 每秒清零一次受击累计量，用于门控回血节奏
		if fCurTime >= self.NextDamageSet then
			self.NextDamageSet = fCurTime + 1
			self.DamageTaken = 0
		end

		-- 平滑跟随：位置缓动到拥有者前方 40 单位，角度绕自身轴旋转 135 度缓动
		self:SetPos(LerpVector(0.1, self:GetPos(), owner:GetPos() + owner:GetForward() * 40))
		local angs = owner:GetAngles()
		angs:RotateAroundAxis(self:GetUp(), 135)
		self:SetAngles(LerpAngle(0.2, self:GetAngles(), angs))
	else
		-- 拥有者失效时直接移除
		self:Remove()
	end

	-- 每帧持续运行
	self:NextThink(fCurTime)
	return true
end
