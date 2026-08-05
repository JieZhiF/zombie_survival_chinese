-- ============================================================================
-- weapon_zs_gigashadowchild/cl_init.lua - 暗影巨婴（客户端入口）
-- 负责：绘制视角模型时应用半透明暗色滤镜（暗影视觉效果）
-- ============================================================================

INC_CLIENT()

-- 缓存渲染函数（性能优化）
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation

-- ==== PreDrawViewModel - 视角模型绘制前（应用暗影半透明滤镜） ====
function SWEP:PreDrawViewModel(vm)
	-- 半透明 + 近黑色调，让拳头呈现暗影质感
	render_SetBlend(0.55)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

-- ==== PostDrawViewModel - 视角模型绘制后（恢复正常渲染） ====
function SWEP:PostDrawViewModel(vm)
	-- 还原混合与颜色调制
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end
