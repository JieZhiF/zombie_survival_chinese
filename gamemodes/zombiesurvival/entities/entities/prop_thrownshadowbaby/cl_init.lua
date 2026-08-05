-- ============================================================================
-- cl_init.lua - 抛投暗影婴孩（客户端）：半透明暗影外观渲染
-- 负责：以 55% 透明度与深黑色调绘制婴孩模型，呈现暗影质感
-- ============================================================================
INC_CLIENT()

-- 缓存渲染函数局部引用（热路径性能优化）
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation

-- ==== Draw - 绘制暗影婴孩：半透明 + 深黑色调 ====
function ENT:Draw()
	render_SetBlend(0.55)
	render_SetColorModulation(0.1, 0.1, 0.1)
	self:DrawModel()
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end
