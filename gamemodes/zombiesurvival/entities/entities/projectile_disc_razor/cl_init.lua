-- ============================================================================
-- projectile_disc_razor/cl_init.lua - 飞盘锯刃投射物（客户端）
-- 负责：以灰暗色调渲染锯刃模型，并缩小弹体、关闭阴影
-- ============================================================================
INC_CLIENT()

-- ==== Draw - 渲染：对模型施加灰色调色并绘制 ====
function ENT:Draw()
	render.SetColorModulation(0.65, 0.65, 0.65)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)
end

-- ==== Initialize - 初始化：缩小模型比例并关闭阴影 ====
function ENT:Initialize()
	self:SetModelScale(0.3, 0)
	self:DrawShadow(false)
end
