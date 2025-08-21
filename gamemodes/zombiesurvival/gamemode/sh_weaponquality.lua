-- 本文件主要负责定义和管理武器的品质和升级系统。它通过创建基础武器的改良版本来提升武器属性，
-- 同时处理不同的升级分支路径，并计算升级和分解武器相关的游戏内货币（废料）成本。

-- GM.WeaponQualityModifiers 存储所有可用的武器属性修改器的定义。
-- GM.WeaponQualities 定义不同的武器品质等级，包括其名称和基础伤害乘数。
-- GM.WeaponQualityColors 定义用于不同品质等级武器UI或击杀图标的颜色。
-- WEAPON_MODIFIER_* 一系列常量，用作每种武器属性修改器的唯一ID。
-- GM:AddWeaponQualityModifier 注册一种新的武器属性修改器（例如“换弹速度”）及其影响的武器变量。
-- GM:SetPrimaryWeaponModifier 为一个武器设置主要的品质升级属性，以替代默认的伤害加成。
-- GM:AttachWeaponModifier 为一个武器的品质升级路径添加一个次要的属性修改器。
-- GM:AddNewRemantleBranch 为一个武器定义一个可供选择的升级分支，具有独特的名称、描述和修改功能。
-- ApplyWeaponModifier (内部函数) 根据武器的品质等级，将指定的属性修改器应用到武器上。
-- CreateQualityKillicon (内部函数) 为一个经过品质改良的武器创建一个新的、带有颜色的击杀图标。
-- GM:CreateWeaponOfQuality 根据品质等级和分支，生成一个具有修改后属性的全新武器实体。
-- GM:CreateWeaponQualities 在游戏启动时遍历所有符合条件的武器，并创建它们所有可能的品质和分支变体。
-- GM:GetWeaponClassOfQuality 为一个特定品质和分支的武器生成唯一的类名字符串。
-- GM:GetDismantleScrap 计算分解一件武器时返还的废料数量。
-- GM:GetUpgradeScrap 计算升级一件武器所需的废料成本。
-- GM:PointsToScrap 将点数（points）转换为等值的废料（scrap）数量。
GM.WeaponQualityModifiers = {}
GM.WeaponQualities = {
    {translate.Get("weapon_quality_sturdy"), 1.09, translate.Get("weapon_quality_tuned")},
    {translate.Get("weapon_quality_honed"), 1.19, translate.Get("weapon_quality_modified")},
    {translate.Get("weapon_quality_perfected"), 1.35, translate.Get("weapon_quality_reformed")}
}

GM.WeaponQualityColors = {
	{Color(235, 235, 115), Color(172, 219, 105)},
	{Color(50, 90, 175), Color(35, 110, 145)},
	{Color(160, 95, 235), Color(252, 100, 100)}
}

WEAPON_MODIFIER_MIN_SPREAD = 1
WEAPON_MODIFIER_MAX_SPREAD = 2
WEAPON_MODIFIER_FIRE_DELAY = 3 -- Rounds up based on tick rate.
WEAPON_MODIFIER_RELOAD_SPEED = 4
WEAPON_MODIFIER_CLIP_SIZE = 5
WEAPON_MODIFIER_MELEE_RANGE = 6
WEAPON_MODIFIER_MELEE_SIZE = 7
WEAPON_MODIFIER_MELEE_IMPACT_DELAY = 8
WEAPON_MODIFIER_PROJECTILE_VELOCITY = 9
WEAPON_MODIFIER_SHORT_TEAM_HEAT = 10
WEAPON_MODIFIER_SHOT_COUNT = 11
WEAPON_MODIFIER_BULLET_PIERCES = 12
WEAPON_MODIFIER_MAXIMUM_MINES = 13
WEAPON_MODIFIER_MAX_DISTANCE = 14
WEAPON_MODIFIER_AURA_RADIUS = 15
WEAPON_MODIFIER_RECOIL = 16
WEAPON_MODIFIER_DAMAGE = 17
WEAPON_MODIFIER_HEALRANGE = 18
WEAPON_MODIFIER_HEALCOOLDOWN = 19
WEAPON_MODIFIER_BUFF_DURATION = 20
WEAPON_MODIFIER_LEG_DAMAGE = 21
WEAPON_MODIFIER_REPAIR = 22
WEAPON_MODIFIER_TURRET_SPREAD = 23
WEAPON_MODIFIER_HEALING = 24
WEAPON_MODIFIER_HEADSHOT_MULTI = 25
WEAPON_MODIFIER_MELEE_KNOCK = 26

local index = 1
function GM:AddWeaponQualityModifier(id, name, displayraw, vartable)
	local datatab = {Name = name, DisplayRaw = displayraw, VarTable = vartable}
	self.WeaponQualityModifiers[id] = datatab

	index = index + 1

	return datatab
end

function GM:SetPrimaryWeaponModifier(swep, modifier, amount)
	swep.PrimaryRemantleModifier = {Modifier = modifier, Amount = amount}
end

function GM:AttachWeaponModifier(swep, modifier, amount, qualitystart)
	if not swep.AltRemantleModifiers then swep.AltRemantleModifiers = {} end

	local datatab = {Amount = amount, QualityStart = qualitystart or 2}
	swep.AltRemantleModifiers[modifier] = datatab
end

function GM:AddNewRemantleBranch(swep, no, printname, desc, branchfunc)
	if not swep.Branches then swep.Branches = {} end

	local datatab = {PrintName = printname, Desc = desc, BranchFunc = branchfunc}
	swep.Branches[no] = datatab

	return datatab
end

GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MIN_SPREAD, translate.Get("weapon_quality_modifier_min_spread"), false, {ConeMin = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MAX_SPREAD, translate.Get("weapon_quality_modifier_max_spread"), false, {ConeMax = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_FIRE_DELAY, translate.Get("weapon_quality_modifier_fire_delay"), false, {Delay = true})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_RELOAD_SPEED, translate.Get("weapon_quality_modifier_reload_speed"), false, {ReloadSpeed = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_CLIP_SIZE, translate.Get("weapon_quality_modifier_clip_size"), true, {ClipSize = true}).ReqClip = true
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_RANGE, translate.Get("weapon_quality_modifier_melee_range"), false, {MeleeRange = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_SIZE, translate.Get("weapon_quality_modifier_melee_size"), false, {MeleeSize = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_IMPACT_DELAY, translate.Get("weapon_quality_modifier_melee_impact_delay"), false, {SwingTime = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_PROJECTILE_VELOCITY, translate.Get("weapon_quality_modifier_projectile_velocity"), false, {ProjVelocity = true})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_SHORT_TEAM_HEAT, translate.Get("weapon_quality_modifier_short_team_heat"), false, {HeatBuildShort = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_SHOT_COUNT, translate.Get("weapon_quality_modifier_shot_count"), true, {NumShots = true})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_BULLET_PIERCES, translate.Get("weapon_quality_modifier_bullet_pierces"), true, {Pierces = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MAXIMUM_MINES, translate.Get("weapon_quality_modifier_maximum_mines"), true, {MaxMines = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MAX_DISTANCE, translate.Get("weapon_quality_modifier_max_distance"), false, {MaxDistance = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_AURA_RADIUS, translate.Get("weapon_quality_modifier_aura_radius"), false, {AuraRange = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_RECOIL, translate.Get("weapon_quality_modifier_recoil"), false, {Recoil = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_DAMAGE, translate.Get("weapon_quality_modifier_damage"), false, {Damage = true, MeleeDamage = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEALRANGE, translate.Get("weapon_quality_modifier_healrange"), false, {HealRange = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEALCOOLDOWN, translate.Get("weapon_quality_modifier_healcooldown"), false, {Delay = true})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_BUFF_DURATION, translate.Get("weapon_quality_modifier_buff_duration"), false, {BuffDuration = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_LEG_DAMAGE, translate.Get("weapon_quality_modifier_leg_damage"), false, {LegDamage = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_REPAIR, translate.Get("weapon_quality_modifier_repair"), false, {Repair = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_TURRET_SPREAD, translate.Get("weapon_quality_modifier_turret_spread"), false, {TurretSpread = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEALING, translate.Get("weapon_quality_modifier_healing"), false, {Heal = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_HEADSHOT_MULTI, translate.Get("weapon_quality_modifier_headshot_multi"), false, {HeadshotMulti = false})
GM:AddWeaponQualityModifier(WEAPON_MODIFIER_MELEE_KNOCK, translate.Get("weapon_quality_modifier_melee_knock"), false, {MeleeKnockBack = false})


local function ApplyWeaponModifier(modinfo, wept, datatab, remantledescs, i)
	local displayed = false
	local mtbl, basestat, newstat, qfactor

	for var, isprimary in pairs(modinfo.VarTable) do
		mtbl = isprimary and wept.Primary or wept
		if mtbl[var] then
			qfactor = i - (datatab.QualityStart - 1)
			basestat = mtbl[var]
			newstat = basestat + datatab.Amount * qfactor

			mtbl[var] = newstat

			if not displayed and qfactor > 0 then
				local ispos = datatab.Amount > 0 and "+" or ""
				local statincdesc = not modinfo.DisplayRaw and (((math.Round(newstat/basestat, 2)-1) * 100).. "% ")
					or ((datatab.Amount * qfactor / (modinfo.ReqClip and wept.RequiredClip or 1)).. " ")

				table.insert(remantledescs, ispos .. statincdesc .. modinfo.Name)
				displayed = true
			end
		end
	end
end

local function CreateQualityKillicon(oldc, newc, i, b, cols)
	local kitbl = killicon.Get(oldc)
	if kitbl then
		local kifunc = #kitbl == 2 and killicon.Add or killicon.AddFont
		local nkitbl = table.Copy(kitbl)
		nkitbl[#kitbl] = cols and cols[i] or GAMEMODE.WeaponQualityColors[i][b and b+1 or 1]
		kifunc(newc, unpack(nkitbl))
	end
end

function GM:CreateWeaponOfQuality(i, orig, quality, classname, branch)
	orig.RemantleDescs[branch and branch.No or 0][i] = {}
	-- Doing it with a full copy prevents crash issues on scoped weapons.
	-- TODO: Refactor me to not use the full weapon class once all self.BaseClass calls have been removed

	local wept = weapons.Get(classname)
	local remantledescs = orig.RemantleDescs[branch and branch.No or 0][i]

	wept.BaseQuality = classname
	wept.QualityTier = i
	wept.Branch = branch and branch.No

	if wept.PrintName then
		wept.PrintName = (branch and branch.NewNames and branch.NewNames[i] or branch and quality[3] or quality[1]).." "..(branch and branch.PrintName or wept.PrintName)
	end

	if wept.PrimaryRemantleModifier then
		local primod = wept.PrimaryRemantleModifier

		ApplyWeaponModifier(self.WeaponQualityModifiers[primod.Modifier], wept, {Amount = primod.Amount, QualityStart = 1}, remantledescs, i)
	else
		if wept.Primary and wept.Primary.Damage then
			wept.Primary.Damage = wept.Primary.Damage * quality[2]
		end
		if wept.MeleeDamage then
			wept.MeleeDamage = wept.MeleeDamage * quality[2]
		end

		table.insert(remantledescs, "+" .. ((quality[2]-1) * 100) .. "% " .. "Damage")
	end
	if wept.AltRemantleModifiers then
		for modifier, datatab in pairs(wept.AltRemantleModifiers) do
			if modifier == "BaseClass" then continue end -- ???

			ApplyWeaponModifier(self.WeaponQualityModifiers[modifier], wept, datatab, remantledescs, i)
		end
	end

	if branch and branch.BranchFunc then
		table.insert(remantledescs, 1, branch.Desc)
		branch.BranchFunc(wept)
	end

	local newclass = self:GetWeaponClassOfQuality(classname, i, branch and branch.No)
	if CLIENT then
		CreateQualityKillicon(branch and branch.Killicon or classname, newclass, i, branch and branch.No, branch and branch.Colors)
	end

	local regscriptent = function(class, cbk, prefix)
		local newent = self:GetWeaponClassOfQuality(class, i)
		local afent = scripted_ents.Get((prefix or "") .. class)
		if cbk then cbk(afent, newent) end

		afent.ClassName = nil
		scripted_ents.Register(afent, (prefix or "") .. newent)
		return newent
	end

	if wept.DeployClass then
		wept.DeployClass = regscriptent(wept.DeployClass, function(ent, newcl)
			if CLIENT then
				CreateQualityKillicon(wept.DeployClass, newcl, i)
			end

			if self.DeployableInfo[wept.DeployClass] then
				self:AddDeployableInfo(newcl, quality[1].." "..self.DeployableInfo[wept.DeployClass].Name, "")
			end
		end)

		if wept.AmmoIfHas then
			local newammo = self:GetWeaponClassOfQuality(wept.Primary.Ammo, i)

			game.AddAmmoType({name = newammo})
			wept.Primary.Ammo = newammo
		end

		if wept.Channel then
			table.insert(self.ChannelsToClass[wept.Channel], wept.DeployClass)
		end
	end

	if wept.GhostStatus then wept.GhostStatus = regscriptent(wept.GhostStatus, function(ent)
		if ent.GhostEntityWildCard then
			ent.GhostEntityWildCard = ent.GhostEntity
		end

		local ghostent = self:GetWeaponClassOfQuality(ent.GhostEntity, i)
		ent.GhostEntity = ghostent
		ent.GhostWeapon = newclass
	end, "status_") end

	wept.ClassName = nil
	weapons.Register(wept, newclass)
end

function GM:CreateWeaponQualities()
	local allweapons = weapons.GetList()
	local classname

	for _, t in ipairs(allweapons) do
		classname = t.ClassName

		if string.sub(classname, 1, 14) == "weapon_zs_base" then
			continue
		end

		local wept = weapons.Get(classname)
		if wept and wept.AllowQualityWeapons then
			local orig = weapons.GetStored(classname)
			orig.RemantleDescs = {}
			orig.RemantleDescs[0] = {}

			if orig.Branches then
				for no, _ in pairs(orig.Branches) do
					orig.RemantleDescs[no] = {}
				end
			end

			for i, quality in ipairs(self.WeaponQualities) do
				self:CreateWeaponOfQuality(i, orig, quality, classname)

				if orig.Branches then
					for no, tbl in pairs(orig.Branches) do
						local ntbl = table.Copy(tbl)
						ntbl.No = no

						self:CreateWeaponOfQuality(i, orig, quality, classname, ntbl)
					end
				end
			end
		end
	end
end

function GM:GetWeaponClassOfQuality(classname, quality, branch)
	return classname.."_"..string.char(113 + (branch or 0))..quality
end

function GM:GetDismantleScrap(wtbl, invitem)
	local itier = wtbl.Tier
	local quatier = wtbl.QualityTier

	local dismantlediv = invitem and 2 or 1
	local baseval = invitem and GAMEMODE.ScrapValsTrinkets[itier or 1] or GAMEMODE.ScrapVals[itier or 1]

	local qu = (quatier or 0) + 1
	local basicvalue = baseval * GAMEMODE.DismantleMultipliers[qu] - ((quatier or itier) and 0 or 1)

	return math.floor((basicvalue * (wtbl.IsMelee and 0.75 or 1)) / (wtbl.DismantleDiv or dismantlediv))
end

function GM:GetUpgradeScrap(wtbl, qualitychoice)
	local itier = wtbl.Tier

	return math.ceil(self.ScrapVals[itier or 1] * qualitychoice * (wtbl.IsMelee and 0.85 or 1))
end

function GM:PointsToScrap(points)
	return points / (70 / 32)
end
