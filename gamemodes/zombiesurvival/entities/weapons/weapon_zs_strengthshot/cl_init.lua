-- ============================================================================
-- weapon_zs_strengthshot/cl_init.lua - 力量射击（客户端逻辑）
-- 负责：武器栏位、拼接模型与智能追踪目标的 HUD 显示
-- ============================================================================
INC_CLIENT()

-- 定义母本引用（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_baseproj")
-- 武器选择栏位（医疗工具类）与视图模型设置
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotMedicalTools")
SWEP.SlotGroup = WEPSELECT_MEDICAL_TOOL
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60

-- HUD 3D 预览：骨骼、位置与缩放
SWEP.HUD3DBone = "ValveBiped.square"
SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
SWEP.HUD3DScale = 0.015

-- 第三人称拼接模型元素（红色药瓶 + 双炮管）
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.5, 2, -3.701), angle = Angle(0, -90, -8), size = Vector(0.5, 0.5, 0.5), color = Color(255, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2+"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
-- 第一人称拼接模型元素
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.square", rel = "", pos = Vector(0, 0.5, 3), angle = Angle(0, 0, 90), size = Vector(0.5, 0.5, 0.5), color = Color(255, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2+"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- ==== Draw2DHUD - 绘制 2D HUD：智能追踪激活时显示目标玩家名 ====
function SWEP:Draw2DHUD()
	BaseClass.Draw2DHUD(self)

	local owner = self:GetOwner()
	-- 未激活智能追踪技能时不显示
	if not owner:IsSkillActive(SKILL_SMARTTARGETING) then return end

	local player = self:GetSeekedPlayer()
	local screenscale = BetterScreenScale()
	surface.SetFont("ZSHUDFont")
	local text = player:IsValidLivingHuman() and player:Name() or "No Target"
	local _, nTEXH = surface.GetTextSize(text)

	-- 屏幕右下角显示目标名（有目标绿色，无目标红色）
	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - 218 * screenscale, ScrH() - nTEXH * 3.5, text ~= "No Target" and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)
end

-- ==== Draw3DHUD - 绘制 3D HUD：在武器模型上方显示目标名 ====
function SWEP:Draw3DHUD(vm, pos, ang)
	BaseClass.Draw3DHUD(self, vm, pos, ang)

	local owner = self:GetOwner()
	if not owner:IsSkillActive(SKILL_SMARTTARGETING) then return end

	local wid, hei = 180, 200
	local x, y = wid * 0, hei * -1

	local player = self:GetSeekedPlayer()
	surface.SetFont("ZS3D2DFontSmall")
	local text = player:IsValidLivingHuman() and player:Name() or "No Target"

	-- 以 3D2D 方式在武器上方绘制目标名
	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		draw.SimpleTextBlurry(text, "ZS3D2DFontSmall", x, y, text ~= "No Target" and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
