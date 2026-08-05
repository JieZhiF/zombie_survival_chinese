-- ============================================================================
-- cl_init.lua - 木板背包武器客户端脚本
-- 负责：设置镜头与武器栏位（部署物槽）；SCK 自定义手持木板外观；
--       木板耗尽后把视图模型移出屏幕外
-- ============================================================================
INC_CLIENT()

-- 第一人称镜头视野与模型方向
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false

-- 隐藏世界模型（仅显示自定义手持部件）
SWEP.ShowWorldModel = false

-- 调整右手骨骼角度（适配手持木板姿势）
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(3.332, -14.445, -21.112) }
}

-- 第一人称部件：手持木板（缩小版）
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_debris/wood_board06a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 2.596, -6.753), angle = Angle(180, 66.623, -1.17), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称部件：手持木板（他人视角）
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_debris/wood_board06a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 2.596, -6.753), angle = Angle(180, 66.623, -1.17), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 武器栏位（部署物槽）与选择组
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES

-- ==== GetViewModelPosition - 木板耗尽时隐藏视图模型 ====
-- 没有剩余木板时把视图模型移到屏幕外 256 单位，示意"背包已空"
function SWEP:GetViewModelPosition(pos, ang)
	if self:GetPrimaryAmmoCount() <= 0 then
		return pos + ang:Forward() * -256, ang
	end

	return pos, ang
end
