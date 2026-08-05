-- ============================================================================
-- weapon_zs_enderp.lua - 多功能等离子步枪（Ender-P）
-- 负责：定义等离子步枪属性、附加模型（SCK 元素）与机瞄位置
-- ============================================================================
-- 视图模型附加模型（SCK 元素）：拼接枪管、机匣、握把、弹匣与枪托
SWEP.VElements = {
	["barrel"] = { type = "Model", model = "models/props_combine/combine_teleportplatform.mdl", bone = "v_weapon.famas", rel = "base", pos = Vector(0, -8.623, -0.958), angle = Angle(-90, 180, 90), size = Vector(0.02, 0.02, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0, -1.916, 18.204), angle = Angle(180, 0, -90), size = Vector(0.013, 0.034, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "v_weapon.bolt", rel = "", pos = Vector(0, 0.6, 0.3), angle = Angle(0, 90, 180), size = Vector(0.07, 0.07, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 5.749, -7.665), angle = Angle(0, 90, 0), size = Vector(0.8, 0.5, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "v_weapon.magazine", rel = "", pos = Vector(0, -4.79, 0), angle = Angle(90, 0, 90), size = Vector(0.155, 0.124, 0.155), color = Color(183, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.famas", rel = "base", pos = Vector(0, 12.455, -1.916), angle = Angle(0, 0, 0), size = Vector(0.015, 0.02, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["under"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.famas", rel = "base", pos = Vector(0, 5.749, -1.916), angle = Angle(0, 0, 180), size = Vector(0.021, 0.035, 0.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型（SCK 元素）：第三人称下的枪体组件
SWEP.WElements = {
	["Bolt"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.958, -0.2), angle = Angle(90, -90, 180), size = Vector(0.06, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Mag"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 11.497, -1.916), angle = Angle(0, 90, 180), size = Vector(0.155, 0.124, 0.155), color = Color(183, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_combine/combine_teleportplatform.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -9.93, -0.958), angle = Angle(-90, 180, 90), size = Vector(0.02, 0.02, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.7, 1.4, -6.1), angle = Angle(-4.31, 90, -168.144), size = Vector(0.013, 0.034, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 5.749, -7.665), angle = Angle(0, 90, 0), size = Vector(0.8, 0.5, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 12.455, -1.916), angle = Angle(0, 0, 0), size = Vector(0.015, 0.02, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["under"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 3.8, -1.916), angle = Angle(0, 0, 180), size = Vector(0.021, 0.045, 0.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


-- 视图模型骨骼调整：将法玛斯枪身缩到极小，改用附加模型拼装外观
SWEP.ViewModelBoneMods = {
	["v_weapon.famas"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_enderp")
-- 武器商店描述
SWEP.Description = "多功能等离子步枪，高速发射能量弹，各项属性均衡。"
-- 继承的武器基类
SWEP.Base					= "weapon_zs_base"

-- 不显示世界模型（纯附加模型外观）
SWEP.ShowWorldModel         = false
-- 使用玩家手臂模型
SWEP.UseHands = true
-- 客户端专属配置块
if CLIENT then
	-- 武器栏位：突击步枪栏
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
	SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	SWEP.WeaponType = "rifle"
end
-- 武器栏内的位置
SWEP.SlotPos				= 1

-- 视图模型与世界模型文件
SWEP.ViewModel 				= "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_famas.mdl"
-- 视图模型不镜像翻转
SWEP.ViewModelFlip 			= false
-- 持枪姿势（AR2 步枪）
SWEP.HoldType				= "ar2"
-- 武器类型：步枪
SWEP.WeaponType = "rifle"

-- 单发伤害
SWEP.Primary.Damage			= 17
-- 每次射击的弹丸数
SWEP.Primary.NumShots		= 1
-- 开火音效
SWEP.Primary.Sound			= Sound("weapons/ender.wav")
-- 弹匣容量 30 发
SWEP.Primary.ClipSize		= 30
-- 初始备用弹药
SWEP.Primary.DefaultClip = 60
-- 射击间隔（高速连发）
SWEP.Primary.Delay			= 0.11
-- 使用的弹药类型
SWEP.Primary.Ammo			= "ar2"
-- 全自动射击
SWEP.Primary.Automatic 		= true
-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置、角度与缩放
SWEP.HUD3DBone = "v_weapon.famas"
SWEP.HUD3DPos = Vector(1.9, -1, 11.5)
SWEP.HUD3DAng = Angle(175, 0, -15)
SWEP.HUD3DScale = 0.015
-- 机瞄（开镜）时的位置偏移与角度
SWEP.IronSightsPos 			= Vector(-6.2, -8.78, 0.65)
SWEP.IronSightsAng 			= Vector(0, 0, 0)
-- 武器等级（Tier 1）
SWEP.Tier = 1
-- 最大/最小准星扩散（移动中/静止时）
SWEP.ConeMax = 3
SWEP.ConeMin = 2.5