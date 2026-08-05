-- ============================================================================
-- status_feigndeath/init.lua - 装死状态（服务器）
-- 负责：装死期间冻结移动、穿体不碰撞并缓慢回复生命；超时/死亡/失去条件
--       时结束装死；倒地方向由玩家按下的方向键决定
-- ============================================================================
INC_SERVER()

-- 生命回复节流时间戳（每 0.25 秒一跳）
ENT.NextHeal = 0

-- ==== OnInitialize - 初始化：注册移动冻结 hook ====
function ENT:OnInitialize()
	hook.Add("Move", self, self.Move)
end

-- ==== PlayerSet - 附加到玩家：设定穿体碰撞组、清除攻击手势并按按键定倒地方向 ====
function ENT:PlayerSet(pPlayer, bExists)
	-- 在玩家身上登记本状态引用（供其他系统查询装死状态）
	pPlayer.FeignDeath = self
	-- 切换为碎屑触发碰撞组，实现装死时的穿体效果
	pPlayer:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	-- 中断攻击/换弹手势，避免倒地时仍播放攻击动画
	pPlayer:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

	-- 按玩家按下的方向键选择倒地朝向（后/右/左，默认前方）
	if pPlayer:KeyDown(IN_BACK) then
		self:SetDirection(DIR_BACK)
	elseif pPlayer:KeyDown(IN_MOVERIGHT) then
		self:SetDirection(DIR_RIGHT)
	elseif pPlayer:KeyDown(IN_MOVELEFT) then
		self:SetDirection(DIR_LEFT)
	else
		self:SetDirection(DIR_FORWARD)
	end
end

-- ==== Think - 主循环：检查结束条件，并缓慢回复生命 ====
function ENT:Think()
	local fCurTime = CurTime()
	local owner = self:GetOwner()

	if owner:IsValid() then
		-- 结束条件：可起身阶段超时，或拥有者死亡/不再属于亡灵阵营/
		-- 当前僵尸类不允许装死（如 Boss）
		if self:GetStateEndTime() <= fCurTime and self:GetState() == 1 or not owner:Alive() or owner:Team() ~= TEAM_UNDEAD or not owner:GetZombieClassTable().CanFeignDeath then
			self:Remove()
			return
		end

		-- 生命回复节流：每 0.25 秒回复一次
		if fCurTime >= self.NextHeal then
			self.NextHeal = fCurTime + 0.25

			-- 非 Boss 且未满血时回复，单跳上限 3 点（或最大生命 3.5%，取小）
			if owner:Health() < owner:GetMaxHealth() and not owner:GetZombieClassTable().Boss then
				owner:SetHealth(math.min(owner:GetMaxHealth(), owner:Health() + math.min(owner:GetMaxHealth() * 0.035, 3)))
			end
		end
	end

	self:NextThink(fCurTime)
	return true
end

-- ==== OnRemove - 状态结束时清除玩家引用并恢复玩家间碰撞 ====
function ENT:OnRemove()
	local parent = self:GetOwner()
	if parent:IsValid() then
		parent.FeignDeath = nil
		-- 强制重新检测玩家重叠：不再与其他玩家重叠则恢复普通玩家碰撞组
		parent:TemporaryNoCollide(true)
	end
end
