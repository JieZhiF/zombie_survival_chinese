-- ============================================================================
-- weapon_zs_tithonus/cl_init.lua - 泰坦投射器（客户端）
-- 负责：武器槽位/HUD 3D 展示、组合体零件造型（第一/三人称）与换弹完成处理
-- ============================================================================

INC_CLIENT()

-- 武器槽位：霰弹枪类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
-- 武器选择分组：霰弹枪
SWEP.SlotGroup = WEPSELECT_SHOTGUN
-- 槽内位置 0
SWEP.SlotPos = 0

-- 不翻转第一人称模型
SWEP.ViewModelFlip = false
-- 第一人称镜头视野
SWEP.ViewModelFOV = 60

-- HUD 3D 模型挂点：枪骨骼
SWEP.HUD3DBone = "ValveBiped.Gun"
-- HUD 3D 模型偏移位置
SWEP.HUD3DPos = Vector(2.12, -1, -8)
-- HUD 3D 模型缩放
SWEP.HUD3DScale = 0.025

-- 第一人称附加模型：蓝色组合体零件拼装的发射器造型
SWEP.VElements = {
	["tithonus_parts+++"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "ValveBiped.Gun", rel = "tithonus_parts", pos = Vector(-4, 0, -10), angle = Angle(0, -90, 90), size = Vector(0.029, 0.039, 0.039), color = Color(59, 92, 161, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tithonus_parts+"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Gun", rel = "tithonus_parts", pos = Vector(-5, 0, -10.91), angle = Angle(-90, 0, 0), size = Vector(0.8, 0.2, 0.367), color = Color(67, 94, 127, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tithonus_parts"] = { type = "Model", model = "models/props_combine/combine_dispenser.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, 0, -2.799), angle = Angle(0, 90, 180), size = Vector(0.15, 0.14, 0.3), color = Color(36, 85, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tithonus_parts++"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Gun", rel = "tithonus_parts", pos = Vector(-1, -1, -8.832), angle = Angle(-180, 0, 0), size = Vector(0.4, 0.219, 1.014), color = Color(72, 87, 130, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型：第三人称对应的组合体零件
SWEP.WElements = {
	["tithonus_parts++"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "tithonus_parts", pos = Vector(-1, -1, -8.832), angle = Angle(-180, 0, 0), size = Vector(0.4, 0.219, 1.014), color = Color(72, 87, 130, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tithonus_parts+"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "tithonus_parts", pos = Vector(-5, 0, -10.91), angle = Angle(-90, 0, 0), size = Vector(0.8, 0.2, 0.367), color = Color(67, 94, 127, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tithonus_parts"] = { type = "Model", model = "models/props_combine/combine_dispenser.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.5, 1, -6.753), angle = Angle(-92.338, 180, 0), size = Vector(0.15, 0.14, 0.3), color = Color(36, 85, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["tithonus_parts+++"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "tithonus_parts", pos = Vector(-4, 0, -10), angle = Angle(0, -90, 90), size = Vector(0.029, 0.039, 0.039), color = Color(59, 92, 161, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- ==== Think - 每帧逻辑 ====
function SWEP:Think()
	-- 换弹进行中：到达完成时刻则结束换弹（客户端表现同步）
	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end

		return
	end

	-- 检查充能状态（蓄力攻击系统）
	self:CheckCharge()
end
