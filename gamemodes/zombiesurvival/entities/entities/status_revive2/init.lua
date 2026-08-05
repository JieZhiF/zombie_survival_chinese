-- ============================================================================
-- status_revive2 - 复活状态实体（服务端）
-- 负责：在玩家身上登记复活状态引用，复活完成或超时后移除状态，并触发"二次活力"复活
-- ============================================================================
INC_SERVER()

-- ==== PlayerSet - 状态施加到玩家身上时，登记玩家当前的复活状态引用 ====
function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Revive = self
end

-- ==== Think - 玩家已复活或复活时间到期时自动移除状态 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() and (owner:Alive() or self:GetReviveTime() <= CurTime()) then
		self:Remove()
	end
end

-- ==== OnRemove - 清除玩家上的状态引用；若玩家仍处于死亡状态，触发"二次活力"原地复活 ====
function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		parent.Revive = nil
		-- 状态结束时玩家仍未复活：执行"二次活力"（原地复活，保留部分状态）
		if not parent:Alive() then
			parent:SecondWind()
		end
	end
end
