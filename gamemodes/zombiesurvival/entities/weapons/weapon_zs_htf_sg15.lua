AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_ender")
SWEP.Description = ""..translate.Get("weapon_zs_ender_description")

SWEP.SlotPos = 0

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 70

	SWEP.HUD3DBone = "v_weapon.famas"
	SWEP.HUD3DPos = Vector(1.2, -1.6, 10)
	SWEP.HUD3DAng = Angle(0,180,150)
	SWEP.HUD3DScale = 0.015
	SWEP.HoldType = "ar2"
	SWEP.ViewModelFlip = false

end
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.Base = "weapon_zs_base"

--[[
	["VElements"] = {
		["lasersigmaedit+"] = {
			["active"] = true
		},
		["laserbeam"] = {
			["active"] = true
		},
	},
	["WElements"] = {
["lasersigmaedit+"] = {
			["active"] = true
		},
	},
	["Primary"] = {
		["Spread"] = function(wep,stat) return math.max( stat * 0.9, stat - 0.01 ) end,
		["SpreadMultiplierMax"] = function(wep,stat) return stat * ( 1 / 0.9 ) * 1.1 end
	},
	["LaserSightAttachment"] = function(wep,stat) return wep.LaserSightModAttachment end,
}
]]

SWEP.ViewModelBoneMods = {
	["v_weapon.famas"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {
	["laserbeam"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 1.75, -1), angle = Angle(-90, -90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}, active = true },
	["stvol++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -2.786, 15.723), angle = Angle(0, 0, 90), size = Vector(0.059, 0.158, 0.025), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["rm+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.159, -3.313, 6.162), angle = Angle(-90, 0, -90), size = Vector(0.17, 0.105, 0.17), color = Color(136, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["rm++"] = { type = "Model", model = "models/xeon133/slider/slider_12x12x12.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.157, -4.5, 6.223), angle = Angle(-90, 0, -90), size = Vector(0.172, 0.086, 0.086), color = Color(136, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -0.382, 11.225), angle = Angle(90, 0, -90), size = Vector(0.048, 0.048, 0.048), color = Color(101, 105, 100, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 0.563, 31.927), angle = Angle(99.526, 180, 180), size = Vector(0.125, 0.16, 0.089), color = Color(192, 191, 197, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["rm+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.159, -3.73, 5.415), angle = Angle(-90, 0, -90), size = Vector(0.061, 0.054, 0.032), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -1.492, 15.949), angle = Angle(0, 0, 90), size = Vector(0.059, 0.193, 0.025), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 1.07, 21.555), angle = Angle(90, 0, -90), size = Vector(0.252, 0.104, 0.128), color = Color(139, 141, 146, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lasersigmaedit+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 1.749, -1.257), angle = Angle(-90, 0, 90), size = Vector(0.009, 0.009, 0.009), color = Color(156, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_lab/blastdoor001b.mdl", bone = "v_weapon.magazine", rel = "", pos = Vector(0, -0.42, -1.403), angle = Angle(0, 0, 0), size = Vector(0.165, 0.104, 0.026), color = Color(192, 191, 189, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -1.946, 17.042), angle = Angle(0, 0, 14.973), size = Vector(0.059, 0.071, 0.035), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++"] = { type = "Model", model = "models/weapons/w_eq_eholster.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -1.278, 29.208), angle = Angle(180, 90, 0), size = Vector(0.805, 0.805, 0.805), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["rm++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.145, -4.515, 6.057), angle = Angle(0, 0, 0), size = Vector(0.03, 0.03, 0.009), color = Color(255, 255, 255, 187), surpresslightning = true, material = "red", skin = 0, bodygroup = {} },
	["stvol+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -2.507, 14.842), angle = Angle(0, 0, 14.973), size = Vector(0.059, 0.071, 0.035), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -2.81, 18.017), angle = Angle(0, 0, 90.734), size = Vector(0.052, 0.116, 0.035), color = Color(111, 113, 111, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 0, 1.623), angle = Angle(0, 0, 0), size = Vector(0.039, 0.039, 0.048), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0.906, -0.51, 19.235), angle = Angle(90, 0, 0), size = Vector(0.02, 0.02, 0.02), color = Color(101, 105, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["mag_extend"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.magazine", rel = "", pos = Vector(0, 2.686, -1.617), angle = Angle(0, 0, 0), size = Vector(0.229, 0.229, 0.076), color = Color(166, 163, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false}, 
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.119, -0.576, 30.284), angle = Angle(0, 0, 180), size = Vector(0.028, 0.028, 0.206), color = Color(139, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 0.563, 27.079), angle = Angle(72.95, 90, 180), size = Vector(0.125, 0.1, 0.125), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 0.277, 16.476), angle = Angle(120.166, 90, 180), size = Vector(0.125, 0.1, 0.125), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["tyan"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "v_weapon.bolt", rel = "", pos = Vector(0, -0.248, -0.187), angle = Angle(0, 90, 0), size = Vector(0.086, 0.05, 0.256), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -0.249, 11.222), angle = Angle(90, 0, -90), size = Vector(0.893, 0.093, 0.177), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -0.783, 16.264), angle = Angle(5.614, 90, 180), size = Vector(0.109, 0.019, 0.17), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -2.537, 16.999), angle = Angle(0, 0, 116.427), size = Vector(0.059, 0.103, 0.032), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, 2.006, 21.642), angle = Angle(-90, 90, 180), size = Vector(1.376, 1.835, 1.228), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/gravestone001a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0.904, -0.815, 19.048), angle = Angle(180, 0, -46.752), size = Vector(0.009, 0.009, 0.009), color = Color(101, 105, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -0.833, 18.097), angle = Angle(180, 0, 90), size = Vector(0.136, 0.81, 0.158), color = Color(101, 105, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -1.782, 14.76), angle = Angle(0, 0, 0), size = Vector(0.059, 0.071, 0.035), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -5.979, 19.54), angle = Angle(0, 0, 108.749), size = Vector(0.063, 0.076, 0.09), color = Color(103, 108, 106, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.famas", rel = "stvol", pos = Vector(0, -1.155, 23.746), angle = Angle(180, 0, 90), size = Vector(0.182, 0.192, 0.111), color = Color(123, 125, 123, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["stvol++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.786, 15.723), angle = Angle(0, 0, 90), size = Vector(0.059, 0.158, 0.025), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["rm+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0, 1.251, -6.288), angle = Angle(-5.817, 0, 0), size = Vector(0.17, 0.105, 0.17), color = Color(136, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.155, 23.746), angle = Angle(180, 0, 90), size = Vector(0.182, 0.192, 0.111), color = Color(123, 125, 123, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.382, 11.225), angle = Angle(90, 0, -90), size = Vector(0.048, 0.048, 0.048), color = Color(101, 105, 100, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.492, 15.949), angle = Angle(0, 0, 90), size = Vector(0.059, 0.193, 0.025), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.07, 21.555), angle = Angle(90, 0, -90), size = Vector(0.252, 0.104, 0.128), color = Color(139, 141, 146, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.833, 18.097), angle = Angle(180, 0, 90), size = Vector(0.136, 0.81, 0.158), color = Color(101, 105, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_lab/blastdoor001b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -4.404, 22.179), angle = Angle(0, 0, 0), size = Vector(0.165, 0.104, 0.026), color = Color(192, 191, 189, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["rm+++"] = { type = "Model", model = "models/xeon133/slider/slider_12x12x12.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-0.082, 1.256, -7.498), angle = Angle(-5.817, 0, 0), size = Vector(0.163, 0.09, 0.093), color = Color(136, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.563, 31.927), angle = Angle(99.526, 180, 180), size = Vector(0.125, 0.16, 0.089), color = Color(192, 191, 197, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.783, 16.264), angle = Angle(5.614, 90, 180), size = Vector(0.109, 0.019, 0.17), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.507, 14.842), angle = Angle(0, 0, 14.973), size = Vector(0.059, 0.071, 0.035), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.946, 17.042), angle = Angle(0, 0, 14.973), size = Vector(0.059, 0.071, 0.035), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0, 1.623), angle = Angle(0, 0, 0), size = Vector(0.039, 0.039, 0.048), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++"] = { type = "Model", model = "models/weapons/w_eq_eholster.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.278, 29.208), angle = Angle(180, 90, 0), size = Vector(0.805, 0.805, 0.805), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["mag_extend"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -6.841, 22.014), angle = Angle(0, 0, 0), size = Vector(0.2, 0.2, 0.071), color = Color(153, 148, 149, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20.961, 1.271, -5.894), angle = Angle(0, -90, 82.885), size = Vector(0.028, 0.028, 0.206), color = Color(139, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.563, 27.079), angle = Angle(72.95, 90, 180), size = Vector(0.125, 0.1, 0.125), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.277, 16.476), angle = Angle(120.166, 90, 180), size = Vector(0.125, 0.1, 0.125), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.906, -0.51, 19.235), angle = Angle(90, 0, 0), size = Vector(0.02, 0.02, 0.02), color = Color(101, 105, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.249, 11.222), angle = Angle(90, 0, -90), size = Vector(0.893, 0.093, 0.177), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lasersigmaedit+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.664, -2.139), angle = Angle(90, 0, 90), size = Vector(0.009, 0.009, 0.009), color = Color(154, 151, 153, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.537, 16.999), angle = Angle(0, 0, 116.427), size = Vector(0.059, 0.103, 0.032), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol+++++++++++++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.006, 21.642), angle = Angle(-90, 90, 180), size = Vector(1.376, 1.835, 1.228), color = Color(141, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/gravestone001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.904, -0.815, 19.048), angle = Angle(180, 0, -46.752), size = Vector(0.009, 0.009, 0.009), color = Color(101, 105, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["tyan"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.618, 12.409), angle = Angle(0, 90, 180), size = Vector(0.086, 0.057, 0.268), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.782, 14.76), angle = Angle(0, 0, 0), size = Vector(0.059, 0.071, 0.035), color = Color(141, 146, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -5.979, 19.54), angle = Angle(0, 0, 108.749), size = Vector(0.063, 0.076, 0.09), color = Color(103, 108, 106, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stvol+++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.81, 18.017), angle = Angle(0, 0, 90.734), size = Vector(0.052, 0.116, 0.035), color = Color(111, 113, 111, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} }
}
SWEP.IronSightsPos = Vector(-6.166, -3.32, 1.12)
SWEP.IronSightsAng = Vector(0.043, -0.04, -0.894)

SWEP.Primary.Sound = Sound("Weapon_Shotpupoksaki.SingleHeavy") 
SWEP.Primary.Damage = 9.5
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.4

SWEP.Primary.ClipSize = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 5.625
SWEP.ConeMin = 4.875

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 3
sound.Add( {
	name = "Weapon_Shotpupoksaki.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 0.6,
	level = 70,
	pitch = 210,//{80,85},
	sound = "weapons/xm1014/xm1014-1.wav"
} )
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.51, 1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_ender_r1"), ""..translate.Get("weapon_zs_ender_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 5.5
	wept.Primary.NumShots = 1
	wept.ConeMin = wept.ConeMin * 0.15
	wept.ConeMax = wept.ConeMax * 0.3
end)

SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 1.2  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.5  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 17   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = true
SWEP.Recoil_Progressive_Max_Multiplier = 1.85
SWEP.Recoil_Progressive_Shot_Increment = 0.01
SWEP.Recoil_Progressive_Reset_Time = 0.2


-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 2.3 -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Percentage = 0.2 -- 恢复70%的后坐力, 剩下30%需要手动压
SWEP.Recoil_Recovery_Speed  = 3.8 -- 自动恢复的速度
SWEP.Recoil_Recovery_Time   = 0.1 -- 