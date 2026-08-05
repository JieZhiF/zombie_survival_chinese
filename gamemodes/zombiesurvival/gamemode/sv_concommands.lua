-- 本文件主要负责处理从客户端发送至服务器的控制台指令（ConCommand），用于处理玩家的各种交互行为，如购买、升级、给予物品以及管理员调试等。

-- GM:ConCommandErrorMessage 向玩家发送一个居中显示的错误消息并播放提示音。
-- zs_pointsshopbuy 处理玩家从点数商店或废料商店购买物品的逻辑。
-- zs_dismantle 处理玩家拆解武器或物品以获得废料的逻辑。
-- zs_upgrade 处理玩家使用废料在升级台升级当前武器的逻辑。
-- worthrandom 在游戏开始时给予玩家一件随机的初始装备。
-- worthcheckout 处理玩家在游戏开始时根据"价值点"选择并确认初始装备的逻辑。
-- zsdropweapon 处理玩家丢弃当前手持武器或指定库存物品的逻辑。
-- zsemptyclip 处理玩家清空当前武器弹匣，将子弹退回备弹的逻辑。
-- GM:TryGetLockOnTrace 一个辅助函数，用于检测玩家面前是否有可以互动的其他玩家。
-- zsgiveammo 处理玩家将自己的备用弹药给予面前另一名玩家的逻辑。
-- zsgiveweapon 处理玩家将当前武器或库存物品给予面前另一名玩家的逻辑。
-- zsgiveweaponclip 处理玩家将当前武器（包含弹匣内的子弹）给予面前另一名玩家的逻辑。
-- zsdropammo 处理玩家丢弃一份指定类型弹药的逻辑。
-- zs_resupplyammotype 设置玩家在补给点优先补给的弹药类型。
-- zs_shitmap_check 管理员指令，用于检查地图中特定实体（传送门、按钮、门）的数量。
-- zs_shitmap_toteleport 超级管理员指令，用于传送到地图上指定的传送门实体。
-- zs_shitmap_teleport_on 超级管理员指令，用于启用地图上所有的传送门。
-- zs_shitmap_teleport_off 超级管理员指令，用于禁用地图上所有的传送门。
-- zs_shitmap_tobutton 超级管理员指令，用于传送到地图上指定的按钮实体。
-- zs_shitmap_tomover 超级管理员指令，用于传送到地图上指定的门或移动平台实体。
-- zs_mutationshop_click 处理僵尸玩家使用代币购买变异技能的逻辑。

-- 向玩家发送错误消息并播放提示音的辅助函数
function GM:ConCommandErrorMessage(pl, message)
	pl:CenterNotify(COLOR_RED, message)
	pl:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
end

-- 处理玩家从点数商店或废料商店购买物品的指令
concommand.Add("zs_pointsshopbuy", function(sender, command, arguments)
	-- 验证发送者是否有效、已连接且是存活的人类玩家
	if not (sender:IsValid() and sender:IsConnected() and sender:IsValidLivingHuman()) or #arguments == 0 then return end
	local usescrap = arguments[2]

	-- 判断当前是否为"波中"阶段（前一半波次之内），用于延迟购买者技能的检查
	local midwave = GAMEMODE:GetWave() < GAMEMODE:GetNumberOfWaves() / 2 or GAMEMODE:GetWave() == GAMEMODE:GetNumberOfWaves() / 2 and GAMEMODE:GetWaveActive() and CurTime() < GAMEMODE:GetWaveEnd() - (GAMEMODE:GetWaveEnd() - GAMEMODE:GetWaveStart()) / 2
	-- 如果玩家启用了延迟购买者技能且正在波中且不是使用废料购买，则发出警告
	if sender:IsSkillActive(SKILL_D_LATEBUYER) and not usescrap and midwave then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "late_buyer_warning"))
		return
	end

	-- 检查玩家是否靠近对应的交互实体（废料商店需要靠近重构台，点数商店需要靠近军火箱）
	if usescrap and not sender:NearRemantler() or not usescrap and not sender:NearArsenalCrate() then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, usescrap and "need_to_be_near_remantler" or "need_to_be_near_arsenal_crate"))
		return
	end

	-- 检查玩家当前是否可以购买（非使用废料时）
	if not (usescrap or gamemode.Call("PlayerCanPurchase", sender)) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "cant_purchase_right_now"))
		return
	end

	-- 获取要购买的物品ID，并查找对应的物品数据表
	local id = arguments[1]
	id = tonumber(id) or id
	local itemtab = FindItem(id)

	-- 验证物品是否存在且允许在商店中购买
	if not itemtab or not itemtab.PointShop then return end
	local itemcat = itemtab.Category
	-- 废料商店只允许购买小饰品、弹药或可废料制作的物品
	if usescrap and not (itemcat == ITEMCAT_TRINKETS or itemcat == ITEMCAT_AMMO) and not itemtab.CanMakeFromScrap then return end

	-- 获取玩家当前的货币数量（废料或点数）
	local points = usescrap and sender:GetAmmoCount("scrap") or sender:GetPoints()
	local cost = itemtab.Price

	-- 检查经典模式下的物品限制
	if GAMEMODE:IsClassicMode() and itemtab.NoClassicMode then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "cant_use_x_in_classic", itemtab.Name))
		return
	end

	-- 检查僵尸逃生模式下的物品限制
	if GAMEMODE.ZombieEscape and itemtab.NoZombieEscape then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "cant_use_x_in_zombie_escape", itemtab.Name))
		return
	end

	-- 检查玩家是否满足物品的技能要求
	if itemtab.SkillRequirement and not sender:IsSkillActive(itemtab.SkillRequirement) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "x_requires_a_skill_you_dont_have", itemtab.Name))
		return
	end

	-- 检查物品的层级解锁要求（特定波次后才可购买）
	if itemtab.Tier and GAMEMODE.LockItemTiers and not GAMEMODE.ObjectiveMap and not GAMEMODE.ZombieEscape and not GAMEMODE:IsClassicMode() and GAMEMODE:GetNumberOfWaves() == GAMEMODE.NumberOfWaves and GAMEMODE:GetWave() + (GAMEMODE:GetWaveActive() and 0 or 1) < itemtab.Tier then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "tier_x_items_unlock_at_wave_y", itemtab.Tier, itemtab.Tier))
		return
	end

	-- 检查物品库存是否还有余量
	if not GAMEMODE:HasItemStocks(id) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "out_of_stock"))
		return
	end

	-- 计算最终价格（废料价格向上取整，点数价格考虑折扣）
	cost = usescrap and math.ceil(GAMEMODE:PointsToScrap(cost)) or math.floor(cost * (sender.ArsenalDiscount or 1))

	-- 检查玩家货币是否足够
	if points < cost then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, usescrap and "need_to_have_enough_scrap" or "dont_have_enough_points"))
		return
	end

	-- 根据物品类型执行购买逻辑：回调函数 / 库存物品 / 武器
	if itemtab.Callback then
		itemtab.Callback(sender)
	elseif itemtab.SWEP then
		-- 非武器类物品（库存物品）
		if string.sub(itemtab.SWEP, 1, 6) ~= "weapon" then
			-- 小饰品类型的库存物品，如果已拥有则生成掉落实体
			if GAMEMODE:GetInventoryItemType(itemtab.SWEP) == INVCAT_TRINKETS and sender:HasInventoryItem(itemtab.SWEP) then
				local wep = ents.Create("prop_invitem")
				if wep:IsValid() then
					wep:SetPos(sender:GetShootPos())
					wep:SetAngles(sender:GetAngles())
					wep:SetInventoryItemType(itemtab.SWEP)
					wep:Spawn()
				end
			else
				sender:AddInventoryItem(itemtab.SWEP)
			end
		-- 武器类物品
		elseif sender:HasWeapon(itemtab.SWEP) then
			-- 如果玩家已有该武器且武器有 AmmoIfHas 属性，则只给弹药
			local stored = weapons.Get(itemtab.SWEP)
			if stored and stored.AmmoIfHas then
				sender:GiveAmmo(stored.Primary.DefaultClip, stored.Primary.Ammo)
			else
				-- 否则生成一个掉落武器实体
				local wep = ents.Create("prop_weapon")
				if wep:IsValid() then
					wep:SetPos(sender:GetShootPos())
					wep:SetAngles(sender:GetAngles())
					wep:SetWeaponType(itemtab.SWEP)
					wep:SetShouldRemoveAmmo(true)
					wep:Spawn()
				end
			end
		else
			-- 给玩家一把新武器，并处理"购买时为空弹"的属性
			local wep = sender:Give(itemtab.SWEP)
			if wep and wep:IsValid() and wep.EmptyWhenPurchased and wep:GetOwner():IsValid() then
				if wep.Primary then
					local primary = wep:ValidPrimaryAmmo()
					if primary then
						sender:RemoveAmmo(math.max(0, wep.Primary.DefaultClip - wep.Primary.ClipSize), primary)
					end
				end
				if wep.Secondary then
					local secondary = wep:ValidSecondaryAmmo()
					if secondary then
						sender:RemoveAmmo(math.max(0, wep.Secondary.DefaultClip - wep.Secondary.ClipSize), secondary)
					end
				end
			end
		end

		-- 记录武器购买统计
		GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, itemtab.SWEP, "Purchases", 1)
	else
		return
	end

	-- 扣除货币并播放对应音效
	if usescrap then
		sender:RemoveAmmo(cost, "scrap")
		sender:SendLua("surface.PlaySound(\"buttons/lever"..math.random(5)..".wav\")")
	else
		sender:TakePoints(cost)
		sender:SendLua("surface.PlaySound(\"ambient/levels/labs/coinslot1.wav\")")
	end
	sender:PrintTranslatedMessage(HUD_PRINTTALK, usescrap and "created_x_for_y_scrap" or "purchased_x_for_y_points", itemtab.Name, cost)

	-- 减少物品库存量
	GAMEMODE:AddItemStocks(id, -1)

	-- 处理购买佣金：如果是废料购买，给重构台所有者佣金；如果是点数购买，给军火箱所有者佣金
	if usescrap then
		local nearest = sender:NearestRemantler()
		if nearest then
			local owner = nearest.GetObjectOwner and nearest:GetObjectOwner() or nearest:GetOwner()
			if owner:IsValid() and owner ~= sender then
				local scrapcom = math.ceil(cost / 8)
				nearest:SetScraps(nearest:GetScraps() + scrapcom)
				nearest:GetObjectOwner():CenterNotify(COLOR_GREEN, translate.Format("remantle_used", scrapcom))
			end
		end
	else
		local nearest = sender:NearestArsenalCrateOwnedByOther()
		if nearest then
			local owner = nearest.GetObjectOwner and nearest:GetObjectOwner() or nearest:GetOwner()
			if owner:IsValid() then
				local commission = cost * GAMEMODE.ArsenalCrateCommission
				if commission > 0 then
					owner:AddPoints(commission, nil, nil, true)

					net.Start(NET_MSG.COMMISSION)
						net.WriteEntity(nearest)
						net.WriteEntity(sender)
						net.WriteFloat(commission)
					net.Send(owner)
				end
			end
		end
	end
end)

-- 处理玩家拆解武器或物品以获得废料的指令
concommand.Add("zs_dismantle", function(sender, command, arguments)
	-- 验证发送者是否有效、已连接且是存活的人类玩家
	if not (sender:IsValid() and sender:IsConnected() and sender:IsValidLivingHuman()) then return end

	local invitem, itypecat, potinv
	-- 检查是否有指定要拆解的库存物品
	if #arguments > 0 then
		invitem = arguments[1]
	end

	-- 如果指定了库存物品但玩家未拥有，则忽略
	if invitem and not sender:HasInventoryItem(invitem) then return end

	-- 获取当前活跃武器及其数据表
	local active = sender:GetActiveWeapon()
	local contents, wtbl = active:GetClass()
	-- 如果没有指定库存物品，则拆解当前活跃武器
	if not invitem then
		wtbl = weapons.Get(contents)
		-- 检查武器是否允许拆解
		if wtbl.NoDismantle or not (wtbl.AllowQualityWeapons or wtbl.PermitDismantle) then
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "cannot_dismantle"))
			return
		end

		-- AmmoIfHas 类型的武器在无弹药时无法拆解
		if wtbl.AmmoIfHas and sender:GetAmmoCount(wtbl.Primary.Ammo) == 0 and active:Clip1() == 0 then
			sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
			return
		end

		potinv = GAMEMODE.Breakdowns[contents]
	else
		-- 拆解库存物品：检查是否为可拆解的小饰品
		itypecat = GAMEMODE:GetInventoryItemType(invitem)
		if itypecat ~= INVCAT_TRINKETS or GAMEMODE.ZSInventoryItemData[invitem].PermitDismantle then
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "cannot_dismantle"))
			return
		end

		potinv = GAMEMODE.Breakdowns[invitem]
	end

	-- 计算拆解获得的废料数量并给予玩家
	local scrap = GAMEMODE:GetDismantleScrap(wtbl or GAMEMODE.ZSInventoryItemData[invitem], invitem)
	net.Start(NET_MSG.AMMOPICKUP)
		net.WriteUInt(scrap, 16)
		net.WriteString("scrap")
	net.Send(sender)
	sender:GiveAmmo(scrap, "scrap")

	-- 从玩家身上移除被拆解的物品或武器
	if invitem then
		sender:TakeInventoryItem(invitem)
	else
		sender:GetActiveWeapon():EmptyAll(true)

		if wtbl and wtbl.AmmoIfHas then
			sender:RemoveAmmo(1, wtbl.Primary.Ammo)
		end

		sender:StripWeapon(contents)
		sender:UpdateAltSelectedWeapon()
	end

	-- 记录拆解统计
	GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, invitem or contents, "Disassembles", 1)

	-- 如果拆解产物中有额外物品，给予玩家
	if potinv and potinv.Result then
		sender:AddInventoryItem(potinv.Result)

		net.Start(NET_MSG.INVITEM)
			net.WriteString(potinv.Result)
		net.Send(sender)
	end
end)

-- 处理玩家在重构台升级武器的指令
concommand.Add("zs_upgrade", function(sender, command, arguments)
	-- 验证发送者是否有效、已连接且是存活的人类玩家
	if not (sender:IsValid() and sender:IsConnected() and sender:IsValidLivingHuman()) then return end

	-- 玩家必须靠近重构台
	if not sender:NearRemantler() then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "need_to_be_near_remantler"))
		return
	end

	-- 获取当前武器信息、品级和分支
	local nearest = sender:NearestRemantler()
	local contents = sender:GetActiveWeapon():GetClass()
	local contentstbl = weapons.Get(contents)
	local contentsqua = contentstbl.QualityTier
	local desiredqua = contentsqua and contentsqua + 1 or 1

	local branch = contentstbl.Branch
	if not contentsqua and #arguments > 0 then
		branch = tonumber(arguments[1])
	end

	-- 验证重构台和武器有效性
	if not (nearest and nearest:IsValid() and contents) then return end

	-- 获取武器数据表和升级所需的废料数量
	local wtbl = weapons.Get(contents)
	local scrapcost = GAMEMODE:GetUpgradeScrap(wtbl, desiredqua)

	-- AmmoIfHas 类型的武器在无弹药时无法升级
	if wtbl.AmmoIfHas and sender:GetAmmoCount(wtbl.Primary.Ammo) == 0 then
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	-- 检查玩家废料是否足够
	if sender:GetAmmoCount("scrap") < scrapcost then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "need_to_have_enough_scrap"))
		return
	end

	-- 获取升级后的武器类型
	local upgclass = GAMEMODE:GetWeaponClassOfQuality(not contentsqua and contents or contentstbl.BaseQuality, desiredqua, branch)
	local classtbl = weapons.Get(upgclass)
	if not classtbl then return end

	-- 如果玩家已经拥有该升级版武器，则拒绝升级
	if sender:HasWeapon(upgclass) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "remantle_cannot"))
		return
	end

	-- 执行升级：扣废料、给新武器、移除旧武器
	local upgname = classtbl.PrintName
	sender:CenterNotify(COLOR_CYAN, translate.ClientGet(sender, "remantle_success"), color_white, " "..upgname)
	sender:SendLua("surface.PlaySound(\"buttons/lever"..math.random(5)..".wav\")")
	sender:RemoveAmmo(scrapcost, "scrap")

	local wep = sender:GiveEmptyWeapon(upgclass)
	if wep and wep:IsValid() then
		sender:GetActiveWeapon():EmptyAll(true)
		sender:SelectWeapon(upgclass)
		sender:StripWeapon(contents)
		sender:UpdateAltSelectedWeapon()

		if wtbl.AmmoIfHas then
			sender:RemoveAmmo(1, wtbl.Primary.Ammo)
		end
		if wep.AmmoIfHas then
			sender:GiveAmmo(1, wep.Primary.Ammo)
		end

		net.Start(NET_MSG.REMANTLECONF)
		net.Send(sender)

		-- 记录升级统计
		GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, upgclass, "Upgrades", 1)
	end

	-- 给重构台所有者佣金
	local owner = nearest.GetObjectOwner and nearest:GetObjectOwner() or nearest:GetOwner()
	if owner:IsValid() and owner ~= sender then
		local scrapcom = math.ceil(scrapcost * 0.08)
		nearest:SetScraps(nearest:GetScraps() + scrapcom)
		nearest:GetObjectOwner():CenterNotify(COLOR_GREEN, translate.Format("remantle_used", scrapcom))
	end
end)

-- 处理玩家在游戏开始时随机获得初始装备的指令
concommand.Add("worthrandom", function(sender, command, arguments)
	if sender:IsValid() and sender:IsConnected() and gamemode.Call("PlayerCanCheckout", sender) then
		gamemode.Call("GiveRandomEquipment", sender)
	end
end)

-- 处理玩家在游戏开始时选择并确认初始装备的指令
concommand.Add("worthcheckout", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected()) or #arguments == 0 then return end

	-- 检查玩家是否还可以选择初始装备
	if not gamemode.Call("PlayerCanCheckout", sender) then
		sender:CenterNotify(COLOR_RED, translate.ClientGet(sender, "cant_use_worth_anymore"))
		return
	end

	local cost = 0
	local hasalready = {}

	-- 第一遍遍历：计算所有物品的总价格
	for _, id in pairs(arguments) do
		id = tonumber(id) or id

		local tab = FindStartingItem(id)
		if tab and not hasalready[id] and (not tab.SkillRequirement or sender:IsSkillActive(tab.SkillRequirement)) then
			cost = cost + tab.Price
			hasalready[id] = true
		end
	end

	-- 检查总价是否超出玩家可用的初始价值点数
	if cost > GAMEMODE.StartingWorth + (sender.ExtraStartingWorth or 0) then return end

	hasalready = {}

	-- 第二遍遍历：实际给予玩家物品
	for _, id in pairs(arguments) do
		id = tonumber(id) or id

		local tab = FindStartingItem(id)
		if tab and not hasalready[id] then
			-- 检查技能要求、经典模式限制
			if tab.SkillRequirement and not sender:IsSkillActive(tab.SkillRequirement) then
				sender:PrintMessage(HUD_PRINTTALK, translate.ClientFormat(sender, "x_requires_a_skill_you_dont_have", tab.Name))
			elseif tab.NoClassicMode and GAMEMODE:IsClassicMode() then
				sender:PrintMessage(HUD_PRINTTALK, translate.ClientFormat(sender, "cant_use_x_in_classic_mode", tab.Name))
			elseif tab.Callback then
				tab.Callback(sender)
				hasalready[id] = true
			elseif tab.SWEP then
				-- 记录武器选择统计
				GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, tab.SWEP, "Checkouts", 1)

				-- 先剥离已有武器（防止互相给空武器刷弹药）
				sender:StripWeapon(tab.SWEP)
				if GAMEMODE.ZSInventoryItemData[tab.SWEP] then
					sender:AddInventoryItem(tab.SWEP)
				else
					sender:Give(tab.SWEP)
				end
				hasalready[id] = true
			end
		end
	end

	-- 如果成功选择了物品，则标记该玩家已结账
	if table.Count(hasalready) > 0 then
		GAMEMODE.CheckedOut[sender:SteamID64()] = true
	end

	-- 清理重复的弹药
	gamemode.Call("RemoveDuplicateAmmo", sender)
end)

-- 处理玩家丢弃武器的指令
concommand.Add("zsdropweapon", function(sender, command, arguments)
	-- 僵尸逃生模式下特殊处理：尝试丢弃精英手枪或刀
	local currentwep = sender:GetActiveWeapon()
	if GAMEMODE.ZombieEscape then
		local hwep, zwep = sender:GetWeapon("weapon_elite"), sender:GetWeapon("weapon_knife")
		if hwep and hwep:IsValid() then
			sender:DropWeapon(hwep)
		elseif zwep and zwep:IsValid() then
			sender:DropWeapon(zwep)
		end

		return
	end

	-- 验证玩家状态和丢弃冷却时间
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) or CurTime() < (sender.NextWeaponDrop or 0) or GAMEMODE.ZombieEscape then return end
	sender.NextWeaponDrop = CurTime() + 0.15

	-- 检查是否有指定要丢弃的库存物品
	local invitem
	if #arguments > 0 then
		invitem = arguments[1]
	end
	if invitem and not sender:HasInventoryItem(invitem) then return end

	-- 执行丢弃逻辑
	if invitem or (currentwep and currentwep:IsValid()) then
		local ent = invitem and sender:DropInventoryItemByType(invitem) or sender:DropWeaponByType(currentwep:GetClass())
		if ent and ent:IsValid() then
			local shootpos = sender:GetShootPos()
			local aimvec = sender:GetAimVector()
			ent:SetPos(util.TraceHull({start = shootpos, endpos = shootpos + aimvec * 32, mask = MASK_SOLID, filter = sender, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2)}).HitPos)
			ent:SetAngles(sender:GetAngles())
		end
	end
end)

-- 处理玩家清空当前武器弹匣的指令
concommand.Add("zsemptyclip", function(sender, command, arguments)
	-- 僵尸逃生模式下禁用此功能
	if GAMEMODE.ZombieEscape then return end

	-- 验证玩家状态
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	-- 冷却时间检查
	sender.NextEmptyClip = sender.NextEmptyClip or 0
	if sender.NextEmptyClip <= CurTime() then
		sender.NextEmptyClip = CurTime() + 0.1

		-- 将弹匣中的子弹退回备弹
		local wep = sender:GetActiveWeapon()
		if wep:IsValid() and (not wep.NoMagazine and not wep.AmmoIfHas or wep.AllowEmpty) then
			local primary = wep:ValidPrimaryAmmo()
			if primary and 0 < wep:Clip1() then
				sender:GiveAmmo(wep:Clip1(), primary, true)
				wep:SetClip1(0)
			end
			local secondary = wep:ValidSecondaryAmmo()
			if secondary and 0 < wep:Clip2() then
				sender:GiveAmmo(wep:Clip2(), secondary, true)
				wep:SetClip2(0)
			end
		end
	end
end)

-- 辅助函数：尝试获取玩家面前的锁定目标（用于给予物品）
function GM:TryGetLockOnTrace(sender, arguments)
	local ent
	local dent = Entity(tonumbersafe(arguments[2] or 0) or 0)
	-- 首先尝试从参数中获取有效的菜单锁定目标
	if GAMEMODE:ValidMenuLockOnTarget(sender, dent) then
		ent = dent
	end

	-- 如果参数无效，则通过近战追踪检测面前的实体
	if not ent then
		ent = sender:MeleeTrace(48, 2, nil, nil, true).Entity
	end

	return ent
end

-- 处理玩家给予另一名玩家弹药的指令
concommand.Add("zsgiveammo", function(sender, command, arguments)
	-- 僵尸逃生模式下禁用
	if GAMEMODE.ZombieEscape then return end

	-- 验证玩家状态
	if not sender:IsValid() or not sender:Alive() or sender:Team() ~= TEAM_HUMAN then return end

	-- 获取弹药类型并验证
	local ammotype = arguments[1]
	if not ammotype or #ammotype == 0 or not GAMEMODE.AmmoCache[ammotype] then return end

	-- 检查玩家是否有弹药可给予
	local count = sender:GetAmmoCount(ammotype)
	if count <= 0 then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_spare_ammo_to_give"))
		return
	end

	-- 获取目标玩家并给予弹药
	local ent = GAMEMODE:TryGetLockOnTrace(sender, arguments)
	if ent and ent:IsValidLivingHuman() then
		local desiredgive = math.min(count, GAMEMODE.AmmoCache[ammotype])
		if desiredgive >= 1 then
			sender:RemoveAmmo(desiredgive, ammotype)
			ent:GiveAmmo(desiredgive, ammotype)

			-- 播放给予弹药音效（带冷却）
			if CurTime() >= (sender.NextGiveAmmoSound or 0) then
				sender.NextGiveAmmoSound = CurTime() + 1
				sender:PlayGiveAmmoSound()
			end

			-- 播放给予手势
			sender:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)

			-- 通知给予者和接收者
			net.Start(NET_MSG.AMMOGIVE)
				net.WriteUInt(desiredgive, 16)
				net.WriteString(ammotype)
				net.WriteEntity(ent)
			net.Send(sender)

			net.Start(NET_MSG.AMMOGIVEN)
				net.WriteUInt(desiredgive, 16)
				net.WriteString(ammotype)
				net.WriteEntity(sender)
			net.Send(ent)

			return
		end
	else
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_person_in_range"))
	end
end)

-- 处理玩家给予另一名玩家武器的指令
concommand.Add("zsgiveweapon", function(sender, command, arguments)
	-- 僵尸逃生模式下禁用
	if GAMEMODE.ZombieEscape then return end

	-- 验证玩家状态
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	-- 检查是否有指定要给予的库存物品
	local invitem
	if #arguments > 0 then
		invitem = arguments[2]
	end
	if invitem and not sender:HasInventoryItem(invitem) then return end

	-- 获取当前武器
	local currentwep = sender:GetActiveWeapon()
	if not invitem and not IsValid(currentwep) then return end

	-- 获取目标玩家并给予物品
	local ent = GAMEMODE:TryGetLockOnTrace(sender, arguments)
	if ent and ent:IsValidLivingHuman() then
		if not invitem then
			if ent:HasWeapon(currentwep:GetClass()) then
				GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "person_has_weapon"))
			else
				sender:GiveWeaponByType(currentwep, ent, false)
			end
		else
			sender:GiveInventoryItemByType(invitem, ent)
		end
	else
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_person_in_range"))
	end
end)

-- 处理玩家给予另一名玩家武器（含弹匣弹药）的指令
concommand.Add("zsgiveweaponclip", function(sender, command, arguments)
	-- 僵尸逃生模式下禁用
	if GAMEMODE.ZombieEscape then return end

	-- 验证玩家状态
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	-- 获取当前武器
	local currentwep = sender:GetActiveWeapon()
	if currentwep and currentwep:IsValid() then
		local ent = GAMEMODE:TryGetLockOnTrace(sender, arguments)
		if ent and ent:IsValidLivingHuman() then
			-- 如果目标已有相同武器则拒绝
			if not ent:HasWeapon(currentwep:GetClass()) then
				sender:GiveWeaponByType(currentwep, ent, true)
			else
				GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "person_has_weapon"))
			end
		else
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_person_in_range"))
		end
	end
end)

-- 处理玩家丢弃指定类型弹药的指令
concommand.Add("zsdropammo", function(sender, command, arguments)
	-- 僵尸逃生模式下禁用
	if GAMEMODE.ZombieEscape then return end

	-- 验证玩家状态和丢弃冷却
	if not sender:IsValid() or not sender:Alive() or sender:Team() ~= TEAM_HUMAN or CurTime() < (sender.NextDropClip or 0) then return end

	sender.NextDropClip = CurTime() + 0.2

	-- 获取当前武器和要丢弃的弹药类型
	local wep = sender:GetActiveWeapon()
	if not wep:IsValid() then return end

	-- 默认丢弃当前武器使用的弹药类型
	local ammotype = arguments[1] or wep:GetPrimaryAmmoTypeString()
	if GAMEMODE.AmmoNames[ammotype] and GAMEMODE.AmmoCache[ammotype] then
		local ent = sender:DropAmmoByType(ammotype, GAMEMODE.AmmoCache[ammotype] * 2)
		if ent and ent:IsValid() then
			ent:SetPos(sender:EyePos() + sender:GetAimVector() * 8)
			ent:SetAngles(sender:GetAngles())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(sender:GetVelocity() * 0.85)
			end
		end
	end
end)

-- 设置玩家优先补给的弹药类型的指令
concommand.Add("zs_resupplyammotype", function(sender, command, arguments)
	-- 僵尸逃生模式下禁用
	if GAMEMODE.ZombieEscape then return end

	-- 验证玩家状态
	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	-- 设置补给弹药选择（"default" 表示恢复默认）
	local ammotype = arguments[1]
	if not ammotype or #ammotype == 0 or not (ammotype == "default" or GAMEMODE.AmmoResupply[ammotype]) then return end

	sender.ResupplyChoice = ammotype ~= "default" and ammotype or nil
end)

-- 管理员指令：检查地图中的传送门、按钮、门实体数量
concommand.Add("zs_shitmap_check", function(sender, command, arguments)
	if not sender:IsAdmin() then return end

	-- 统计各种实体的数量
	local teleporters = ents.FindByClass("trigger_teleport")
	local buttons = ents.FindByClass("func_button")
	local doors = ents.FindByClass("func_door_rotating")
	table.Add(doors, ents.FindByClass("func_movelinear"))

	sender:PrintMessage(HUD_PRINTCONSOLE, "Teleports: "..#teleporters.." Buttons: "..#buttons.." Doors: "..#doors)
end)

-- 超级管理员指令：传送到指定的传送门
concommand.Add("zs_shitmap_toteleport", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local ent = ents.FindByClass("trigger_teleport")[tonumber(arguments[1])]
	if ent then
		sender:SetPos(ent:WorldSpaceCenter())
	end
end)

-- 超级管理员指令：启用所有传送门
concommand.Add("zs_shitmap_teleport_on", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Fire("enable", "", 0)
	end
end)

-- 超级管理员指令：禁用所有传送门
concommand.Add("zs_shitmap_teleport_off", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Fire("enable", "", 0)
	end
end)

-- 超级管理员指令：传送到指定的按钮
concommand.Add("zs_shitmap_tobutton", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local ent = ents.FindByClass("func_button")[tonumber(arguments[1])]
	if ent then
		sender:SetPos(ent:WorldSpaceCenter())
	end
end)

-- 超级管理员指令：传送到指定的门或移动平台
concommand.Add("zs_shitmap_tomover", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local entities = ents.FindByClass("func_door_rotating")
	table.Add(entities, ents.FindByClass("func_movelinear"))
	local ent = entities[tonumber(arguments[1])]
	if ent then
		sender:SetPos(ent:WorldSpaceCenter())
	end
end)

-- 用这段代码完整替换你原来的 concommand.Add("zs_mutationshop_click", ...) 函数
-- 处理僵尸玩家使用代币（BTokens）购买变异技能的指令
concommand.Add("zs_mutationshop_click", function(sender, command, arguments)
	-- 验证发送者是否有效、已连接且有参数
	if not (sender:IsValid() and sender:IsConnected()) or #arguments == 0 then return end
	sender.UsedMutations = sender.UsedMutations or {}
	-- 注释掉的代码：原本检查是否还有人类存活，若有则阻止购买
	--[[for _, pl in pairs(player.GetAll(TEAM_HUMAN)) do
		if LASTHUMAN then
		sender:CenterNotify(COLOR_RED, translate.ClientGet(sender, "cant_buy_mutations"))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
		end
	end]]
	
	-- 检查僵尸当前是否可以购买变异技能
	if not gamemode.Call("ZombieCanPurchase", sender) then
		sender:CenterNotify(COLOR_RED, translate.ClientGet(sender, "cant_buy_mutations"))
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	local cost
	local hasalready = {}
	local tokens = sender:GetTokens()

	-- 遍历所有请求购买的变异技能
	for _, id in pairs(arguments) do
		local tab = FindMutation(id)
		
		if tab and not hasalready[id] then
			if tab.Price and tab.Callback then
				cost = tab.Price
				hasalready[id] = true
				
				-- 每次购买前重新读取代币余额，防止一次命令内多次购买时透支
				if sender:GetTokens() >= cost then

					tab.Callback(sender)
					sender:TakeTokens(cost)
					sender:PrintTranslatedMessage(HUD_PRINTTALK, "purchased_x_for_y_btokens", tab.Name, cost)
					sender:SendLua("surface.PlaySound(\"ambient/levels/labs/coinslot1.wav\")")
					-- 可重复购买项（如迷你BOSS变身）不记入 UsedMutations，
					-- 这样每次购买后界面不会显示"已拥有"，允许重复购买
					if not tab.Repeatable then
						sender.UsedMutations = sender.UsedMutations or {}
						table.insert(sender.UsedMutations, tab.Signature)
					end

				else
					-- 如果钱不够，可以给玩家一个提示
					sender:CenterNotify(COLOR_RED, translate.ClientGet(sender, "you_dont_have_enough_btokens"))
					sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
					-- 钱不够时，直接跳出循环，不再尝试购买后续物品
					break 
				end
			end
		end
	end

	-- 向客户端发送已使用的变异技能列表以更新UI
	net.Start(NET_MSG.MUTATIONS_TABLE)
		net.WriteTable(sender.UsedMutations)
	net.Send(sender)

end)
