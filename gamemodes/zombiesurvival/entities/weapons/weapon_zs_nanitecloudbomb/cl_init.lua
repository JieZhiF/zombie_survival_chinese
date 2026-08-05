-- ============================================================================
-- weapon_zs_nanitecloudbomb/cl_init.lua - 纳米虫云炸弹（客户端逻辑）
-- 负责：视图模型设置与第一/第三人称拼接模型元素
-- ============================================================================
INC_CLIENT()

-- 视图模型设置
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70

-- 骨骼缩放：把原始手雷模型主体缩到极小
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

-- 第一人称拼接模型元素（紫色药瓶外观）
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 2.5, -7), angle = Angle(0, -90, 0), size = Vector(1, 1, 1), color = Color(135, 20, 245, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称拼接模型元素（绑定右手附着点）
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Anim_Attachment_RH", rel = "", pos = Vector(0, 4, 0.5), angle = Angle(0, 0, -90), size = Vector(1, 1, 1), color = Color(135, 20, 245, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
