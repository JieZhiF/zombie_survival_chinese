-- ============================================================================
-- weapon_zs_chilledghoul/cl_init.lua - 冰霜食尸鬼武器（客户端）
-- 负责：将第一人称模型渲染为冰蓝色调，营造寒冰质感
-- ============================================================================
INC_CLIENT()

-- ==== ViewModelDrawn - 视图模型绘制后 ====
-- 恢复材质覆盖与颜色调制（还原为默认渲染）
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
	render.SetColorModulation(1, 1, 1)
end

-- 冰霜皮肤材质
local matSheet = Material("Models/humans/corpse/corpse1.vtf")
-- ==== PreDrawViewModel - 视图模型绘制前 ====
-- 覆盖材质并调制为冰蓝色
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
	render.SetColorModulation(0.2, 0.5, 0.95)
end
