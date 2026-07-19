-- ============================================================================
-- shared.lua — 僵尸生存游戏模式核心共享文件
-- 此文件在服务端和客户端均会执行，定义了游戏模式的基本信息、团队设置、
-- 自定义弹药类型、核心游戏逻辑函数以及加载其他共享脚本。
-- ============================================================================

-- ============================================================================
-- 文件顶部的函数说明列表（仅作为目录参考，下方有每个函数的完整实现）
-- ============================================================================

-- GM:GetNumberOfWaves 获取当前游戏的总波数。
-- GM:GetWaveOneLength 获取第一波的持续时间。
-- GM:AddCustomAmmo 注册游戏模式所需的自定义弹药类型。
-- GM:RegisterFood 注册所有食物类型的武器。
--[[
GM:RefreshMapIsObjective 检查当前地图是否为目标模式地图。

GM:AssignItemProperties 将武器的属性（如描述、等级）赋予对应的商店物品。

GM:SetupDefaultClip 工具函数，用于设置武器的默认弹药量。

GM:FixWeaponBase 修复和调整基础武器类(weapon_base)的功能。

GM:GetRedeemBrains 获取复活所需的脑子数量。

GM:PlayerIsAdmin 检查玩家是否为管理员。

GM:GetFallDamage 获取玩家的坠落伤害（实际逻辑在OnPlayerHitGround中处理）。

GM:ValidMenuLockOnTarget 判断玩家是否可以对目标实体使用锁定菜单。

GM:GetHandsModel 获取玩家当前模型对应的手臂模型。

GM:GetBestAvailableZombieClass 获取玩家可用的最高级的僵尸职业。

GM:ShouldUseBetterVersionSystem 判断是否应启用僵尸职业的"高级版本"系统。

GM:DynamicSpawnIsValidOld (旧版逻辑) 检查一个动态僵尸出生点是否有效。

GM:GetBestDynamicSpawnOld (旧版逻辑) 寻找最佳的动态僵尸出生点。

GM:GetDynamicSpawnsOld (旧版逻辑) 获取所有可用的动态僵尸出生点列表。

GM:DynamicSpawnIsValid 检查一个动态出生点（僵尸或巢穴）是否有效。

GM:GetBestDynamicSpawn 寻找最佳的动态出生点。

GM:GetDynamicSpawns 获取所有可用的动态出生点（通常是爬行者巢穴）列表。

GM:GetDesiredStartingZombies 计算回合开始时应选择的初始僵尸数量。

GM:GetEndRound 检查回合是否已经结束。

GM:PrecacheResources 预缓存游戏所需的模型、声音和粒子效果等资源。

GM:ShouldCollide 决定两个实体之间是否应该发生碰撞。

GM:DoChangeDeploySpeed 根据玩家状态调整武器的切换速度。

GM:OnPlayerHitGround 处理玩家落地时的坠落伤害和效果。

GM:PlayerCanBeHealed 检查玩家是否可以被治疗。

GM:PlayerCanPurchase 检查人类玩家是否满足购买物品的条件。

GM:ZombieCanPurchase 检查僵尸玩家是否可以打开购买菜单。

GM:PlayerCanHearPlayersVoice 决定玩家之间是否能听到对方的语音。

GM:PlayerCanHearPlayersVoiceDefault 默认的语音通信规则。

GM:PlayerCanHearPlayersVoiceAllTalk 全局语音开启时的通信规则。

GM:PlayerTraceAttack 处理玩家受到子弹等射线攻击时的逻辑。

GM:GetDamageResistance 根据恐惧值和符文计算伤害抗性。

GM:FindUseEntity 寻找玩家准星指向的可交互实体。

GM:ShouldUseAlternateDynamicSpawn 判断是否应使用备用的（旧版）动态出生点系统。

GM:GetZombieDamageScale 根据恐惧值计算僵尸的伤害缩放比例。

GM:GetClosestSpawnPoint 从一个列表中找到离目标位置最近的出生点。

GM:GetFurthestSpawnPoint 从一个列表中找到离目标位置最远的出生点。

GM:GetTeamRallyGroups 识别并分组聚集在一起的同队玩家。

GM:GetTeamRallyPoints 计算队伍集结点的中心位置和强度。

GM:GetTeamEpicentre 计算一个队伍所有存活玩家的平均位置（中心点）。

GM:GetTeamEpicenter (同上)

GM:GetCurrentEquipmentCount 统计地图上特定装备的总数量。

GM:GetFearMeterPower 根据周围敌人的数量和距离计算一个点的"恐惧值"。

GM:GetRagdollEyes 获取玩家死亡后布娃娃模型的眼睛位置和朝向。

GM:PlayerNoClip 处理玩家尝试开启/关闭穿墙模式(noclip)的逻辑。

GM:IsSpecialPerson 检查玩家是否为开发者、管理员等特殊身份，并返回对应的图标信息。

GM:GetWaveEnd 获取当前波次结束的时间点。

GM:SetWaveEnd 设置当前波次结束的时间点。

GM:GetWaveStart 获取当前波次开始的时间点。

GM:SetWaveStart 设置当前波次开始的时间点。

GM:GetWave 获取当前是第几波。

GM:GetWaveActive 检查当前是否处于僵尸进攻的活跃波次。

GM:SetWaveActive 设置波次的活跃状态。

SoundDuration 修复引擎对.ogg和.mp3格式声音文件时长计算不准的问题。

GM:VehicleMove 载具移动时的钩子函数（当前为空）。
]]

-- ============================================================================
-- 游戏模式基本信息
-- 定义模式的名称、作者、联系方式和网站。
-- ============================================================================
GM.Name		=	"Zombie Survival"
GM.Author	=	"William \"JetBoom\" Moodhe"
GM.Email	=	"williammoodhe@gmail.com"
GM.Website	=	"http://www.noxiousnet.com"

-- 贡献者列表 — 按贡献类型分组
-- 注意：添加一把武器并不意味着你的名字就值得出现在这里。
GM.Credits = {
	{"William \"JetBoom\" Moodhe", "williammoodhe@gmail.com (www.noxiousnet.com)", "Creator / Programmer"},
	{"11k", "tjd113@gmail.com", "Zombie view models"},
	{"Eisiger", "k2deseve@gmail.com", "Zombie kill icons"},
	{"Austin \"Little Nemo\" Killey", "austin_odyssey@yahoo.com", "Ambient music"},
	{"Zombie Panic: Source", "http://www.zombiepanic.org/", "Melee weapon sounds"},
	{"Samuel", "samuel_games@hotmail.com", "Board Kit models"},
	{"Typhon", "lukas-tinel@hotmail.com", "Fear-o-meter textures"},
	{"Benjy, The Darker One, Raox, Scott", "", "Code contributions"},

	{"Mr. Darkness", "", "Russian translation"},
	{"honsal", "", "Korean translation"},
	{"rui_troia", "", "Portuguese translation"},
	{"Shinyshark", "", "Dutch translation"},
	{"Kradar", "", "Italian translation"},
	{"Raptor", "", "German translation"},
	{"The Special Duckling", "", "Danish translation"},
	{"ptown, Dr. Broly", "", "Spanish translation"},

	{"Anyone else on GitHub or who I've forgotten", "", "Various contributions"},
}

-- ============================================================================
-- 地图专用脚本加载
-- 如果当前地图在 maps/ 目录下有对应的 Lua 脚本文件，则将其包含进来。
-- 地图脚本文件命名规则：gamemode/maps/<地图名>.lua
-- ============================================================================
if file.Exists(GM.FolderName.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

-- ============================================================================
-- GM:GetNumberOfWaves
-- 功能：获取当前游戏的总波数（回合数）。
-- 逻辑：如果是经典模式则固定返回10波，否则使用全局变量"numwaves"的值。
--       如果该值为-2（表示"默认"），则使用 GM.NumberOfWaves 的默认值。
-- 返回值：number — 总波数
-- ============================================================================
function GM:GetNumberOfWaves()
	-- 经典模式：固定10波；否则使用默认波数
	local default = GetGlobalBool("classicmode") and 10 or self.NumberOfWaves
	-- numwaves 由 logic_waves 实体控制
	local num = GetGlobalInt("numwaves", default)
	return num == -2 and default or num
end

-- ============================================================================
-- GM:GetWaveOneLength
-- 功能：获取第一波僵尸进攻的持续时间。
-- 逻辑：经典模式下使用经典模式的第一波长度，否则使用标准的第一波长度。
-- 返回值：number — 第一波持续时间（秒）
-- ============================================================================
function GM:GetWaveOneLength()
	return GetGlobalBool("classicmode") and self.WaveOneLengthClassic or self.WaveOneLength
end

-- ============================================================================
-- 包含扩展脚本
-- 这些文件向各种核心对象（Vector、Entity、Player、Weapon）添加了扩展方法。
-- ============================================================================
include("obj_vector_extend.lua")
include("obj_entity_extend.lua")
include("obj_player_extend.lua")
include("obj_weapon_extend.lua")

-- ============================================================================
-- 包含共享基础脚本
-- 这些文件定义了翻译、颜色、序列化工具和通用工具函数。
-- ============================================================================
include("sh_translate.lua")
include("sh_colors.lua")
include("sh_serialization.lua")
include("sh_util.lua")

-- ============================================================================
-- 包含技能树系统
-- 定义了玩家的技能树相关逻辑。
-- ============================================================================
include("skillweb/sh_skillweb.lua")

-- ============================================================================
-- 包含游戏选项、僵尸商店、僵尸职业、动画、符文、频道和武器品质系统
-- 这些文件定义了游戏的核心配置和机制。
-- ============================================================================
include("sh_options.lua")
include("sh_zombieshop.lua")
include("sh_zombieclasses.lua")
include("sh_animations.lua")
include("sh_sigils.lua")
include("sh_channel.lua")
include("sh_weaponquality.lua")

-- ============================================================================
-- 包含 NoxAPI 系统
-- NoxAPI 是一个用于服务端-客户端通信和功能扩展的 API 层。
-- ============================================================================
include("noxapi/noxapi.lua")

-- ============================================================================
-- 包含保险库/存储系统
-- 定义了玩家的存储箱和共享库存逻辑。
-- ============================================================================
include("vault/shared.lua")

-- ============================================================================
-- 包含 Workshop 修复脚本
-- 修复创意工坊物品相关的问题。
-- ============================================================================
include("workshopfix.lua")

-- ============================================================================
-- 包含库模块（性能优化、玩家移动、库存、弹药扩展）
-- include_library 是一个自定义函数，用于按需加载子模块。
-- ============================================================================
include_library("perf")
include_library("player_movement")
include_library("inventory")
include_library("ammoexpand")

-- ============================================================================
-- 全局变量定义
-- ============================================================================

-- 回合是否已结束的标记（布尔值）
GM.EndRound = false

-- 初始购买金额（人类玩家回合开始时拥有的资金）
GM.StartingWorth = 250

-- 自愿选择成为僵尸的玩家列表（用于回合开始时确定初始僵尸）
GM.ZombieVolunteers = {}

-- 随机初始装备配置列表（由 sv_options.lua 填充）
GM.StartLoadouts = {}

-- ============================================================================
-- 设置游戏团队
-- TEAM_ZOMBIE（亡灵/僵尸） — 绿色
-- TEAM_SURVIVORS（幸存者/人类） — 蓝色
-- ============================================================================
team.SetUp(TEAM_ZOMBIE, "The Undead", Color(0, 255, 0, 255))
team.SetUp(TEAM_SURVIVORS, "Survivors", Color(0, 160, 255, 255))

-- ============================================================================
-- 有效玩家模型列表（排除 Team Fortress 2 的模型）
-- 防止玩家使用 TF2 模型导致兼容性问题。
-- ============================================================================
local validmodels = player_manager.AllValidModels()
validmodels["tf01"] = nil
validmodels["tf02"] = nil

-- ============================================================================
-- 微小向量常量
-- 用于一些边界计算（如0尺寸碰撞盒兼容性处理）。
-- ============================================================================
vector_tiny = Vector(0.001, 0.001, 0.001)

-- ============================================================================
-- GM.SoundDuration
-- 功能：声音时长修正表
-- 说明：Garry's Mod 引擎对 .ogg 和 .mp3 格式的声音文件时长计算不准确，
--       该表存储了各种声音文件的实际时长（秒）用于替代引擎的估算值。
-- 注意：实际运行时还有一个全局的 SoundDuration 函数覆盖（见文件末尾），
--       但这个表可能在某些场景下被直接查找使用。
-- ============================================================================
GM.SoundDuration = {
	["zombiesurvival/music_win.ogg"] = 33.149,
	["zombiesurvival/music_lose.ogg"] = 45.714,
	["zombiesurvival/lasthuman.ogg"] = 120.503,

	["zombiesurvival/beats/defaulthuman/1.ogg"] = 7.111,
	["zombiesurvival/beats/defaulthuman/2.ogg"] = 7.111,
	["zombiesurvival/beats/defaulthuman/3.ogg"] = 7.111,
	["zombiesurvival/beats/defaulthuman/4.ogg"] = 7.111,
	["zombiesurvival/beats/defaulthuman/5.ogg"] = 7.111,
	["zombiesurvival/beats/defaulthuman/6.ogg"] = 14.222,
	["zombiesurvival/beats/defaulthuman/7.ogg"] = 14.222,
	["zombiesurvival/beats/defaulthuman/8.ogg"] = 7.111,
	["zombiesurvival/beats/defaulthuman/9.ogg"] = 14.222,

	["zombiesurvival/beats/defaultzombiev2/1.ogg"] = 8,
	["zombiesurvival/beats/defaultzombiev2/2.ogg"] = 8,
	["zombiesurvival/beats/defaultzombiev2/3.ogg"] = 8,
	["zombiesurvival/beats/defaultzombiev2/4.ogg"] = 8,
	["zombiesurvival/beats/defaultzombiev2/5.ogg"] = 8,
	["zombiesurvival/beats/defaultzombiev2/6.ogg"] = 6.038,
	["zombiesurvival/beats/defaultzombiev2/7.ogg"] = 6.038,
	["zombiesurvival/beats/defaultzombiev2/8.ogg"] = 6.038,
	["zombiesurvival/beats/defaultzombiev2/9.ogg"] = 6.038,
	["zombiesurvival/beats/defaultzombiev2/10.ogg"] = 6.038
}

-- ============================================================================
-- 局部引用缓存（性能优化）
-- 将全局变量缓存为局部变量，减少表查找开销。
-- ============================================================================
local SERVER = SERVER
local CLIENT = CLIENT
local HITGROUP_HEAD = HITGROUP_HEAD
local HITGROUP_LEFTARM = HITGROUP_LEFTARM
local HITGROUP_RIGHTARM = HITGROUP_RIGHTARM
local HITGROUP_GEAR = HITGROUP_GEAR
local HITGROUP_STOMACH = HITGROUP_STOMACH
local HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
local HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
local PTeam = FindMetaTable("Player").Team

-- ============================================================================
-- GM:AddCustomAmmo
-- 功能：注册游戏模式所需的所有自定义弹药类型。
-- 说明：除了标准的弹药类型外，僵尸生存模式使用了大量自定义弹药类型，
--       包括各种特殊武器（投掷物、陷阱、无人机、炮塔、食物等）使用的弹药。
-- 调用时机：通常在 GM:Initialize 中调用。
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:AddCustomAmmo()
	game.AddAmmoType({name = "dummy"})
	game.AddAmmoType({name = "pulse"})
	game.AddAmmoType({name = "impactmine"})
	game.AddAmmoType({name = "chemical"})
	game.AddAmmoType({name = "scrap"})

	game.AddAmmoType({name = "stone"})
	game.AddAmmoType({name = "flashbomb"})
	game.AddAmmoType({name = "betty"})
	game.AddAmmoType({name = "molotov"})
	game.AddAmmoType({name = "corgasgrenade"})
	game.AddAmmoType({name = "crygasgrenade"})
	game.AddAmmoType({name = "bloodshot"})

	game.AddAmmoType({name = "spotlamp"})
	game.AddAmmoType({name = "manhack"})
	game.AddAmmoType({name = "manhack_saw"})
	game.AddAmmoType({name = "drone"})
	game.AddAmmoType({name = "pulse_cutter"})
	game.AddAmmoType({name = "drone_hauler"})
	game.AddAmmoType({name = "rollermine"})
	game.AddAmmoType({name = "sigilfragment"})
	game.AddAmmoType({name = "corruptedfragment"})
	game.AddAmmoType({name = "mediccloudbomb"})
	game.AddAmmoType({name = "nanitecloudbomb"})
	game.AddAmmoType({name = "repairfield"})
	game.AddAmmoType({name = "medicfield"})
	game.AddAmmoType({name = "zapper"})
	game.AddAmmoType({name = "zapper_arc"})
	game.AddAmmoType({name = "remantler"})
	game.AddAmmoType({name = "turret_buckshot"})
	game.AddAmmoType({name = "turret_assault"})
	game.AddAmmoType({name = "turret_rocket"})
	game.AddAmmoType({name = "turret_pulse"})
	game.AddAmmoType({name = "camera"})
	game.AddAmmoType({name = "tv"})

	game.AddAmmoType({name = "foodwatermelon"})
	game.AddAmmoType({name = "foodorange"})
	game.AddAmmoType({name = "foodbanana"})
	game.AddAmmoType({name = "foodsoda"})
	game.AddAmmoType({name = "foodmilk"})
	game.AddAmmoType({name = "foodtakeout"})
	game.AddAmmoType({name = "foodwater"})
end

-- ============================================================================
-- GM.Food — 食物武器类名列表
-- 存储所有以 weapon_zs_basefood 为基类的武器名称。
-- ============================================================================
GM.Food = {}

-- ============================================================================
-- GM:RegisterFood
-- 功能：扫描所有已注册的武器，找出所有基类为 weapon_zs_basefood 的武器
--       （即食物类物品），并将它们的类名存入 GM.Food 表中供后续使用。
-- 调用时机：在所有武器加载完成后调用（通常在 GM:InitPostEntity 中）。
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:RegisterFood()
	self.Food = {}

	for k, v in pairs(weapons.GetList()) do
		if v.Base == "weapon_zs_basefood" then
			table.insert(self.Food, v.ClassName)
		end
	end
end

-- ============================================================================
-- GM:RefreshMapIsObjective
-- 功能：根据当前地图的名称判断是否为目标模式地图（Objective Map）。
-- 判断规则：地图名包含 "_obj_" 或 "objective"（不区分大小写）则视为目标模式。
-- 目标模式地图通常有不同的游戏规则（如僵尸逃生）。
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:RefreshMapIsObjective()
	local mapname = string.lower(game.GetMap())
	if string.find(mapname, "_obj_", 1, true) or string.find(mapname, "objective", 1, true) then
		self.ObjectiveMap = true
	else
		self.ObjectiveMap = false
	end
end

-- ============================================================================
-- GM:AssignItemProperties
-- 功能：为商店中的物品分配武器属性（描述、品质等级、最大库存、名称）。
-- 说明：如果物品对应的 SWEP（武器）在库存物品数据表中有定义，则从那里
--       继承属性；否则直接从武器定义表中获取。仅当物品尚未设置该属性时
--       才进行赋值（避免覆盖手动设置的值）。
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:AssignItemProperties()
	for _, tab in ipairs(self.Items) do
		if tab.SWEP then
			-- 从库存物品数据表或武器定义表获取 SWEP 数据
			local sweptab = self.ZSInventoryItemData[tab.SWEP] or weapons.Get(tab.SWEP)
			if sweptab then
				if not tab.Description then
					tab.Description = sweptab.Description
				end
				if not tab.Tier then
					tab.Tier = sweptab.Tier
				end
				if not tab.MaxStock then
					tab.MaxStock = sweptab.MaxStock
				end
				if tab.Name == "?" then
					tab.Name = sweptab.PrintName or tab.Name
				end
			end
		end
	end
end

-- ============================================================================
-- GM:SetupDefaultClip
-- 功能：计算并设置武器的默认弹药量（DefaultClip）。
-- 计算公式：DefaultClip = 弹匣容量 × 生存弹药倍率 × 武器自定义倍率
-- 参数：
--   tab — 武器的定义表（SWEP table）
-- 返回值：无
-- ============================================================================
function GM:SetupDefaultClip(tab)
	tab.DefaultClip = math.ceil(tab.ClipSize * self.SurvivalClips * (tab.ClipMultiplier or 1))
end

-- ============================================================================
-- GM:FixWeaponBase
-- 功能：修复和增强基础武器类 weapon_base 的功能。
-- 说明：部分武器派生自 weapon_base，需要使用 .Owner 属性。此函数为
--       weapon_base 添加缺失的方法或修复现有方法的行为。
-- 具体修改：
--   1. TranslateActivity — 安全地翻译武器活动（动画）ID
--   2. TakePrimaryAmmo — 正确处理弹药消耗（弹匣优先，备用弹药其次）
--   3. Ammo1 — 获取主要弹药类型的当前数量
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:FixWeaponBase()
	local base = weapons.GetStored("weapon_base")

	-- 修复武器活动翻译函数，防止因活动不存在而报错
	base.TranslateActivity = function(me)
		if me.ActivityTranslate[act] ~= nil then
			return me.ActivityTranslate[act]
		end

		return -1
	end

	-- 修复消耗弹药逻辑：
	-- 如果弹匣中有子弹，先从弹匣扣除；
	-- 如果弹匣空了但有备用弹药，从备用弹药扣除。
	base.TakePrimaryAmmo = function(me, num)
		if me.Weapon:Clip1() <= 0 then
			if me:Ammo1() <= 0 then return end

			me:GetOwner():RemoveAmmo(num, me.Weapon:GetPrimaryAmmoType())

			return
		end

		me.Weapon:SetClip1(me.Weapon:Clip1() - num)
	end

	-- 修复获取主要弹药数量的方法
	base.Ammo1 = function(me)
		return me:GetOwner():GetAmmoCount(me.Weapon:GetPrimaryAmmoType())
	end
end

-- ============================================================================
-- GM:GetRedeemBrains
-- 功能：获取僵尸玩家复活所需消耗的"脑子"数量。
-- 逻辑：优先使用全局变量"redeembrains"，否则使用默认值。
-- 参数：无
-- 返回值：number — 复活所需脑子数量
-- ============================================================================
function GM:GetRedeemBrains()
	return GetGlobalInt("redeembrains", self.DefaultRedeem)
end

-- ============================================================================
-- GM:PlayerIsAdmin
-- 功能：判断指定玩家是否为管理员。
-- 参数：
--   pl — 玩家对象（Player）
-- 返回值：boolean — 是否为管理员
-- ============================================================================
function GM:PlayerIsAdmin(pl)
	return pl:IsAdmin()
end

-- ============================================================================
-- GM:GetFallDamage
-- 功能：获取玩家应受到的坠落伤害值。
-- 说明：此函数始终返回0，因为实际的坠落伤害逻辑在 OnPlayerHitGround
--       中处理。这个函数存在是为了覆盖引擎的默认坠落伤害行为。
-- 参数：
--   pl — 玩家对象
--   fallspeed — 下落速度
-- 返回值：number — 始终为0
-- ============================================================================
function GM:GetFallDamage(pl, fallspeed)
	return 0 -- 坠落伤害在 OnPlayerHitGround 中处理
end

-- ============================================================================
-- GM:ValidMenuLockOnTarget
-- 功能：判断玩家是否可以对目标实体使用锁定菜单（如瞄准锁定功能）。
-- 条件：
--   1. 目标实体是有效的活人类实体
--   2. 目标在48单位距离内（距离平方 <= 2304）
--   3. 玩家到目标之间没有障碍物遮挡（TrueVisible）
-- 参数：
--   pl — 发起锁定的玩家
--   ent — 目标实体
-- 返回值：boolean — 是否可以锁定
-- ============================================================================
function GM:ValidMenuLockOnTarget(pl, ent)
	if ent and ent:IsValidLivingHuman() then
		local startpos = pl:EyePos()
		local endpos = ent:NearestPoint(startpos)
		-- 检查距离（48^2 = 2304）和视线是否通畅
		if startpos:DistToSqr(endpos) <= 2304 and TrueVisible(startpos, endpos) then
			return true
		end
	end

	return false
end

-- ============================================================================
-- GM:GetHandsModel
-- 功能：根据玩家当前使用的模型获取对应的手臂（hand）模型。
-- 通过 player_manager 系统进行模型到手臂的转换。
-- 参数：
--   pl — 玩家对象
-- 返回值：table — 手臂模型数据
-- ============================================================================
function GM:GetHandsModel(pl)
	return player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(pl:GetModel()))
end

-- ============================================================================
-- GM:GetBestAvailableZombieClass
-- 功能：获取玩家可用的最高级的僵尸职业。
-- 逻辑：如果启用了"高级版本"系统且当前职业有更高级版本（BetterVersion），
--       则自动升级到已解锁的最高级版本。
-- 参数：
--   baseclass_id — 基础职业的ID
-- 返回值：number — 最佳可用职业的索引（Index）
-- ============================================================================
function GM:GetBestAvailableZombieClass(baseclass_id)
	if self:ShouldUseBetterVersionSystem() then
		local baseclass

		-- 循环查找最高级的已解锁版本
		while true do
			baseclass = self.ZombieClasses[baseclass_id]
			-- 如果当前职业有 BetterVersion 且已解锁，则升级
			if baseclass and baseclass.BetterVersion and self:IsClassUnlocked(baseclass.BetterVersion) then
				baseclass_id = baseclass.BetterVersion
			else
				break
			end
		end
	end

	return self.ZombieClasses[baseclass_id].Index
end

-- ============================================================================
-- GM:ShouldUseBetterVersionSystem
-- 功能：判断是否应启用僵尸职业的"高级版本"升级系统。
-- 逻辑：在目标模式（Objective）地图中禁用高级版本系统。
-- 参数：无
-- 返回值：boolean — 是否启用高级版本系统
-- ============================================================================
function GM:ShouldUseBetterVersionSystem()
	return not self.ObjectiveMap
end

-- ============================================================================
-- 局部常量定义（用于动态出生点计算）
-- playerheight — 玩家站立高度（72单位）
-- playermins — 玩家碰撞盒最小边界
-- playermaxs — 玩家碰撞盒最大边界（仅4单位高，用于地面检测）
-- SkewedDistance — 倾斜距离计算函数引用（性能优化）
-- ============================================================================
local playerheight = Vector(0, 0, 72)
local playermins = Vector(-17, -17, 0)
local playermaxs = Vector(17, 17, 4)
local SkewedDistance = util.SkewedDistance

-- 旧版动态出生点 — 可见性检测距离（2048单位）
GM.DynamicSpawnDistVisOld = 2048
-- 旧版动态出生点 — 基础检测距离（640单位）
GM.DynamicSpawnDistOld = 640

-- ============================================================================
-- GM:DynamicSpawnIsValidOld (旧版逻辑)
-- 功能：（旧版）检查一个僵尸是否可以作为一个有效的动态出生点。
-- 条件：
--   1. 僵尸最近2秒内没有被 trigger_hurt 伤害
--   2. 僵尸活着、处于行走移动模式、在地面上
--   3. 僵尸位置有足够的站立空间（不被方块阻挡）
--   4. 僵尸不在天空盒或不可绘制表面上
--   5. 僵尸不在任何人形玩家的近距离范围内
--   6. 僵尸不被任何人形玩家直接看到
-- 参数：
--   zombie — 僵尸玩家
--   humans — 人类玩家列表（可选，用于缓存优化）
--   allplayers — 所有玩家列表（可选，用于缓存优化）
-- 返回值：boolean — 是否可作为有效出生点
-- ============================================================================
function GM:DynamicSpawnIsValidOld(zombie, humans, allplayers)
	-- 注意：我没有检查 trigger_hurt 实体本身，而是检查上次被 trigger_hurt
	-- 击中后的时间。我不确定是否可以通过 Lua 绑定检查 trigger_hurt 的启用/禁用状态。
	if SERVER and zombie.LastHitWithTriggerHurt and CurTime() < zombie.LastHitWithTriggerHurt + 2 then
		return false
	end

	local hpos, nearest, dist

	-- 可选缓存参数：如果未提供则实时获取
	if not humans then humans = team.GetPlayers(TEAM_HUMAN) end
	if not allplayers then allplayers = player.GetAll() end

	local pos = zombie:GetPos() + Vector(0, 0, 1)
	-- 检查僵尸是否存活、行走模式、在地面上，且站立位置不被阻挡
	if zombie:Alive() and zombie:GetMoveType() == MOVETYPE_WALK and zombie:OnGround()
	and not util.TraceHull({start = pos, endpos = pos + playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID, filter = allplayers}).Hit then
		-- 检查上方是否有站立空间，下方是否是有效地面
		local vtr = util.TraceHull({start = pos, endpos = pos - playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID_BRUSHONLY})
		if not vtr.HitSky and not vtr.HitNoDraw then
			local valid = true

			-- 对所有人类玩家进行距离和可见性检查
			for _, human in pairs(humans) do
				hpos = human:GetPos()
				nearest = zombie:NearestPoint(hpos)
				-- 倾斜距离计算：如果僵尸在人类下方，Z轴距离会被加权放大
				dist = SkewedDistance(hpos, nearest, 2.75)
				-- 僵尸不能在任意人类的近距离范围内；僵尸不能被任意人类清晰看到
				if dist <= self.DynamicSpawnDistOld or dist <= self.DynamicSpawnDistVisOld and WorldVisible(hpos, nearest) then
					valid = false
					break
				end
			end

			return valid
		end
	end

	return false
end

-- ============================================================================
-- GM:GetBestDynamicSpawnOld (旧版逻辑)
-- 功能：从所有可用的旧版动态出生点中，选择离指定位置（或人类中心点）最近的。
-- 如果所有出生点都不理想，则随机选一个。
-- 参数：
--   pl — 当前僵尸玩家
--   pos — 目标位置（可选，默认为人类队伍的 Epicentre 中心点）
-- 返回值：Player|nil — 最佳的僵尸出生点，如果没有则返回 nil
-- ============================================================================
function GM:GetBestDynamicSpawnOld(pl, pos)
	local spawns = self:GetDynamicSpawnsOld(pl)
	if #spawns == 0 then return end

	return self:GetClosestSpawnPoint(spawns, pos or self:GetTeamEpicentre(TEAM_HUMAN)) or table.Random(spawns)
end

-- ============================================================================
-- GM:GetDynamicSpawnsOld (旧版逻辑)
-- 功能：获取所有可用的旧版动态出生点（僵尸玩家）。
-- 遍历所有亡灵队伍（TEAM_UNDEAD）的玩家，筛选出有效的出生点。
-- 参数：
--   pl — 当前僵尸玩家（会被排除在出生点列表之外）
-- 返回值：table — 有效僵尸出生点列表
-- ============================================================================
function GM:GetDynamicSpawnsOld(pl)
	local tab = {}

	local allplayers = player.GetAll()
	local humans = team.GetPlayers(TEAM_HUMAN)
	for _, zombie in pairs(team.GetPlayers(TEAM_UNDEAD)) do
		if zombie ~= pl and self:DynamicSpawnIsValidOld(zombie, humans, allplayers) then
			table.insert(tab, zombie)
		end
	end

	return tab
end

-- ============================================================================
-- 新版动态出生点配置常量
-- ============================================================================

-- 动态出生点基础距离（512单位）
GM.DynamicSpawnDist = 512
-- 动态出生点可见性检测距离（2048单位）
GM.DynamicSpawnDistVis = 2048
-- 爬行者巢穴（Creeper Nest）的最小安全距离（150单位）
GM.CreeperNestDist = 150
-- 爬行者巢穴建造距离（420单位）
GM.CreeperNestDistBuild = 420
-- 巢穴之间建造最小距离（192单位）
GM.CreeperNestDistBuildNest = 192
-- 僵尸出生点之间建造最小距离（256单位）
GM.CreeperNestDistBuildZSpawn = 256

-- 用于出生点碰撞检测的射线追踪参数模板（复用避免重复创建表）
local trace_dynspawn = {mins = playermins, maxs = playermaxs, mask = MASK_SOLID}
-- 用于天空盒/不可绘制表面检测的射线模板
local trace_dynspawn_skybox = {mins = playermins, maxs = playermaxs, mask = MASK_SOLID_BRUSHONLY}

-- ============================================================================
-- GM:DynamicSpawnIsValid
-- 功能：检查一个实体（僵尸或爬行者巢穴）是否可以作为有效的动态出生点。
-- 逻辑：
--   1. 如果使用替代（旧版）系统，则委托给 DynamicSpawnIsValidOld
--   2. 巢穴（prop_creepernest）需要已建造完成
--   3. 检查出生点是否有足够的站立空间
--   4. 检查出生点是否离人类太近
--   5. 非巢穴实体还需要检查是否被人类看到
-- 参数：
--   ent — 要检查的实体（玩家或巢穴）
--   humans — 人类玩家列表（可选，缓存优化）
--   allplayers — 所有玩家列表（可选，缓存优化）
-- 返回值：boolean — 是否可作为有效出生点
-- ============================================================================
function GM:DynamicSpawnIsValid(ent, humans, allplayers)
	if self:ShouldUseAlternateDynamicSpawn() then
		return self:DynamicSpawnIsValidOld(ent, humans, allplayers)
	end

	-- 可选缓存参数：如果未提供则实时获取
	if not humans then humans = team.GetPlayers(TEAM_HUMAN) end
	if not allplayers then allplayers = player.GetAll() end

	local pos = ent:GetPos() + Vector(0, 0, 1)
	-- 判断是否是巢穴实体
	local is_nest = ent:GetClass() == "prop_creepernest"
	-- 巢穴使用更短的安全距离，且不需要可见性检查
	local required_distance = is_nest and self.CreeperNestDist or self.DynamicSpawnDist

	-- 如果巢穴未建造完成，则不可用作出生点
	if is_nest and not ent:GetNestBuilt() then
		return false
	end

	-- 检查出生点是否有足够站立空间（头部不被方块阻挡）
	trace_dynspawn.start = pos
	trace_dynspawn.endpos = pos + playerheight
	trace_dynspawn.filter = allplayers
	table.insert(trace_dynspawn.filter, ent)
	local tr = util.TraceHull(trace_dynspawn)
	if tr.Hit then
		return false
	end

	-- 以下代码被注释掉：
	-- 理论上不应在 nodraw/skybox 上方建造巢穴
	-- 所以这里省略了对天空盒/不可绘制表面的检测
	-- 检查是否在 nodraw / skybox 上方
	-- trace_dynspawn_skybox.start = pos
	-- trace_dynspawn_skybox.endpos = pos - playerheight
	-- local vtr = util.TraceHull(trace_dynspawn_skybox)
	-- if vtr.HitSky or vtr.HitNoDraw then
	-- 	return false
	-- end
	-- vtr = util.TraceLine(trace_dynspawn_skybox)
	-- if vtr.HitSky or vtr.HitNoDraw then
	-- 	return false
	-- end

	-- 检查是否离任何人类玩家太近
	local nearest, dist
	for _, human in pairs(humans) do
		nearest = human:NearestPoint(pos)
		dist = SkewedDistance(nearest, pos, 2.75)
		-- 如果实体在人类下方，Z轴距离会被加权放大
		if dist <= required_distance then
			return false
		end

		-- 非巢穴实体还需要检查是否被人类看到
		if not is_nest and dist <= self.DynamicSpawnDistVis and WorldVisible(nearest, pos) then
			return false
		end
	end

	return true
end

-- ============================================================================
-- GM:GetBestDynamicSpawn
-- 功能：获取最佳的动态出生点（优先使用新版系统）。
-- 逻辑：从所有有效动态出生点中选择离指定位置最近的。
--       如果使用替代（旧版）系统，则委托给 GetBestDynamicSpawnOld。
-- 参数：
--   pl — 当前僵尸玩家
--   pos — 目标位置（可选，默认为人类队伍的中心点）
-- 返回值：Entity|nil — 最佳出生点实体，如果没有则返回 nil
-- ============================================================================
function GM:GetBestDynamicSpawn(pl, pos)
	if self:ShouldUseAlternateDynamicSpawn() then
		return self:GetBestDynamicSpawnOld(pl, pos)
	end

	local spawns = self:GetDynamicSpawns(pl)
	if #spawns == 0 then return end

	return self:GetClosestSpawnPoint(spawns, pos or self:GetTeamEpicentre(TEAM_HUMAN)) or table.Random(spawns)
end

-- ============================================================================
-- GM:GetDynamicSpawns
-- 功能：获取所有可用的动态出生点列表（优先使用新版系统）。
-- 逻辑：遍历所有爬行者巢穴实体（prop_creepernest），筛选出有效的巢穴。
--       如果使用替代（旧版）系统，则委托给 GetDynamicSpawnsOld。
-- 参数：
--   pl — 当前僵尸玩家
-- 返回值：table — 有效动态出生点（巢穴）列表
-- ============================================================================
function GM:GetDynamicSpawns(pl)
	if self:ShouldUseAlternateDynamicSpawn() then
		return self:GetDynamicSpawnsOld(pl)
	end

	local tab = {}

	local humans = team.GetPlayers(TEAM_HUMAN)
	for _, nest in pairs(ents.FindByClass("prop_creepernest")) do
		if self:DynamicSpawnIsValid(nest, humans) then
			table.insert(tab, nest)
		end
	end

	return tab
end

-- ============================================================================
-- GM:GetDesiredStartingZombies
-- 功能：计算回合开始时应该选择多少玩家作为初始僵尸。
-- 公式：玩家总数 × 第一波僵尸比例，向上取整，
--       最小为1，最大为（玩家总数 - 1）。
-- 参数：无
-- 返回值：number — 期望的初始僵尸数量
-- ============================================================================
function GM:GetDesiredStartingZombies()
	local numplayers = #player.GetAllActive()
	return math.Clamp(math.ceil(numplayers * self.WaveOneZombies), 1, numplayers - 1)
end

-- ============================================================================
-- GM:GetEndRound
-- 功能：检查当前回合是否已经结束。
-- 参数：无
-- 返回值：boolean — 回合是否结束
-- ============================================================================
function GM:GetEndRound()
	return self.RoundEnded
end

-- ============================================================================
-- GM:PrecacheResources
-- 功能：预缓存游戏运行所需的资源（声音、模型、粒子效果）。
-- 提前加载资源可以避免游戏过程中出现卡顿。
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:PrecacheResources()
	util.PrecacheSound("physics/body/body_medium_break2.wav")
	util.PrecacheSound("physics/body/body_medium_break3.wav")
	util.PrecacheSound("physics/body/body_medium_break4.wav")
	-- 预缓存所有有效的玩家模型
	for name, mdl in pairs(player_manager.AllValidModels()) do
		util.PrecacheModel(mdl)
	end

	game.AddParticles("particles/vman_explosion.pcf")
	PrecacheParticleSystem("dusty_explosion_rockets")
end

-- ============================================================================
-- GM:ShouldCollide
-- 功能：判断两个实体之间是否应该发生物理碰撞。
-- 逻辑：每个实体可以定义 ShouldNotCollide 方法来指定不需要碰撞的实体类型。
--       只有当两个实体都同意碰撞（没有拒绝碰撞）时才发生碰撞。
-- 参数：
--   enta — 第一个实体
--   entb — 第二个实体
-- 返回值：boolean — 是否应发生碰撞
-- ============================================================================
function GM:ShouldCollide(enta, entb)
	-- 检查 enta 是否拒绝与 entb 碰撞
	local snca = enta.ShouldNotCollide
	if snca and snca(enta, entb) then return false end

	-- 检查 entb 是否拒绝与 enta 碰撞
	local sncb = entb.ShouldNotCollide
	if sncb and sncb(entb, enta) then return false end

	return true
end

-- ============================================================================
-- GM:DoChangeDeploySpeed
-- 功能：根据玩家当前状态调整武器的切换（部署）速度。
-- 影响因素：
--   1. 基础部署速度（BaseDeploySpeed）
--   2. 玩家的部署速度倍率（DeploySpeedMultiplier）
--   3. 玩家是否处于冰冻状态（frost，减速30%）
-- 参数：
--   wep — 要调整部署速度的武器实体
-- 返回值：无
-- ============================================================================
function GM:DoChangeDeploySpeed(wep)
	if wep:IsValid() and wep.SetDeploySpeed and not wep.NoDeploySpeedChange then
		local owner = wep:GetOwner()
		wep:SetDeploySpeed(self.BaseDeploySpeed * (owner:IsValid() and owner.DeploySpeedMultiplier or 1) * (owner:IsValid() and owner:GetStatus("frost") and 0.7 or 1))
	end
end

-- ============================================================================
-- GM:OnPlayerHitGround
-- 功能：处理玩家从高处落地时的坠落伤害和各种效果。
-- 逻辑：
--   1. 在水中落地则无伤害
--   2. 速度 > 64 单位/秒时设置落地减速标记（LandSlow）
--   3. 僵尸职业如果具有"无坠落伤害"特性则跳过伤害计算
--   4. 人类和僵尸使用不同的阈值和伤害倍率
--   5. 坠落伤害公式：0.1 × (速度 - 525 × 阈值) ^ 1.45
--   6. 如果落在漂浮物上，伤害减半
--   7. 如果玩家有"curbstompers"饰品且踩到僵尸，对僵尸造成额外伤害
--   8. 如果伤害 ≥ 5，触发腿部伤害减速效果
-- 参数：
--   pl — 落地的玩家
--   inwater — 是否落在水中
--   hitfloater — 是否落在漂浮物上
--   speed — 落地时的速度
-- 返回值：boolean — 始终返回 true（覆盖引擎默认坠落行为）
-- ============================================================================
function GM:OnPlayerHitGround(pl, inwater, hitfloater, speed)
	-- 在水中落地时无伤害
	if inwater then return true end

	-- 速度超过64时标记为"硬着陆"，后续可能触发减速
	if speed > 64 then
		pl.LandSlow = true
	end

	-- 检查是否为亡灵（僵尸）队伍
	local isundead = PTeam(pl) == TEAM_UNDEAD
	-- 僵尸职业如果拥有 NoFallDamage 特性则完全免疫坠落伤害
	if isundead and pl:GetZombieClassTable().NoFallDamage then return true end

	-- 伤害计算相关倍率
	local threshold_mul  -- 伤害阈值倍率
	local slowdown_mul   -- 减速倍率
	local recovery_mul   -- 恢复倍率
	local damage_mul     -- 伤害倍率

	if isundead then
		-- 僵尸：降低200单位速度阈值（僵尸更耐摔）
		speed = math.max(0, speed - 200)

		threshold_mul = 1
		slowdown_mul = 1
		recovery_mul = 1
		damage_mul = 1
	else
		-- 人类：使用玩家自定义的倍率（可能来自技能或装备）
		threshold_mul = pl.FallDamageThresholdMul or 1
		slowdown_mul = pl.FallDamageSlowDownMul or 1
		recovery_mul = pl.FallDamageRecoveryMul or 1
		damage_mul = pl.FallDamageDamageMul or 1
	end

	-- 计算坠落伤害：速度超出阈值部分按指数增长
	local damage = (0.1 * (speed - 525 * threshold_mul)) ^ 1.45
	-- 落在漂浮物上时伤害减半
	if hitfloater then damage = damage / 2 end

	if SERVER then
		-- 处理"curbstompers"饰品效果：踩到僵尸时造成额外伤害
		local groundent = pl:GetGroundEntity()
		if groundent:IsValid() and groundent:IsPlayer() and PTeam(groundent) == TEAM_UNDEAD and pl:HasTrinket("curbstompers") then
			-- 对不同类型的僵尸造成不同的伤害
			if groundent:IsHeadcrab() then
				groundent:TakeSpecialDamage(groundent:Health() + 70, DMG_DIRECT, pl, pl, pl:GetPos())
			elseif groundent:IsTorso() then
				groundent:TakeSpecialDamage(50, DMG_CLUB, pl, pl, pl:GetPos())
			end

			-- 额外基于坠落伤害的5倍伤害
			if math.floor(damage) > 0 then
				groundent:TakeSpecialDamage(damage * 5, DMG_CLUB, pl, pl, pl:GetPos())
				return true
			end
		end
	end

	-- 如果计算出的伤害 > 0，则应用伤害和效果
	if math.floor(damage) > 0 then
		if SERVER then
			-- 服务端：应用实际伤害，并触发减速效果
			local h = pl:Health()
			pl:TakeSpecialDamage(damage * damage_mul, DMG_FALL, game.GetWorld(), game.GetWorld(), pl:GetPos())
			damage = h - pl:Health()

			-- 非僵尸逃生模式下，伤害 ≥ 5 且玩家存活时触发效果
			if not self.ZombieEscape and damage >= 5 and pl:Health() > 0 then
				-- 伤害 ≥ 30 时触发击倒效果
				if damage >= 30 then
					pl:KnockDown(damage * 0.05 * recovery_mul)
				end
				-- 除非僵尸职业具有"无坠落减速"特性，否则触发腿部减速
				if not isundead or not pl:GetZombieClassTable().NoFallSlowdown then
					pl:RawCapLegDamage(CurTime() + math.min(2, damage * 0.038 * slowdown_mul))
				end
			end

			-- 播放落地疼痛音效
			pl:EmitSound("player/pl_fallpain"..(math.random(2) == 1 and 3 or 1)..".wav")
		elseif not self.ZombieEscape and damage >= 5 and (not isundead or not pl:GetZombieClassTable().NoFallSlowdown) then
			-- 客户端：仅处理腿部减速效果
			pl:RawCapLegDamage(CurTime() + math.min(2, damage * 0.038 * slowdown_mul))
		end
	end

	return true
end

-- ============================================================================
-- GM:PlayerCanBeHealed
-- 功能：判断一个玩家是否可以被治疗。
-- 条件：满足以下任一条件即可被治疗：
--   1. 当前生命值低于最大生命值
--      注意：如果玩家激活了 SKILL_D_FRAIL（脆弱）技能，最大生命值降为25%
--   2. 当前受到毒伤害
--   3. 当前受到流血伤害
-- 参数：
--   pl — 要检查的玩家
-- 返回值：boolean — 是否可以治疗
-- ============================================================================
function GM:PlayerCanBeHealed(pl)
	-- 如果玩家有"脆弱"技能，可治疗的最大生命值降为原来的25%
	local maxhp = pl:IsSkillActive(SKILL_D_FRAIL) and math.floor(pl:GetMaxHealth() * 0.25) or pl:GetMaxHealth()

	-- 生命值不满、中毒或流血时均可治疗
	return pl:Health() < maxhp or pl:GetPoisonDamage() > 0 or pl:GetBleedDamage() > 0
end

-- ============================================================================
-- GM:PlayerCanPurchase
-- 功能：检查人类玩家是否可以打开购买菜单（购买装备）。
-- 条件：
--   1. 玩家是人类队伍（TEAM_HUMAN）
--   2. 当前波次 > 0（游戏已开始）
--   3. 玩家还活着
--   4. 玩家在武器箱附近（NearArsenalCrate）
-- 说明：客户端侧使用缓存机制，每0.5秒更新一次结果以提高性能。
-- 参数：
--   pl — 要检查的玩家
-- 返回值：boolean — 是否可以购买
-- ============================================================================
function GM:PlayerCanPurchase(pl)
	-- 客户端使用缓存：如果缓存未过期，直接返回缓存结果
	if CLIENT and self.CanPurchaseCacheTime and self.CanPurchaseCacheTime >= CurTime() then
		return self.CanPurchaseCache
	end
	-- 人类玩家、游戏已开始、存活、且在武器箱附近
	local canpurchase = PTeam(pl) == TEAM_HUMAN and self:GetWave() > 0 and pl:Alive() and pl:NearArsenalCrate()

	if CLIENT then
		self.CanPurchaseCache = canpurchase
		self.CanPurchaseCacheTime = CurTime() + 0.5
	end
	return canpurchase
end

-- 随便放
-- ============================================================================
-- GM:ZombieCanPurchase
-- 功能：检查僵尸玩家是否可以打开购买菜单。
-- 条件：
--   1. 玩家是亡灵队伍（TEAM_UNDEAD）
--   2. 当前波次 > 0
--   3. 不是目标模式地图（ObjectiveMap）
-- 参数：
--   pl — 要检查的玩家
-- 返回值：boolean — 僵尸是否可以购买
-- ============================================================================
function GM:ZombieCanPurchase(pl)
	return pl:Team() == TEAM_UNDEAD and self:GetWave() > 0 and not self.ObjectiveMap
end

-- ============================================================================
-- GM:PlayerCanHearPlayersVoice
-- 功能：判断一个玩家是否能听到另一个玩家的语音聊天。
-- 默认逻辑：同队伍可以互相听到；观察者（Spectator）可以听到所有人。
-- 说明：这个函数实际上只在服务端被引擎调用，但放在这里以便客户端
--       也可以查询语音通信规则。
-- 参数：
--   listener — 听者
--   talker — 说话者
-- 返回值：
--   boolean — 是否可以听到
--   boolean — 是否与第三人称有关（始终返回 false）
-- ============================================================================
local TEAM_SPECTATOR = TEAM_SPECTATOR
function GM:PlayerCanHearPlayersVoice(listener, talker)
	return PTeam(listener) == PTeam(talker) or PTeam(listener) == TEAM_SPECTATOR, false
end
GM.PlayerCanHearPlayersVoiceDefault = GM.PlayerCanHearPlayersVoice

-- ============================================================================
-- GM:PlayerCanHearPlayersVoiceAllTalk
-- 功能：全局语音模式（sv_alltalk = 1）下的语音通信规则。
-- 所有玩家都可以互相听到。
-- 参数：
--   listener — 听者
--   talker — 说话者
-- 返回值：
--   boolean — 始终返回 true
--   boolean — 始终返回 false
-- ============================================================================
function GM:PlayerCanHearPlayersVoiceAllTalk(listener, talker)
	return true, false
end

-- ============================================================================
-- sv_alltalk 控制台变量变更回调
-- 当 sv_alltalk 值改变时，自动切换语音通信规则。
-- ============================================================================
cvars.AddChangeCallback("sv_alltalk", function(cvar, old, new)
	GAMEMODE.PlayerCanHearPlayersVoice = new ~= "1" and GAMEMODE.PlayerCanHearPlayersVoiceDefault or  GAMEMODE.PlayerCanHearPlayersVoiceAllTalk
end)

-- 初始化语音通信规则（根据当前 sv_alltalk 设置）
GM.PlayerCanHearPlayersVoice = GetConVar("sv_alltalk"):GetBool() and GM.PlayerCanHearPlayersVoiceAllTalk or  GM.PlayerCanHearPlayersVoiceDefault

-- ============================================================================
-- GM:PlayerTraceAttack
-- 功能：处理玩家受到射线攻击（子弹等）时的回调。
-- 目前此函数为空，即使用引擎的默认处理逻辑。
-- 参数：
--   pl — 受到攻击的玩家
--   dmginfo — 伤害信息对象
--   dir — 攻击方向
--   trace — 射线追踪结果
-- 返回值：无
-- ============================================================================
function GM:PlayerTraceAttack(pl, dmginfo, dir, trace)
end

-- ============================================================================
-- GM:GetDamageResistance
-- 功能：根据指定位置的恐惧值计算伤害抗性百分比。
-- 伤害抗性降低僵尸造成的伤害。
-- 逻辑：
--   1. 如果启用了符文系统（Sigils）：抗性 = 恐惧值 × 0.1 + 腐化符文比例 × 0.2
--   2. 如果未启用符文系统：抗性 = 恐惧值 × 0.15
-- 参数：
--   fearpower — 恐惧值（0~1之间）
-- 返回值：number — 伤害抗性（0~1之间）
-- ============================================================================
function GM:GetDamageResistance(fearpower)
	if self.MaxSigils > 0 and self:GetUseSigils() then
		return fearpower * 0.1 + self:NumSigilsCorrupted() / self.MaxSigils * 0.2
	end

	return fearpower * 0.15
end

-- ============================================================================
-- GM:FindUseEntity
-- 功能：查找玩家准星指向的可交互实体。
-- 逻辑：如果传入的实体无效，则使用玩家准星方向的射线检测找到目标实体。
--       主要用于"使用键（E键）"的交互逻辑。
-- 参数：
--   pl — 玩家
--   ent — 当前目标实体（可能无效）
-- 返回值：Entity — 找到的可交互实体
-- ============================================================================
function GM:FindUseEntity(pl, ent)
	-- 如果当前实体无效，使用玩家视角进行射线检测
	if not ent:IsValid() then
		local e = pl:TraceLine(90, MASK_SOLID, pl:GetDynamicTraceFilter()).Entity
		if e:IsValid() then return e end
	end

	return ent
end

-- ============================================================================
-- GM:ShouldUseAlternateDynamicSpawn
-- 功能：判断是否应使用备用的（旧版）动态出生点系统。
-- 在以下情况下使用旧版系统：
--   1. 僵尸逃生模式（ZombieEscape）
--   2. 经典模式（ClassicMode）
--   3. 裤子模式（PantsMode）
--   4. 婴儿模式（BabyMode）
-- 参数：无
-- 返回值：boolean — 是否使用旧版系统
-- ============================================================================
function GM:ShouldUseAlternateDynamicSpawn()
	return self.ZombieEscape or self:IsClassicMode() or self.PantsMode or self:IsBabyMode()
end

-- ============================================================================
-- GM:GetZombieDamageScale
-- 功能：根据指定位置的恐惧值计算僵尸的伤害缩放比例。
-- 公式：基础伤害倍率 × (1 - 伤害抗性)
-- 注意：如果仅剩最后一名人类（LASTHUMAN），则伤害抗性被忽略（施加全力伤害）。
-- 参数：
--   pos — 要计算的位置
--   ignore — 要忽略的玩家（可选）
-- 返回值：number — 伤害缩放倍率
-- ============================================================================
function GM:GetZombieDamageScale(pos, ignore)
	-- 最后一名人类时，僵尸造成全额伤害（不受恐惧值影响）
	if LASTHUMAN then return self.ZombieDamageMultiplier end

	return self.ZombieDamageMultiplier * (1 - self:GetDamageResistance(self:GetFearMeterPower(pos, TEAM_UNDEAD, ignore)))
end

-- ============================================================================
-- 辅助变量和函数：按距离排序出生点
-- ============================================================================

-- 临时位置变量（用于 SortByDistance 闭包）
local temppos

-- SortByDistance — 比较两个实体到 temppos 的距离
-- 用于按距离升序排序出生点列表
local function SortByDistance(a, b)
	return a:GetPos():DistToSqr(temppos) < b:GetPos():DistToSqr(temppos)
end

-- ============================================================================
-- GetSortedSpawnPoints (局部函数)
-- 功能：获取指定队伍的出生点列表，并按到目标位置的距离排序。
-- 参数：
--   teamid — 队伍ID 或 出生点表（supporting multiple input types）
--   pos — 目标位置
-- 返回值：table — 按距离排序后的出生点表
-- ============================================================================
local function GetSortedSpawnPoints(teamid, pos)
	temppos = pos
	local spawnpoints
	-- 如果 teamid 是表，则直接作为出生点列表使用
	if type(teamid) == "table" then
		spawnpoints = teamid
	else
		spawnpoints = team.GetValidSpawnPoint(teamid)
	end

	table.sort(spawnpoints, SortByDistance)
	return spawnpoints
end

-- ============================================================================
-- GM:GetClosestSpawnPoint
-- 功能：从指定队伍的出生点中，找到离目标位置最近的一个。
-- 参数：
--   teamid — 队伍ID 或 出生点表
--   pos — 目标位置
-- 返回值：Entity — 最近的出生点实体
-- ============================================================================
function GM:GetClosestSpawnPoint(teamid, pos)
	return GetSortedSpawnPoints(teamid, pos)[1]
end

-- ============================================================================
-- GM:GetFurthestSpawnPoint
-- 功能：从指定队伍的出生点中，找到离目标位置最远的一个。
-- 参数：
--   teamid — 队伍ID 或 出生点表
--   pos — 目标位置
-- 返回值：Entity — 最远的出生点实体
-- ============================================================================
function GM:GetFurthestSpawnPoint(teamid, pos)
	local spawnpoints = GetSortedSpawnPoints(teamid, pos)
	return spawnpoints[#spawnpoints]
end

-- ============================================================================
-- 恐惧值和集结点计算相关常量
-- ============================================================================

-- 恐惧感应范围（768单位）的平方值（用于距离平方比较）
local FEAR_RANGE = 768^2

-- 每个敌人实例贡献的恐惧值（7.5%）
local FEAR_PERINSTANCE = 0.075

-- 集结点判定阈值（达到30%的恐惧值才认定为集结点）
local RALLYPOINT_THRESHOLD = 0.3

-- ============================================================================
-- GetEpicenter (局部函数)
-- 功能：计算一组玩家的平均位置（队伍中心点）。
-- 参数：
--   tab — 玩家表
-- 返回值：Vector — 所有玩家位置的平均值（如果为空则返回原点）
-- ============================================================================
local function GetEpicenter(tab)
	local vec = Vector(0, 0, 0)
	if #tab == 0 then return vec end

	-- 将所有玩家位置累加
	for k, v in pairs(tab) do
		vec = vec + v:GetPos()
	end

	-- 返回平均值
	return vec / #tab
end

-- ============================================================================
-- GM:GetTeamRallyGroups
-- 功能：识别并分组聚集在一起的同队玩家。
-- 逻辑：
--   1. 遍历队伍中的所有存活玩家
--   2. 如果某个玩家未分组，则找出所有在其 FEAR_RANGE 范围内的同队玩家
--   3. 如果该组的总恐惧值达到阈值，则形成一个集结点组
-- 参数：
--   teamid — 队伍ID
-- 返回值：table — 集结点组列表，每组是一个玩家表
-- ============================================================================
function GM:GetTeamRallyGroups(teamid)
	local groups = {}
	local ingroup = {}

	local plys = team.GetPlayers(teamid)
	local plpos, group

	for _, pl in pairs(plys) do
		-- 如果该玩家尚未分组且还活着
		if not ingroup[pl] and pl:Alive() then
			plpos = pl:GetPos()
			group = {pl}

			-- 查找附近的其他存活队友
			for __, otherpl in pairs(plys) do
				if otherpl ~= pl and not ingroup[otherpl] and otherpl:Alive() and otherpl:GetPos():DistToSqr(plpos) <= FEAR_RANGE then
					group[#group + 1] = otherpl
				end
			end

			-- 如果组的总恐惧值达到阈值，则认定为一个集结点
			if #group * FEAR_PERINSTANCE >= RALLYPOINT_THRESHOLD then
				for k, v in pairs(group) do
					ingroup[v] = true
				end
				groups[#groups + 1] = group
			end
		end
	end

	return groups
end

-- ============================================================================
-- GM:GetTeamRallyPoints
-- 功能：计算指定队伍的所有集结点信息。
-- 每个集结点包含：中心位置 + 集结强度（0~1）
-- 强度计算公式：(组数量 × 每实例恐惧值 - 阈值) / (1 - 阈值)
-- 参数：
--   teamid — 队伍ID
-- 返回值：table — 集结点列表，每项为 {位置Vector, 强度number}
-- ============================================================================
function GM:GetTeamRallyPoints(teamid)
	local points = {}

	for _, group in pairs(self:GetTeamRallyGroups(teamid)) do
		-- 计算集结点强度和中心位置
		points[#points + 1] = {GetEpicenter(group), math.min(1, (#group * FEAR_PERINSTANCE - RALLYPOINT_THRESHOLD) / (1 - RALLYPOINT_THRESHOLD))}
	end

	return points
end

-- ============================================================================
-- 队伍中心点缓存系统
-- 避免每帧重复计算，缓存有效期0.5秒。
-- ============================================================================
local CachedEpicentreTimes = {}
local CachedEpicentres = {}

-- ============================================================================
-- GM:GetTeamEpicentre
-- 功能：计算指定队伍所有存活玩家的平均位置（队伍中心点）。
-- 逻辑：仅统计存活且拥有完整光环范围（AuraRange == 2048）的玩家。
--       结果会缓存0.5秒以提升性能。
-- 参数：
--   teamid — 队伍ID
--   nocache — 是否禁用缓存（可选，默认false）
-- 返回值：Vector — 队伍中心点位置
-- ============================================================================
function GM:GetTeamEpicentre(teamid, nocache)
	-- 如果有缓存且未过期，直接返回缓存值
	if not nocache and CachedEpicentres[teamid] and CurTime() < CachedEpicentreTimes[teamid] then
		return CachedEpicentres[teamid]
	end

	local plys = team.GetPlayers(teamid)
	local vVec = Vector(0, 0, 0)
	local considered = 0
	for _, pl in pairs(plys) do
		-- 仅统计存活且具有完整光环范围的玩家
		if pl:Alive() and pl:GetAuraRange() == 2048 then
			vVec = vVec + pl:GetPos()
			considered = considered + 1
		end
	end

	-- 计算平均值
	local epicentre = vVec / considered
	-- 写入缓存（除非要求不缓存）
	if not nocache then
		CachedEpicentreTimes[teamid] = CurTime() + 0.5
		CachedEpicentres[teamid] = epicentre
	end

	return epicentre
end
-- 别名：GetTeamEpicenter（美式拼写）与 GetTeamEpicentre（英式拼写）
GM.GetTeamEpicenter = GM.GetTeamEpicentre

-- ============================================================================
-- GM:GetCurrentEquipmentCount
-- 功能：统计当前地图上某种特定装备的数量。
-- 逻辑：从库存定义中获取该装备的可计数实体类名（Countables）和 SWEP 类名，
--       然后分别统计对应实体总数。
-- 参数：
--   id — 物品在 GM.Items 表中的索引
-- 返回值：number — 地图上该物品的数量
-- ============================================================================
function GM:GetCurrentEquipmentCount(id)
	local count = 0

	local item = self.Items[id]
	if item then
		-- 统计可计数实体
		if item.Countables then
			if type(item.Countables) == "table" then
				-- 如果是表，遍历每个类名进行统计
				for k, v in pairs(item.Countables) do
					count = count + #ents.FindByClass(v)
				end
			else
				-- 如果是字符串，直接按类名统计
				count = count + #ents.FindByClass(item.Countables)
			end
		end

		-- 统计 SWEP 武器的实体数量
		if item.SWEP then
			count = count + #ents.FindByClass(item.SWEP)
		end
	end

	return count
end

-- ============================================================================
-- GM:GetFearMeterPower
-- 功能：计算指定位置的"恐惧值"（0~1），即周围敌人带来的压迫感。
-- 逻辑：
--   1. 遍历所有玩家
--   2. 排除自身（ignore 参数）和指定队伍之外的玩家
--   3. 排除不会产生恐惧的僵尸（DoesntGiveFear）
--   4. 距离越近、该僵尸职业的 FearPerInstance 值越高，产生的恐惧越大
-- 参数：
--   pos — 要计算的位置
--   teamid — 要计算哪个队伍的恐惧影响
--   ignore — 要忽略的玩家（可选）
-- 返回值：number — 恐惧值（0~1）
-- ============================================================================
function GM:GetFearMeterPower(pos, teamid, ignore)
	-- 最后一名人类时，恐惧值直接拉满（施加全力压迫感）
	if LASTHUMAN then return 1 end

	local dist

	local power = 0

	for _, pl in pairs(player.GetAll()) do
		-- 排除被忽略的玩家、排除非目标队伍玩家、排除不产生恐惧的僵尸
		if pl ~= ignore and PTeam(pl) == teamid and not pl:CallZombieFunction0("DoesntGiveFear") and pl:Alive() then
			dist = pl:GetPos():DistToSqr(pos)
			if dist <= FEAR_RANGE then
				-- 恐惧贡献 = (1 - 距离/最大距离) × 该僵尸职业的恐惧系数
				power = power + (1 - dist / FEAR_RANGE) * (pl:GetZombieClassTable().FearPerInstance or FEAR_PERINSTANCE)
			end
		end
	end

	return math.min(1, power)
end

-- ============================================================================
-- GM:GetRagdollEyes
-- 功能：获取玩家死亡后布娃娃模型的眼睛位置和朝向。
-- 用于"看到自己死亡视角"等效果（如转移僵尸视角到尸体眼睛位置）。
-- 参数：
--   pl — 玩家
-- 返回值：
--   Vector — 眼睛位置（如果存在布娃娃且有"eyes"附着点）
--   Angle — 眼睛朝向
--   如无布娃娃则返回 nil
-- ============================================================================
function GM:GetRagdollEyes(pl)
	local Ragdoll = pl:GetRagdollEntity()
	if not Ragdoll then return end

	-- 查找布娃娃上的"eyes"附着点
	local att = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))
	if att then
		att.Pos = att.Pos + att.Ang:Forward() * -2
		att.Ang = att.Ang

		return att.Pos, att.Ang
	end
end

-- ============================================================================
-- GM:PlayerNoClip
-- 功能：处理玩家尝试开启/关闭穿墙模式（noclip）的请求。
-- 只有管理员可以开启穿墙模式，开启时会在服务器控制台记录日志。
-- 参数：
--   pl — 玩家
--   on — 是否开启（true=开启，false=关闭）
-- 返回值：boolean — 是否允许操作
-- ============================================================================
function GM:PlayerNoClip(pl, on)
	if pl:IsAdmin() then
		if SERVER then
			-- 在控制台输出通知
			PrintMessage(HUD_PRINTCONSOLE, translate.Format(on and "x_turned_on_noclip" or "x_turned_off_noclip", pl:Name()))
		end

		if SERVER then
			-- 标记为"不良档案"（反作弊或追踪目的）
			pl:MarkAsBadProfile()
		end

		return true
	end

	return false
end

-- ============================================================================
-- GM:IsSpecialPerson
-- 功能：检查玩家是否为特殊身份（开发者、管理员、赞助者等），
--       并返回对应的头像图标和提示文字。
-- 身份层级：
--   1. JetBoom（原版作者）— Source SDK 图标
--   2. 管理员 — 盾牌图标
--   3. No Supporters — NoxiousNet 图标
--   4. 优秀玩家（Good user）— 绿色包裹图标
-- 注：以下身份被注释掉了（原 fork 移除或未使用）：
--   - 建筑师（builder）
--   - 赞助者（sponsor）
--   - 超级管理员（superadmin）
--   - 特定的"良缘管理员"SteamID
-- 参数：
--   pl — 玩家
--   image — 用于显示图标的 DImage 控件（仅客户端使用）
-- 返回值：boolean — 是否为特殊身份
-- ============================================================================
function GM:IsSpecialPerson(pl, image)
	local img, tooltip

	-- 检查是否为作者 JetBoom
	if pl:SteamID() == "STEAM_0:1:3307510" then
		img = "VGUI/steam/games/icon_sourcesdk"
		tooltip = "JetBoom\nCreator of Zombie Survival!"
	--elseif pl:IsAdmin() then
		--img = "VGUI/servers/icon_robotron"
		--tooltip = "管理员"
	elseif pl:IsAdmin() then
		img = "icon16/shield.png"
		tooltip = "管理员"
	elseif pl:IsNoxSupporter() then
		img = "noxiousnet/noxicon.png"
		tooltip = "No supporter"
	elseif pl:IsUserGroup("Good user") then
	    img = "icon16/package_green.png"
	    tooltip = "优秀的玩家"
	end
	--[[
	elseif pl:Isbuilder() then
	    img = "icon16/wrench_orange.png"
	    tooltip = "建筑师"
	elseif pl:Issponsor() then
	    img = "icon16/ruby.png"
	    tooltip = "赞助玩家，感谢此玩家为服务器提供了赞助"
	elseif pl:Issuperadmin() then
	    img = "icon16/shield.png"
	    tooltip = "超级管理员"
	elseif pl:SteamID() == "STEAM_0:0:158504149" then
	    img = "icon16/award_star_add.png"
	    tooltip = "良缘管理员"
	end
    --]]
	if img then
		if CLIENT then
			-- 客户端：设置图标图像和提示文本
			image:SetImage(img)
			image:SetTooltip(tooltip)
		end

		return true
	end

	return false
end

-- ============================================================================
-- 波次时间管理函数组
-- 这些函数通过全局变量在网络中同步波次起止时间和当前波次数。
-- ============================================================================

-- ============================================================================
-- GM:GetWaveEnd
-- 功能：获取当前波次结束的时间点。
-- 返回值：number — 结束时间的全局时间戳（CurTime），默认为0
-- ============================================================================
function GM:GetWaveEnd()
	return GetGlobalFloat("waveend", 0)
end

-- ============================================================================
-- GM:SetWaveEnd
-- 功能：设置当前波次结束的时间点。
-- 参数：
--   time — 结束时间（CurTime）
-- 返回值：无
-- ============================================================================
function GM:SetWaveEnd(time)
	SetGlobalFloat("waveend", time)
end

-- ============================================================================
-- GM:GetWaveStart
-- 功能：获取当前波次开始的时间点。
-- 如果尚未设置，则默认为第0波的持续时间（WaveZeroLength）。
-- 返回值：number — 开始时间的全局时间戳
-- ============================================================================
function GM:GetWaveStart()
	return GetGlobalFloat("wavestart", self.WaveZeroLength)
end

-- ============================================================================
-- GM:SetWaveStart
-- 功能：设置当前波次开始的时间点。
-- 参数：
--   time — 开始时间（CurTime）
-- 返回值：无
-- ============================================================================
function GM:SetWaveStart(time)
	SetGlobalFloat("wavestart", time)
end

-- ============================================================================
-- GM:GetWave
-- 功能：获取当前是第几波（从0开始计数，0表示准备阶段）。
-- 返回值：number — 波次数（全局整数），默认为0
-- ============================================================================
function GM:GetWave()
	return GetGlobalInt("wave", 0)
end

-- ============================================================================
-- 波次初始化（仅在文件首次加载时执行一次）
-- 如果当前波次为0（初始状态），设置第0波的开始和结束时间。
-- 第0波是准备阶段，持续到 WaveZeroLength + 第一波长度。
-- ============================================================================
if GM:GetWave() == 0 then
	GM:SetWaveStart(GM.WaveZeroLength)
	GM:SetWaveEnd(GM.WaveZeroLength + GM:GetWaveOneLength())
end

-- ============================================================================
-- GM:GetWaveActive
-- 功能：检查当前是否处于僵尸进攻的活跃波次。
-- 返回值：boolean — 波次是否活跃
-- ============================================================================
function GM:GetWaveActive()
	return GetGlobalBool("waveactive", false)
end

-- ============================================================================
-- GM:SetWaveActive
-- 功能：设置波次的活跃状态。
-- 逻辑：如果回合已结束或新状态与当前状态相同，则不执行任何操作。
--       状态改变时，在服务端触发 WaveStateChanged 回调。
-- 参数：
--   active — true=激活波次，false=停用波次
-- 返回值：无
-- ============================================================================
function GM:SetWaveActive(active)
	-- 回合结束后不允许更改波次状态
	if self.RoundEnded then return end

	if self:GetWaveActive() ~= active then
		SetGlobalBool("waveactive", active)

		if SERVER then
			-- 通知服务端其他模块波次状态已改变
			gamemode.Call("WaveStateChanged", active)
		end
	end
end

-- ============================================================================
-- 全局 SoundDuration 函数覆盖（仅执行一次）
-- 修复引擎对 .ogg 和 .mp3 格式声音文件的时长计算错误。
-- Garry's Mod 引擎估算的时长与实际播放时长不一致，此处通过乘数修正。
-- .mp3 时长修正系数：2.25
-- .ogg 时长修正系数：3.0
-- 其他格式：使用引擎原始计算结果
-- ============================================================================
if not FixedSoundDuration then
FixedSoundDuration = true
local OldSoundDuration = SoundDuration
function SoundDuration(snd)
	if snd then
		local ft = string.sub(snd, -4)
		-- .mp3 文件：引擎估算值乘以2.25
		if ft == ".mp3" then
			return OldSoundDuration(snd) * 2.25
		end
		-- .ogg 文件：引擎估算值乘以3.0
		if ft == ".ogg" then
			return OldSoundDuration(snd) * 3
		end
	end

	-- 其他格式直接返回引擎计算结果
	return OldSoundDuration(snd)
end
end

-- ============================================================================
-- GM:VehicleMove
-- 功能：载具移动处理回调（当前为空）。
-- 此函数在载具移动时被调用，但当前不执行任何自定义逻辑。
-- 保留此函数以备将来扩展载具相关功能。
-- 参数：无
-- 返回值：无
-- ============================================================================
function GM:VehicleMove()
end
