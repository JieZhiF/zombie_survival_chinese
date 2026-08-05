-- ============================================================================
-- weapon_zs_healingray/cl_init.lua - 治疗射线武器（客户端部分）
-- 负责：栏位与模型设置、用零件拼装治疗枪外观（VElements/WElements），
--       以及绘制屏幕上与武器上的剩余能量 HUD
-- ============================================================================
INC_CLIENT() -- 客户端专用文件标记

-- 武器栏位：放入"特种武器"分类（Bolt 栏）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotBolt")
-- 栏位组：特种武器栏
SWEP.SlotGroup = WEPSELECT_BOLT
-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

SWEP.ViewModelFlip = false -- 不翻转第一人称模型
SWEP.ViewModelFOV = 57 -- 第一人称视野大小

-- HUD 3D 武器展示图：绑定骨骼与位置/角度/缩放
SWEP.HUD3DBone = "Base"
SWEP.HUD3DPos = Vector(4, -1, -10)
SWEP.HUD3DAng = Angle(180, 0, 0)
SWEP.HUD3DScale = 0.03

-- 第一人称手持元素：用多个零件模型拼装出治疗枪外形（主机身、线圈、管线等）
SWEP.VElements = {
	["egon_base+++++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "Base", rel = "egon_base", pos = Vector(1, 3, 4), angle = Angle(140, -90, 0), size = Vector(0.017, 0.017, 0.129), color = Color(196, 234, 244, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
	["egon_base++++++"] = { type = "Model", model = "models/props_phx/misc/iron_beam2.mdl", bone = "Base", rel = "egon_base", pos = Vector(1.5, -4, -2), angle = Angle(-17.532, 90, 0), size = Vector(0.119, 0.119, 0.119), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_stunstick/v_stunstick_diffuse", skin = 0, bodygroup = {} },
	["egon_base+"] = { type = "Model", model = "models/props_phx/construct/metal_wire_angle360x2.mdl", bone = "Base", rel = "egon_base", pos = Vector(10, 0.2, 0), angle = Angle(90, 0, 0), size = Vector(0.07, 0.07, 0.17), color = Color(89, 100, 99, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["egon_base++++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "Base", rel = "egon_base", pos = Vector(1, 3, 4), angle = Angle(140, -90, 0), size = Vector(0.018, 0.018, 0.1), color = Color(9, 115, 0, 255), surpresslightning = false, material = "phoenix_storms/camera", skin = 1, bodygroup = {} },
	["egon_base+++"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "Base", rel = "egon_base", pos = Vector(7, 0, -3.1), angle = Angle(180, 90, 0), size = Vector(0.039, 0.079, 0.054), color = Color(142, 142, 142, 255), surpresslightning = false, material = "phoenix_storms/future_vents", skin = 0, bodygroup = {} },
	["egon_base+++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "Base", rel = "egon_base", pos = Vector(1, 3, 4), angle = Angle(140, -90, 0), size = Vector(0.025, 0.025, 0.059), color = Color(188, 196, 213, 255), surpresslightning = false, material = "phoenix_storms/metal_plate", skin = 0, bodygroup = {} },
	["egon_base+++++"] = { type = "Model", model = "models/props_phx/construct/metal_plate_curve360.mdl", bone = "Base", rel = "egon_base", pos = Vector(-6.909, 0.2, 0), angle = Angle(90, 0, 0), size = Vector(0.07, 0.07, 0.2), color = Color(145, 152, 173, 255), surpresslightning = false, material = "phoenix_storms/cube", skin = 0, bodygroup = {} },
	["egon_base"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "Base", rel = "", pos = Vector(0.699, 1, -7.792), angle = Angle(90, -90, 0), size = Vector(0.2, 0.1, 0.1), color = Color(87, 95, 110, 255), surpresslightning = false, material = "phoenix_storms/indenttiles_1-2", skin = 0, bodygroup = {} },
	["egon_base++"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "Base", rel = "egon_base", pos = Vector(7, 0, 2), angle = Angle(0, 90, 0), size = Vector(0.039, 0.079, 0.05), color = Color(142, 142, 142, 255), surpresslightning = false, material = "phoenix_storms/future_vents", skin = 0, bodygroup = {} }
}

-- 第三人称世界元素：同样的零件拼装，绑在玩家右手骨骼上
SWEP.WElements = {
	["egon_base+++++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(1, 3, 4), angle = Angle(140, -90, 0), size = Vector(0.017, 0.017, 0.129), color = Color(196, 234, 244, 255), surpresslightning = false, material = "phoenix_storms/metalset_1-2", skin = 0, bodygroup = {} },
	["egon_base++++++"] = { type = "Model", model = "models/props_phx/misc/iron_beam2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(1.5, -4, -2), angle = Angle(-17.532, 90, 0), size = Vector(0.119, 0.119, 0.119), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_stunstick/v_stunstick_diffuse", skin = 0, bodygroup = {} },
	["egon_base+"] = { type = "Model", model = "models/props_phx/construct/metal_wire_angle360x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(10, 0.2, 0), angle = Angle(90, 0, 0), size = Vector(0.07, 0.07, 0.17), color = Color(89, 100, 99, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["egon_base++++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(1, 3, 4), angle = Angle(140, -90, 0), size = Vector(0.018, 0.018, 0.1), color = Color(9, 115, 0, 255), surpresslightning = false, material = "phoenix_storms/camera", skin = 1, bodygroup = {} },
	["egon_base+++"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(7, 0, -3.1), angle = Angle(180, 90, 0), size = Vector(0.039, 0.079, 0.054), color = Color(142, 142, 142, 255), surpresslightning = false, material = "phoenix_storms/future_vents", skin = 0, bodygroup = {} },
	["egon_base"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(9, 2, -5.6), angle = Angle(0, 0, -160), size = Vector(0.2, 0.1, 0.1), color = Color(87, 95, 110, 255), surpresslightning = false, material = "phoenix_storms/indenttiles_1-2", skin = 0, bodygroup = {} },
	["egon_base+++++"] = { type = "Model", model = "models/props_phx/construct/metal_plate_curve360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(-6.909, 0.2, 0), angle = Angle(90, 0, 0), size = Vector(0.07, 0.07, 0.2), color = Color(145, 152, 173, 255), surpresslightning = false, material = "phoenix_storms/cube", skin = 0, bodygroup = {} },
	["egon_base+++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(1, 3, 4), angle = Angle(140, -90, 0), size = Vector(0.025, 0.025, 0.059), color = Color(188, 196, 213, 255), surpresslightning = false, material = "phoenix_storms/metal_plate", skin = 0, bodygroup = {} },
	["egon_base++"] = { type = "Model", model = "models/props_c17/factorymachine01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "egon_base", pos = Vector(7, 0, 2), angle = Angle(0, 90, 0), size = Vector(0.039, 0.079, 0.05), color = Color(142, 142, 142, 255), surpresslightning = false, material = "phoenix_storms/future_vents", skin = 0, bodygroup = {} }
}

-- 第一人称骨骼变形：隐藏物理枪手臂并缩放主机身骨骼
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, -3), angle = Angle(0, 0, 0) },
	["Base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 3), angle = Angle(0, 0, 0) }
}

local colBG = Color(16, 16, 16, 90) -- 能量条背景色（半透明黑）
local colRed = Color(220, 0, 0, 230) -- 能量耗尽警告色（红）
local colWhite = Color(220, 220, 220, 230) -- 正常能量文字色（白）

-- ==== Draw2DHUD - 绘制屏幕角落的剩余能量 HUD ====
function SWEP:Draw2DHUD()
	local screenscale = BetterScreenScale() -- 屏幕缩放比例

	-- 面板尺寸与位置：屏幕右下角
	local wid, hei = 180 * screenscale, 64 * screenscale
	local x, y = ScrW() - wid - screenscale * 128, ScrH() - hei - screenscale * 72
	local spare = self:GetPrimaryAmmoCount() -- 剩余能量

	draw.RoundedBox(16, x, y, wid, hei, colBG) -- 绘制圆角背景
	-- 绘制能量数字（>=1000 用小字体，否则用大字体；为 0 时显示红色）
	draw.SimpleTextBlurry(spare, spare >= 1000 and "ZSHUDFont" or "ZSHUDFontBig", x + wid * 0.5, y + hei * 0.5, spare == 0 and colRed or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- ==== Draw3DHUD - 在武器模型上绘制 3D 能量 HUD ====
function SWEP:Draw3DHUD(vm, pos, ang)
	local wid, hei = 180, 64
	local x, y = wid * -0.6, hei * -0.5
	local spare = self:GetPrimaryAmmoCount() -- 剩余能量

	-- 在武器表面以 3D2D 方式绘制能量面板
	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		draw.RoundedBoxEx(32, x, y, wid, hei, colBG, true, false, true, false)
		draw.SimpleTextBlurry(spare, spare >= 1000 and "ZS3D2DFontSmall" or "ZS3D2DFont", x + wid * 0.5, y + hei * 0.5, spare == 0 and colRed or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
