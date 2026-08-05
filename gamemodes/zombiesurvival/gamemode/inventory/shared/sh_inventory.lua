-- ============================================================================
-- sh_inventory.lua - 库存系统（共享端）数据与注册表
-- 负责：定义库存物品类别常量、物品元数据注册、武器分解/合成配方注册，
--       以及全部饰品（Trinket）的模型渲染配置与技能修饰符注册
-- ============================================================================

-- ========== 库存物品类别常量定义 ==========

-- 饰品类别（穿戴类，提供被动技能加成）
INVCAT_TRINKETS = 1
-- 组件类别（用于合成武器的材料）
INVCAT_COMPONENTS = 2
-- 消耗品类别（一次性使用的物品）
INVCAT_CONSUMABLES = 3

-- ========== 全局库存物品数据表 ==========

-- 所有库存物品的元数据表（名称、描述、模型等）
GM.ZSInventoryItemData = {}
-- 库存物品类别分类表，包含类别的显示名称（通过翻译系统获取）
GM.ZSInventoryCategories = {
    [INVCAT_TRINKETS] = ""..translate.Get("Inventory_Category_Trinkets"),
    [INVCAT_COMPONENTS] = ""..translate.Get("Inventory_Category_Components"),
    [INVCAT_CONSUMABLES] = ""..translate.Get("Inventory_Category_Consumables")
}

-- ========== 库存物品前缀映射表 ==========

-- 每个类别对应的物品前缀标识（用于从物品名称判断类别）
GM.ZSInventoryPrefix = {
    [INVCAT_TRINKETS] = "trin",
    [INVCAT_COMPONENTS] = "comp",
    [INVCAT_CONSUMABLES] = "cons"
}


-- ========== 合成与分解配方表 ==========

-- 合成配方表（基础武器+组件→高级武器）
GM.Assemblies = {}
-- 分解配方表（武器→组件）
GM.Breakdowns = {}

-- ========== 获取物品类别函数 ==========

-- 根据物品名称前缀判断其所属类别
function GM:GetInventoryItemType(item)
	for typ, aff in pairs(self.ZSInventoryPrefix) do
		if string.sub(item, 1, 4) == aff then
			return typ
		end
	end

	return -1
end

-- ========== 库存物品索引计数器 ==========

local index = 1

-- ========== 注册库存物品数据 ==========

-- 向系统注册一个新的库存物品（含名称、描述、掉落模型、品质等级和库存限制）
function GM:AddInventoryItemData(intname, name, description, weles, tier, stocks)
	
	local datatab = {PrintName = name, DroppedEles = weles, Tier = tier, Description = description, Stocks = stocks, Index = index}
	self.ZSInventoryItemData[intname] = datatab
	self.ZSInventoryItemData[index] = datatab

	index = index + 1
end


-- ========== 注册武器分解配方 ==========

-- 为指定武器注册分解配方（分解后获得特定组件）
function GM:AddWeaponBreakdownRecipe(weapon, result)
	local datatab = {Result = result, Index = index}
	self.Breakdowns[weapon] = datatab
	-- 为武器的三个品质等级也注册相同的分解配方
	for i = 1, 3 do
		self.Breakdowns[self:GetWeaponClassOfQuality(weapon, i)] = datatab
		self.Breakdowns[self:GetWeaponClassOfQuality(weapon, i, 1)] = datatab
	end

	self.Breakdowns[#self.Breakdowns + 1] = datatab
end

-- ========== 武器分解配方定义列表 ==========

GM:AddWeaponBreakdownRecipe("weapon_zs_stubber",							"comp_modbarrel")
GM:AddWeaponBreakdownRecipe("weapon_zs_z9000",								"comp_basicecore")
GM:AddWeaponBreakdownRecipe("weapon_zs_blaster",							"comp_pumpaction")
GM:AddWeaponBreakdownRecipe("weapon_zs_novablaster",						"comp_contaecore")
GM:AddWeaponBreakdownRecipe("weapon_zs_waraxe", 							"comp_focusbarrel")
GM:AddWeaponBreakdownRecipe("weapon_zs_innervator",							"comp_gaussframe")
GM:AddWeaponBreakdownRecipe("weapon_zs_swissarmyknife",						"comp_shortblade")
GM:AddWeaponBreakdownRecipe("weapon_zs_owens",								"comp_multibarrel")
GM:AddWeaponBreakdownRecipe("weapon_zs_onyx",								"comp_precision")
GM:AddWeaponBreakdownRecipe("weapon_zs_minelayer",							"comp_launcher")
GM:AddWeaponBreakdownRecipe("weapon_zs_fracture",							"comp_linearactuator")
GM:AddWeaponBreakdownRecipe("weapon_zs_harpoon",							"comp_metalpole")
GM:AddWeaponBreakdownRecipe("weapon_zs_frotchet",							"comp_frostaxe")

-- ========== 武器合成配方定义列表 ==========

-- 合成配方格式：{所需组件， 基础武器} → 合成目标武器
-- Assemblies (Assembly, Component, Weapon)
GM.Assemblies["weapon_zs_waraxe"] 								= {"comp_modbarrel", 		"weapon_zs_glock3"}
GM.Assemblies["weapon_zs_bust"] 								= {"comp_busthead", 		"weapon_zs_plank"}
GM.Assemblies["weapon_zs_sawhack"] 								= {"comp_sawblade", 		"weapon_zs_axe"}
GM.Assemblies["weapon_zs_manhack_saw"] 							= {"comp_sawblade", 		"weapon_zs_manhack"}
GM.Assemblies["weapon_zs_megamasher"] 							= {"comp_propanecan", 		"weapon_zs_sledgehammer"}
GM.Assemblies["weapon_zs_electrohammer"] 						= {"comp_electrobattery",	"weapon_zs_hammer"}
GM.Assemblies["weapon_zs_novablaster"] 							= {"comp_basicecore",		"weapon_zs_magnum"}
GM.Assemblies["weapon_zs_tithonus"] 							= {"comp_contaecore",		"weapon_zs_oberon"}
GM.Assemblies["weapon_zs_fracture"] 							= {"comp_pumpaction",		"weapon_zs_sawedoff"}
GM.Assemblies["weapon_zs_seditionist"] 							= {"comp_focusbarrel",		"weapon_zs_deagle"}
GM.Assemblies["weapon_zs_molotov"] 								= {"comp_propanecan",		"weapon_zs_glassbottle"}
GM.Assemblies["weapon_zs_blareduct"] 							= {"trinket_ammovestii",	"weapon_zs_pipe"}
GM.Assemblies["weapon_zs_cinderrod"] 							= {"comp_propanecan",		"weapon_zs_blareduct"}
GM.Assemblies["weapon_zs_innervator"] 							= {"comp_electrobattery",	"weapon_zs_jackhammer"}
GM.Assemblies["weapon_zs_hephaestus"] 							= {"comp_gaussframe",		"weapon_zs_tithonus"}
GM.Assemblies["weapon_zs_stabber"] 								= {"comp_shortblade",		"weapon_zs_annabelle"}
GM.Assemblies["weapon_zs_galestorm"] 							= {"comp_multibarrel",		"weapon_zs_uzi"}
GM.Assemblies["weapon_zs_eminence"] 							= {"trinket_ammovestiii",	"weapon_zs_barrage"}
GM.Assemblies["weapon_zs_gladiator"] 							= {"trinket_ammovestiii",	"weapon_zs_sweepershotgun"}
GM.Assemblies["weapon_zs_ripper"]								= {"comp_sawblade",			"weapon_zs_zeus"}
GM.Assemblies["weapon_zs_avelyn"]								= {"trinket_ammovestiii",	"weapon_zs_charon"}
GM.Assemblies["weapon_zs_asmd"]									= {"comp_precision",		"weapon_zs_quasar"}
GM.Assemblies["weapon_zs_frotkatana"]							= {"comp_frostaxe",			"weapon_zs_katana"}
GM.Assemblies["weapon_zs_enkindler"]							= {"comp_launcher",			"weapon_zs_cinderrod"}
GM.Assemblies["weapon_zs_proliferator"]							= {"comp_linearactuator",	"weapon_zs_galestorm"}

-- ========== 饰品合成配方定义列表 ==========

GM.Assemblies["trinket_electromagnet"]							= {"comp_electrobattery",	"trinket_magnet"}
GM.Assemblies["trinket_projguide"]								= {"comp_cpuparts",			"trinket_targetingvisori"}
GM.Assemblies["trinket_projwei"]								= {"comp_busthead",			"trinket_projguide"}
GM.Assemblies["trinket_controlplat"]							= {"comp_cpuparts",			"trinket_mainsuite"}

-- ========== 组件物品数据注册列表 ==========

GM:AddInventoryItemData("comp_modbarrel", ""..translate.Get("Inventory_comp_modbarrel"), ""..translate.Get("Inventory_comp_modbarrel_desc"), "models/props_c17/trappropeller_lever.mdl")
GM:AddInventoryItemData("comp_burstmech", ""..translate.Get("Inventory_comp_burstmech"), ""..translate.Get("Inventory_comp_burstmech_desc"), "models/props_c17/trappropeller_lever.mdl")
GM:AddInventoryItemData("comp_basicecore", ""..translate.Get("Inventory_comp_basicecore"), ""..translate.Get("Inventory_comp_basicecore_desc"), "models/Items/combine_rifle_cartridge01.mdl")
GM:AddInventoryItemData("comp_busthead", ""..translate.Get("Inventory_comp_busthead"), ""..translate.Get("Inventory_comp_busthead_desc"), "models/props_combine/breenbust.mdl")
GM:AddInventoryItemData("comp_sawblade", ""..translate.Get("Inventory_comp_sawblade"), ""..translate.Get("Inventory_comp_sawblade_desc"), "models/props_junk/sawblade001a.mdl")
GM:AddInventoryItemData("comp_propanecan", ""..translate.Get("Inventory_comp_propanecan"), ""..translate.Get("Inventory_comp_propanecan_desc"), "models/props_junk/propane_tank001a.mdl")
GM:AddInventoryItemData("comp_electrobattery", ""..translate.Get("Inventory_comp_electrobattery"), ""..translate.Get("Inventory_comp_electrobattery_desc"), "models/items/car_battery01.mdl")

--GM:AddInventoryItemData("comp_hungrytether",	"Hungry Tether",			"A hungry tether from a devourer that comes from a devourer rib.",								"models/gibs/HGIBS_rib.mdl")]]
GM:AddInventoryItemData("comp_contaecore", ""..translate.Get("Inventory_comp_contaecore"), ""..translate.Get("Inventory_comp_contaecore_desc"), "models/Items/combine_rifle_cartridge01.mdl")
GM:AddInventoryItemData("comp_pumpaction", ""..translate.Get("Inventory_comp_pumpaction"), ""..translate.Get("Inventory_comp_pumpaction_desc"), "models/props_c17/trappropeller_lever.mdl")
GM:AddInventoryItemData("comp_focusbarrel", ""..translate.Get("Inventory_comp_focusbarrel"), ""..translate.Get("Inventory_comp_focusbarrel_desc"), "models/props_c17/trappropeller_lever.mdl")
GM:AddInventoryItemData("comp_gaussframe", ""..translate.Get("Inventory_comp_gaussframe"), ""..translate.Get("Inventory_comp_gaussframe_desc"), "models/Items/combine_rifle_cartridge01.mdl")
GM:AddInventoryItemData("comp_metalpole", ""..translate.Get("Inventory_comp_metalpole"), ""..translate.Get("Inventory_comp_metalpole_desc"), "models/props_c17/signpole001.mdl")
GM:AddInventoryItemData("comp_salleather", ""..translate.Get("Inventory_comp_salleather"), ""..translate.Get("Inventory_comp_salleather_desc"), "models/props_junk/shoe001.mdl")
GM:AddInventoryItemData("comp_gyroscope", ""..translate.Get("Inventory_comp_gyroscope"), ""..translate.Get("Inventory_comp_gyroscope_desc"), "models/maxofs2d/hover_rings.mdl")
GM:AddInventoryItemData("comp_reciever", ""..translate.Get("Inventory_comp_reciever"), ""..translate.Get("Inventory_comp_reciever_desc"), "models/props_lab/reciever01b.mdl")
GM:AddInventoryItemData("comp_cpuparts", ""..translate.Get("Inventory_comp_cpuparts"), ""..translate.Get("Inventory_comp_cpuparts_desc"), "models/props_lab/harddrive01.mdl")
GM:AddInventoryItemData("comp_launcher", ""..translate.Get("Inventory_comp_launcher"), ""..translate.Get("Inventory_comp_launcher_desc"), "models/weapons/w_rocket_launcher.mdl")
GM:AddInventoryItemData("comp_launcherh", ""..translate.Get("Inventory_comp_launcherh"), ""..translate.Get("Inventory_comp_launcherh_desc"), "models/weapons/w_rocket_launcher.mdl")
GM:AddInventoryItemData("comp_shortblade", ""..translate.Get("Inventory_comp_shortblade"), ""..translate.Get("Inventory_comp_shortblade_desc"), "models/weapons/w_knife_t.mdl")
GM:AddInventoryItemData("comp_multibarrel", ""..translate.Get("Inventory_comp_multibarrel"), ""..translate.Get("Inventory_comp_multibarrel_desc"), "models/props_lab/pipesystem03a.mdl")
GM:AddInventoryItemData("comp_holoscope", ""..translate.Get("Inventory_comp_holoscope"), ""..translate.Get("Inventory_comp_holoscope_desc"), {
    ["base"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.273, 1.728, -0.843), angle = Angle(74.583, 180, 0), size = Vector(2.207, 0.105, 0.316), color = Color(50, 50, 66, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal02", skin = 0, bodygroup = {} },
    ["base+"] = { type = "Model", model = "models/props_combine/tprotato1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.492, -1.03, 0), angle = Angle(0, -78.715, 90), size = Vector(0.03, 0.02, 0.032), color = Color(50, 50, 66, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal02", skin = 0, bodygroup = {} }
})

GM:AddInventoryItemData("comp_linearactuator", ""..translate.Get("Inventory_comp_linearactuator"), ""..translate.Get("Inventory_comp_linearactuator_desc"), "models/Items/combine_rifle_cartridge01.mdl")
GM:AddInventoryItemData("comp_pulsespool", ""..translate.Get("Inventory_comp_pulsespool"), ""..translate.Get("Inventory_comp_pulsespool_desc"), "models/Items/combine_rifle_cartridge01.mdl")
GM:AddInventoryItemData("comp_flak", ""..translate.Get("Inventory_comp_flak"), ""..translate.Get("Inventory_comp_flak_desc"), "models/weapons/w_rocket_launcher.mdl")

GM:AddInventoryItemData("comp_precision",		""..translate.Get("Inventory_comp_precision"),		""..translate.Get("Inventory_comp_precision_desc"),									"models/Items/combine_rifle_cartridge01.mdl")
GM:AddInventoryItemData("comp_frostaxe",		""..translate.Get("Inventory_comp_frostaxe"),		""..translate.Get("Inventory_comp_frostaxe_desc"),									"models/Items/combine_rifle_cartridge01.mdl")

-- ========== 饰品掉落渲染模型定义 ==========

-- 装饰品相关变量声明
local trinket, description, trinketwep

-- 生命类饰品的手持视角渲染配置（第一人称）
local hpveles = {
	["ammo"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 3.5, 3), angle = Angle(15.194, 80.649, 180), size = Vector(0.6, 0.6, 1.2), color = Color(145, 132, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 生命类饰品的第三人称渲染配置
local hpweles = {
	["ammo"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.5, 2.5, 3), angle = Angle(15.194, 80.649, 180), size = Vector(0.6, 0.6, 1.2), color = Color(145, 132, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 弹药类饰品的第一人称渲染配置
local ammoveles = {
	["ammo"] = { type = "Model", model = "models/props/de_prodigy/ammo_can_02.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 3, -0.519), angle = Angle(0, 85.324, 101.688), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 弹药类饰品的第三人称渲染配置
local ammoweles = {
	["ammo"] = { type = "Model", model = "models/props/de_prodigy/ammo_can_02.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 2, -1.558), angle = Angle(5.843, 82.986, 111.039), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 近战类饰品的第一人称渲染配置（含多层部件组装）
local mveles = {
	["band++"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "band", pos = Vector(2.599, 1, 1), angle = Angle(0, -25, 0), size = Vector(0.019, 0.15, 0.15), color = Color(55, 52, 51, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["band"] = { type = "Model", model = "models/props_phx/construct/metal_plate_curve360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 3, -1), angle = Angle(97.013, 29.221, 0), size = Vector(0.045, 0.045, 0.025), color = Color(55, 52, 51, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["band+"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "band", pos = Vector(-2.401, -1, 0.5), angle = Angle(0, 155.455, 0), size = Vector(0.019, 0.15, 0.15), color = Color(55, 52, 51, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
}

-- 近战类饰品的第三人称渲染配置（含多层部件组装）
local mweles = {
	["band++"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "band", pos = Vector(2.599, 1, 1), angle = Angle(0, -25, 0), size = Vector(0.019, 0.15, 0.15), color = Color(55, 52, 51, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["band+"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "band", pos = Vector(-2.401, -1, 0.5), angle = Angle(0, 155.455, 0), size = Vector(0.019, 0.15, 0.15), color = Color(55, 52, 51, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
	["band"] = { type = "Model", model = "models/props_phx/construct/metal_plate_curve360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.5, 2, -0.5), angle = Angle(111.039, -92.338, 97.013), size = Vector(0.045, 0.045, 0.025), color = Color(55, 52, 51, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
}

-- 性能类饰品的第一人称渲染配置
local pveles = {
	["perf"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1.557, -2.597), angle = Angle(5.843, 90, 0), size = Vector(0.25, 0.15, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 性能类饰品的第三人称渲染配置
local pweles = {
	["perf"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 0.5, -2), angle = Angle(5, 90, 0), size = Vector(0.25, 0.15, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 进攻类饰品的第一人称渲染配置
local oveles = {
	["perf"] = { type = "Model", model = "models/props_combine/combine_generator01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.799, 2, -1.5), angle = Angle(5, 180, 0), size = Vector(0.05, 0.039, 0.07), color = Color(196, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 进攻类饰品的第三人称渲染配置
local oweles = {
	["perf"] = { type = "Model", model = "models/props_combine/combine_generator01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.799, 2, -1.5), angle = Angle(5, 180, 0), size = Vector(0.05, 0.039, 0.07), color = Color(196, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 防御类饰品的第一人称渲染配置
local develes = {
	["perf"] = { type = "Model", model = "models/props_lab/blastdoor001b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.799, 2.5, -5.715), angle = Angle(5, 180, 0), size = Vector(0.1, 0.039, 0.09), color = Color(168, 155, 0, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} }
}

-- 防御类饰品的第三人称渲染配置
local deweles = {
	["perf"] = { type = "Model", model = "models/props_lab/blastdoor001b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 2, -5.715), angle = Angle(0, 180, 0), size = Vector(0.1, 0.039, 0.09), color = Color(168, 155, 0, 255), surpresslightning = false, material = "models/props_pipes/pipeset_metal", skin = 0, bodygroup = {} }
}

-- 支援类饰品的第一人称渲染配置
local supveles = {
	["perf"] = { type = "Model", model = "models/props_lab/reciever01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.299, 2.5, -2), angle = Angle(5, 180, 92.337), size = Vector(0.2, 0.699, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 支援类饰品的第三人称渲染配置
local supweles = {
	["perf"] = { type = "Model", model = "models/props_lab/reciever01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.5, -2), angle = Angle(5, 180, 92.337), size = Vector(0.2, 0.699, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- ========== 生命/治疗类饰品注册 ==========

-- 医疗包：提供+10生命值、+5%治疗效果，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_HealthPackage"), "vitpackagei", false, hpveles, hpweles, 2, ""..translate.Get("Inventory_Trinket_HealthPackage_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_HEALTH, 10)
GM:AddSkillModifier(trinket, SKILLMOD_HEALING_RECEIVED, 0.05)
trinketwep.PermitDismantle = true

-- 生命银行：提供+21生命值、+6%治疗效果
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_VitalityBank"), "vitpackageii", false, hpveles, hpweles, 4, ""..translate.Get("Inventory_Trinket_VitalityBank_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_HEALTH, 21)
GM:AddSkillModifier(trinket, SKILLMOD_HEALING_RECEIVED, 0.06)

-- 输血包：需要15等级，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_BloodTransfusionPack"), "bloodpack", false, hpveles, hpweles, 2, ""..translate.Get("Inventory_Trinket_BloodTransfusionPack_desc"), nil, 15)
trinketwep.PermitDismantle = true

-- 血包：提供+10血甲，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_BloodPackage"), "cardpackagei", false, hpveles, hpweles, 2, ""..translate.Get("Inventory_Trinket_BloodPackage_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_BLOODARMOR, 10)
trinketwep.PermitDismantle = true

-- 血库：提供+30血甲
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_BloodBank"), "cardpackageii", false, hpveles, hpweles, 4, ""..translate.Get("Inventory_Trinket_BloodBank_desc")), SKILLMOD_BLOODARMOR, 30)

-- 再生植入体
GM:AddTrinket(""..translate.Get("Inventory_Trinket_RegenerationImplant"), "regenimplant", false, hpveles, hpweles, 3, ""..translate.Get("Inventory_Trinket_RegenerationImplant_desc"))

-- 生物净化器：可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_BioCleanser"), "biocleanser", false, hpveles, hpweles, 2, ""..translate.Get("Inventory_Trinket_BioCleanser_desc"))
trinketwep.PermitDismantle = true

-- 餐具套装：减少80%进食时间
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_CutlerySet"), "cutlery", false, hpveles, hpweles, nil, ""..translate.Get("Inventory_Trinket_CutlerySet_desc")), SKILLMOD_FOODEATTIME_MUL, -0.8)

-- ========== 近战类饰品注册 ==========

-- 近战类装饰品说明文本
description = ""..translate.Get("Inventory_Trinket_BoxingTrainingManual_desc")
-- 拳击训练手册：减少15%徒手攻击间隔
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_BoxingTrainingManual"), "boxingtraining", false, mveles, mweles, nil, description)
GM:AddSkillModifier(trinket, SKILLMOD_UNARMED_SWING_DELAY_MUL, -0.15)
GM:AddSkillFunction(trinket, function(pl, active) pl.BoxingTraining = active end)

-- 动量支撑系统II：减少13%近战攻击间隔、+10%击退，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_MomentumSupport"), "momentumsupsysii", false, mveles, mweles, 2, ""..translate.Get("Inventory_Trinket_MomentumSupport_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_SWING_DELAY_MUL, -0.13)
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_KNOCKBACK_MUL, 0.1)
trinketwep.PermitDismantle = true

-- 动量支架III：减少20%近战攻击间隔、+12%击退
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_MomentumScaffold"), "momentumsupsysiii", false, mveles, mweles, 3, ""..translate.Get("Inventory_Trinket_MomentumScaffold_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_SWING_DELAY_MUL, -0.20)
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_KNOCKBACK_MUL, 0.12)

-- 血肾上腺素转换器I：2%近战伤害转化为血甲
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_HemoAdrenalConverterI"), "hemoadrenali", false, mveles, mweles, nil, ""..translate.Get("Inventory_Trinket_HemoAdrenalConverterI_desc")), SKILLMOD_MELEE_DAMAGE_TO_BLOODARMOR_MUL, 0.02)

-- 血肾上腺素放大器：3%伤害转血甲、击杀+30移速
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_HemoAdrenalineAmplifier"), "hemoadrenalii", false, mveles, mweles, 3, ""..translate.Get("Inventory_Trinket_HemoAdrenalineAmplifier_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_DAMAGE_TO_BLOODARMOR_MUL, 0.03)
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_MOVEMENTSPEED_ON_KILL, 30)

-- 血肾上腺素转换器II：4%伤害转血甲
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_HemoAdrenalConverterII"), "hemoadrenaliii", false, mveles, mweles, 4, ""..translate.Get("Inventory_Trinket_HemoAdrenalConverterII_desc")), SKILLMOD_MELEE_DAMAGE_TO_BLOODARMOR_MUL, 0.04)

-- 动力拳套：+45%近战强力攻击伤害
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_PowerGauntlet"), "powergauntlet", false, mveles, mweles, 3, ""..translate.Get("Inventory_Trinket_PowerGauntlet_desc")), SKILLMOD_MELEE_POWERATTACK_MUL, 0.45)

-- 精巧工具包
GM:AddTrinket(""..translate.Get("Inventory_Trinket_FinesseKit"), "sharpkit", false, mveles, mweles, 2, ""..translate.Get("Inventory_Trinket_FinesseKit_desc"))

-- 磨刀石：+5%近战伤害
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_SharpStone"), "sharpstone", false, mveles, mweles, 3, ""..translate.Get("Inventory_Trinket_SharpStone_desc")), SKILLMOD_MELEE_DAMAGE_MUL, 0.05)

-- ========== 性能类饰品注册 ==========

-- 氧气罐（主动使用）
GM:AddTrinket(""..translate.Get("Inventory_Trinket_OxygenTank"), "oxygentank", true, nil, {
	["base"] = { type = "Model", model = "models/props_c17/canister01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 3, -1), angle = Angle(180, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}, nil, ""..translate.Get("Inventory_Trinket_OxygenTank_desc"), "oxygentank")

-- 杂技框架：+8%跳跃力
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_AcrobatFrame"), "acrobatframe", false, pveles, pweles, nil, ""..translate.Get("Inventory_Trinket_AcrobatFrame_desc")), SKILLMOD_JUMPPOWER_MUL, 0.08)

-- 夜视护目镜：减少50%昏暗效果、减少45%恐惧持续时间、减少40%视觉变异效果，可拆解
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_NightVisionGoggles"), "nightvision", true, pveles, pweles, 2, ""..translate.Get("Inventory_Trinket_NightVisionGoggles_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_DIMVISION_EFF_MUL, -0.5)
GM:AddSkillModifier(trinket, SKILLMOD_FRIGHT_DURATION_MUL, -0.45)
GM:AddSkillModifier(trinket, SKILLMOD_VISION_ALTER_DURATION_MUL, -0.4)
-- 客户端特有：取消夜视时的音效处理
GM:AddSkillFunction(trinket, function(pl, active)
	if CLIENT and pl == MySelf and GAMEMODE.m_NightVision and not active then
		surface.PlaySound("items/nvg_off.wav")
		GAMEMODE.m_NightVision = false
	end
end)
trinketwep.PermitDismantle = true

-- 便携武器背包：+15%部署速度、+3%换弹速度
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_PortableWeaponsSatchel"), "portablehole", false, pveles, pweles, nil, ""..translate.Get("Inventory_Trinket_PortableWeaponsSatchel_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_DEPLOYSPEED_MUL, 0.15)
GM:AddSkillModifier(trinket, SKILLMOD_RELOADSPEED_MUL, 0.03)

-- 灵活放大器：+40%路障穿越速度、-45%符文传送延迟、+13%跳跃力
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_AgilityMagnifier"), "pathfinder", false, pveles, pweles, 2, ""..translate.Get("Inventory_Trinket_AgilityMagnifier_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_BARRICADE_PHASE_SPEED_MUL, 0.4)
GM:AddSkillModifier(trinket, SKILLMOD_SIGIL_TELEPORT_MUL, -0.45)
GM:AddSkillModifier(trinket, SKILLMOD_JUMPPOWER_MUL, 0.13)

-- 激励植入体：-50%减速效果、-50%低血量减速、-50%击倒恢复时间、+25%部署速度
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_GalvanizerImplant"), "analgestic", false, pveles, pweles, 3, ""..translate.Get("Inventory_Trinket_GalvanizerImplant_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_SLOW_EFF_TAKEN_MUL, -0.50)
GM:AddSkillModifier(trinket, SKILLMOD_LOW_HEALTH_SLOW_MUL, -0.50)
GM:AddSkillModifier(trinket, SKILLMOD_KNOCKDOWN_RECOVERY_MUL, -0.5)
GM:AddSkillModifier(trinket, SKILLMOD_DEPLOYSPEED_MUL, 0.25)

-- 弹药背心II：+5%换弹速度
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_AmmoVest"), "ammovestii", false, ammoveles, ammoweles, 2, ""..translate.Get("Inventory_Trinket_AmmoVest_desc")), SKILLMOD_RELOADSPEED_MUL, 0.05)
-- 弹药带III：+12%换弹速度
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_AmmoBandolier"), "ammovestiii", false, ammoveles, ammoweles, 4, ""..translate.Get("Inventory_Trinket_AmmoBandolier_desc")), SKILLMOD_RELOADSPEED_MUL, 0.12)

-- 自动装填器
GM:AddTrinket(""..translate.Get("Inventory_Trinket_AutomatedReloader"), "autoreload", false, ammoveles, ammoweles, 2, ""..translate.Get("Inventory_Trinket_AutomatedReloader_desc"))

-- ========== 进攻类饰品注册 ==========

-- 目标锁定护目镜I：-5%散布
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_TargetingVisor"), "targetingvisori", false, oveles, oweles, nil, ""..translate.Get("Inventory_Trinket_TargetingVisor_desc")), SKILLMOD_AIMSPREAD_MUL, -0.05)

-- 目标统一器III：-11%散布
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_TargetingUnifier"), "targetingvisoriii", false, oveles, oweles, 4, ""..translate.Get("Inventory_Trinket_TargetingUnifier_desc")), SKILLMOD_AIMSPREAD_MUL, -0.11)

-- 精密副瞄准镜
GM:AddTrinket(""..translate.Get("Inventory_Trinket_RefinedSubscope"), "refinedsub", false, oveles, oweles, 4, ""..translate.Get("Inventory_Trinket_RefinedSubscope_desc"))

-- 瞄准补偿器：-5%散布、-52%瞄准晃动，启用目标锁定功能
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_AimCompensator"), "aimcomp", false, oveles, oweles, 3, ""..translate.Get("Inventory_Trinket_AimCompensator_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_AIMSPREAD_MUL, -0.05)
GM:AddSkillModifier(trinket, SKILLMOD_AIM_SHAKE_MUL, -0.52)
GM:AddSkillFunction(trinket, function(pl, active) pl.TargetLocus = active end)

-- 脉冲增强器I：+14%脉冲武器减速
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_PulseBooster"), "pulseampi", false, oveles, oweles, nil, ""..translate.Get("Inventory_Trinket_PulseBooster_desc")), SKILLMOD_PULSE_WEAPON_SLOW_MUL, 0.14)

-- 脉冲注入器II：+20%脉冲武器减速、+7%爆炸范围
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_PulseInfuser"), "pulseampii", false, oveles, oweles, 3, ""..translate.Get("Inventory_Trinket_PulseInfuser_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_PULSE_WEAPON_SLOW_MUL, 0.2)
GM:AddSkillModifier(trinket, SKILLMOD_EXP_DAMAGE_RADIUS, 0.07)

-- 共振级联装置：-25%脉冲武器减速
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ResonanceCascadeDevice"), "resonance", false, oveles, oweles, 4, ""..translate.Get("Inventory_Trinket_ResonanceCascadeDevice_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_PULSE_WEAPON_SLOW_MUL, -0.25)

-- 低温电感器
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_CryogenicInductor"), "cryoindu", false, oveles, oweles, 4, ""..translate.Get("Inventory_Trinket_CryogenicInductor_desc"))

-- 扩展弹匣
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ExtendedMagazine"), "extendedmag", false, oveles, oweles, 3, ""..translate.Get("Inventory_Trinket_ExtendedMagazine_desc"))

-- 脉冲阻抗模块：+24%脉冲武器减速，启用脉冲阻抗功能
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_PulseImpedanceModule"), "pulseimpedance", false, oveles, oweles, 5, ""..translate.Get("Inventory_Trinket_PulseImpedanceModule_desc"))
GM:AddSkillFunction(trinket, function(pl, active) pl.PulseImpedance = active end)
GM:AddSkillModifier(trinket, SKILLMOD_PULSE_WEAPON_SLOW_MUL, 0.24)

-- 践踏者：-25%坠落减速效果
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_CurbStompers"), "curbstompers", false, oveles, oweles, 2, ""..translate.Get("Inventory_Trinket_CurbStompers_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_FALLDAMAGE_SLOWDOWN_MUL, -0.25)

-- 高级组装
GM:AddTrinket(""..translate.Get("Inventory_Trinket_SuperiorAssembly"), "supasm", false, oveles, oweles, 5, ""..translate.Get("Inventory_Trinket_SuperiorAssembly_desc"))

-- 奥林匹克框架：+100%投掷力量、-25%搬运减速、-35%武器重量减速
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_OlympianFrame"), "olympianframe", false, oveles, oweles, 2, ""..translate.Get("Inventory_Trinket_OlympianFrame_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_PROP_THROW_STRENGTH_MUL, 1)
GM:AddSkillModifier(trinket, SKILLMOD_PROP_CARRY_SLOW_MUL, -0.25)
GM:AddSkillModifier(trinket, SKILLMOD_WEAPON_WEIGHT_SLOW_MUL, -0.35)

-- ========== 防御类饰品注册 ==========

-- 凯夫拉内衬：-11%近战伤害、-11%远程伤害，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_KevlarUnderlay"), "kevlar", false, develes, deweles, 2, ""..translate.Get("Inventory_Trinket_KevlarUnderlay_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_DAMAGE_TAKEN_MUL, -0.11)
GM:AddSkillModifier(trinket, SKILLMOD_PROJECTILE_DAMAGE_TAKEN_MUL, -0.11)
trinketwep.PermitDismantle = true

-- 倒刺装甲：14点近战伤害反射、100%反射几率、-4%近战伤害
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_BarbedArmor"), "barbedarmor", false, develes, deweles, 3, ""..translate.Get("Inventory_Trinket_BarbedArmor_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_ATTACKER_DMG_REFLECT, 14)
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_ATTACKER_DMG_REFLECT_PERCENT, 1)
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_DAMAGE_TAKEN_MUL, -0.04)

-- 抗毒包：-17%毒素伤害、-40%毒素减速
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_AntitoxinPackage"), "antitoxinpack", false, develes, deweles, 2, ""..translate.Get("Inventory_Trinket_AntitoxinPackage_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_POISON_DAMAGE_TAKEN_MUL, -0.17)
GM:AddSkillModifier(trinket, SKILLMOD_POISON_SPEED_MUL, -0.4)

-- 止血植入体：-30%流血伤害、-60%流血减速
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_HemostasisImplant"), "hemostasis", false, develes, deweles, 2, ""..translate.Get("Inventory_Trinket_HemostasisImplant_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_BLEED_DAMAGE_TAKEN_MUL, -0.3)
GM:AddSkillModifier(trinket, SKILLMOD_BLEED_SPEED_MUL, -0.6)

-- 排爆背心：-35%爆炸伤害、-50%火焰伤害、-5%自我伤害
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_EODVest"), "eodvest", false, develes, deweles, 4, ""..translate.Get("Inventory_Trinket_EODVest_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_EXP_DAMAGE_TAKEN_MUL, -0.35)
GM:AddSkillModifier(trinket, SKILLMOD_FIRE_DAMAGE_TAKEN_MUL, -0.50)
GM:AddSkillModifier(trinket, SKILLMOD_SELF_DAMAGE_MUL, -0.05)

-- 羽落框架：-35%坠落伤害、+30%坠落阈值、-65%坠落减速
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_FeatherFallFrame"), "featherfallframe", false, develes, deweles, 3, ""..translate.Get("Inventory_Trinket_FeatherFallFrame_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_FALLDAMAGE_DAMAGE_MUL, -0.35)
GM:AddSkillModifier(trinket, SKILLMOD_FALLDAMAGE_THRESHOLD_MUL, 0.30)
GM:AddSkillModifier(trinket, SKILLMOD_FALLDAMAGE_SLOWDOWN_MUL, -0.65)

-- ========== 冰爆护盾渲染模型定义 ==========

-- 冰爆护盾第一人称渲染配置
local eicev = {
	["base"] = { type = "Model", model = "models/gibs/glass_shard04.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.339, 2.697, -2.309), angle = Angle(4.558, -34.502, -72.395), size = Vector(0.5, 0.5, 0.5), color = Color(0, 137, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
}

-- 冰爆护盾第三人称渲染配置
local eicew = {
	["base"] = { type = "Model", model = "models/gibs/glass_shard04.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.556, 2.519, -1.468), angle = Angle(0, -5.844, -75.974), size = Vector(0.5, 0.5, 0.5), color = Color(0, 137, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
}

-- 冰爆护盾饰品
GM:AddTrinket(""..translate.Get("Inventory_Trinket_IceburstShield"), "iceburst", false, eicev, eicew, nil, ""..translate.Get("Inventory_Trinket_IceburstShield_desc"))

-- 力场阻尼场发射器：-33%物理伤害
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_ForceDampeningFieldEmitter"), "forcedamp", false, develes, deweles, 2, ""..translate.Get("Inventory_Trinket_ForceDampeningFieldEmitter_desc")), SKILLMOD_PHYSICS_DAMAGE_TAKEN_MUL, -0.33)

-- 死灵感知扭曲器：启用死灵感知网络变量
GM:AddSkillFunction(GM:AddTrinket(""..translate.Get("Inventory_Trinket_NecroticSensesDistorter"), "necrosense", false, develes, deweles, 2, ""..translate.Get("Inventory_Trinket_NecroticSensesDistorter_desc")), function(pl, active) pl:SetDTBool(DT_PLAYER_BOOL_NECRO, active) end)

-- 反应闪光器：可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ReactiveFlasher"), "reactiveflasher", false, develes, deweles, 2, ""..translate.Get("Inventory_Trinket_ReactiveFlasher_desc"))
trinketwep.PermitDismantle = true

-- 复合内衬：-16%近战伤害、-16%远程伤害
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_CompositeUnderlay"), "composite", false, develes, deweles, 4, ""..translate.Get("Inventory_Trinket_CompositeUnderlay_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_DAMAGE_TAKEN_MUL, -0.16)
GM:AddSkillModifier(trinket, SKILLMOD_PROJECTILE_DAMAGE_TAKEN_MUL, -0.16)

-- ========== 支援类饰品注册 ==========

-- 武器库背包（主动使用），允许存放3把武器，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ArsenalPack"), "arsenalpack", false, {
	["base"] = { type = "Model", model = "models/Items/item_item_crate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.35, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}, {
	["base"] = { type = "Model", model = "models/Items/item_item_crate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.35, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}, 4, ""..translate.Get("Inventory_Trinket_ArsenalPack_desc"), "arsenalpack", 3)
trinketwep.PermitDismantle = true

-- 补给背包（主动使用），允许存放3个补给，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ResupplyPack"), "resupplypack", true, nil, {
	["base"] = { type = "Model", model = "models/Items/ammocrate_ar2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.35, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}, 4, ""..translate.Get("Inventory_Trinket_ResupplyPack_desc"), "resupplypack", 3)
trinketwep.PermitDismantle = true

-- 磁铁（主动使用）
GM:AddTrinket(""..translate.Get("Inventory_Trinket_Magnet"), "magnet", true, supveles, supweles, nil, ""..translate.Get("Inventory_Trinket_Magnet_desc"), "magnet")
-- 电磁铁（主动使用）
GM:AddTrinket(""..translate.Get("Inventory_Trinket_Electromagnet"), "electromagnet", true, supveles, supweles, nil, ""..translate.Get("Inventory_Trinket_Electromagnet_desc"), "magnet_electro")

-- 装载外骨骼：-55%搬运减速、-20%部署物打包时间，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_LoadingExoskeleton"), "loadingex", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_LoadingExoskeleton_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_PROP_CARRY_SLOW_MUL, -0.55)
GM:AddSkillModifier(trinket, SKILLMOD_DEPLOYABLE_PACKTIME_MUL, -0.2)
trinketwep.PermitDismantle = true

-- 蓝图I：+10%修复速度，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_Blueprints"), "blueprintsi", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_Blueprints_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_REPAIRRATE_MUL, 0.1)
trinketwep.PermitDismantle = true

-- 高级蓝图II：+20%修复速度
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_AdvancedBlueprints"), "blueprintsii", false, supveles, supweles, 4, ""..translate.Get("Inventory_Trinket_AdvancedBlueprints_desc")), SKILLMOD_REPAIRRATE_MUL, 0.2)

-- 医疗处理器：-5%医疗包冷却、-10%医疗枪射击间隔
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_MedicalProcessor"), "processor", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_MedicalProcessor_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MEDKIT_COOLDOWN_MUL, -0.05)
GM:AddSkillModifier(trinket, SKILLMOD_MEDGUN_FIRE_DELAY_MUL, -0.1)

-- 治疗工具包III：-10%医疗包冷却、-20%医疗枪射击间隔
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_CurativeKit"), "curativeii", false, supveles, supweles, 3, ""..translate.Get("Inventory_Trinket_CurativeKit_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MEDKIT_COOLDOWN_MUL, -0.1)
GM:AddSkillModifier(trinket, SKILLMOD_MEDGUN_FIRE_DELAY_MUL, -0.2)

-- 康复增强器：+8%医疗包效果
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_RemedialBooster"), "remedy", false, supveles, supweles, 3, ""..translate.Get("Inventory_Trinket_RemedialBooster_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, 0.08)

-- 维护套件II：+10%领域范围、-7%领域延迟、+10%炮塔范围
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_MaintenanceSuite"), "mainsuite", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_MaintenanceSuite_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_FIELD_RANGE_MUL, 0.1)
GM:AddSkillModifier(trinket, SKILLMOD_FIELD_DELAY_MUL, -0.07)
GM:AddSkillModifier(trinket, SKILLMOD_TURRET_RANGE_MUL, 0.1)

-- 控制平台II：+15%可控制实体生命、+15%速度、+20%猎头蟹伤害
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ControlPlatform"), "controlplat", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_ControlPlatform_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_CONTROLLABLE_HEALTH_MUL, 0.15)
GM:AddSkillModifier(trinket, SKILLMOD_CONTROLLABLE_SPEED_MUL, 0.15)
GM:AddSkillModifier(trinket, SKILLMOD_MANHACK_DAMAGE_MUL, 0.2)

-- 弹射物制导：+25%弹射物速度
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ProjectileGuidance"), "projguide", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_ProjectileGuidance_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_PROJ_SPEED, 0.25)

-- 弹射物重锤：-50%弹射物速度、+5%弹射物伤害
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ProjectileWeight"), "projwei", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_ProjectileWeight_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_PROJ_SPEED, -0.5)
GM:AddSkillModifier(trinket, SKILLMOD_PROJECTILE_DAMAGE_MUL, 0.05)

-- ========== 反应化学物渲染模型定义 ==========

-- 反应化学物第一人称渲染配置
local ectov = {
	["base"] = { type = "Model", model = "models/props_junk/glassjug01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.381, 2.617, 2.062), angle = Angle(180, 12.243, 0), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 4.07), angle = Angle(180, 12.243, 0), size = Vector(0.123, 0.123, 0.085), color = Color(0, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
}

-- 反应化学物第三人称渲染配置
local ectow = {
	["base"] = { type = "Model", model = "models/props_junk/glassjug01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.506, 1.82, 1.758), angle = Angle(-164.991, 19.691, 8.255), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 4.07), angle = Angle(180, 12.243, 0), size = Vector(0.123, 0.123, 0.085), color = Color(0, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
}

-- 反应化学物：+30%爆炸易伤、+10%爆炸范围
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ReactiveChemicals"), "reachem", false, ectov, ectow, 3, ""..translate.Get("Inventory_Trinket_ReactiveChemicals_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_EXP_DAMAGE_TAKEN_MUL, 0.3)
GM:AddSkillModifier(trinket, SKILLMOD_EXP_DAMAGE_RADIUS, 0.1)

-- 运作矩阵IV：+15%领域范围、-13%领域延迟、+15%炮塔范围
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_OperationsMatrix"), "opsmatrix", false, supveles, supweles, 4, ""..translate.Get("Inventory_Trinket_OperationsMatrix_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_FIELD_RANGE_MUL, 0.15)
GM:AddSkillModifier(trinket, SKILLMOD_FIELD_DELAY_MUL, -0.13)
GM:AddSkillModifier(trinket, SKILLMOD_TURRET_RANGE_MUL, 0.15)

-- 获取清单II：-6%补给延迟
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_AcquisitionsManifest"), "acqmanifest", false, supveles, supweles, 2, ""..translate.Get("Inventory_Trinket_AcquisitionsManifest_desc")), SKILLMOD_RESUPPLY_DELAY_MUL, -0.06)
-- 采购清单IV：-9%补给延迟
GM:AddSkillModifier(GM:AddTrinket(""..translate.Get("Inventory_Trinket_ProcurementManifest"), "promanifest", false, supveles, supweles, 4, ""..translate.Get("Inventory_Trinket_ProcurementManifest_desc")), SKILLMOD_RESUPPLY_DELAY_MUL, -0.09)

-- ========== Boss饰品注册 ==========

-- 黑色核心第一人称渲染配置（含Sprite粒子效果）
local blcorev = {
	["black_core_2+"] = { type = "Sprite", sprite = "effects/splashwake1", bone = "ValveBiped.Bip01_Spine4", rel = "black_core", pos = Vector(0, 0.1, -0.201), size = { x = 10, y = 10 }, color = Color(0, 0, 0, 255), nocull = false, additive = false, vertexalpha = true, vertexcolor = true, ignorez = true},
	["black_core"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0, 0.5, -1.701), angle = Angle(0, 0, 0), size = Vector(0.349, 0.349, 0.349), color = Color(20, 20, 20, 255), surpresslightning = false, material = "models/shiny", skin = 0, bodygroup = {} },
	["black_core_2"] = { type = "Sprite", sprite = "effects/splashwake3", bone = "ValveBiped.Bip01_Spine4", rel = "black_core", pos = Vector(0, 0.1, -0.201), size = { x = 7.697, y = 7.697 }, color = Color(0, 0, 0, 255), nocull = false, additive = false, vertexalpha = true, vertexcolor = true, ignorez = true}
}

-- 黑色核心第三人称渲染配置
local blcorew = {
	["black_core_2"] = { type = "Sprite", sprite = "effects/splashwake3", bone = "ValveBiped.Bip01_R_Hand", rel = "black_core", pos = Vector(0, 0.1, -0.201), size = { x = 7.697, y = 7.697 }, color = Color(0, 0, 0, 255), nocull = false, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
	["black_core_2+"] = { type = "Sprite", sprite = "effects/splashwake1", bone = "ValveBiped.Bip01_R_Hand", rel = "black_core", pos = Vector(0, 0.1, -0.201), size = { x = 10, y = 10 }, color = Color(0, 0, 0, 255), nocull = false, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
	["black_core"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, 0), angle = Angle(0, 0, 0), size = Vector(0.349, 0.349, 0.349), color = Color(20, 20, 20, 255), surpresslightning = false, material = "models/shiny", skin = 0, bodygroup = {} }
}

-- 苍白之魂（Boss掉落饰品）
GM:AddTrinket(""..translate.Get("Inventory_Trinket_BleakSoul"), "bleaksoul", false, blcorev, blcorew, nil, ""..translate.Get("Inventory_Trinket_BleakSoul_desc"))

-- 精神精华（Boss掉落饰品，含白色发光效果）
trinket = GM:AddTrinket(""..translate.Get("Inventory_Trinket_SpiritEssence"), "spiritess", false, nil, {
	["black_core_2"] = { type = "Sprite", sprite = "effects/splashwake3", bone = "ValveBiped.Bip01_R_Hand", rel = "black_core", pos = Vector(0, 0.1, -0.201), size = { x = 7.697, y = 7.697 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["black_core_2+"] = { type = "Sprite", sprite = "effects/splashwake1", bone = "ValveBiped.Bip01_R_Hand", rel = "black_core", pos = Vector(0, 0.1, -0.201), size = { x = 10, y = 10 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["black_core"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, 0), angle = Angle(0, 0, 0), size = Vector(0.349, 0.349, 0.349), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
}, nil, ""..translate.Get("Inventory_Trinket_SpiritEssence_desc"))

-- 精神精华提供+13%跳跃力
GM:AddSkillModifier(trinket, SKILLMOD_JUMPPOWER_MUL, 0.13)

-- ========== 初始饰品注册（新玩家默认获得） ==========

-- 臂章：-10%近战攻击间隔、-6%近战伤害，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_Armband"), "armband", false, mveles, mweles, nil, ""..translate.Get("Inventory_Trinket_Armband_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_SWING_DELAY_MUL, -0.1)
GM:AddSkillModifier(trinket, SKILLMOD_MELEE_DAMAGE_TAKEN_MUL, -0.06)
trinketwep.PermitDismantle = true

-- 调味品：+20%食物恢复、-20%进食时间，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_Condiments"), "condiments", false, supveles, supweles, nil, ""..translate.Get("Inventory_Trinket_Condiments_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_FOODRECOVERY_MUL, 0.20)
GM:AddSkillModifier(trinket, SKILLMOD_FOODEATTIME_MUL, -0.20)
trinketwep.PermitDismantle = true

-- 逃脱手册：+20%路障穿越速度、-12%低血量减速，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_EscapeManual"), "emanual", false, develes, deweles, nil, ""..translate.Get("Inventory_Trinket_EscapeManual_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_BARRICADE_PHASE_SPEED_MUL, 0.20)
GM:AddSkillModifier(trinket, SKILLMOD_LOW_HEALTH_SLOW_MUL, -0.12)
trinketwep.PermitDismantle = true

-- 瞄准辅助器：-5%散布、-6%瞄准晃动，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_AimingAid"), "aimaid", false, develes, deweles, nil, ""..translate.Get("Inventory_Trinket_AimingAid_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_AIMSPREAD_MUL, -0.05)
GM:AddSkillModifier(trinket, SKILLMOD_AIM_SHAKE_MUL, -0.06)
trinketwep.PermitDismantle = true

-- 维生素胶囊：+5生命、-12%毒素伤害，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_VitaminCapsules"), "vitamins", false, hpveles, hpweles, nil, ""..translate.Get("Inventory_Trinket_VitaminCapsules_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_HEALTH, 5)
GM:AddSkillModifier(trinket, SKILLMOD_POISON_DAMAGE_TAKEN_MUL, -0.12)
trinketwep.PermitDismantle = true

-- 福利护盾：-5%补给延迟、-7%自我伤害，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_WelfareShield"), "welfare", false, hpveles, hpweles, nil, ""..translate.Get("Inventory_Trinket_WelfareShield_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_RESUPPLY_DELAY_MUL, -0.05)
GM:AddSkillModifier(trinket, SKILLMOD_SELF_DAMAGE_MUL, -0.07)
trinketwep.PermitDismantle = true

-- 化学套装：+6%医疗包效果、+12%治疗云持续时间，可拆解
trinket, trinketwep = GM:AddTrinket(""..translate.Get("Inventory_Trinket_ChemistrySet"), "chemistry", false, hpveles, hpweles, nil, ""..translate.Get("Inventory_Trinket_ChemistrySet_desc"))
GM:AddSkillModifier(trinket, SKILLMOD_MEDKIT_EFFECTIVENESS_MUL, 0.06)
GM:AddSkillModifier(trinket, SKILLMOD_CLOUD_TIME, 0.12)
trinketwep.PermitDismantle = true
