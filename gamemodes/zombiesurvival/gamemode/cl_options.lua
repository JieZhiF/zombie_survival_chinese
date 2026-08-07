-- ============================================================
-- cl_options.lua - 客户端配置与控制台变量（ConVar）
-- 定义游戏客户端的所有可配置选项、默认值、回调函数以及
-- 各种 UI 显示所需的数据表（图标、颜色、文本映射等）。
-- 这些 ConVar 以 "zs_" 为前缀，部分以 "zsw_" 为前缀。
-- ============================================================

-- ============================================================
-- 客户端 ConVar 注册辅助：创建 ConVar、初始化 GM 字段、注册变更回调。
-- 用法：
--   RegisterClientConVar("zs_名称", "默认值", "GM字段名", "描述", "bool|int|float|string", [转换函数], [副作用回调])
-- 转换函数接收原始值（初始化时传入数字/布尔，回调时传入字符串），返回存入 GM 字段的值；
-- 副作用回调仅在 ConVar 被修改时触发（初始化不触发），保持与原代码行为一致。
-- ============================================================
local function RegisterClientConVar(name, default, field, desc, ctype, transform, onchange)
	local cvar = CreateClientConVar(name, default, true, false, desc)

	-- 捕获 gamemode 表引用：两端 GM/GAMEMODE 别名可用性不一致，取其一
	local gm = GM or GAMEMODE

	local function apply(value, notify)
		if transform then
			value = transform(value)
		elseif ctype == "bool" then
			value = value == true or (tonumber(value) or 0) == 1
		elseif ctype == "string" then
			value = tostring(value)
		else
			value = tonumber(value)
		end

		gm[field] = value

		if notify and onchange then
			onchange(value)
		end
	end

	if ctype == "string" then
		apply(cvar:GetString(), false)
	elseif ctype == "bool" then
		apply(cvar:GetBool(), false)
	elseif ctype == "int" then
		apply(cvar:GetInt(), false)
	else
		apply(cvar:GetFloat(), false)
	end

	cvars.AddChangeCallback(name, function(_, _, newvalue)
		apply(newvalue, true)
	end)
end

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
    -- 武器品质与基础属性（Tier 取值 1~5，min=0 使 Tier1 显示 20%、Tier5 显示 100%）
    {"Tier", translate.Get("option_weapon_Tier"), 0, 5, false},
    {"Damage", translate.Get("option_weapon_Damage"), 1, 105, false, "Primary"},
    {"HeadshotMulti", translate.Get("option_weapon_Headshot"), 1, 5, false},
    {"Delay", translate.Get("option_weapon_AttackDelay"), 0.05, 2, true, "Primary"},
    {"ReloadSpeed", translate.Get("option_weapon_ReloadSpeed"), 0.3, 1.5, false},
    {"ClipSize", translate.Get("option_weapon_ClipSize"), 1, 35, false, "Primary"},
    {"Pierces", translate.Get("option_weapon_Pierces"), 0, 5, false},
    -- 精度与机动性
    {"ConeMin", translate.Get("option_weapon_MinSpread"), 0, 5, true},
    {"ConeMax", translate.Get("option_weapon_MaxSpread"), 1.5, 7, true},
    {"WalkSpeed", translate.Get("option_weapon_MoveSpeed"), 200, 250, false},
    -- 近战属性
    {"MeleeDamage", translate.Get("option_weapon_MeleeDamage"), 2, 140, false},
    {"MeleeRange", translate.Get("option_weapon_MeleeRange"), 30, 100, false},
    {"MeleeSize", translate.Get("option_weapon_MeleeSize"), 0.2, 3, false}
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
RegisterClientConVar("zs_filmmode", "0", "FilmMode", "电影模式（隐藏HUD）", "bool", nil, function() gamemode.Call("EvaluateFilmMode") end)

-- 玩家自动行为偏好：不兑换 / 总是当志愿者 / 不选Boss / 不使用提交 / 不捡道具
CreateClientConVar("zs_noredeem", "0", true, true)
CreateClientConVar("zs_alwaysvolunteer", "0", true, true)
CreateClientConVar("zs_nobosspick", "0", true, true)
CreateClientConVar("zs_nousetodeposit", "0", true, true)
CreateClientConVar("zs_nopickupprops", "0", true, true)
CreateClientConVar("zs_nailplacer_ghostmode", "1", true, true) -- 钉子放置器幽灵预显模式：0 = 仅显示当前等级，1 = 全部显示（超出等级的为红色）
-- 禁用武器瞄准镜功能
RegisterClientConVar("zs_disablescopes", "0", "DisableScopes", "禁用武器瞄准镜功能", "bool")

-- 一键解锁功能开关
RegisterClientConVar("zs_one_click_unlock", "1", "OneClickUnlock", "一键解锁功能开关", "bool")

-- 机械瞄准（Ironsight）时的缩放比例（0~1）
RegisterClientConVar("zs_ironsightzoom", 1, "IronsightZoomScale", "机械瞄准缩放比例（0~1）", "float", function(v) return math.Clamp(tonumber(v) or 1, 0, 1) end)

-- 被击倒时是否切换到第三人称视角
RegisterClientConVar("zs_thirdpersonknockdown", "1", "ThirdPersonKnockdown", "被击倒时切换到第三人称视角", "bool")

-- 更换职业时是否自动自杀
RegisterClientConVar("zs_suicideonchange", "1", "SuicideOnChangeClass", "更换职业时自动自杀", "bool")

-- BGM（背景音乐）总开关
RegisterClientConVar("zs_beats", "1", "BeatsEnabled", "BGM总开关", "bool")

-- 伤害数字是否穿墙显示
RegisterClientConVar("zs_damagefloaterswalls", "0", "DamageNumberThroughWalls", "伤害数字穿墙显示", "bool")

-- BGM 音量（0~100 映射到 0.0~1.0）
RegisterClientConVar("zs_beatsvolume", 80, "BeatsVolume", "BGM音量（0~100）", "int", function(v) return math.Clamp(tonumber(v) or 0, 0, 100) / 100 end)

-- 准星线条数量（2~8条）
RegisterClientConVar("zs_crosshairlines", 4, "CrosshairLines", "准星线条数量（2~8）", "int", function(v) return math.Clamp(tonumber(v) or 4, 2, 8) end)

-- 准星偏移量（线条末端与中心的距离，0~90像素）
RegisterClientConVar("zs_crosshairoffset", 0, "CrosshairOffset", "准星偏移量（0~90）", "int", function(v) return math.Clamp(tonumber(v) or 0, 0, 90) end)

-- 准星线条粗细（0.5~2像素）
RegisterClientConVar("zs_crosshairthickness", 1, "CrosshairThickness", "准星线条粗细（0.5~2）", "float", function(v) return math.Clamp(tonumber(v) or 1, 0.5, 2) end)

-- 拖拽道具时的旋转灵敏度（0.1~4）
RegisterClientConVar("zs_proprotationsens", 1, "PropRotationSensitivity", "拖拽道具旋转灵敏度（0.1~4）", "float", function(v) return math.Clamp(tonumber(v) or 1, 0.1, 4) end)

-- 拖拽道具时的旋转吸附角度（0~45度，0=无吸附）
RegisterClientConVar("zs_proprotationsnap", 0, "PropRotationSnap", "拖拽道具旋转吸附角度（0~45）", "int", function(v) return math.Clamp(tonumber(v) or 0, 0, 45) end)

-- 伤害数字大小缩放（0.5~2倍）
RegisterClientConVar("zs_dmgnumberscale", 1, "DamageNumberScale", "伤害数字大小缩放（0.5~2）", "float", function(v) return math.Clamp(tonumber(v) or 1, 0.5, 2) end)

-- 伤害数字移动速度（0~1）
RegisterClientConVar("zs_dmgnumberspeed", 1, "DamageNumberSpeed", "伤害数字移动速度（0~1）", "float", function(v) return math.Clamp(tonumber(v) or 1, 0, 1) end)

-- 伤害数字显示寿命（0.2~1.5秒）
RegisterClientConVar("zs_dmgnumberlife", 1, "DamageNumberLifetime", "伤害数字显示寿命（0.2~1.5）", "float", function(v) return math.Clamp(tonumber(v) or 1, 0.2, 1.5) end)

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
RegisterClientConVar("zs_alwaysshownails", "0", "AlwaysShowNails", "总是显示钉子数量", "bool")

-- 是否总是使用快速购买（无需长按）
RegisterClientConVar("zs_alwaysquickbuy", "0", "AlwaysQuickBuy", "总是使用快速购买", "bool")

-- 禁用机械瞄准功能
RegisterClientConVar("zs_noironsights", "0", "NoIronsights", "禁用机械瞄准功能", "bool")

-- 禁用准星旋转（默认禁用）
RegisterClientConVar("zs_nocrosshairrotate", "1", "NoCrosshairRotate", "禁用准星旋转", "bool")
-- 准星圆圈效果开关（无回调，仅作为存储）
CreateClientConVar("zs_crosshair_cicrle", "1", true, false)

-- 隐藏玩家第一人称手臂和武器模型
RegisterClientConVar("zs_hideviewmodels", "0", "HideViewModels", "隐藏第一人称手臂和武器模型", "bool")

-- 玩家透明效果相关：最大半径和当前半径
GM.TransparencyRadiusMax = 8192
GM.TransparencyRadius = 0

-- 捕获 gamemode 表引用供回调闭包使用：客户端回调环境中 GM 全局为 nil（见文件头注释），只能在加载期捕获
local gm = GM or GAMEMODE

-- 第一人称视角下玩家模型的透明半径（平方值）
RegisterClientConVar("zs_transparencyradius", 140, "TransparencyRadius1p", "第一人称视角玩家模型透明半径", "int", function(v) return math.Clamp(tonumber(v) or 0, 0, gm.TransparencyRadiusMax) ^ 2 end)

-- 第三人称视角下玩家模型的透明半径（平方值）
RegisterClientConVar("zs_transparencyradius3p", 140, "TransparencyRadius3p", "第三人称视角玩家模型透明半径", "int", function(v) return math.Clamp(tonumber(v) or 0, 0, gm.TransparencyRadiusMax) ^ 2 end)

-- 启用或禁用移动时的视角倾斜效果
RegisterClientConVar("zs_movementviewroll", "0", "MovementViewRoll", "移动时视角倾斜效果", "bool")

-- 是否显示信息信标（消息标记）
RegisterClientConVar("zs_messagebeaconshow", "1", "MessageBeaconShow", "显示信息信标", "bool")

-- 武器HUD显示模式（整数值）
RegisterClientConVar("zs_weaponhudmode", "2", "WeaponHUDMode", "武器HUD显示模式", "int", function(v) return tonumber(v) or 0 end)

-- 目标生命值显示方式（整数值）
RegisterClientConVar("zs_healthtargetdisplay", "0", "HealthTargetDisplay", "目标生命值显示方式", "int", function(v) return tonumber(v) or 0 end)

-- 受伤时是否显示疼痛闪光效果
RegisterClientConVar("zs_drawpainflash", "1", "DrawPainFlash", "受伤疼痛闪光效果", "bool")

-- 是否显示经验值HUD
RegisterClientConVar("zs_drawxp", "1", "DisplayXPHUD", "显示经验值HUD", "bool", nil, function() gamemode.Call("EvaluateFilmMode") end)

-- 启用或禁用字体特效（如文字模糊发光）
RegisterClientConVar("zs_fonteffects", "0", "FontEffects", "字体特效", "bool")

-- 隐藏背包装饰
RegisterClientConVar("zs_hidepacks", "0", "HidePacks", "隐藏背包装饰", "bool")

-- 是否始终高亮显示好友
RegisterClientConVar("zs_showfriends", "0", "AlwaysDrawFriend", "始终高亮显示好友", "bool")

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
-- 数据驱动：新增/调整武器类别插槽只需在 WeaponSlotConfigs 中增改一行。
-- ============================================================

-- 武器插槽配置表：{ConVar名, GM字段名, 插槽组常量, 默认槽位}
local WeaponSlotConfigs = {
	{"zs_wepslot_assaultrifles", "WeaponSelectSlotAssaultRifles", WEPSELECT_ASSAULT_RIFLE, 3},
	{"zs_wepslot_rifles", "WeaponSelectSlotRifles", WEPSELECT_RIFLE, 4},
	{"zs_wepslot_shotguns", "WeaponSelectSlotShotguns", WEPSELECT_SHOTGUN, 4},
	{"zs_wepslot_smgs", "WeaponSelectSlotSMGs", WEPSELECT_SMG, 3},
	{"zs_wepslot_pistols", "WeaponSelectSlotPistols", WEPSELECT_PISTOL, 2},
	{"zs_wepslot_unarmed", "WeaponSelectSlotUnarmed", WEPSELECT_UNARMED, 1},
	{"zs_wepslot_melee", "WeaponSelectSlotMelee", WEPSELECT_MELEE, 1},
	{"zs_wepslot_medkits", "WeaponSelectSlotMedkits", WEPSELECT_MEDKIT, 5},
	{"zs_wepslot_trinkets", "WeaponSelectSlotTrinkets", WEPSELECT_TRINKET, 5},
	{"zs_wepslot_food", "WeaponSelectSlotFood", WEPSELECT_FOOD, 6},
	{"zs_wepslot_flasks", "WeaponSelectSlotFlasks", WEPSELECT_FLASK, 5},
	{"zs_wepslot_deployables", "WeaponSelectSlotDeployables", WEPSELECT_DEPLOYABLE, 5},
	{"zs_wepslot_misctools", "WeaponSelectSlotMiscTools", WEPSELECT_MISCTOOL, 5},
	{"zs_wepslot_repairtools", "WeaponSelectSlotRepairTools", WEPSELECT_REPAIRTOOL, 1},
	{"zs_wepslot_medicaltools", "WeaponSelectSlotMedicalTools", WEPSELECT_MEDICALTOOL, 4},
	{"zs_wepslot_consupportive", "WeaponSelectSlotConSupportive", WEPSELECT_CONSUMABLE_SUPPORTIVE, 6},
	{"zs_wepslot_conoffensive", "WeaponSelectSlotConOffensive", WEPSELECT_CONSUMABLE_OFFENSIVE, 5},
	{"zs_wepslot_explosives", "WeaponSelectSlotExplosives", WEPSELECT_EXPLOSIVE, 5},
	{"zs_wepslot_bolt", "WeaponSelectSlotBolt", WEPSELECT_BOLT, 4},
	{"zs_wepslot_potions", "WeaponSelectSlotPotions", WEPSELECT_POTION, 6},
}

-- 循环注册：创建 ConVar、初始化 GM 字段、注册回调（更新同组武器的插槽值）
for _, cfg in ipairs(WeaponSlotConfigs) do
	local cvarname, fieldname, slotgroup, defaultslot = cfg[1], cfg[2], cfg[3], cfg[4]
	local gm = GM or GAMEMODE

	gm[fieldname] = math.Clamp(CreateClientConVar(cvarname, defaultslot, true, false):GetInt(), 0, 6)

	cvars.AddChangeCallback(cvarname, function(convar_name, old_value, new_value)
		gm[fieldname] = math.Clamp(tonumber(new_value) or defaultslot, 0, 6)
		local new_slot = gm[fieldname]

		for _, wep_data in pairs(weapons.GetList()) do
			if wep_data.SlotGroup and wep_data.SlotGroup == slotgroup then
				local stored_wep = weapons.GetStored(wep_data.ClassName)
				if stored_wep then
					-- 插槽为0时设为-2（隐藏），否则设为 new_slot - 1（内部从0开始）
					stored_wep.Slot = (new_slot == 0) and -2 or (new_slot - 1)
				end
			end
		end
	end)
end
