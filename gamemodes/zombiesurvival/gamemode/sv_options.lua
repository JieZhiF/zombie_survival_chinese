-- Weapon sets that humans can start with if they choose RANDOM.
-- 本文件主要负责定义服务器端的各种游戏性选项、参数以及回合结束后的荣誉提名（奖励）逻辑。

-- GM.StartLoadouts 定义了人类玩家选择“随机”时可能获得的初始武器配置组合。
-- zs_bosszombies 设置是否在每波进攻的间歇期间生成一个Boss僵尸。
-- zs_outnumberedhealthbonus 当僵尸数量少于或等于设定值时，为僵尸提供额外的最大生命值加成。
-- zs_pantsmode 一个特殊的趣味游戏模式。
-- zs_classicmode 启用经典模式，该模式下没有钉子和职业选择。
-- zs_babymode 启用婴儿（简单）模式。
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
-- HM_USEFULTOOPPOSITE 死亡次数最多（对敌方最“有用”）
-- HM_PACIFIST 作为人类获胜但未击杀任何僵尸
-- HM_STUPID 死亡地点离僵尸出生点最近
-- HM_OUTLANDER 死亡地点离僵尸出生点最远
-- HM_SALESMAN 通过队友购买物品获得的佣金最多
-- HM_WAREHOUSE 放置的补给箱被队友使用次数最多
-- HM_NESTDESTROYER 摧毁僵尸巢穴最多
-- HM_NESTMASTER 通过放置的巢穴生成的僵尸最多
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


GM.BossZombies = CreateConVar("zs_bosszombies", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Summon a boss zombie in the middle of each wave break."):GetBool()
cvars.AddChangeCallback("zs_bosszombies", function(cvar, oldvalue, newvalue)
	GAMEMODE.BossZombies = tonumber(newvalue) == 1
end)

GM.OutnumberedHealthBonus = CreateConVar("zs_outnumberedhealthbonus", "4", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Give zombies some extra maximum health if there are less than or equal to this many zombies. 0 to disable."):GetInt()
cvars.AddChangeCallback("zs_outnumberedhealthbonus", function(cvar, oldvalue, newvalue)
	GAMEMODE.OutnumberedHealthBonus = tonumber(newvalue) or 0
end)

GM.PantsMode = CreateConVar("zs_pantsmode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Only the dead can know peace from this evil."):GetBool()
cvars.AddChangeCallback("zs_pantsmode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetPantsMode(tonumber(newvalue) == 1)
end)

GM.ClassicMode = CreateConVar("zs_classicmode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "No nails, no class selection, final destination."):GetBool()
cvars.AddChangeCallback("zs_classicmode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetClassicMode(tonumber(newvalue) == 1)
end)

GM.BabyMode = CreateConVar("zs_babymode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Babby mode."):GetBool()
cvars.AddChangeCallback("zs_babymode", function(cvar, oldvalue, newvalue)
	GAMEMODE:SetBabyMode(tonumber(newvalue) == 1)
end)

GM.EndWaveHealthBonus = CreateConVar("zs_endwavehealthbonus", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Humans will get this much health after every wave. 0 to disable."):GetInt()
cvars.AddChangeCallback("zs_endwavehealthbonus", function(cvar, oldvalue, newvalue)
	GAMEMODE.EndWaveHealthBonus = tonumber(newvalue) or 0
end)

GM.GibLifeTime = CreateConVar("zs_giblifetime", "25", FCVAR_ARCHIVE, "Specifies how many seconds player gibs will stay in the world if not eaten or destroyed."):GetFloat()
cvars.AddChangeCallback("zs_giblifetime", function(cvar, oldvalue, newvalue)
	GAMEMODE.GibLifeTime = tonumber(newvalue) or 1
end)

GM.GriefForgiveness = math.ceil(100 * CreateConVar("zs_grief_forgiveness", "0.5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Scales the damage given to griefable objects by this amount. Does not actually prevent damage, it only decides how much of a penalty to give the player. Use smaller values for more forgiving, larger for less forgiving."):GetFloat()) * 0.01
cvars.AddChangeCallback("zs_grief_forgiveness", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefForgiveness = math.ceil(100 * (tonumber(newvalue) or 1)) * 0.01
end)

GM.GriefStrict = CreateConVar("zs_grief_strict", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Anti-griefing system. Gives points and eventually health penalties to humans who destroy friendly barricades."):GetBool()
cvars.AddChangeCallback("zs_grief_strict", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefStrict = tonumber(newvalue) == 1
end)

GM.GriefMinimumHealth = CreateConVar("zs_grief_minimumhealth", "100", FCVAR_ARCHIVE + FCVAR_NOTIFY, "The minimum health for an object to be considered griefable."):GetInt()
cvars.AddChangeCallback("zs_grief_minimumhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefMinimumHealth = tonumber(newvalue) or 100
end)

GM.GriefDamageMultiplier = math.ceil(100 * CreateConVar("zs_grief_damagemultiplier", "0.5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Multiplies damage done to griefable objects from humans by this amount."):GetFloat()) * 0.01
cvars.AddChangeCallback("zs_grief_damagemultiplier", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefDamageMultiplier = math.ceil(100 * (tonumber(newvalue) or 0.5)) * 0.01
end)

GM.GriefReflectThreshold = CreateConVar("zs_grief_reflectthreshold", "-5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Start giving damage if the player has less than this many points."):GetInt()
cvars.AddChangeCallback("zs_grief_reflectthreshold", function(cvar, oldvalue, newvalue)
	GAMEMODE.GriefReflectThreshold = tonumber(newvalue) or -5
end)

GM.MaxPropsInBarricade = CreateConVar("zs_maxpropsinbarricade", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Limits the amount of props that can be in one 'contraption' of nails."):GetInt()
cvars.AddChangeCallback("zs_maxpropsinbarricade", function(cvar, oldvalue, newvalue)
	GAMEMODE.MaxPropsInBarricade = tonumber(newvalue) or 8
end)

GM.MaxDroppedItems = 48--[[CreateConVar("zs_maxdroppeditems", "48", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Maximum amount of dropped items. Prevents spam or lag when lots of people die."):GetInt()
cvars.AddChangeCallback("zs_maxdroppeditems", function(cvar, oldvalue, newvalue)
	GAMEMODE.MaxDroppedItems = tonumber(newvalue) or 48
end)]]

GM.NailHealthPerRepair = CreateConVar("zs_nailhealthperrepair", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY, "How much health a nail gets when being repaired."):GetInt()
cvars.AddChangeCallback("zs_nailhealthperrepair", function(cvar, oldvalue, newvalue)
	GAMEMODE.NailHealthPerRepair = tonumber(newvalue) or 1
end)

GM.NoPropDamageFromHumanMelee = CreateConVar("zs_nopropdamagefromhumanmelee", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Melee from humans doesn't damage props."):GetBool()
cvars.AddChangeCallback("zs_nopropdamagefromhumanmelee", function(cvar, oldvalue, newvalue)
	GAMEMODE.NoPropDamageFromHumanMelee = tonumber(newvalue) == 1
end)

GM.MedkitPointsPerHealth = 3--[[CreateConVar("zs_medkitpointsperhealth", "8", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Specifies the amount of healing for players to be given a point. For use with the medkit and such."):GetInt()
cvars.AddChangeCallback("zs_medkitpointsperhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.MedkitPointsPerHealth = tonumber(newvalue) or 1
end)]]

GM.RepairPointsPerHealth = CreateConVar("zs_repairpointsperhealth", "25", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Specifies the amount of repairing for players to be given a point. For use with nails and such."):GetInt()
cvars.AddChangeCallback("zs_repairpointsperhealth", function(cvar, oldvalue, newvalue)
	GAMEMODE.RepairPointsPerHealth = tonumber(newvalue) or 1
end)

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

GM.HonorableMentions[HM_MOSTZOMBIESKILLED].GetPlayer = function(self)
	return GetMostKey("ZombiesKilled")
end

GM.HonorableMentions[HM_MOSTBRAINSEATEN].GetPlayer = function(self)
	return GetMostKey("BrainsEaten")
end

GM.HonorableMentions[HM_MOSTHEADSHOTS].GetPlayer = function(self)
	return GetMostKey("Headshots")
end

GM.HonorableMentions[HM_SCARECROW].GetPlayer = function(self)
	return GetMostKey("CrowKills")
end

GM.HonorableMentions[HM_DEFENCEDMG].GetPlayer = function(self)
	return GetMostKey("DefenceDamage")
end

GM.HonorableMentions[HM_STRENGTHDMG].GetPlayer = function(self)
	return GetMostKey("StrengthBoostDamage")
end

GM.HonorableMentions[HM_BARRICADEDESTROYER].GetPlayer = function(self)
	return GetMostKey("BarricadeDamage")
end

GM.HonorableMentions[HM_HANDYMAN].GetPlayer = function(self)
	local pl, amount = GetMostKey("RepairedThisRound")
	if pl and amount then
		return pl, math.ceil(amount)
	end
end

GM.HonorableMentions[HM_LASTHUMAN].GetPlayer = function(self)
	if self.TheLastHuman and self.TheLastHuman:IsValid() then return self.TheLastHuman end
end

GM.HonorableMentions[HM_MOSTHELPFUL].GetPlayer = function(self)
	return GetMostKey("ZombiesKilledAssists")
end

GM.HonorableMentions[HM_GOODDOCTOR].GetPlayer = function(self)
	return GetMostKey("HealedThisRound")
end

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

GM.HonorableMentions[HM_LASTBITE].GetPlayer = function(self)
	if LAST_BITE and LAST_BITE:IsValid() then
		return LAST_BITE
	end
end

GM.HonorableMentions[HM_USEFULTOOPPOSITE].GetPlayer = function(self)
	local pl, mag = GetMostFunc("Deaths")
	if mag and mag >= 30 then
		return pl, mag
	end
end

GM.HonorableMentions[HM_PACIFIST].GetPlayer = function(self)
	if WINNER == TEAM_HUMAN then
		for _, pl in pairs(player.GetAll()) do
			if pl.ZombiesKilled == 0 and pl:Team() == TEAM_HUMAN then return pl end
		end
	end
end

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

GM.HonorableMentions[HM_SALESMAN].GetPlayer = function(self)
	return GetMostKey("PointsCommission")
end

GM.HonorableMentions[HM_WAREHOUSE].GetPlayer = function(self)
	return GetMostKey("ResupplyBoxUsedByOthers")
end

GM.HonorableMentions[HM_NESTDESTROYER].GetPlayer = function(self)
	return GetMostKey("NestsDestroyed")
end

GM.HonorableMentions[HM_NESTMASTER].GetPlayer = function(self)
	return GetMostKey("NestSpawns")
end
