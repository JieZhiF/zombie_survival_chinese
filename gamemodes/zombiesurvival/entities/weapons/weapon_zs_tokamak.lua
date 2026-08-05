-- ============================================================================
-- weapon_zs_tokamak.lua - 托卡马克核粒子加速器（质子束步枪）
-- 负责：定义高精度质子束步枪的属性、附加模型（SCK 元素）与机瞄位置
-- ============================================================================

-- 视图模型骨骼调整：修正双手握持姿态，并将原枪身缩到极小
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -43.114, -92.695) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(-0.5, -0.1, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.base"] = { scale = Vector(0.108, 0.108, 0.108), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
-- 机瞄（开镜）时的位置偏移与角度（自定义机瞄，零偏移）
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)
-- 视图模型附加模型（SCK 元素）：拼接枪身、电池、握把与枪口
SWEP.VElements = {
	["back"] = { type = "Model", model = "models/gibs/gunship_gibs_nosegun.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.8, 0, 2.874), angle = Angle(90, -180, -90), size = Vector(0.35, 0.2, 0.25), color = Color(161, 255, 74, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/suit_charger001.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(-0.7, 0, -1.916), angle = Angle(0, 0, 0), size = Vector(0.25, 0.25, 0.8), color = Color(175, 255, 102, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0.4, -1.9, -10.539), angle = Angle(0, 90, 0), size = Vector(0.5, 0.5, 2.7), color = Color(184, 255, 119, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0.8, 9.581, -0.958), angle = Angle(-90, 0, -90), size = Vector(0.2, 0.2, 0.2), color = Color(166, 255, 83, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["muzzle"] = { type = "Model", model = "models/Items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0.4, 0, 3.832), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 2.5), color = Color(192, 255, 133, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
 
-- 世界模型附加模型（SCK 元素）：第三人称下的枪体组件
SWEP.WElements = {
	["back"] = { type = "Model", model = "models/gibs/gunship_gibs_nosegun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.8, 0, 2.874), angle = Angle(90, -180, -90), size = Vector(0.35, 0.2, 0.25), color = Color(161, 255, 74, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/suit_charger001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.533, 0.067, -2.086), angle = Angle(0, -90, -110), size = Vector(0.25, 0.25, 0.8), color = Color(175, 255, 102, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_combine/suit_charger001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 0), angle = Angle(-180, 0, 180), size = Vector(0.25, 0.25, 0.8), color = Color(175, 255, 102, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.4, -1.9, -10.539), angle = Angle(0, 90, 0), size = Vector(0.5, 0.5, 2.7), color = Color(184, 255, 119, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.69, 11.497, -1.918), angle = Angle(-90, 0, -90), size = Vector(0.2, 0.2, 0.3), color = Color(166, 255, 83, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["muzzle"] = { type = "Model", model = "models/Items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.4, 0, 3.832), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 2.5), color = Color(192, 255, 133, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
-- 武器等级（Tier 5）
SWEP.Tier = 5
-- 使用玩家手臂模型
SWEP.UseHands = true
-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_tokamak")
-- 武器商店描述
SWEP.Description = "核粒子加速器，发射质子束。中高伤害，精度好。"
-- 继承的武器基类
SWEP.Base					= "weapon_zs_base"

-- 武器栏位：2 号栏（重型武器），栏内位置 1
SWEP.Slot					= 2
SWEP.SlotPos				= 1

-- 不显示世界模型（纯附加模型外观）
SWEP.ShowWorldModel         = false
-- 视图模型与世界模型文件
SWEP.ViewModel 				= "models/weapons/c_smg1.mdl"
SWEP.WorldModel				= "models/weapons/w_smg1.mdl"
-- 视图模型不镜像翻转
SWEP.ViewModelFlip 			= false
-- 持枪姿势（AR2 步枪）
SWEP.HoldType				= "ar2"

-- 单发伤害
SWEP.Primary.Damage			= 32
-- 每次射击的弹丸数
SWEP.Primary.NumShots		= 1
-- 开火音效
SWEP.Primary.Sound			= Sound("weapons/tokamak.wav")
-- 弹匣容量 30 发
SWEP.Primary.ClipSize		= 30
-- 初始备用弹药
SWEP.Primary.DefaultClip = 60
-- 射击间隔（高速连发）
SWEP.Primary.Delay			= 0.12
-- 使用的弹药类型（脉冲弹药）
SWEP.Primary.Ammo			= "pulse"
-- 全自动射击
SWEP.Primary.Automatic 		= true
-- 换弹音效
SWEP.ReloadSound			= Sound("weapons/quickload1.wav")

-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置、角度与缩放
SWEP.HUD3DBone = "ValveBiped.base"
SWEP.HUD3DPos = Vector(2, -1.3, -5)
SWEP.HUD3DAng = Angle(175, 0, -15)
SWEP.HUD3DScale = 0.016
-- 机瞄（开镜）时的位置偏移与角度
SWEP.IronSightsPos = Vector(-6.64, -0.488, -0.12)
SWEP.IronSightsAng = Vector(0, 0, 0)



-- 弹道曳光效果（激光曳光）
SWEP.TracerName = "trancer_laser"