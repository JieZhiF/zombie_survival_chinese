-- ============================================================================
-- weapon_zs_broadside/cl_init.lua - 舷侧火箭炮（客户端）
-- 负责：客户端武器栏位设置、SCK 模型元素定义（自定义火箭炮外观）、
--       换弹动画时枪管滑动效果、副攻击客户端占位
-- ============================================================================
INC_CLIENT()

-- 武器栏位设置（爆炸物栏）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotExplosives")
SWEP.SlotGroup = WEPSELECT_EXPLOSIVE

-- 栏位内排序位置
SWEP.SlotPos = 0

-- 第一人称视角设置
SWEP.ViewModelFOV = 61
SWEP.ViewModelFlip = false

-- 3D HUD 绘制参数（在枪身骨上绘制弹药信息）
SWEP.HUD3DBone = "base"
SWEP.HUD3DPos = Vector(5.3, 3.2, 12)
SWEP.HUD3DAng = Angle(180, 0, 0)
SWEP.HUD3DScale = 0.035

-- 第一人称视角模型元素（由多个道具拼装而成的火箭炮外观）
SWEP.VElements = {
	["gep_gun+++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "base", rel = "gep_gun", pos = Vector(18, 0.5, 4.2), angle = Angle(0, 90, 180), size = Vector(0.05, 0.037, 0.029), color = Color(89, 110, 156, 255), surpresslightning = false, material = "models/props_wasteland/prison_objects002", skin = 0, bodygroup = {} },
	["gep_gun+++++++"] = { type = "Model", model = "models/props_wasteland/kitchen_stove002a.mdl", bone = "base", rel = "gep_gun", pos = Vector(2, 5, 2), angle = Angle(90, 0, 0), size = Vector(0.06, 0.059, 0.15), color = Color(55, 61, 75, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun++++++++"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "base", rel = "gep_gun", pos = Vector(-5.47, 5, 1.5), angle = Angle(180, 0, 0), size = Vector(0.259, 0.08, 0.09), color = Color(46, 64, 79, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun++"] = { type = "Model", model = "models/props_wasteland/coolingtank02.mdl", bone = "base", rel = "gep_gun", pos = Vector(4.675, 1.399, -3.1), angle = Angle(50, 90, 90), size = Vector(0.04, 0.01, 0.06), color = Color(110, 125, 168, 255), surpresslightning = false, material = "models/props_wasteland/laundry_machines001", skin = 0, bodygroup = {} },
	["gep_gun++++++"] = { type = "Model", model = "models/props_pipes/pipecluster32d_001a.mdl", bone = "base", rel = "gep_gun", pos = Vector(-5, 3, -1.5), angle = Angle(0, 90, 0), size = Vector(0.04, 0.019, 0.048), color = Color(51, 70, 127, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
	["gep_gun++++"] = { type = "Model", model = "models/props_c17/truss02g.mdl", bone = "base", rel = "gep_gun", pos = Vector(18, -0.1, 4.2), angle = Angle(0, 90, 180), size = Vector(0.17, 0.153, 0.2), color = Color(47, 64, 120, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gunf"] = { type = "Model", model = "models/props_trainstation/flatcar.mdl", bone = "base", rel = "gep_gun", pos = Vector(23, -1.56, 8), angle = Angle(0, 0, 90), size = Vector(0.029, 0.039, 0.06), color = Color(66, 105, 150, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "base", rel = "", pos = Vector(0, 0.3, 4.635), angle = Angle(90, 90, 0), size = Vector(0.04, 0.07, 0.023), color = Color(216, 219, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun+++++"] = { type = "Model", model = "models/props_wasteland/prison_heavydoor001a.mdl", bone = "base", rel = "gep_gun", pos = Vector(-0.7, 0.899, -2.1), angle = Angle(-30, 90, 90), size = Vector(0.2, 0.115, 0.129), color = Color(89, 105, 143, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 世界模型元素（第三人称显示的火箭炮外观）
SWEP.WElements = {
	["gep_gun+++"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(18, -0.5, 4.9), angle = Angle(0, 90, 180), size = Vector(0.05, 0.037, 0.029), color = Color(89, 110, 156, 255), surpresslightning = false, material = "models/props_wasteland/prison_objects002", skin = 0, bodygroup = {} },
	["gep_gun+++++++"] = { type = "Model", model = "models/props_wasteland/kitchen_stove002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(2, 5, 2), angle = Angle(90, 0, 0), size = Vector(0.06, 0.059, 0.15), color = Color(55, 61, 75, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun++++++++"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(-5.47, 5, 1.5), angle = Angle(180, 0, 0), size = Vector(0.259, 0.08, 0.09), color = Color(46, 64, 79, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun++"] = { type = "Model", model = "models/props_wasteland/coolingtank02.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(4.675, 1.399, -3.1), angle = Angle(50, 90, 90), size = Vector(0.04, 0.01, 0.06), color = Color(110, 125, 168, 255), surpresslightning = false, material = "models/props_wasteland/laundry_machines001", skin = 0, bodygroup = {} },
	["gep_gun++++++"] = { type = "Model", model = "models/props_pipes/pipecluster32d_001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(-5, 3, -1.5), angle = Angle(0, 90, 0), size = Vector(0.04, 0.019, 0.048), color = Color(51, 70, 127, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004b", skin = 0, bodygroup = {} },
	["gep_gun++++"] = { type = "Model", model = "models/props_c17/truss02g.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(18, -0.9, 4.9), angle = Angle(0, 90, 180), size = Vector(0.17, 0.153, 0.2), color = Color(47, 64, 120, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gunf"] = { type = "Model", model = "models/props_trainstation/flatcar.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(11.598, -1.56, 7), angle = Angle(0, 0, 90), size = Vector(0.029, 0.039, 0.06), color = Color(66, 105, 150, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0.5, -1.5, -11), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.025), color = Color(216, 219, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gep_gun+++++"] = { type = "Model", model = "models/props_wasteland/prison_heavydoor001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "gep_gun", pos = Vector(-0.7, 0.899, -2.1), angle = Angle(-30, 90, 90), size = Vector(0.2, 0.115, 0.129), color = Color(89, 105, 143, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 视角模型骨骼缩放（将原始 RPG 骨骼缩到极小，用 SCK 元素替代）
SWEP.ViewModelBoneMods = {
	["base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

-- ==== PostDrawViewModel - 绘制视角模型后回调（换弹时枪管滑动动画） ====
function SWEP:PostDrawViewModel(vm)
	local time = UnPredictedCurTime()
	-- 根据换弹进度计算枪管滑动方向和速度
	local reloaddelta = ((self:GetReloadFinish() - time) > (time - self:GetReloadStart()) and 55 or -7) * FrameTime()

	-- 获取枪管元素位置并沿 X 轴滑动（模拟换弹拉栓）
	local reloadpos = self.VElements.gep_gunf.pos
	reloadpos.x = math.Clamp(reloadpos.x + reloaddelta, 8.5, 23)

	-- 调用基类绘制
	self.BaseClass.PostDrawViewModel(self, vm)
end

-- ==== SecondaryAttack - 客户端副攻击占位（服务器端实现引爆） ====
function SWEP:SecondaryAttack()
end
