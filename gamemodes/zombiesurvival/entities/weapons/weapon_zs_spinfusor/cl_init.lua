-- ============================================================================
-- weapon_zs_spinfusor/cl_init.lua - 旋转掷弹枪（客户端）
-- 负责：定义武器槽位归属、枪身 3D2D HUD 挂点，
--       以及第一/第三人称的蓝色能量武器外观拼装
-- ============================================================================
INC_CLIENT()
-- 武器槽位：弩/螺栓类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotBolt")
SWEP.SlotGroup = WEPSELECT_BOLT
-- 枪身 3D2D HUD 挂点骨骼与偏移/缩放/角度
SWEP.HUD3DBone = "ValveBiped.Crossbow_base"
SWEP.HUD3DPos = Vector(-0.3, -1, -4.54)
SWEP.HUD3DScale = 0.035
SWEP.HUD3DAng = Angle(180, 0, -55)

-- 第一人称镜头 FOV 与视模型朝向
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false

-- 第一人称附加模型：以弩为基础拼出蓝色能量武器外形
SWEP.VElements = {
	["base+++"] = { type = "Model", model = "models/props_lab/eyescanner.mdl", bone = "ValveBiped.Crossbow_base", rel = "", pos = Vector(-0, -1.854, 0.455), angle = Angle(-24.781, 90, 180), size = Vector(0.307, 0.476, 0.423), color = Color(103, 168, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+++++"] = { type = "Model", model = "models/props_combine/combine_binocular01.mdl", bone = "ValveBiped.Crossbow_base", rel = "", pos = Vector(-0, 1.748, -1.219), angle = Angle(-9.438, 90, -0), size = Vector(0.316, 0.428, 0.321), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 枪身主体（蓝色护板）
	["base"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Crossbow_base", rel = "", pos = Vector(-3.401, -0.851, 6.88), angle = Angle(0, -90, 0), size = Vector(0.174, 0.174, 0.174), color = Color(142, 197, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base++++"] = { type = "Model", model = "models/props_combine/combinecrane002.mdl", bone = "ValveBiped.Crossbow_base", rel = "", pos = Vector(0.391, -2.362, 14.17), angle = Angle(-180, 0, 0), size = Vector(0.032, 0.029, 0.067), color = Color(125, 193, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "ValveBiped.Crossbow_base", rel = "", pos = Vector(3.4, -0.851, 6.88), angle = Angle(0, -90, 0), size = Vector(0.174, 0.174, 0.174), color = Color(142, 197, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 弩机上的能量环
	["base++"] = { type = "Model", model = "models/props_combine/breentp_rings.mdl", bone = "ValveBiped.bolt", rel = "", pos = Vector(0, -0.468, 1.162), angle = Angle(0, 0, 90), size = Vector(0.054, 0.054, 0.014), color = Color(42, 173, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称附加模型：挂在右手骨上的同款外形
SWEP.WElements = {
	["base+++++"] = { type = "Model", model = "models/props_combine/combine_binocular01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7.879, 1.001, -0.686), angle = Angle(-100.002, 7.423, 0), size = Vector(0.316, 0.428, 0.321), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/props_combine/breentp_rings.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(13.13, -0.075, -5.329), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.014), color = Color(42, 173, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_combine/combine_fence01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15.503, 3.358, -4.2), angle = Angle(90, -170, 0), size = Vector(0.174, 0.174, 0.174), color = Color(142, 197, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base++++"] = { type = "Model", model = "models/props_combine/combinecrane002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(22.2, -1.374, -5.395), angle = Angle(180, -79.429, 90), size = Vector(0.032, 0.029, 0.067), color = Color(125, 193, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Model", model = "models/props_lab/eyescanner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.237, 0.861, -5.441), angle = Angle(-57.536, -171.206, 0), size = Vector(0.307, 0.476, 0.423), color = Color(103, 168, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(14.208, -3.931, -4.16), angle = Angle(90, -170, 0), size = Vector(0.174, 0.174, 0.174), color = Color(142, 197, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
