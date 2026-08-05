-- ============================================================================
-- weapon_zs_eminence/cl_init.lua - 能量弩「至圣」（Eminence）客户端
-- 负责：3D HUD 展示、SCK 枪体外观模型、充能时模型倾斜与发光效果
-- ============================================================================

INC_CLIENT()

-- 3D HUD 中展示武器模型的绑定骨骼与位置/角度/缩放
SWEP.HUD3DBone = "v_weapon.ump45_Release"
SWEP.HUD3DPos = Vector(-1.6, -4.4, 2)
SWEP.HUD3DAng = Angle(0, 0, 0)
SWEP.HUD3DScale = 0.02

-- 隐藏官方模型，改用 SCK 自定义外观；FOV 65、不翻转
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false

-- 武器栏槽位 4（特殊武器）与槽位序号 0
SWEP.Slot = 4
SWEP.SlotPos = 0

-- SCK 元素（第一人称）：由多个零件拼装的未来感枪体
SWEP.VElements = {
	["whity++"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.26, 0.26, 0.26), color = Color(255, 255, 255, 26), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["whity+++++"] = { type = "Model", model = "models/props_wasteland/coolingtank01.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, -2.597, 4.699), angle = Angle(8, 90, 180), size = Vector(0.014, 0.019, 0.041), color = Color(105, 128, 135, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity+++++++"] = { type = "Model", model = "models/props_wasteland/prison_flourescentlight002b.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(2.2, 0, 8), angle = Angle(0, 0, 90), size = Vector(0.3, 0.3, 0.3), color = Color(180, 193, 195, 255), surpresslightning = false, material = "models/props_combine/breenwindows_sheet", skin = 0, bodygroup = {} },
	["whity++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, 3, 8), angle = Angle(0, 0, 180), size = Vector(0.039, 0.039, 0.237), color = Color(249, 223, 204, 255), surpresslightning = false, material = "models/props_combine/combine_monitorbay_sheet", skin = 0, bodygroup = {} },
	["whity2"] = { type = "Sprite", sprite = "sprites/glow04", bone = "ValveBiped.Bip01_Spine4", rel = "whity", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(255, 255, 255, 49), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
	["whity"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Crossbow_base", rel = "", pos = Vector(-0.5, -2.3, -3.636), angle = Angle(0, 0, 0), size = Vector(0.23, 0.23, 0.23), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["whity++++"] = { type = "Model", model = "models/props_wasteland/coolingtank01.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, 2.5, 4.675), angle = Angle(-8.183, 90, 180), size = Vector(0.014, 0.019, 0.041), color = Color(105, 128, 135, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity++++++"] = { type = "Model", model = "models/props_wasteland/prison_flourescentlight002b.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(-2.201, 0, 8), angle = Angle(0, 180, 90), size = Vector(0.3, 0.3, 0.3), color = Color(180, 193, 195, 255), surpresslightning = false, material = "models/props_combine/breenwindows_sheet", skin = 0, bodygroup = {} },
	["whity+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, 1.899, 0), angle = Angle(0, 90, 0), size = Vector(1.7, 0.019, 0.019), color = Color(70, 74, 79, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity+++++++++"] = { type = "Model", model = "models/props_c17/handrail04_short.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, 0, 1.557), angle = Angle(-90, 90, 0), size = Vector(0.3, 0.15, 0.15), color = Color(181, 193, 204, 255), surpresslightning = false, material = "models/props_combine/combine_gate_vehicle01a", skin = 0, bodygroup = {} },
	["whity+++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Crossbow_base", rel = "whity", pos = Vector(0, -3.3, 0), angle = Angle(0, 90, 0), size = Vector(2.5, 0.019, 0.019), color = Color(74, 79, 79, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} }
}

-- SCK 元素（第三人称）：与第一人称一致的枪体拼装外观
SWEP.WElements = {
	["whity++"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.26, 0.26, 0.26), color = Color(255, 255, 255, 36), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["whity+++++"] = { type = "Model", model = "models/props_wasteland/coolingtank01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, -2.597, 4.699), angle = Angle(8, 90, 180), size = Vector(0.014, 0.019, 0.041), color = Color(105, 128, 135, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity+++++++"] = { type = "Model", model = "models/props_wasteland/prison_flourescentlight002b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(2.2, 0, 8), angle = Angle(0, 0, 90), size = Vector(0.3, 0.3, 0.3), color = Color(180, 193, 195, 255), surpresslightning = false, material = "models/props_combine/breenwindows_sheet", skin = 0, bodygroup = {} },
	["whity++++++++"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, 3, 8), angle = Angle(0, 0, 180), size = Vector(0.039, 0.039, 0.237), color = Color(249, 223, 204, 255), surpresslightning = false, material = "models/props_combine/combine_monitorbay_sheet", skin = 0, bodygroup = {} },
	["whity2"] = { type = "Sprite", sprite = "sprites/glow04", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(255, 255, 255, 49), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
	["whity"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 0, -1.558), angle = Angle(0, -90, -104.027), size = Vector(0.23, 0.23, 0.23), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["whity++++"] = { type = "Model", model = "models/props_wasteland/coolingtank01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, 2.5, 4.675), angle = Angle(-8.183, 90, 180), size = Vector(0.014, 0.019, 0.041), color = Color(105, 128, 135, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity++++++"] = { type = "Model", model = "models/props_wasteland/prison_flourescentlight002b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(-2.201, 0, 8), angle = Angle(0, 180, 90), size = Vector(0.3, 0.3, 0.3), color = Color(180, 193, 195, 255), surpresslightning = false, material = "models/props_combine/breenwindows_sheet", skin = 0, bodygroup = {} },
	["whity+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, 1.899, 0), angle = Angle(0, 90, 0), size = Vector(1.7, 0.019, 0.019), color = Color(70, 74, 79, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity+++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, -3.3, 0), angle = Angle(0, 90, 0), size = Vector(2.5, 0.019, 0.019), color = Color(74, 79, 79, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["whity+++++++++"] = { type = "Model", model = "models/props_c17/handrail04_short.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "whity", pos = Vector(0, 0, 1.557), angle = Angle(-90, 90, 0), size = Vector(0.3, 0.15, 0.15), color = Color(181, 193, 204, 255), surpresslightning = false, material = "models/props_combine/combine_gate_vehicle01a", skin = 0, bodygroup = {} }
}

-- 幽灵（充能/建造）姿态过渡的插值系数
local ghostlerp = 0
-- ==== CalcViewModelView - 计算第一人称视角：建造幽灵或换弹收尾时枪体倾斜 ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 处于建造幽灵状态或换弹收尾时，倾斜系数快速上升（速度 1），否则缓慢回落（速度 1.5）
	if self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 1)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 1.5)
	end

	-- 按倾斜系数绕右轴旋转视角（最多 -35 度）
	if ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -35 * ghostlerp)
	end

	return pos, ang
end

-- ==== PostDrawViewModel - 绘制第一人称模型后：HUD 与充能发光状态 ====
function SWEP:PostDrawViewModel(vm, pl, wep)
	-- 需要时绘制 3D 武器 HUD
	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end

	-- 控制枪体核心发光球（whity/whity2）的颜色：默认完全透明
	local veles = self.VElements
	local col1, col2, col3 = Color(0, 0, 0, 0), Color(255, 255, 255, 255), Color(255, 255, 255, 50)
	veles["whity"].color = col1
	veles["whity2"].color = col1

	-- 弹匣有弹且冷却结束（可开火）时，发光球变为充能高亮
	if self:Clip1() < 1 or self:GetNextPrimaryFire() > CurTime() then return end

	veles["whity"].color = col2
	veles["whity2"].color = col3
end
