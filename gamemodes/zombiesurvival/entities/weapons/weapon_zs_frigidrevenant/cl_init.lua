-- ============================================================================
-- cl_init.lua - 冰封亡魂（僵尸近战武器）客户端渲染逻辑
-- 负责：第一人称持握渲染为半透明冰蓝色（营造冰霜亡魂观感）
-- ============================================================================

-- 客户端 realm 守卫：仅客户端加载本文件（替代 if CLIENT then 写法）
INC_CLIENT()

-- 缓存渲染函数，避免每帧查全局表（性能惯例）
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation

-- ==== PreDrawViewModel - 绘制视图模型前：设置半透明与冰蓝色调 ====
function SWEP:PreDrawViewModel(vm)
	render_SetBlend(0.65)
	render_SetColorModulation(0.1, 0.5, 0.9)
end

-- ==== PostDrawViewModel - 绘制视图模型后：恢复默认渲染参数 ====
function SWEP:PostDrawViewModel(vm)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end
