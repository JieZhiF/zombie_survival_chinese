-- ============================================================================
-- weapon_zs_ripper/cl_init.lua - 撕裂者（客户端逻辑）
-- 负责：HUD 3D 预览、拼接模型、锯盘旋转动画与幽灵建造视角摆动
-- ============================================================================
INC_CLIENT()

-- HUD 3D 预览：绑定骨骼、位置、角度与缩放
SWEP.HUD3DBone = "v_weapon.Glock_Parent"
SWEP.HUD3DPos = Vector(3.338, -3.442, 1.976)
SWEP.HUD3DAng = Angle(270, 0, 0)
SWEP.HUD3DScale = 0.015

-- 第一人称视野大小与模型翻转
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false

-- 隐藏原模型，改用拼接模型元素
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 武器选择栏位（弩箭类）与栏内位置
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotBolt")
SWEP.SlotGroup = WEPSELECT_BOLT
SWEP.SlotPos = 0

-- 第一人称拼接模型元素（用道具模型组合出锯盘发射器外形）
SWEP.VElements = {
	["METALSPIKES"] = { type = "Model", model = "models/Mechanics/gears2/pinion_20t1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "METALFRONT", pos = Vector(-0.83, 0, 0), angle = Angle(0, -90, 0), size = Vector(0.201, 0.328, 0.166), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["projectilepart2"] = { type = "Model", model = "models/items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "projectile", pos = Vector(0, 0, -0.579), angle = Angle(0, 0, 0), size = Vector(0.92, 0.92, 0.09), color = Color(130, 125, 120, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "METALback", pos = Vector(1.743, 0, 1.736), angle = Angle(0, 0, 0), size = Vector(0.134, 0.134, 0.085), color = Color(100, 90, 120, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["METALFRONT"] = { type = "Model", model = "models/props_c17/light_decklight01_on.mdl", bone = "v_weapon.Glock_Parent", rel = "", pos = Vector(-1.338, -4.442, 0.976), angle = Angle(-11.62, -107.073, -5), size = Vector(0.236, 0.621, 0.105), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["METALback"] = { type = "Model", model = "models/props_combine/combine_interface003.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "METALFRONT+", pos = Vector(-6.52, -10.306, 0), angle = Angle(0, 90, 90), size = Vector(0.167, 0.043, 0.15), color = Color(125, 120, 130, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["projectile"] = { type = "Model", model = "models/props_junk/sawblade001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "METALFRONT", pos = Vector(2.355, -1.673, 0), angle = Angle(0, 90, 90), size = Vector(0.224, 0.224, 0.564), color = Color(130, 125, 120, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["METALTOP"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "METALFRONT", pos = Vector(2.826, -7.87, 0), angle = Angle(0, 64.527, 90), size = Vector(0.63, 0.598, 0.63), color = Color(125, 120, 130, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["METALGASCAN"] = { type = "Model", model = "models/props_c17/canister_propane01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "METALFRONT+", pos = Vector(1.205, -5.669, 0), angle = Angle(90, 0, 0), size = Vector(0.104, 0.105, 0.089), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["METALFRONT+"] = { type = "Model", model = "models/props_c17/light_decklight01_on.mdl", bone = "v_weapon.Glock_Parent", rel = "METALFRONT", pos = Vector(3.799, 1.751, 0), angle = Angle(180, 0, 0), size = Vector(0.236, 0.621, 0.105), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} }
}

-- 第三人称拼接模型元素（绑定右手骨骼）
SWEP.WElements = {
	["METALSPIKES"] = { type = "Model", model = "models/Mechanics/gears2/pinion_20t1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALFRONT", pos = Vector(-0.83, 0, 0), angle = Angle(0, -90, 0), size = Vector(0.347, 0.328, 0.166), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["projectilepart2"] = { type = "Model", model = "models/items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "projectile", pos = Vector(0, 0, -0.579), angle = Angle(0, 0, 0), size = Vector(0.92, 0.92, 0.09), color = Color(130, 125, 120, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALback", pos = Vector(2.243, 0, 1.736), angle = Angle(0, 0, 0), size = Vector(0.134, 0.134, 0.085), color = Color(100, 90, 120, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["METALFRONT"] = { type = "Model", model = "models/props_c17/light_decklight01_on.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(21.676, 0.808, -9.053), angle = Angle(90.266, 0, 90), size = Vector(0.236, 1.067, 0.105), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["METALback"] = { type = "Model", model = "models/props_combine/combine_interface003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALFRONT+", pos = Vector(-6.603, -17.254, 0), angle = Angle(0, 92.513, 90), size = Vector(0.232, 0.043, 0.15), color = Color(105, 100, 110, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["projectile"] = { type = "Model", model = "models/props_junk/sawblade001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALFRONT", pos = Vector(2.355, -6.348, 0), angle = Angle(90, 0, 0), size = Vector(0.224, 0.224, 0.564), color = Color(130, 125, 120, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["METALTOP"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALFRONT", pos = Vector(2.826, -11.686, 0), angle = Angle(0, 64.527, 90), size = Vector(0.63, 0.598, 0.63), color = Color(100, 90, 120, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
	["METALGASCAN"] = { type = "Model", model = "models/props_c17/canister_propane01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALFRONT+", pos = Vector(1.281, -11.554, 0), angle = Angle(90, 0, 0), size = Vector(0.104, 0.105, 0.098), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} },
	["METALFRONT+"] = { type = "Model", model = "models/props_c17/light_decklight01_on.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "METALFRONT", pos = Vector(3.799, 1.49, 0), angle = Angle(180, 0, 0), size = Vector(0.236, 1.258, 0.105), color = Color(110, 100, 90, 255), surpresslightning = false, material = "models/props_canal/metalwall005b", skin = 0, bodygroup = {} }
}

-- ==== PostDrawViewModel - 视图模型绘制后：绘制 3D 武器 HUD 并驱动锯盘动画 ====
function SWEP:PostDrawViewModel(vm, pl, wep)
	-- 需要时绘制 3D 武器 HUD
	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end

	-- 根据剩余弹药与距上次开火的时间计算锯盘回缩比例（无弹药时完全收回）
	local lol = self:Clip1() == 0 and 0 or (CurTime() - self:GetLastFired())^1.2
	local resize = math.Clamp(lol, 0, 0.224)

	-- 动态调整锯盘模型大小，模拟锯盘弹出/收回
	local rotsize = self.VElements["projectile"].size
	local rotsize2 = self.VElements["projectilepart2"].size
	rotsize.x = resize
	rotsize.y = resize
	rotsize2.y = resize * 4
	rotsize2.x = resize * 4

	-- 让锯盘持续旋转
	local rots= self.VElements["projectile"].angle
	rots.x = rots.x + 1.5
end


-- 幽灵建造/换弹时的视角摆动插值
local ghostlerp = 0
-- ==== CalcViewModelView - 计算视图模型位置：建造幽灵或换弹时向右倾斜 ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 处于幽灵建造或换弹完成阶段时逐渐倾斜，否则缓慢回正
	if self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 1)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 1.5)
	end

	-- 按插值量绕右轴旋转视角
	if ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -35 * ghostlerp)
	end

	return pos, ang
end
