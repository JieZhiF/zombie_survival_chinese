-- ============================================================================
-- weapon_zs_corruptedfragment.lua - 腐化碎片（人类副手道具）
-- 负责：继承法阵碎片基底；客户端拼装绿色发光晶体 + 光晕特效外观；
--       消耗"腐化碎片"弹药，用于在腐化法阵处进行传送（腐化传送状态/特效）
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_corruptedfragment")
SWEP.Description = ""..translate.Get("weapon_zs_corruptedfragment_description")

-- 继承法阵碎片基底（提供法阵交互逻辑）
SWEP.Base = "weapon_zs_sigilfragment"

if CLIENT then
	-- 第一人称附加模型：脊柱骨上挂晶体主体 + 多个绿色光晕 Sprite
	SWEP.VElements = {
		["main"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1, 5, 1), angle = Angle(-61.949, 87.662, 127.402), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
		["1++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(-1.558, -1.558, 0.2), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 200, 64, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["base++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
		["base+"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
		["1+++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(0.518, 1, 1.557), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 200, 64, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["base"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
		["1+"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(1.557, 0, 0.2), angle = Angle(0, 99.35, 52.597), size = Vector(0.05, 0.05, 0.05), color = Color(72, 200, 64, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["1"] = { type = "Model", model = "models/props_wasteland/medbridge_post01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(0, 0, -1.5), angle = Angle(0, 0, 0), size = Vector(0.029, 0.029, 0.029), color = Color(166, 255, 100, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：挂在右手骨上的同款晶体外观
	SWEP.WElements = {
		["main"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 5, -0.5), angle = Angle(-17.532, 45.583, 127.402), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["1++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(-1.558, -1.558, 0.2), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 200, 64, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["base++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["base+"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["1+++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0.518, 1, 1.557), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 200, 64, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["1"] = { type = "Model", model = "models/props_wasteland/medbridge_post01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0, 0, -1.5), angle = Angle(0, 0, 0), size = Vector(0.029, 0.029, 0.029), color = Color(166, 255, 100, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
		["base"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(123, 255, 104, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["1+"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(1.557, 0, 0.2), angle = Angle(0, 99.35, 52.597), size = Vector(0.05, 0.05, 0.05), color = Color(72, 200, 64, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
	}
end

-- 主攻击消耗的弹药类型
SWEP.Primary.Ammo = "corruptedfragment"

-- 传送附加的状态与特效名（法阵传送）
SWEP.TeleportStatus = "corruptedteleport"
SWEP.TeleportEffect = "corrupted_teleport"

-- ==== CanPrimaryAttack - 主攻击可用性判定：持物/建墙中或场上无腐化法阵时禁用 ====
function SWEP:CanPrimaryAttack()
	-- 持物、建墙幽灵状态或场上没有腐化法阵：不可使用
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or GAMEMODE:NumCorruptedSigils() <= 0 then return false end

	-- 弹药耗尽：走一次攻击冷却后返回不可用
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

if CLIENT then
-- ==== DrawWorldModel - 世界模型绘制：让晶体主体随时间自旋 ====
function SWEP:DrawWorldModel()
	local time = UnPredictedCurTime() * 45
	local vang = self.WElements.main.angle
	-- 每帧更新偏航/俯仰角实现旋转
	vang.p = time % 360
	vang.y = vang.p

	self.BaseClass.BaseClass.DrawWorldModel(self)
end
-- 半透明渲染路径复用同一绘制函数
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel
end
