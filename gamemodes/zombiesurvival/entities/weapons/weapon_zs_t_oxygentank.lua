-- ============================================================================
-- weapon_zs_t_oxygentank.lua - 氧气瓶饰品（随身携带物）
-- 负责：定义氧气瓶的模型显示与配套状态效果
-- ============================================================================
AddCSLuaFile()

-- 基于饰品母本，并缩小模型显示
SWEP.Base = "weapon_zs_basetrinket"
SWEP.ModelScale = 0.5

-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_oxygentank")
SWEP.Description = ""..translate.Get("weapon_zs_t_oxygentank_description")

-- 第三人称模型（使用罐体模型）
SWEP.WorldModel = "models/props_c17/canister01a.mdl"

if CLIENT then
	-- 第一人称视野大小
	SWEP.ViewModelFOV = 60

	-- 隐藏原模型，改用拼接模型元素
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	-- 第一人称拼接模型元素（绑定右手骨骼的氧气罐）
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/canister01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 3, -1), angle = Angle(180, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称拼接模型元素（绑定右手骨骼的氧气罐）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/canister01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 3, -1), angle = Angle(180, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 携带时附加的氧气罐状态效果
SWEP.TrinketStatus = "status_oxygentank"
