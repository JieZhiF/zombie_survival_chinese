-- AddCSLuaFile() should be at the top of the file.
AddCSLuaFile()

SWEP.VElements = {
["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "v_weapon.m249", rel = "", pos = Vector(0, 2.8, 7.665), angle = Angle(-90, 0, -90), size = Vector(0.05, 0.019, 0.019), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-2.8, 0.08, 4.16), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 1.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["box"] = { type = "Model", model = "models/Items/combine_rifle_cartridge01.mdl", bone = "v_weapon.ammobox", rel = "", pos = Vector(2.241, -3.002, 0.075), angle = Angle(0, 0, -90), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet1", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet+"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet2", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet3", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet+++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet4", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet++++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet5", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet+++++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet6", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet++++++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet7", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet+++++++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet8", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet++++++++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet9", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["bullet+++++++++"] = { type = "Model", model = "models/props_lab/labpart.mdl", bone = "v_weapon.bullet10", rel = "", pos = Vector(-0.002, 0.072, -0.024), angle = Angle(0, 0, 0), size = Vector(0.077, 0.077, 0.077), color = Color(112, 247, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["cover"] = { type = "Model", model = "models/props_combine/combine_barricade_short01a.mdl", bone = "v_weapon.receiver", rel = "", pos = Vector(-2.894, -0.438, 0.487), angle = Angle(-90, 180, 90), size = Vector(0.1, 0.15, 0.055), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["muzzle"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-15.248, -0.19, 4.56), angle = Angle(180, 90, -90), size = Vector(0.03, 0.03, 0.04), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.092, 0.609, -3.327), angle = Angle(172.455, 0, 1), size = Vector(0.05, 0.019, 0.019), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-2.8, 0.08, 4.16), angle = Angle(90, 0, 0), size = Vector(0.5, 0.5, 1.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["box"] = { type = "Model", model = "models/Items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-4.899, 2.091, 0.747), angle = Angle(0, -90, 0), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["cover"] = { type = "Model", model = "models/props_combine/combine_barricade_short01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.27, -0.597, 5.794), angle = Angle(-90, 180, 90), size = Vector(0.1, 0.15, 0.055), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
["muzzle"] = { type = "Model", model = "models/props_combine/combinethumper002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-15.248, -0.19, 4.56), angle = Angle(180, 90, -90), size = Vector(0.03, 0.03, 0.04), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["v_weapon.ammobox"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.handle"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.receiver"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.PrintName = "'堡垒' 等离子机枪"
SWEP.Description = "轻型等离子机枪，威力大、射速快，但后坐力大。"
SWEP.Base					= "weapon_zs_base"

SWEP.UseHands = true
SWEP.Slot					= 3
SWEP.SlotPos				= 0
SWEP.ViewModel 				= "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel				= "models/weapons/w_mach_m249para.mdl"
SWEP.ViewModelFlip 			= false
SWEP.HoldType				= "ar2"

SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Sound			= Sound("weapons/citadel_fire.wav")
SWEP.Primary.ClipSize		= 100
SWEP.Primary.SpareClip		= 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Delay			= 0.08
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Automatic 		= true
SWEP.Tier = 5
SWEP.ConeMax = 4
SWEP.ConeMin = 1.2
SWEP.HUD3DBone = "v_weapon.m249"
SWEP.HUD3DPos = Vector(1.4, -1.3, 5)
SWEP.HUD3DAng = Angle(180, 0, -15)
SWEP.HUD3DScale = 0.015
SWEP.TracerName = "AR2Tracer"
SWEP.IronSightsPos = Vector(-5.88, -13.76, 1.8)
SWEP.IronSightsAng = Vector(0, 0, 0)


SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.3  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.04  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 18   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = true
SWEP.Recoil_Progressive_Max_Multiplier = 2
SWEP.Recoil_Progressive_Shot_Increment = 0.01
SWEP.Recoil_Progressive_Reset_Time = 0.2


-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 2.2 -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Percentage = 0.1 
SWEP.Recoil_Recovery_Speed  = 3.2 -- 自动恢复的速度
SWEP.Recoil_Recovery_Time   = 0.15 