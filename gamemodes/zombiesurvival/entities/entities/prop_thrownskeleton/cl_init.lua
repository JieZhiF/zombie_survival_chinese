-- ============================================================================
-- prop_thrownskeleton/cl_init.lua - 被投掷的强化骷髅巢穴（客户端）
-- 负责：放大模型并绘制
-- ============================================================================

INC_CLIENT()

-- ==== Initialize - 放大模型 ====
function ENT:Initialize()
	self:SetModelScale(1.3, 0)
end

-- ==== Draw - 绘制模型 ====
function ENT:Draw()
	self:DrawModel()
end
