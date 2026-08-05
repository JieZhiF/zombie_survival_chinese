-- ============================================================================
-- init.lua - 复活状态（服务器）：复活生命周期与二次活力
-- 负责：记录被复活玩家的引用；玩家存活或复活完成时移除，并触发二次活力
-- ============================================================================
INC_SERVER()

-- ==== PlayerSet - 玩家状态挂接：记录复活状态引用 ====
function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Revive = self
end

-- ==== Think - 玩家存活或复活倒计时结束则移除状态 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() and (owner:Alive() or self:GetReviveTime() <= CurTime()) then
		self:Remove()
	end
end

-- ==== OnRemove - 移除时：玩家仍死亡则触发"二次活力" ====
function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		parent.Revive = nil
		-- 复活倒计时结束仍未存活：给予二次活力原地复活
		if not parent:Alive() then
			parent:SecondWind()
		end
	end
end
