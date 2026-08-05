-- ============================================================================
-- status_redmarrow/init.lua - 红骨髓状态（服务器）
-- 负责：每帧校验存活条件——到期、或拥有者死亡/离开僵尸阵营/职业不再
--       是红骨髓（Red Marrow）时移除自身
-- ============================================================================
INC_SERVER()

-- ==== Think - 存活校验：超时或失去红骨髓职业即移除自身 ====
function ENT:Think()
	local owner = self:GetOwner()

	-- 到期，或拥有者死亡/不在僵尸阵营/职业不再是红骨髓时移除
	if self.DieTime <= CurTime() or not (owner:Alive() and owner:Team() == TEAM_UNDEAD and owner:GetZombieClassTable().Name == "Red Marrow") then
		self:Remove()
	end
end


  