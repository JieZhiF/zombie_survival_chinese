-- ============================================================================
-- cl_init.lua - 暗影血娃武器的客户端渲染脚本
-- 负责：绘制第一人称视图模型时叠加半透明暗色滤镜，绘制结束后恢复默认渲染状态
-- ============================================================================
INC_CLIENT()

-- 缓存渲染函数（性能优化）
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation

-- ==== PreDrawViewModel - 视图模型绘制前应用暗色半透明滤镜 ====
-- 将武器渲染为半透明暗影质感（透明度 0.55，颜色调暗至 0.1），配合暗影血娃主题
function SWEP:PreDrawViewModel(vm)
	render_SetBlend(0.55)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

-- ==== PostDrawViewModel - 视图模型绘制结束后恢复默认渲染状态 ====
function SWEP:PostDrawViewModel(vm)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end
