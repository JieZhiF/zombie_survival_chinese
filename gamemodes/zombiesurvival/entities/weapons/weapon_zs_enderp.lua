SWEP.VElements = {
	["barrel"] = { type = "Model", model = "models/props_combine/combine_teleportplatform.mdl", bone = "v_weapon.famas", rel = "base", pos = Vector(0, -8.623, -0.958), angle = Angle(-90, 180, 90), size = Vector(0.02, 0.02, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0, -1.916, 18.204), angle = Angle(180, 0, -90), size = Vector(0.013, 0.034, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "v_weapon.bolt", rel = "", pos = Vector(0, 0.6, 0.3), angle = Angle(0, 90, 180), size = Vector(0.07, 0.07, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 5.749, -7.665), angle = Angle(0, 90, 0), size = Vector(0.8, 0.5, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "v_weapon.magazine", rel = "", pos = Vector(0, -4.79, 0), angle = Angle(90, 0, 90), size = Vector(0.155, 0.124, 0.155), color = Color(183, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.famas", rel = "base", pos = Vector(0, 12.455, -1.916), angle = Angle(0, 0, 0), size = Vector(0.015, 0.02, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["under"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.famas", rel = "base", pos = Vector(0, 5.749, -1.916), angle = Angle(0, 0, 180), size = Vector(0.021, 0.035, 0.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["Bolt"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.958, -0.2), angle = Angle(90, -90, 180), size = Vector(0.06, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Mag"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 11.497, -1.916), angle = Angle(0, 90, 180), size = Vector(0.155, 0.124, 0.155), color = Color(183, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_combine/combine_teleportplatform.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -9.93, -0.958), angle = Angle(-90, 180, 90), size = Vector(0.02, 0.02, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.7, 1.4, -6.1), angle = Angle(-4.31, 90, -168.144), size = Vector(0.013, 0.034, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/weapons/w_pist_p228.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 5.749, -7.665), angle = Angle(0, 90, 0), size = Vector(0.8, 0.5, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 12.455, -1.916), angle = Angle(0, 0, 0), size = Vector(0.015, 0.02, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["under"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 3.8, -1.916), angle = Angle(0, 0, 180), size = Vector(0.021, 0.045, 0.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


SWEP.ViewModelBoneMods = {
	["v_weapon.famas"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.PrintName = "'末影' 等离子无托步枪"
SWEP.Description = "多功能等离子步枪，高速发射能量弹，各项属性均衡。"
SWEP.Base					= "weapon_zs_base"

SWEP.ShowWorldModel         = false
SWEP.UseHands = true
SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.ViewModel 				= "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_famas.mdl"
SWEP.ViewModelFlip 			= false
SWEP.HoldType				= "ar2"

SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Sound			= Sound("weapons/ender.wav")
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Delay			= 0.093 
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Automatic 		= true
SWEP.HUD3DBone = "v_weapon.famas"
SWEP.HUD3DPos = Vector(1.9, -1, 11.5)
SWEP.HUD3DAng = Angle(175, 0, -15)
SWEP.HUD3DScale = 0.015
SWEP.IronSightsPos 			= Vector(-6.2, -8.78, 0.65)
SWEP.IronSightsAng 			= Vector(0, 0, 0)
SWEP.Tier = 3