-- 本文件负责处理僵尸逃生（Zombie Escape / ZE）模式的服务器端逻辑。
-- 包括：CS地图实体转换、玩家冻结、波次管理、时间限制伤害、以及通过 trigger_hurt 检测僵尸全灭来结束回合。

-- 注册客户端和共享文件以便传输至客户端
AddCSLuaFile("cl_zombieescape.lua")
AddCSLuaFile("sh_zombieescape.lua")

-- 包含共享的 ZE 逻辑文件
include("sh_zombieescape.lua")

-- 如果不是僵尸逃生模式，则直接返回（不执行后续代码）
if not GM.ZombieEscape then return end

-- 将需要清理地图时保留的实体类型添加到清理过滤表中
table.insert(GM.CleanupFilter, "func_brush")
table.insert(GM.CleanupFilter, "env_global")
table.insert(GM.CleanupFilter, "info_player_terrorist")
table.insert(GM.CleanupFilter, "info_player_counterterrorist")

-- 映射表：用于修正 CS 地图中的 setparentattachment 值为 GMod 支持的值
local attachmentFallbackMap = table.ToAssoc({
	"forward",
	"grenade0",
	"grenade1",
	"grenade2",
	"pistol",
	"primary",
	"defusekit",
	"eholster",
	"rfoot",
	"lfoot",
	"muzzle_flash"
})

-- 钩子：拦截实体键值设置，修正 CS 地图实体以适配 ZS
hook.Add("EntityKeyValue", "zombieescape", function(ent, key, value)
	-- 修正 filter_activator_team 的队伍ID：CS中 Terrorist=2, CT=3，需要映射到 ZS 的 TEAM_UNDEAD 和 TEAM_HUMAN
	if ent:GetClass() == "filter_activator_team" and not ent.ZEFix then
		if string.lower(key) == "filterteam" then
			if value == "2" then
				ent.ZEFix = tostring(TEAM_UNDEAD)
			elseif value == "3" then
				ent.ZEFix = tostring(TEAM_HUMAN)
			end
		end

		return true
	end

	-- 注释掉的代码：原本用于删除会恢复血量或设置血量的触发器
	--[[if (ent:GetClass() == "trigger_multiple" or ent:GetClass() == "trigger_once") and string.find(string.lower(value), "%!.*%,.+%,health") then
		ent.ZEDelete = true
	end]]

	-- 修复 setparentattachment 的兼容性问题（Samuel Maddock 的修复）
	if value:lower():find("setparentattachment") then
		local startIdx, endIdx, attachmentName = value:lower():find("^.-,setparentattachment,(.-),")

		if startIdx and attachmentFallbackMap[attachmentName] then
			startIdx = endIdx - attachmentName:len()
			return value:sub(1, startIdx - 1) .. "eyes" .. value:sub(endIdx)
		end
	end
end)

-- 钩子：地图实体初始化完成后执行修正和设置
hook.Add("InitPostEntityMap", "zombieescape", function(fromze)
	-- 应用之前保存的队伍过滤器修正
	for _, ent in pairs(ents.FindByClass("filter_activator_team")) do
		if ent.ZEFix then
			ent:SetKeyValue("filterteam", ent.ZEFix)
		end
	end

	-- 删除标记为需要删除的实体
	for _, ent in pairs(ents.GetAll()) do
		if ent and ent.ZEDelete and ent:IsValid() then
			ent:Remove()
		end
	end

	-- 强制启用动态生成（ZE地图通常只有一个出生点，不开动态生成对僵尸太无聊）
	GAMEMODE.DynamicSpawning = true

	-- 如果不是从 ZE 地图重新初始化，则设置波次开始时间
	if not fromze then
		GAMEMODE:SetRedeemBrains(0)
		if GAMEMODE.CurrentRound <= 1 then
			GAMEMODE:SetWaveStart(CurTime() + GAMEMODE.WaveZeroLength + 30) -- 首回合多给30秒让玩家加入
		else
			GAMEMODE:SetWaveStart(CurTime() + GAMEMODE.ZE_FreezeTime)
		end
	end
end)

-- 钩子：玩家出生时处理冻结逻辑
hook.Add("PlayerSpawn", "zombieescape", function(pl)
	timer.Simple(0, function()
		if not pl:IsValid() then return end

		-- 在第0波且波次未开始时，冻结所有玩家（无敌且不能移动），类似CS的冻住时间
		if GAMEMODE:GetWave() == 0 and not GAMEMODE:GetWaveActive() and (pl:Team() == TEAM_UNDEAD or pl:Team() == TEAM_HUMAN and CurTime() < GAMEMODE:GetWaveStart() - GAMEMODE.ZE_FreezeTime) then
			pl.ZEFreeze = true
			pl:Freeze(true)
			pl:GodEnable()
		end
	end)
end)

-- 在 ZE 模式中，胜利条件通常是所有僵尸在同一时刻全部死亡（由覆盖全图的 trigger_hurt 触发）
-- 所以当所有活着的僵尸同时被 trigger_hurt 杀死时，判定人类获胜

-- 钩子：监听波次状态变化，在波1开始时解冻所有玩家
hook.Add("OnWaveStateChanged", "zombieescape", function()
	if GAMEMODE:GetWave() == 1 and GAMEMODE:GetWaveActive() then
		for _, pl in pairs(player.GetAll()) do
			pl:Freeze(false)
			pl:GodDisable()
		end
	end
end)

-- 局部变量：用于检测僵尸全灭的时间状态
local CheckTime
local FreezeTime = true
local NextDamage = 0

-- 钩子：每帧更新逻辑，处理冻结阶段、时间限制伤害和僵尸全灭检测
hook.Add("Think", "zombieescape", function()
	-- 第0波（准备阶段）的处理：冻结倒计时结束后解冻人类并重新布置
	if GAMEMODE:GetWave() == 0 then
		if FreezeTime and CurTime() >= GAMEMODE:GetWaveStart() - GAMEMODE.ZE_FreezeTime then
			FreezeTime = false

			-- 清理地图（保留过滤列表中的实体）
			game.CleanUpMap(false, GAMEMODE.CleanupFilter)
			gamemode.Call("InitPostEntityMap", true)

			-- 解冻所有人类玩家，并将他们移动到出生点
			for _, pl in pairs(team.GetPlayers(TEAM_HUMAN)) do
				pl.ZEFreeze = nil
				pl:Freeze(false)
				pl:GodDisable()
				local ent = GAMEMODE:PlayerSelectSpawn(pl)
				if IsValid(ent) then
					pl:SetPos(ent:GetPos())
				end
			end
		end

		return
	end

	-- 重置冻结状态标志
	FreezeTime = true

	-- 时间限制：波次开始后超过 ZE_TimeLimit 秒，人类每秒受到5点伤害（强制推进）
	if CurTime() >= GAMEMODE:GetWaveStart() + GAMEMODE.ZE_TimeLimit and CurTime() >= NextDamage then
		NextDamage = CurTime() + 1

		for _, pl in pairs(team.GetPlayers(TEAM_HUMAN)) do
			pl:TakeDamage(5)
		end
	end

	-- 检查是否所有僵尸都已死亡
	local undead = team.GetPlayers(TEAM_UNDEAD)
	if #undead == 0 then return end

	-- 检查每个僵尸是否都被 trigger_hurt 杀死（超过12秒的标记则忽略）
	for _, pl in pairs(undead) do
		if not pl.KilledByTriggerHurt or CurTime() > pl.KilledByTriggerHurt + 12 then
			CheckTime = nil
			return
		end
	end

	-- 所有僵尸都被 trigger_hurt 杀死，设置2.5秒的延迟检测
	CheckTime = CheckTime or (CurTime() + 2.5)

	-- 延迟结束后宣告人类胜利
	if CheckTime and CurTime() >= CheckTime then
		gamemode.Call("EndRound", TEAM_HUMAN)
	end
end)

-- 钩子：玩家死亡时记录死亡位置和 trigger_hurt 击杀标记
hook.Add("DoPlayerDeath", "zombieescape", function(pl, attacker, dmginfo)
	pl.KilledPos = pl:GetPos()

	-- 僵尸玩家死亡处理
	if pl:Team() == TEAM_UNDEAD then
		-- 被 trigger_hurt 击杀（即地图范围的即死伤害），标记并设置10秒重生延迟
		if attacker:IsValid() and attacker:GetClass() == "trigger_hurt" and not attacker:GetParent():IsValid() then
			pl.KilledByTriggerHurt = CurTime()
			pl.NextSpawnTime = CurTime() + 10
		elseif GAMEMODE.RoundEnded then
			-- 如果回合已结束，设置极长的重生延迟（防止回合结束后重生）
			pl.NextSpawnTime = CurTime() + 9999
		else
			-- 正常死亡，5秒后重生
			pl.NextSpawnTime = CurTime() + 5
		end
	end
end)
