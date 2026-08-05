-- ============================================================================
-- weapon_zs_wrench/cl_init.lua - 近战维修工具「扳手」（Wrench）客户端
-- 负责：第一人称视角设置与 SCK 扳手模型元素
-- ============================================================================

INC_CLIENT()

-- 第一人称视野 FOV 55、不翻转
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false

-- 隐藏官方模型，改用 SCK 自定义外观
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- SCK 元素（第一人称）：手持的扳手模型（金属材质、放大 1.5 倍）
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 2, 0), angle = Angle(190, 0, 90), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} }
}

-- SCK 元素（第三人称）：与第一人称一致的扳手外观
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 1, 0), angle = Angle(190, 90, 90), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} }
}
