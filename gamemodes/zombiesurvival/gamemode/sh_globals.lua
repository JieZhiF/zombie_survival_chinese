-- 本文件是一个共享的全局配置文件
--定义了游戏模式中客户端和服务端共用的各种常量、变量和数据表。
--内容涵盖团队定义、伤害部位、回合结束奖励、玩家网络数据索引、语音集、玩家物理属性、物品携带规则、游戏平衡性数值（如波数、得分比率、速度)
--以及弹药和物品的名称、模型、图标映射等。这些全局设置构成了游戏模式的基础规则和数据。
include("sh_translate.lua")
TEAM_ZOMBIE = 3
TEAM_ZOMBIES = TEAM_ZOMBIE
TEAM_UNDEAD = TEAM_ZOMBIE
TEAM_SURVIVOR = 4
TEAM_SURVIVORS = TEAM_SURVIVOR
TEAM_HUMAN = TEAM_SURVIVOR
TEAM_HUMANS = TEAM_SURVIVOR

DISMEMBER_HEAD = 1
DISMEMBER_LEFTARM = 2
DISMEMBER_RIGHTARM = 4
DISMEMBER_LEFTLEG = 8
DISMEMBER_RIGHTLEG = 16

HM_MOSTZOMBIESKILLED = 1
HM_MOSTDAMAGETOUNDEAD = 2
HM_MOSTHEADSHOTS = 3
HM_DEFENCEDMG = 4
HM_MOSTHELPFUL = 5
HM_LASTHUMAN = 6
HM_OUTLANDER = 7
HM_GOODDOCTOR = 8
HM_HANDYMAN = 9
HM_STRENGTHDMG = 10
HM_MOSTBRAINSEATEN = 11
HM_MOSTDAMAGETOHUMANS = 12
HM_LASTBITE = 13
HM_USEFULTOOPPOSITE = 14
HM_STUPID = 15
HM_SALESMAN = 16
HM_WAREHOUSE = 17
HM_BARRICADEDESTROYER = 18
HM_PACIFIST = 19
HM_SCARECROW = 20
HM_NESTDESTROYER = 21
HM_NESTMASTER = 22

DT_PLAYER_INT_REMORTLEVEL = 5
DT_PLAYER_INT_XP = 6
DT_PLAYER_INT_BLOODARMOR = 7
DT_PLAYER_INT_VOICESET = 8
DT_PLAYER_BOOL_BARRICADEEXPERT = 6
DT_PLAYER_BOOL_NECRO = 7
DT_PLAYER_BOOL_FRAIL = 8
DT_PLAYER_FLOAT_WIDELOAD = 5
DT_PLAYER_FLOAT_PHANTOMHEALTH = 6

VOICESET_MALE = 0
VOICESET_FEMALE = 1
VOICESET_COMBINE = 2
VOICESET_BARNEY = 3
VOICESET_ALYX = 4
VOICESET_MONK = 5

VOICELINE_PAIN_LIGHT = 0
VOICELINE_PAIN_MED = 1
VOICELINE_PAIN_HEAVY = 2
VOICELINE_DEATH = 3
VOICELINE_EYEPAIN = 4
VOICELINE_GIVEAMMO = 5

DT_WEAPON_BASE_FLOAT_NEXTRELOAD = 0
DT_WEAPON_BASE_FLOAT_RELOADSTART = 1
DT_WEAPON_BASE_FLOAT_RELOADEND = 2

FM_NONE = 0
FM_LOCALKILLOTHERASSIST = 1
FM_LOCALASSISTOTHERKILL = 2

DIR_FORWARD = 0
DIR_RIGHT = 1
DIR_BACK = 2
DIR_LEFT = 3

SLOWTYPE_PULSE = 1
SLOWTYPE_COLD = 2
SLOWTYPE_FLAME = 3

-- Made because these are constantly swapped in different gmod updates for some bizzare reason.
TEXT_ALIGN_TOP_REAL = 3
TEXT_ALIGN_BOTTOM_REAL = 4

DEFAULT_VIEW_OFFSET = Vector(0, 0, 64)
DEFAULT_VIEW_OFFSET_DUCKED = Vector(0, 0, 32) -- 28 is the default but 32 lines up to where the gun is on the model
-- default land speed = 269.5 274
DEFAULT_JUMP_POWER = 185 --284
DEFAULT_STEP_SIZE = 18
DEFAULT_MASS = 80
DEFAULT_MODELSCALE = 1

-- Humans can not carry OR drag anything heavier than this (in kg.)
CARRY_MAXIMUM_MASS = 300
-- Humans can not carry anything with a volume more than this (OBBMins():Length() + OBBMaxs():Length()).
CARRY_MAXIMUM_VOLUME = 150
-- Objects with more mass than this will be dragged instead of carried.
CARRY_DRAG_MASS = 145
-- Anything bigger than this is dragged regardless of mass.
CARRY_DRAG_VOLUME = 120
-- Humans are slowed by this amount per kg carried...
CARRY_SPEEDLOSS_PERKG = 1.3
-- but can never be slower than this.
CARRY_SPEEDLOSS_MINSPEED = 88

GM.MaxLegDamage = 3
GM.MaxArmDamage = 3

GM.UtilityKey = IN_SPEED
GM.MenuKey = IN_WALK -- I would use the spawn menu but it has no IN_ key assignment.

GM.ArsenalCrateCommission = 0.08

GM.BaseDeploySpeed = 1 -- Put this back to 1 to increase the value of it

GM.ExtraHealthPerExtraNail = 375
GM.MaxNails = 2


-- Moved from options to globals because the game is now balanced around it being static. The gamemode will BREAK if this is not 6!!
GM.NumberOfWaves = 6

GM.PulsePointsMultiplier = 1.25

-- The amount of damage you need to inflict to a zombie type to get a point
GM.HumanoidZombiePointRatio = 45
GM.PoisonZombiePointRatio = 60 -- Has an enormous head hitbox
GM.HeadcrabZombiePointRatio = 30
GM.NoHeadboxZombiePointRatio = 38
GM.TorsoZombiePointRatio = 42
GM.LegsZombiePointRatio = 37.5
GM.SkeletonPointRatio = GM.HumanoidZombiePointRatio/3

SPEED_NORMAL = 225
SPEED_SLOWEST = SPEED_NORMAL - 20
SPEED_SLOWER = SPEED_NORMAL - 14
SPEED_SLOW = SPEED_NORMAL - 7
SPEED_FAST = SPEED_NORMAL + 7
SPEED_FASTER = SPEED_NORMAL + 14
SPEED_FASTEST = SPEED_NORMAL + 20

SPEED_ZOMBIEESCAPE_SLOWEST = 220
SPEED_ZOMBIEESCAPE_SLOWER = 230
SPEED_ZOMBIEESCAPE_SLOW = 240
SPEED_ZOMBIEESCAPE_NORMAL = 250
SPEED_ZOMBIEESCAPE_ZOMBIE = 280

ZE_KNOCKBACKSCALE = 1

MASK_HOVER = bit.bor(CONTENTS_SOLID, CONTENTS_WATER, CONTENTS_SLIME, CONTENTS_GRATE, CONTENTS_WINDOW, CONTENTS_HITBOX)

GM.BarricadeHealthMin = 50
GM.BarricadeHealthMax = 1100 * 1.1
GM.BarricadeHealthMassFactor = 3 * 1
GM.BarricadeHealthVolumeFactor = 4 * 1.1
GM.BarricadeRepairCapacity = 1.25

GM.BossZombiePlayersRequired = 8

GM.HumanGibs = {
Model("models/gibs/HGIBS.mdl"),
Model("models/gibs/HGIBS_spine.mdl"),

Model("models/gibs/HGIBS_rib.mdl"),
Model("models/gibs/HGIBS_scapula.mdl"),
Model("models/gibs/antlion_gib_medium_2.mdl"),
Model("models/gibs/Antlion_gib_Large_1.mdl"),
Model("models/gibs/Strider_Gib4.mdl")
}

GM.BannedProps = {
}

GM.PropHealthMultipliers = {
}

GM.CleanupFilter = {
	"zs_hands",
	"zsbotnb"
}
GM.AmmoNames = {}
GM.AmmoNames["ar2"] = ""..translate.Get("ammotype_ar2")  -- Assault Rifle
GM.AmmoNames["pistol"] = ""..translate.Get("ammotype_pistol")  -- Pistol
GM.AmmoNames["smg1"] = ""..translate.Get("ammotype_smg")  -- SMG
GM.AmmoNames["357"] = ""..translate.Get("ammotype_rifle")  -- Rifle
GM.AmmoNames["xbowbolt"] = ""..translate.Get("ammotype_bolts")  -- Bolts
GM.AmmoNames["buckshot"] = ""..translate.Get("ammotype_buckshot")  -- Buckshot
GM.AmmoNames["sniperround"] = ""..translate.Get("ammotype_boards")  -- Boards
GM.AmmoNames["grenade"] = ""..translate.Get("ammotype_grenades")  -- Grenades
GM.AmmoNames["thumper"] = ""..translate.Get("ammotype_turrets")  -- Turrets
GM.AmmoNames["battery"] = ""..translate.Get("ammotype_medical_supplies")  -- Medical Supplies
GM.AmmoNames["gaussenergy"] = ""..translate.Get("ammotype_nails")  -- Nails
GM.AmmoNames["airboatgun"] = ""..translate.Get("ammotype_arsenal_crates")  -- Arsenal Crates
GM.AmmoNames["striderminigun"] = ""..translate.Get("ammotype_beacons")  -- Beacons
GM.AmmoNames["helicoptergun"] = ""..translate.Get("ammotype_resupply_boxes")  -- Resupply Boxes
GM.AmmoNames["slam"] = ""..translate.Get("ammotype_force_field_emitters")  -- Force Field Emitters
GM.AmmoNames["spotlamp"] = ""..translate.Get("ammotype_spot_lamps")  -- Spot Lamps
GM.AmmoNames["stone"] = ""..translate.Get("ammotype_stones")  -- Stones
GM.AmmoNames["flashbomb"] = ""..translate.Get("ammotype_flashbombs")  -- Flash Bombs
GM.AmmoNames["betty"] = ""..translate.Get("ammotype_proximity_mines")  -- Proximity Mines
GM.AmmoNames["molotov"] = ""..translate.Get("ammotype_molotovs")  -- Molotovs
GM.AmmoNames["manhack"] = ""..translate.Get("ammotype_manhacks")  -- Manhacks
GM.AmmoNames["manhack_saw"] = ""..translate.Get("ammotype_sawblade_manhacks")  -- Sawblade Manhacks
GM.AmmoNames["drone"] = ""..translate.Get("ammotype_drones")  -- Drones
GM.AmmoNames["sigilfragment"] = ""..translate.Get("ammotype_sigil_fragments")  -- Sigil Fragments
GM.AmmoNames["corruptedfragment"] = ""..translate.Get("ammotype_corrupted_fragments")  -- Corrupted Fragments
GM.AmmoNames["mediccloudbomb"] = ""..translate.Get("ammotype_medic_cloud_bombs")  -- Medic Cloud Bombs
GM.AmmoNames["nanitecloudbomb"] = ""..translate.Get("ammotype_nanite_cloud_bombs")  -- Nanite Cloud Bombs
GM.AmmoNames["foodwatermelon"] = ""..translate.Get("ammotype_watermelons")  -- Watermelons
GM.AmmoNames["foodorange"] = ""..translate.Get("ammotype_oranges")  -- Oranges
GM.AmmoNames["foodbanana"] = ""..translate.Get("ammotype_bananas")  -- Bananas
GM.AmmoNames["foodsoda"] = ""..translate.Get("ammotype_soda_cans")  -- Soda Cans
GM.AmmoNames["foodmilk"] = ""..translate.Get("ammotype_milk_cartons")  -- Milk Cartons
GM.AmmoNames["foodtakeout"] = ""..translate.Get("ammotype_chinese_takeouts")  -- Chinese Takeouts
GM.AmmoNames["foodwater"] = ""..translate.Get("ammotype_water_bottles")  -- Water Bottles
GM.AmmoNames["pulse"] = ""..translate.Get("ammotype_pulse_shots")  -- Pulse Shots
GM.AmmoNames["impactmine"] = ""..translate.Get("ammotype_explosives")  -- Explosives
GM.AmmoNames["chemical"] = ""..translate.Get("ammotype_chemicals")  -- Chemicals
GM.AmmoNames["repairfield"] = ""..translate.Get("ammotype_repair_fields")  -- Repair Fields
GM.AmmoNames["medicfield"] = ""..translate.Get("ammotype_medic_fields")  -- Repair Fields
GM.AmmoNames["zapper"] = ""..translate.Get("ammotype_zappers")  -- Zappers
GM.AmmoNames["zapper_arc"] = ""..translate.Get("ammotype_arc_zappers")  -- Arc Zappers
GM.AmmoNames["remantler"] = ""..translate.Get("ammotype_remantlers")  -- Remantlers
GM.AmmoNames["turret_buckshot"] = ""..translate.Get("ammotype_blast_turrets")  -- Blast Turrets
GM.AmmoNames["turret_assault"] = ""..translate.Get("ammotype_assault_turrets")  -- Assault Turrets
GM.AmmoNames["scrap"] = ""..translate.Get("ammotype_scrap")  -- Scrap


GM.AmmoTranslations = {}
GM.AmmoTranslations["weapon_physcannon"] = "pistol"
GM.AmmoTranslations["weapon_ar2"] = "ar2"
GM.AmmoTranslations["weapon_shotgun"] = "buckshot"
GM.AmmoTranslations["weapon_smg1"] = "smg1"
GM.AmmoTranslations["weapon_pistol"] = "pistol"
GM.AmmoTranslations["weapon_357"] = "357"
GM.AmmoTranslations["weapon_slam"] = "pistol"
GM.AmmoTranslations["weapon_crowbar"] = "pistol"
GM.AmmoTranslations["weapon_stunstick"] = "pistol"

GM.AmmoModels = {}
GM.AmmoModels["pistol"] = "models/Items/BoxSRounds.mdl" -- Pistols
GM.AmmoModels["smg1"] = "models/Items/BoxMRounds.mdl" -- SMGs
GM.AmmoModels["ar2"] = "models/Items/357ammobox.mdl" -- Assault rifles
GM.AmmoModels["battery"] = "models/healthvial.mdl" -- Medical Kit charge
GM.AmmoModels["buckshot"] = "models/Items/BoxBuckshot.mdl" -- Buckshot
GM.AmmoModels["357"] = "models/props_lab/box01a.mdl" -- Slugs
GM.AmmoModels["xbowbolt"] = "models/Items/CrossbowRounds.mdl" -- Bolts
GM.AmmoModels["gaussenergy"] = "models/props_junk/cardboard_box004a.mdl" -- Nails
GM.AmmoModels["grenade"] = "models/weapons/w_grenade.mdl" -- Grenades
GM.AmmoModels["thumper"] = "models/Combine_turrets/Floor_turret.mdl" -- Gun turrets
GM.AmmoModels["airboatgun"] = "models/Items/item_item_crate.mdl" -- Arsenal crates
GM.AmmoModels["striderminigun"] = "models/props_combine/combine_mine01.mdl" -- Message beacons
GM.AmmoModels["helicoptergun"] = "models/Items/ammocrate_ar2.mdl" -- Resupply boxes
GM.AmmoModels["slam"] = "models/props_lab/lab_flourescentlight002b.mdl" -- Force Field Emitters
GM.AmmoModels["spotlamp"] = "models/props_combine/combine_light001a.mdl"
GM.AmmoModels["stone"] = "models/props_junk/rock001a.mdl"
GM.AmmoModels["pulse"] = "models/Items/combine_rifle_ammo01.mdl"
GM.AmmoModels["impactmine"] = "models/weapons/w_missile_closed.mdl"
GM.AmmoModels["chemical"] = "models/weapons/w_missile_closed.mdl"
GM.AmmoModels["repairfield"] = "models/props/de_nuke/smokestack01.mdl"
GM.AmmoModels["medicfield"] = "models/props/de_nuke/smokestack01.mdl"
GM.AmmoModels["zapper"] = "models/props_c17/utilityconnecter006c.mdl"
GM.AmmoModels["zapper_arc"] = "models/props_c17/utilityconnecter006c.mdl"
GM.AmmoModels["turret_buckshot"] = "models/Combine_turrets/Floor_turret.mdl"
GM.AmmoModels["turret_assault"] = "models/Combine_turrets/Floor_turret.mdl"
GM.AmmoModels["remantler"] = "models/props_lab/powerbox01a.mdl"
GM.AmmoModels["scrap"] = "models/props_junk/vent001_chunk5.mdl"
GM.AmmoModels["sniperround"] = "models/props_debris/wood_board02a.mdl"
GM.AmmoModels["camera"] = "models/props_combine/combine_mine01.mdl"

GM.AmmoIcons = {}
GM.AmmoIcons["pistol"] = "ammo_pistol"
GM.AmmoIcons["smg1"] = "ammo_smg"
GM.AmmoIcons["ar2"] = "ammo_assault"
GM.AmmoIcons["battery"] = "ammo_medpower"
GM.AmmoIcons["buckshot"] = "ammo_shotgun"
GM.AmmoIcons["357"] = "ammo_rifle"
GM.AmmoIcons["xbowbolt"] = "ammo_bolts"
GM.AmmoIcons["gaussenergy"] = "ammo_nail"
GM.AmmoIcons["pulse"] = "ammo_pulse"
GM.AmmoIcons["impactmine"] = "ammo_explosive"
GM.AmmoIcons["chemical"] = "ammo_chemical"
GM.AmmoIcons["scrap"] = "ammo_scrap"

GM.ResistableStatuses = {
	"sickness",
	"dimvision",
	"enfeeble",
	"slow",
	"frightened",
	"frost"
}

GM.ScrapVals = {
	--6, 16, 32, 58, 92, 138
	6, 16, 30, 46, 70, 106
}

GM.ScrapValsTrinkets = {
	5, 10, 16, 23, 32, 56
}

GM.DismantleMultipliers = {
	1, 2, 4, 7
}

-- Handled in languages file.
GM.ValidBeaconMessages = {
	"message_beacon_1",
	"message_beacon_2",
	"message_beacon_3",
	"message_beacon_4",
	"message_beacon_5",
	"message_beacon_6",
	"message_beacon_7",
	"message_beacon_8",
	"message_beacon_9",
	"message_beacon_10",
	"message_beacon_11",
	"message_beacon_12",
	"message_beacon_13",
	"message_beacon_14",
	"message_beacon_15",
	"message_beacon_16",
	"message_beacon_17",
	"message_beacon_18",
	"message_beacon_19",
	"message_beacon_20",
	"message_beacon_21",
	"message_beacon_22",
	"message_beacon_23",
	"message_beacon_24",
	"message_beacon_25"
}

WeaponMaterials = {
    pistol = Material("zombiesurvival/bullet_pistol.png", "smooth"),
    magnum = Material("zombiesurvival/bullet_magnum.png", "smooth"),
    shotgun = Material("zombiesurvival/bullet_shell.png", "smooth"),
    pulse = Material("zombiesurvival/bullet_pulse.png", "smooth"),
    rifle = Material("zombiesurvival/bullet_rifle.png", "smooth"),
    medical = Material("zombiesurvival/bullet_medical2.png", "smooth"),
    explosive = Material("zombiesurvival/bullet_explosive2.png", "smooth"),
    projectile = Material("zombiesurvival/bullet_bolt.png", "smooth")
}

GM.LabourTime = 1