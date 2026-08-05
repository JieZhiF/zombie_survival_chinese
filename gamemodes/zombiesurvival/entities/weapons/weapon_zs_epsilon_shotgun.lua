-- ============================================================================
-- weapon_zs_epsilon_shotgun.lua - Epsilon 全自动等离子霰弹枪
-- 负责：定义霰弹枪属性（磁性等离子球分裂弹丸）、附加模型与机瞄位置
-- ============================================================================
-- 视图模型附加模型（SCK 元素）：拼接枪身、电池、喉缩、握把与枪托
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "v_weapon.xm1014_Parent", rel = "", pos = Vector(0, -2.874, -9.581), angle = Angle(90, 0, -90), size = Vector(0.055, 0.01, 0.011), color = Color(247, 251, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(12.455, 0.35, 1.85), angle = Angle(0, -90, 90), size = Vector(0.35, 0.5, 0.7), color = Color(253, 253, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["choke"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.xm1014_Parent", rel = "base", pos = Vector(-19.162, 0, 1.4), angle = Angle(180, 90, 180), size = Vector(0.2, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(9.9, 0, -4.5), angle = Angle(0, 180, 0), size = Vector(0.8, 0.8, 0.85), color = Color(189, 206, 212, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["shell"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "v_weapon.xm1014_Shell", rel = "", pos = Vector(0.15, -0.1, -1.3), angle = Angle(0, 0, 90), size = Vector(0.2, 0.65, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/phxtended/tri2x1.mdl", bone = "v_weapon.xm1014_Parent", rel = "base", pos = Vector(19.7, 0.46, 3.13), angle = Angle(-90, 180, 90), size = Vector(0.057, 0.1, 0.15), color = Color(143, 147, 157, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型（SCK 元素）：第三人称下的枪体组件
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.9, 0.958, -3.832), angle = Angle(168.144, 0, 0), size = Vector(0.05, 0.01, 0.011), color = Color(247, 251, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(12.455, 0.35, 1.85), angle = Angle(0, -90, 90), size = Vector(0.35, 0.5, 0.7), color = Color(253, 253, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["choke"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-17.246, 0, 1.4), angle = Angle(180, 90, 180), size = Vector(0.2, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(9.9, 0, -4.5), angle = Angle(0, 180, 0), size = Vector(0.8, 0.8, 0.85), color = Color(189, 206, 212, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/phxtended/tri2x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(19.7, 0.46, 3.13), angle = Angle(-90, 180, 90), size = Vector(0.057, 0.1, 0.15), color = Color(143, 147, 157, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
}

-- 视图模型骨骼调整：修正右手手指握持姿态，并将原枪身缩到极小
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(10.778, 6.467, -12.934) },
	["ValveBiped.Bip01_R_Finger21"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-4.311, -25.868, 0) },
	["ValveBiped.Bip01_R_Finger31"] = { scale = Vector(1, 1, 1), pos = Vector(0.25, 0, -0.2), angle = Angle(-2.156, -30.18, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0.4, 0, 0), angle = Angle(6.467, -17.246, 8.623) },
	["v_weapon.xm1014_Parent"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_epsilon_shotgun")
-- 武器商店描述
SWEP.Description = "全自动等离子霰弹枪，伤害高，射程好。发射磁性等离子球，会分裂成多个“弹丸”，类似于鹿弹。"
-- 继承的霰弹枪基类
SWEP.Base					= "weapon_zs_baseshotgun"

-- 使用玩家手臂模型
SWEP.UseHands = true


-- 武器栏位：3 号栏（霰弹枪），栏内位置 1
SWEP.Slot					= 3
SWEP.SlotPos				= 1

-- 视图模型与世界模型文件
SWEP.ViewModel 				= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel				= "models/weapons/w_shot_xm1014.mdl"
-- 视图模型不镜像翻转
SWEP.ViewModelFlip 			= false
-- 持枪姿势（霰弹枪）
SWEP.HoldType               = "shotgun"
-- 不显示世界模型（纯附加模型外观）
SWEP.ShowWorldModel         = false


-- 单颗弹丸伤害
SWEP.Primary.Damage			= 21.7
-- 每次射击的弹丸数（分裂成多发）
SWEP.Primary.NumShots		= 6
-- 开火音效
SWEP.Primary.Sound			= Sound("weapons/epsilon.wav")
-- 弹匣容量 12 发
SWEP.Primary.ClipSize		= 12
-- 初始备用弹药
SWEP.Primary.DefaultClip	= 48
-- 射击间隔
SWEP.Primary.Delay			= 0.25
-- 换弹速度倍率
SWEP.ReloadSpeed = 1.2
-- 使用的弹药类型（霰弹）
SWEP.Primary.Ammo			= "buckshot"
-- 全自动射击
SWEP.Primary.Automatic 		= true
-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置、角度与缩放
SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
SWEP.HUD3DPos = Vector(-1.6, 0, -1.4)
SWEP.HUD3DAng = Angle(0, 0, 0)
SWEP.HUD3DScale = 0.020
-- 弹道曳光效果
SWEP.TracerName = "AR2Tracer"
-- 最大/最小准星扩散（移动中/静止时）
SWEP.ConeMax = 4.2
SWEP.ConeMin = 2.2
-- 准星扩散速度
SWEP.ConeRamp = 2
-- 武器等级（Tier 4）
SWEP.Tier = 4
-- 最大库存数量
SWEP.MaxStock = 2
