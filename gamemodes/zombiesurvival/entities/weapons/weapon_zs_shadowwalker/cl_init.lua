-- ============================================================================
-- weapon_zs_shadowwalker/cl_init.lua - 暗影行者僵尸利爪（客户端）
-- 负责：第一人称手臂半透明 + 压暗渲染，营造暗影行者若隐若现的外观
-- ============================================================================
INC_CLIENT()

-- 缓存渲染函数（热路径性能优化）
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation

-- ==== PreDrawViewModel - 绘制视模型前：半透明并整体压暗 ====
function SWEP:PreDrawViewModel(vm)
	-- 混合度 45% + 深灰色调（暗影外观）
	render_SetBlend(0.45)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

-- ==== PostDrawViewModel - 视模型绘制后：恢复不透明与正常颜色 ====
function SWEP:PostDrawViewModel(vm)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end
