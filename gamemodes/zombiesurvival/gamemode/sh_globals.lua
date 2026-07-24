--[[
	sh_globals.lua — 全局共享常量与数据定义
	本文件是一个共享的全局配置文件
	定义了游戏模式中客户端和服务端共用的各种常量、变量和数据表。
	内容涵盖团队定义、伤害部位、回合结束奖励、玩家网络数据索引、语音集、玩家物理属性、物品携带规则、游戏平衡性数值（如波数、得分比率、速度)
	以及弹药和物品的名称、模型、图标映射等。这些全局设置构成了游戏模式的基础规则和数据。
--]]

-- 载入翻译系统，用于多语言支持（所有 translate.Get 调用依赖此文件）
include("sh_translate.lua")

-- ============================
-- 团队（Team）常量定义
-- 用于玩家队伍分配与游戏逻辑判断
-- ============================

-- 僵尸阵营，数值 3
TEAM_ZOMBIE = 3
-- TEAM_ZOMBIES 是 TEAM_ZOMBIE 的别名，方便复数形式引用
TEAM_ZOMBIES = TEAM_ZOMBIE
-- TEAM_UNDEAD 也是僵尸阵营的别名，便于语义化命名
TEAM_UNDEAD = TEAM_ZOMBIE
-- 幸存者阵营，数值 4
TEAM_SURVIVOR = 4
-- TEAM_SURVIVORS 是 TEAM_SURVIVOR 的别名
TEAM_SURVIVORS = TEAM_SURVIVOR
-- TEAM_HUMAN 是幸存者阵营的别名
TEAM_HUMAN = TEAM_SURVIVOR
-- TEAM_HUMANS 是幸存者阵营的别名（复数形式）
TEAM_HUMANS = TEAM_SURVIVOR

-- ============================
-- 肢解（Dismemberment）部位位掩码
-- 使用位运算组合，可同时表示多个部位
-- 用于伤害系统和模型肢解效果
-- ============================

-- 头部，位值 1
DISMEMBER_HEAD = 1
-- 左臂，位值 2
DISMEMBER_LEFTARM = 2
-- 右臂，位值 4
DISMEMBER_RIGHTARM = 4
-- 左腿，位值 8
DISMEMBER_LEFTLEG = 8
-- 右腿，位值 16
DISMEMBER_RIGHTLEG = 16

-- ============================
-- 荣誉提及（Honor Mentions）ID
-- 回合结束时根据玩家表现颁发的各种称号
-- 每个常量对应一种统计维度
-- ============================

-- 击杀僵尸最多
HM_MOSTZOMBIESKILLED = 1
-- 对僵尸造成伤害最多
HM_MOSTDAMAGETOUNDEAD = 2
-- 爆头次数最多
HM_MOSTHEADSHOTS = 3
-- 防御伤害最多（如抵挡攻击）
HM_DEFENCEDMG = 4
-- 最有帮助的玩家（治疗、支援等）
HM_MOSTHELPFUL = 5
-- 最后一名存活的幸存者
HM_LASTHUMAN = 6
-- 局外人（远离团队孤军奋战）
HM_OUTLANDER = 7
-- 好医生（治疗量最高）
HM_GOODDOCTOR = 8
-- 勤杂工（建造/修理最多）
HM_HANDYMAN = 9
-- 力量伤害最多（近战）
HM_STRENGTHDMG = 10
-- 吃掉最多脑子（僵尸行为）
HM_MOSTBRAINSEATEN = 11
-- 对人类造成伤害最多（僵尸方）
HM_MOSTDAMAGETOHUMANS = 12
-- 最后一击（咬死最后一个幸存者）
HM_LASTBITE = 13
-- 对反方最有用的玩家（如僵尸帮了人类或反之）
HM_USEFULTOOPPOSITE = 14
-- 最愚蠢行为
HM_STUPID = 15
-- 推销员（贩卖物品最多）
HM_SALESMAN = 16
-- 仓库管理员（库存最多）
HM_WAREHOUSE = 17
-- 路障破坏者（破坏最多路障）
HM_BARRICADEDESTROYER = 18
-- 和平主义者（不造成伤害）
HM_PACIFIST = 19
-- 稻草人（被攻击但很少还击）
HM_SCARECROW = 20
-- 巢穴破坏者（摧毁僵尸巢穴）
HM_NESTDESTROYER = 21
-- 巢穴大师（建造僵尸巢穴）
HM_NESTMASTER = 22

-- ============================
-- 玩家网络数据表（DT_PLAYER_*）索引
-- 用于通过 SendProxy 在客户端与服务端之间同步玩家属性
-- 整数型（Int）数据
-- ============================

-- 复活等级（remort level）
DT_PLAYER_INT_REMORTLEVEL = 5
-- 经验值
DT_PLAYER_INT_XP = 6
-- 血甲值（blood armor）
DT_PLAYER_INT_BLOODARMOR = 7
-- 语音集编号（决定角色语音风格）
DT_PLAYER_INT_VOICESET = 8

-- 布尔型（Bool）数据
-- 是否为路障专家
DT_PLAYER_BOOL_BARRICADEEXPERT = 6
-- 是否为死灵法师
DT_PLAYER_BOOL_NECRO = 7
-- 是否为脆弱体质
DT_PLAYER_BOOL_FRAIL = 8

-- 浮点型（Float）数据
-- 宽载系数（影响移动/携带）
DT_PLAYER_FLOAT_WIDELOAD = 5
-- 幻影生命值（phantom health）
DT_PLAYER_FLOAT_PHANTOMHEALTH = 6

-- ============================
-- 语音集（Voice Set）常量
-- 定义玩家角色可用的不同语音风格
-- ============================

-- 男性角色语音
VOICESET_MALE = 0
-- 女性角色语音
VOICESET_FEMALE = 1
-- 联合军（Combine）语音
VOICESET_COMBINE = 2
-- Barney（《半条命2》角色）语音
VOICESET_BARNEY = 3
-- Alyx（《半条命2》角色）语音
VOICESET_ALYX = 4
-- Monk（《半条命2》角色）语音
VOICESET_MONK = 5

-- ============================
-- 语音线（Voice Line）类型
-- 玩家在不同情况下触发不同的语音
-- ============================

-- 轻度疼痛
VOICELINE_PAIN_LIGHT = 0
-- 中度疼痛
VOICELINE_PAIN_MED = 1
-- 重度疼痛
VOICELINE_PAIN_HEAVY = 2
-- 死亡
VOICELINE_DEATH = 3
-- 眼部受伤
VOICELINE_EYEPAIN = 4
-- 给予弹药时的语音
VOICELINE_GIVEAMMO = 5

-- ============================
-- 武器数据表（DT_WEAPON_BASE_*）索引
-- 用于网络同步武器状态
-- 浮点型数据
-- ============================

-- 下次重装完成时间
DT_WEAPON_BASE_FLOAT_NEXTRELOAD = 0
-- 重装开始时间
DT_WEAPON_BASE_FLOAT_RELOADSTART = 1
-- 重装结束时间
DT_WEAPON_BASE_FLOAT_RELOADEND = 2

-- ============================
-- 友军伤害协助（Friendly Fire Assist Mode）常量
-- 用于判断击杀/助攻的归属
-- ============================

-- 无协助模式
FM_NONE = 0
-- 本地玩家击杀，他人助攻
FM_LOCALKILLOTHERASSIST = 1
-- 本地玩家助攻，他人击杀
FM_LOCALASSISTOTHERKILL = 2

-- ============================
-- 方向（Direction）常量
-- 用于相对方向判断（相对于玩家视野）
-- ============================

-- 前方
DIR_FORWARD = 0
-- 右方
DIR_RIGHT = 1
-- 后方
DIR_BACK = 2
-- 左方
DIR_LEFT = 3

-- ============================
-- 减速类型（Slow Type）常量
-- 用于区分不同来源的减速效果
-- ============================

-- 脉冲减速
SLOWTYPE_PULSE = 1
-- 寒冷减速
SLOWTYPE_COLD = 2
-- 火焰减速
SLOWTYPE_FLAME = 3

-- 由于每次 GMod 更新都会莫名其妙地交换这些对齐值，所以定义真实常量以保持不变
TEXT_ALIGN_TOP_REAL = 3
TEXT_ALIGN_BOTTOM_REAL = 4

-- ============================
-- 默认玩家物理属性
-- 决定游戏的基本物理表现
-- ============================

-- 默认站立视角偏移（眼睛位置相对于模型原点）
DEFAULT_VIEW_OFFSET = Vector(0, 0, 64)
-- 默认蹲下视角偏移（28 为默认值，但 32 能让枪口与模型对齐）
DEFAULT_VIEW_OFFSET_DUCKED = Vector(0, 0, 32)
-- 默认陆地移动速度（原默认值约为 269.5~274）
DEFAULT_JUMP_POWER = 185
-- 默认踏步高度（角色能迈上的最大台阶高度）
DEFAULT_STEP_SIZE = 18
-- 默认玩家质量（千克）
DEFAULT_MASS = 80
-- 默认模型缩放比例
DEFAULT_MODELSCALE = 1

-- ============================
-- 物品携带系统（Carry System）常量
-- 限制玩家可以携带或拖动物体的能力
-- ============================

-- 人类不能携带或拖动任何比这个质量（千克）更重的物体
CARRY_MAXIMUM_MASS = 355
-- 人类不能携带体积超过此值的物体（体积 = OBBMins():Length() + OBBMaxs():Length()）
CARRY_MAXIMUM_VOLUME = 150
-- 质量超过此值的物体将被拖拽而非携带
CARRY_DRAG_MASS = 165
-- 体积超过此值的物体无论质量如何都会被拖拽
CARRY_DRAG_VOLUME = 120
-- 每携带 1 千克物品，移动速度降低的量
CARRY_SPEEDLOSS_PERKG = 1
-- 携带物品时移速被降低的下限，不能慢于这个速度
CARRY_SPEEDLOSS_MINSPEED = 99

-- 腿部受伤最大等级（用于肢解伤害系统）
GM.MaxLegDamage = 3
-- 手臂受伤最大等级
GM.MaxArmDamage = 3

-- 工具键绑定（使用/互动键），绑定到 IN_SPEED（默认 Shift）
GM.UtilityKey = IN_SPEED
-- 菜单键绑定，绑定到 IN_WALK（默认 Alt）
-- 本来想用生成菜单键，但它没有对应的 IN_ 常量
GM.MenuKey = IN_WALK

-- 军火箱佣金比例（军火箱中收取的额外费用比例）
GM.ArsenalCrateCommission = 0.05

-- 基础部署速度（设为 1 以增加其价值）
GM.BaseDeploySpeed = 1

-- 每多一块额外钉子增加的生命值
GM.ExtraHealthPerExtraNail = 400
-- 最大钉子数量
GM.MaxNails = 2

-- ============================
-- 游戏核心平衡常量
-- 这些值从选项移到全局常量，因为游戏已围绕它们平衡
-- ============================

-- 波数（Waves）总量 —— 非常重要：如果此值不是 6，游戏模式将会崩溃！
GM.NumberOfWaves = 6

-- 脉冲点数倍率（Pulse Points 的收益乘数）
GM.PulsePointsMultiplier = 1.25

-- ============================
-- 得分比例（Point Ratio）常量
-- 对不同类型僵尸造成一定伤害获得 1 分所需的伤害量
-- 不同的僵尸类型头部命中体积不同，因此比例不同
-- ============================

-- 人形僵尸得分比例
GM.HumanoidZombiePointRatio = 45
-- 毒僵尸得分比例（头部命中体积巨大）
GM.PoisonZombiePointRatio = 60
-- 头蟹僵尸得分比例
GM.HeadcrabZombiePointRatio = 30
-- 无头命中盒僵尸得分比例
GM.NoHeadboxZombiePointRatio = 38
-- 躯干型僵尸得分比例
GM.TorsoZombiePointRatio = 42
-- 腿部型僵尸得分比例
GM.LegsZombiePointRatio = 37.5
-- 骷髅得分比例（为人形僵尸的三分之一）
GM.SkeletonPointRatio = GM.HumanoidZombiePointRatio/3

-- ============================
-- 移动速度常量
-- 定义不同等级的基础移动速度
-- ============================

-- 普通速度
SPEED_NORMAL = 225
-- 最慢速度
SPEED_SLOWEST = SPEED_NORMAL - 20
-- 较慢速度
SPEED_SLOWER = SPEED_NORMAL - 14
-- 慢速
SPEED_SLOW = SPEED_NORMAL - 7
-- 快速
SPEED_FAST = SPEED_NORMAL + 7
-- 较快速度
SPEED_FASTER = SPEED_NORMAL + 14
-- 最快速度
SPEED_FASTEST = SPEED_NORMAL + 20

-- ============================
-- 僵尸逃跑（Zombie Escape, ZE）模式速度常量
-- 仅在 ZE 地图中使用
-- ============================

-- 最慢
SPEED_ZOMBIEESCAPE_SLOWEST = 220
-- 较慢
SPEED_ZOMBIEESCAPE_SLOWER = 230
-- 慢速
SPEED_ZOMBIEESCAPE_SLOW = 240
-- 正常速度
SPEED_ZOMBIEESCAPE_NORMAL = 250
-- 僵尸速度（比人类快）
SPEED_ZOMBIEESCAPE_ZOMBIE = 280

-- 僵尸逃跑（ZE）模式的击退缩放比例
ZE_KNOCKBACKSCALE = 1

-- 悬停（Hover）碰撞掩码
-- 包含固体、水、黏液、栅格、窗户和碰撞盒，用于射线检测
MASK_HOVER = bit.bor(CONTENTS_SOLID, CONTENTS_WATER, CONTENTS_SLIME, CONTENTS_GRATE, CONTENTS_WINDOW, CONTENTS_HITBOX)

-- ============================
-- 路障（Barricade）系统属性
-- 控制路障的血量范围以及根据质量和体积计算的额外血量
-- ============================

-- 路障最低生命值
GM.BarricadeHealthMin = 50
-- 路障最高生命值（基础 1100 × 1.1）
GM.BarricadeHealthMax = 1100 * 1.1
-- 路障生命值质量因子：每单位质量对血量的贡献
GM.BarricadeHealthMassFactor = 3 * 1
-- 路障生命值体积因子：每单位体积对血量的贡献
GM.BarricadeHealthVolumeFactor = 4 * 1.1
-- 路障修复容量（每次修复恢复的血量比例）
GM.BarricadeRepairCapacity = 1.25

-- Boss 僵尸所需的最小玩家数（少于这个数量则不会生成 Boss 僵尸）
GM.BossZombiePlayersRequired = 8

-- ============================
-- 人类尸体碎片（Gibs）模型列表
-- 玩家被肢解时生成的模型
-- ============================

GM.HumanGibs = {
Model("models/gibs/HGIBS.mdl"),
Model("models/gibs/HGIBS_spine.mdl"),

Model("models/gibs/HGIBS_rib.mdl"),
Model("models/gibs/HGIBS_scapula.mdl"),
Model("models/gibs/antlion_gib_medium_2.mdl"),
Model("models/gibs/Antlion_gib_Large_1.mdl"),
Model("models/gibs/Strider_Gib4.mdl")
}

-- 被禁止作为路障使用的道具模型列表（空表表示不限制）
GM.BannedProps = {
}

-- 不同道具类型/模型的血量倍率映射表（空表表示使用默认值）
GM.PropHealthMultipliers = {
}

-- ============================
-- 清理过滤器（Cleanup Filter）
-- 列出在回合清理中不被移除的实体类名
-- ============================

GM.CleanupFilter = {
	-- 僵尸的手部模型（保留）
	"zs_hands",
	-- 巡逻机器人（保留）
	"zsbotnb"
}

-- ============================
-- 弹药名称映射表（GM.AmmoNames）
-- 将弹药类型内部名称映射为本地化显示名称
-- 每个条目: 弹药类型键 → 翻译后的名称字符串
-- ============================

GM.AmmoNames = {}
-- AR2 突击步枪弹药
GM.AmmoNames["ar2"] = ""..translate.Get("ammotype_ar2")
-- 手枪弹药
GM.AmmoNames["pistol"] = ""..translate.Get("ammotype_pistol")
-- SMG 冲锋枪弹药
GM.AmmoNames["smg1"] = ""..translate.Get("ammotype_smg")
-- 步枪弹药（.357）
GM.AmmoNames["357"] = ""..translate.Get("ammotype_rifle")
-- 弩箭
GM.AmmoNames["xbowbolt"] = ""..translate.Get("ammotype_bolts")
-- 霰弹枪弹药
GM.AmmoNames["buckshot"] = ""..translate.Get("ammotype_buckshot")
-- 木板弹药（狙击弹药类型）
GM.AmmoNames["sniperround"] = ""..translate.Get("ammotype_boards")
-- 手榴弹
GM.AmmoNames["grenade"] = ""..translate.Get("ammotype_grenades")
-- 炮塔（Thumper）
GM.AmmoNames["thumper"] = ""..translate.Get("ammotype_turrets")
-- 医疗补给（电池）
GM.AmmoNames["battery"] = ""..translate.Get("ammotype_medical_supplies")
-- 钉子（高斯能量）
GM.AmmoNames["gaussenergy"] = ""..translate.Get("ammotype_nails")
-- 军火箱
GM.AmmoNames["airboatgun"] = ""..translate.Get("ammotype_arsenal_crates")
-- 信标
GM.AmmoNames["striderminigun"] = ""..translate.Get("ammotype_beacons")
-- 补给箱
GM.AmmoNames["helicoptergun"] = ""..translate.Get("ammotype_resupply_boxes")
-- 力场发生器
GM.AmmoNames["slam"] = ""..translate.Get("ammotype_force_field_emitters")
-- 探照灯
GM.AmmoNames["spotlamp"] = ""..translate.Get("ammotype_spot_lamps")
-- 石头
GM.AmmoNames["stone"] = ""..translate.Get("ammotype_stones")
-- 闪光弹
GM.AmmoNames["flashbomb"] = ""..translate.Get("ammotype_flashbombs")
-- 感应地雷
GM.AmmoNames["betty"] = ""..translate.Get("ammotype_proximity_mines")
-- 燃烧瓶
GM.AmmoNames["molotov"] = ""..translate.Get("ammotype_molotovs")
-- 猎头虫（Manhack）
GM.AmmoNames["manhack"] = ""..translate.Get("ammotype_manhacks")
-- 锯片猎头虫
GM.AmmoNames["manhack_saw"] = ""..translate.Get("ammotype_sawblade_manhacks")
-- 无人机
GM.AmmoNames["drone"] = ""..translate.Get("ammotype_drones")
-- 印记碎片
GM.AmmoNames["sigilfragment"] = ""..translate.Get("ammotype_sigil_fragments")
-- 腐化碎片
GM.AmmoNames["corruptedfragment"] = ""..translate.Get("ammotype_corrupted_fragments")
-- 医疗云弹
GM.AmmoNames["mediccloudbomb"] = ""..translate.Get("ammotype_medic_cloud_bombs")
-- 纳米云弹
GM.AmmoNames["nanitecloudbomb"] = ""..translate.Get("ammotype_nanite_cloud_bombs")
-- 西瓜（食物）
GM.AmmoNames["foodwatermelon"] = ""..translate.Get("ammotype_watermelons")
-- 橘子（食物）
GM.AmmoNames["foodorange"] = ""..translate.Get("ammotype_oranges")
-- 香蕉（食物）
GM.AmmoNames["foodbanana"] = ""..translate.Get("ammotype_bananas")
-- 汽水罐（食物）
GM.AmmoNames["foodsoda"] = ""..translate.Get("ammotype_soda_cans")
-- 牛奶盒（食物）
GM.AmmoNames["foodmilk"] = ""..translate.Get("ammotype_milk_cartons")
-- 中餐外卖（食物）
GM.AmmoNames["foodtakeout"] = ""..translate.Get("ammotype_chinese_takeouts")
-- 水瓶（食物）
GM.AmmoNames["foodwater"] = ""..translate.Get("ammotype_water_bottles")
-- 脉冲射击
GM.AmmoNames["pulse"] = ""..translate.Get("ammotype_pulse_shots")
-- 爆炸物
GM.AmmoNames["impactmine"] = ""..translate.Get("ammotype_explosives")
-- 化学品
GM.AmmoNames["chemical"] = ""..translate.Get("ammotype_chemicals")
-- 修理场
GM.AmmoNames["repairfield"] = ""..translate.Get("ammotype_repair_fields")
-- 医疗场
GM.AmmoNames["medicfield"] = ""..translate.Get("ammotype_medic_fields")
-- 电击器
GM.AmmoNames["zapper"] = ""..translate.Get("ammotype_zappers")
-- 电弧电击器
GM.AmmoNames["zapper_arc"] = ""..translate.Get("ammotype_arc_zappers")
-- 超级电弧电击器
GM.AmmoNames["zapper_arc_ex"] = ""..translate.Get("ammotype_arc_zappers_ex")
-- 重塑器
GM.AmmoNames["remantler"] = ""..translate.Get("ammotype_remantlers")
-- 爆炸炮塔
GM.AmmoNames["turret_buckshot"] = ""..translate.Get("ammotype_blast_turrets")
-- 突击炮塔
GM.AmmoNames["turret_assault"] = ""..translate.Get("ammotype_assault_turrets")
-- 废料
GM.AmmoNames["scrap"] = ""..translate.Get("ammotype_scrap")

-- ============================
-- 弹药类型转换表（GM.AmmoTranslations）
-- 将基础武器（来源引擎默认武器）映射到本模式自定义弹药类型
-- 用于弹药兼容性检测
-- ============================

GM.AmmoTranslations = {}
-- 物理枪使用手枪弹药
GM.AmmoTranslations["weapon_physcannon"] = "pistol"
-- AR2 使用 AR2 弹药
GM.AmmoTranslations["weapon_ar2"] = "ar2"
-- 霰弹枪使用霰弹弹药
GM.AmmoTranslations["weapon_shotgun"] = "buckshot"
-- SMG1 使用 SMG 弹药
GM.AmmoTranslations["weapon_smg1"] = "smg1"
-- 手枪使用手枪弹药
GM.AmmoTranslations["weapon_pistol"] = "pistol"
-- .357 左轮使用步枪弹药
GM.AmmoTranslations["weapon_357"] = "357"
-- SLAM 使用手枪弹药（作为默认备用）
GM.AmmoTranslations["weapon_slam"] = "pistol"
-- 撬棍使用手枪弹药（默认备用）
GM.AmmoTranslations["weapon_crowbar"] = "pistol"
-- 电击棒使用手枪弹药（默认备用）
GM.AmmoTranslations["weapon_stunstick"] = "pistol"

-- ============================
-- 弹药掉落物模型映射表（GM.AmmoModels）
-- 每种弹药类型对应的世界模型路径
-- 用于在游戏中生成可见的弹药拾取物
-- ============================

GM.AmmoModels = {}
-- 手枪弹药箱
GM.AmmoModels["pistol"] = "models/Items/BoxSRounds.mdl"
-- SMG 弹药箱
GM.AmmoModels["smg1"] = "models/Items/BoxMRounds.mdl"
-- AR2 弹药箱
GM.AmmoModels["ar2"] = "models/Items/357ammobox.mdl"
-- 医疗包充能
GM.AmmoModels["battery"] = "models/healthvial.mdl"
-- 霰弹弹药箱
GM.AmmoModels["buckshot"] = "models/Items/BoxBuckshot.mdl"
-- 步枪弹（独头弹）
GM.AmmoModels["357"] = "models/props_lab/box01a.mdl"
-- 弩箭
GM.AmmoModels["xbowbolt"] = "models/Items/CrossbowRounds.mdl"
-- 钉子
GM.AmmoModels["gaussenergy"] = "models/props_junk/cardboard_box004a.mdl"
-- 手榴弹
GM.AmmoModels["grenade"] = "models/weapons/w_grenade.mdl"
-- 地面炮塔
GM.AmmoModels["thumper"] = "models/Combine_turrets/Floor_turret.mdl"
-- 军火箱
GM.AmmoModels["airboatgun"] = "models/Items/item_item_crate.mdl"
-- 信息信标
GM.AmmoModels["striderminigun"] = "models/props_combine/combine_mine01.mdl"
-- 补给箱
GM.AmmoModels["helicoptergun"] = "models/Items/ammocrate_ar2.mdl"
-- 力场发生器
GM.AmmoModels["slam"] = "models/props_lab/lab_flourescentlight002b.mdl"
-- 探照灯
GM.AmmoModels["spotlamp"] = "models/props_combine/combine_light001a.mdl"
-- 石头
GM.AmmoModels["stone"] = "models/props_junk/rock001a.mdl"
-- 脉冲弹药
GM.AmmoModels["pulse"] = "models/Items/combine_rifle_ammo01.mdl"
-- 爆炸物
GM.AmmoModels["impactmine"] = "models/weapons/w_missile_closed.mdl"
-- 化学品
GM.AmmoModels["chemical"] = "models/weapons/w_missile_closed.mdl"
-- 修理场
GM.AmmoModels["repairfield"] = "models/props/de_nuke/smokestack01.mdl"
-- 医疗场
GM.AmmoModels["medicfield"] = "models/props/de_nuke/smokestack01.mdl"
-- 电击器
GM.AmmoModels["zapper"] = "models/props_c17/utilityconnecter006c.mdl"
-- 电弧电击器
GM.AmmoModels["zapper_arc"] = "models/props_c17/utilityconnecter006c.mdl"
-- 超级电弧电击器
GM.AmmoModels["zapper_arc_ex"] = "models/props_c17/utilityconnecter006c.mdl"
-- 爆炸炮塔
GM.AmmoModels["turret_buckshot"] = "models/Combine_turrets/Floor_turret.mdl"
-- 突击炮塔
GM.AmmoModels["turret_assault"] = "models/Combine_turrets/Floor_turret.mdl"
-- 重塑器
GM.AmmoModels["remantler"] = "models/props_lab/powerbox01a.mdl"
-- 废料
GM.AmmoModels["scrap"] = "models/props_junk/vent001_chunk5.mdl"
-- 木板
GM.AmmoModels["sniperround"] = "models/props_debris/wood_board02a.mdl"
-- 相机
GM.AmmoModels["camera"] = "models/props_combine/combine_mine01.mdl"

-- ============================
-- 弹药图标映射表（GM.AmmoIcons）
-- 每种弹药类型对应的 HUD 图标名称
-- 用于在界面中展示弹药图标
-- ============================

GM.AmmoIcons = {}
-- 手枪弹药图标
GM.AmmoIcons["pistol"] = "ammo_pistol"
-- SMG 弹药图标
GM.AmmoIcons["smg1"] = "ammo_smg"
-- 突击步枪弹药图标
GM.AmmoIcons["ar2"] = "ammo_assault"
-- 医疗能量图标
GM.AmmoIcons["battery"] = "ammo_medpower"
-- 霰弹弹药图标
GM.AmmoIcons["buckshot"] = "ammo_shotgun"
-- 步枪弹药图标
GM.AmmoIcons["357"] = "ammo_rifle"
-- 弩箭图标
GM.AmmoIcons["xbowbolt"] = "ammo_bolts"
-- 钉子图标
GM.AmmoIcons["gaussenergy"] = "ammo_nail"
-- 脉冲弹药图标
GM.AmmoIcons["pulse"] = "ammo_pulse"
-- 爆炸物图标
GM.AmmoIcons["impactmine"] = "ammo_explosive"
-- 化学品图标
GM.AmmoIcons["chemical"] = "ammo_chemical"
-- 废料图标
GM.AmmoIcons["scrap"] = "ammo_scrap"

-- ============================
-- 可抵抗状态效果（Resistable Statuses）列表
-- 玩家通过特定技能或装备可以免疫或抵抗这些负面状态
-- ============================

GM.ResistableStatuses = {
	-- 疾病效果
	"sickness",
	-- 视野模糊
	"dimvision",
	-- 虚弱（减伤/减攻）
	"enfeeble",
	-- 减速
	"slow",
	-- 恐惧
	"frightened",
	-- 冰冻
	"frost"
}

-- ============================
-- 废料价值（Scrap Values）表
-- 按波数索引，每波击杀僵尸可获得的废料数量
-- 原设计值：[6, 16, 32, 58, 92, 138]，当前为调整后的平衡值
-- ============================

GM.ScrapVals = {
	6, 16, 30, 46, 70, 106
}

-- 饰品废料价值（用于出售饰品获得的废料量）
GM.ScrapValsTrinkets = {
	5, 10, 16, 23, 32, 56
}

-- 拆解倍率（Dismantle Multipliers）
-- 不同品质/等级拆解时的材料回收系数
GM.DismantleMultipliers = {
	1, 2, 4, 7
}

-- ============================
-- 有效信标消息列表（Valid Beacon Messages）
-- 玩家放置信标后可选择的广播消息
-- 这些文本键在语言文件中定义，由 translate.Get 解析
-- ============================

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

-- ============================
-- 武器材质（Weapon Materials）映射表
-- 每种伤害类型对应的子弹/弹头材质
-- 用于子弹撞击效果、弹孔渲染等视觉表现
-- ============================

WeaponMaterials = {
    -- 手枪子弹材质
    pistol = Material("zombiesurvival/bullet_pistol.png", "smooth"),
    -- 马格南子弹材质
    magnum = Material("zombiesurvival/bullet_magnum.png", "smooth"),
    -- 霰弹弹壳材质
    shotgun = Material("zombiesurvival/bullet_shell.png", "smooth"),
    -- 脉冲子弹材质
    pulse = Material("zombiesurvival/bullet_pulse.png", "smooth"),
    -- 步枪子弹材质
    rifle = Material("zombiesurvival/bullet_rifle.png", "smooth"),
    -- 医疗弹药材质
    medical = Material("zombiesurvival/bullet_medical2.png", "smooth"),
    -- 爆炸物材质
    explosive = Material("zombiesurvival/bullet_explosive2.png", "smooth"),
    -- 抛射物（如弩箭）材质
    projectile = Material("zombiesurvival/bullet_bolt.png", "smooth")
}

-- 劳动时间（Labour Time）（单位：秒）
-- 用于采集、建造等需要读条的动作的基准时长
GM.LabourTime = 1
