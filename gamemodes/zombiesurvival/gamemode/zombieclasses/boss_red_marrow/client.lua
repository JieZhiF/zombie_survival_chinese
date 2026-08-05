-- ============================================================================
-- boss_red_marrow/client.lua - 红髓 (Red Marrow) BOSS 客户端逻辑
-- 负责：击杀图标、红色调渲染与藤壶皮肤材质
-- ============================================================================

include("shared.lua")

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/skeletal_walker"
-- 图标颜色（红色）
CLASS.IconColor = Color(255, 0, 0)

-- 皮肤材质（藤壶皮肤）
local matSkin = Material("Models/Barnacle/barnacle_sheet")

-- ==== PrePlayerDraw - 绘制前覆盖藤壶皮肤材质并施加红色调 ====
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(1, 0, 0)
	render.ModelMaterialOverride(matSkin)
end

-- ==== PostPlayerDraw - 绘制后恢复材质与默认颜色 ====
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end
