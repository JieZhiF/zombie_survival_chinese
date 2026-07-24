-- 武器设置列表：人类玩家选择"随机"初始装备时可能获得的武器组合
-- 本文件主要负责定义服务器端的各种游戏性选项、参数以及回合结束后的荣誉提名（奖励）逻辑。

-- GM.StartLoadouts 定义了人类玩家选择"随机"时可能获得的初始武器配置组合。
-- zs_bosszombies 设置是否在每波进攻的间歇期间生成一个Boss僵尸。
-- zs_outnumberedhealthbonus 当僵尸数量少于或等于设定值时，为僵尸提供额外的最大生命值加成。
-- zs_pantsmode 一个特殊的趣味游戏模式。
-- zs_classicmode 启用经典模式，该模式下没有钉子和职业选择。
-- zs_babymode 启用婴儿（简单）模式。
-- zs_lowplayermode 在玩家人数较少时启用，以优化游戏体验。
-- zs_endwavehealthbonus 人类在每波成功防守后获得的生命值奖励。
-- zs_giblifetime 设置玩家死亡后身体碎块在被吃掉或销毁前存留的时间。
-- zs_grief_forgiveness 调整对友方建筑造成伤害的惩罚宽容度，数值越小越宽容。
-- zs_grief_strict 启用反恶意破坏系统，惩罚破坏友方障碍物的玩家。
-- zs_grief_minimumhealth 一个物件被反恶意破坏系统监视的最低生命值。
-- zs_grief_damagemultiplier 人类对友方可破坏物件造成的伤害乘数。
-- zs_grief_reflectthreshold 当玩家的恶意破坏分数低于此阈值时，开始对其自身造成伤害。
-- zs_maxpropsinbarricade 限制一个由钉子固定的障碍物结构中可以包含的最大物件数量。
-- zs_maxdroppeditems 限制地图上存在的最大掉落物品数量，以防止服务器卡顿。
-- zs_nailhealthperrepair 每次修理钉子时为其恢复的生命值数量。
-- zs_nopropdamagefromhumanmelee 设置人类的近战攻击是否对物件造成伤害。
-- zs_medkitpointsperhealth 通过治疗队友获得点数的效率。
-- zs_repairpointsperhealth 通过修理建筑获得点数的效率。
-- GetMostKey 一个辅助函数，用于查找在某个特定统计数据上值最高的玩家。
-- GetMostFunc 一个辅助函数，通过调用一个函数来计算并查找值最高的玩家。
-- GM.HonorableMentions 定义了各种回合结束荣誉称号的评定逻辑，例如：
-- HM_MOSTZOMBIESKILLED 击杀僵尸最多
-- HM_MOSTBRAINSEATEN 吃掉大脑最多
-- HM_MOSTHEADSHOTS 爆头最多
-- HM_SCARECROW 击杀乌鸦最多
-- HM_DEFENCEDMG 造成防御伤害最多
-- HM_STRENGTHDMG 在力量增强状态下造成伤害最多
-- HM_BARRICADEDESTROYER 对障碍物造成伤害最多
-- HM_HANDYMAN 修理量最多
-- HM_LASTHUMAN 最后一名幸存的人类
-- HM_MOSTHELPFUL 助攻最多
-- HM_GOODDOCTOR 治疗量最多
-- HM_MOSTDAMAGETOUNDEAD 对僵尸阵营造成总伤害最多
-- HM_MOSTDAMAGETOHUMANS 对人类阵营造成总伤害最多
-- HM_LASTBITE 造成最后一次感染的僵尸
-- HM_USEFULTOOPPOSITE 死亡次数最多（对敌方最"有用"）
-- HM_PACIFIST 作为人类获胜但未击杀任何僵尸
-- HM_STUPID 死亡地点离僵尸出生点最近
-- HM_OUTLANDER 死亡地点离僵尸出生点最远
-- HM_SALESMAN 通过队友购买物品获得的佣金最多
-- HM_WAREHOUSE 放置的补给箱被队友使用次数最多
-- HM_NESTDESTROYER 摧毁僵尸巢穴最多
-- HM_NESTMASTER 通过放置的巢穴生成的僵尸最多

-- 定义随机初始装备的武器配置组合表
GM.StartLoadouts = {
	{"pshtr", "3pcp", "2pcp", "2sgcp", "3sgcp"},
	{"btlax", "3pcp", "2pcp", "2arcp", "3arcp"},
	{"stbbr", "3rcp", "2rcp", "2pcp", "3pcp"},
	{"tossr", "3smgcp", "2smgcp", "zpplnk", "stone"},
	{"blstr", "3sgcp", "2sgcp", "csknf"},
	{"owens", "3pcp", "2pcp", "2pls", "3pls"},
	{"curativei", "medkit", "90mkit", "60mkit"},
	{"minelayer", "4mines", "6mines"},
	{"crklr", "3arcp", "2arcp", "xbow1", "xbow2"},
	{"junkpack", "12nails", "crphmr", "loadingframe"},
	{"z9000", "3pls", "2pls", "stnbtn"},
	{"sling", "xbow1", "xbow2", "2sgcp", "3sgcp"}
}


-- zs_bosszombies：是否在每波休息期间生成一个BOSS僵尸（默认启用）
GM.BossZombies = CreateConVar("zs_bosszombies", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "是否在每波休息期间生成一个BOSS僵尸"):GetBool()
-- 监听 zs_bosszombies 变量变化，实时更新游戏模式设置
cvars.AddChangeCallback("zs_bosszombies", function(cvar, oldvalue, newvalue)
	GAMEMODE.BossZombies = tonumber(newvalue) == 1
end)

-- zs_outnumberedhealthbonus：当僵尸数量少时给予额外血量加成（默认4，设为0禁用）
GM.OutnumberedHealthBonus = CreateConVar("zs_outnumberedhealthbonus", "4", FCVAR_ARCHIVE + FCVAR_NOTIFY, "如果僵尸数量少于或等于此数值，给予僵尸额外的最大生命值。设为0禁用"):GetInt()
-- 监听人数劣势血量加成变量变化
cvars.AddChangeCallback("zs_outnumberedhealthbonus", function(cvar, oldvalue, newvalue)
	GAMEMODE.OutnumberedHealthBonus = tonumber(newvalue) or 0
end)

-- zs_pantsmode：趣味裤子模式（默认关闭）
GM.PantsMode = CreateConVar("zs_pantsmode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "裤子模式：只有死者才能从这种邪恶中得到安息"):GetBool()
-- 监听裤子模式变量变化
cvars.AddChangeCallback("zs_pantsmode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetPantsMode(tonumber(newvalue) == 1)
end)

-- zs_classicmode：经典模式，无钉子无职业（默认关闭）
GM.ClassicMode = CreateConVar("zs_classicmode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "经典模式：无钉子，无职业选择，只有终极目的地"):GetBool()
-- 监听经典模式变量变化
cvars.AddChangeCallback("zs_classicmode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetClassicMode(tonumber(newvalue) == 1)
end)

-- zs_babymode：宝宝简单模式（默认关闭）
GM.BabyMode = CreateConVar("zs_babymode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "宝宝模式"):GetBool()
-- 监听宝宝模式变量变化
cvars.AddChangeCallback("zs_babymode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetBabyMode(tonumber(newvalue) == 1)
end)

-- zs_lowplayermode：低人数模式，优化游戏体验（默认启用）
GM.LowPlayerMode = CreateConVar("zs_lowplayermode", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "人数低的时候启用，达到最好的游玩效果"):GetBool()
-- 监听低人数模式变量变化
cvars.AddChangeCallback("zs_lowplayermode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetLowPlayerMode(tonumber(newvalue) == 1)
end)

-- zs_endwavehealthbonus：每波结束后人类获得的生命值奖励（默认0，设为0禁用）
GM.EndWaveHealthBonus = CreateConVar("zs_endwavehealthbonus", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "每波结束后人类将获得此数值的生命值。设为0禁用"):GetInt()
-- 监听波末血量奖励变量变化
cvars.AddChangeCallback("zs_endwavehealthbonus", function(cvar, oldvalue, newvalue)
	GAMEMODE.EndWaveHealthBonus = tonumber(newvalue) or 0
end)

-- zs_giblifetime：玩家碎尸留在世界中的秒数（默认25秒）
GM.GibLifeTime = CreateConVar("zs_giblifetime", "25", FCVAR_ARCHIVE, "指定玩家碎尸(Gibs)在未被食用或破坏的情况下在世界中停留的秒数"):GetFloat()
-- 监听碎尸存留时间变量变化
cvars.AddChangeCallback("zs_giblifetime", function(cvar, oldvalue, newvalue)
	GAMEMODE.GibLifeTime = tonumber(newvalue) or 1
end)

-- zs_grief_forgiveness：恶意破坏惩罚宽容度（默认0.5，数值越小越宽容）
GM.GriefForgiveness = math.ceil(100 * CreateConVar("zs_grief_forgiveness", "0.5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "按此比例缩放对可破坏物体造成的伤害判定。这并不防止伤害，只决定给予玩家多少惩罚。数值越小越宽容，数值越大越严厉"):GetFloat()) * 0.01
-- 监听恶意破坏宽容度变量变化
cvars.AddChangeCallback("zs_grief_forgiveness", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefForgiveness = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

-- zs_grief_strict：反恶意破坏系统开关（默认启用）
GM.GriefStrict = CreateConVar("zs_grief_strict", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "防恶意破坏系统。给予破坏己方路障的人类扣分，最终给予生命值惩罚"):GetBool()
-- 监听恶意破坏严格模式变量变化
cvars.AddChangeCallback("zs_grief_strict", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefStrict = tonumber(newvalue) == 1
end)

-- zs_grief_minimumhealth：反恶意破坏系统关注的最小生命值阈值（默认100）
GM.GriefMinimumHealth = CreateConVar("zs_grief_minimumhealth", "100", FCVAR_ARCHIVE + FCVAR_NOTIFY, "物体被视为可被恶意破坏的最小生命值阈值"):GetInt()
-- 监听恶意破坏最小血量变量变化
cvars.AddChangeCallback("zs_grief_minimumhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefMinimumHealth = tonumber(newvalue) or 100
end)

-- zs_grief_damagemultiplier：人类对可破坏物的伤害倍率（默认0.5）
GM.GriefDamageMultiplier = math.ceil(100 * CreateConVar("zs_grief_damagemultiplier", "0.5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "将人类对可破坏物体造成的伤害乘以该数值"):GetFloat()) * 0.01
-- 监听恶意破坏伤害倍率变量变化
cvars.AddChangeCallback("zs_grief_damagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 0.5)) * 0.01
end)

-- zs_grief_reflectthreshold：恶意破坏分数低于此值时开始反弹伤害（默认-5）
GM.GriefReflectThreshold = CreateConVar("zs_grief_reflectthreshold", "-5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "如果玩家分数低于此数值，则开始反弹伤害"):GetInt()
-- 监听恶意破坏反弹阈值变量变化
cvars.AddChangeCallback("zs_grief_reflectthreshold", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefReflectThreshold = tonumber(newvalue) or -5
end)

-- zs_maxpropsinbarricade：钉连装置中最大道具数量（默认2）
GM.MaxPropsInBarricade = CreateConVar("zs_maxpropsinbarricade", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY, "限制一个'钉连装置'中可以包含的道具数量"):GetInt()
-- 监听障碍物最大道具数量变量变化
cvars.AddChangeCallback("zs_maxpropsinbarricade", function(cvar, oldvalue, newvalue)
	GAMEMODE.MaxPropsInBarricade = tonumber(newvalue) or 8
end)

-- zs_maxdroppeditems：最大掉落物品数量（目前已注释并硬编码为48）
GM.MaxDroppedItems = 48--[[CreateConVar("zs_maxdroppeditems", "48", FCVAR_ARCHIVE + FCVAR_NOTIFY, "掉落物品的最大数量。防止大量玩家死亡时出现刷屏或滞后"):GetInt()
cvars.AddChangeCallback("zs_maxdroppeditems", function(cvar, oldvalue, newvalue)
	GAMEMODE.MaxDroppedItems = tonumber(newvalue) or 48
end)]]

-- zs_nailhealthperrepair：每次修复钉子恢复的生命值（默认10）
GM.NailHealthPerRepair = CreateConVar("zs_nailhealthperrepair", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY, "钉子被修复时获得的生命值"):GetInt()
-- 监听每次修复钉子恢复血量变量变化
cvars.AddChangeCallback("zs_nailhealthperrepair", function(cvar, oldvalue, newvalue)
	GAMEMODE.NailHealthPerRepair = tonumber(newvalue) or 1
end)

-- zs_nopropdamagefromhumanmelee：人类近战不对道具造成伤害（默认启用）
GM.NoPropDamageFromHumanMelee = CreateConVar("zs_nopropdamagefromhumanmelee", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "人类近战攻击不会对道具造成伤害"):GetBool()
-- 监听人类近战不伤道具变量变化
cvars.AddChangeCallback("zs_nopropdamagefromhumanmelee", function(cvar, oldvalue, newvalue)
	GAMEMODE.NoPropDamageFromHumanMelee = tonumber(newvalue) == 1
end)

-- zs_medkitpointsperhealth：每点治疗量对应的得分系数（目前已注释并硬编码为3）
GM.MedkitPointsPerHealth = 3--[[CreateConVar("zs_medkitpointsperhealth", "8", FCVAR_ARCHIVE + FCVAR_NOTIFY, "指定玩家获得1点积分所需的治疗量。用于医疗包等"):GetInt()
cvars.AddChangeCallback("zs_medkitpointsperhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.MedkitPointsPerHealth = tonumber(newvalue) or 1
end)]]

-- zs_repairpointsperhealth：每点修复量对应的得分系数（默认25）
GM.RepairPointsPerHealth = CreateConVar("zs_repairpointsperhealth", "25", FCVAR_ARCHIVE + FCVAR_NOTIFY, "指定玩家获得1点积分所需的修复量。用于钉子等"):GetInt()
-- 监听修复得分系数变量变化
cvars.AddChangeCallback("zs_repairpointsperhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.RepairPointsPerHealth = tonumber(newvalue) or 1
end)

-- 辅助函数：遍历所有玩家，查找某个键值最大的玩家（如击杀数）
local function GetMostKey(key, top)
	top = top or 0
	local toppl
	for _, pl in pairs(player.GetAll()) do
		if pl[key] and pl[key] > top then
			top = pl[key]
			toppl = pl
		end
	end

	if toppl and top > 0 then
		return toppl, top
	end
end

-- 辅助函数：遍历所有玩家，通过调用玩家上的函数来查找数值最大的玩家（如死亡次数）
local function GetMostFunc(func, top)
	top = top or 0
	local toppl
	for _, pl in pairs(player.GetAll()) do
		local amount = pl[func](pl)
		if amount > top then
			top = amount
			toppl = pl
		end
	end

	if toppl and top > 0 then
		return toppl, top
	end
end

-- 荣誉：击杀僵尸最多的玩家
GM.HonorableMentions[HM_MOSTZOMBIESKILLED].GetPlayer = function(self)
	return GetMostKey("ZombiesKilled")
end

-- 荣誉：吃掉大脑最多的玩家
GM.HonorableMentions[HM_MOSTBRAINSEATEN].GetPlayer = function(self)
	return GetMostKey("BrainsEaten")
end

-- 荣誉：爆头最多的玩家
GM.HonorableMentions[HM_MOSTHEADSHOTS].GetPlayer = function(self)
	return GetMostKey("Headshots")
end

-- 荣誉：击杀乌鸦最多的玩家
GM.HonorableMentions[HM_SCARECROW].GetPlayer = function(self)
	return GetMostKey("CrowKills")
end

-- 荣誉：造成防御伤害最多的玩家
GM.HonorableMentions[HM_DEFENCEDMG].GetPlayer = function(self)
	return GetMostKey("DefenceDamage")
end

-- 荣誉：在力量增强状态下造成伤害最多的玩家
GM.HonorableMentions[HM_STRENGTHDMG].GetPlayer = function(self)
	return GetMostKey("StrengthBoostDamage")
end

-- 荣誉：对障碍物造成伤害最多的玩家
GM.HonorableMentions[HM_BARRICADEDESTROYER].GetPlayer = function(self)
	return GetMostKey("BarricadeDamage")
end

-- 荣誉：修理最多的玩家（修理量向上取整）
GM.HonorableMentions[HM_HANDYMAN].GetPlayer = function(self)
	local pl, amount = GetMostKey("RepairedThisRound")
	if pl and amount then
		return pl, math.ceil(amount)
	end
end

-- 荣誉：最后一名幸存的人类
GM.HonorableMentions[HM_LASTHUMAN].GetPlayer = function(self)
	if self.TheLastHuman and self.TheLastHuman:IsValid() then return self.TheLastHuman end
end

-- 荣誉：助攻最多的玩家
GM.HonorableMentions[HM_MOSTHELPFUL].GetPlayer = function(self)
	return GetMostKey("ZombiesKilledAssists")
end

-- 荣誉：治疗量最多的玩家
GM.HonorableMentions[HM_GOODDOCTOR].GetPlayer = function(self)
	return GetMostKey("HealedThisRound")
end

-- 荣誉：对亡灵（僵尸）阵营造成总伤害最多的玩家
GM.HonorableMentions[HM_MOSTDAMAGETOUNDEAD].GetPlayer = function(self)
	local top = 0
	local toppl
	for _, pl in pairs(player.GetAll()) do
		if pl.DamageDealt and pl.DamageDealt[TEAM_HUMAN] > top then
			top = pl.DamageDealt[TEAM_HUMAN]
			toppl = pl
		end
	end

	if toppl and top >= 1 then
		return toppl, math.ceil(top)
	end
end

-- 荣誉：对人类阵营造成总伤害最多的玩家
GM.HonorableMentions[HM_MOSTDAMAGETOHUMANS].GetPlayer = function(self)
	local top = 0
	local toppl
	for _, pl in pairs(player.GetAll()) do
		if pl.DamageDealt and pl.DamageDealt[TEAM_UNDEAD] > top then
			top = pl.DamageDealt[TEAM_UNDEAD]
			toppl = pl
		end
	end

	if toppl and top >= 1 then
		return toppl, math.ceil(top)
	end
end

-- 荣誉：造成最后一次感染的僵尸
GM.HonorableMentions[HM_LASTBITE].GetPlayer = function(self)
	if LAST_BITE and LAST_BITE:IsValid() then
		return LAST_BITE
	end
end

-- 荣誉：死亡次数最多的玩家（需达到30次以上）
GM.HonorableMentions[HM_USEFULTOOPPOSITE].GetPlayer = function(self)
	local pl, mag = GetMostFunc("Deaths")
	if mag and mag >= 30 then
		return pl, mag
	end
end

-- 荣誉：和平主义者（人类获胜且未击杀任何僵尸）
GM.HonorableMentions[HM_PACIFIST].GetPlayer = function(self)
	if WINNER == TEAM_HUMAN then
		for _, pl in pairs(player.GetAll()) do
			if pl.ZombiesKilled == 0 and pl:Team() == TEAM_HUMAN then return pl end
		end
	end
end

-- 荣誉：最愚蠢的玩家（死亡地点离僵尸出生点最近，需在1000单位内）
GM.HonorableMentions[HM_STUPID].GetPlayer = function(self)
	local dist = 99999
	local finalpl
	for _, pl in pairs(player.GetAll()) do
		if pl.ZombieSpawnDeathDistance and pl.ZombieSpawnDeathDistance < dist then
			finalpl = pl
			dist = pl.ZombieSpawnDeathDistance
		end
	end

	if finalpl and dist <= 1000 then
		return finalpl, math.ceil(dist / 12)
	end
end

-- 荣誉：外地人（死亡地点离僵尸出生点最远，需超过8000单位）
GM.HonorableMentions[HM_OUTLANDER].GetPlayer = function(self)
	local dist = 0
	local finalpl
	for _, pl in pairs(player.GetAll()) do
		if pl.ZombieSpawnDeathDistance and dist < pl.ZombieSpawnDeathDistance then
			finalpl = pl
			dist = pl.ZombieSpawnDeathDistance
		end
	end

	if finalpl and 8000 <= dist then
		return finalpl, math.ceil(dist / 12)
	end
end

-- 荣誉：销售员（通过队友购买获得佣金最多的玩家）
GM.HonorableMentions[HM_SALESMAN].GetPlayer = function(self)
	return GetMostKey("PointsCommission")
end

-- 荣誉：仓库管理员（补给箱被队友使用次数最多的玩家）
GM.HonorableMentions[HM_WAREHOUSE].GetPlayer = function(self)
	return GetMostKey("ResupplyBoxUsedByOthers")
end

-- 荣誉：巢穴毁灭者（摧毁僵尸巢穴最多的玩家）
GM.HonorableMentions[HM_NESTDESTROYER].GetPlayer = function(self)
	return GetMostKey("NestsDestroyed")
end

-- 荣誉：巢穴之主（通过放置的巢穴生成僵尸最多的玩家）
GM.HonorableMentions[HM_NESTMASTER].GetPlayer = function(self)
	return GetMostKey("NestSpawns")
end
