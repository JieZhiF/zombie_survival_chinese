-- ============================================================================
-- weapon_zs_mediccloudbomb/cl_init.lua - 医疗烟雾弹（客户端入口）
-- 负责：配置第一人称手持模型的显示（用医疗瓶代替手雷外观）
-- ============================================================================

INC_CLIENT()

-- 视角模型不镜像翻转
SWEP.ViewModelFlip = false
-- 第一人称镜头视野大小
SWEP.ViewModelFOV = 70

-- 将视角模型上的手雷主体骨骼缩小为不可见（隐藏原手雷模型）
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

-- 第一人称附加模型：手持医疗瓶
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 2.5, -7), angle = Angle(0, -90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称附加模型：同样的医疗瓶，供他人视角显示
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Anim_Attachment_RH", rel = "", pos = Vector(0, 4, 0.5), angle = Angle(0, 0, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
