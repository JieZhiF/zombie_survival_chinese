-- ============================================================================
-- status_arsenalpack - 军械包（Arsenal Pack）状态实体（服务端）
-- 负责：生成跟随持有者的军械包模型，并在持有者死亡或不再拥有军械包护身符时自动移除
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化模型与物理属性：缩小模型、球形碰撞体、无移动 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(0.4, 0)

	self:SetModel("models/Items/item_item_crate.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInitSphere(3)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

-- ==== Think - 持有者无效/死亡/失去护身符时移除本实体 ====
function ENT:Think()
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:Alive() and owner:HasTrinket("arsenalpack")) then self:Remove() end
end
