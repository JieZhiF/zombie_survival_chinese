-- ============================================================================
-- weapon_zs_proxymine/cl_init.lua - 感应地雷（客户端入口）
-- 负责：配置第一人称手持模型的显示（用小型假模型模拟手持地雷）
-- ============================================================================

INC_CLIENT()

-- 视角模型不镜像翻转
SWEP.ViewModelFlip = false
-- 第一人称镜头视野大小
SWEP.ViewModelFOV = 50

-- 将视角模型上的原始方块骨骼缩小为不可见（隐藏原模型部件）
SWEP.ViewModelBoneMods = {
	["ValveBiped.cube1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.cube2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.cube"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
-- 第一人称附加模型：油桶底座 + 断路器外壳，拼成手持地雷外观
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.091, 3.181, 3), angle = Angle(0, 0, 180), size = Vector(0.16, 0.16, 0.16), color = Color(235, 205, 185, 255), surpresslightning = false, material = "models/props_canal/canal_bridge_railing_01c", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_c17/substation_circuitbreaker01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 7), angle = Angle(0, 0, 0), size = Vector(0.02, 0.02, 0.02), color = Color(255, 205, 175, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称附加模型：只有油桶底座，供他人视角显示
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 2.273, -0.456), angle = Angle(-43.978, 27.614, 70.568), size = Vector(0.16, 0.16, 0.16), color = Color(235, 205, 185, 255), surpresslightning = false, material = "models/props_canal/canal_bridge_railing_01c", skin = 0, bodygroup = {} }
}
