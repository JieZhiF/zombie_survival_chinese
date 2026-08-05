-- ============================================================================
-- weapon_zs_shadowlurker/cl_init.lua - 暗影潜行者（客户端定义）
-- 负责：第一人称视角下渲染半透明暗色效果（潜行者视觉风格）
-- ============================================================================
-- 客户端专用（GMod 武器文件的标准客户端入口标记）
INC_CLIENT()

-- 缓存渲染函数（性能优化：避免每帧查找全局函数）
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation

-- ==== PreDrawViewModel - 绘制第一人称模型前设置半透明暗色 ====
function SWEP:PreDrawViewModel(vm)
	-- 模型透明度 45%，颜色调暗至 10%（营造暗影效果）
	render_SetBlend(0.45)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

-- ==== PostDrawViewModel - 绘制完成后恢复渲染状态 ====
function SWEP:PostDrawViewModel(vm)
	-- 恢复完全透明与正常颜色
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end
