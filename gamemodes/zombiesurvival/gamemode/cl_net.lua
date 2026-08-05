-- ============================================================
-- cl_net.lua - 网络消息接收处理
-- 负责处理从服务器发送到客户端的所有网络消息（net.Receive），
-- 用于同步游戏状态、更新 UI、播放音效、显示通知等。
-- ============================================================

-- 缓存 surface.PlaySound 函数引用以提高性能
local surface_PlaySound = surface.PlaySound

-- 伤害浮动数字显示开关的 ConVar（客户端可选）
local DamageFloaters = CreateClientConVar("zs_damagefloaters", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_damagefloaters", function(cvar, oldvalue, newvalue)
	DamageFloaters = newvalue ~= "0"
end)

-- 缓存 Player 元表和 Team 方法，避免重复表查找
local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team

-- 内部函数：更新人类菜单中当前选中武器的显示标签
local function AltSelItemUpd()
	local activeweapon = MySelf:GetActiveWeapon()
	if not activeweapon or not activeweapon:IsValid() then return end
	if not GAMEMODE.HumanMenuPanel or not GAMEMODE.HumanMenuPanel:IsValid() then return end
	if not GAMEMODE.HumanMenuPanel.SelectedItemLabel then return end

	local actwclass = activeweapon:GetClass()
	GAMEMODE.HumanMenuPanel.SelectedItemLabel:SetText(weapons.Get(actwclass).PrintName)
end

-- 接收服务器发来的腿部伤害值
net.Receive(NET_MSG.LEGDAMAGE, function(length)
	MySelf.LegDamage = net.ReadFloat()
end)

-- 接收服务器发来的手臂伤害值
net.Receive(NET_MSG.ARMDAMAGE, function(length)
	MySelf.ArmDamage = net.ReadFloat()
end)

-- 接收下一个 Boss 的信息（实体和职业名）
net.Receive(NET_MSG.NEXTBOSS, function(length)
	GAMEMODE.NextBossZombie = net.ReadEntity()
	GAMEMODE.NextBossZombieClass = net.ReadString()
end)

-- 接收僵尸志愿者列表（多人可同时当僵尸）
net.Receive(NET_MSG.ZVOLS, function(length)
	local volunteers = {}
	local count = net.ReadUInt(8)
	for i=1, count do
		volunteers[i] = net.ReadEntity()
	end

	GAMEMODE.ZombieVolunteers = volunteers
end)

-- 接收对玩家造成的伤害数据，用于显示伤害数字
net.Receive(NET_MSG.DMG, function(length)
	local damage = net.ReadUInt(16)
	local pos = net.ReadVector()

	if DamageFloaters then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetMagnitude(damage)
			effectdata:SetScale(0)
		util.Effect("damagenumber", effectdata)
	end
end)

-- 接收对道具/障碍物造成的伤害数据，用于显示伤害数字（scale=1 标记为道具伤害）
net.Receive(NET_MSG.DMG_PROP, function(length)
	local damage = net.ReadUInt(16)
	local pos = net.ReadVector()

	if DamageFloaters then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetMagnitude(damage)
			effectdata:SetScale(1)
		util.Effect("damagenumber", effectdata)
	end
end)

-- 接收玩家的当局完整统计数据（障碍物伤害、人类伤害、吃掉的大脑数）
net.Receive(NET_MSG.LIFESTATS, function(length)
	local barricadedamage = net.ReadUInt(16)
	local humandamage = net.ReadUInt(16)
	local brainseaten = net.ReadUInt(8)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsBarricadeDamage = barricadedamage
	GAMEMODE.LifeStatsHumanDamage = humandamage
	GAMEMODE.LifeStatsBrainsEaten = brainseaten
end)

-- 单独更新障碍物伤害统计
net.Receive(NET_MSG.LIFESTATSBD, function(length)
	local barricadedamage = net.ReadUInt(16)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsBarricadeDamage = barricadedamage
end)

-- 单独更新对人类伤害统计
net.Receive(NET_MSG.LIFESTATSHD, function(length)
	local humandamage = net.ReadUInt(16)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsHumanDamage = humandamage
end)

-- 单独更新吃掉的大脑数统计
net.Receive(NET_MSG.LIFESTATSBE, function(length)
	local brainseaten = net.ReadUInt(8)

	GAMEMODE.LifeStatsEndTime = CurTime() + GAMEMODE.LifeStatsLifeTime

	GAMEMODE.LifeStatsBrainsEaten = brainseaten
end)

-- 接收回合结束时的荣誉提名信息（玩家、提名ID、额外数据）
net.Receive(NET_MSG.HONMENTION, function(length)
	local pl = net.ReadEntity()
	local mentionid = net.ReadUInt(8)
	local etc = net.ReadInt(32)

	if pl:IsValid() then
		gamemode.Call("AddHonorableMention", pl, mentionid, etc)
	end
end)

-- 接收当前生效的突变列表（随便放就行）
net.Receive(NET_MSG.MUTATIONS_TABLE, function(len)
	local mutationstable = net.ReadTable()
	if mutationstable then
		UsedMutations = mutationstable
	end
end)

-- 接收波数开始事件：更新波数、时间，显示通知并播放音乐
net.Receive(NET_MSG.WAVESTART, function(length)
	local wave = net.ReadInt(16)
	local time = net.ReadFloat()

	gamemode.Call("SetWave", wave)
	gamemode.Call("SetWaveEnd", time)

	if GAMEMODE.ZombieEscape then
		GAMEMODE:CenterNotify(COLOR_RED, {font = "ZSHUDFont"}, translate.Get("escape_from_the_zombies"))
	elseif wave == GAMEMODE:GetNumberOfWaves() then
		GAMEMODE:CenterNotify({killicon = "default"}, {font = "ZSHUDFont"}, " ", COLOR_RED, translate.Get("final_wave"), {killicon = "default"})
		GAMEMODE:CenterNotify(translate.Get("final_wave_sub"))
	else
		GAMEMODE:CenterNotify({killicon = "default"}, {font = "ZSHUDFont"}, " ", COLOR_RED, translate.Format("wave_x_has_begun", wave), {killicon = "default"})

		if wave == 1 and GAMEMODE:GetUseSigils() then
			GAMEMODE:CenterNotify(translate.Format("x_sigils_appeared", GAMEMODE.MaxSigils))
		end
	end

	surface_PlaySound("ambient/creatures/town_zombie_call1.wav")
end)

-- 接收新职业解锁通知
net.Receive(NET_MSG.CLASSUNLOCK, function(length)
	GAMEMODE:CenterNotify(COLOR_GREEN, translate.Format("x_unlocked", net.ReadString()))
end)

-- 接收波数结束事件：更新下一波开始时间，显示生存奖励和剩余技能点提示
net.Receive(NET_MSG.WAVEEND, function(length)
	local wave = net.ReadInt(16)
	local time = net.ReadFloat()

	gamemode.Call("SetWaveStart", time)

	if wave < GAMEMODE:GetNumberOfWaves() and wave > 0 then
		GAMEMODE:CenterNotify(COLOR_RED, {font = "ZSHUDFont"}, translate.Format("wave_x_is_over", wave))
		GAMEMODE:CenterNotify(translate.Get("wave_x_is_over_sub"))

		if MySelf:IsValid() and P_Team(MySelf) == TEAM_HUMAN then
			if MySelf:GetZSSPRemaining() > 0 then
				GAMEMODE:CenterNotify(translate.Format("unspent_skill_points_press_x", input.LookupBinding("gm_showspare1") or "F3"))
			end

			if GAMEMODE.EndWavePointsBonus > 0 then
				local pointsbonus = GAMEMODE.EndWavePointsBonus + (GAMEMODE:GetWave() - 1) * GAMEMODE.EndWavePointsBonusPerWave + (MySelf.EndWavePointsExtra or 0)

				if not MySelf.Scourer then
					GAMEMODE:CenterNotify(COLOR_CYAN, translate.Format("points_for_surviving", pointsbonus))
				else
					GAMEMODE:CenterNotify(COLOR_ORANGE, translate.Format("scrap_for_surviving", pointsbonus))
				end
			end
		end

		surface_PlaySound("ambient/atmosphere/cave_hit"..math.random(6)..".wav")
	end
end)

-- 同步当前的游戏状态（波数、波开始时间、波结束时间）
net.Receive(NET_MSG.GAMESTATE, function(length)
	local wave = net.ReadInt(16)
	local wavestart = net.ReadFloat()
	local waveend = net.ReadFloat()

	gamemode.Call("SetWave", wave)
	gamemode.Call("SetWaveStart", wavestart)
	gamemode.Call("SetWaveEnd", waveend)
end)

-- 接收 Boss 生成事件：显示通知，玩家若成为 Boss 则有特殊提示
net.Receive(NET_MSG.BOSS_SPAWNED, function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}
	local kid = {killicon = "default"}

	if ent == MySelf and ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_RED, translate.Format("you_are_x", translate.Get(classtbl.TranslationName)), ki)
	elseif ent:IsValid() and P_Team(MySelf) == TEAM_UNDEAD then
		GAMEMODE:CenterNotify(ki, " ", COLOR_RED, translate.Format("x_has_risen_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	else
		GAMEMODE:CenterNotify(kid, " ", COLOR_RED, translate.Get("x_has_risen"), kid)
	end

	if MySelf:IsValid() then
		MySelf:EmitSound(string.format("npc/zombie_poison/pz_alert%d.wav", math.random(1, 2)), 0, math.random(95, 105))
	end
end)

-- 接收 Boss 被击杀事件：显示通知并播放音效
net.Receive(NET_MSG.BOSS_SLAIN, function(length)
	local ent = net.ReadEntity()
	local classindex = net.ReadUInt(8)
	local classtbl = GAMEMODE.ZombieClasses[classindex]
	local ki = {killicon = classtbl.SWEP}

	if ent:IsValid() then
		GAMEMODE:CenterNotify(ki, " ", COLOR_YELLOW, translate.Format("x_has_been_slain_as_y", ent:Name(), translate.Get(classtbl.TranslationName)), ki)
	end

	if MySelf:IsValid() then
		MySelf:EmitSound("ambient/atmosphere/cave_hit4.wav", 0, 150)
	end
end)

-- 更新特定僵尸职业的解锁状态
net.Receive(NET_MSG.CLASSUNLOCKSTATE, function(length)
	local clstr = net.ReadInt(8)
	local class = GAMEMODE.ZombieClasses[clstr]
	local unlocked = net.ReadBool()

	class.Locked = not unlocked
	class.Unlocked = unlocked
end)

-- 在屏幕中央显示通知（从服务器接收表格参数）
net.Receive(NET_MSG.CENTERNOTIFY, function(length)
	local tab = net.ReadTable()

	GAMEMODE:CenterNotify(unpack(tab))
end)

-- 在屏幕顶部显示通知（从服务器接收表格参数）
net.Receive(NET_MSG.TOPNOTIFY, function(length)
	local tab = net.ReadTable()

	GAMEMODE:TopNotify(unpack(tab))
end)

-- 处理玩家幸存事件：显示顶部通知，存活者为自己时触发白屏淡出效果
net.Receive(NET_MSG.SURVIVOR, function(length)
	local ent = net.ReadEntity()

	if ent:IsValidPlayer() then
		GAMEMODE:TopNotify(ent, " ", translate.Get("has_survived"))

		if ent == MySelf then
			util.WhiteOut(3)
		end
	end
end)

-- 接收最后一名人类玩家的信息
net.Receive(NET_MSG.LASTHUMAN, function(length)
	local pl = net.ReadEntity()

	gamemode.Call("LastHuman", pl)
end)

-- 远程调用一个游戏模式函数（函数名由服务器发送）
-- 白名单限制：仅允许服务器已知安全的下发调用，防滥用
local AllowedGamemodeCalls = {
	RestartRound = true,
}
net.Receive(NET_MSG.GAMEMODECALL, function(length)
	local funcname = net.ReadString()
	if AllowedGamemodeCalls[funcname] then
		gamemode.Call(funcname)
	end
end)

-- 接收最后一名人类玩家的位置坐标
net.Receive(NET_MSG.LASTHUMANPOS, function(length)
	GAMEMODE.LastHumanPosition = net.ReadVector()
end)

-- 接收回合结束事件：包含胜利方和下一张地图名
net.Receive(NET_MSG.ENDROUND, function(length)
	local winner = net.ReadUInt(8)
	local nextmap = net.ReadString()

	gamemode.Call("EndRound", winner, nextmap)
end)

-- 接收治疗其他玩家的通知：显示浮动数字和中央提示
net.Receive(NET_MSG.HEALOTHER, function(length)
	local healed_player = net.ReadEntity()
	local health_amount = net.ReadFloat()

	if not IsValid(healed_player) then return end

	gamemode.Call("HealedOtherPlayer", healed_player, health_amount)
	
	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicalkit"}, " ", COLOR_GREEN, translate.Format("healed_x_for_y", healed_player:Name(), health_amount))
end)

-- 接收修复物体的事件通知
net.Receive(NET_MSG.REPAIROBJECT, function(length)
	gamemode.Call("RepairedObject", net.ReadEntity(), net.ReadFloat())
end)

-- 接收收到佣金的事件通知
net.Receive(NET_MSG.COMMISSION, function(length)
	gamemode.Call("ReceivedCommission", net.ReadEntity(), net.ReadEntity(), net.ReadFloat())
end)

-- 接收印记被腐化的事件：播放音效序列，显示通知
net.Receive(NET_MSG.SIGILCORRUPTED, function(length)
	local corrupted = net.ReadUInt(8)

	LastSigilCorrupted = CurTime()

	if MySelf:IsValid() then
		local maxsigils = GAMEMODE:NumSigils()
		local winddown = CreateSound(MySelf, "ambient/levels/labs/teleport_winddown1.wav")
		winddown:PlayEx(1, 120)

		timer.Simple(1.25, function()
			MySelf:EmitSound("ambient/levels/labs/machine_stop1.wav", 75, 80)
			MySelf:EmitSound("ambient/atmosphere/hole_hit5.wav", 75, 70)
		end)

		timer.Simple(1.5, function()
			winddown:Stop()
			MySelf:EmitSound("zombiesurvival/eyeflash.ogg", 75, 100)
		end)

		if corrupted == maxsigils then
			GAMEMODE:CenterNotify({killicon = "default"}, {font = "ZSHUDFontSmall"}, COLOR_RED, translate.Get("sigil_corrupted_last"), {killicon = "default"})
		else
			GAMEMODE:CenterNotify(COLOR_RED, {font = "ZSHUDFontSmall"}, translate.Get("sigil_corrupted"))
		end
	end
end)

-- 接收印记被净化的事件：播放音效并显示通知
net.Receive(NET_MSG.SIGILUNCORRUPTED, function(length)
	LastSigilUncorrupted = CurTime()

	if MySelf:IsValid() then
		MySelf:EmitSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 75, 180)

		timer.Simple(1.25, function()
			MySelf:EmitSound("ambient/machines/teleport1.wav", 75, 60, 0.3)
		end)
		GAMEMODE:CenterNotify(COLOR_GREEN, {font = "ZSHUDFontSmall"}, translate.Get("sigil_uncorrupted"))
	end
end)

-- 显示拾取弹药的通知
net.Receive(NET_MSG.AMMOPICKUP, function(length)
	local amount = net.ReadUInt(16)
	local ammotype = net.ReadString()
	local ico = GAMEMODE.AmmoIcons[ammotype] or "weapon_zs_resupplybox"

	ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

	GAMEMODE:CenterNotify({killicon = ico}, " ", COLOR_GREEN, translate.Format("obtained_x_y_ammo", amount, ammotype))
end)

-- 显示给予其他玩家弹药的通知
net.Receive(NET_MSG.AMMOGIVE, function(length)
	local amount = net.ReadUInt(16)
	local ammotype = net.ReadString()
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end
	local ico = GAMEMODE.AmmoIcons[ammotype] or "weapon_zs_resupplybox"

	ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

	GAMEMODE:CenterNotify({killicon = ico}, " ", COLOR_GREEN, translate.Format("gave_x_y_ammo_to_z", amount, ammotype, ent:Name()))
end)

-- 显示从其他玩家处收到弹药的通知
net.Receive(NET_MSG.AMMOGIVEN, function(length)
	local amount = net.ReadUInt(16)
	local ammotype = net.ReadString()
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end
	local ico = GAMEMODE.AmmoIcons[ammotype] or "weapon_zs_resupplybox"
 
	ammotype = GAMEMODE.AmmoNames[ammotype] or ammotype

	GAMEMODE:CenterNotify({killicon = ico}, " ", COLOR_GREEN, translate.Format("obtained_x_y_ammo_from_z", ent:Name(), amount, ammotype))
end)

-- 显示可部署物品丢失的通知
net.Receive(NET_MSG.DEPLOYABLELOST, function(length)
	local deploy = net.ReadString()
	local class = net.ReadString()

	GAMEMODE:CenterNotify({killicon = class}, " ", COLOR_RED, translate.Format("deployable_lost", deploy))
end)

-- 显示可部署物品被领取的通知
net.Receive(NET_MSG.DEPLOYABLECLAIM, function(length)
	local deploy = net.ReadString()
	local class = net.ReadString()

	GAMEMODE:CenterNotify({killicon = class}, " ", COLOR_LBLUE, translate.Format("deployable_claimed", deploy))
end)

-- 显示可部署物品弹药耗尽的通知
net.Receive(NET_MSG.DEPLOYABLEOUT, function(length)
	local deploy = net.ReadString()
	local class = net.ReadString()

	GAMEMODE:CenterNotify({killicon = class}, " ", COLOR_RED, translate.Format("ran_out_of_ammo", deploy))
end)

-- 显示饰品被消耗的通知并播放音效
net.Receive(NET_MSG.TRINKETCONSUMED, function(length)
	local trinket = net.ReadString()
	MySelf:EmitSound("buttons/button3.wav", 75, 50)

	GAMEMODE:CenterNotify({killicon = "weapon_zs_trinket"}, " ", COLOR_RORANGE, translate.Format("trinket_consumed", trinket))
end)

-- 接收AFK状态更新（TAB记分板显示AFK提示，类似特殊身份图标）
net.Receive(NET_MSG.AFK_STATE, function(length)
	local pl = net.ReadEntity()
	local afk = net.ReadBool()
	if pl:IsValid() then
		pl.ZSAFK = afk
	end
end)

-- 显示获得物品栏物品的通知
net.Receive(NET_MSG.INVITEM, function(length)
	local invitemt = net.ReadString()
	local inviname = GAMEMODE.ZSInventoryItemData[invitemt].PrintName
	local category = GAMEMODE:GetInventoryItemType(invitemt)

	surface.PlaySound("items/ammo_pickup.wav")
	GAMEMODE:CenterNotify({killicon = category == INVCAT_TRINKETS and "weapon_zs_trinket" or "weapon_zs_craftables"}, " ", COLOR_RORANGE, translate.Format("obtained_a_inv", inviname))
end)

-- 显示从其他玩家处获得物品栏物品的通知
net.Receive(NET_MSG.INVGIVEN, function(length)
	local invitemt = net.ReadString()
	local inviname = GAMEMODE.ZSInventoryItemData[invitemt].PrintName
	local category = GAMEMODE:GetInventoryItemType(invitemt)
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = category == INVCAT_TRINKETS and "weapon_zs_trinket" or "weapon_zs_craftables"}, " ", COLOR_RORANGE, translate.Format("obtained_inv_item_from_z", inviname, ent:Name()))
end)

-- 显示被其他玩家治疗的通知
net.Receive(NET_MSG.HEALBY, function(length)
	local amount = net.ReadFloat()
	local ent = net.ReadEntity()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicalkit"}, " ", COLOR_GREEN, translate.Format("healed_x_by_y", ent:Name(), amount))
end)

-- 显示被其他玩家施加增益效果的通知
net.Receive(NET_MSG.BUFFBY, function(length)
	local ent = net.ReadEntity()
	local buff = net.ReadString()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicgun"}, " ", COLOR_GREEN, translate.Format("buffed_x_with_y", ent:Name(), buff))
end)

-- 显示为其他玩家施加增益效果的通知
net.Receive(NET_MSG.BUFFWITH, function(length)
	local ent = net.ReadEntity()
	local buff = net.ReadString()

	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_medicgun"}, " ", COLOR_GREEN, translate.Format("buffed_x_with_a_y", ent:Name(), buff))
end)

-- 显示自己的木板被其他玩家移除的通知
net.Receive(NET_MSG.NAILREMOVED, function(length)
	local ent = net.ReadEntity()
	if not ent:IsValidPlayer() then return end

	GAMEMODE:CenterNotify({killicon = "weapon_zs_hammer"}, " ", COLOR_RED, translate.Format("removed_your_nail", ent:Name()))
end)

-- 接收并更新当前回合数
net.Receive(NET_MSG.CURRENTROUND, function(length)
	GAMEMODE.CurrentRound = net.ReadUInt(6)
end)

-- 更新人类菜单中当前选中武器的显示（延迟执行确保界面已就绪）
net.Receive(NET_MSG.UPDATEALTSELWEP, function(length)
	if MySelf:Alive() and P_Team(MySelf) == TEAM_HUMAN and GAMEMODE.HumanMenuPanel and GAMEMODE.HumanMenuPanel:IsValid() and not (GAMEMODE.InventoryMenu and GAMEMODE.InventoryMenu.SelInv) then
		timer.Simple(0.25, AltSelItemUpd)
	end
end)

-- 刷新僵尸出生菜单以响应巢穴建成
net.Receive(NET_MSG.NESTBUILT, function(length)
	if GAMEMODE.ZSpawnMenu and GAMEMODE.ZSpawnMenu:IsValid() then
		GAMEMODE.ZSpawnMenu:RefreshContents()
	end
end)
