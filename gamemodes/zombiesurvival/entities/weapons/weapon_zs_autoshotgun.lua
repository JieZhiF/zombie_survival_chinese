-- ============================================================================
-- weapon_zs_autoshotgun.lua - 全自动霰弹枪（Autoshotgun）
-- 负责：定义全自动霰弹枪属性（六弹丸散射）、附加模型与泵动动画
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()
-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_autoshotgun")

-- 继承的霰弹枪基类
SWEP.Base         = "weapon_zs_baseshotgun"
 
-- 武器权重（栏内排序优先级）
SWEP.Weight			    = 5

-- 武器栏位：3 号栏（霰弹枪），栏内位置 1
SWEP.Slot			    = 3
SWEP.SlotPos			= 1

-- 视图模型与世界模型文件
SWEP.ViewModel           = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel          = "models/weapons/w_shotgun.mdl"
-- 使用玩家手臂模型
SWEP.UseHands            = true
-- 单颗弹丸伤害
SWEP.Primary.Damage		= 12	
-- 每次射击的弹丸数
SWEP.Primary.NumShots	= 6		
-- 单次射击后坐力
SWEP.Primary.Recoil		= 0.1			
-- 最大/最小准星扩散（移动中/静止时）
SWEP.ConeMax = 4.2
SWEP.ConeMin = 2.8		
-- 射击间隔
SWEP.Primary.Delay		= 0.3
-- 弹匣容量 10 发
SWEP.Primary.ClipSize		= 10

-- 按幸存模式规则计算初始备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)
-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置与缩放
SWEP.HUD3DBone = "ValveBiped.Gun"
SWEP.HUD3DPos = Vector(2, -0.85, -7.5)
SWEP.HUD3DScale = 0.025
-- 全自动射击
SWEP.Primary.Automatic	= true
-- 使用的弹药类型（霰弹）
SWEP.Primary.Ammo = "buckshot"		
-- 弹道曳光效果
SWEP.TracerName = "AR2Tracer"
-- 武器等级（Tier 2）
SWEP.Tier = 2
-- 泵动（上膛）动作手势与音效
SWEP.PumpActivity = ACT_SHOTGUN_PUMP
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1")
-- 换弹音效
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")
-- 第一人称视野角度
SWEP.ViewModelFOV = 66

-- 视图模型附加模型（SCK 元素）：拼接枪管、泵动护木与弹仓组件
SWEP.VElements = {
	["bas"] = { type = "Model", model = "models/props_c17/Lockers001a.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, -2.222, -5.007), angle = Angle(0, 90, 180), size = Vector(0.136, 0.029, 0.184), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tptimer_sheet", skin = 0, bodygroup = {} },
	["bas+"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "ValveBiped.Pump", rel = "", pos = Vector(0, 0, 0.433), angle = Angle(0, -90, 0), size = Vector(0.046, 0.03, 0.115), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bas++++"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "ValveBiped.Pump", rel = "", pos = Vector(0, 0.104, 0.273), angle = Angle(0, 90, 0), size = Vector(0.02, 0.03, 0.118), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["oboi"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, 2.431, -8.478), angle = Angle(0, -90, 0), size = Vector(0.2, 0.2, 0.065), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tptimer_sheet", skin = 0, bodygroup = {} },
	["stvl+"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, -0.461, 18.531), angle = Angle(-90, 90, 0), size = Vector(0.129, 0.104, 0.125), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bas+++"] = { type = "Model", model = "models/props_c17/Lockers001a.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, -2.243, 1.373), angle = Angle(0, 90, 0), size = Vector(0.136, 0.028, 0.231), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tptimer_sheet", skin = 0, bodygroup = {} },
	["stvl"] = { type = "Model", model = "models/hunter/tubes/tube1x1x5.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, -0.48, 8.095), angle = Angle(0, 0, 0), size = Vector(0.043, 0.043, 0.079), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tower01a", skin = 0, bodygroup = {} },
	["stvl++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x5.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, 1.468, 8.095), angle = Angle(0, 0, 0), size = Vector(0.043, 0.043, 0.064), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tower01a", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型（SCK 元素）：第三人称下的枪体组件
SWEP.WElements = {
	["oboi"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.343, 0.987, -2.05), angle = Angle(96.117, 177.746, 2.043), size = Vector(0.2, 0.2, 0.065), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tptimer_sheet", skin = 0, bodygroup = {} },
	["bas"] = { type = "Model", model = "models/props_c17/Lockers001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(13.42, 1.126, -7.224), angle = Angle(-85.306, 179.438, -1.277), size = Vector(0.136, 0.025, 0.184), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tptimer_sheet", skin = 0, bodygroup = {} },
	["bas+"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16.495, 0.996, -5.397), angle = Angle(97.967, -180, 0.596), size = Vector(0.046, 0.019, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["stvl++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x5.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(22.031, 0.753, -5.159), angle = Angle(-96.295, 0, 0), size = Vector(0.032, 0.032, 0.043), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tower01a", skin = 0, bodygroup = {} },
	["stvl"] = { type = "Model", model = "models/hunter/tubes/tube1x1x5.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20.291, 1.075, -6.376), angle = Angle(-96.543, 1.458, 0.368), size = Vector(0.037, 0.037, 0.057), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tower01a", skin = 0, bodygroup = {} },
	["bas+++"] = { type = "Model", model = "models/props_c17/Lockers001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(18.16, 1.11, -7.678), angle = Angle(-95.172, 0, 0), size = Vector(0.136, 0.024, 0.157), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_tptimer_sheet", skin = 0, bodygroup = {} },
	["bas++++"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16.732, 0.949, -5.355), angle = Angle(-97.795, 0, 0), size = Vector(0.02, 0.02, 0.072), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["stvl+"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(28.472, 0.949, -7.706), angle = Angle(173.761, 0.546, -0.238), size = Vector(0.129, 0.075, 0.125), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 开火音效（外星武器音效）
SWEP.Primary.Sound = ("weapons/alien/alien_fire.wav")

-- 换弹音效（外星武器音效）
SWEP.ReloadSound = "weapons/alien/alien_reload.wav"
