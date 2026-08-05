-- ============================================================================
-- projectile_shadeice/cl_init.lua - 寒冰投射物（客户端）
-- 负责：应用冰蓝色着色材质与模型缩放，以 95% 半透明度绘制冰弹
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：应用着色材质、颜色与缩放 ====
function ENT:Initialize()
	self:SetMaterial("models/shadertest/shader2")
	self:SetColor(Color(0, 150, 255, 255))
	self:SetModelScale(0.3, 0)
end

-- ==== DrawTranslucent - 半透明绘制：压低透明度后绘制模型 ====
function ENT:DrawTranslucent()
	render.SetBlend(0.95)
	self:DrawModel()
	render.SetBlend(1)
end