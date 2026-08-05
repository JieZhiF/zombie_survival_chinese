-- ============================================================================
-- cl_init.lua - 污秽肿胀僵尸武器客户端脚本
-- 负责：绘制视图模型时覆盖为藤壶表皮材质并调制暗绿色，绘制后恢复原样
-- ============================================================================
INC_CLIENT()

-- ==== ViewModelDrawn - 视图模型绘制完成后恢复默认渲染状态 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
	render.SetColorModulation(1, 1, 1)
end

-- 藤壶表皮材质（用于覆盖视图模型外观）
local matSheet = Material("Models/Barnacle/barnacle_sheet")

-- ==== PreDrawViewModel - 视图模型绘制前应用藤壶表皮材质 ====
-- 覆盖材质并调制为暗绿色，让僵尸手臂呈现污秽肿胀质感
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
	render.SetColorModulation(0.16, 0.3, 0.12)
end
