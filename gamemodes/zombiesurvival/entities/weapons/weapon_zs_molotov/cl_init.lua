-- ============================================================================
-- weapon_zs_molotov/cl_init.lua - 燃烧瓶（客户端）
-- 负责：定义第一人称（VElements）与第三人称（WElements）的附加模型，
--       在视模型/世界模型上拼出"瓶子 + 缠布"的燃烧瓶外观
-- ============================================================================
INC_CLIENT()

-- 视模型不左右翻转
SWEP.ViewModelFlip = false
-- 第一人称镜头 FOV
SWEP.ViewModelFOV = 60

-- 第一人称附加模型：以玻璃瓶为主体，缠布（石头材质的管道碎片）贴在瓶身两侧
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_junk/glassbottle01a.mdl", bone = "ValveBiped.cube3", rel = "", pos = Vector(-2.689, -1.606, 0.225), angle = Angle(22.583, 43.495, -80.544), size = Vector(0.972, 0.972, 0.972), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 瓶身左侧的缠布（相对 base 摆放）
	["base+"] = { type = "Model", model = "models/props_combine/pipes01_cluster02a.mdl", bone = "ValveBiped.cube3", rel = "base", pos = Vector(-6.965, 2.759, -1.328), angle = Angle(-41.908, 63.826, 30.479), size = Vector(0.019, 0.019, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/rock_junk001a", skin = 0, bodygroup = {} },
	-- 瓶身右侧的缠布（相对 base 摆放）
	["base++"] = { type = "Model", model = "models/props_combine/pipes01_cluster02a.mdl", bone = "ValveBiped.cube3", rel = "base", pos = Vector(-6.877, 2.499, -1.168), angle = Angle(-41.908, 63.826, 30.479), size = Vector(0.019, 0.019, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/rock_junk001a", skin = 0, bodygroup = {} }
}

-- 第三人称附加模型：挂在右手骨上，同样由瓶身 + 缠布组成
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_junk/glassbottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.177, 1.401, -4.493), angle = Angle(171.264, -163.805, 0), size = Vector(0.972, 0.972, 0.972), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 右手后侧的缠布
	["base+++"] = { type = "Model", model = "models/props_combine/pipes01_cluster02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-7.496, 2.316, -1.423), angle = Angle(-20.43, 91.721, 48.534), size = Vector(0.019, 0.019, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/rock_junk001a", skin = 0, bodygroup = {} },
	-- 右手左侧的缠布
	["base+"] = { type = "Model", model = "models/props_combine/pipes01_cluster02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-6.965, 2.759, -1.328), angle = Angle(-41.908, 63.826, 30.479), size = Vector(0.019, 0.019, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/rock_junk001a", skin = 0, bodygroup = {} },
	-- 右手右侧的缠布
	["base++"] = { type = "Model", model = "models/props_combine/pipes01_cluster02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-7.117, 0.734, -2.342), angle = Angle(-42.299, 17.763, 11.817), size = Vector(0.019, 0.019, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/rock_junk001a", skin = 0, bodygroup = {} }
}
