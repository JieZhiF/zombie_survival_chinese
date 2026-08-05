-- ============================================================================
-- status_stun/init.lua - 眩晕状态实体（服务器端）
-- 负责：冻结被眩晕玩家（无法移动），并在状态移除时解冻
-- ============================================================================

INC_SERVER()

-- ==== Think - 每帧逻辑 ====
-- 调用基类逻辑；持有者死亡时提前移除眩晕状态
function ENT:Think()
	self.BaseClass.Think(self)

	local owner = self:GetOwner()

	if not owner:Alive() then
		self:Remove()
	end
end


-- ==== PlayerSet - 玩家绑定回调 ====
-- 状态附加到玩家时冻结其移动，并记录眩晕时刻
function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Freeze(true)

	pPlayer.LastStunned = CurTime()
end

-- ==== OnRemove - 移除时 ====
-- 解除持有者的冻结（恢复移动能力）
function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		parent:Freeze(false)
	end
end
