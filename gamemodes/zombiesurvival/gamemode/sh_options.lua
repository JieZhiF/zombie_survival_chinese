--[[
	sh_options.lua - 共享选项与物品注册模块
	本文件定义了游戏中的所有物品、武器池、弹药缓存、荣誉提及、可部署物信息以及各类游戏参数。
	是僵尸生存模式的核心配置/注册文件。
]]

-- ============================================================
-- 僵尸逃跑模式（ZE）主武器池
-- 当游戏处于僵尸逃跑模式时，幸存者将从这些武器中随机获得主武器
-- ============================================================
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

-- ============================================================
-- 僵尸逃跑模式（ZE）副武器池
-- 当游戏处于僵尸逃跑模式时，幸存者将从这些武器中随机获得副武器
-- ============================================================
GM.ZombieEscapeWeaponsSecondary = {
	"weapon_zs_zedeagle",
	"weapon_zs_zebattleaxe",
	"weapon_zs_zeeraser",
	"weapon_zs_zeglock",
	"weapon_zs_zetempest"
}

-- ============================================================
-- 存档文件配置
-- 如果你打算修改物品价格或大幅改变 Worth 系统的工作方式，请更改此项。
-- 使用独立的存档文件可以让玩家在不同服务器上拥有不同的配装方案。
-- ============================================================
-- 玩家物品购买记录的存档文件名（Worth 商店数据）
GM.CartFile = "zscarts.txt"
-- 技能配装方案的存档文件名
GM.SkillLoadoutsFile = "zsskloadouts.txt"

-- ============================================================
-- 物品主分类常量定义
-- 这些常量用于标识物品属于哪个主分类，在物品注册时作为 category 参数传入
-- ============================================================
ITEMCAT_GUNS = 1          -- 枪械类（主武器/副武器）
ITEMCAT_AMMO = 2          -- 弹药类
ITEMCAT_MELEE = 3         -- 近战武器类
ITEMCAT_TOOLS = 4         -- 工具类（医疗包、焊枪等）
ITEMCAT_DEPLOYABLES = 5   -- 可部署物类（炮塔、补给箱等）
ITEMCAT_TRINKETS = 6      -- 饰品/小玩意类（被动加成道具）
ITEMCAT_OTHER = 7         -- 其他类（投掷物、特殊物品等）

-- ============================================================
-- 物品子分类常量（主要用于饰品分类）
-- 饰品内部进一步的细分，用于在界面中分组显示
-- ============================================================
ITEMSUBCAT_TRINKETS_DEFENSIVE = 1     -- 防御型饰品
ITEMSUBCAT_TRINKETS_OFFENSIVE = 2     -- 进攻型饰品
ITEMSUBCAT_TRINKETS_MELEE = 3         -- 近战型饰品
ITEMSUBCAT_TRINKETS_PERFORMANCE = 4   -- 性能型饰品
ITEMSUBCAT_TRINKETS_SUPPORT = 5       -- 支援型饰品
ITEMSUBCAT_TRINKETS_SPECIAL = 6       -- 特殊型饰品

-- ============================================================
-- 物品主分类名称映射表
-- 将分类编号映射为可翻译的分类名称字符串，用于显示在 Arsenal（军械库）界面中
-- 注意：如果有自定义分类需求，可以复制覆盖此表或仅添加带标记的新条目
-- ============================================================
GM.ItemCategories = {
    [ITEMCAT_GUNS] = ""..translate.Get("arsenal_itemcat_Guns"),
    [ITEMCAT_AMMO] = ""..translate.Get("arsenal_itemcat_Ammo"),
    [ITEMCAT_MELEE] = ""..translate.Get("arsenal_itemcat_Melee"),
    [ITEMCAT_TOOLS] = ""..translate.Get("arsenal_itemcat_Tools"),
    [ITEMCAT_DEPLOYABLES] = ""..translate.Get("arsenal_itemcat_Deployables"),
    [ITEMCAT_TRINKETS] = ""..translate.Get("arsenal_itemcat_Trinkets"),
    [ITEMCAT_OTHER] = ""..translate.Get("arsenal_itemcat_Other")
}

-- ============================================================
-- 物品子分类名称映射表
-- 将子分类编号映射为可翻译的名称字符串，用于饰品分类的界面显示
-- ============================================================
GM.ItemSubCategories = {
    [ITEMSUBCAT_TRINKETS_DEFENSIVE] = ""..translate.Get("arsenal_itemsubcat_Defensive"),
    [ITEMSUBCAT_TRINKETS_OFFENSIVE] = ""..translate.Get("arsenal_itemsubcat_Offensive"),
    [ITEMSUBCAT_TRINKETS_MELEE] = ""..translate.Get("arsenal_itemsubcat_Melee"),
    [ITEMSUBCAT_TRINKETS_PERFORMANCE] = ""..translate.Get("arsenal_itemsubcat_Performance"),
    [ITEMSUBCAT_TRINKETS_SUPPORT] = ""..translate.Get("arsenal_itemsubcat_Support"),
    [ITEMSUBCAT_TRINKETS_SPECIAL] = ""..translate.Get("arsenal_itemsubcat_Special")
}

--[[
	物品系统说明：
	人类玩家可以选择他们出生时想要携带的武器/物品，甚至可以将偏好保存。
	每个物品都分配有『Worth』点数（价值点数）。

	signature（签名）是唯一的标识字符串，以防物品被重命名或重新排序时失效。
	请不要使用数字或数字字符串作为签名！

	一个人类玩家在加入时默认只能使用 100 点 Worth 点数。
	赎罪重生或迟加入的玩家将获得随机配装。

	SWEP 参数指定了玩家选择此物品时获得的武器 SWEP 类名。
	Callback 参数是当物品被选中时调用的回调函数。
	Model 参数是界面中显示的模型路径。
	swep、callback 和 model 都可以为 nil 或空。
--]]

-- ============================================================
-- GM.Items 物品总表
-- 存储所有已注册的物品，以数字索引和签名索引双重方式存储
-- ============================================================
GM.Items = {}

-- ============================================================
-- GM:AddItem() - 添加一个通用物品到物品系统
-- @param signature (string) 物品的唯一签名标识
-- @param category (number) 物品分类常量
-- @param price (number) 物品的 Worth 点数价格
-- @param swep (string|nil) 关联的武器 SWEP 类名
-- @param name (string|nil) 物品的显示名称
-- @param desc (string|nil) 物品的描述文本
-- @param model (string|nil) 界面中使用的模型路径
-- @param callback (function|nil) 物品被选择时的回调函数
-- @return table 返回创建的物品数据表
-- ============================================================
function GM:AddItem(signature, category, price, swep, name, desc, model, callback)
	-- 构建物品数据表，包含所有属性
	local tab = {Signature = signature, Name = name or "?", Description = desc, Category = category, Price = price or 0, SWEP = swep, Callback = callback, Model = model}

	-- 兼容旧版代码：Worth 字段与 Price 相同
	tab.Worth = tab.Price

	-- 同时以数字索引和签名索引方式存储，方便快速查找
	self.Items[#self.Items + 1] = tab
	self.Items[signature] = tab

	return tab
end

-- ============================================================
-- GM:AddStartingItem() - 添加一个起始物品（Worth 商店物品）
-- 通过此函数注册的物品会在 Worth 商店中显示，供玩家选择配装
-- @param signature (string) 物品的签名
-- @param category (number) 物品分类
-- @param price (number) 物品价格
-- @param swep (string|nil) 关联武器
-- @param name (string|nil) 名称
-- @param desc (string|nil) 描述
-- @param model (string|nil) 模型
-- @param callback (function|nil) 回调函数
-- @return table 返回创建的物品数据表（含 WorthShop = true 标记）
-- ============================================================
function GM:AddStartingItem(signature, category, price, swep, name, desc, model, callback)
	local item = self:AddItem(signature, category, price, swep, name, desc, model, callback)
	-- 标记为 Worth 商店物品，会在初始配装界面显示
	item.WorthShop = true

	return item
end

-- ============================================================
-- GM:AddPointShopItem() - 添加一个积分商店物品（PointShop）
-- 通过此函数注册的物品会在游戏内的积分商店中显示，使用游戏积分购买
-- 注意：签名会自动添加 "ps_" 前缀以避免与起始物品冲突
-- @param signature (string) 物品签名（会自动加 "ps_" 前缀）
-- @param category (number) 物品分类
-- @param price (number) 物品价格
-- @param swep (string|nil) 关联武器
-- @param name (string|nil) 名称
-- @param desc (string|nil) 描述
-- @param model (string|nil) 模型
-- @param callback (function|nil) 回调函数
-- @return table 返回创建的物品数据表（含 PointShop = true 标记）
-- ============================================================
function GM:AddPointShopItem(signature, category, price, swep, name, desc, model, callback)
	local item = self:AddItem("ps_"..signature, category, price, swep, name, desc, model, callback)
	-- 标记为积分商店物品
	item.PointShop = true

	return item
end

-- ============================================================
-- 延时回调：在游戏模式加载完成后自动补全物品描述
-- 武器注册发生在游戏模式之后，所以需要延时执行
-- 对于已经有 SWEP 但没有描述的物品，从对应的武器定义中获取描述
-- ============================================================
timer.Simple(0, function()
	-- 遍历所有已注册的物品
	for _, tab in pairs(GAMEMODE.Items) do
		-- 如果物品没有描述但有关联的 SWEP，则从 SWEP 定义中获取描述
		if not tab.Description and tab.SWEP then
			local sweptab = weapons.GetStored(tab.SWEP)
			if sweptab then
				tab.Description = sweptab.Description
			end
		end
	end
end)

-- ============================================================
-- GM.AmmoCache - 补给箱弹药缓存配置
-- 定义了玩家从各类补给箱（Arsenal Crate, Resupply Box 等）中能获得的弹药数量
-- 注释中说明了每种弹药对应的武器类型
-- ============================================================
GM.AmmoCache = {}
GM.AmmoCache["ar2"]							= 135		-- 突击步枪弹药
GM.AmmoCache["alyxgun"]						= 24		-- 未使用
GM.AmmoCache["pistol"]						= 60		-- 手枪弹药
GM.AmmoCache["smg1"]						= 135		-- 冲锋枪弹药
GM.AmmoCache["357"]							= 30		-- 狙击类弹药
GM.AmmoCache["xbowbolt"]					= 30		-- 弩箭弹药
GM.AmmoCache["buckshot"]					= 48		-- 霰弹枪弹药
GM.AmmoCache["ar2altfire"]					= 2			-- 未使用
GM.AmmoCache["slam"]						= 3			-- 地雷弹药
GM.AmmoCache["rpg_round"]					= 2			-- 未使用（火箭筒？）
GM.AmmoCache["smg1_grenade"]				= 2			-- 未使用
GM.AmmoCache["sniperround"]					= 2			-- 路障工具包
GM.AmmoCache["sniperpenetratedround"]		= 1			-- 遥控炸药包
GM.AmmoCache["grenade"]						= 1			-- 手雷
GM.AmmoCache["thumper"]						= 1			-- 枪炮塔
GM.AmmoCache["gravity"]						= 1			-- 未使用
GM.AmmoCache["battery"]						= 90		-- 医疗弹药
GM.AmmoCache["gaussenergy"]					= 6			-- 钉子（高斯能量）
GM.AmmoCache["combinecannon"]				= 1			-- 未使用
GM.AmmoCache["airboatgun"]					= 1			-- 军械库箱子
GM.AmmoCache["striderminigun"]				= 1			-- 信息信标
GM.AmmoCache["helicoptergun"]				= 1			-- 补给箱
GM.AmmoCache["spotlamp"]					= 1
GM.AmmoCache["manhack"]						= 1
GM.AmmoCache["repairfield"]					= 1
GM.AmmoCache["medicfield"]					= 1
GM.AmmoCache["zapper"]						= 1
GM.AmmoCache["pulse"]						= 135
GM.AmmoCache["impactmine"]					= 9			-- 爆炸弹药
GM.AmmoCache["chemical"]					= 40
GM.AmmoCache["flashbomb"]					= 1
GM.AmmoCache["turret_buckshot"]				= 1
GM.AmmoCache["turret_assault"]				= 1
GM.AmmoCache["scrap"]						= 12

-- ============================================================
-- GM.AmmoResupply - 可补充弹药类型列表
-- 使用 table.ToAssoc 将弹药类型列表转换为关联表（键值映射）
-- 只有在列表中的弹药类型才能从补给箱中补充
-- ============================================================
GM.AmmoResupply = table.ToAssoc({"ar2", "pistol", "smg1", "357", "xbowbolt", "buckshot", "battery", "pulse", "impactmine", "chemical", "gaussenergy", "scrap"})

-- ============================================================
-- Worth 商店物品注册 - 枪械类（起始配装物品）
-- 玩家在出生前可以通过 Worth 商店选择这些物品作为初始装备
-- 格式：签名, 分类, 价格, SWEP 名称
-- 价格单位为 Worth 点数，默认总额为 100 点
-- ============================================================

-- 一级枪械（价格 40）
GM:AddStartingItem("pshtr",				ITEMCAT_GUNS,			40,				"weapon_zs_peashooter")     -- 豌豆射手
GM:AddStartingItem("btlax",				ITEMCAT_GUNS,			40,				"weapon_zs_battleaxe")      -- 战斧
GM:AddStartingItem("owens",				ITEMCAT_GUNS,			40,				"weapon_zs_owens")          -- 欧文斯冲锋枪
GM:AddStartingItem("blstr",				ITEMCAT_GUNS,			40,				"weapon_zs_blaster")        -- 爆能枪
GM:AddStartingItem("tossr",				ITEMCAT_GUNS,			40,				"weapon_zs_tosser")         -- 投掷者
GM:AddStartingItem("stbbr",				ITEMCAT_GUNS,			40,				"weapon_zs_stubber")        -- 短管枪
GM:AddStartingItem("crklr",				ITEMCAT_GUNS,			40,				"weapon_zs_enderp")       -- 末影 等离子无托步枪（原爆裂者位置）
--GM:AddStartingItem("sling",			ITEMCAT_GUNS,			40,				"weapon_zs_slinger")       -- 投石索（已禁用）
GM:AddStartingItem("handgrenade",		ITEMCAT_GUNS,			60,				"weapon_zs_handgrenade")    -- 手榴弹发射器

-- 特殊枪械（价格 40-70）
GM:AddStartingItem("z9000",				ITEMCAT_GUNS,			40,				"weapon_zs_z9000")          -- Z9000
GM:AddStartingItem("minelayer",			ITEMCAT_GUNS,			70,				"weapon_zs_minelayer")      -- 布雷器
--GM:AddStartingItem("qiyuanm4",			ITEMCAT_GUNS,			0,				"weapon_zs_stm4")           -- 起源M4（已禁用）
--GM:AddStartingItem("qiyuanDeagle",		ITEMCAT_GUNS,			0,				"weapon_zs_superde")        -- 起源沙鹰（已禁用）

-- ============================================================
-- Worth 商店物品注册 - 弹药类（起始配装物品）
-- 玩家可以选择额外的弹药包作为初始装备
-- 每个弹药包使用回调函数在生成时直接给予玩家指定弹药
-- 参数：签名, 分类, 价格, SWEP（nil）, 名称, 描述（nil）, 模型, 回调函数
-- ============================================================
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

-- ============================================================
-- Worth 商店物品注册 - 近战武器类（起始配装物品）
-- 近战武器通常具有不同的攻击速度、伤害和攻击范围
-- 部分武器设置了自定义模型路径（.Model = "..."）
-- ============================================================
GM:AddStartingItem("brassknuckles",		ITEMCAT_MELEE,			20,				"weapon_zs_brassknuckles").Model = "models/props_c17/utilityconnecter005.mdl"   -- 指虎
GM:AddStartingItem("zpaxe",				ITEMCAT_MELEE,			40,				"weapon_zs_axe")              -- 斧头
GM:AddStartingItem("crwbar",			ITEMCAT_MELEE,			40,				"weapon_zs_crowbar")          -- 撬棍
GM:AddStartingItem("stnbtn",			ITEMCAT_MELEE,			40,				"weapon_zs_stunbaton")        -- 电击棒
GM:AddStartingItem("csknf",				ITEMCAT_MELEE,			20,				"weapon_zs_swissarmyknife")   -- 瑞士军刀
GM:AddStartingItem("zpplnk",			ITEMCAT_MELEE,			20,				"weapon_zs_plank")            -- 木板
GM:AddStartingItem("zpfryp",			ITEMCAT_MELEE,			30,				"weapon_zs_fryingpan")        -- 平底锅
GM:AddStartingItem("zpcpot",			ITEMCAT_MELEE,			30,				"weapon_zs_pot")              -- 锅
GM:AddStartingItem("ladel",				ITEMCAT_MELEE,			30,				"weapon_zs_ladel")            -- 勺子
GM:AddStartingItem("pipe",				ITEMCAT_MELEE,			40,				"weapon_zs_pipe")             -- 水管
GM:AddStartingItem("hook",				ITEMCAT_MELEE,			40,				"weapon_zs_hook")             -- 钩子

-- ============================================================
-- Worth 商店物品注册 - 工具类（起始配装物品）
-- 工具类物品提供治疗、建造等特殊功能
-- 某些工具需要特定的技能解锁（SkillRequirement）
-- ============================================================
local item
GM:AddStartingItem("medkit",			ITEMCAT_TOOLS,			40,				"weapon_zs_medicalkit")       -- 医疗包
GM:AddStartingItem("medgun",			ITEMCAT_TOOLS,			50,				"weapon_zs_medicgun")         -- 治疗枪
item =
GM:AddStartingItem("strengthshot",		ITEMCAT_TOOLS,			40,				"weapon_zs_strengthshot")     -- 力量注射剂
item.SkillRequirement = SKILL_U_STRENGTHSHOT                                                      -- 需要力量注射技能解锁
item =
GM:AddStartingItem("antidoteshot",		ITEMCAT_TOOLS,			40,				"weapon_zs_antidoteshot")     -- 解毒注射剂
item.SkillRequirement = SKILL_U_ANTITODESHOT                                                      -- 需要解毒注射技能解锁

-- ============================================================
-- Worth 商店物品注册 - 可部署物类（起始配装物品）
-- 可部署物是玩家可以放置在地图上的功能性实体
-- 包含：军械库箱子、补给箱、拆解器、炮塔、修复场等
-- 某些部署物在经典模式中不可用（NoClassicMode = true）
-- 某些部署物需要技能解锁
-- Countables 属性标记了该物品对应的实体类名，用于计数限制
-- ============================================================
GM:AddStartingItem("arscrate",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_arsenalcrate")     -- 军械库箱子
.Countables = "prop_arsenalcrate"                                                                 -- 对应实体类名
GM:AddStartingItem("resupplybox",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_resupplybox")      -- 补给箱
.Countables = "prop_resupplybox"
GM:AddStartingItem("remantler",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_remantler")        -- 武器拆解器
.Countables = "prop_remantler"
item =
-- 机枪炮塔：需要弹药补给（thumper 和 smg1），回调中给予空武器和弹药
GM:AddStartingItem("infturret",			ITEMCAT_DEPLOYABLES,			75,				"weapon_zs_gunturret",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret") pl:GiveAmmo(1, "thumper") pl:GiveAmmo(125, "smg1") end)
item.Countables = "prop_gunturret"
item.NoClassicMode = true                -- 经典模式不可用
item =
-- 霰弹炮塔：使用 buckshot 弹药
GM:AddStartingItem("blastturret",		ITEMCAT_DEPLOYABLES,			70,				"weapon_zs_gunturret_buckshot",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_buckshot") pl:GiveAmmo(1, "turret_buckshot") pl:GiveAmmo(30, "buckshot") end)
item.Countables = "prop_gunturret_buckshot"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_BLASTTURRET   -- 需要爆炸炮塔技能解锁
item =
-- 修复场发射器：可修复范围内的建筑物
GM:AddStartingItem("repairfield",		ITEMCAT_DEPLOYABLES,			60,				"weapon_zs_repairfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_repairfield") pl:GiveAmmo(1, "repairfield") pl:GiveAmmo(50, "pulse") end)
item.Countables = "prop_repairfield"
item.NoClassicMode = true
item =
-- 医疗场发射器：可治疗范围内的队友
GM:AddStartingItem("medicfield",		ITEMCAT_DEPLOYABLES,			60,				"weapon_zs_medicfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_medicfield") pl:GiveAmmo(1, "medicfield") pl:GiveAmmo(50, "Battery") end)
item.Countables = "prop_medicfield"
item.NoClassicMode = true
item =
-- 电击器（Zapper）：对靠近的僵尸造成电击伤害
GM:AddStartingItem("zapper",			ITEMCAT_DEPLOYABLES,			75,				"weapon_zs_zapper",				nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_zapper") pl:GiveAmmo(1, "zapper") pl:GiveAmmo(50, "pulse") end)
item.Countables = "prop_zapper"
item.NoClassicMode = true

-- 猎杀无人机（自动追踪攻击僵尸）
GM:AddStartingItem("manhack",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_manhack").Countables = "prop_manhack"
item =
-- 基础无人机：可远程操控飞行
GM:AddStartingItem("drone",				ITEMCAT_DEPLOYABLES,			55,				"weapon_zs_drone",				nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_drone") pl:GiveAmmo(1, "drone") pl:GiveAmmo(60, "smg1") end)
item.Countables = "prop_drone"
item =
-- 脉冲无人机：发射脉冲能量攻击
GM:AddStartingItem("pulsedrone",		ITEMCAT_DEPLOYABLES,			55,				"weapon_zs_drone_pulse",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_drone_pulse") pl:GiveAmmo(1, "pulse_cutter") pl:GiveAmmo(60, "pulse") end)
item.Countables = "prop_drone_pulse"
item.SkillRequirement = SKILL_U_DRONE                                                             -- 需要无人机技能解锁
item =
-- 搬运无人机：用于搬运物资
GM:AddStartingItem("hauldrone",			ITEMCAT_DEPLOYABLES,			25,				"weapon_zs_drone_hauler",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_drone_hauler") pl:GiveAmmo(1, "drone_hauler") end)
item.Countables = "prop_drone_hauler"
item.SkillRequirement = SKILL_HAULMODULE                                                           -- 需要搬运模块技能解锁
item =
-- 滚雷机器人：在地面滚动攻击僵尸
GM:AddStartingItem("rollermine",		ITEMCAT_DEPLOYABLES,			65,				"weapon_zs_rollermine",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_rollermine") pl:GiveAmmo(1, "rollermine") end)
item.Countables = "prop_rollermine"
item.SkillRequirement = SKILL_U_ROLLERMINE                                                         -- 需要滚雷技能解锁

-- ============================================================
-- Worth 商店物品注册 - 更多工具和可部署物
-- 包括：扳手、锤子（仅经典模式不可用）、木板包、组件等
-- ============================================================
GM:AddStartingItem("wrench",			ITEMCAT_TOOLS,			20,				"weapon_zs_wrench").NoClassicMode = true       -- 扳手（经典模式不可用）
GM:AddStartingItem("crphmr",			ITEMCAT_TOOLS,			40,				"weapon_zs_hammer").NoClassicMode = true       -- 锤子（经典模式不可用）
GM:AddStartingItem("junkpack",			ITEMCAT_DEPLOYABLES,	30,				"weapon_zs_boardpack")                         -- 木板包
GM:AddStartingItem("propanetank",		ITEMCAT_TOOLS,			30,				"comp_propanecan")                             -- 丙烷罐（制作组件）
GM:AddStartingItem("busthead",			ITEMCAT_TOOLS,			35,				"comp_busthead")                               -- 半身像（制作组件）
GM:AddStartingItem("sawblade",			ITEMCAT_TOOLS,			35,				"comp_sawblade").SkillRequirement = SKILL_U_CRAFTINGPACK          -- 锯片（需要制作包技能）
GM:AddStartingItem("cpuparts",			ITEMCAT_TOOLS,			35,				"comp_cpuparts").SkillRequirement = SKILL_U_CRAFTINGPACK          -- CPU零件（需要制作包技能）
GM:AddStartingItem("electrobattery",	ITEMCAT_TOOLS,			45,				"comp_electrobattery").SkillRequirement = SKILL_U_CRAFTINGPACK    -- 电磁电池（需要制作包技能）
GM:AddStartingItem("msgbeacon",			ITEMCAT_DEPLOYABLES,			10,				"weapon_zs_messagebeacon").Countables = "prop_messagebeacon"      -- 信息信标
item =
-- 力场发射器：制造防御性力场
GM:AddStartingItem("ffemitter",			ITEMCAT_DEPLOYABLES,			45,				"weapon_zs_ffemitter",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_ffemitter") pl:GiveAmmo(1, "slam") pl:GiveAmmo(50, "pulse") end)
item.Countables = "prop_ffemitter"
GM:AddStartingItem("barricadekit",		ITEMCAT_DEPLOYABLES,			80,				"weapon_zs_barricadekit")                      -- 路障工具包
GM:AddStartingItem("camera",			ITEMCAT_DEPLOYABLES,			15,				"weapon_zs_camera").Countables = "prop_camera" -- 摄像头
GM:AddStartingItem("tv",				ITEMCAT_DEPLOYABLES,			35,				"weapon_zs_tv").Countables = "prop_tv"         -- 电视

-- ============================================================
-- Worth 商店物品注册 - 饰品/小玩意类（起始配装物品）
-- 饰品提供各种被动加成效果，每个饰品属于一个子分类
-- SubCategory 属性决定了饰品在界面中的分组位置
-- ============================================================
GM:AddStartingItem("oxtank",			ITEMCAT_TRINKETS,		5,				"trinket_oxygentank").SubCategory =				ITEMSUBCAT_TRINKETS_PERFORMANCE       -- 氧气罐（提升体力恢复）
GM:AddStartingItem("boxingtraining",	ITEMCAT_TRINKETS,		10,				"trinket_boxingtraining").SubCategory =			ITEMSUBCAT_TRINKETS_MELEE             -- 拳击训练（提升近战速度）
GM:AddStartingItem("cutlery",			ITEMCAT_TRINKETS,		10,				"trinket_cutlery").SubCategory =				ITEMSUBCAT_TRINKETS_DEFENSIVE         -- 餐具（提升防御）
GM:AddStartingItem("portablehole",		ITEMCAT_TRINKETS,		10,				"trinket_portablehole").SubCategory =			ITEMSUBCAT_TRINKETS_PERFORMANCE       -- 便携洞（提升机动性）
GM:AddStartingItem("acrobatframe",		ITEMCAT_TRINKETS,		15,				"trinket_acrobatframe").SubCategory=			ITEMSUBCAT_TRINKETS_PERFORMANCE       -- 特技骨架（提升跳跃能力）
GM:AddStartingItem("nightvision",		ITEMCAT_TRINKETS,		15,				"trinket_nightvision").SubCategory =			ITEMSUBCAT_TRINKETS_SPECIAL           -- 夜视仪
GM:AddStartingItem("targetingvisi",		ITEMCAT_TRINKETS,		15,				"trinket_targetingvisori").SubCategory =		ITEMSUBCAT_TRINKETS_OFFENSIVE         -- 瞄准镜（提升射击精度）
GM:AddStartingItem("pulseampi",			ITEMCAT_TRINKETS,		15,				"trinket_pulseampi").SubCategory =				ITEMSUBCAT_TRINKETS_OFFENSIVE         -- 脉冲增幅器 I
GM:AddStartingItem("blueprintsi",		ITEMCAT_TRINKETS,		15,				"trinket_blueprintsi").SubCategory =			ITEMSUBCAT_TRINKETS_SUPPORT           -- 蓝图 I（提升建造效率）
GM:AddStartingItem("loadingframe",		ITEMCAT_TRINKETS,		15,				"trinket_loadingex").SubCategory =				ITEMSUBCAT_TRINKETS_PERFORMANCE       -- 负重骨架
GM:AddStartingItem("kevlar",			ITEMCAT_TRINKETS,		15,				"trinket_kevlar").SubCategory =					ITEMSUBCAT_TRINKETS_DEFENSIVE         -- 凯夫拉护甲
GM:AddStartingItem("momentumsupsysii",	ITEMCAT_TRINKETS,		15,				"trinket_momentumsupsysii").SubCategory =		ITEMSUBCAT_TRINKETS_MELEE             -- 动量支撑系统 II
GM:AddStartingItem("hemoadrenali",		ITEMCAT_TRINKETS,		15,				"trinket_hemoadrenali").SubCategory =			ITEMSUBCAT_TRINKETS_MELEE             -- 血肾上腺素 I
GM:AddStartingItem("vitpackagei",		ITEMCAT_TRINKETS,		20,				"trinket_vitpackagei").SubCategory =			ITEMSUBCAT_TRINKETS_DEFENSIVE         -- 维他命包 I
GM:AddStartingItem("processor",			ITEMCAT_TRINKETS,		20,				"trinket_processor").SubCategory =				ITEMSUBCAT_TRINKETS_SUPPORT           -- 处理器
GM:AddStartingItem("cardpackagei",		ITEMCAT_TRINKETS,		20,				"trinket_cardpackagei").SubCategory =			ITEMSUBCAT_TRINKETS_DEFENSIVE         -- 心脏包 I
GM:AddStartingItem("bloodpack",			ITEMCAT_TRINKETS,		20,				"trinket_bloodpack").SubCategory =				ITEMSUBCAT_TRINKETS_DEFENSIVE         -- 血包
GM:AddStartingItem("biocleanser",		ITEMCAT_TRINKETS,		20,				"trinket_biocleanser").SubCategory =			ITEMSUBCAT_TRINKETS_SPECIAL           -- 生物清洁剂（移除负面效果）
GM:AddStartingItem("reactiveflasher",	ITEMCAT_TRINKETS,		25,				"trinket_reactiveflasher").SubCategory =		ITEMSUBCAT_TRINKETS_SPECIAL           -- 反应闪光器
GM:AddStartingItem("magnet",			ITEMCAT_TRINKETS,		25,				"trinket_magnet").SubCategory =					ITEMSUBCAT_TRINKETS_SPECIAL           -- 磁铁（吸引物品）
GM:AddStartingItem("arsenalpack",		ITEMCAT_TRINKETS,		55,				"trinket_arsenalpack").SubCategory =			ITEMSUBCAT_TRINKETS_SUPPORT           -- 军械库背包
GM:AddStartingItem("resupplypack",		ITEMCAT_TRINKETS,		55,				"trinket_resupplypack").SubCategory =			ITEMSUBCAT_TRINKETS_SUPPORT           -- 补给背包

-- ============================================================
-- Worth 商店物品注册 - 其他类（起始配装物品）
-- 主要包括投掷物和特殊物品，如石头、手雷、燃烧瓶、炸药包等
-- ============================================================
GM:AddStartingItem("stone",				ITEMCAT_OTHER,			10,				"weapon_zs_stone")                             -- 石头
GM:AddStartingItem("grenade",			ITEMCAT_OTHER,			30,				"weapon_zs_grenade")                           -- 手雷
GM:AddStartingItem("flashbomb",			ITEMCAT_OTHER,			15,				"weapon_zs_flashbomb")                         -- 闪光弹
GM:AddStartingItem("molotov",			ITEMCAT_OTHER,			30,				"weapon_zs_molotov")                           -- 燃烧瓶
GM:AddStartingItem("betty",				ITEMCAT_OTHER,			30,				"weapon_zs_proxymine")                         -- 跳雷
GM:AddStartingItem("corgasgrenade",		ITEMCAT_OTHER,			40,				"weapon_zs_corgasgrenade")                     -- 腐蚀气体手雷
GM:AddStartingItem("crygasgrenade",		ITEMCAT_OTHER,			35,				"weapon_zs_crygasgrenade").SkillRequirement = SKILL_U_CRYGASGREN     -- 冷冻气体手雷（需要技能解锁）
GM:AddStartingItem("detpck",			ITEMCAT_OTHER,			35,				"weapon_zs_detpack").Countables = "prop_detpack"                     -- 遥控炸药包
item =
GM:AddStartingItem("sigfragment",		ITEMCAT_OTHER,			25,				"weapon_zs_sigilfragment")                     -- 印记碎片
item.NoClassicMode = true                                                                         -- 经典模式不可用
item =
GM:AddStartingItem("corfragment",		ITEMCAT_OTHER,			35,				"weapon_zs_corruptedfragment")                 -- 腐化碎片
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_CORRUPTEDFRAGMENT                                                 -- 需要腐化碎片技能解锁
item =
GM:AddStartingItem("medcloud",			ITEMCAT_OTHER,			35,				"weapon_zs_mediccloudbomb")                    -- 医疗云炸弹
item.SkillRequirement = SKILL_U_MEDICCLOUD                                                        -- 需要医疗云技能解锁
item =
GM:AddStartingItem("nanitecloud",		ITEMCAT_OTHER,			35,				"weapon_zs_nanitecloudbomb")                   -- 纳米修复云炸弹
item.SkillRequirement = SKILL_U_NANITECLOUD                                                       -- 需要纳米云技能解锁
GM:AddStartingItem("bloodshot",			ITEMCAT_OTHER,			35,				"weapon_zs_bloodshotbomb")                     -- 血甲手雷
GM:AddStartingItem("rewardchest",		ITEMCAT_OTHER,			100,			"weapon_zs_box")                               -- 奖励箱

-- ============================================================
-- 积分商店（PointShop）物品注册 - 枪械类
-- 积分商店的物品使用游戏内获得的积分（Points）购买
-- 武器按等级（Tier）划分，等级越高价格越贵，威力越强
-- Tier 1：基础武器（价格 15-20）
-- ============================================================
GM:AddPointShopItem("pshtr",			ITEMCAT_GUNS,			15,				"weapon_zs_peashooter", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_peashooter") end)       -- 豌豆射手
GM:AddPointShopItem("btlax",			ITEMCAT_GUNS,			15,				"weapon_zs_battleaxe", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_battleaxe") end)           -- 战斧
GM:AddPointShopItem("owens",			ITEMCAT_GUNS,			15,				"weapon_zs_owens", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_owens") end)                   -- 欧文斯冲锋枪
GM:AddPointShopItem("blstr",			ITEMCAT_GUNS,			15,				"weapon_zs_blaster", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_blaster") end)               -- 爆能枪
GM:AddPointShopItem("tossr",			ITEMCAT_GUNS,			15,				"weapon_zs_tosser", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_tosser") end)                  -- 投掷者
GM:AddPointShopItem("stbbr",			ITEMCAT_GUNS,			15,				"weapon_zs_stubber", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_stubber") end)                -- 短管枪
GM:AddPointShopItem("crklr",			ITEMCAT_GUNS,			15,				"weapon_zs_enderp", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_enderp") end)             -- 末影 等离子无托步枪（原爆裂者位置）
--GM:AddPointShopItem("sling",			ITEMCAT_GUNS,			15,				"weapon_zs_slinger", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_slinger") end) -- 投石索（已禁用）

GM:AddPointShopItem("z9000",			ITEMCAT_GUNS,			15,				"weapon_zs_z9000", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_z9000") end)                   -- Z9000
GM:AddPointShopItem("handgrenade",		ITEMCAT_GUNS,			20,				"weapon_zs_handgrenade")                                                                                      -- 手榴弹发射器
GM:AddPointShopItem("minelayer",		ITEMCAT_GUNS,			20,				"weapon_zs_minelayer", nil, nil, nil, function(pl) pl:GiveEmptyWeapon("weapon_zs_minelayer") end)            -- 布雷器

-- Tier 2：二级武器（价格 35）
GM:AddPointShopItem("glock3",			ITEMCAT_GUNS,			35,				"weapon_zs_glock3")                                                                                           -- 格洛克3
GM:AddPointShopItem("magnum",			ITEMCAT_GUNS,			35,				"weapon_zs_magnum")                                                                                           -- 马格南
--GM:AddPointShopItem("eraser",			ITEMCAT_GUNS,			35,				"weapon_zs_eraser")                                                                                          -- 橡皮擦（已禁用）
GM:AddPointShopItem("aldarhtf",			ITEMCAT_GUNS,			35,				"weapon_zs_htf_amt")                                                                                          -- HTF AMT 手枪
GM:AddPointShopItem("sawedoff",			ITEMCAT_GUNS,			35,				"weapon_zs_sawedoff")                                                                                         -- 短管霰弹枪
GM:AddPointShopItem("autoshot",			ITEMCAT_GUNS,			35,				"weapon_zs_autoshotgun")                                                                                      -- 自动霰弹枪
GM:AddPointShopItem("uzi",				ITEMCAT_GUNS,			35,				"weapon_zs_uzi")                                                                                              -- 乌兹冲锋枪
GM:AddPointShopItem("annabelle",		ITEMCAT_GUNS,			35,				"weapon_zs_annabelle")                                                                                        -- 安娜贝尔
GM:AddPointShopItem("inquisitor",		ITEMCAT_GUNS,			35,				"weapon_zs_inquisitor")                                                                                       -- 审判者
GM:AddPointShopItem("amigo",			ITEMCAT_GUNS,			35,				"weapon_zs_amigo")                                                                                            -- Amigo 手枪
GM:AddPointShopItem("hurricane",		ITEMCAT_GUNS,			35,				"weapon_zs_hurricane")                                                                                        -- 飓风冲锋枪

-- Tier 3：三级武器（价格 60）
GM:AddPointShopItem("deagle",			ITEMCAT_GUNS,			70,				"weapon_zs_deagle")                                                                                           -- 沙漠之鹰
GM:AddPointShopItem("tempest",			ITEMCAT_GUNS,			70,				"weapon_zs_tempest")                                                                                          -- 暴风雨
--GM:AddPointShopItem("ender",			ITEMCAT_GUNS,			60,				"weapon_zs_ender")                                                                                           -- 终结者（已禁用）
GM:AddPointShopItem("sg15",			    ITEMCAT_GUNS,			70,				"weapon_zs_htf_sg15")                                                                                         -- HTF SG15 霰弹枪
GM:AddPointShopItem("shredder",			ITEMCAT_GUNS,			70,				"weapon_zs_smg")                                                                                              -- 粉碎者冲锋枪
GM:AddPointShopItem("silencer",			ITEMCAT_GUNS,			70,				"weapon_zs_silencer")                                                                                         -- 消音步枪
GM:AddPointShopItem("hunter",			ITEMCAT_GUNS,			70,				"weapon_zs_hunter")                                                                                           -- 猎人步枪
GM:AddPointShopItem("onyx",				ITEMCAT_GUNS,			70,				"weapon_zs_onyx")                                                                                             -- 黑玛瑙
GM:AddPointShopItem("charon",			ITEMCAT_GUNS,			70,				"weapon_zs_charon")                                                                                           -- 卡戎
GM:AddPointShopItem("akbar",			ITEMCAT_GUNS,			70,				"weapon_zs_akbar")                                                                                            -- 阿克巴
--GM:AddPointShopItem("enderp",			ITEMCAT_GUNS,			70,				"weapon_zs_enderp")                                                                                           -- 终结者 P（已隐藏，移至 Tier 1 槽位 crklr，武器保留）
GM:AddPointShopItem("oberon",			ITEMCAT_GUNS,			70,				"weapon_zs_oberon")                                                                                           -- 奥伯龙
GM:AddPointShopItem("hyena",			ITEMCAT_GUNS,			70,				"weapon_zs_hyena")                                                                                            -- 鬣狗
GM:AddPointShopItem("pollutor",			ITEMCAT_GUNS,			70,				"weapon_zs_pollutor")                                                                                         -- 污染者

-- Tier 4：四级武器（价格 100-115）
GM:AddPointShopItem("longarm",			ITEMCAT_GUNS,			125,			"weapon_zs_longarm")                                                                                          -- 长臂步枪
GM:AddPointShopItem("dag",		    	ITEMCAT_GUNS,			125,			"weapon_zs_dag")                                                                                              -- DAG 步枪
GM:AddPointShopItem("sweeper",			ITEMCAT_GUNS,			125,			"weapon_zs_sweepershotgun")                                                                                   -- 清扫者霰弹枪
GM:AddPointShopItem("jackhammer",		ITEMCAT_GUNS,			125,			"weapon_zs_jackhammer")                                                                                       --  jackhammer 霰弹枪
GM:AddPointShopItem("epsilon",		    ITEMCAT_GUNS,			125,			"weapon_zs_epsilon_shotgun")                                                                                  -- Epsilon 霰弹枪
GM:AddPointShopItem("bulletstorm",		ITEMCAT_GUNS,			125,			"weapon_zs_bulletstorm")                                                                                      -- 弹幕风暴
GM:AddPointShopItem("reaper",			ITEMCAT_GUNS,			125,			"weapon_zs_reaper")                                                                                           -- 死神
GM:AddPointShopItem("quicksilver",		ITEMCAT_GUNS,			125,			"weapon_zs_quicksilver")                                                                                      -- 水银
GM:AddPointShopItem("slugrifle",		ITEMCAT_GUNS,			125,			"weapon_zs_slugrifle")                                                                                        -- 独头步枪
GM:AddPointShopItem("artemis",			ITEMCAT_GUNS,			125,			"weapon_zs_artemis")                                                                                          -- 阿尔忒弥斯
GM:AddPointShopItem("zeus",				ITEMCAT_GUNS,			125,			"weapon_zs_zeus")                                                                                             -- 宙斯
GM:AddPointShopItem("stalker",			ITEMCAT_GUNS,			125,			"weapon_zs_m4")                                                                                               -- 追踪者 M4
GM:AddPointShopItem("inferno",			ITEMCAT_GUNS,			125,			"weapon_zs_inferno")                                                                                          -- 炼狱
GM:AddPointShopItem("ebanator",			ITEMCAT_GUNS,			125,			"weapon_zs_htf_ebanator")                                                                                     -- HTF Ebanator
GM:AddPointShopItem("quasar",			ITEMCAT_GUNS,			125,			"weapon_zs_quasar")                                                                                           -- 类星体
GM:AddPointShopItem("gluon",			ITEMCAT_GUNS,			125,			"weapon_zs_gluon")                                                                                            -- 胶子枪
GM:AddPointShopItem("barrage",			ITEMCAT_GUNS,			125,			"weapon_zs_barrage")                                                                                          -- 弹幕
GM:AddPointShopItem("famass",			ITEMCAT_GUNS,			125,			"weapon_zs_famas_s")                                                                                          -- FAMAS

-- Tier 5：五级武器（价格 175，游戏中最强力的武器）
GM:AddPointShopItem("novacolt",			ITEMCAT_GUNS,			200,			"weapon_zs_novacolt")                                                                                         -- 新星左轮
GM:AddPointShopItem("bulwark",			ITEMCAT_GUNS,			200,			"weapon_zs_bulwark")                                                                                          -- 壁垒
--GM:AddPointShopItem("juggernaut",		ITEMCAT_GUNS,			175,			"weapon_zs_juggernaut")                                                                                      -- 主宰（已禁用）
GM:AddPointShopItem("citadel",	    	ITEMCAT_GUNS,			200,			"weapon_zs_citadel")                                                                                          -- 堡垒
--GM:AddPointShopItem("scar",				ITEMCAT_GUNS,			175,			"weapon_zs_scar")                                                                                             -- SCAR（已禁用）
GM:AddPointShopItem("nexus",			ITEMCAT_GUNS,		    200,			"weapon_zs_nexus")                                                                                            -- 核心 Nexus
GM:AddPointShopItem("tokamak",			ITEMCAT_GUNS,	    	200,			"weapon_zs_tokamak")                                                                                          -- 托卡马克
GM:AddPointShopItem("boomstick",		ITEMCAT_GUNS,			200,			"weapon_zs_boomstick")                                                                                        -- 爆破棍
GM:AddPointShopItem("deathdlrs",		ITEMCAT_GUNS,			200,			"weapon_zs_deathdealers")                                                                                     -- 死亡交易者
GM:AddPointShopItem("hammerdown",		ITEMCAT_GUNS,			200,			"weapon_zs_hammerdown")                                                                                       -- 锤击
GM:AddPointShopItem("colossus",			ITEMCAT_GUNS,			200,			"weapon_zs_colossus")                                                                                         -- 巨像
GM:AddPointShopItem("renegade",			ITEMCAT_GUNS,			200,			"weapon_zs_renegade")                                                                                         -- 叛徒
GM:AddPointShopItem("crossbow",			ITEMCAT_GUNS,			200,			"weapon_zs_crossbow")                                                                                         -- 弩
GM:AddPointShopItem("pulserifle",		ITEMCAT_GUNS,			200,			"weapon_zs_pulserifle")                                                                                       -- 脉冲步枪
GM:AddPointShopItem("spinfusor",		ITEMCAT_GUNS,			200,			"weapon_zs_spinfusor")                                                                                        -- 旋涡
GM:AddPointShopItem("broadside",		ITEMCAT_GUNS,			200,			"weapon_zs_broadside")                                                                                        -- 舷炮
GM:AddPointShopItem("smelter",			ITEMCAT_GUNS,			200,			"weapon_zs_smelter")                                                                                          -- 熔炉
GM:AddPointShopItem("magnum_a",			ITEMCAT_GUNS,			200,			"weapon_zs_magnum_a")                                                                                         -- 马格南 A
--GM:AddPointShopItem("hunter_bear",		ITEMCAT_GUNS,			200,			"weapon_zs_hunter_bear")                                                                                     -- 猎熊者（已禁用）
GM:AddPointShopItem("青峰",			    ITEMCAT_GUNS,			200,			"weapon_zs_electron")                                                                                         -- 青峰（电子步枪）
--GM:AddPointShopItem("Eightyone",		ITEMCAT_GUNS,			200,			"weapon_zs_81")                                                                                              -- 八一（已禁用）
GM:AddPointShopItem("vepr12",	    	ITEMCAT_GUNS,			200,			"weapon_zs_vepr12")                                                                                           -- VEPR12 霰弹枪
--GM:AddPointShopItem("m82a1",	    	ITEMCAT_GUNS,			200,			"weapon_zs_m82a3")                                                                                           -- M82A1（已禁用）

-- ============================================================
-- AMMO_TYPES 弹药类型配置表
-- 定义了积分商店中所有可购买的弹药类型及其参数
-- 每行格式：签名, 显示数量, 实际给予数量, 价格, 弹药类型, 名称翻译键, 模型后缀, 描述键, 描述参数, 可制作标记, 钉子标记
-- ============================================================
local AMMO_TYPES = {
    -- 基础弹药包
    { "pistolammo",     20, 20,  5, "pistol",     "pistol",    "pistol" },                                          -- 手枪弹药
    { "shotgunammo",    16, 16,  5, "buckshot",   "shotgun",   "shotgun" },                                          -- 霰弹枪弹药
    { "smgammo",        45, 45,  5, "smg1",       "smg",       "smg" },                                              -- 冲锋枪弹药
    { "rifleammo",      10,  10,  5, "357",        "rifle",     "rifle" },                                           -- 步枪弹药（.357）
    { "crossbowammo",   10,  10,  5, "XBowBolt",   "bolts",     "bolts" },                                           -- 弩箭弹药
    { "assaultrifleammo",45,45,  5, "ar2",        "assault",   "assault" },                                          -- 突击步枪弹药
    { "pulseammo",      45, 45,  5, "pulse",      "pulse",     "pulse" },                                           -- 脉冲弹药
    { "impactmine",     3,  3,   5, "impactmine", "explosive", "explosive" },                                        -- 冲击地雷弹药
    { "chemical",       20, 20,  5, "chemical",   "chemical",  "chemical" },                                         -- 化学弹药
    { "scrap",          8,8,   14,"scrap",      "scrap",     "scrap", nil, nil, true },                              -- 废料（无数量显示，可制作）
    { "25mkit",         30, 30,  8, "Battery",    "medpower",  "medpower", "medical_desc", {5}, true },              -- 医疗药包（医疗子弹，可制作）
    { "nail",           2,  2,   1, "GaussEnergy","nail",      "nail",    "nail_desc", nil, true, true },            -- 钉子（可制作，经典模式不可用）

    -- 十倍弹药包（x10，批量购买，价格更优惠）
    { "pistolammo_x10",     200, 200,  52, "pistol",     "pistol",    "pistol" },                                   -- 手枪弹药 x10
    { "shotgunammo_x10",    160, 160,  52, "buckshot",   "shotgun",   "shotgun" },                                   -- 霰弹枪弹药 x10
    { "smgammo_x10",        450, 450,  52, "smg1",       "smg",       "smg" },                                       -- 冲锋枪弹药 x10
    { "rifleammo_x10",      100,  100,  52, "357",        "rifle",     "rifle" },                                    -- 步枪弹药 x10
    { "crossbowammo_x10",   100,  100,  52, "XBowBolt",   "bolts",     "bolts" },                                    -- 弩箭弹药 x10
    { "assaultrifleammo_x10",450,450,  52, "ar2",        "assault",   "assault" },                                   -- 突击步枪弹药 x10
    { "pulseammo_x10",      450, 450,  52, "pulse",      "pulse",     "pulse" },                                     -- 脉冲弹药 x10
    { "impactmine_x10",     30,  30,   52, "impactmine", "explosive", "explosive" },                                 -- 冲击地雷 x10
    { "chemical_x10",       200, 200,  52, "chemical",   "chemical",  "chemical" },                                  -- 化学弹药 x10
    { "scrap_x5",       40, 40,  60, "scrap",   "scrap",  "scrap", nil, nil, true },                                 -- 废料 x5（可制作）
    { "nail_x5",           10,  10,   6, "GaussEnergy","nail",      "nail",    "nail_desc", nil, true, true },       -- 钉子 x5（可制作，经典模式不可用）
    { "25mkit_x10",         300, 300,  82, "Battery",    "medpower",  "medpower", "medical_desc", {5}, true },       -- 医疗药包 x10（可制作）
}

-- ============================================================
-- CreateAmmoGenerator() - 弹药商店生成器函数
-- 遍历 AMMO_TYPES 配置表，为每种弹药在积分商店中注册一个购买项
-- 自动处理弹药名称、描述和回调逻辑
-- @param 无（使用闭包变量 AMMO_TYPES）
-- @return 无
-- ============================================================
local function CreateAmmoGenerator()
    -- 遍历 AMMO_TYPES 表中的所有弹药类型数据
    for _, data in ipairs(AMMO_TYPES) do
        -- 解包弹药数据：签名, 显示数量, 实际给予数量, 价格, 弹药类型, 名称键, 模型后缀, 描述键, 描述参数, 废料标记, 钉子标记
        local sig, disp_amt, give_amt, price, ammo_type, name_key, model_suffix, desc_key, desc_args, is_scrap, is_nail = unpack(data)

        -- 生成弹药的显示名称
        -- 如果 disp_amt 存在，则使用格式 "弹药类型 x 数量" 生成名称
        -- 否则直接使用弹药类型的翻译名称
        local name = disp_amt and translate.Format(
            "arsenal_ammo_entry",
            translate.Get("ammo_type_"..name_key),     -- 弹药类型名称（如 "手枪弹药"）
            disp_amt                                    -- 弹药数量（如 20）
        ) or translate.Get("ammo_type_"..name_key)      -- 直接使用弹药类型名称

        -- 生成弹药的描述文本
        local desc
        if desc_key then
            -- 如果 desc_key 存在，则根据是否有 desc_args 决定如何生成描述
            desc = desc_args and translate.Format("arsenal_ammo_"..desc_key, unpack(desc_args))     -- 带参数的描述（如医疗弹药描述含有数字参数）
                or translate.Get("arsenal_ammo_"..desc_key)                                        -- 不带参数的描述
        end

        -- 创建积分商店弹药项
        local item = GAMEMODE:AddPointShopItem(
            sig,                -- 弹药唯一标识符
            ITEMCAT_AMMO,       -- 物品分类（弹药）
            price,              -- 弹药积分价格
            nil,                -- 关联的武器（弹药不需要 SWEP）
            name,               -- 显示名称
            desc,               -- 描述文本
            "ammo_"..model_suffix,  -- 显示模型路径（如 "ammo_pistol"）
            function(pl)
                -- 回调函数：当玩家购买弹药时，给予玩家指定类型和数量的弹药
                pl:GiveAmmo(give_amt, ammo_type, true)
            end
        )

        -- 设置弹药的特殊属性标记
        if is_scrap then
            -- 标记为可通过废料制作
            item.CanMakeFromScrap = true
        end
        if is_nail then
            -- 钉子类型：经典模式不可用，且可通过废料制作
            item.NoClassicMode = true
            item.CanMakeFromScrap = true
        end
    end
end

-- ============================================================
-- 在游戏初始化时调用 CreateAmmoGenerator 函数，注册所有弹药商店项
-- 使用 Initialize 钩子确保在合适的时机执行
-- ============================================================
hook.Add("Initialize", "LoadAmmoItems", CreateAmmoGenerator)

-- ============================================================
-- 积分商店物品注册 - 近战武器类（PointShop）
-- 近战武器按等级划分，从基础到高级
-- Tier 1：基础近战（价格 10-15）
-- ============================================================
GM:AddPointShopItem("brassknuckles",	ITEMCAT_MELEE,			10,				"weapon_zs_brassknuckles").Model = "models/props_c17/utilityconnecter005.mdl"  -- 指虎
GM:AddPointShopItem("knife",			ITEMCAT_MELEE,			10,				"weapon_zs_swissarmyknife")                                                     -- 瑞士军刀
GM:AddPointShopItem("zpplnk",			ITEMCAT_MELEE,			10,				"weapon_zs_plank")                                                              -- 木板
GM:AddPointShopItem("axe",				ITEMCAT_MELEE,			15,				"weapon_zs_axe")                                                                -- 斧头
GM:AddPointShopItem("zpfryp",			ITEMCAT_MELEE,			15,				"weapon_zs_fryingpan")                                                          -- 平底锅
GM:AddPointShopItem("zpcpot",			ITEMCAT_MELEE,			15,				"weapon_zs_pot")                                                                -- 锅
GM:AddPointShopItem("ladel",			ITEMCAT_MELEE,			15,				"weapon_zs_ladel")                                                              -- 勺子
GM:AddPointShopItem("crowbar",			ITEMCAT_MELEE,			15,				"weapon_zs_crowbar")                                                            -- 撬棍
GM:AddPointShopItem("pipe",				ITEMCAT_MELEE,			15,				"weapon_zs_pipe")                                                               -- 水管
GM:AddPointShopItem("stunbaton",		ITEMCAT_MELEE,			15,				"weapon_zs_stunbaton")                                                          -- 电击棒
GM:AddPointShopItem("hook",				ITEMCAT_MELEE,			15,				"weapon_zs_hook")                                                               -- 钩子

-- Tier 2：中级近战（价格 30-50）
GM:AddPointShopItem("broom",			ITEMCAT_MELEE,			30,				"weapon_zs_pushbroom")                                                          -- 扫帚
GM:AddPointShopItem("shovel",			ITEMCAT_MELEE,			30,				"weapon_zs_shovel")                                                             -- 铁锹
GM:AddPointShopItem("sledgehammer",		ITEMCAT_MELEE,			30,				"weapon_zs_sledgehammer")                                                       -- 大锤
GM:AddPointShopItem("harpoon",			ITEMCAT_MELEE,			30,				"weapon_zs_harpoon")                                                            -- 鱼叉
GM:AddPointShopItem("harpoon_te",		ITEMCAT_MELEE,			50,				"weapon_zs_harpoon_te")                                                         -- 泰斯拉鱼叉
GM:AddPointShopItem("teslakatana",		ITEMCAT_MELEE,			50,				"weapon_zs_teslakatana")                                                        -- 特斯拉武士刀
GM:AddPointShopItem("butcherknf",		ITEMCAT_MELEE,			30,				"weapon_zs_butcherknife")                                                       -- 屠夫刀

-- Tier 3：高级近战（价格 60）
GM:AddPointShopItem("longsword",		ITEMCAT_MELEE,			60,				"weapon_zs_longsword")                                                          -- 长剑
GM:AddPointShopItem("executioner",		ITEMCAT_MELEE,			60,				"weapon_zs_executioner")                                                        -- 刽子手
GM:AddPointShopItem("rebarmace",		ITEMCAT_MELEE,			60,				"weapon_zs_rebarmace")                                                          -- 钢筋锤
GM:AddPointShopItem("meattenderizer",	ITEMCAT_MELEE,			60,				"weapon_zs_meattenderizer")                                                     -- 嫩肉锤
GM:AddPointShopItem("katana",       	ITEMCAT_MELEE,			60,			    "weapon_zs_katana")                                                             -- 武士刀

-- Tier 4：顶级近战（价格 85-100）
GM:AddPointShopItem("graveshvl",		ITEMCAT_MELEE,			100,			"weapon_zs_graveshovel")                                                        -- 坟墓铲
GM:AddPointShopItem("kongol",			ITEMCAT_MELEE,			100,			"weapon_zs_kongolaxe")                                                          -- 刚果斧
GM:AddPointShopItem("scythe",			ITEMCAT_MELEE,			100,			"weapon_zs_scythe")                                                             -- 镰刀
GM:AddPointShopItem("powerfists",		ITEMCAT_MELEE,			100,			"weapon_zs_powerfists")                                                         -- 动力拳套
GM:AddPointShopItem("energysword",		ITEMCAT_MELEE,			100,			"weapon_zs_energysword")                                                        -- 能量剑
GM:AddPointShopItem("kongolaxesp",		ITEMCAT_MELEE,			85,		    	"weapon_zs_kongolaxe_sp")                                                       -- 刚果斧 SP

-- 特殊近战武器（价格 135）
GM:AddPointShopItem("血狱之剑",         ITEMCAT_MELEE,			135,			"weapon_zs_firesword")                                                          -- 血剑（烈焰之剑）
GM:AddPointShopItem("黄金之剑",         ITEMCAT_MELEE,			135,			"weapon_firesword_x")                                                           -- 金剑

-- Tier 5：终极近战（价格 125-160）
GM:AddPointShopItem("frotchet",			ITEMCAT_MELEE,			150,			"weapon_zs_frotchet")                                                           -- 飞镖
GM:AddPointShopItem("harpoon_sp",		ITEMCAT_MELEE,			125,			"weapon_zs_harpoon_sp")                                                         -- 鱼叉 SP
GM:AddPointShopItem("telepor",	    	ITEMCAT_MELEE,			160,			"weapon_zs_teleportationdagger")                                                -- 传送匕首

-- ============================================================
-- 积分商店物品注册 - 工具与可部署物类（PointShop）
-- 包括各种功能性工具和可部署实体
-- ============================================================
GM:AddPointShopItem("suicideboom",			ITEMCAT_TOOLS,			75,				"weapon_zs_suicidebomb",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_suicidebomb") end)  -- 自杀炸弹

GM:AddPointShopItem("crphmr_sp",			ITEMCAT_TOOLS,			65,				"weapon_zs_hammer_sp",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_hammer_sp") pl:GiveAmmo(5, "GaussEnergy") end)  -- 锤子 SP

GM:AddPointShopItem("crphmr",			ITEMCAT_TOOLS,			25,				"weapon_zs_hammer",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_hammer") pl:GiveAmmo(5, "GaussEnergy") end)  -- 锤子
GM:AddPointShopItem("wrench",			ITEMCAT_TOOLS,			20,				"weapon_zs_wrench").NoClassicMode = true                                                                  -- 扳手（经典模式不可用）
GM:AddPointShopItem("arsenalcrate",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_arsenalcrate").Countables = "prop_arsenalcrate"                    -- 军械库箱子
GM:AddPointShopItem("resupplybox",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_resupplybox").Countables = "prop_resupplybox"                      -- 补给箱
GM:AddPointShopItem("remantler",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_remantler").Countables = "prop_remantler"                          -- 武器拆解器
GM:AddPointShopItem("msgbeacon",		ITEMCAT_DEPLOYABLES,			10,				"weapon_zs_messagebeacon").Countables = "prop_messagebeacon"                  -- 信息信标
GM:AddPointShopItem("camera",			ITEMCAT_DEPLOYABLES,			15,				"weapon_zs_camera").Countables = "prop_camera"                                -- 摄像头
GM:AddPointShopItem("tv",				ITEMCAT_DEPLOYABLES,			25,				"weapon_zs_tv").Countables = "prop_tv"                                        -- 电视
item =
-- 机枪炮塔
GM:AddPointShopItem("infturret",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_gunturret",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret") pl:GiveAmmo(1, "thumper") end)
item.NoClassicMode = true
item.Countables = "prop_gunturret"
item =
-- 霰弹炮塔
GM:AddPointShopItem("blastturret",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_gunturret_buckshot",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_buckshot") pl:GiveAmmo(1, "turret_buckshot") end)
item.Countables = "prop_gunturret_buckshot"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_BLASTTURRET
item =
-- 突击炮塔
GM:AddPointShopItem("assaultturret",	ITEMCAT_DEPLOYABLES,			125,			"weapon_zs_gunturret_assault",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_assault") pl:GiveAmmo(1, "turret_assault") end)
item.NoClassicMode = true
item.Countables = "prop_gunturret_assault"
item =
-- 火箭炮塔
GM:AddPointShopItem("rocketturret",		ITEMCAT_DEPLOYABLES,			125,			"weapon_zs_gunturret_rocket",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_rocket") pl:GiveAmmo(1, "turret_rocket") end)
item.Countables = "prop_gunturret_rocket"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_ROCKETTURRET
item =
-- 冰冻炮塔
GM:AddPointShopItem("freezeturret",		ITEMCAT_DEPLOYABLES,			70,				"weapon_zs_gunturret_freeze",	nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_gunturret_freeze") pl:GiveAmmo(1, "turret_pulse") end)
item.NoClassicMode = true
item.Countables = "prop_gunturret_pulse"
GM:AddPointShopItem("manhack",			ITEMCAT_DEPLOYABLES,			30,				"weapon_zs_manhack").Countables = "prop_manhack"                              -- 猎杀无人机
item =
GM:AddPointShopItem("drone",			ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_drone")                                                            -- 无人机
item.Countables = "prop_drone"
item =
GM:AddPointShopItem("pulsedrone",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_drone_pulse")                                                      -- 脉冲无人机
item.Countables = "prop_drone_pulse"
item.SkillRequirement = SKILL_U_DRONE
item =
GM:AddPointShopItem("hauldrone",		ITEMCAT_DEPLOYABLES,			15,				"weapon_zs_drone_hauler")                                                     -- 搬运无人机
item.Countables = "prop_drone_hauler"
item.SkillRequirement = SKILL_HAULMODULE
item =
GM:AddPointShopItem("rollermine",		ITEMCAT_DEPLOYABLES,			35,				"weapon_zs_rollermine")                                                       -- 滚雷
item.Countables = "prop_rollermine"
item.SkillRequirement = SKILL_U_ROLLERMINE

item =
-- 修复场发射器
GM:AddPointShopItem("repairfield",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_repairfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_repairfield") pl:GiveAmmo(1, "repairfield") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_repairfield"
item.NoClassicMode = true

item =
-- 医疗场发射器
GM:AddPointShopItem("medicfield",		ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_medicfield",		nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_medicfield") pl:GiveAmmo(1, "medicfield") pl:GiveAmmo(60, "Battery") end)
item.Countables = "prop_medicfield"
item.NoClassicMode = true

item =
-- 电击器（标准）
GM:AddPointShopItem("zapper",			ITEMCAT_DEPLOYABLES,			50,				"weapon_zs_zapper",				nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_zapper") pl:GiveAmmo(1, "zapper") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_zapper"
item.NoClassicMode = true
item =
-- 电弧电击器
GM:AddPointShopItem("zapper_arc",		ITEMCAT_DEPLOYABLES,			100,			"weapon_zs_zapper_arc",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_zapper_arc") pl:GiveAmmo(1, "zapper_arc") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_zapper_arc"
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_ZAPPER_ARC
item =
-- 力场发射器
GM:AddPointShopItem("ffemitter",		ITEMCAT_DEPLOYABLES,			40,				"weapon_zs_ffemitter",			nil,							nil,									nil,											function(pl) pl:GiveEmptyWeapon("weapon_zs_ffemitter") pl:GiveAmmo(1, "slam") pl:GiveAmmo(30, "pulse") end)
item.Countables = "prop_ffemitter"
GM:AddPointShopItem("propanetank",		ITEMCAT_TOOLS,			15,				"comp_propanecan")                                                            -- 丙烷罐
GM:AddPointShopItem("busthead",			ITEMCAT_TOOLS,			25,				"comp_busthead")                                                              -- 半身像
GM:AddPointShopItem("sawblade",			ITEMCAT_TOOLS,			30,				"comp_sawblade").SkillRequirement = SKILL_U_CRAFTINGPACK                      -- 锯片（需要制作包技能）
GM:AddPointShopItem("cpuparts",			ITEMCAT_TOOLS,			30,				"comp_cpuparts").SkillRequirement = SKILL_U_CRAFTINGPACK                      -- CPU零件（需要制作包技能）
GM:AddPointShopItem("electrobattery",	ITEMCAT_TOOLS,			40,				"comp_electrobattery").SkillRequirement = SKILL_U_CRAFTINGPACK                -- 电磁电池（需要制作包技能）
GM:AddPointShopItem("barricadekit",		ITEMCAT_DEPLOYABLES,	60,				"weapon_zs_barricadekit")                                                     -- 路障工具包（宙斯盾）
GM:AddPointShopItem("medkit",			ITEMCAT_TOOLS,			15,				"weapon_zs_medicalkit")                                                       -- 医疗包
GM:AddPointShopItem("medgun",			ITEMCAT_TOOLS,			30,				"weapon_zs_medicgun")                                                         -- 治疗枪
item =
GM:AddPointShopItem("strengthshot",		ITEMCAT_TOOLS,			30,				"weapon_zs_strengthshot")                                                     -- 力量注射剂
item.SkillRequirement = SKILL_U_STRENGTHSHOT
item =
GM:AddPointShopItem("antidote",			ITEMCAT_TOOLS,			30,				"weapon_zs_antidoteshot")                                                     -- 解毒注射剂
item.SkillRequirement = SKILL_U_ANTITODESHOT
GM:AddPointShopItem("medrifle",			ITEMCAT_TOOLS,			55,				"weapon_zs_medicrifle")                                                       -- 治疗步枪
GM:AddPointShopItem("healray",			ITEMCAT_TOOLS,			125,			"weapon_zs_healingray")                                                       -- 治疗射线
GM:AddPointShopItem("junkpack",			ITEMCAT_DEPLOYABLES,	40,				"weapon_zs_boardpack")                                                        -- 垃圾包（木板包）

-- ============================================================
-- 积分商店物品注册 - 饰品/小玩意类（PointShop）
-- 饰品按等级（Tier 1-5）和子分类划分，提供各种被动加成
-- 每个饰品都通过 .SubCategory 指定其子分类
-- ============================================================
-- Tier 1：基础饰品（价格 10）
GM:AddPointShopItem("cutlery",			ITEMCAT_TRINKETS,		10,				"trinket_cutlery").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 餐具（防御）
GM:AddPointShopItem("boxingtraining",	ITEMCAT_TRINKETS,		10,				"trinket_boxingtraining").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE              -- 拳击训练（近战）
GM:AddPointShopItem("hemoadrenali",		ITEMCAT_TRINKETS,		10,				"trinket_hemoadrenali").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE              -- 血肾上腺素 I（近战）
GM:AddPointShopItem("oxtank",			ITEMCAT_TRINKETS,		10,				"trinket_oxygentank").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 氧气罐（性能）
GM:AddPointShopItem("acrobatframe",		ITEMCAT_TRINKETS,		10,				"trinket_acrobatframe").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 特技骨架（性能）
GM:AddPointShopItem("portablehole",		ITEMCAT_TRINKETS,		10,				"trinket_portablehole").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 便携洞（性能）
GM:AddPointShopItem("magnet",			ITEMCAT_TRINKETS,		10,				"trinket_magnet").SubCategory =									ITEMSUBCAT_TRINKETS_SPECIAL            -- 磁铁（特殊）
GM:AddPointShopItem("targetingvisi",	ITEMCAT_TRINKETS,		10,				"trinket_targetingvisori").SubCategory =						ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 瞄准镜 I（进攻）
GM:AddPointShopItem("pulseampi",		ITEMCAT_TRINKETS,		10,				"trinket_pulseampi").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 脉冲增幅器 I（进攻）

-- Tier 2：中级饰品（价格 15）
GM:AddPointShopItem("momentumsupsysii",	ITEMCAT_TRINKETS,		15,				"trinket_momentumsupsysii").SubCategory =						ITEMSUBCAT_TRINKETS_MELEE              -- 动量支撑系统 II（近战）
GM:AddPointShopItem("sharpkit",			ITEMCAT_TRINKETS,		15,				"trinket_sharpkit").SubCategory =								ITEMSUBCAT_TRINKETS_MELEE              -- 磨刀工具（近战）
GM:AddPointShopItem("nightvision",		ITEMCAT_TRINKETS,		15,				"trinket_nightvision").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 夜视仪（性能）
GM:AddPointShopItem("loadingframe",		ITEMCAT_TRINKETS,		15,				"trinket_loadingex").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 负重骨架（性能）
GM:AddPointShopItem("pathfinder",		ITEMCAT_TRINKETS,		15,				"trinket_pathfinder").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 寻路者（性能）
GM:AddPointShopItem("ammovestii",		ITEMCAT_TRINKETS,		15,				"trinket_ammovestii").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 弹药背心 II（进攻）
GM:AddPointShopItem("olympianframe",	ITEMCAT_TRINKETS,		15,				"trinket_olympianframe").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 奥林匹克骨架（进攻）
GM:AddPointShopItem("autoreload",		ITEMCAT_TRINKETS,		15,				"trinket_autoreload").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 自动装填（进攻）
GM:AddPointShopItem("curbstompers",		ITEMCAT_TRINKETS,		15,				"trinket_curbstompers").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 路沿踩踏者（进攻）
GM:AddPointShopItem("vitpackagei",		ITEMCAT_TRINKETS,		15,				"trinket_vitpackagei").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 维他命包 I（防御）
GM:AddPointShopItem("cardpackagei",		ITEMCAT_TRINKETS,		15,				"trinket_cardpackagei").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 心脏包 I（防御）
GM:AddPointShopItem("forcedamp",		ITEMCAT_TRINKETS,		15,				"trinket_forcedamp").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 力场阻尼器（防御）
GM:AddPointShopItem("kevlar",			ITEMCAT_TRINKETS,		15,				"trinket_kevlar").SubCategory =									ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 凯夫拉护甲（防御）
GM:AddPointShopItem("antitoxinpack",	ITEMCAT_TRINKETS,		15,				"trinket_antitoxinpack").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 抗毒素包（防御）
GM:AddPointShopItem("hemostasis",		ITEMCAT_TRINKETS,		15,				"trinket_hemostasis").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 止血器（防御）
GM:AddPointShopItem("bloodpack",		ITEMCAT_TRINKETS,		15,				"trinket_bloodpack").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 血包（防御）
GM:AddPointShopItem("reactiveflasher",	ITEMCAT_TRINKETS,		15,				"trinket_reactiveflasher").SubCategory =						ITEMSUBCAT_TRINKETS_SPECIAL            -- 反应闪光器（特殊）
GM:AddPointShopItem("iceburst",			ITEMCAT_TRINKETS,		15,				"trinket_iceburst").SubCategory =								ITEMSUBCAT_TRINKETS_SPECIAL            -- 冰霜爆发（特殊）
GM:AddPointShopItem("biocleanser",		ITEMCAT_TRINKETS,		15,				"trinket_biocleanser").SubCategory =							ITEMSUBCAT_TRINKETS_SPECIAL            -- 生物清洁剂（特殊）
GM:AddPointShopItem("necrosense",		ITEMCAT_TRINKETS,		15,				"trinket_necrosense").SubCategory =								ITEMSUBCAT_TRINKETS_SPECIAL            -- 死亡感知（特殊）
GM:AddPointShopItem("blueprintsi",		ITEMCAT_TRINKETS,		15,				"trinket_blueprintsi").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT            -- 蓝图 I（支援）
GM:AddPointShopItem("processor",		ITEMCAT_TRINKETS,		15,				"trinket_processor").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT            -- 处理器（支援）
GM:AddPointShopItem("acqmanifest",		ITEMCAT_TRINKETS,		15,				"trinket_acqmanifest").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT            -- 获取清单（支援）
GM:AddPointShopItem("mainsuite",		ITEMCAT_TRINKETS,		15,				"trinket_mainsuite").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT            -- 主控套件（支援）

-- Tier 3：高级饰品（价格 30）
--GM:AddPointShopItem("climbinggear",	ITEMCAT_TRINKETS,		30,				"trinket_climbinggear").SubCategory =							ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 攀爬装备（性能，已禁用）
GM:AddPointShopItem("reachem",			ITEMCAT_TRINKETS,		30,				"trinket_reachem").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 反应增强（进攻）
GM:AddPointShopItem("momentumsupsysiii",ITEMCAT_TRINKETS,		30,				"trinket_momentumsupsysiii").SubCategory =						ITEMSUBCAT_TRINKETS_MELEE              -- 动量支撑系统 III（近战）
GM:AddPointShopItem("powergauntlet",	ITEMCAT_TRINKETS,		30,				"trinket_powergauntlet").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE              -- 能量护手（近战）
GM:AddPointShopItem("hemoadrenalii",	ITEMCAT_TRINKETS,		30,				"trinket_hemoadrenalii").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE              -- 血肾上腺素 II（近战）
GM:AddPointShopItem("sharpstone",		ITEMCAT_TRINKETS,		30,				"trinket_sharpstone").SubCategory =								ITEMSUBCAT_TRINKETS_MELEE              -- 磨刀石（近战）
GM:AddPointShopItem("analgestic",		ITEMCAT_TRINKETS,		30,				"trinket_analgestic").SubCategory =								ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 镇痛剂（性能）
GM:AddPointShopItem("feathfallframe",	ITEMCAT_TRINKETS,		30,				"trinket_featherfallframe").SubCategory =						ITEMSUBCAT_TRINKETS_PERFORMANCE        -- 羽落骨架（性能）
GM:AddPointShopItem("aimcomp",			ITEMCAT_TRINKETS,		30,				"trinket_aimcomp").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 瞄准补偿器（进攻）
GM:AddPointShopItem("pulseampii",		ITEMCAT_TRINKETS,		30,				"trinket_pulseampii").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 脉冲增幅器 II（进攻）
GM:AddPointShopItem("extendedmag",		ITEMCAT_TRINKETS,		30,				"trinket_extendedmag").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 扩容弹匣（进攻）
GM:AddPointShopItem("vitpackageii",		ITEMCAT_TRINKETS,		30,				"trinket_vitpackageii").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 维他命包 II（防御）
GM:AddPointShopItem("cardpackageii",	ITEMCAT_TRINKETS,		30,				"trinket_cardpackageii").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 心脏包 II（防御）
GM:AddPointShopItem("regenimplant",		ITEMCAT_TRINKETS,		30,				"trinket_regenimplant").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 再生植入体（防御）
GM:AddPointShopItem("barbedarmor",		ITEMCAT_TRINKETS,		30,				"trinket_barbedarmor").SubCategory =							ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 倒刺护甲（防御）
GM:AddPointShopItem("blueprintsii",		ITEMCAT_TRINKETS,		30,				"trinket_blueprintsii").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT            -- 蓝图 II（支援）
GM:AddPointShopItem("curativeii",		ITEMCAT_TRINKETS,		30,				"trinket_curativeii").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT            -- 治疗 II（支援）
GM:AddPointShopItem("remedy",			ITEMCAT_TRINKETS,		30,				"trinket_remedy").SubCategory =									ITEMSUBCAT_TRINKETS_SUPPORT            -- 治疗药（支援）

-- Tier 4：顶级饰品（价格 50）
GM:AddPointShopItem("hemoadrenaliii",	ITEMCAT_TRINKETS,		50,				"trinket_hemoadrenaliii").SubCategory =							ITEMSUBCAT_TRINKETS_MELEE              -- 血肾上腺素 III（近战）
GM:AddPointShopItem("ammoband",			ITEMCAT_TRINKETS,		50,				"trinket_ammovestiii").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 弹药背带（进攻）
GM:AddPointShopItem("resonance",		ITEMCAT_TRINKETS,		50,				"trinket_resonance").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 谐振（进攻）
GM:AddPointShopItem("cryoindu",			ITEMCAT_TRINKETS,		50,				"trinket_cryoindu").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 冷冻诱导（进攻）
GM:AddPointShopItem("refinedsub",		ITEMCAT_TRINKETS,		50,				"trinket_refinedsub").SubCategory =								ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 精炼替代物（进攻）
GM:AddPointShopItem("targetingvisiii",	ITEMCAT_TRINKETS,		50,				"trinket_targetingvisoriii").SubCategory =						ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 瞄准镜 III（进攻）
GM:AddPointShopItem("eodvest",			ITEMCAT_TRINKETS,		50,				"trinket_eodvest").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 排爆背心（防御）
GM:AddPointShopItem("composite",		ITEMCAT_TRINKETS,		50,				"trinket_composite").SubCategory =								ITEMSUBCAT_TRINKETS_DEFENSIVE          -- 复合材料（防御）
GM:AddPointShopItem("arsenalpack",		ITEMCAT_TRINKETS,		50,				"trinket_arsenalpack").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT            -- 军械库背包（支援）
GM:AddPointShopItem("resupplypack",		ITEMCAT_TRINKETS,		50,				"trinket_resupplypack").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT            -- 补给背包（支援）
GM:AddPointShopItem("promanifest",		ITEMCAT_TRINKETS,		50,				"trinket_promanifest").SubCategory =							ITEMSUBCAT_TRINKETS_SUPPORT            -- 专业清单（支援）
GM:AddPointShopItem("opsmatrix",		ITEMCAT_TRINKETS,		50,				"trinket_opsmatrix").SubCategory =								ITEMSUBCAT_TRINKETS_SUPPORT            -- 运算矩阵（支援）

-- Tier 5：终极饰品（价格 70）
GM:AddPointShopItem("supasm",			ITEMCAT_TRINKETS,		70,				"trinket_supasm").SubCategory =									ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 超级瞄准（进攻）
GM:AddPointShopItem("pulseimpedance",	ITEMCAT_TRINKETS,		70,				"trinket_pulseimpedance").SubCategory =							ITEMSUBCAT_TRINKETS_OFFENSIVE          -- 脉冲阻抗（进攻）

-- ============================================================
-- 积分商店物品注册 - 其他类（投掷物和特殊物品）
-- ============================================================
GM:AddPointShopItem("flashbomb",		ITEMCAT_OTHER,			15,				"weapon_zs_flashbomb")                                          -- 闪光弹
GM:AddPointShopItem("molotov",			ITEMCAT_OTHER,			30,				"weapon_zs_molotov")                                            -- 燃烧瓶
GM:AddPointShopItem("grenade",			ITEMCAT_OTHER,			35,				"weapon_zs_grenade")                                            -- 手雷
GM:AddPointShopItem("betty",			ITEMCAT_OTHER,			35,				"weapon_zs_proxymine")                                          -- 跳雷
GM:AddPointShopItem("detpck",			ITEMCAT_OTHER,			40,				"weapon_zs_detpack")                                            -- 遥控炸药包
item =
GM:AddPointShopItem("crygasgrenade",	ITEMCAT_OTHER,			40,				"weapon_zs_crygasgrenade")                                      -- 冷冻气体手雷
item.SkillRequirement = SKILL_U_CRYGASGREN
GM:AddPointShopItem("corgasgrenade",	ITEMCAT_OTHER,			45,				"weapon_zs_corgasgrenade")                                      -- 腐蚀气体手雷
GM:AddPointShopItem("sigfragment",		ITEMCAT_OTHER,			30,				"weapon_zs_sigilfragment")                                      -- 印记碎片
GM:AddPointShopItem("bloodshot",		ITEMCAT_OTHER,			35,				"weapon_zs_bloodshotbomb")                                      -- 血甲手雷
item =
GM:AddPointShopItem("corruptedfragment",ITEMCAT_OTHER,			55,				"weapon_zs_corruptedfragment")                                  -- 腐化碎片
item.NoClassicMode = true
item.SkillRequirement = SKILL_U_CORRUPTEDFRAGMENT
item =
GM:AddPointShopItem("medcloud",			ITEMCAT_OTHER,			25,				"weapon_zs_mediccloudbomb")                                     -- 治疗云炸弹
item.SkillRequirement = SKILL_U_MEDICCLOUD
item =
GM:AddPointShopItem("nanitecloud",		ITEMCAT_OTHER,			25,				"weapon_zs_nanitecloudbomb")                                    -- 纳米修复云炸弹
item.SkillRequirement = SKILL_U_NANITECLOUD

-- ============================================================
-- genericcallback() - 荣誉提及通用回调函数
-- 玩家的荣誉提及默认使用此回调来生成显示文本
-- @param pl (Player) 玩家对象
-- @param magnitude (number) 数值（如击杀数、伤害量等）
-- @return (string, number) 返回玩家名称和数值
-- ============================================================
local function genericcallback(pl, magnitude) return pl:Name(), magnitude end

-- ============================================================
-- GM.HonorableMentions - 荣誉提及系统配置
-- 在回合结束时显示，表彰玩家在本回合中的特殊表现
-- 每个条目包含：显示名称、格式化字符串、回调函数和显示颜色
-- HM_ 常量在 sh_globals.lua 中定义
-- ============================================================
GM.HonorableMentions = {}
GM.HonorableMentions[HM_MOSTZOMBIESKILLED] = {Name = ""..translate.Get("honorpanel_most_zombies_killed"), String = ""..translate.Get("honorpanel_most_zombies_killed_string"), Callback = genericcallback, Color = COLOR_CYAN}          -- 最多僵尸击杀（幸存者）
GM.HonorableMentions[HM_MOSTDAMAGETOUNDEAD] = {Name = translate.Get("honorpanel_most_damage_to_undead"), String = translate.Get("honorpanel_most_damage_to_undead_string"), Callback = genericcallback, Color = COLOR_CYAN}              -- 对亡灵造成最多伤害
GM.HonorableMentions[HM_MOSTHEADSHOTS] = {Name = translate.Get("honorpanel_most_headshots"), String = translate.Get("honorpanel_most_headshots_string"), Callback = genericcallback, Color = COLOR_CYAN}                                  -- 最多爆头
GM.HonorableMentions[HM_PACIFIST] = {Name = translate.Get("honorpanel_pacifist"), String = translate.Get("honorpanel_pacifist_string"), Callback = genericcallback, Color = COLOR_CYAN}                                                    -- 和平主义者（未造成伤害的幸存者）
GM.HonorableMentions[HM_MOSTHELPFUL] = {Name = translate.Get("honorpanel_most_helpful"), String = translate.Get("honorpanel_most_helpful_string"), Callback = genericcallback, Color = COLOR_CYAN}                                        -- 最有帮助
GM.HonorableMentions[HM_LASTHUMAN] = {Name = translate.Get("honorpanel_last_human"), String = translate.Get("honorpanel_last_human_string"), Callback = genericcallback, Color = COLOR_CYAN}                                              -- 最后幸存者
GM.HonorableMentions[HM_OUTLANDER] = {Name = translate.Get("honorpanel_outlander"), String = translate.Get("honorpanel_outlander_string"), Callback = genericcallback, Color = COLOR_CYAN}                                                -- 异乡人
GM.HonorableMentions[HM_GOODDOCTOR] = {Name = translate.Get("honorpanel_good_doctor"), String = translate.Get("honorpanel_good_doctor_string"), Callback = genericcallback, Color = COLOR_CYAN}                                           -- 好医生（治疗最多）
GM.HonorableMentions[HM_HANDYMAN] = {Name = translate.Get("honorpanel_handy_man"), String = translate.Get("honorpanel_handy_man_string"), Callback = genericcallback, Color = COLOR_CYAN}                                                 -- 巧手（建造最多）
GM.HonorableMentions[HM_SCARECROW] = {Name = translate.Get("honorpanel_scarecrow"), String = translate.Get("honorpanel_scarecrow_string"), Callback = genericcallback, Color = COLOR_WHITE}                                               -- 稻草人（伤害吸收最多）
GM.HonorableMentions[HM_MOSTBRAINSEATEN] = {Name = translate.Get("honorpanel_most_brains_eaten"), String = translate.Get("honorpanel_most_brains_eaten_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}                     -- 最多脑浆（僵尸）
GM.HonorableMentions[HM_MOSTDAMAGETOHUMANS] = {Name = translate.Get("honorpanel_most_damage_to_humans"), String = translate.Get("honorpanel_most_damage_to_humans_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}           -- 对人类造成最多伤害（僵尸）
GM.HonorableMentions[HM_LASTBITE] = {Name = translate.Get("honorpanel_last_bite"), String = translate.Get("honorpanel_last_bite_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}                                            -- 最后一咬（最终感染者的僵尸）
GM.HonorableMentions[HM_USEFULTOOPPOSITE] = {Name = translate.Get("honorpanel_useful_to_opposite"), String = translate.Get("honorpanel_useful_to_opposite_string"), Callback = genericcallback, Color = COLOR_RED}                         -- 帮倒忙
GM.HonorableMentions[HM_STUPID] = {Name = translate.Get("honorpanel_stupid"), String = translate.Get("honorpanel_stupid_string"), Callback = genericcallback, Color = COLOR_RED}                                                           -- 最蠢操作
GM.HonorableMentions[HM_SALESMAN] = {Name = translate.Get("honorpanel_salesman"), String = translate.Get("honorpanel_salesman_string"), Callback = genericcallback, Color = COLOR_CYAN}                                                    -- 推销员
GM.HonorableMentions[HM_WAREHOUSE] = {Name = translate.Get("honorpanel_warehouse"), String = translate.Get("honorpanel_warehouse_string"), Callback = genericcallback, Color = COLOR_CYAN}                                                -- 仓库管理员
GM.HonorableMentions[HM_DEFENCEDMG] = {Name = translate.Get("honorpanel_defender"), String = translate.Get("honorpanel_defender_string"), Callback = genericcallback, Color = COLOR_WHITE}                                                -- 防御者
GM.HonorableMentions[HM_STRENGTHDMG] = {Name = translate.Get("honorpanel_alchemist"), String = translate.Get("honorpanel_alchemist_string"), Callback = genericcallback, Color = COLOR_CYAN}                                              -- 炼金术士
GM.HonorableMentions[HM_BARRICADEDESTROYER] = {Name = translate.Get("honorpanel_barricade_destroyer"), String = translate.Get("honorpanel_barricade_destroyer_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}              -- 路障破坏者（僵尸）
GM.HonorableMentions[HM_NESTDESTROYER] = {Name = translate.Get("honorpanel_nest_destroyer"), String = translate.Get("honorpanel_nest_destroyer_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}                              -- 巢穴破坏者
GM.HonorableMentions[HM_NESTMASTER] = {Name = translate.Get("honorpanel_nest_master"), String = translate.Get("honorpanel_nest_master_string"), Callback = genericcallback, Color = COLOR_LIMEGREEN}                                      -- 巢穴大师

-- ============================================================
-- GM.RestrictedModels - 受限玩家模型列表
-- 人类玩家不能使用这些模型，因为它们看起来像亡灵/僵尸模型
-- 所有模型名称必须为小写形式
-- ============================================================
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

-- ============================================================
-- GM.RandomPlayerModels - 随机玩家模型列表（自动生成）
-- 如果玩家没有指定模型，系统会从此列表中随机选择一个
-- 自动排除受限制的模型，只保留人类可用的模型
-- ============================================================
GM.RandomPlayerModels = {}
for name, mdl in pairs(player_manager.AllValidModels()) do
	-- 检查模型是否在受限列表中，如果不在则添加到可用模型列表
	if not table.HasValue(GM.RestrictedModels, string.lower(mdl)) then
		table.insert(GM.RandomPlayerModels, name)
	end
end

-- ============================================================
-- GM.DeployableInfo / GM:AddDeployableInfo() - 可部署物信息注册系统
-- 用于存储所有可部署物的信息，包括实体类名、显示名称和对应的武器类名
-- @param class (string) 实体类名（如 "prop_arsenalcrate"）
-- @param name (string) 可部署物的显示名称
-- @param wepclass (string) 对应的武器 SWEP 类名
-- @return table 返回创建的信息数据表
-- ============================================================
GM.DeployableInfo = {}
function GM:AddDeployableInfo(class, name, wepclass)
	local tab = {Class = class, Name = name or "?", WepClass = wepclass}

	-- 同时以数字索引和类名索引方式存储
	self.DeployableInfo[#self.DeployableInfo + 1] = tab
	self.DeployableInfo[class] = tab

	return tab
end

-- 注册所有可部署物的信息
GM:AddDeployableInfo("prop_arsenalcrate", 		"Arsenal Crate", 		"weapon_zs_arsenalcrate")             -- 军械库箱子
GM:AddDeployableInfo("prop_resupplybox", 		"Resupply Box", 		"weapon_zs_resupplybox")              -- 补给箱
GM:AddDeployableInfo("prop_remantler", 			"Weapon Remantler", 	"weapon_zs_remantler")                -- 武器拆解器
GM:AddDeployableInfo("prop_messagebeacon", 		"Message Beacon", 		"weapon_zs_messagebeacon")            -- 信息信标
GM:AddDeployableInfo("prop_camera", 			"Camera",	 			"weapon_zs_camera")                   -- 摄像头
GM:AddDeployableInfo("prop_gunturret", 			"Gun Turret",	 		"weapon_zs_gunturret")                -- 机枪炮塔
GM:AddDeployableInfo("prop_gunturret_assault", 	"Assault Turret",	 	"weapon_zs_gunturret_assault")        -- 突击炮塔
GM:AddDeployableInfo("prop_gunturret_buckshot",	"Blast Turret",	 		"weapon_zs_gunturret_buckshot")       -- 霰弹炮塔
GM:AddDeployableInfo("prop_gunturret_pulse",	"Freeze Turret",	 	"weapon_zs_gunturret_freeze")         -- 冰冻炮塔
GM:AddDeployableInfo("prop_gunturret_rocket",	"Rocket Turret",	 	"weapon_zs_gunturret_rocket")         -- 火箭炮塔
GM:AddDeployableInfo("prop_repairfield",		"Repair Field Emitter",	"weapon_zs_repairfield")              -- 修复场发射器
GM:AddDeployableInfo("prop_medicfield",		    "Medic Field Emitter",	"weapon_zs_medicfield")               -- 医疗场发射器
GM:AddDeployableInfo("prop_zapper",				"Zapper",				"weapon_zs_zapper")                   -- 电击器
GM:AddDeployableInfo("prop_zapper_arc",			"Arc Zapper",			"weapon_zs_zapper_arc")               -- 电弧电击器
GM:AddDeployableInfo("prop_zapper_arc",			"Arc Zapper EX",		"weapon_zs_zapper_arc_ex")            -- 电弧电击器
GM:AddDeployableInfo("prop_ffemitter",			"Force Field Emitter",	"weapon_zs_ffemitter")                -- 力场发射器
GM:AddDeployableInfo("prop_manhack",			"Manhack",				"weapon_zs_manhack")                  -- 猎杀无人机
GM:AddDeployableInfo("prop_manhack_saw",		"Sawblade Manhack",		"weapon_zs_manhack_saw")              -- 锯片猎杀无人机
GM:AddDeployableInfo("prop_drone",				"Drone",				"weapon_zs_drone")                    -- 无人机
GM:AddDeployableInfo("prop_drone_pulse",		"Pulse Drone",			"weapon_zs_drone_pulse")              -- 脉冲无人机
GM:AddDeployableInfo("prop_drone_hauler",		"Hauler Drone",			"weapon_zs_drone_hauler")             -- 搬运无人机
GM:AddDeployableInfo("prop_rollermine",			"Rollermine",			"weapon_zs_rollermine")               -- 滚雷
GM:AddDeployableInfo("prop_tv",                   	"TV",                    	"weapon_zs_tv")                       -- 电视

-- ============================================================
-- GM.MaxSigils - 印记最大数量限制
-- 玩家同时可以携带的印记（Sigil）数量上限
-- ============================================================
GM.MaxSigils = 3

-- ============================================================
-- zs_redeem - 赎罪（僵尸变回人类）所需击杀数
-- 僵尸可以通过击杀足够数量的其他僵尸来赎罪变回人类
-- 设为 0 禁用赎罪功能
-- ============================================================
GM.DefaultRedeem = CreateConVar("zs_redeem", "4", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "僵尸赎罪（变回人类）所需的击杀数。设为 0 禁用。"):GetInt()
cvars.AddChangeCallback("zs_redeem", function(cvar, oldvalue, newvalue)
	GAMEMODE.DefaultRedeem = math.max(0, tonumber(newvalue) or 0)
end)

-- ============================================================
-- zs_waveonezombies - 第一波僵尸出生比例
-- 游戏开始时，此比例的玩家会作为僵尸出生
-- 当前为硬编码 0.11（11%），原为控制台变量但已注释
-- ============================================================
GM.WaveOneZombies = 0.11--math.Round(CreateConVar("zs_waveonezombies", "0.1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "游戏开始时作为僵尸出生的玩家百分比。"):GetFloat(), 2)
-- cvars.AddChangeCallback("zs_waveonezombies", function(cvar, oldvalue, newvalue)
-- 	GAMEMODE.WaveOneZombies = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
-- end)

-- ============================================================
-- zs_zombiespeedmultiplier - 僵尸速度倍率
-- 调整僵尸移动速度的缩放系数
-- 数值越大僵尸跑得越快，数值越小越慢
-- ============================================================
GM.ZombieSpeedMultiplier = math.Round(CreateConVar("zs_zombiespeedmultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "僵尸的奔跑速度将按此数值进行缩放。"):GetFloat(), 2)
cvars.AddChangeCallback("zs_zombiespeedmultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieSpeedMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- ============================================================
-- zs_zombiedamagemultiplier - 僵尸伤害抗性倍率
-- 注意：这是一个抗性系数，不是爪子伤害。
-- 0.5 会让僵尸只受到一半伤害，0.25 则是 1/4，以此类推。
-- 数值越大僵尸越容易打（更脆），数值越小越难打（更肉）
-- ============================================================
GM.ZombieDamageMultiplier = math.Round(CreateConVar("zs_zombiedamagemultiplier", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY, "缩放僵尸受到的伤害量。数值越大僵尸越容易打（更脆），数值越小越难打（更肉）。"):GetFloat(), 2)
cvars.AddChangeCallback("zs_zombiedamagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.ZombieDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- ============================================================
-- zs_timelimit - 游戏时间限制（以分钟为单位）
-- 在自动更换地图前的游戏时间。
-- 如果当前回合正在进行，不会立即换图，而是等到回合结束后。
-- -1 表示永不换图，0 表示总是换图。
-- ============================================================
GM.TimeLimit = CreateConVar("zs_timelimit", "15", FCVAR_ARCHIVE + FCVAR_NOTIFY, "游戏更换地图前的时间（分钟）。如果当前回合正在进行，不会立即换图，而是等到回合结束后。-1 表示永不换图。0 表示总是换图。"):GetInt() * 60
cvars.AddChangeCallback("zs_timelimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.TimeLimit = tonumber(newvalue) or 15
	if GAMEMODE.TimeLimit ~= -1 then
		GAMEMODE.TimeLimit = GAMEMODE.TimeLimit * 60
	end
end)

-- ============================================================
-- zs_roundlimit - 同一张地图的最大回合数
-- 在同一张地图上可以游玩的回合数上限。
-- -1 表示无限或仅使用时间限制，0 表示只玩一次。
-- ============================================================
GM.RoundLimit = CreateConVar("zs_roundlimit", "3", FCVAR_ARCHIVE + FCVAR_NOTIFY, "同一张地图可以游玩的回合数。-1 表示无限或仅使用时间限制。0 表示一次。"):GetInt()
cvars.AddChangeCallback("zs_roundlimit", function(cvar, oldvalue, newvalue)
	GAMEMODE.RoundLimit = tonumber(newvalue) or 3
end)

-- ============================================================
-- 静态游戏参数配置
-- 这些是不需要控制台变量的固定值，直接在此处定义
-- ============================================================

-- 第一波的初始长度（秒）
GM.WaveOneLength = 165

-- 每增加一波额外增加的秒数
GM.TimeAddedPerWave = 12

-- 新玩家加入时的波次阈值：当达到此波次或更高时，新玩家将被分配到僵尸队伍
-- 不要将此值设为小于 1，否则会破坏游戏平衡
GM.NoNewHumansWave = 3

-- 禁止自杀的波次阈值：当波次低于或等于此值时，人类玩家不能自杀
GM.NoSuicideWave = 1

-- 第 0 波（准备阶段）的持续时间（秒）
-- 这是给新玩家加入和准备的时间
GM.WaveZeroLength = 240

-- 波间休息时间（秒）
-- 人类可以在波间自由活动，但不会有新的僵尸生成
-- 已经死亡的僵尸会以乌鸦视角观战，存活中的僵尸继续保持
GM.WaveIntermissionLength = 90
GM.WaveIntermissionLengthIncrease = 10 -- 每增加一波额外增加的秒数
-- 回合结束到换图之间的时间（秒）
GM.EndGameTime = 50

-- 从 Worth 菜单获得枪支时初始携带的弹药夹数
-- 某些武器（如霰弹枪和狙击步枪）会在此基础上乘以额外的倍率
GM.SurvivalClips = 4 --2

-- 人类从补给箱（Resupply Box）获取弹药的冷却时间（秒）
GM.ResupplyBoxCooldown = 75

-- 最后幸存者音乐（当只剩一名人类时播放）
GM.LastHumanSound = Sound("zombiesurvival/lasthuman.ogg")

-- 人类全灭时的失败音乐
GM.AllLoseSound = Sound("zombiesurvival/music_lose.ogg")

-- 人类存活时的胜利音乐
GM.HumanWinSound = Sound("zombiesurvival/music_win.ogg")

-- 人类死亡时的音效
GM.DeathSound = Sound("zombiesurvival/human_death_stinger.ogg")

-- 是否从 noxiousnet 数据库获取地图配置文件和节点配置文件（在线配置文件）
GM.UseOnlineProfiles = false

-- 积分继承比例：本回合的积分有多少会保留到下回合
-- 1 表示全额保留，0 表示不保留
-- 注意：设为 0 不会删除已有的存档积分，且小于 1 时存档积分不会"衰减"
GM.PointSaving = 0

-- 物品购买波次锁定
-- 启用后，Tier 2 物品只能在第 2 波购买，Tier 3 在第 3 波，依此类推
-- 如果启用了积分继承，强烈建议开启此选项
-- 在目标地图、僵尸逃跑、经典模式或地图修改波次时始终禁用
GM.LockItemTiers = false

-- 积分保存上限（0 表示无上限）
GM.PointSavingLimit = 0

-- ============================================================
-- 经典模式专用配置
-- 当游戏处于经典模式时，使用这些值覆盖默认波次时间
-- ============================================================
GM.WaveIntermissionLengthClassic = 20
GM.WaveOneLengthClassic = 120
GM.TimeAddedPerWaveClassic = 10

-- ============================================================
-- 伤害持续效果上限
-- 超过此数值的待处理持续伤害将被忽略
-- ============================================================
GM.MaxPoisonDamage = 50     -- 最大中毒伤害累计值
GM.MaxBleedDamage = 50      -- 最大流血伤害累计值

-- 波次结束时给所有人类玩家的基础积分奖励
GM.EndWavePointsBonus = 10

-- 波次结束时额外积分奖励（乘以（波次 - 1））
GM.EndWavePointsBonusPerWave = 20
