-- ============================================================================
-- weapon_zs_handgrenade/cl_init.lua - 手榴弹（客户端）
-- 负责：手榴弹 HUD 3D 图标、第一/第三人称拼装模型与爆炸物栏位设置
-- ============================================================================
INC_CLIENT()

-- HUD 3D 图标（大图标预览）的骨骼、位置与缩放
SWEP.HUD3DBone = "Python"
SWEP.HUD3DPos = Vector(1.4, -0.3, -2.5)
SWEP.HUD3DScale = 0.015

-- 隐藏原生模型，全部由拼装件构成
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 第一人称拼装件：手雷外形（罐体、拉环、引信等）
SWEP.VElements = {
	["element_name++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "Python", rel = "", pos = Vector(0, 2.52, -4.041), angle = Angle(180, 0, -111.02), size = Vector(0.513, 0.8, 0.349), color = Color(72, 72, 72, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name++++++"] = { type = "Model", model = "models/hunter/triangles/2x2x2.mdl", bone = "Python", rel = "", pos = Vector(0, -0.357, -1.77), angle = Angle(180, 0, -135.064), size = Vector(0.017, 0.017, 0.017), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name+++++++"] = { type = "Model", model = "models/hunter/blocks/cube1x1x1.mdl", bone = "Python", rel = "", pos = Vector(0, -0.357, -1.551), angle = Angle(180, 0, 0), size = Vector(0.035, 0.056, 0.009), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name++++++++"] = { type = "Model", model = "models/hunter/misc/shell2x2a.mdl", bone = "Python", rel = "", pos = Vector(0, -0.197, -1.397), angle = Angle(180, 0, 0), size = Vector(0.028, 0.028, 0.028), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["addka"] = { type = "Model", model = "models/weapons/Shotgun_shell.mdl", bone = "Bullet1", rel = "", pos = Vector(0, -0.359, 1.59), angle = Angle(90, 90, 0), size = Vector(0.725, 1.401, 1.401), color = Color(255, 191, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["element_name++++++++++++"] = { type = "Model", model = "models/gibs/manhack_gib06.mdl", bone = "Python", rel = "", pos = Vector(0, 1.922, -0.389), angle = Angle(-90, 180, -180), size = Vector(0.252, 0.128, 0.252), color = Color(255, 255, 255, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name+++++++++++"] = { type = "Model", model = "models/props_vehicles/tire001b_truck.mdl", bone = "Python", rel = "", pos = Vector(0, 1.93, -0.783), angle = Angle(180, 0, 90), size = Vector(0.057, 0.071, 0.059), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name+++++++++"] = { type = "Model", model = "models/hunter/blocks/cube1x1x1.mdl", bone = "Python", rel = "", pos = Vector(0, -1.408, 6.875), angle = Angle(180, 90, 0), size = Vector(0.035, 0.009, 0.009), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name"] = { type = "Model", model = "models/hunter/tubes/tube1x1x4.mdl", bone = "Cylinder", rel = "", pos = Vector(0, 0, -1.611), angle = Angle(0, 0, 0), size = Vector(0.052, 0.052, 0.014), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name+++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "Python", rel = "", pos = Vector(0, 4.07, -4.361), angle = Angle(180, 0, -90), size = Vector(0.513, 0.8, 0.358), color = Color(72, 72, 72, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name+++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "Python", rel = "", pos = Vector(0, 1.19, -3.122), angle = Angle(180, 0, -132.299), size = Vector(0.513, 0.8, 0.349), color = Color(72, 72, 72, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "Python", rel = "", pos = Vector(0, -0.357, -2.895), angle = Angle(180, 0, -73.21), size = Vector(0.057, 0.057, 0.061), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["element_name+"] = { type = "Model", model = "models/hunter/tubes/tube1x1x4.mdl", bone = "Python", rel = "", pos = Vector(0, -0.172, 1.197), angle = Angle(0, 0, 0), size = Vector(0.052, 0.052, 0.034), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["element_name++"] = { type = "Model", model = "models/phxtended/bar1x45a.mdl", bone = "Python", rel = "", pos = Vector(0.47, 0.968, 5.1), angle = Angle(180, 0, 90), size = Vector(0.128, 0.151, 0.111), color = Color(255, 0, 0, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} }
}

-- 第三人称拼装件：左轮手枪模型占位
SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/weapons/w_357.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0.681, 0.14, -0.708), angle = Angle(-180, 180, 0), size = Vector(1, 1, 1), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第一人称视野与镜像
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false

-- 武器栏位：爆炸物槽
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotExplosives")
SWEP.SlotGroup = WEPSELECT_EXPLOSIVE
SWEP.SlotPos = 0
