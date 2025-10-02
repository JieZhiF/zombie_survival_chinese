-- 本文件主要负责定义客户端的各种配置、设置和控制台变量（ConVar）。
-- 它包含了用于UI显示的查找表（如物品图标、颜色、文本翻译），并创建了大量允许玩家自定义游戏体验的客户端选项，例如准星、HUD、视觉效果和游戏性偏好。

-- GM.BeatSet...Default          定义默认的人类和僵尸BGM（背景音乐）设置
-- GM.ItemCategoryIcons          定义不同物品类别的图标路径
-- GM.RemortColors               定义不同转生等级对应的颜色
-- GM.SpeedToText                将内部速度值映射为可读的文本描述
-- GM.AmmoToPurchaseNames        将弹药类型映射到商店中对应的购买名称
-- GM.WeaponStatBarVals          定义武器统计信息在UI中的显示方式和范围
-- GM.LifeStatsLifeTime          设置当局统计数据显示的持续时间
-- GM.RewardIcons                定义奖励物品的模型路径
-- zs_crosshair_col* ConVars     控制准星的颜色
-- zs_filmmode ConVar            启用或禁用电影模式（隐藏HUD）
-- zs_noredeem, etc. ConVars     定义玩家的自动行为偏好（不兑换、总是当志愿者等）
-- zs_disablescopes ConVar       禁用武器瞄准镜
-- zs_one_click_unlock ConVar    启用或禁用一键解锁功能
-- zs_ironsightzoom ConVar       调整机械瞄准时的缩放比例
-- zs_thirdpersonknockdown ConVar 设置被击倒时是否切换到第三人称视角
-- zs_suicideonchange ConVar     设置更换职业时是否自动自杀
-- zs_beats* ConVars             控制游戏内BGM（背景音乐）的启用和音量
-- zs_damagefloaterswalls ConVar 设置伤害数字是否穿墙显示
-- zs_crosshair* ConVars         控制准星的样式（线条数、偏移、粗细、旋转）
-- zs_proprotation* ConVars      控制拖拽道具时的旋转灵敏度和吸附角度
-- zs_dmg* ConVars               控制伤害数字的大小、速度和生命周期
-- zs_interfacesize ConVar       调整游戏UI界面的整体大小
-- zs_alwaysshownails ConVar     设置是否总是显示钉子
-- zs_alwaysquickbuy ConVar      设置是否总是使用快速购买
-- zs_noironsights ConVar        禁用机械瞄准功能
-- zs_hideviewmodels ConVar      隐藏玩家的第一人称手臂和武器模型
-- zs_transparencyradius* ConVar 控制玩家模型在靠近时变透明的半径
-- zs_movementviewroll ConVar    启用或禁用移动时的视角倾斜效果
-- zs_messagebeaconshow ConVar   控制是否显示信息信标
-- zs_weaponhudmode ConVar       设置武器HUD的显示模式
-- zs_healthtargetdisplay ConVar 设置目标生命值的显示方式
-- zs_drawpainflash ConVar       控制受伤时是否显示疼痛闪光效果
-- zs_drawxp ConVar              控制是否显示经验值HUD
-- zs_fonteffects ConVar         启用或禁用字体特效
-- zs_hidepacks ConVar           隐藏背包装饰
-- zs_showfriends ConVar         设置是否总是高亮显示好友
-- cl_playercolor/weaponcolor    GMod内置ConVar，用于自定义模型颜色
-- zs_beatset_* ConVars          设置人类和僵尸使用的BGM（背景音乐）包
-- zsw_* ConVars                 一系列用于控制自定义HUD、准星模式和字体的开关
GM.BeatSetHumanDefault = "defaulthuman"
GM.BeatSetZombieDefault = "defaultzombiev2"

GM.ItemCategoryIcons = {
	[ITEMCAT_GUNS] = "icon16/gun.png",
	[ITEMCAT_AMMO] = "icon16/box.png",
	[ITEMCAT_MELEE] = "icon16/cog.png",
	[ITEMCAT_TOOLS] = "icon16/wrench.png",
	[ITEMCAT_DEPLOYABLES] = "icon16/package.png",
	[ITEMCAT_OTHER] = "icon16/world.png",
	[ITEMCAT_TRINKETS] = "icon16/ruby.png",
	[ITEMCAT_MUTATIONS] = "icon16/pill.png",--主要添加这个
	[ITEMCAT_MUTATIONS_BOSS] = "icon16/pill_add.png",--[[,
	[ITEMCAT_RETURNS] = "icon16/user_delete.png"]]
}

GM.RemortColors = {
	[9] = COLOR_TAN,
	[8] = COLOR_BROWN,
	[7] = COLOR_RPINK,
	[6] = COLOR_RPURPLE,
	[5] = COLOR_CYAN,
	[4] = COLOR_GREEN,
	[3] = COLOR_YELLOW,
	[2] = COLOR_RORANGE,
	[1] = COLOR_RED
}

GM.SpeedToText = {
    [SPEED_NORMAL] = translate.Get("option_speed_Normal"),
    [SPEED_SLOWEST] = translate.Get("option_speed_VerySlow"),
    [SPEED_SLOWER] = translate.Get("option_speed_QuiteSlow"),
    [SPEED_SLOW] = translate.Get("option_speed_Slow"),
    [SPEED_FAST] = translate.Get("option_speed_Fast"),
    [SPEED_FASTER] = translate.Get("option_speed_QuiteFast"),
    [SPEED_FASTEST] = translate.Get("option_speed_VeryFast"),
    [-1] = translate.Get("option_speed_UltraSlow"),
}


GM.AmmoToPurchaseNames = {
	["pistol"] = "pistolammo",
	["buckshot"] = "shotgunammo",
	["smg1"] = "smgammo",
	["ar2"] = "assaultrifleammo",
	["357"] = "rifleammo",
	["pulse"] = "pulseammo",
	["XBowBolt"] = "crossbowammo",
	["impactmine"] = "impactmine",
	["chemical"] = "chemical"
}

GM.WeaponStatBarVals = {
    {"MeleeDamage", translate.Get("option_weapon_MeleeDamage"), 2, 140, false},
    {"MeleeRange", translate.Get("option_weapon_MeleeRange"), 30, 100, false},
    {"MeleeSize", translate.Get("option_weapon_MeleeSize"), 0.2, 3, false},

    {"Damage", translate.Get("option_weapon_Damage"), 1, 105, false, "Primary"},
    {"Delay", translate.Get("option_weapon_AttackDelay"), 0.05, 2, true, "Primary"},
    {"ClipSize", translate.Get("option_weapon_ClipSize"), 1, 35, false, "Primary"},

    {"ConeMin", translate.Get("option_weapon_MinSpread"), 0, 5, true},
    {"ConeMax", translate.Get("option_weapon_MaxSpread"), 1.5, 7, true},
    {"WalkSpeed", translate.Get("option_weapon_MoveSpeed"), 200, 250, false}
}

GM.LifeStatsLifeTime = 5

GM.RewardIcons = {}
GM.RewardIcons["weapon_zs_barricadekit"] = "models/props_debris/wood_board05a.mdl"

GM.CrosshairColor = Color(CreateClientConVar("zs_crosshair_colr", "255", true, false):GetInt(), CreateClientConVar("zs_crosshair_colg", "255", true, false):GetInt(), CreateClientConVar("zs_crosshair_colb", "255", true, false):GetInt(), CreateClientConVar("zs_crosshair_cola", "220", true, false):GetInt())
GM.CrosshairColor2 = Color(CreateClientConVar("zs_crosshair_colr2", "220", true, false):GetInt(), CreateClientConVar("zs_crosshair_colg2", "0", true, false):GetInt(), CreateClientConVar("zs_crosshair_colb2", "0", true, false):GetInt(), CreateClientConVar("zs_crosshair_cola2", "220", true, false):GetInt())
cvars.AddChangeCallback("zs_crosshair_colr", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.r = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colg", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.g = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colb", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.b = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_cola", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.a = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colr2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.r = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colg2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.g = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colb2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.b = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_cola2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.a = tonumber(newvalue) or 255 end)

GM.FilmMode = CreateClientConVar("zs_filmmode", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_filmmode", function(cvar, oldvalue, newvalue)
	GAMEMODE.FilmMode = tonumber(newvalue) == 1

	gamemode.Call("EvaluateFilmMode")
end)

CreateClientConVar("zs_noredeem", "0", true, true)
CreateClientConVar("zs_alwaysvolunteer", "0", true, true)
CreateClientConVar("zs_nobosspick", "0", true, true)
CreateClientConVar("zs_nousetodeposit", "0", true, true)
CreateClientConVar("zs_nopickupprops", "0", true, true)

GM.DisableScopes = CreateClientConVar("zs_disablescopes", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_disablescopes", function(cvar, oldvalue, newvalue)
	GAMEMODE.DisableScopes = tonumber(newvalue) == 1
end)

GM.OneClickUnlock = CreateClientConVar("zs_one_click_unlock", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_one_click_unlock", function(cvar, oldvalue, newvalue)
	GAMEMODE.OneClickUnlock = tonumber(newvalue) == 1
end)

GM.IronsightZoomScale = math.Clamp(CreateClientConVar("zs_ironsightzoom", 1, true, false):GetFloat(), 0, 1)
cvars.AddChangeCallback("zs_ironsightzoom", function(cvar, oldvalue, newvalue)
	GAMEMODE.IronsightZoomScale = math.Clamp(tonumber(newvalue) or 1, 0, 1)
end)

GM.ThirdPersonKnockdown = CreateClientConVar("zs_thirdpersonknockdown", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_thirdpersonknockdown", function(cvar, oldvalue, newvalue)
	GAMEMODE.ThirdPersonKnockdown = tonumber(newvalue) == 1
end)

GM.SuicideOnChangeClass = CreateClientConVar("zs_suicideonchange", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_suicideonchange", function(cvar, oldvalue, newvalue)
	GAMEMODE.SuicideOnChangeClass = tonumber(newvalue) == 1
end)

GM.BeatsEnabled = CreateClientConVar("zs_beats", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_beats", function(cvar, oldvalue, newvalue)
	GAMEMODE.BeatsEnabled = tonumber(newvalue) == 1
end)

GM.DamageNumberThroughWalls = CreateClientConVar("zs_damagefloaterswalls", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_damagefloaterswalls", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberThroughWalls = tonumber(newvalue) == 1
end)

GM.BeatsVolume = math.Clamp(CreateClientConVar("zs_beatsvolume", 80, true, false):GetInt(), 0, 100) / 100
cvars.AddChangeCallback("zs_beatsvolume", function(cvar, oldvalue, newvalue)
	GAMEMODE.BeatsVolume = math.Clamp(tonumber(newvalue) or 0, 0, 100) / 100
end)

GM.CrosshairLines = math.Clamp(CreateClientConVar("zs_crosshairlines", 4, true, false):GetInt(), 2, 8)
cvars.AddChangeCallback("zs_crosshairlines", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairLines = math.Clamp(tonumber(newvalue) or 4, 2, 8)
end)

GM.CrosshairOffset = math.Clamp(CreateClientConVar("zs_crosshairoffset", 0, true, false):GetInt(), 0, 90)
cvars.AddChangeCallback("zs_crosshairoffset", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairOffset = math.Clamp(tonumber(newvalue) or 0, 0, 90)
end)

GM.CrosshairThickness = math.Clamp(CreateClientConVar("zs_crosshairthickness", 1, true, false):GetFloat(), 0.5, 2)
cvars.AddChangeCallback("zs_crosshairthickness", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairThickness = math.Clamp(tonumber(newvalue) or 1, 0.5, 2)
end)

GM.PropRotationSensitivity = math.Clamp(CreateClientConVar("zs_proprotationsens", 1, true, false):GetFloat(), 0.1, 4)
cvars.AddChangeCallback("zs_proprotationsens", function(cvar, oldvalue, newvalue)
	GAMEMODE.PropRotationSensitivity = math.Clamp(tonumber(newvalue) or 1, 0.1, 4)
end)

GM.PropRotationSnap = math.Clamp(CreateClientConVar("zs_proprotationsnap", 0, true, false):GetInt(), 0, 45)
cvars.AddChangeCallback("zs_proprotationsnap", function(cvar, oldvalue, newvalue)
	GAMEMODE.PropRotationSnap = math.Clamp(tonumber(newvalue) or 0, 0, 45)
end)

GM.DamageNumberScale = math.Clamp(CreateClientConVar("zs_dmgnumberscale", 1, true, false):GetFloat(), 0.5, 2)
cvars.AddChangeCallback("zs_dmgnumberscale", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberScale = math.Clamp(tonumber(newvalue) or 1, 0.5, 2)
end)

GM.DamageNumberSpeed = math.Clamp(CreateClientConVar("zs_dmgnumberspeed", 1, true, false):GetFloat(), 0, 1)
cvars.AddChangeCallback("zs_dmgnumberspeed", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberSpeed = math.Clamp(tonumber(newvalue) or 1, 0, 1)
end)

GM.DamageNumberLifetime = math.Clamp(CreateClientConVar("zs_dmgnumberlife", 1, true, false):GetFloat(), 0.2, 1.5)
cvars.AddChangeCallback("zs_dmgnumberlife", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberLifetime = math.Clamp(tonumber(newvalue) or 1, 0.2, 1.5)
end)

GM.InterfaceSize = math.Clamp(CreateClientConVar("zs_interfacesize", 1, true, false):GetFloat(), 0.7, 1.5)
cvars.AddChangeCallback("zs_interfacesize", function(cvar, oldvalue, newvalue)
	if not GAMEMODE.EmptyCachedFontHeights then return end --???

	GAMEMODE.InterfaceSize = math.Clamp(tonumber(newvalue) or 1, 0.7, 1.5)

	GAMEMODE:CreateScalingFonts()
	GAMEMODE:EmptyCachedFontHeights()

	local screenscale = BetterScreenScale()

	GAMEMODE.HealthHUD:InvalidateLayout()

	GAMEMODE.GameStatePanel:InvalidateLayout()
	GAMEMODE.GameStatePanel:SetSize(screenscale * 420, screenscale * 80)

	GAMEMODE.TopNotificationHUD:InvalidateLayout()
	GAMEMODE.CenterNotificationHUD:InvalidateLayout()
	GAMEMODE.XPHUD:InvalidateLayout()
	GAMEMODE.StatusHUD:InvalidateLayout()

	GAMEMODE.ArsenalInterface = nil

	GAMEMODE:ScoreboardRebuild()
end)

GM.AlwaysShowNails = CreateClientConVar("zs_alwaysshownails", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_alwaysshownails", function(cvar, oldvalue, newvalue)
	GAMEMODE.AlwaysShowNails = tonumber(newvalue) == 1
end)

GM.AlwaysQuickBuy = CreateClientConVar("zs_alwaysquickbuy", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_alwaysquickbuy", function(cvar, oldvalue, newvalue)
	GAMEMODE.AlwaysQuickBuy = tonumber(newvalue) == 1
end)

GM.NoIronsights = CreateClientConVar("zs_noironsights", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_noironsights", function(cvar, oldvalue, newvalue)
	GAMEMODE.NoIronsights = tonumber(newvalue) == 1
end)

GM.NoCrosshairRotate = CreateClientConVar("zs_nocrosshairrotate", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_nocrosshairrotate", function(cvar, oldvalue, newvalue)
	GAMEMODE.NoCrosshairRotate = tonumber(newvalue) == 1
end)
CreateClientConVar("zs_crosshair_cicrle", "1", true, false)

GM.HideViewModels = CreateClientConVar("zs_hideviewmodels", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_hideviewmodels", function(cvar, oldvalue, newvalue)
	GAMEMODE.HideViewModels = tonumber(newvalue) == 1
end)

GM.TransparencyRadiusMax = 8192
GM.TransparencyRadius = 0

GM.TransparencyRadius1p = math.Clamp(CreateClientConVar("zs_transparencyradius", 140, true, false):GetInt(), 0, GM.TransparencyRadiusMax) ^ 2
cvars.AddChangeCallback("zs_transparencyradius", function(cvar, oldvalue, newvalue)
	GAMEMODE.TransparencyRadius1p = math.Clamp(tonumber(newvalue) or 0, 0, GAMEMODE.TransparencyRadiusMax) ^ 2
end)

GM.TransparencyRadius3p = math.Clamp(CreateClientConVar("zs_transparencyradius3p", 140, true, false):GetInt(), 0, GM.TransparencyRadiusMax) ^ 2
cvars.AddChangeCallback("zs_transparencyradius3p", function(cvar, oldvalue, newvalue)
	GAMEMODE.TransparencyRadius3p = math.Clamp(tonumber(newvalue) or 0, 0, GAMEMODE.TransparencyRadiusMax) ^ 2
end)

GM.MovementViewRoll = CreateClientConVar("zs_movementviewroll", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_movementviewroll", function(cvar, oldvalue, newvalue)
	GAMEMODE.MovementViewRoll = tonumber(newvalue) == 1
end)

GM.MessageBeaconShow = CreateClientConVar("zs_messagebeaconshow", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_messagebeaconshow", function(cvar, oldvalue, newvalue)
	GAMEMODE.MessageBeaconShow = tonumber(newvalue) == 1
end)

GM.WeaponHUDMode = CreateClientConVar("zs_weaponhudmode", "2", true, false):GetInt()
cvars.AddChangeCallback("zs_weaponhudmode", function(cvar, oldvalue, newvalue)
	GAMEMODE.WeaponHUDMode = tonumber(newvalue) or 0
end)

GM.HealthTargetDisplay = CreateClientConVar("zs_healthtargetdisplay", "0", true, false):GetInt()
cvars.AddChangeCallback("zs_healthtargetdisplay", function(cvar, oldvalue, newvalue)
	GAMEMODE.HealthTargetDisplay = tonumber(newvalue) or 0
end)

GM.DrawPainFlash = CreateClientConVar("zs_drawpainflash", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_drawpainflash", function(cvar, oldvalue, newvalue)
	GAMEMODE.DrawPainFlash = tonumber(newvalue) == 1
end)

GM.DisplayXPHUD = CreateClientConVar("zs_drawxp", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_drawxp", function(cvar, oldvalue, newvalue)
	GAMEMODE.DisplayXPHUD = tonumber(newvalue) == 1
	gamemode.Call("EvaluateFilmMode")
end)

GM.FontEffects = CreateClientConVar("zs_fonteffects", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_fonteffects", function(cvar, oldvalue, newvalue)
	GAMEMODE.FontEffects = tonumber(newvalue) == 1
end)

GM.HidePacks = CreateClientConVar("zs_hidepacks", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_hidepacks", function(cvar, oldvalue, newvalue)
	GAMEMODE.HidePacks = tonumber(newvalue) == 1
end)

GM.AlwaysDrawFriend = CreateClientConVar("zs_showfriends", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_showfriends", function(cvar, oldvalue, newvalue)
	GAMEMODE.AlwaysDrawFriend = tonumber(newvalue) == 1
end)

CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )
CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )

GM.BeatSetHuman = CreateClientConVar("zs_beatset_human", "default", true, false):GetString()
cvars.AddChangeCallback("zs_beatset_human", function(cvar, oldvalue, newvalue)
	newvalue = tostring(newvalue)
	if newvalue == "default" then
		GAMEMODE.BeatSetHuman = GAMEMODE.BeatSetHumanDefault
	else
		GAMEMODE.BeatSetHuman = newvalue
	end
end)
if GM.BeatSetHuman == "default" then
	GM.BeatSetHuman = GM.BeatSetHumanDefault
end

GM.BeatSetZombie = CreateClientConVar("zs_beatset_zombie", "default", true, false):GetString()
cvars.AddChangeCallback("zs_beatset_zombie", function(cvar, oldvalue, newvalue)
	newvalue = tostring(newvalue)
	if newvalue == "default" then
		GAMEMODE.BeatSetZombie = GAMEMODE.BeatSetZombieDefault
	else
		GAMEMODE.BeatSetZombie = newvalue
	end
end)
if GM.BeatSetZombie == "default" then
	GM.BeatSetZombie = GM.BeatSetZombieDefault
end

-- Enable/Disable the melee cooldown feature
CreateClientConVar("zsw_enable_cooldown", 1, true, false, "Enable or disable the melee cooldown feature")

-- Enable/Disable the custom HUD
CreateClientConVar("zsw_enable_hud", 1, true, false, "Enable or disable the custom HUD")

-- Enable/Disable RTS Hud
CreateClientConVar("zsw_enable_rts_hud", 1, true, false, "Enable or disable the RTS HUD")

-- Crosshair mode: 0 = Classic, 1 = Remastered
CreateClientConVar("zsw_crosshair_mode", 1, true, false, "Select the crosshair mode: 0 for Classic, 1 for Remastered")

-- Define the client CVAR for font choice

-- Melee Cooldown Primary Size
CreateClientConVar("zsw_cooldown_primary_size", "2.0", true, false, "Cooldown Primary Attack (RMB) Circle Size")

-- Melee Cooldown Secondary Size
CreateClientConVar("zsw_cooldown_secondary_size", "0.8", true, false, "Cooldown Secondary Attack (LMB) Circle Size")

-- Melee Cooldown Tertiary Size
CreateClientConVar("zsw_cooldown_tertiary_size", "1.0", true, false, "Cooldown tertiary/block (RELOAD) Circle Size")


CreateClientConVar("zsw_font_choice", "1", true, false, "Choose the font to use: 1 = ZSM_Coolvetica (default), 2 = Remington Noiseless, 3 = Typenoksidi, 4 = Ghoulish Fright AOE")


CrosshairCoolPrimaryCircleSize = math.Clamp(GetConVar("zsw_cooldown_primary_size"):GetFloat(), 1, 16)
cvars.AddChangeCallback("zsw_cooldown_primary_size", function(cvar, old, new)
    CrosshairCoolPrimaryCircleSize = math.Clamp(tonumber(new), 1, 16)
end, "CrosshairPrimaryCooldown_cv")

CrosshairCoolSecondaryCircleSize = math.Clamp(GetConVar("zsw_cooldown_secondary_size"):GetFloat(), 1, 16)
cvars.AddChangeCallback("zsw_cooldown_secondary_size", function(cvar, old, new)
    CrosshairCoolSecondaryCircleSize = math.Clamp(tonumber(new), 1, 16)
end, "CrosshairSecondaryCooldown_cv")

CrosshairCoolTertiaryCircleSize = math.Clamp(GetConVar("zsw_cooldown_tertiary_size"):GetFloat(), 1, 16)
cvars.AddChangeCallback("zsw_cooldown_tertiary_size", function(cvar, old, new)
    CrosshairCoolTertiaryCircleSize = math.Clamp(tonumber(new), 1, 16)
end, "CrosshairTertiaryCooldown_cv")

-- =================================================================
--      客户端 ConVar 与武器组（SlotGroup）中文类别对应表
-- =================================================================
-- 本注释用于清晰地展示每个控制台变量（ConVar）所控制的武器类别。
-- 格式: ConVar -> 中文武器类别
--
-- ConVar: "zs_wepslot_unarmed"        -> 武器类别: 赤手空拳
-- ConVar: "zs_wepslot_melee"          -> 武器类别: 近战武器
-- ConVar: "zs_wepslot_repairtools"    -> 武器类别: 维修工具
--
-- ConVar: "zs_wepslot_pistols"        -> 武器类别: 手枪
--
-- ConVar: "zs_wepslot_smgs"           -> 武器类别: 冲锋枪
-- ConVar: "zs_wepslot_assaultrifles"  -> 武器类别: 突击步枪
--
-- ConVar: "zs_wepslot_rifles"         -> 武器类别: 步枪
-- ConVar: "zs_wepslot_shotguns"       -> 武器类别: 霰弹枪
-- ConVar: "zs_wepslot_bolt"           -> 武器类别: 栓动步枪/弩
-- ConVar: "zs_wepslot_medicaltools"   -> 武器类别: 医疗工具
--
-- ConVar: "zs_wepslot_medkits"        -> 武器类别: 医疗包
-- ConVar: "zs_wepslot_trinkets"       -> 武器类别: 饰品/小配件
-- ConVar: "zs_wepslot_flasks"         -> 武器类别: 药水瓶/烧瓶
-- ConVar: "zs_wepslot_deployables"    -> 武器类别: 可部署物品
-- ConVar: "zs_wepslot_misctools"      -> 武器类别: 杂项工具
-- ConVar: "zs_wepslot_conoffensive"   -> 武器类别: 消耗品-进攻型
-- ConVar: "zs_wepslot_explosives"     -> 武器类别: 爆炸物
--
-- ConVar: "zs_wepslot_food"           -> 武器类别: 食物
-- ConVar: "zs_wepslot_potions"        -> 武器类别: 药剂
-- ConVar: "zs_wepslot_consupportive"  -> 武器类别: 消耗品-支援型
-- 描述：这些变量是用的是sunrust同样的名字，因此可以通用（为了方便）
-- =================================================================

-- 1. 为突击步枪创建 ConVar 并设置初始插槽值。
--    该值被限制在 0 (隐藏) 到 6 (最大插槽) 之间。
GM.WeaponSelectSlotAssaultRifles = math.Clamp(CreateClientConVar("zs_wepslot_assaultrifles", 3, true, false):GetInt(), 0, 6)

-- 2. 添加一个回调函数，当 ConVar 的值改变时运行。
cvars.AddChangeCallback("zs_wepslot_assaultrifles", function(convar_name, old_value, new_value)
    -- 使用新的、被限制过的值更新全局变量。
    GAMEMODE.WeaponSelectSlotAssaultRifles = math.Clamp(tonumber(new_value) or 3, 0, 6)

    local new_slot = GAMEMODE.WeaponSelectSlotAssaultRifles

    -- 遍历所有已注册的武器，找到属于这个组的武器。
    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_ASSAULT_RIFLE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                -- 如果新插槽为 0，则隐藏武器 (-2)，否则设置为新插槽减 1 (因为插槽索引从0开始)。
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Rifles Slot
-- =================================================================

GM.WeaponSelectSlotRifles = math.Clamp(CreateClientConVar("zs_wepslot_rifles", 4, true, false):GetInt(), 0, 6)

-- 为步枪 ConVar 添加相应的回调。
cvars.AddChangeCallback("zs_wepslot_rifles", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotRifles = math.Clamp(tonumber(new_value) or 4, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotRifles

    for _, wep_data in pairs(weapons.GetList()) do
        -- 注意: 请确保你已经定义了 'WEPSELECT_RIFLE' 这个常量。
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_RIFLE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Shotguns Slot
-- =================================================================

GM.WeaponSelectSlotShotguns = math.Clamp(CreateClientConVar("zs_wepslot_shotguns", 4, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_shotguns", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotShotguns = math.Clamp(tonumber(new_value) or 4, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotShotguns

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_SHOTGUN then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- SMGs Slot
-- =================================================================

GM.WeaponSelectSlotSMGs = math.Clamp(CreateClientConVar("zs_wepslot_smgs", 3, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_smgs", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotSMGs = math.Clamp(tonumber(new_value) or 3, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotSMGs

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_SMG then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Pistols Slot
-- =================================================================

GM.WeaponSelectSlotPistols = math.Clamp(CreateClientConVar("zs_wepslot_pistols", 2, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_pistols", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotPistols = math.Clamp(tonumber(new_value) or 2, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotPistols

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_PISTOL then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Unarmed Slot
-- =================================================================

GM.WeaponSelectSlotUnarmed = math.Clamp(CreateClientConVar("zs_wepslot_unarmed", 1, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_unarmed", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotUnarmed = math.Clamp(tonumber(new_value) or 1, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotUnarmed

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_UNARMED then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Melee Slot
-- =================================================================

GM.WeaponSelectSlotMelee = math.Clamp(CreateClientConVar("zs_wepslot_melee", 1, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_melee", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotMelee = math.Clamp(tonumber(new_value) or 1, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotMelee

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_MELEE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Medkits Slot
-- =================================================================

GM.WeaponSelectSlotMedkits = math.Clamp(CreateClientConVar("zs_wepslot_medkits", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_medkits", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotMedkits = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotMedkits

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_MEDKIT then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Trinkets Slot
-- =================================================================

GM.WeaponSelectSlotTrinkets = math.Clamp(CreateClientConVar("zs_wepslot_trinkets", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_trinkets", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotTrinkets = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotTrinkets

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_TRINKET then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)


-- ... (为列表中的其余所有武器类别重复此模式) ...


-- 例如，为 "Food" 添加:
-- =================================================================
-- Food Slot
-- =================================================================

GM.WeaponSelectSlotFood = math.Clamp(CreateClientConVar("zs_wepslot_food", 6, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_food", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotFood = math.Clamp(tonumber(new_value) or 6, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotFood

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_FOOD then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Flasks Slot
-- =================================================================

GM.WeaponSelectSlotFlasks = math.Clamp(CreateClientConVar("zs_wepslot_flasks", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_flasks", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotFlasks = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotFlasks

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_FLASK then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Deployables Slot
-- =================================================================

GM.WeaponSelectSlotDeployables = math.Clamp(CreateClientConVar("zs_wepslot_deployables", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_deployables", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotDeployables = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotDeployables

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_DEPLOYABLE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Misc Tools Slot
-- =================================================================

GM.WeaponSelectSlotMiscTools = math.Clamp(CreateClientConVar("zs_wepslot_misctools", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_misctools", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotMiscTools = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotMiscTools

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_MISCTOOL then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Repair Tools Slot
-- =================================================================

GM.WeaponSelectSlotRepairTools = math.Clamp(CreateClientConVar("zs_wepslot_repairtools", 1, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_repairtools", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotRepairTools = math.Clamp(tonumber(new_value) or 1, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotRepairTools

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_REPAIRTOOL then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Medical Tools Slot
-- =================================================================

GM.WeaponSelectSlotMedicalTools = math.Clamp(CreateClientConVar("zs_wepslot_medicaltools", 4, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_medicaltools", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotMedicalTools = math.Clamp(tonumber(new_value) or 4, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotMedicalTools

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_MEDICALTOOL then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Consumable Supportive Slot
-- =================================================================

GM.WeaponSelectSlotConSupportive = math.Clamp(CreateClientConVar("zs_wepslot_consupportive", 6, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_consupportive", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotConSupportive = math.Clamp(tonumber(new_value) or 6, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotConSupportive

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_CONSUMABLE_SUPPORTIVE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Consumable Offensive Slot
-- =================================================================

GM.WeaponSelectSlotConOffensive = math.Clamp(CreateClientConVar("zs_wepslot_conoffensive", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_conoffensive", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotConOffensive = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotConOffensive

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_CONSUMABLE_OFFENSIVE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Explosives Slot
-- =================================================================

GM.WeaponSelectSlotExplosives = math.Clamp(CreateClientConVar("zs_wepslot_explosives", 5, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_explosives", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotExplosives = math.Clamp(tonumber(new_value) or 5, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotExplosives

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_EXPLOSIVE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Bolt-Action / Crossbow Slot
-- =================================================================

GM.WeaponSelectSlotBolt = math.Clamp(CreateClientConVar("zs_wepslot_bolt", 4, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_bolt", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotBolt = math.Clamp(tonumber(new_value) or 4, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotBolt

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_BOLT then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- =================================================================
-- Potions Slot
-- =================================================================

GM.WeaponSelectSlotPotions = math.Clamp(CreateClientConVar("zs_wepslot_potions", 6, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_potions", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotPotions = math.Clamp(tonumber(new_value) or 6, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotPotions

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_POTION then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)