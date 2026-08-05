-- ============================================================================
-- cl_init.lua - 医疗步枪武器客户端脚本
-- 负责：设置武器栏位（医疗工具槽）与机瞄参数；SCK 自定义医疗步枪外观
--       （蓝色科技部件拼装）；实现瞄准镜 HUD 与"智能锁定"目标名称显示
-- ============================================================================
INC_CLIENT()

-- 定义父类引用（投掷/投射物武器基类）
DEFINE_BASECLASS("weapon_zs_baseproj")
-- 武器栏位（医疗工具槽）与选择组
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotMedicalTools")
SWEP.SlotGroup = WEPSELECT_MEDICAL_TOOL
-- 模型方向与镜头视野
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55
-- 显示默认模型（SCK 部件叠加在默认模型上）
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
-- 狙击枪标记：启用机瞄
SWEP.SniperRifle = true
-- 机瞄时鼠标灵敏度倍率
SWEP.IronsightsMultiplier = 0.25
-- HUD 3D 预览的骨骼/位置/角度/缩放
SWEP.HUD3DBone = "v_weapon.scout_Parent"
SWEP.HUD3DPos = Vector(-1.25, -2.75, -6)
SWEP.HUD3DAng = Angle(0, 0, 0)
SWEP.HUD3DScale = 0.017

-- 机瞄时视图模型位置与角度偏移
SWEP.IronSightsPos = Vector(5.015, -8, 2.52)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- 第一人称视图模型的 SCK 自定义部件（蓝色科技风格医疗步枪拼装）
SWEP.VElements = {
	-- 部件 body2：弹匣部位（蓝色药剂瓶）
	["body2"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-2.431, 0, 7.743), angle = Angle(-180, 90, 0), size = Vector(0.541, 0.736, 1.307), color = Color(85, 120, 195, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 barrel：枪管（细圆柱）
	["barrel"] = { type = "Model", model = "models/XQM/cylinderx1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-1.833, 0, 11.97), angle = Angle(90, 0, 0), size = Vector(0.717, 0.061, 0.061), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body3：枪身下部连接件
	["body3"] = { type = "Model", model = "models/props_trainstation/train001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-2.57, 0, -5.768), angle = Angle(0, 90, 90), size = Vector(0.009, 0.016, 0.012), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 scope：瞄准镜主体
	["scope"] = { type = "Model", model = "models/props_combine/breenlight.mdl", bone = "v_weapon.scout_Parent", rel = "", pos = Vector(0, -5.212, -11.976), angle = Angle(0, 90, 180), size = Vector(0.368, 0.616, 0.603), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body4：枪机部件
	["body4"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-5.567, 0, -7.106), angle = Angle(-90, 0, 0), size = Vector(0.009, 0.014, 0.01), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body：枪托（墓碑模型）
	["body"] = { type = "Model", model = "models/props_c17/gravestone003a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-2.309, 0, 0.996), angle = Angle(-90, 0, 0), size = Vector(3.167, 0.043, 0.061), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body5：扳机护圈部件
	["body5"] = { type = "Model", model = "models/props_combine/breenconsole.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-3.738, 0, 5.004), angle = Angle(0, -90, -90), size = Vector(0.096, 0.284, 0.081), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 stuff：枪身上的指示灯
	["stuff"] = { type = "Model", model = "models/props_c17/FurnitureDrawer001a_Chunk05.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0.041, 0, -5.003), angle = Angle(90, 0, 0), size = Vector(0.05, 0.035, 0.05), color = Color(255, 255, 195, 255), surpresslightning = false, material = "models/props_combine/masterinterface_alert", skin = 0, bodygroup = {} }
}

-- 第三人称世界模型的 SCK 自定义部件（他人视角的医疗步枪）
SWEP.WElements = {
	-- 部件 body2：弹匣部位（世界模型）
	["body2"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-2.922, 0, 15.505), angle = Angle(-180, 90, 0), size = Vector(0.582, 0.805, 1.307), color = Color(85, 120, 195, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 body3：枪身下部连接件（世界模型）
	["body3"] = { type = "Model", model = "models/props_trainstation/train001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-2.491, 0, -2.517), angle = Angle(0, 90, 90), size = Vector(0.009, 0.016, 0.012), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 barrel：枪管（世界模型）
	["barrel"] = { type = "Model", model = "models/XQM/cylinderx1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-2.411, 0, 16.427), angle = Angle(90, 0, 0), size = Vector(0.99, 0.061, 0.061), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 scope：瞄准镜主体（世界模型）
	["scope"] = { type = "Model", model = "models/props_combine/breenlight.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11.253, 0.721, -7.623), angle = Angle(-100, 0, 0), size = Vector(0.433, 0.616, 0.755), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body4：枪机部件（世界模型）
	["body4"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-6.316, 0, -2.192), angle = Angle(-90, 0, 0), size = Vector(0.014, 0.014, 0.014), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body：枪托（世界模型）
	["body"] = { type = "Model", model = "models/props_c17/gravestone003a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-2.75, 0, 8.814), angle = Angle(-90, 0, 0), size = Vector(3.167, 0.043, 0.065), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 body5：扳机护圈部件（世界模型）
	["body5"] = { type = "Model", model = "models/props_combine/breenconsole.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-3.738, 0, 12.616), angle = Angle(0, -90, -90), size = Vector(0.096, 0.419, 0.093), color = Color(85, 120, 195, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	-- 部件 stuff：枪身上的指示灯（世界模型）
	["stuff"] = { type = "Model", model = "models/props_c17/FurnitureDrawer001a_Chunk05.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0.046, 0, -6.447), angle = Angle(90, 0, 0), size = Vector(0.05, 0.035, 0.061), color = Color(255, 255, 195, 255), surpresslightning = false, material = "models/props_combine/masterinterface_alert", skin = 0, bodygroup = {} }
}

-- ==== IsScoped - 是否处于瞄准镜状态 ====
-- 机瞄开启且持续超过 0.25 秒后判定为已进入瞄准镜
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- ==== GetViewModelPosition - 瞄准镜状态下的视图模型定位 ====
-- 禁用瞄准镜时或瞄准中返回 nil（保持当前镜头），否则走父类默认偏移
function SWEP:GetViewModelPosition(pos, ang)
	if GAMEMODE.DisableScopes then return end

	if self:IsScoped() then return end

	return BaseClass.GetViewModelPosition(self, pos, ang)
end

-- ==== DrawHUDBackground - 绘制瞄准镜背景 ====
-- 进入瞄准镜状态且未禁用瞄准镜时绘制未来风格瞄准镜（遮罩屏幕）
function SWEP:DrawHUDBackground()
	if GAMEMODE.DisableScopes then return end

	if self:IsScoped() then
		self:DrawFuturisticScope()
	end
end

-- ==== Draw2DHUD - 绘制 2D HUD（智能锁定目标名） ====
-- 激活"智能锁定"技能时，在屏幕右侧显示当前锁定目标的名字
function SWEP:Draw2DHUD()
	BaseClass.Draw2DHUD(self)

	local owner = self:GetOwner()
	if not owner:IsSkillActive(SKILL_SMARTTARGETING) then return end

	local player = self:GetSeekedPlayer()
	local screenscale = BetterScreenScale()
	surface.SetFont("ZSHUDFont")
	local text = player:IsValidLivingHuman() and player:Name() or "No Target"
	local _, nTEXH = surface.GetTextSize(text)

	-- 有目标时显示绿色名字，无目标时显示红色"No Target"
	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - 218 * screenscale, ScrH() - nTEXH * 3.5, text ~= "No Target" and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)
end

-- ==== Draw3DHUD - 在瞄准镜中绘制锁定目标名 ====
-- 激活"智能锁定"技能时，把目标名字以 3D2D 文本绘制在镜头 HUD 位置
function SWEP:Draw3DHUD(vm, pos, ang)
	BaseClass.Draw3DHUD(self, vm, pos, ang)

	local owner = self:GetOwner()
	if not owner:IsSkillActive(SKILL_SMARTTARGETING) then return end

	local wid, hei = 180, 200
	local x, y = wid * 1.25, hei * -2.25

	local player = self:GetSeekedPlayer()
	surface.SetFont("ZS3D2DFontSmall")
	local text = player:IsValidLivingHuman() and player:Name() or "No Target"

	cam.Start3D2D(pos, ang, self.HUD3DScale / 3)
		draw.SimpleTextBlurry(text, "ZS3D2DFontSmall", x, y, text ~= "No Target" and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
