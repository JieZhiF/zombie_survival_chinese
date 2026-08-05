-- ============================================================================
-- weapon_zs_wildpoisonzombie/cl_init.lua - 野生毒僵尸武器（客户端）
-- 负责：第一人称爪子模型的材质覆盖（毒液黄绿色）
-- ============================================================================

INC_CLIENT()

-- ==== ViewModelDrawn - 模型绘制完成后复位渲染状态 ====
function SWEP:ViewModelDrawn()
	-- 清除材质覆盖并复位颜色调制
	render.ModelMaterialOverride(0)
	render.SetColorModulation(1, 1, 1)
end

-- 毒液材质（黄绿色皮肤）
local matSheet = Material("Models/headcrab/allinonebacup2.vtf")
-- ==== PreDrawViewModel - 绘制第一人称模型前覆盖材质 ====
function SWEP:PreDrawViewModel(vm)
	-- 覆盖为毒液材质并调成黄绿色（0.7, 0.9, 0.2）
	render.ModelMaterialOverride(matSheet)
	render.SetColorModulation(0.7, 0.9, 0.2)
end
