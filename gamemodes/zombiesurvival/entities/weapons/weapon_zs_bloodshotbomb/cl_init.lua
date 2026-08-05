-- ============================================================================
-- cl_init.lua - 血弹炸弹武器客户端脚本
-- 负责：定义 SCK 自定义模型元素（VElements/WElements），将手雷外观拼装为
--       腐蚀性血弹（红色药剂瓶 + 洗衣机金属环 + 实验室管身）
-- ============================================================================
INC_CLIENT()

-- 第一人称视图模型的 SCK 自定义部件
SWEP.VElements = {
	-- 部件 corrosive_nade++：顶部红色药剂瓶（血弹液体）
	["corrosive_nade++"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Grenade_body", rel = "corrosive_nade", pos = Vector(0, -7, 0.4), angle = Angle(0, 0, 90), size = Vector(0.75, 0.75, 1.299), color = Color(255, 59, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 corrosive_nade+：金属环扣（洗衣机零件）
	["corrosive_nade+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Grenade_body", rel = "corrosive_nade", pos = Vector(0, -0.201, 0.4), angle = Angle(0, 90, 0), size = Vector(0.119, 0.019, 0.019), color = Color(100, 100, 100, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 corrosive_nade：管身主体（实验室零件，SMG 贴图）
	["corrosive_nade"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0, 0, -1), angle = Angle(0, 0, 90), size = Vector(0.449, 0.55, 0.5), color = Color(200, 200, 200, 255), surpresslightning = false, material = "models/weapons/v_smg1/v_smg1_sheet", skin = 0, bodygroup = {} }
}

-- 第三人称世界模型的 SCK 自定义部件
SWEP.WElements = {
	-- 部件 corrosive_nade+：金属环扣（世界模型）
	["corrosive_nade+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "corrosive_nade", pos = Vector(0, -0.201, 0.4), angle = Angle(0, 90, 0), size = Vector(0.119, 0.019, 0.019), color = Color(100, 100, 100, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 corrosive_nade++：顶部红色药剂瓶（世界模型）
	["corrosive_nade++"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "corrosive_nade", pos = Vector(0, -7, 0.4), angle = Angle(0, 0, 90), size = Vector(0.75, 0.75, 1.299), color = Color(255, 59, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 corrosive_nade：管身主体（世界模型）
	["corrosive_nade"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5, 2, 0), angle = Angle(0, 0, 99.35), size = Vector(0.449, 0.55, 0.5), color = Color(200, 200, 200, 255), surpresslightning = false, material = "models/weapons/v_smg1/v_smg1_sheet", skin = 0, bodygroup = {} }
}
