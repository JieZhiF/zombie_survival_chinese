-- ============================================================================
-- weapon_zs_t_magnet.lua - T 型磁铁（饰物类被动武器）
-- 负责：以磁铁标记提供被动效果（吸附弹药），并配置手持模型外观
-- ============================================================================
AddCSLuaFile()

-- 基于饰物（trinket）武器母本
SWEP.Base = "weapon_zs_basetrinket"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_magnet")

if CLIENT then
	-- 第一人称视图附加元素：磁铁接收器模型（SCK 元素表）
	SWEP.VElements = {
		["perf"] = { type = "Model", model = "models/props_lab/reciever01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.299, 2.5, -2), angle = Angle(5, 180, 92.337), size = Vector(0.2, 0.699, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称视图附加元素（同样的磁铁模型）
	SWEP.WElements = {
		["perf"] = { type = "Model", model = "models/props_lab/reciever01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.5, -2), angle = Angle(5, 180, 92.337), size = Vector(0.2, 0.699, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 隐藏原模型，只显示磁铁附加元素
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
end

-- 磁铁标记：为持有者提供吸附弹药等被动效果
SWEP.IsMagnet = true
