-- ============================================================================
-- weapon_zs_crygasgrenade/cl_init.lua - 冷冻气体手雷（客户端）
-- 负责：定义手雷的蓝色罐体外观（第一/三人称附加模型）
-- ============================================================================

INC_CLIENT()

-- 第一人称附加模型：蓝色冷冻气体罐（罐体 + 顶部阀件）
SWEP.VElements = {
	["corrosive_nade+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Grenade_body", rel = "corrosive_nade", pos = Vector(0, -0.201, 0.4), angle = Angle(0, 90, 0), size = Vector(0.1, 0.029, 0.029), color = Color(74, 95, 120, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["corrosive_nade"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0, 0, -1), angle = Angle(0, 0, 90), size = Vector(0.449, 0.4, 0.449), color = Color(67, 119, 165, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型：第三人称对应的冷冻气体罐
SWEP.WElements = {
	["corrosive_nade+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "corrosive_nade", pos = Vector(0, -0.201, 0.4), angle = Angle(0, 90, 0), size = Vector(0.1, 0.029, 0.029), color = Color(74, 95, 120, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["corrosive_nade"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5, 2, -0.5), angle = Angle(0, 0, 90), size = Vector(0.449, 0.4, 0.449), color = Color(67, 119, 165, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
