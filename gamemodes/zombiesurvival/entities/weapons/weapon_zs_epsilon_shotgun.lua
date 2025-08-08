SWEP.VElements = {
	["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "v_weapon.xm1014_Parent", rel = "", pos = Vector(0, -2.874, -9.581), angle = Angle(90, 0, -90), size = Vector(0.055, 0.01, 0.011), color = Color(247, 251, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(12.455, 0.35, 1.85), angle = Angle(0, -90, 90), size = Vector(0.35, 0.5, 0.7), color = Color(253, 253, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["choke"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.xm1014_Parent", rel = "base", pos = Vector(-19.162, 0, 1.4), angle = Angle(180, 90, 180), size = Vector(0.2, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(9.9, 0, -4.5), angle = Angle(0, 180, 0), size = Vector(0.8, 0.8, 0.85), color = Color(189, 206, 212, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["shell"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "v_weapon.xm1014_Shell", rel = "", pos = Vector(0.15, -0.1, -1.3), angle = Angle(0, 0, 90), size = Vector(0.2, 0.65, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/phxtended/tri2x1.mdl", bone = "v_weapon.xm1014_Parent", rel = "base", pos = Vector(19.7, 0.46, 3.13), angle = Angle(-90, 180, 90), size = Vector(0.057, 0.1, 0.15), color = Color(143, 147, 157, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.9, 0.958, -3.832), angle = Angle(168.144, 0, 0), size = Vector(0.05, 0.01, 0.011), color = Color(247, 251, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(12.455, 0.35, 1.85), angle = Angle(0, -90, 90), size = Vector(0.35, 0.5, 0.7), color = Color(253, 253, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["choke"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-17.246, 0, 1.4), angle = Angle(180, 90, 180), size = Vector(0.2, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(9.9, 0, -4.5), angle = Angle(0, 180, 0), size = Vector(0.8, 0.8, 0.85), color = Color(189, 206, 212, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/phxtended/tri2x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(19.7, 0.46, 3.13), angle = Angle(-90, 180, 90), size = Vector(0.057, 0.1, 0.15), color = Color(143, 147, 157, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(10.778, 6.467, -12.934) },
	["ValveBiped.Bip01_R_Finger21"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-4.311, -25.868, 0) },
	["ValveBiped.Bip01_R_Finger31"] = { scale = Vector(1, 1, 1), pos = Vector(0.25, 0, -0.2), angle = Angle(-2.156, -30.18, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0.4, 0, 0), angle = Angle(6.467, -17.246, 8.623) },
	["v_weapon.xm1014_Parent"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.PrintName = "'伊普西隆' 等离子霰弹枪"
SWEP.Description = "全自动等离子霰弹枪，伤害高，射程好。发射磁性等离子球，会分裂成多个“弹丸”，类似于鹿弹。"
SWEP.Base					= "weapon_zs_baseshotgun"

SWEP.UseHands = true


SWEP.Slot					= 3
SWEP.SlotPos				= 1

SWEP.ViewModel 				= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel				= "models/weapons/w_shot_xm1014.mdl"
SWEP.ViewModelFlip 			= false
SWEP.HoldType               = "shotgun"
SWEP.ShowWorldModel         = false


SWEP.Primary.Damage			= 26
SWEP.Primary.NumShots		= 6
SWEP.Primary.Sound			= Sound("weapons/epsilon.wav")
SWEP.Primary.Cone			= 0.025
SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 48
SWEP.Primary.Delay			= 0.25
SWEP.ReloadSpeed = 1.3
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Automatic 		= true
SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
SWEP.HUD3DPos = Vector(-1.6, 0, -1.4)
SWEP.HUD3DAng = Angle(0, 0, 0)
SWEP.HUD3DScale = 0.020
SWEP.TracerName = "AR2Tracer"
SWEP.ConeMax = 4.2
SWEP.ConeMin = 2.2
SWEP.ConeRamp = 2
SWEP.Tier = 4
SWEP.MaxStock = 2
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 1.3  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.58  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 19   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = false
SWEP.Recoil_Progressive_Max_Multiplier = 1.85
SWEP.Recoil_Progressive_Shot_Increment = 0.01
SWEP.Recoil_Progressive_Reset_Time = 0.2


-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 2.3 -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Percentage = 0.2 -- 恢复70%的后坐力, 剩下30%需要手动压
SWEP.Recoil_Recovery_Speed  = 4.3 -- 自动恢复的速度
SWEP.Recoil_Recovery_Time   = 0.1 -- 