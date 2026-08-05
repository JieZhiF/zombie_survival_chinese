-- ============================================================================
-- status_oxygentank/init.lua - 氧气罐状态实体（服务器）
-- 负责：创建不可见的氧气罐模型挂载于拥有者，拥有者失去氧气罐饰品时移除
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：创建 0.5 倍缩放的氧气罐模型，无碰撞不移动 ====
function ENT:Initialize()
	-- 不绘制阴影
	self:DrawShadow(false)
	self:SetModelScale(0.5, 0)

	-- 使用金属罐模型，纯视觉效果（无碰撞、无移动）
	self:SetModel("models/props_c17/canister01a.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
end

-- ==== Think - 生命周期检查：拥有者无效、死亡或丢失氧气罐饰品时移除 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 拥有者不满足条件（无效/死亡/没有 oxygentank 饰品）则销毁本实体
	if not (owner:IsValid() and owner:Alive() and owner:HasTrinket("oxygentank")) then self:Remove() end
end
