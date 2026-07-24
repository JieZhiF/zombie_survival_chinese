-- ============================================================
-- cl_options.lua - 客户端配置与控制台变量（ConVar）
-- 定义游戏客户端的所有可配置选项、默认值、回调函数以及
-- 各种 UI 显示所需的数据表（图标、颜色、文本映射等）。
-- 这些 ConVar 以 "zs_" 为前缀，部分以 "zsw_" 为前缀。
-- ============================================================

-- 默认的人类/僵尸BGM（背景音乐）设置名称
GM.BeatSetHumanDefault = "defaulthuman"
GM.BeatSetZombieDefault = "defaultzombiev2"

-- 不同物品类别在UI中对应的图标路径
GM.ItemCategoryIcons = {
	[ITEMCAT_GUNS] = "icon16/gun.png",
	[ITEMCAT_AMMO] = "icon16/box.png",
	[ITEMCAT_MELEE] = "icon16/cog.png",
	[ITEMCAT_TOOLS] = "icon16/wrench.png",
	[ITEMCAT_DEPLOYABLES] = "icon16/package.png",
	[ITEMCAT_OTHER] = "icon16/world.png",
	[ITEMCAT_TRINKETS] = "icon16/ruby.png",
	--[ITEMCAT_RETURNS] = "icon16/user_delete.png"
}

-- 转生等级（Remort Level）对应的显示颜色映射表
-- 键：转生等级  值：颜色值（等级越高序号越小）
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

-- 内部速度值到可读文本描述的映射表（用于UI显示移动速度）
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

-- 弹药类型名到商店购买名的映射表（用于UI显示和购买操作）
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

-- 武器统计信息的UI显示配置表
-- 每项：{内部键名, 翻译文本, 最小值, 最大值, 是否反比显示, (可选)子分类}
GM.WeaponStatBarVals = {
    -- 近战属性
    {"MeleeDamage", translate.Get("option_weapon_MeleeDamage"), 2, 140, false},
    {"MeleeRange", translate.Get("option_weapon_MeleeRange"), 30, 100, false},
    {"MeleeSize", translate.Get("option_weapon_MeleeSize"), 0.2, 3, false},
    -- 主武器基础属性
    {"Damage", translate.Get("option_weapon_Damage"), 1, 105, false, "Primary"},
    {"Delay", translate.Get("option_weapon_AttackDelay"), 0.05, 2, true, "Primary"},
    {"ClipSize", translate.Get("option_weapon_ClipSize"), 1, 35, false, "Primary"},
    -- 精度与机动性
    {"ConeMin", translate.Get("option_weapon_MinSpread"), 0, 5, true},
    {"ConeMax", translate.Get("option_weapon_MaxSpread"), 1.5, 7, true},
    {"WalkSpeed", translate.Get("option_weapon_MoveSpeed"), 200, 250, false}
}

-- 当局统计数据（LifeStats）在屏幕上显示的持续时间（秒）
GM.LifeStatsLifeTime = 5

-- 奖励物品图标缓存表（模型路径）
GM.RewardIcons = {}
GM.RewardIcons["weapon_zs_barricadekit"] = "models/props_debris/wood_board05a.mdl"

-- ============================================================
-- 准星颜色（主色和次要色）
-- 每个颜色分量对应一个独立的 ConVar，并注册回调即时更新
-- ============================================================
GM.CrosshairColor = Color(CreateClientConVar("zs_crosshair_colr", "255", true, false):GetInt(), CreateClientConVar("zs_crosshair_colg", "255", true, false):GetInt(), CreateClientConVar("zs_crosshair_colb", "255", true, false):GetInt(), CreateClientConVar("zs_crosshair_cola", "220", true, false):GetInt())
GM.CrosshairColor2 = Color(CreateClientConVar("zs_crosshair_colr2", "220", true, false):GetInt(), CreateClientConVar("zs_crosshair_colg2", "0", true, false):GetInt(), CreateClientConVar("zs_crosshair_colb2", "0", true, false):GetInt(), CreateClientConVar("zs_crosshair_cola2", "220", true, false):GetInt())
-- 准星主色各分量值变化回调
cvars.AddChangeCallback("zs_crosshair_colr", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.r = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colg", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.g = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colb", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.b = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_cola", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor.a = tonumber(newvalue) or 255 end)
-- 准星次要色各分量值变化回调
cvars.AddChangeCallback("zs_crosshair_colr2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.r = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colg2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.g = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_colb2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.b = tonumber(newvalue) or 255 end)
cvars.AddChangeCallback("zs_crosshair_cola2", function(cvar, oldvalue, newvalue) GAMEMODE.CrosshairColor2.a = tonumber(newvalue) or 255 end)

-- 电影模式开关（隐藏HUD），启用时触发 EvaluateFilmMode 回调
GM.FilmMode = CreateClientConVar("zs_filmmode", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_filmmode", function(cvar, oldvalue, newvalue)
	GAMEMODE.FilmMode = tonumber(newvalue) == 1

	gamemode.Call("EvaluateFilmMode")
end)

-- 玩家自动行为偏好：不兑换 / 总是当志愿者 / 不选Boss / 不使用提交 / 不捡道具
CreateClientConVar("zs_noredeem", "0", true, true)
CreateClientConVar("zs_alwaysvolunteer", "0", true, true)
CreateClientConVar("zs_nobosspick", "0", true, true)
CreateClientConVar("zs_nousetodeposit", "0", true, true)
CreateClientConVar("zs_nopickupprops", "0", true, true)

-- 禁用武器瞄准镜功能
GM.DisableScopes = CreateClientConVar("zs_disablescopes", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_disablescopes", function(cvar, oldvalue, newvalue)
	GAMEMODE.DisableScopes = tonumber(newvalue) == 1
end)

-- 一键解锁功能开关
GM.OneClickUnlock = CreateClientConVar("zs_one_click_unlock", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_one_click_unlock", function(cvar, oldvalue, newvalue)
	GAMEMODE.OneClickUnlock = tonumber(newvalue) == 1
end)

-- 机械瞄准（Ironsight）时的缩放比例（0~1）
GM.IronsightZoomScale = math.Clamp(CreateClientConVar("zs_ironsightzoom", 1, true, false):GetFloat(), 0, 1)
cvars.AddChangeCallback("zs_ironsightzoom", function(cvar, oldvalue, newvalue)
	GAMEMODE.IronsightZoomScale = math.Clamp(tonumber(newvalue) or 1, 0, 1)
end)

-- 被击倒时是否切换到第三人称视角
GM.ThirdPersonKnockdown = CreateClientConVar("zs_thirdpersonknockdown", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_thirdpersonknockdown", function(cvar, oldvalue, newvalue)
	GAMEMODE.ThirdPersonKnockdown = tonumber(newvalue) == 1
end)

-- 更换职业时是否自动自杀
GM.SuicideOnChangeClass = CreateClientConVar("zs_suicideonchange", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_suicideonchange", function(cvar, oldvalue, newvalue)
	GAMEMODE.SuicideOnChangeClass = tonumber(newvalue) == 1
end)

-- BGM（背景音乐）总开关
GM.BeatsEnabled = CreateClientConVar("zs_beats", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_beats", function(cvar, oldvalue, newvalue)
	GAMEMODE.BeatsEnabled = tonumber(newvalue) == 1
end)

-- 伤害数字是否穿墙显示
GM.DamageNumberThroughWalls = CreateClientConVar("zs_damagefloaterswalls", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_damagefloaterswalls", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberThroughWalls = tonumber(newvalue) == 1
end)

-- BGM 音量（0~100 映射到 0.0~1.0）
GM.BeatsVolume = math.Clamp(CreateClientConVar("zs_beatsvolume", 80, true, false):GetInt(), 0, 100) / 100
cvars.AddChangeCallback("zs_beatsvolume", function(cvar, oldvalue, newvalue)
	GAMEMODE.BeatsVolume = math.Clamp(tonumber(newvalue) or 0, 0, 100) / 100
end)

-- 准星线条数量（2~8条）
GM.CrosshairLines = math.Clamp(CreateClientConVar("zs_crosshairlines", 4, true, false):GetInt(), 2, 8)
cvars.AddChangeCallback("zs_crosshairlines", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairLines = math.Clamp(tonumber(newvalue) or 4, 2, 8)
end)

-- 准星偏移量（线条末端与中心的距离，0~90像素）
GM.CrosshairOffset = math.Clamp(CreateClientConVar("zs_crosshairoffset", 0, true, false):GetInt(), 0, 90)
cvars.AddChangeCallback("zs_crosshairoffset", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairOffset = math.Clamp(tonumber(newvalue) or 0, 0, 90)
end)

-- 准星线条粗细（0.5~2像素）
GM.CrosshairThickness = math.Clamp(CreateClientConVar("zs_crosshairthickness", 1, true, false):GetFloat(), 0.5, 2)
cvars.AddChangeCallback("zs_crosshairthickness", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairThickness = math.Clamp(tonumber(newvalue) or 1, 0.5, 2)
end)

-- 拖拽道具时的旋转灵敏度（0.1~4）
GM.PropRotationSensitivity = math.Clamp(CreateClientConVar("zs_proprotationsens", 1, true, false):GetFloat(), 0.1, 4)
cvars.AddChangeCallback("zs_proprotationsens", function(cvar, oldvalue, newvalue)
	GAMEMODE.PropRotationSensitivity = math.Clamp(tonumber(newvalue) or 1, 0.1, 4)
end)

-- 拖拽道具时的旋转吸附角度（0~45度，0=无吸附）
GM.PropRotationSnap = math.Clamp(CreateClientConVar("zs_proprotationsnap", 0, true, false):GetInt(), 0, 45)
cvars.AddChangeCallback("zs_proprotationsnap", function(cvar, oldvalue, newvalue)
	GAMEMODE.PropRotationSnap = math.Clamp(tonumber(newvalue) or 0, 0, 45)
end)

-- 伤害数字大小缩放（0.5~2倍）
GM.DamageNumberScale = math.Clamp(CreateClientConVar("zs_dmgnumberscale", 1, true, false):GetFloat(), 0.5, 2)
cvars.AddChangeCallback("zs_dmgnumberscale", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberScale = math.Clamp(tonumber(newvalue) or 1, 0.5, 2)
end)

-- 伤害数字移动速度（0~1）
GM.DamageNumberSpeed = math.Clamp(CreateClientConVar("zs_dmgnumberspeed", 1, true, false):GetFloat(), 0, 1)
cvars.AddChangeCallback("zs_dmgnumberspeed", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberSpeed = math.Clamp(tonumber(newvalue) or 1, 0, 1)
end)

-- 伤害数字显示寿命（0.2~1.5秒）
GM.DamageNumberLifetime = math.Clamp(CreateClientConVar("zs_dmgnumberlife", 1, true, false):GetFloat(), 0.2, 1.5)
cvars.AddChangeCallback("zs_dmgnumberlife", function(cvar, oldvalue, newvalue)
	GAMEMODE.DamageNumberLifetime = math.Clamp(tonumber(newvalue) or 1, 0.2, 1.5)
end)

-- UI界面整体大小比例（0.7~1.5倍）
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

-- 是否总是显示钉子数量
GM.AlwaysShowNails = CreateClientConVar("zs_alwaysshownails", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_alwaysshownails", function(cvar, oldvalue, newvalue)
	GAMEMODE.AlwaysShowNails = tonumber(newvalue) == 1
end)

-- 是否总是使用快速购买（无需长按）
GM.AlwaysQuickBuy = CreateClientConVar("zs_alwaysquickbuy", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_alwaysquickbuy", function(cvar, oldvalue, newvalue)
	GAMEMODE.AlwaysQuickBuy = tonumber(newvalue) == 1
end)

-- 禁用机械瞄准功能
GM.NoIronsights = CreateClientConVar("zs_noironsights", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_noironsights", function(cvar, oldvalue, newvalue)
	GAMEMODE.NoIronsights = tonumber(newvalue) == 1
end)

-- 禁用准星旋转（默认禁用）
GM.NoCrosshairRotate = CreateClientConVar("zs_nocrosshairrotate", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_nocrosshairrotate", function(cvar, oldvalue, newvalue)
	GAMEMODE.NoCrosshairRotate = tonumber(newvalue) == 1
end)
-- 准星圆圈效果开关（无回调，仅作为存储）
CreateClientConVar("zs_crosshair_cicrle", "1", true, false)

-- 隐藏玩家第一人称手臂和武器模型
GM.HideViewModels = CreateClientConVar("zs_hideviewmodels", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_hideviewmodels", function(cvar, oldvalue, newvalue)
	GAMEMODE.HideViewModels = tonumber(newvalue) == 1
end)

-- 玩家透明效果相关：最大半径和当前半径
GM.TransparencyRadiusMax = 8192
GM.TransparencyRadius = 0

-- 第一人称视角下玩家模型的透明半径（平方值）
GM.TransparencyRadius1p = math.Clamp(CreateClientConVar("zs_transparencyradius", 140, true, false):GetInt(), 0, GM.TransparencyRadiusMax) ^ 2
cvars.AddChangeCallback("zs_transparencyradius", function(cvar, oldvalue, newvalue)
	GAMEMODE.TransparencyRadius1p = math.Clamp(tonumber(newvalue) or 0, 0, GAMEMODE.TransparencyRadiusMax) ^ 2
end)

-- 第三人称视角下玩家模型的透明半径（平方值）
GM.TransparencyRadius3p = math.Clamp(CreateClientConVar("zs_transparencyradius3p", 140, true, false):GetInt(), 0, GM.TransparencyRadiusMax) ^ 2
cvars.AddChangeCallback("zs_transparencyradius3p", function(cvar, oldvalue, newvalue)
	GAMEMODE.TransparencyRadius3p = math.Clamp(tonumber(newvalue) or 0, 0, GAMEMODE.TransparencyRadiusMax) ^ 2
end)

-- 启用或禁用移动时的视角倾斜效果
GM.MovementViewRoll = CreateClientConVar("zs_movementviewroll", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_movementviewroll", function(cvar, oldvalue, newvalue)
	GAMEMODE.MovementViewRoll = tonumber(newvalue) == 1
end)

-- 是否显示信息信标（消息标记）
GM.MessageBeaconShow = CreateClientConVar("zs_messagebeaconshow", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_messagebeaconshow", function(cvar, oldvalue, newvalue)
	GAMEMODE.MessageBeaconShow = tonumber(newvalue) == 1
end)

-- 武器HUD显示模式（整数值）
GM.WeaponHUDMode = CreateClientConVar("zs_weaponhudmode", "2", true, false):GetInt()
cvars.AddChangeCallback("zs_weaponhudmode", function(cvar, oldvalue, newvalue)
	GAMEMODE.WeaponHUDMode = tonumber(newvalue) or 0
end)

-- 目标生命值显示方式（整数值）
GM.HealthTargetDisplay = CreateClientConVar("zs_healthtargetdisplay", "0", true, false):GetInt()
cvars.AddChangeCallback("zs_healthtargetdisplay", function(cvar, oldvalue, newvalue)
	GAMEMODE.HealthTargetDisplay = tonumber(newvalue) or 0
end)

-- 受伤时是否显示疼痛闪光效果
GM.DrawPainFlash = CreateClientConVar("zs_drawpainflash", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_drawpainflash", function(cvar, oldvalue, newvalue)
	GAMEMODE.DrawPainFlash = tonumber(newvalue) == 1
end)

-- 是否显示经验值HUD
GM.DisplayXPHUD = CreateClientConVar("zs_drawxp", "1", true, false):GetBool()
cvars.AddChangeCallback("zs_drawxp", function(cvar, oldvalue, newvalue)
	GAMEMODE.DisplayXPHUD = tonumber(newvalue) == 1
	gamemode.Call("EvaluateFilmMode")
end)

-- 启用或禁用字体特效（如文字模糊发光）
GM.FontEffects = CreateClientConVar("zs_fonteffects", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_fonteffects", function(cvar, oldvalue, newvalue)
	GAMEMODE.FontEffects = tonumber(newvalue) == 1
end)

-- 隐藏背包装饰
GM.HidePacks = CreateClientConVar("zs_hidepacks", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_hidepacks", function(cvar, oldvalue, newvalue)
	GAMEMODE.HidePacks = tonumber(newvalue) == 1
end)

-- 是否始终高亮显示好友
GM.AlwaysDrawFriend = CreateClientConVar("zs_showfriends", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_showfriends", function(cvar, oldvalue, newvalue)
	GAMEMODE.AlwaysDrawFriend = tonumber(newvalue) == 1
end)

-- GMod 内置的颜色控制 ConVar（用于自定义玩家与武器模型颜色）
CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )
CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )

-- 人类使用的 BGM 包名称（"default" 时使用默认值）
GM.BeatSetHuman = CreateClientConVar("zs_beatset_human", "default", true, false):GetString()
cvars.AddChangeCallback("zs_beatset_human", function(cvar, oldvalue, newvalue)
	newvalue = tostring(newvalue)
	if newvalue == "default" then
		GAMEMODE.BeatSetHuman = GAMEMODE.BeatSetHumanDefault
	else
		GAMEMODE.BeatSetHuman = newvalue
	end
end)
-- 若用户未自定义，则使用默认值
if GM.BeatSetHuman == "default" then
	GM.BeatSetHuman = GM.BeatSetHumanDefault
end

-- 僵尸使用的 BGM 包名称（"default" 时使用默认值）
GM.BeatSetZombie = CreateClientConVar("zs_beatset_zombie", "default", true, false):GetString()
cvars.AddChangeCallback("zs_beatset_zombie", function(cvar, oldvalue, newvalue)
	newvalue = tostring(newvalue)
	if newvalue == "default" then
		GAMEMODE.BeatSetZombie = GAMEMODE.BeatSetZombieDefault
	else
		GAMEMODE.BeatSetZombie = newvalue
	end
end)
-- 若用户未自定义，则使用默认值
if GM.BeatSetZombie == "default" then
	GM.BeatSetZombie = GM.BeatSetZombieDefault
end

-- 启用/禁用近战冷却条功能（zsw_ 前缀为额外插件选项）
CreateClientConVar("zsw_enable_cooldown", 1, true, false, "Enable or disable the melee cooldown feature")

-- 启用/禁用自定义 HUD
CreateClientConVar("zsw_enable_hud", 1, true, false, "Enable or disable the custom HUD")

-- 启用/禁用 RTS 风格 HUD
CreateClientConVar("zsw_enable_rts_hud", 1, true, false, "Enable or disable the RTS HUD")

-- 准星模式：0 = 经典，1 = 重制版
CreateClientConVar("zsw_crosshair_mode", 1, true, false, "Select the crosshair mode: 0 for Classic, 1 for Remastered")

-- 近战冷却条 - 主攻击（RMB）圆圈大小
CreateClientConVar("zsw_cooldown_primary_size", "2.0", true, false, "Cooldown Primary Attack (RMB) Circle Size")

-- 近战冷却条 - 副攻击（LMB）圆圈大小
CreateClientConVar("zsw_cooldown_secondary_size", "0.8", true, false, "Cooldown Secondary Attack (LMB) Circle Size")

-- 近战冷却条 - 第三攻击/格挡（RELOAD）圆圈大小
CreateClientConVar("zsw_cooldown_tertiary_size", "1.0", true, false, "Cooldown tertiary/block (RELOAD) Circle Size")

-- 字体选择：1=ZSM_Coolvetica(默认)，2=Remington Noiseless，3=Typenoksidi，4=Ghoulish Fright AOE
CreateClientConVar("zsw_font_choice", "1", true, false, "Choose the font to use: 1 = ZSM_Coolvetica (default), 2 = Remington Noiseless, 3 = Typenoksidi, 4 = Ghoulish Fright AOE")

-- 近战主攻击冷却圆圈大小的全局变量（读取ConVar并限制范围1~16）
CrosshairCoolPrimaryCircleSize = math.Clamp(GetConVar("zsw_cooldown_primary_size"):GetFloat(), 1, 16)
cvars.AddChangeCallback("zsw_cooldown_primary_size", function(cvar, old, new)
    CrosshairCoolPrimaryCircleSize = math.Clamp(tonumber(new), 1, 16)
end, "CrosshairPrimaryCooldown_cv")

-- 近战副攻击冷却圆圈大小的全局变量（读取ConVar并限制范围1~16）
CrosshairCoolSecondaryCircleSize = math.Clamp(GetConVar("zsw_cooldown_secondary_size"):GetFloat(), 1, 16)
cvars.AddChangeCallback("zsw_cooldown_secondary_size", function(cvar, old, new)
    CrosshairCoolSecondaryCircleSize = math.Clamp(tonumber(new), 1, 16)
end, "CrosshairSecondaryCooldown_cv")

-- 近战第三攻击/格挡冷却圆圈大小的全局变量（读取ConVar并限制范围1~16）
CrosshairCoolTertiaryCircleSize = math.Clamp(GetConVar("zsw_cooldown_tertiary_size"):GetFloat(), 1, 16)
cvars.AddChangeCallback("zsw_cooldown_tertiary_size", function(cvar, old, new)
    CrosshairCoolTertiaryCircleSize = math.Clamp(tonumber(new), 1, 16)
end, "CrosshairTertiaryCooldown_cv")

-- ============================================================
-- 武器插槽（Slot）自定义配置
-- 以下每个 ConVar 控制一类武器在武器选择轮盘中的插槽位置。
-- 值为 0 时隐藏该类别，1~6 对应武器槽 0~5（内部索引减1）。
-- 这些 ConVar 与 Sunrust 通用，方便跨模式兼容。
-- ============================================================

-- 突击步枪插槽位置
GM.WeaponSelectSlotAssaultRifles = math.Clamp(CreateClientConVar("zs_wepslot_assaultrifles", 3, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_assaultrifles", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotAssaultRifles = math.Clamp(tonumber(new_value) or 3, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotAssaultRifles
    -- 遍历所有已注册武器，更新属于该组的武器插槽值
    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_ASSAULT_RIFLE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                -- 插槽为0时设为-2（隐藏），否则设为 new_slot - 1（内部从0开始）
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- 步枪插槽位置
GM.WeaponSelectSlotRifles = math.Clamp(CreateClientConVar("zs_wepslot_rifles", 4, true, false):GetInt(), 0, 6)

cvars.AddChangeCallback("zs_wepslot_rifles", function(convar_name, old_value, new_value)
    GAMEMODE.WeaponSelectSlotRifles = math.Clamp(tonumber(new_value) or 4, 0, 6)
    local new_slot = GAMEMODE.WeaponSelectSlotRifles

    for _, wep_data in pairs(weapons.GetList()) do
        if wep_data.SlotGroup and wep_data.SlotGroup == WEPSELECT_RIFLE then
            local stored_wep = weapons.GetStored(wep_data.ClassName)
            if stored_wep then
                stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
            end
        end
    end
end)

-- 霰弹枪插槽位置
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

-- 冲锋枪插槽位置
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

-- 手枪插槽位置
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

-- 空手插槽位置
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

-- 近战武器插槽位置
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

-- 医疗包插槽位置
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

-- 饰品/小配件插槽位置
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

-- 食物插槽位置
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

-- 药水瓶/烧瓶插槽位置
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

-- 可部署物品插槽位置
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

-- 杂项工具插槽位置
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

-- 维修工具插槽位置
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

-- 医疗工具插槽位置
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

-- 消耗品-支援型插槽位置
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

-- 消耗品-进攻型插槽位置
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

-- 爆炸物插槽位置
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

-- 栓动步枪/弩插槽位置
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

-- 药剂插槽位置
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
