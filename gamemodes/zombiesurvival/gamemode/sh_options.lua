GM.ZombieEscapeWeaponsPrimary = {
	"weapon_zs_zeakbar",
	"weapon_zs_zesweeper",
	"weapon_zs_zesmg",
	"weapon_zs_zeinferno",
	"weapon_zs_zestubber",
	"weapon_zs_zebulletstorm",
	"weapon_zs_zesilencer",
	"weapon_zs_zequicksilver",
	"weapon_zs_zeamigo",
	"weapon_zs_zem4"
}

GM.ZombieEscapeWeaponsSecondary = {
	"weapon_zs_zedeagle",
	"weapon_zs_zebattleaxe",
	"weapon_zs_zeeraser",
	"weapon_zs_zeglock",
	"weapon_zs_zetempest"
}

-- Change this if you plan to alter the cost of items or you severely change how Worth works.
-- Having separate cart files allows people to have separate loadouts for different servers.
GM.CartFile = "zscarts.txt"
GM.SkillLoadoutsFile = "zsskloadouts.txt"

ITEMCAT_GUNS = 1
ITEMCAT_AMMO = 2
ITEMCAT_MELEE = 3
ITEMCAT_TOOLS = 4
ITEMCAT_DEPLOYABLES = 5
ITEMCAT_TRINKETS = 6
ITEMCAT_OTHER = 7
ITEMCAT_MUTATIONS = 8 --后面添加这两个
ITEMCAT_MUTATIONS_BOSS = 9 --后面添加这两个，数字要改成按顺序的

ITEMSUBCAT_TRINKETS_DEFENSIVE = 1
ITEMSUBCAT_TRINKETS_OFFENSIVE = 2
ITEMSUBCAT_TRINKETS_MELEE = 3
ITEMSUBCAT_TRINKETS_PERFORMANCE = 4
ITEMSUBCAT_TRINKETS_SUPPORT = 5
ITEMSUBCAT_TRINKETS_SPECIAL = 6

GM.ItemCategories = { --找到同名表，复制覆盖，或者只添加有标记的这两个
    [ITEMCAT_GUNS] = ""..translate.Get("arsenal_itemcat_Guns"),
    [ITEMCAT_AMMO] = ""..translate.Get("arsenal_itemcat_Ammo"),
    [ITEMCAT_MELEE] = ""..translate.Get("arsenal_itemcat_Melee"),
    [ITEMCAT_TOOLS] = ""..translate.Get("arsenal_itemcat_Tools"),
    [ITEMCAT_DEPLOYABLES] = ""..translate.Get("arsenal_itemcat_Deployables"),
    [ITEMCAT_TRINKETS] = ""..translate.Get("arsenal_itemcat_Trinkets"),
    [ITEMCAT_OTHER] = ""..translate.Get("arsenal_itemcat_Other"),
    [ITEMCAT_MUTATIONS] = ""..translate.Get("arsenal_itemcat_Mutations"), --标记
    [ITEMCAT_MUTATIONS_BOSS] = ""..translate.Get("arsenal_itemcat_MutationsBoss"), --标记
}


GM.ItemSubCategories = {
    [ITEMSUBCAT_TRINKETS_DEFENSIVE] = ""..translate.Get("arsenal_itemsubcat_Defensive"),
    [ITEMSUBCAT_TRINKETS_OFFENSIVE] = ""..translate.Get("arsenal_itemsubcat_Offensive"),
    [ITEMSUBCAT_TRINKETS_MELEE] = ""..translate.Get("arsenal_itemsubcat_Melee"),
    [ITEMSUBCAT_TRINKETS_PERFORMANCE] = ""..translate.Get("arsenal_itemsubcat_Performance"),
    [ITEMSUBCAT_TRINKETS_SUPPORT] = ""..translate.Get("arsenal_itemsubcat_Support"),
    [ITEMSUBCAT_TRINKETS_SPECIAL] = ""..translate.Get("arsenal_itemsubcat_Special")
}

--[[
Humans select what weapons (or other things) they want to start with and can even save favorites. Each object has a number of 'Worth' points.
Signature is a unique signature to give in case the item is renamed or reordered. Don't use a number or a string number!
A human can only use 100 points (default) when they join. Redeeming or joining late starts you out with a random loadout from above.
SWEP is a swep given when the player spawns with that perk chosen.
Callback is a function called. Model is a display model. If model isn't defined then the SWEP model will try to be used.
swep, callback, and model can all be nil or empty
]]
GM.Items = {}
function GM:AddItem(signature, category, price, swep, name, desc, model, callback)
	local tab = {Signature = signature, Name = name or "?", Description = desc, Category = category, Price = price or 0, SWEP = swep, Callback = callback, Model = model}

	tab.Worth = tab.Price -- compat

	self.Items[#self.Items + 1] = tab
	self.Items[signature] = tab

	return tab
end

function GM:AddStartingItem(signature, category, price, swep, name, desc, model, callback)
	local item = self:AddItem(signature, category, price, swep, name, desc, model, callback)
	item.WorthShop = true

	return item
end

function GM:AddPointShopItem(signature, category, price, swep, name, desc, model, callback)
	local item = self:AddItem("ps_"..signature, category, price, swep, name, desc, model, callback)
	item.PointShop = true

	return item
end

GM.Mutations = {}
function GM:AddMutation(signature, name, desc, category, worth, swep, callback, model, worthshop, mutationshop)
	local tab = {Signature = signature, Name = name, Description = desc, Category = category, Worth = worth or 0, SWEP = swep, Callback = callback, Model = model, WorthShop = worthshop, MutationShop = mutationshop}
	self.Mutations[#self.Mutations + 1] = tab

	return tab
end

function GM:AddMutationItem(signature, name, desc, category, brains, worth, callback, model)
	return self:AddMutation(signature, name, desc, category, brains, worth, callback, model, false, true)
end

-- Weapons are registered after the gamemode.
timer.Simple(0, function()
	for _, tab in pairs(GAMEMODE.Items) do
		if not tab.Description and tab.SWEP then
			local sweptab = weapons.GetStored(tab.SWEP)
			if sweptab then
				tab.Description = sweptab.Description
			end
		end
	end
end)

-- 可以从补给箱获得的弹药物品数量
GM.AmmoCache = {}
GM.AmmoCache["ar2"]							= 135		--突击步枪弹药
GM.AmmoCache["alyxgun"]						= 24		-- Not used.
GM.AmmoCache["pistol"]						= 60		--手枪弹药
GM.AmmoCache["smg1"]						= 135		 -- 冲锋枪弹药
GM.AmmoCache["357"]							= 30			 --狙击类弹药
GM.AmmoCache["xbowbolt"]					= 30			--弩箭弹药
GM.AmmoCache["buckshot"]					= 48		-- 霰弹枪弹药
GM.AmmoCache["ar2altfire"]					= 2			-- Not used.
GM.AmmoCache["slam"]						= 3			-- 地雷弹药
GM.AmmoCache["rpg_round"]					= 2			-- Not used. Rockets?
GM.AmmoCache["smg1_grenade"]				= 2			-- Not used.
GM.AmmoCache["sniperround"]					= 2			-- Barricade Kit
GM.AmmoCache["sniperpenetratedround"]		= 1			-- Remote Det pack.
GM.AmmoCache["grenade"]						= 1			-- Grenades.
GM.AmmoCache["thumper"]						= 1			-- Gun turret.
GM.AmmoCache["gravity"]						= 1			-- Unused.
GM.AmmoCache["battery"]						= 90		-- 医疗弹药
GM.AmmoCache["gaussenergy"]					= 6			--钉子
GM.AmmoCache["combinecannon"]				= 1			-- Not used.
GM.AmmoCache["airboatgun"]					= 1			-- Arsenal crates.
GM.AmmoCache["striderminigun"]				= 1			-- Message beacons.
GM.AmmoCache["helicoptergun"]				= 1			-- Resupply boxes.
GM.AmmoCache["spotlamp"]					= 1
GM.AmmoCache["manhack"]						= 1
GM.AmmoCache["repairfield"]					= 1
GM.AmmoCache["medicfield"]					= 1
GM.AmmoCache["zapper"]						= 1
GM.AmmoCache["pulse"]						= 135
GM.AmmoCache["impactmine"]					= 9			--爆炸弹药
GM.AmmoCache["chemical"]					= 40
GM.AmmoCache["flashbomb"]					= 1
GM.AmmoCache["turret_buckshot"]				= 1
GM.AmmoCache["turret_assault"]				= 1
GM.AmmoCache["scrap"]						= 12

GM.AmmoResupply = table.ToAssoc({"ar2", "pistol", "smg1", "357", "xbowbolt", "buckshot", "battery", "pulse", "impactmine", "chemical", "gaussenergy", "scrap"})

-----------
-- worth --
-----------

GM:AddStartingItem("pshtr",				ITEMCAT_GUNS,			40,				"weapon_zs_peashooter")
GM:AddStartingItem("btlax",				ITEMCAT_GUNS,			40,				"weapon_zs_battleaxe")
GM:AddStartingItem("owens",				ITEMCAT_GUNS,			40,				"weapon_zs_owens")
GM:AddStartingItem("blstr",				ITEMCAT_GUNS,			40,				"weapon_zs_blaster")
GM:AddStartingItem("tossr",				ITEMCAT_GUNS,			40,				"weapon_zs_tosser")
GM:AddStartingItem("stbbr",				ITEMCAT_GUNS,			40,				"weapon_zs_stubber")
GM:AddStartingItem("crklr",				ITEMCAT_GUNS,			40,				"weapon_zs_crackler")
--GM:AddStartingItem("sling",				ITEMCAT_GUNS,			40,				"weapon_zs_slinger")
GM:AddStartingItem("handgrenade",		ITEMCAT_GUNS,			60,				"weapon_zs_handgrenade")

GM:AddStartingItem("z9000",				ITEMCAT_GUNS,			40,				"weapon_zs_z9000")
GM:AddStartingItem("minelayer",			ITEMCAT_GUNS,			70,				"weapon_zs_minelayer")
--GM:AddStartingItem("qiyuanm4",			ITEMCAT_GUNS,			0,				"weapon_zs_stm4") --起源M4
--GM:AddStartingItem("qiyuanDeagle",		ITEMCAT_GUNS,			0,				"weapon_zs_superde") --一起源沙鹰

GM:AddStartingItem("2pcp", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_28PistolAmmo"), nil, "ammo_pistol", function(pl) pl:GiveAmmo(28, "pistol", true) end)
GM:AddStartingItem("3pcp", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_42PistolAmmo"), nil, "ammo_pistol", function(pl) pl:GiveAmmo(42, "pistol", true) end)
GM:AddStartingItem("2sgcp", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_24ShotgunAmmo"), nil, "ammo_shotgun", function(pl) pl:GiveAmmo(24, "buckshot", true) end)
GM:AddStartingItem("3sgcp", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_36ShotgunAmmo"), nil, "ammo_shotgun", function(pl) pl:GiveAmmo(36, "buckshot", true) end)
GM:AddStartingItem("2smgcp", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_72SMGAmmo"), nil, "ammo_smg", function(pl) pl:GiveAmmo(72, "smg1", true) end)
GM:AddStartingItem("3smgcp", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_108SMGAmmo"), nil, "ammo_smg", function(pl) pl:GiveAmmo(108, "smg1", true) end)
GM:AddStartingItem("2arcp", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_64AssaultRifleAmmo"), nil, "ammo_assault", function(pl) pl:GiveAmmo(64, "ar2", true) end)
GM:AddStartingItem("3arcp", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_96AssaultRifleAmmo"), nil, "ammo_assault", function(pl) pl:GiveAmmo(96, "ar2", true) end)
GM:AddStartingItem("2rcp", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_16RifleAmmo"), nil, "ammo_rifle", function(pl) pl:GiveAmmo(16, "357", true) end)
GM:AddStartingItem("3rcp", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_24RifleAmmo"), nil, "ammo_rifle", function(pl) pl:GiveAmmo(24, "357", true) end)
GM:AddStartingItem("2pls", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_60PulseAmmo"), nil, "ammo_pulse", function(pl) pl:GiveAmmo(60, "pulse", true) end)
GM:AddStartingItem("3pls", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_90PulseAmmo"), nil, "ammo_pulse", function(pl) pl:GiveAmmo(90, "pulse", true) end)
GM:AddStartingItem("xbow1", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_16CrossbowBolts"), nil, "ammo_bolts", function(pl) pl:GiveAmmo(16, "XBowBolt", true) end)
GM:AddStartingItem("xbow2", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_24CrossbowBolts"), nil, "ammo_bolts", function(pl) pl:GiveAmmo(24, "XBowBolt", true) end)
GM:AddStartingItem("4mines", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_6Explosives"), nil, "ammo_explosive", function(pl) pl:GiveAmmo(6, "impactmine", true) end)
GM:AddStartingItem("6mines", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_9Explosives"), nil, "ammo_explosive", function(pl) pl:GiveAmmo(9, "impactmine", true) end)
GM:AddStartingItem("8nails", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_8Nails"), nil, "ammo_nail", function(pl) pl:GiveAmmo(8, "GaussEnergy", true) end)
GM:AddStartingItem("12nails", ITEMCAT_AMMO, 20, nil, translate.Get("arsenal_item_12Nails"), nil, "ammo_nail", function(pl) pl:GiveAmmo(12, "GaussEnergy", true) end)
GM:AddStartingItem("60mkit", ITEMCAT_AMMO, 15, nil, translate.Get("arsenal_item_60MedicalPower"), nil, "ammo_medpower", function(pl) pl:GiveAmmo(60, "Battery", true) end)
GM:AddStartingItem("90mkit", ITEMCAT_AMMO, 25, nil, translate.Get("arsenal_item_90MedicalPower"), nil, "ammo_medpower", function(pl) pl:GiveAmmo(90, "Battery", true) end)

 
GM:AddStartingItem("brassknuckles",		ITEMCAT_MELEE,			20,				"weapon_zs_brassknuckles").Model = "models/props_c17/utilityconnecter005.mdl"
GM:AddStartingItem("zpaxe",				ITEMCAT_MELEE,			40,				"weapon_zs_axe")
GM:AddStartingItem("crwbar",			ITEMCAT_MELEE,			40,				"weapon_zs_crowbar")
GM:AddStartingItem("stnbtn",			ITEMCAT_MELEE,			40,				"weapon_zs_stunbaton")
GM:AddStartingItem("csknf",				ITEMCAT_MELEE,			20,				"weapon_zs_swissarmyknife")
GM:AddStartingItem("zpplnk",			ITEMCAT_MELEE,			20,				"weapon_zs_plank")
GM:AddStartingItem("zpfryp",			ITEMCAT_MELEE,			30,				"weapon_zs_fryingpan")
GM:AddStartingItem("zpcpot",			ITEMCAT_MELEE,			30,				"weapon_zs_pot")
GM:AddStartingItem("ladel",				ITEMCAT_MELEE,			30,				"weapon_zs_ladel")
GM:AddStartingItem("pipe",				ITEMCAT_MELEE,			40,				"weapon_zs_pipe")
GM:AddStartingItem("hook",				ITEMCAT_MELEE,			40,				"weapon_zs_hook")

local item
GM:AddStartingItem("medkit",			ITEMCAT_TOOLS,			40,				"weapon_zs_medicalkit")
GM:AddStartingItem("medgun",			ITEMCAT_TOOLS,			50,				"weapon_zs_medicgun")
item =
GM:AddStartingItem("strengthshot",		ITEMCAT_TOOLS,			40,				"weapon_zs_strengthshot")
item.SkillRequirement = SKILL_U_STRENGTHSHOT
item =
GM:AddStartingItem("antidoteshot",		ITEMCAT_TOOLS,			40,				"weapon_zs_antidoteshot")
item.SkillRequirement = SKILL_U_ANTITODESHOT
GM:AddStartingItem("arscrate",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_arsenalcrate")
.Countables = "prop_arsenalcrate"
GM:AddStartingItem("resupplybox",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_resupplybox")
.Countables = "prop_resupplybox"
GM:AddStartingItem("remantler",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_remantler")
.Countables = "prop_remantler"
item =
GM:AddStartingItem("infturret",			ITEMCAT_DEPLOYABLES,			75,				"weapon_zs_gunturret",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret") pl:GiveAmmo(1, "thumper") pl:GiveAmmo(125, "smg1") end)
item.Countables = "prop_gunturret"
item.NoClassicMode = true
item =
GM:AddStartingItem("blastturret",		ITEMCAT_DEPLOYABLES,			70,				"weapon_zs_gunturret_buckshot",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_buckshot") pl:GiveAmmo(1, "turret_buckshot") pl:GiveAmmo(30, "buckshot") end)
item.Countables = "prop_gunturret_buckshot"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_BLASTTURRET
item =
GM:AddStartingItem("repairfield",		ITEMCAT_DEPLOYABLES,			60,				"weapon_zs_repairfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_repairfield") pl:GiveAmmo(1, "repairfield") pl:GiveAmmo(50, "pulse") end)
item.Countables = "prop_repairfield"
item.NoClassicMode = true
item =
GM:AddStartingItem("medicfield",		ITEMCAT_DEPLOYABLES,			60,				"weapon_zs_medicfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_medicfield") pl:GiveAmmo(1, "medicfield") pl:GiveAmmo(50, "Battery") end)
item.Countables = "prop_medicfield"
item.NoClassicMode = true
item =
GM:AddStartingItem("zapper",			ITEMCAT_DEPLOYABLES,			75,				"weapon_zs_zapper",				nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_zapper") pl:GiveAmmo(1, "zapper") pl:GiveAmmo(50, "pulse") end)
item.Countables = "prop_zapper"
item.NoClassicMode = true

GM:AddStartingItem("manhack",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_manhack").Countables = "prop_manhack"
item =
GM:AddStartingItem("drone",				ITEMCAT_DEPLOYABLES,			55,				"weapon_zs_drone",				nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_drone") pl:GiveAmmo(1, "drone") pl:GiveAmmo(60, "smg1") end)
item.Countables = "prop_drone"
item =
GM:AddStartingItem("pulsedrone",		ITEMCAT_DEPLOYABLES,			55,				"weapon_zs_drone_pulse",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_drone_pulse") pl:GiveAmmo(1, "pulse_cutter") pl:GiveAmmo(60, "pulse") end)
item.Countables = "prop_drone_pulse"
item.SkillRequirement = SKILL_U_DRONE
item =
GM:AddStartingItem("hauldrone",			ITEMCAT_DEPLOYABLES,			25,				"weapon_zs_drone_hauler",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_drone_hauler") pl:GiveAmmo(1, "drone_hauler") end)
item.Countables = "prop_drone_hauler"
item.SkillRequirement = SKILL_HAULMODULE
item =
GM:AddStartingItem("rollermine",		ITEMCAT_DEPLOYABLES,			65,				"weapon_zs_rollermine",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_rollermine") pl:GiveAmmo(1, "rollermine") end)
item.Countables = "prop_rollermine"
item.SkillRequirement = SKILL_U_ROLLERMINE

GM:AddStartingItem("wrench",			ITEMCAT_TOOLS,			20,				"weapon_zs_wrench").NoClassicMode = true
GM:AddStartingItem("crphmr",			ITEMCAT_TOOLS,			40,				"weapon_zs_hammer").NoClassicMode = true
GM:AddStartingItem("junkpack",			ITEMCAT_DEPLOYABLES,	30,				"weapon_zs_boardpack")
GM:AddStartingItem("propanetank",		ITEMCAT_TOOLS,			30,				"comp_propanecan")
GM:AddStartingItem("busthead",			ITEMCAT_TOOLS,			35,				"comp_busthead")
GM:AddStartingItem("sawblade",			ITEMCAT_TOOLS,			35,				"comp_sawblade").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:AddStartingItem("cpuparts",			ITEMCAT_TOOLS,			35,				"comp_cpuparts").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:AddStartingItem("electrobattery",	ITEMCAT_TOOLS,			45,				"comp_electrobattery").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:AddStartingItem("msgbeacon",			ITEMCAT_DEPLOYABLES,			10,				"weapon_zs_messagebeacon").Countables = "prop_messagebeacon"
item =
GM:AddStartingItem("ffemitter",			ITEMCAT_DEPLOYABLES,			45,				"weapon_zs_ffemitter",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_ffemitter") pl:GiveAmmo(1, "slam") pl:GiveAmmo(50, "pulse") end)
item.Countables = "prop_ffemitter"
GM:AddStartingItem("barricadekit",		ITEMCAT_DEPLOYABLES,			80,				"weapon_zs_barricadekit")
GM:AddStartingItem("camera",			ITEMCAT_DEPLOYABLES,			15,				"weapon_zs_camera").Countables = "prop_camera"
GM:AddStartingItem("tv",				ITEMCAT_DEPLOYABLES,			35,				"weapon_zs_tv").Countables = "prop_tv"

GM:AddStartingItem("oxtank",			ITEMCAT_TRINKETS,		5,				"trinket_oxygentank").SubCategory =				ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddStartingItem("boxingtraining",	ITEMCAT_TRINKETS,		10,				"trinket_boxingtraining").SubCategory =			ITEMSUBCAT_TRINKETS_MELEE
GM:AddStartingItem("cutlery",			ITEMCAT_TRINKETS,		10,				"trinket_cutlery").SubCategory =				ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddStartingItem("portablehole",		ITEMCAT_TRINKETS,		10,				"trinket_portablehole").SubCategory =			ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddStartingItem("acrobatframe",		ITEMCAT_TRINKETS,		15,				"trinket_acrobatframe").SubCategory=			ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddStartingItem("nightvision",		ITEMCAT_TRINKETS,		15,				"trinket_nightvision").SubCategory =			ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddStartingItem("targetingvisi",		ITEMCAT_TRINKETS,		15,				"trinket_targetingvisori").SubCategory =		ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddStartingItem("pulseampi",			ITEMCAT_TRINKETS,		15,				"trinket_pulseampi").SubCategory =				ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddStartingItem("blueprintsi",		ITEMCAT_TRINKETS,		15,				"trinket_blueprintsi").SubCategory =			ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddStartingItem("loadingframe",		ITEMCAT_TRINKETS,		15,				"trinket_loadingex").SubCategory =				ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddStartingItem("kevlar",			ITEMCAT_TRINKETS,		15,				"trinket_kevlar").SubCategory =					ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddStartingItem("momentumsupsysii",	ITEMCAT_TRINKETS,		15,				"trinket_momentumsupsysii").SubCategory =		ITEMSUBCAT_TRINKETS_MELEE
GM:AddStartingItem("hemoadrenali",		ITEMCAT_TRINKETS,		15,				"trinket_hemoadrenali").SubCategory =			ITEMSUBCAT_TRINKETS_MELEE
GM:AddStartingItem("vitpackagei",		ITEMCAT_TRINKETS,		20,				"trinket_vitpackagei").SubCategory =			ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddStartingItem("processor",			ITEMCAT_TRINKETS,		20,				"trinket_processor").SubCategory =				ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddStartingItem("cardpackagei",		ITEMCAT_TRINKETS,		20,				"trinket_cardpackagei").SubCategory =			ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddStartingItem("bloodpack",			ITEMCAT_TRINKETS,		20,				"trinket_bloodpack").SubCategory =				ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddStartingItem("biocleanser",		ITEMCAT_TRINKETS,		20,				"trinket_biocleanser").SubCategory =			ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddStartingItem("reactiveflasher",	ITEMCAT_TRINKETS,		25,				"trinket_reactiveflasher").SubCategory =		ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddStartingItem("magnet",			ITEMCAT_TRINKETS,		25,				"trinket_magnet").SubCategory =					ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddStartingItem("arsenalpack",		ITEMCAT_TRINKETS,		55,				"trinket_arsenalpack").SubCategory =			ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddStartingItem("resupplypack",		ITEMCAT_TRINKETS,		55,				"trinket_resupplypack").SubCategory =			ITEMSUBCAT_TRINKETS_SUPPORT

GM:AddStartingItem("stone",				ITEMCAT_OTHER,			10,				"weapon_zs_stone")
GM:AddStartingItem("grenade",			ITEMCAT_OTHER,			30,				"weapon_zs_grenade")
GM:AddStartingItem("flashbomb",			ITEMCAT_OTHER,			15,				"weapon_zs_flashbomb")
GM:AddStartingItem("molotov",			ITEMCAT_OTHER,			30,				"weapon_zs_molotov")
GM:AddStartingItem("betty",				ITEMCAT_OTHER,			30,				"weapon_zs_proxymine")
GM:AddStartingItem("corgasgrenade",		ITEMCAT_OTHER,			40,				"weapon_zs_corgasgrenade")
GM:AddStartingItem("crygasgrenade",		ITEMCAT_OTHER,			35,				"weapon_zs_crygasgrenade").SkillRequirement = SKILL_U_CRYGASGREN
GM:AddStartingItem("detpck",			ITEMCAT_OTHER,			35,				"weapon_zs_detpack").Countables = "prop_detpack"
item =
GM:AddStartingItem("sigfragment",		ITEMCAT_OTHER,			25,				"weapon_zs_sigilfragment")
item.NoClassicMode = true
item =
GM:AddStartingItem("corfragment",		ITEMCAT_OTHER,			35,				"weapon_zs_corruptedfragment")
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_CORRUPTEDFRAGMENT
item =
GM:AddStartingItem("medcloud",			ITEMCAT_OTHER,			35,				"weapon_zs_mediccloudbomb")
item.SkillRequirement = SKILL_U_MEDICCLOUD
item =
GM:AddStartingItem("nanitecloud",		ITEMCAT_OTHER,			35,				"weapon_zs_nanitecloudbomb")
item.SkillRequirement = SKILL_U_NANITECLOUD
GM:AddStartingItem("bloodshot",			ITEMCAT_OTHER,			35,				"weapon_zs_bloodshotbomb")

------------
-- Points --
------------

-- Tier 1
GM:AddPointShopItem("pshtr",			ITEMCAT_GUNS,			15,				"weapon_zs_peashooter", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_peashooter") end)
GM:AddPointShopItem("btlax",			ITEMCAT_GUNS,			15,				"weapon_zs_battleaxe", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_battleaxe") end)
GM:AddPointShopItem("owens",			ITEMCAT_GUNS,			15,				"weapon_zs_owens", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_owens") end)
GM:AddPointShopItem("blstr",			ITEMCAT_GUNS,			15,				"weapon_zs_blaster", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_blaster") end)
GM:AddPointShopItem("tossr",			ITEMCAT_GUNS,			15,				"weapon_zs_tosser", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_tosser") end)
GM:AddPointShopItem("stbbr",			ITEMCAT_GUNS,			15,				"weapon_zs_stubber", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_stubber") end)
GM:AddPointShopItem("crklr",			ITEMCAT_GUNS,			15,				"weapon_zs_crackler", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_crackler") end)
--GM:AddPointShopItem("sling",			ITEMCAT_GUNS,			15,				"weapon_zs_slinger", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_slinger") end) --weapon_zs_handgrenade

GM:AddPointShopItem("z9000",			ITEMCAT_GUNS,			15,				"weapon_zs_z9000", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_z9000") end)
GM:AddPointShopItem("handgrenade",		ITEMCAT_GUNS,			20,				"weapon_zs_handgrenade")
GM:AddPointShopItem("minelayer",		ITEMCAT_GUNS,			20,				"weapon_zs_minelayer", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_minelayer") end)
-- Tier 2
GM:AddPointShopItem("glock3",			ITEMCAT_GUNS,			35,				"weapon_zs_glock3")
GM:AddPointShopItem("magnum",			ITEMCAT_GUNS,			35,				"weapon_zs_magnum")
--GM:AddPointShopItem("eraser",			ITEMCAT_GUNS,			35,				"weapon_zs_eraser")
GM:AddPointShopItem("aldarhtf",			ITEMCAT_GUNS,			35,				"weapon_zs_htf_amt")
GM:AddPointShopItem("sawedoff",			ITEMCAT_GUNS,			35,				"weapon_zs_sawedoff")
GM:AddPointShopItem("autoshot",			ITEMCAT_GUNS,			35,				"weapon_zs_autoshotgun")
GM:AddPointShopItem("uzi",				ITEMCAT_GUNS,			35,				"weapon_zs_uzi")
GM:AddPointShopItem("annabelle",		ITEMCAT_GUNS,			35,				"weapon_zs_annabelle")
GM:AddPointShopItem("inquisitor",		ITEMCAT_GUNS,			35,				"weapon_zs_inquisitor")
GM:AddPointShopItem("amigo",			ITEMCAT_GUNS,			35,				"weapon_zs_amigo")
GM:AddPointShopItem("hurricane",		ITEMCAT_GUNS,			35,				"weapon_zs_hurricane")
-- Tier 3
GM:AddPointShopItem("deagle",			ITEMCAT_GUNS,			60,				"weapon_zs_deagle")
GM:AddPointShopItem("tempest",			ITEMCAT_GUNS,			60,				"weapon_zs_tempest")
--GM:AddPointShopItem("ender",			ITEMCAT_GUNS,			60,				"weapon_zs_ender")
GM:AddPointShopItem("sg15",			    ITEMCAT_GUNS,			60,				"weapon_zs_htf_sg15")
GM:AddPointShopItem("shredder",			ITEMCAT_GUNS,			60,				"weapon_zs_smg")
GM:AddPointShopItem("silencer",			ITEMCAT_GUNS,			60,				"weapon_zs_silencer")
GM:AddPointShopItem("hunter",			ITEMCAT_GUNS,			60,				"weapon_zs_hunter")
GM:AddPointShopItem("onyx",				ITEMCAT_GUNS,			60,				"weapon_zs_onyx")
GM:AddPointShopItem("charon",			ITEMCAT_GUNS,			60,				"weapon_zs_charon")
GM:AddPointShopItem("akbar",			ITEMCAT_GUNS,			60,				"weapon_zs_akbar")
GM:AddPointShopItem("enderp",			ITEMCAT_GUNS,			60,				"weapon_zs_enderp")
GM:AddPointShopItem("oberon",			ITEMCAT_GUNS,			60,				"weapon_zs_oberon")
GM:AddPointShopItem("hyena",			ITEMCAT_GUNS,			60,				"weapon_zs_hyena")
GM:AddPointShopItem("pollutor",			ITEMCAT_GUNS,			60,				"weapon_zs_pollutor")

-- Tier 4

GM:AddPointShopItem("longarm",			ITEMCAT_GUNS,			100,			"weapon_zs_longarm")
GM:AddPointShopItem("dag",		    	ITEMCAT_GUNS,			100,			"weapon_zs_dag")
GM:AddPointShopItem("sweeper",			ITEMCAT_GUNS,			100,			"weapon_zs_sweepershotgun")
GM:AddPointShopItem("jackhammer",		ITEMCAT_GUNS,			100,			"weapon_zs_jackhammer")
GM:AddPointShopItem("epsilon",		    ITEMCAT_GUNS,			100,			"weapon_zs_epsilon_shotgun")
GM:AddPointShopItem("bulletstorm",		ITEMCAT_GUNS,			100,			"weapon_zs_bulletstorm")
GM:AddPointShopItem("reaper",			ITEMCAT_GUNS,			100,			"weapon_zs_reaper")
GM:AddPointShopItem("quicksilver",		ITEMCAT_GUNS,			100,			"weapon_zs_quicksilver")
GM:AddPointShopItem("slugrifle",		ITEMCAT_GUNS,			100,			"weapon_zs_slugrifle")
GM:AddPointShopItem("artemis",			ITEMCAT_GUNS,			100,			"weapon_zs_artemis")
GM:AddPointShopItem("zeus",				ITEMCAT_GUNS,			100,			"weapon_zs_zeus")
GM:AddPointShopItem("stalker",			ITEMCAT_GUNS,			100,			"weapon_zs_m4")
GM:AddPointShopItem("inferno",			ITEMCAT_GUNS,			100,			"weapon_zs_inferno")
GM:AddPointShopItem("ebanator",			ITEMCAT_GUNS,			115,			"weapon_zs_htf_ebanator")
GM:AddPointShopItem("quasar",			ITEMCAT_GUNS,			100,			"weapon_zs_quasar")
GM:AddPointShopItem("gluon",			ITEMCAT_GUNS,			100,			"weapon_zs_gluon")
GM:AddPointShopItem("barrage",			ITEMCAT_GUNS,			100,			"weapon_zs_barrage")

-- Tier 5
GM:AddPointShopItem("novacolt",			ITEMCAT_GUNS,			175,			"weapon_zs_novacolt")
GM:AddPointShopItem("bulwark",			ITEMCAT_GUNS,			175,			"weapon_zs_bulwark")
--GM:AddPointShopItem("juggernaut",		ITEMCAT_GUNS,			175,			"weapon_zs_juggernaut")
GM:AddPointShopItem("citadel",	    	ITEMCAT_GUNS,			175,			"weapon_zs_citadel")
--GM:AddPointShopItem("scar",				ITEMCAT_GUNS,			175,			"weapon_zs_scar")
GM:AddPointShopItem("nexus",			ITEMCAT_GUNS,		    175,			"weapon_zs_nexus")
GM:AddPointShopItem("tokamak",			ITEMCAT_GUNS,	    	175,			"weapon_zs_tokamak")
GM:AddPointShopItem("boomstick",		ITEMCAT_GUNS,			175,			"weapon_zs_boomstick")
GM:AddPointShopItem("deathdlrs",		ITEMCAT_GUNS,			175,			"weapon_zs_deathdealers")
GM:AddPointShopItem("hammerdown",		ITEMCAT_GUNS,			175,			"weapon_zs_hammerdown")
GM:AddPointShopItem("colossus",			ITEMCAT_GUNS,			175,			"weapon_zs_colossus")
GM:AddPointShopItem("renegade",			ITEMCAT_GUNS,			175,			"weapon_zs_renegade")
GM:AddPointShopItem("crossbow",			ITEMCAT_GUNS,			175,			"weapon_zs_crossbow")
GM:AddPointShopItem("pulserifle",		ITEMCAT_GUNS,			175,			"weapon_zs_pulserifle")
GM:AddPointShopItem("spinfusor",		ITEMCAT_GUNS,			175,			"weapon_zs_spinfusor")
GM:AddPointShopItem("broadside",		ITEMCAT_GUNS,			175,			"weapon_zs_broadside")
GM:AddPointShopItem("smelter",			ITEMCAT_GUNS,			175,			"weapon_zs_smelter")
GM:AddPointShopItem("magnum_a",			ITEMCAT_GUNS,			175,			"weapon_zs_magnum_a")
--GM:AddPointShopItem("hunter_bear",		ITEMCAT_GUNS,			175,			"weapon_zs_hunter_bear")
GM:AddPointShopItem("青峰",			    ITEMCAT_GUNS,			175,			"weapon_zs_electron")
--GM:AddPointShopItem("Eightyone",		ITEMCAT_GUNS,			175,			"weapon_zs_81")
GM:AddPointShopItem("vepr12",	    	ITEMCAT_GUNS,			175,			"weapon_zs_vepr12")
--GM:AddPointShopItem("m82a1",	    	ITEMCAT_GUNS,			175,			"weapon_zs_m82a3")


local AMMO_TYPES = {
    -- 格式：签名, 显示数量, 实际给予数量, 价格, 弹药类型, 名称翻译键, 模型后缀, 描述键, 描述参数, 特殊标记
    { "pistolammo",     20, 20,  5, "pistol",     "pistol",    "pistol" },
    { "shotgunammo",    16, 16,  5, "buckshot",   "shotgun",   "shotgun" },
    { "smgammo",        45, 45,  5, "smg1",       "smg",       "smg" },
    { "rifleammo",      10,  10,  5, "357",        "rifle",     "rifle" },
    { "crossbowammo",   10,  10,  5, "XBowBolt",   "bolts",     "bolts" },
    { "assaultrifleammo",45,45,  5, "ar2",        "assault",   "assault" },
    { "pulseammo",      45, 45,  5, "pulse",      "pulse",     "pulse" },
    { "impactmine",     3,  3,   5, "impactmine", "explosive", "explosive" },
    { "chemical",       20, 20,  5, "chemical",   "chemical",  "chemical" },
    { "scrap",          8,8,   14,"scrap",      "scrap",     "scrap", nil, nil, true }, -- 无数量显示
    { "25mkit",         30, 30,  8, "Battery",    "medpower",  "medpower", "medical_desc", {5}, true }, -- 医疗子弹
    { "nail",           2,  2,   1, "GaussEnergy","nail",      "nail",    "nail_desc", nil, true, true }, -- 钉子
    { "pistolammo_x10",     200, 200,  52, "pistol",     "pistol",    "pistol" },
    { "shotgunammo_x10",    160, 160,  52, "buckshot",   "shotgun",   "shotgun" },
    { "smgammo_x10",        450, 450,  52, "smg1",       "smg",       "smg" },
    { "rifleammo_x10",      100,  100,  52, "357",        "rifle",     "rifle" },
    { "crossbowammo_x10",   100,  100,  52, "XBowBolt",   "bolts",     "bolts" },
    { "assaultrifleammo_x10",450,450,  52, "ar2",        "assault",   "assault" },
    { "pulseammo_x10",      450, 450,  52, "pulse",      "pulse",     "pulse" },
    { "impactmine_x10",     30,  30,   52, "impactmine", "explosive", "explosive" },
    { "chemical_x10",       200, 200,  52, "chemical",   "chemical",  "chemical" },
    { "scrap_x5",       40, 40,  60, "scrap",   "scrap",  "scrap", nil, nil, true },
    { "nail_x5",           10,  10,   6, "GaussEnergy","nail",      "nail",    "nail_desc", nil, true, true }, -- 钉子
    { "25mkit_x10",         300, 300,  82, "Battery",    "medpower",  "medpower", "medical_desc", {5}, true }, -- 医疗子弹
}

local function CreateAmmoGenerator()
    -- 遍历 AMMO_TYPES 表中的所有弹药类型数据
    for _, data in ipairs(AMMO_TYPES) do
        -- 解包弹药数据
        local sig, disp_amt, give_amt, price, ammo_type, name_key, model_suffix, desc_key, desc_args, is_scrap, is_nail = unpack(data)
        
        -- 生成弹药的显示名称
        -- 如果 disp_amt 存在，则使用格式化字符串生成名称，格式为 "弹药类型 x 数量"
        -- 否则直接使用弹药类型的翻译名称
        local name = disp_amt and translate.Format(
            "arsenal_ammo_entry", 
            translate.Get("ammo_type_"..name_key), -- 弹药类型名称
            disp_amt                              -- 弹药数量
        ) or translate.Get("ammo_type_"..name_key) -- 直接使用弹药类型名称
        
        -- 生成弹药的描述
        local desc
        if desc_key then
            -- 如果 desc_key 存在，则根据是否有 desc_args 决定如何生成描述
            desc = desc_args and translate.Format("arsenal_ammo_"..desc_key, unpack(desc_args)) -- 带参数的描述
                or translate.Get("arsenal_ammo_"..desc_key) -- 不带参数的描述
        end
        
        -- 创建商店项
        local item = GAMEMODE:AddPointShopItem(
            sig,                -- 弹药唯一标识符
            ITEMCAT_AMMO,       -- 物品分类（弹药）
            price,             -- 弹药价格
            nil,               -- 关联的武器（无）
            name,              -- 显示名称
            desc,              -- 描述
            "ammo_"..model_suffix, -- 模型路径
            function(pl) 
                -- 回调函数：当玩家购买弹药时，给予玩家指定类型和数量的弹药
                pl:GiveAmmo(give_amt, ammo_type, true) 
            end
        )
        
        -- 设置弹药的特殊属性
        if is_scrap then
            -- 如果弹药可以从废料制作，则标记为可制作
            item.CanMakeFromScrap = true
        end
        if is_nail then
            -- 如果弹药是钉子类型，则标记为不在经典模式中使用，且可以从废料制作
            item.NoClassicMode = true
            item.CanMakeFromScrap = true
        end
    end
end


-- 初始化时调用
hook.Add("Initialize", "LoadAmmoItems", CreateAmmoGenerator)
-- Tier 1
GM:AddPointShopItem("brassknuckles",	ITEMCAT_MELEE,			10,				"weapon_zs_brassknuckles").Model = "models/props_c17/utilityconnecter005.mdl"
GM:AddPointShopItem("knife",			ITEMCAT_MELEE,			10,				"weapon_zs_swissarmyknife")
GM:AddPointShopItem("zpplnk",			ITEMCAT_MELEE,			10,				"weapon_zs_plank")
GM:AddPointShopItem("axe",				ITEMCAT_MELEE,			15,				"weapon_zs_axe")
GM:AddPointShopItem("zpfryp",			ITEMCAT_MELEE,			15,				"weapon_zs_fryingpan")
GM:AddPointShopItem("zpcpot",			ITEMCAT_MELEE,			15,				"weapon_zs_pot")
GM:AddPointShopItem("ladel",			ITEMCAT_MELEE,			15,				"weapon_zs_ladel")
GM:AddPointShopItem("crowbar",			ITEMCAT_MELEE,			15,				"weapon_zs_crowbar")
GM:AddPointShopItem("pipe",				ITEMCAT_MELEE,			15,				"weapon_zs_pipe")
GM:AddPointShopItem("stunbaton",		ITEMCAT_MELEE,			15,				"weapon_zs_stunbaton")
GM:AddPointShopItem("hook",				ITEMCAT_MELEE,			15,				"weapon_zs_hook")
-- Tier 2
GM:AddPointShopItem("broom",			ITEMCAT_MELEE,			30,				"weapon_zs_pushbroom")
GM:AddPointShopItem("shovel",			ITEMCAT_MELEE,			30,				"weapon_zs_shovel")
GM:AddPointShopItem("sledgehammer",		ITEMCAT_MELEE,			30,				"weapon_zs_sledgehammer")
GM:AddPointShopItem("harpoon",			ITEMCAT_MELEE,			30,				"weapon_zs_harpoon")
GM:AddPointShopItem("harpoon_te",		ITEMCAT_MELEE,			50,				"weapon_zs_harpoon_te")
GM:AddPointShopItem("teslakatana",		ITEMCAT_MELEE,			50,				"weapon_zs_teslakatana")
GM:AddPointShopItem("butcherknf",		ITEMCAT_MELEE,			30,				"weapon_zs_butcherknife")
-- Tier 3
GM:AddPointShopItem("longsword",		ITEMCAT_MELEE,			60,				"weapon_zs_longsword")
GM:AddPointShopItem("executioner",		ITEMCAT_MELEE,			60,				"weapon_zs_executioner")
GM:AddPointShopItem("rebarmace",		ITEMCAT_MELEE,			60,				"weapon_zs_rebarmace")
GM:AddPointShopItem("meattenderizer",	ITEMCAT_MELEE,			60,				"weapon_zs_meattenderizer")
GM:AddPointShopItem("katana",       	ITEMCAT_MELEE,			60,			    "weapon_zs_katana")
-- Tier 4
GM:AddPointShopItem("graveshvl",		ITEMCAT_MELEE,			100,			"weapon_zs_graveshovel")
GM:AddPointShopItem("kongol",			ITEMCAT_MELEE,			100,			"weapon_zs_kongolaxe")
GM:AddPointShopItem("scythe",			ITEMCAT_MELEE,			100,			"weapon_zs_scythe")
GM:AddPointShopItem("powerfists",		ITEMCAT_MELEE,			100,			"weapon_zs_powerfists")
GM:AddPointShopItem("energysword",		ITEMCAT_MELEE,			100,			"weapon_zs_energysword")

GM:AddPointShopItem("血狱之剑",         ITEMCAT_MELEE,			135,			"weapon_zs_firesword")            --将剑
GM:AddPointShopItem("黄金之剑",         ITEMCAT_MELEE,			135,			"weapon_firesword_x")            --金剑
-- Tier 5
GM:AddPointShopItem("frotchet",			ITEMCAT_MELEE,			150,			"weapon_zs_frotchet")
--GM:AddPointShopItem("harpoon_sp",		ITEMCAT_MELEE,			130,			"weapon_zs_harpoon_sp")
GM:AddPointShopItem("telepor",	    	ITEMCAT_MELEE,			160,			"weapon_zs_teleportationdagger")


GM:AddPointShopItem("suicideboom",			ITEMCAT_TOOLS,			100,				"weapon_zs_suicidebomb",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_suicidebomb") end)

GM:AddPointShopItem("crphmr_sp",			ITEMCAT_TOOLS,			65,				"weapon_zs_hammer_sp",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_hammer_sp") pl:GiveAmmo(5, "GaussEnergy") end)

GM:AddPointShopItem("crphmr",			ITEMCAT_TOOLS,			25,				"weapon_zs_hammer",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_hammer") pl:GiveAmmo(5, "GaussEnergy") end)
GM:AddPointShopItem("wrench",			ITEMCAT_TOOLS,			20,				"weapon_zs_wrench").NoClassicMode = true
GM:AddPointShopItem("arsenalcrate",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_arsenalcrate").Countables = "prop_arsenalcrate"
GM:AddPointShopItem("resupplybox",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_resupplybox").Countables = "prop_resupplybox"
GM:AddPointShopItem("remantler",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_remantler").Countables = "prop_remantler"
GM:AddPointShopItem("msgbeacon",		ITEMCAT_DEPLOYABLES,			10,				"weapon_zs_messagebeacon").Countables = "prop_messagebeacon"
GM:AddPointShopItem("camera",			ITEMCAT_DEPLOYABLES,			15,				"weapon_zs_camera").Countables = "prop_camera"
GM:AddPointShopItem("tv",				ITEMCAT_DEPLOYABLES,			25,				"weapon_zs_tv").Countables = "prop_tv"
item =
GM:AddPointShopItem("infturret",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_gunturret",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret") pl:GiveAmmo(1, "thumper") end)
item.NoClassicMode = true
item.Countables = "prop_gunturret"
item =
GM:AddPointShopItem("blastturret",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_gunturret_buckshot",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_buckshot") pl:GiveAmmo(1, "turret_buckshot") end)
item.Countables = "prop_gunturret_buckshot"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_BLASTTURRET
item =
GM:AddPointShopItem("assaultturret",	ITEMCAT_DEPLOYABLES,			125,			"weapon_zs_gunturret_assault",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_assault") pl:GiveAmmo(1, "turret_assault") end)
item.NoClassicMode = true
item.Countables = "prop_gunturret_assault"
item =
GM:AddPointShopItem("rocketturret",		ITEMCAT_DEPLOYABLES,			125,			"weapon_zs_gunturret_rocket",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_rocket") pl:GiveAmmo(1, "turret_rocket") end)
item.Countables = "prop_gunturret_rocket"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_ROCKETTURRET
GM:AddPointShopItem("manhack",			ITEMCAT_DEPLOYABLES,			30,				"weapon_zs_manhack").Countables = "prop_manhack"
item =
GM:AddPointShopItem("drone",			ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_drone")
item.Countables = "prop_drone"
item =
GM:AddPointShopItem("pulsedrone",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_drone_pulse")
item.Countables = "prop_drone_pulse"
item.SkillRequirement = SKILL_U_DRONE
item =
GM:AddPointShopItem("hauldrone",		ITEMCAT_DEPLOYABLES,			15,				"weapon_zs_drone_hauler")
item.Countables = "prop_drone_hauler"
item.SkillRequirement = SKILL_HAULMODULE
item =
GM:AddPointShopItem("rollermine",		ITEMCAT_DEPLOYABLES,			35,				"weapon_zs_rollermine")
item.Countables = "prop_rollermine"
item.SkillRequirement = SKILL_U_ROLLERMINE

item =
GM:AddPointShopItem("repairfield",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_repairfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_repairfield") pl:GiveAmmo(1, "repairfield") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_repairfield"
item.NoClassicMode = true

item =
GM:AddPointShopItem("medicfield",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_medicfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_medicfield") pl:GiveAmmo(1, "medicfield") pl:GiveAmmo(60, "Battery") end)
item.Countables = "prop_medicfield"
item.NoClassicMode = true

item =
GM:AddPointShopItem("zapper",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_zapper",				nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_zapper") pl:GiveAmmo(1, "zapper") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_zapper"
item.NoClassicMode = true
item =
GM:AddPointShopItem("zapper_arc",		ITEMCAT_DEPLOYABLES,			100,			"weapon_zs_zapper_arc",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_zapper_arc") pl:GiveAmmo(1, "zapper_arc") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_zapper_arc"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_ZAPPER_ARC
item =
GM:AddPointShopItem("ffemitter",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_ffemitter",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_ffemitter") pl:GiveAmmo(1, "slam") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_ffemitter"
GM:AddPointShopItem("propanetank",		ITEMCAT_TOOLS,			15,				"comp_propanecan")
GM:AddPointShopItem("busthead",			ITEMCAT_TOOLS,			25,				"comp_busthead")
GM:AddPointShopItem("sawblade",			ITEMCAT_TOOLS,			30,				"comp_sawblade").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:AddPointShopItem("cpuparts",			ITEMCAT_TOOLS,			30,				"comp_cpuparts").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:AddPointShopItem("electrobattery",	ITEMCAT_TOOLS,			40,				"comp_electrobattery").SkillRequirement = SKILL_U_CRAFTINGPACK
GM:AddPointShopItem("barricadekit",		ITEMCAT_DEPLOYABLES,	60,				"weapon_zs_barricadekit") --宙斯盾
GM:AddPointShopItem("medkit",			ITEMCAT_TOOLS,			15,				"weapon_zs_medicalkit") --医疗包
GM:AddPointShopItem("medgun",			ITEMCAT_TOOLS,			30,				"weapon_zs_medicgun")
item =
GM:AddPointShopItem("strengthshot",		ITEMCAT_TOOLS,			30,				"weapon_zs_strengthshot")
item.SkillRequirement = SKILL_U_STRENGTHSHOT
item =
GM:AddPointShopItem("antidote",			ITEMCAT_TOOLS,			30,				"weapon_zs_antidoteshot")
item.SkillRequirement = SKILL_U_ANTITODESHOT
GM:AddPointShopItem("medrifle",			ITEMCAT_TOOLS,			55,				"weapon_zs_medicrifle")  --治疗步枪
GM:AddPointShopItem("healray",			ITEMCAT_TOOLS,			125,			"weapon_zs_healingray")
GM:AddPointShopItem("junkpack",			ITEMCAT_DEPLOYABLES,	40,				"weapon_zs_boardpack")   --垃圾包
-- Tier 1
GM:AddPointShopItem("cutlery",			ITEMCAT_TRINKETS,		10,				"trinket_cutlery").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("boxingtraining",	ITEMCAT_TRINKETS,		10,				"trinket_boxingtraining").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("hemoadrenali",		ITEMCAT_TRINKETS,		10,				"trinket_hemoadrenali").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("oxtank",			ITEMCAT_TRINKETS,		10,				"trinket_oxygentank").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("acrobatframe",		ITEMCAT_TRINKETS,		10,				"trinket_acrobatframe").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("portablehole",		ITEMCAT_TRINKETS,		10,				"trinket_portablehole").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("magnet",			ITEMCAT_TRINKETS,		10,				"trinket_magnet").SubCategory =									ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddPointShopItem("targetingvisi",	ITEMCAT_TRINKETS,		10,				"trinket_targetingvisori").SubCategory =						ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("pulseampi",		ITEMCAT_TRINKETS,		10,				"trinket_pulseampi").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
-- Tier 2
GM:AddPointShopItem("momentumsupsysii",	ITEMCAT_TRINKETS,		15,				"trinket_momentumsupsysii").SubCategory =						ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("sharpkit",			ITEMCAT_TRINKETS,		15,				"trinket_sharpkit").SubCategory =								ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("nightvision",		ITEMCAT_TRINKETS,		15,				"trinket_nightvision").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("loadingframe",		ITEMCAT_TRINKETS,		15,				"trinket_loadingex").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("pathfinder",		ITEMCAT_TRINKETS,		15,				"trinket_pathfinder").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("ammovestii",		ITEMCAT_TRINKETS,		15,				"trinket_ammovestii").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("olympianframe",	ITEMCAT_TRINKETS,		15,				"trinket_olympianframe").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("autoreload",		ITEMCAT_TRINKETS,		15,				"trinket_autoreload").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("curbstompers",		ITEMCAT_TRINKETS,		15,				"trinket_curbstompers").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("vitpackagei",		ITEMCAT_TRINKETS,		15,				"trinket_vitpackagei").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("cardpackagei",		ITEMCAT_TRINKETS,		15,				"trinket_cardpackagei").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("forcedamp",		ITEMCAT_TRINKETS,		15,				"trinket_forcedamp").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("kevlar",			ITEMCAT_TRINKETS,		15,				"trinket_kevlar").SubCategory =									ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("antitoxinpack",	ITEMCAT_TRINKETS,		15,				"trinket_antitoxinpack").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("hemostasis",		ITEMCAT_TRINKETS,		15,				"trinket_hemostasis").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("bloodpack",		ITEMCAT_TRINKETS,		15,				"trinket_bloodpack").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("reactiveflasher",	ITEMCAT_TRINKETS,		15,				"trinket_reactiveflasher").SubCategory =						ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddPointShopItem("iceburst",			ITEMCAT_TRINKETS,		15,				"trinket_iceburst").SubCategory =								ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddPointShopItem("biocleanser",		ITEMCAT_TRINKETS,		15,				"trinket_biocleanser").SubCategory =							ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddPointShopItem("necrosense",		ITEMCAT_TRINKETS,		15,				"trinket_necrosense").SubCategory =								ITEMSUBCAT_TRINKETS_SPECIAL
GM:AddPointShopItem("blueprintsi",		ITEMCAT_TRINKETS,		15,				"trinket_blueprintsi").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("processor",		ITEMCAT_TRINKETS,		15,				"trinket_processor").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("acqmanifest",		ITEMCAT_TRINKETS,		15,				"trinket_acqmanifest").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("mainsuite",		ITEMCAT_TRINKETS,		15,				"trinket_mainsuite").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT
-- Tier 3
--GM:AddPointShopItem("climbinggear",	ITEMCAT_TRINKETS,		30,				"trinket_climbinggear").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("reachem",			ITEMCAT_TRINKETS,		30,				"trinket_reachem").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("momentumsupsysiii",ITEMCAT_TRINKETS,		30,				"trinket_momentumsupsysiii").SubCategory =						ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("powergauntlet",	ITEMCAT_TRINKETS,		30,				"trinket_powergauntlet").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("hemoadrenalii",	ITEMCAT_TRINKETS,		30,				"trinket_hemoadrenalii").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("sharpstone",		ITEMCAT_TRINKETS,		30,				"trinket_sharpstone").SubCategory =								ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("analgestic",		ITEMCAT_TRINKETS,		30,				"trinket_analgestic").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("feathfallframe",	ITEMCAT_TRINKETS,		30,				"trinket_featherfallframe").SubCategory =						ITEMSUBCAT_TRINKETS_PERFORMANCE
GM:AddPointShopItem("aimcomp",			ITEMCAT_TRINKETS,		30,				"trinket_aimcomp").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("pulseampii",		ITEMCAT_TRINKETS,		30,				"trinket_pulseampii").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("extendedmag",		ITEMCAT_TRINKETS,		30,				"trinket_extendedmag").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("vitpackageii",		ITEMCAT_TRINKETS,		30,				"trinket_vitpackageii").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("cardpackageii",	ITEMCAT_TRINKETS,		30,				"trinket_cardpackageii").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("regenimplant",		ITEMCAT_TRINKETS,		30,				"trinket_regenimplant").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("barbedarmor",		ITEMCAT_TRINKETS,		30,				"trinket_barbedarmor").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("blueprintsii",		ITEMCAT_TRINKETS,		30,				"trinket_blueprintsii").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("curativeii",		ITEMCAT_TRINKETS,		30,				"trinket_curativeii").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("remedy",			ITEMCAT_TRINKETS,		30,				"trinket_remedy").SubCategory =									ITEMSUBCAT_TRINKETS_SUPPORT
-- Tier 4
GM:AddPointShopItem("hemoadrenaliii",	ITEMCAT_TRINKETS,		50,				"trinket_hemoadrenaliii").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE
GM:AddPointShopItem("ammoband",			ITEMCAT_TRINKETS,		50,				"trinket_ammovestiii").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("resonance",		ITEMCAT_TRINKETS,		50,				"trinket_resonance").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("cryoindu",			ITEMCAT_TRINKETS,		50,				"trinket_cryoindu").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("refinedsub",		ITEMCAT_TRINKETS,		50,				"trinket_refinedsub").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("targetingvisiii",	ITEMCAT_TRINKETS,		50,				"trinket_targetingvisoriii").SubCategory =						ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("eodvest",			ITEMCAT_TRINKETS,		50,				"trinket_eodvest").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("composite",		ITEMCAT_TRINKETS,		50,				"trinket_composite").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE
GM:AddPointShopItem("arsenalpack",		ITEMCAT_TRINKETS,		50,				"trinket_arsenalpack").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("resupplypack",		ITEMCAT_TRINKETS,		50,				"trinket_resupplypack").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("promanifest",		ITEMCAT_TRINKETS,		50,				"trinket_promanifest").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT
GM:AddPointShopItem("opsmatrix",		ITEMCAT_TRINKETS,		50,				"trinket_opsmatrix").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT
-- Tier 5
GM:AddPointShopItem("supasm",			ITEMCAT_TRINKETS,		70,				"trinket_supasm").SubCategory =									ITEMSUBCAT_TRINKETS_OFFENSIVE
GM:AddPointShopItem("pulseimpedance",	ITEMCAT_TRINKETS,		70,				"trinket_pulseimpedance").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE

GM:AddPointShopItem("flashbomb",		ITEMCAT_OTHER,			15,				"weapon_zs_flashbomb")--闪光弹
GM:AddPointShopItem("molotov",			ITEMCAT_OTHER,			30,				"weapon_zs_molotov")--燃烧瓶
GM:AddPointShopItem("grenade",			ITEMCAT_OTHER,			35,				"weapon_zs_grenade")--手雷
GM:AddPointShopItem("betty",			ITEMCAT_OTHER,			35,				"weapon_zs_proxymine")
GM:AddPointShopItem("detpck",			ITEMCAT_OTHER,			40,				"weapon_zs_detpack")
item =
GM:AddPointShopItem("crygasgrenade",	ITEMCAT_OTHER,			40,				"weapon_zs_crygasgrenade")
item.SkillRequirement = SKILL_U_CRYGASGREN
GM:AddPointShopItem("corgasgrenade",	ITEMCAT_OTHER,			45,				"weapon_zs_corgasgrenade")
GM:AddPointShopItem("sigfragment",		ITEMCAT_OTHER,			30,				"weapon_zs_sigilfragment")
GM:AddPointShopItem("bloodshot",		ITEMCAT_OTHER,			35,				"weapon_zs_bloodshotbomb")--血甲手雷
item =
GM:AddPointShopItem("corruptedfragment",ITEMCAT_OTHER,			55,				"weapon_zs_corruptedfragment")
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_CORRUPTEDFRAGMENT
item =
GM:AddPointShopItem("medcloud",			ITEMCAT_OTHER,			25,				"weapon_zs_mediccloudbomb")--治疗雷
item.SkillRequirement = SKILL_U_MEDICCLOUD
item =
GM:AddPointShopItem("nanitecloud",		ITEMCAT_OTHER,			25,				"weapon_zs_nanitecloudbomb")--维修雷
item.SkillRequirement = SKILL_U_NANITECLOUD


GM:AddMutationItem("m_zombie_health", ""..translate.Get("zshop_alphazomb"), ""..translate.Get("zshop_alphazomb2"), ITEMCAT_MUTATIONS, 50, nil, function(pl) pl.m_Zombie_Health = true end, "models/items/healthkit.mdl")    
GM:AddMutationItem("m_zombie_moan", ""..translate.Get("zshop_zombsprint"), ""..translate.Get("zshop_zombsprint2"), ITEMCAT_MUTATIONS, 15, nil, function(pl) pl.m_Zombie_Moan = true end, "models/player/zombie_classic.mdl")
GM:AddMutationItem("m_zombie_moanguard", ""..translate.Get("zshop_zombguard"), ""..translate.Get("zshop_zombguard2"), ITEMCAT_MUTATIONS, 80, nil, function(pl) pl.m_Zombie_MoanGuard = true end, "models/player/zombie_classic.mdl")
GM:AddMutationItem("m_zombie_damage_1", translate.Get("zshop_mutation_damage_1"), translate.Get("zshop_mutation_increase_damage_7"), ITEMCAT_MUTATIONS, 100, nil, function(pl) pl.m_Zombie_Damage1 = true end, "models/player/zombie_classic.mdl")

-- Boss Mutations
GM:AddMutationItem("m_shade_damage", ""..translate.Get("zshop_bossphysicshazard"), ""..translate.Get("zshop_bossphysicshazard2"), ITEMCAT_MUTATIONS_BOSS, 550, nil, function(pl) pl.m_Shade_Force = true end, "models/player/zombie_classic.mdl")

local function genericcallback(pl, magnitude) return pl:Name(), magnitude end
GM.HonorableMentions = {}
GM.HonorableMentions[HM_MOSTZOMBIESKILLED] = {Name = ""..translate.Get("honorpanel_most_zombies_killed"), String = ""..translate.Get("honorpanel_most_zombies_killed_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTDAMAGETOUNDEAD] = {Name = translate.Get("honorpanel_most_damage_to_undead"), String = translate.Get("honorpanel_most_damage_to_undead_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTHEADSHOTS] = {Name = translate.Get("honorpanel_most_headshots"), String = translate.Get("honorpanel_most_headshots_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_PACIFIST] = {Name = translate.Get("honorpanel_pacifist"), String = translate.Get("honorpanel_pacifist_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_MOSTHELPFUL] = {Name = translate.Get("honorpanel_most_helpful"), String = translate.Get("honorpanel_most_helpful_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_LASTHUMAN] = {Name = translate.Get("honorpanel_last_human"), String = translate.Get("honorpanel_last_human_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_OUTLANDER] = {Name = translate.Get("honorpanel_outlander"), String = translate.Get("honorpanel_outlander_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_GOODDOCTOR] = {Name = translate.Get("honorpanel_good_doctor"), String = translate.Get("honorpanel_good_doctor_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_HANDYMAN] = {Name = translate.Get("honorpanel_handy_man"), String = translate.Get("honorpanel_handy_man_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_SCARECROW] = {Name = translate.Get("honorpanel_scarecrow"), String = translate.Get("honorpanel_scarecrow_string"), Callback = genericcallback, Color = COLOR_WHITE}
GM.HonorableMentions[HM_MOSTBRAINSEATEN] = {Name = translate.Get("honorpanel_most_brains_eaten"), String = translate.Get("honorpanel_most_brains_eaten_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_MOSTDAMAGETOHUMANS] = {Name = translate.Get("honorpanel_most_damage_to_humans"), String = translate.Get("honorpanel_most_damage_to_humans_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_LASTBITE] = {Name = translate.Get("honorpanel_last_bite"), String = translate.Get("honorpanel_last_bite_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_USEFULTOOPPOSITE] = {Name = translate.Get("honorpanel_useful_to_opposite"), String = translate.Get("honorpanel_useful_to_opposite_string"), Callback = genericcallback, Color = COLOR_RED}
GM.HonorableMentions[HM_STUPID] = {Name = translate.Get("honorpanel_stupid"), String = translate.Get("honorpanel_stupid_string"), Callback = genericcallback, Color = COLOR_RED}
GM.HonorableMentions[HM_SALESMAN] = {Name = translate.Get("honorpanel_salesman"), String = translate.Get("honorpanel_salesman_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_WAREHOUSE] = {Name = translate.Get("honorpanel_warehouse"), String = translate.Get("honorpanel_warehouse_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_DEFENCEDMG] = {Name = translate.Get("honorpanel_defender"), String = translate.Get("honorpanel_defender_string"), Callback = genericcallback, Color = COLOR_WHITE}
GM.HonorableMentions[HM_STRENGTHDMG] = {Name = translate.Get("honorpanel_alchemist"), String = translate.Get("honorpanel_alchemist_string"), Callback = genericcallback, Color = COLOR_CYAN}
GM.HonorableMentions[HM_BARRICADEDESTROYER] = {Name = translate.Get("honorpanel_barricade_destroyer"), String = translate.Get("honorpanel_barricade_destroyer_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_NESTDESTROYER] = {Name = translate.Get("honorpanel_nest_destroyer"), String = translate.Get("honorpanel_nest_destroyer_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}
GM.HonorableMentions[HM_NESTMASTER] = {Name = translate.Get("honorpanel_nest_master"), String = translate.Get("honorpanel_nest_master_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}


-- Don't let humans use these models because they look like undead models. Must be lower case.
GM.RestrictedModels = {
	"models/player/zombie_classic.mdl",
	"models/player/zombie_classic_hbfix.mdl",
	"models/player/zombine.mdl",
	"models/player/zombie_soldier.mdl",
	"models/player/zombie_fast.mdl",
	"models/player/corpse1.mdl",
	"models/player/charple.mdl",
	"models/player/skeleton.mdl",
	"models/player/combine_soldier_prisonguard.mdl",
	"models/player/soldier_stripped.mdl",
	"models/player/zelpa/stalker.mdl",
	"models/player/fatty/fatty.mdl",
	"models/player/zombie_lacerator2.mdl"
}

-- If a person has no player model then use one of these (auto-generated).
GM.RandomPlayerModels = {}
for name, mdl in pairs(player_manager.AllValidModels()) do
	if not table.HasValue(GM.RestrictedModels, string.lower(mdl)) then
		table.insert(GM.RandomPlayerModels, name)
	end
end

GM.DeployableInfo = {}
function GM:AddDeployableInfo(class, name, wepclass)
	local tab = {Class = class, Name = name or "?", WepClass = wepclass}

	self.DeployableInfo[#self.DeployableInfo + 1] = tab
	self.DeployableInfo[class] = tab

	return tab
end
GM:AddDeployableInfo("prop_arsenalcrate", 		"Arsenal Crate", 		"weapon_zs_arsenalcrate")
GM:AddDeployableInfo("prop_resupplybox", 		"Resupply Box", 		"weapon_zs_resupplybox")
GM:AddDeployableInfo("prop_remantler", 			"Weapon Remantler", 	"weapon_zs_remantler")
GM:AddDeployableInfo("prop_messagebeacon", 		"Message Beacon", 		"weapon_zs_messagebeacon")
GM:AddDeployableInfo("prop_camera", 			"Camera",	 			"weapon_zs_camera")
GM:AddDeployableInfo("prop_gunturret", 			"Gun Turret",	 		"weapon_zs_gunturret")
GM:AddDeployableInfo("prop_gunturret_assault", 	"Assault Turret",	 	"weapon_zs_gunturret_assault")
GM:AddDeployableInfo("prop_gunturret_buckshot",	"Blast Turret",	 		"weapon_zs_gunturret_buckshot")
GM:AddDeployableInfo("prop_gunturret_pulse",	"Pulse Turret",	 	    "weapon_zs_gunturret_pulse")
GM:AddDeployableInfo("prop_gunturret_rocket",	"Rocket Turret",	 	"weapon_zs_gunturret_rocket")
GM:AddDeployableInfo("prop_repairfield",		"Repair Field Emitter",	"weapon_zs_repairfield")
GM:AddDeployableInfo("prop_medicfield",		    "Medic Field Emitter",	"weapon_zs_medicfield")
GM:AddDeployableInfo("prop_zapper",				"Zapper",				"weapon_zs_zapper")
GM:AddDeployableInfo("prop_zapper_arc",			"Arc Zapper",			"weapon_zs_zapper_arc")
GM:AddDeployableInfo("prop_ffemitter",			"Force Field Emitter",	"weapon_zs_ffemitter")
GM:AddDeployableInfo("prop_manhack",			"Manhack",				"weapon_zs_manhack")
GM:AddDeployableInfo("prop_manhack_saw",		"Sawblade Manhack",		"weapon_zs_manhack_saw")
GM:AddDeployableInfo("prop_drone",				"Drone",				"weapon_zs_drone")
GM:AddDeployableInfo("prop_drone_pulse",		"Pulse Drone",			"weapon_zs_drone_pulse")
GM:AddDeployableInfo("prop_drone_hauler",		"Hauler Drone",			"weapon_zs_drone_hauler")
GM:AddDeployableInfo("prop_rollermine",			"Rollermine",			"weapon_zs_rollermine")
GM:AddDeployableInfo("prop_tv",                   	"TV",                    	"weapon_zs_tv")

GM.MaxSigils = 3

GM.DefaultRedeem = CreateConVar("zs_redeem", "4", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The amount of kills a zombie needs to do in order to redeem. Set to 0 to disable."):GetInt()
cvars.AddChangeCallback("zs_redeem", function(cvar, oldvalue, newvalue)
	GAMEMODE.DefaultRedeem = math.max(0, tonumber(newvalue) or 0)
end)

GM.WaveOneZombies = 0.11--math.Round(CreateConVar("zs_waveonezombies", "0.1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "The percentage of players that will start as zombies when the game begins."):GetFloat(), 2)
-- cvars.AddChangeCallback("zs_waveonezombies", function(cvar, oldvalue, newvalue)
-- 	GAMEMODE.WaveOneZombies = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
-- end)

-- Game feeling too easy? Just change these values!
GM.ZombieSpeedMultiplier = math.Round(CreateConVar("zs_zombiespeedmultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Zombie running speed will be scaled by this value."):GetFloat(), 2)
cvars.AddChangeCallback("zs_zombiespeedmultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieSpeedMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- This is a resistance, not for claw damage. 0.5 will make zombies take half damage, 0.25 makes them take 1/4, etc.
GM.ZombieDamageMultiplier = math.Round(CreateConVar("zs_zombiedamagemultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "Scales the amount of damage that zombies take. Use higher values for easy zombies, lower for harder."):GetFloat(), 2)
cvars.AddChangeCallback("zs_zombiedamagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

GM.TimeLimit = CreateConVar("zs_timelimit", "15", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Time in minutes before the game will change maps. It will not change maps if a round is currently in progress but after the current round ends. -1 means never switch maps. 0 means always switch maps."):GetInt() * 60
cvars.AddChangeCallback("zs_timelimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.TimeLimit = tonumber(newvalue) or 15
	if GAMEMODE.TimeLimit ~= -1 then
		GAMEMODE.TimeLimit = GAMEMODE.TimeLimit * 60
	end
end)

GM.RoundLimit = CreateConVar("zs_roundlimit", "3", FCVAR_ARCHIVE + FCVAR_NOTIFY, "How many times the game can be played on the same map. -1 means infinite or only use time limit. 0 means once."):GetInt()
cvars.AddChangeCallback("zs_roundlimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.RoundLimit = tonumber(newvalue) or 3
end)

-- Static values that don't need convars...

-- Initial length for wave 1.
GM.WaveOneLength = 165

-- Add this many seconds for each additional wave.
GM.TimeAddedPerWave = 12

-- New players are put on the zombie team if the current wave is this or higher. Do not put it lower than 1 or you'll break the game.
GM.NoNewHumansWave = 3

-- Humans can not commit suicide if the current wave is this or lower.
GM.NoSuicideWave = 1

-- How long 'wave 0' should last in seconds. This is the time you should give for new players to join and get ready.
GM.WaveZeroLength = 240

-- Time humans have between waves to do stuff without NEW zombies spawning. Any dead zombies will be in spectator (crow) view and any living ones will still be living.
GM.WaveIntermissionLength = 90

-- Time in seconds between end round and next map.
GM.EndGameTime = 50

-- How many clips of ammo guns from the Worth menu start with. Some guns such as shotguns and sniper rifles have multipliers on this.
GM.SurvivalClips = 4 --2

-- How long do humans have to wait before being able to get more ammo from a resupply box?
GM.ResupplyBoxCooldown = 75

-- Put your unoriginal, 5MB Rob Zombie and Metallica music here.
GM.LastHumanSound = Sound("zombiesurvival/lasthuman.ogg")

-- Sound played when humans all die.
GM.AllLoseSound = Sound("zombiesurvival/music_lose.ogg")

-- Sound played when humans survive.
GM.HumanWinSound = Sound("zombiesurvival/music_win.ogg")

-- Sound played to a person when they die as a human.
GM.DeathSound = Sound("zombiesurvival/human_death_stinger.ogg")

-- Fetch map profiles and node profiles from noxiousnet database?
GM.UseOnlineProfiles = false

-- This multiplier of points will save over to the next round. 1 is full saving. 0 is disabled.
-- Setting this to 0 will not delete saved points and saved points do not "decay" if this is less than 1.
GM.PointSaving = 0

-- Lock item purchases to waves. Tier 2 items can only be purchased on wave 2, tier 3 on wave 3, etc.
-- HIGHLY suggested that this is on if you enable point saving. Always false if objective map, zombie escape, classic mode, or wave number is changed by the map.
GM.LockItemTiers = false

-- Don't save more than this amount of points. 0 for infinite.
GM.PointSavingLimit = 0

-- For Classic Mode
GM.WaveIntermissionLengthClassic = 20
GM.WaveOneLengthClassic = 120
GM.TimeAddedPerWaveClassic = 10

-- Max amount of damage left to tick on these. Any more pending damage is ignored.
GM.MaxPoisonDamage = 50
GM.MaxBleedDamage = 50

-- Give humans this many points when the wave ends.
GM.EndWavePointsBonus = 10

-- Also give humans this many points when the wave ends, multiplied by (wave - 1)
GM.EndWavePointsBonusPerWave = 20
