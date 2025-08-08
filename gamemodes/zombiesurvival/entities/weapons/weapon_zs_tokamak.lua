

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -43.114, -92.695) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(-0.5, -0.1, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.base"] = { scale = Vector(0.108, 0.108, 0.108), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.VElements = {
	["back"] = { type = "Model", model = "models/gibs/gunship_gibs_nosegun.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.8, 0, 2.874), angle = Angle(90, -180, -90), size = Vector(0.35, 0.2, 0.25), color = Color(161, 255, 74, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/suit_charger001.mdl", bone = "ValveBiped.base", rel = "", pos = Vector(-0.7, 0, -1.916), angle = Angle(0, 0, 0), size = Vector(0.25, 0.25, 0.8), color = Color(175, 255, 102, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0.4, -1.9, -10.539), angle = Angle(0, 90, 0), size = Vector(0.5, 0.5, 2.7), color = Color(184, 255, 119, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0.8, 9.581, -0.958), angle = Angle(-90, 0, -90), size = Vector(0.2, 0.2, 0.2), color = Color(166, 255, 83, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["muzzle"] = { type = "Model", model = "models/Items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0.4, 0, 3.832), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 2.5), color = Color(192, 255, 133, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
 
SWEP.WElements = {
	["back"] = { type = "Model", model = "models/gibs/gunship_gibs_nosegun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.8, 0, 2.874), angle = Angle(90, -180, -90), size = Vector(0.35, 0.2, 0.25), color = Color(161, 255, 74, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_combine/suit_charger001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.533, 0.067, -2.086), angle = Angle(0, -90, -110), size = Vector(0.25, 0.25, 0.8), color = Color(175, 255, 102, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_combine/suit_charger001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 0), angle = Angle(-180, 0, 180), size = Vector(0.25, 0.25, 0.8), color = Color(175, 255, 102, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.4, -1.9, -10.539), angle = Angle(0, 90, 0), size = Vector(0.5, 0.5, 2.7), color = Color(184, 255, 119, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.69, 11.497, -1.918), angle = Angle(-90, 0, -90), size = Vector(0.2, 0.2, 0.3), color = Color(166, 255, 83, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["muzzle"] = { type = "Model", model = "models/Items/combine_rifle_ammo01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.4, 0, 3.832), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 2.5), color = Color(192, 255, 133, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.Tier = 5
SWEP.UseHands = true
SWEP.PrintName = "'托卡马克' 质子枪"
SWEP.Description = "核粒子加速器，发射质子束。中高伤害，精度好。"
SWEP.Base					= "weapon_zs_base"

SWEP.Slot					= 2
SWEP.SlotPos				= 1

SWEP.ShowWorldModel         = false
SWEP.ViewModel 				= "models/weapons/c_smg1.mdl"
SWEP.WorldModel				= "models/weapons/w_smg1.mdl"
SWEP.ViewModelFlip 			= false
SWEP.HoldType				= "ar2"

SWEP.Primary.Damage			= 32
SWEP.Primary.NumShots		= 1
SWEP.Primary.Sound			= Sound("weapons/tokamak.wav")
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Delay			= 0.12
SWEP.Primary.Ammo			= "pulse"
SWEP.Primary.Automatic 		= true
SWEP.ReloadSound			= Sound("weapons/quickload1.wav")

SWEP.HUD3DBone = "ValveBiped.base"
SWEP.HUD3DPos = Vector(2, -1.3, -5)
SWEP.HUD3DAng = Angle(175, 0, -15)
SWEP.HUD3DScale = 0.016
SWEP.IronSightsPos = Vector(-6.64, -0.488, -0.12)
SWEP.IronSightsAng = Vector(0, 0, 0)



SWEP.TracerName = "trancer_laser"