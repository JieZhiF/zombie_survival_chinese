-- ============================================================================
-- weapon_zs_bulwark/cl_init.lua - 堡垒机炮（客户端入口）
-- 负责：客户端栏位设置、拼装机炮外观、弹药 HUD（2D/3D）、枪管旋转动画
--       以及机瞄/预转时的视角模型偏移
-- ============================================================================

INC_CLIENT()


-- 武器栏位：突击步枪栏
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
SWEP.SlotPos = 0

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 65

-- HUD 3D 预览图标：挂在根骨骼上
SWEP.HUD3DBone = "Base"
SWEP.HUD3DPos = Vector(3, -0.5, -13)
SWEP.HUD3DAng = Angle(180, 0, 0)
SWEP.HUD3DScale = 0.03

-- 第一人称附加模型：由轮子（多管枪管）、圆盘、手柄、弹箱等零件拼装成机炮
SWEP.VElements = {
	["barrel1+"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-14.094, 0, -2.274), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["handleexternalattachment"] = { type = "Model", model = "models/xqm/coastertrack/track_guide.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "handle", pos = Vector(0.34, 0, -0.64), angle = Angle(0, 0, 0), size = Vector(0.123, 0.108, 0.193), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1+++++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-14.094, -2.057, 0.998), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_wasteland/panel_leverhandle001a.mdl", bone = "Base", rel = "", pos = Vector(2.502, 1.71, 0.43), angle = Angle(-90, 90.875, 0), size = Vector(0.5, 1.041, 0.903), color = Color(95, 95, 95, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["triangle++++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-22.296, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.949, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["triangle+++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-20.307, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.949, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-14.094, 2.056, 0.998), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["triangle+++++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-24.285, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.949, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["circle1+"] = { type = "Model", model = "models/props_citizen_tech/steamengine001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "handle", pos = Vector(9.253, -1.787, -0.245), angle = Angle(0, 180, 0), size = Vector(0.052, 0.1, 0.1), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-14.094, 0, 2.216), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["ammobox"] = { type = "Model", model = "models/Items/ammocrate_smg1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "handle", pos = Vector(9.486, -0.033, -6.211), angle = Angle(0, 90, 0), size = Vector(0.18, 0.174, 0.224), color = Color(122, 125, 166, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["triangle++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-11.82, 0, 0), angle = Angle(180, 180, 0), size = Vector(2.15, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["circle1"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "handle", pos = Vector(0.708, 0, 0), angle = Angle(0, 0, 0), size = Vector(2.135, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1+++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-14.094, 2.056, -1.323), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1++++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "circle1", pos = Vector(-14.094, -2.057, -1.323), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["secondhandle"] = { type = "Model", model = "models/props_c17/TrapPropeller_Lever.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "handle", pos = Vector(13.623, 0, 3.605), angle = Angle(0, 90, 90), size = Vector(0.842, 0.598, 1.07), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} }
}

-- 第三人称附加模型：同样的机炮拼装外观，供他人视角显示
SWEP.WElements = {
	["barrel1+"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-14.094, 0, 2.216), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["handleexternalattachment"] = { type = "Model", model = "models/xqm/coastertrack/track_guide.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "handle", pos = Vector(0.34, 0, -0.64), angle = Angle(0, 0, 0), size = Vector(0.123, 0.108, 0.193), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["triangle+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-11.82, 0, 0), angle = Angle(180, 180, 0), size = Vector(2.15, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_wasteland/panel_leverhandle001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16.549, 0.56, 4.052), angle = Angle(177.938, 3.655, 0), size = Vector(0.5, 1.041, 0.903), color = Color(95, 95, 95, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel1++++++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-14.094, -2.057, 0.998), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["triangle+++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-22.296, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.949, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["secondhandle"] = { type = "Model", model = "models/props_c17/TrapPropeller_Lever.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "handle", pos = Vector(13.623, 0, 3.605), angle = Angle(0, 90, 90), size = Vector(0.842, 0.598, 1.07), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-14.094, 0, -2.274), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["circle1+"] = { type = "Model", model = "models/props_citizen_tech/steamengine001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "handle", pos = Vector(9.253, -1.787, -0.245), angle = Angle(0, 180, 0), size = Vector(0.052, 0.1, 0.1), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["circle1"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "handle", pos = Vector(0.708, 0, 0), angle = Angle(0, 0, 0), size = Vector(2.135, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["ammobox"] = { type = "Model", model = "models/Items/ammocrate_smg1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "handle", pos = Vector(9.486, -0.002, -6.052), angle = Angle(0, 90, 0), size = Vector(0.187, 0.174, 0.224), color = Color(122, 125, 166, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["triangle++++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-24.285, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.949, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["triangle++"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-20.307, 0, 0), angle = Angle(180, 180, 0), size = Vector(0.949, 0.143, 0.143), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1+++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-14.094, 2.056, 0.998), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1++++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-14.094, 2.056, -1.323), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["barrel1+++++"] = { type = "Model", model = "models/mechanics/wheels/wheel_rugged_24.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "circle1", pos = Vector(-14.094, -2.057, -1.323), angle = Angle(90, 0, 0), size = Vector(0.054, 0.054, 3.535), color = Color(100, 100, 100, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} }
}

-- 视角模型骨骼调整：左手位置与根骨骼位移
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(1, 0, 9), angle = Angle(0, 0, 0) },
	["Base"] = { scale = Vector(1, 1, 1), pos = Vector(-12.412, -2.212, -0.42), angle = Angle(0, 0, 0) }
}

-- 枪管旋转角速度缓存（用于平滑旋转）
SWEP.LastVel = 0

-- 机瞄时的准星偏移与旋转
SWEP.IronSightsPos = Vector(1.24, 0, 2.359)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- ==== Think - 客户端每帧逻辑（检查预转状态） ====
function SWEP:Think()
	self:CheckSpool()
end

-- HUD 绘制颜色：背景半透明黑、弹药耗尽红、正常白
local colBG = Color(16, 16, 16, 90)
local colRed = Color(220, 0, 0, 230)
local colWhite = Color(220, 220, 220, 230)

-- ==== Draw2DHUD - 绘制 2D 弹药 HUD 并旋转枪管模型 ====
function SWEP:Draw2DHUD()
	local screenscale = BetterScreenScale()

	-- 屏幕右下角绘制弹药面板（数字随弹药量切换字体大小）
	local wid, hei = 180 * screenscale, 64 * screenscale
	local x, y = ScrW() - wid - screenscale * 128, ScrH() - hei - screenscale * 72
	local spare = self:GetPrimaryAmmoCount()

	draw.RoundedBox(16, x, y, wid, hei, colBG)
	draw.SimpleTextBlurry(spare, spare >= 1000 and "ZSHUDFont" or "ZSHUDFontBig", x + wid * 0.5, y + hei * 0.5, spare == 0 and colRed or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	-- 枪管组（circle1）按蓄能等级旋转：蓄能越高转得越快，旋转速度平滑过渡
	local rotators = self.VElements["circle1"].angle
	local vel = Lerp(0.01, self.LastVel, self:GetSpool() * FrameTime() * 2000)
	rotators.r = rotators.r + vel

	self.LastVel = vel
end

-- ==== Draw3DHUD - 绘制 3D 弹药 HUD（跟随视角模型） ====
function SWEP:Draw3DHUD(vm, pos, ang)
	local wid, hei = 180, 64
	local x, y = wid * -0.6, hei * -0.5
	local spare = self:GetPrimaryAmmoCount()

	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		-- 只圆化上下两角的面板 + 弹药数字
		draw.RoundedBoxEx(32, x, y, wid, hei, colBG, true, false, true, false)
		draw.SimpleTextBlurry(spare, spare >= 1000 and "ZS3D2DFontSmall" or "ZS3D2DFont", x + wid * 0.5, y + hei * 0.5, spare == 0 and colRed or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

-- 视角模型机瞄/预转切换的插值
local ghostlerp = 0
-- ==== CalcViewModelView - 计算视角模型位置姿态 ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 应用机瞄偏移与旋转
	local Offset = self.IronSightsPos
	if self.IronSightsAng then
		ang = Angle(ang.p, ang.y, ang.r)
		ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x)
		ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z)
	end

	pos = pos + Offset.x * ang:Right() + Offset.y * ang:Forward() + Offset.z * ang:Up()

	-- 未预转时视角模型下垂（机炮坠感），预转开始后快速抬起
	if not self:GetSpooling() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 1)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 1.5)
	end

	if ghostlerp > 0 then
		pos = pos - 35.5 * ghostlerp * ang:Up()
		ang:RotateAroundAxis(ang:Right(), 70 * ghostlerp)
	end

	return pos, ang
end
