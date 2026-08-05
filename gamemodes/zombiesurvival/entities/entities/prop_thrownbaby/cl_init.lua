-- ============================================================================
-- prop_thrownbaby/cl_init.lua - 被投掷的婴儿实体（客户端）
-- 负责：放大模型并绘制（投掷动画与渲染）
-- ============================================================================

INC_CLIENT()

-- ==== Initialize - 初始化 ====
-- 放大模型至 1.3 倍（突出投掷物视觉效果）
function ENT:Initialize()
	self:SetModelScale(1.3, 0)
end

-- ==== Draw - 绘制 ====
-- 直接绘制模型
function ENT:Draw()
	self:DrawModel()
end
