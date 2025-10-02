AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = ""..translate.Get("weapon_zs_stubber")
SWEP.Description = ""..translate.Get("weapon_zs_stubber_description")

SWEP.SlotPos = 0
 
if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.awm_parent"
	SWEP.HUD3DPos = Vector(-1.6, -3.5, -15)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
SWEP.VElements = {
	["handle+++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 3.065, 26.465), angle = Angle(180, 0, -37.278), size = Vector(0.029, 0.061, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.awm_bolt_action", rel = "", pos = Vector(-0.241, 0.289, 0.405), angle = Angle(-90, 90, 0), size = Vector(0.014, 0.025, 0.025), color = Color(143, 143, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -0.113, 24.153), angle = Angle(90, 90, 180), size = Vector(0.019, 0.028, 0.02), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++++"] = { type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.882, 25.874), angle = Angle(0, 0, -180), size = Vector(0.426, 0.426, 0.367), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 2.39, 24.752), angle = Angle(180, 0, 0), size = Vector(0.029, 0.071, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.awm_clip", rel = "", pos = Vector(0, 1.072, -0.491), angle = Angle(0, 0, 0), size = Vector(0.105, 0.229, 0.402), color = Color(154, 149, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.316, 23.541), angle = Angle(180, 0, -90), size = Vector(0.086, 0.065, 0.05), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+"] = { type = "Model", model = "models/props_junk/MetalBucket01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 0.944, 18.635), angle = Angle(0, 0, 180), size = Vector(0.108, 0.141, 0.075), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lutiscope+++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_36t3.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -2.869, 22.663), angle = Angle(180, 0, -90), size = Vector(0.009, 0.009, 0.014), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.316, 20.65), angle = Angle(0, 0, -90), size = Vector(0.086, 0.065, 0.05), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 3, 24.87), angle = Angle(180, 0, 26.819), size = Vector(0.029, 0.061, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.awm_parent", rel = "", pos = Vector(-0.239, -4.212, -27.128), angle = Angle(0, 0, 0), size = Vector(0.037, 0.037, 0.397), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.awm_bolt_action", rel = "", pos = Vector(-0.241, 0.368, -3.461), angle = Angle(-90, 90, 0), size = Vector(0.054, 0.02, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt+"] = { type = "Model", model = "models/Gibs/HGIBS_spine.mdl", bone = "v_weapon.awm_bolt_action", rel = "", pos = Vector(-1.106, 0.425, 0.111), angle = Angle(-90, 90, 56.512), size = Vector(0.194, 0.194, 0.158), color = Color(141, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -0.532, 22.023), angle = Angle(90, 90, -180), size = Vector(1.001, 1.001, 0.493), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 2.105, 20.695), angle = Angle(180, 0, -95.741), size = Vector(0.1, 0.009, 0.1), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 0.976, 8.208), angle = Angle(0, 0, 0), size = Vector(0.068, 0.079, 0.219), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["barrel+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -0.013, -0.423), angle = Angle(90, 0, -90), size = Vector(0.021, 0.021, 0.021), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_36t3.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.882, 27.978), angle = Angle(180, 0, 0), size = Vector(0.019, 0.019, 0.019), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.882, 21.002), angle = Angle(180, 0, -180), size = Vector(0.03, 0.03, 0.071), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++"] = { type = "Model", model = "models/props_junk/MetalBucket01a.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.882, 24.77), angle = Angle(180, 0, -180), size = Vector(0.071, 0.071, 0.071), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++"] = { type = "Model", model = "models/props_c17/SuitCase_Passenger_Physics.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 1.103, 18.743), angle = Angle(0, 0, 180), size = Vector(0.052, 0.236, 0.476), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["sosilence"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, 0, -3.261), angle = Angle(0, 90, 0), size = Vector(0.064, 0.059, 0.467), color = Color(171, 173, 169, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {}, active = false },
	["handle++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 2.559, 26.684), angle = Angle(180, 0, -10.146), size = Vector(0.029, 0.052, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -0.113, 19.062), angle = Angle(90, 90, -90), size = Vector(0.025, 0.025, 0.025), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++"] = { type = "Model", model = "models/Gibs/HGIBS_spine.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 2.161, 27.993), angle = Angle(0, 0, 35.522), size = Vector(0.782, 0.602, 0.335), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle++++"] = { type = "Model", model = "models/props_c17/SuitCase_Passenger_Physics.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 3.717, 28.951), angle = Angle(0, 0, 160.944), size = Vector(0.057, 0.184, 0.087), color = Color(234, 255, 209, 0), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lutiscope+++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.882, 22.663), angle = Angle(180, 0, -90), size = Vector(0.026, 0.026, 0.026), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_48t3.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(-0.708, -1.961, 22.629), angle = Angle(90, 0, 0), size = Vector(0.009, 0.009, 0.014), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope+++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0.778, -1.961, 22.629), angle = Angle(90, 0, 0), size = Vector(0.035, 0.035, 0.035), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	--["scope"] = { type = "Model", model = "models/rtcircle.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.885, 28.305), angle = Angle(90, 0, -90), size = Vector(0.324, 0.324, 0.324), color = Color(255, 255, 255, 255), surpresslightning = false, material = "!tfa_rtmaterial", skin = 0, bodygroup = {} },
	["bolt++"] = { type = "Model", model = "models/hunter/misc/sphere025x025.mdl", bone = "v_weapon.awm_bolt_action", rel = "", pos = Vector(-1.979, 0.99, -0.04), angle = Angle(-90, 90, 56.512), size = Vector(0.089, 0.089, 0.089), color = Color(125, 125, 128, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 2.227, 25.951), angle = Angle(0, 90, 180), size = Vector(0.052, 0.052, 0.128), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 1.86, 23.459), angle = Angle(180, 180, 0), size = Vector(0.109, 0.035, 0.704), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 3.059, 34.145), angle = Angle(180, 180, 0), size = Vector(0.225, 0.225, 0.361), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 3.305, 25.659), angle = Angle(180, 0, 90), size = Vector(0.029, 0.137, 0.025), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(0, 2.114, 26.625), angle = Angle(180, 0, 28.59), size = Vector(0.029, 0.05, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++"] = { type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "v_weapon.awm_parent", rel = "barrel", pos = Vector(0, -1.882, 18.399), angle = Angle(180, 0, -180), size = Vector(0.5, 0.5, 0.602), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["handle+++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 3.065, 26.465), angle = Angle(180, 0, -37.278), size = Vector(0.029, 0.061, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.144, 1.12, -4.172), angle = Angle(-7.908, 0, 180), size = Vector(0.014, 0.025, 0.025), color = Color(143, 143, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel+++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -0.113, 24.153), angle = Angle(90, 90, 180), size = Vector(0.019, 0.028, 0.02), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++++"] = { type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.882, 25.874), angle = Angle(0, 0, -180), size = Vector(0.426, 0.426, 0.367), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.39, 24.752), angle = Angle(180, 0, 0), size = Vector(0.029, 0.071, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope+++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0.778, -1.961, 22.629), angle = Angle(90, 0, 0), size = Vector(0.035, 0.035, 0.035), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.316, 23.541), angle = Angle(180, 0, -90), size = Vector(0.086, 0.065, 0.05), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+"] = { type = "Model", model = "models/props_junk/MetalBucket01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 0.944, 18.635), angle = Angle(0, 0, 180), size = Vector(0.108, 0.141, 0.075), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lutiscope+++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_36t3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -2.869, 22.663), angle = Angle(180, 0, -90), size = Vector(0.009, 0.009, 0.014), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.316, 20.65), angle = Angle(0, 0, -90), size = Vector(0.086, 0.065, 0.05), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 3, 24.87), angle = Angle(180, 0, 26.819), size = Vector(0.029, 0.061, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(30.809, 1.151, -7.762), angle = Angle(0, 90, -81.982), size = Vector(0.037, 0.037, 0.397), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-0.053, -0.044, 21.933), angle = Angle(90, -90, 0), size = Vector(0.054, 0.02, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt++"] = { type = "Model", model = "models/hunter/misc/sphere025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-2.056, 0.541, 25.934), angle = Angle(0, 0, 0), size = Vector(0.089, 0.089, 0.089), color = Color(125, 125, 128, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel++"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -0.113, 19.062), angle = Angle(90, 90, -90), size = Vector(0.025, 0.025, 0.025), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.105, 20.695), angle = Angle(180, 0, -95.741), size = Vector(0.1, 0.009, 0.1), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 0.976, 8.208), angle = Angle(0, 0, 0), size = Vector(0.068, 0.079, 0.219), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["barrel+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-0.239, -0.113, -0.523), angle = Angle(90, 0, -90), size = Vector(0.021, 0.021, 0.021), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_36t3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.882, 27.978), angle = Angle(180, 0, 0), size = Vector(0.019, 0.019, 0.019), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.882, 21.002), angle = Angle(180, 0, -180), size = Vector(0.03, 0.03, 0.071), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lutiscope++++"] = { type = "Model", model = "models/props_junk/MetalBucket01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.882, 24.77), angle = Angle(180, 0, -180), size = Vector(0.071, 0.071, 0.071), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++"] = { type = "Model", model = "models/props_c17/SuitCase_Passenger_Physics.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 1.103, 18.743), angle = Angle(0, 0, 180), size = Vector(0.052, 0.236, 0.476), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lutiscope++"] = { type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.882, 18.399), angle = Angle(180, 0, -180), size = Vector(0.5, 0.5, 0.602), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.559, 26.684), angle = Angle(180, 0, -10.146), size = Vector(0.029, 0.052, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.114, 26.625), angle = Angle(180, 0, 28.59), size = Vector(0.029, 0.05, 0.029), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++"] = { type = "Model", model = "models/Gibs/HGIBS_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.161, 27.993), angle = Angle(0, 0, 35.522), size = Vector(0.782, 0.602, 0.335), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle++++"] = { type = "Model", model = "models/props_c17/SuitCase_Passenger_Physics.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 3.717, 28.951), angle = Angle(0, 0, 160.944), size = Vector(0.057, 0.184, 0.087), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["lutiscope+++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -1.882, 22.663), angle = Angle(180, 0, -90), size = Vector(0.026, 0.026, 0.026), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 3.305, 25.659), angle = Angle(180, 0, 90), size = Vector(0.029, 0.137, 0.025), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["bolt+"] = { type = "Model", model = "models/Gibs/HGIBS_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-0.663, 0, 25.906), angle = Angle(90, 0, 0), size = Vector(0.194, 0.194, 0.158), color = Color(141, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 1.86, 23.459), angle = Angle(180, 180, 0), size = Vector(0.109, 0.035, 0.704), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.227, 25.951), angle = Angle(0, 90, 180), size = Vector(0.052, 0.052, 0.128), color = Color(118, 116, 118, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["barrel++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, -0.532, 22.023), angle = Angle(90, 90, -180), size = Vector(1.001, 1.001, 0.493), color = Color(154, 158, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 3.059, 34.089), angle = Angle(180, 180, 0), size = Vector(0.225, 0.225, 0.361), color = Color(234, 255, 209, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["sosilence"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 0, -3.261), angle = Angle(0, 90, 0), size = Vector(0.064, 0.059, 0.467), color = Color(171, 173, 169, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {}, active = false },
	["lutiscope++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_48t3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-0.708, -1.961, 22.629), angle = Angle(90, 0, 0), size = Vector(0.009, 0.009, 0.014), color = Color(139, 138, 139, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0, 2.928, 22.643), angle = Angle(0, 0, 0), size = Vector(0.105, 0.229, 0.402), color = Color(154, 149, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} }
}
SWEP.UseHands = true
sound.Add( {
	name = "Weapon_SV308.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 90,//{80,85},
	sound = "weapons/scout/scout_fire-1.wav"
} )
sound.Add( {
	name = "Weapon_SV308.Sosali",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 200,//{80,85},
	sound = "weapons/galil/galil-1.wav"
} )
SWEP.IronSightsPos = Vector(-7.1831, -10.834, 2.747)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.IronSightsPos_Scope = Vector(-6.7045, -11.237, 2.799)
SWEP.IronSightsAng_Scope = Vector(0, 0, 0)

SWEP.Primary.SilencedSound = Sound("Weapon_SV308.Sosali") 
SWEP.ReloadSound = Sound("Weapon_Scout.ClipOut")
SWEP.Primary.Sound = Sound("Weapon_SV308.SingleHeavy")
SWEP.Primary.Damage = 55
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.25
SWEP.ReloadDelay = SWEP.Primary.Delay
 
SWEP.Primary.ClipSize = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 25

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

SWEP.ConeMax = 3.75
SWEP.ConeMin = 0

SWEP.IronSightsPos = Vector(5.015, -8, 2.52)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.WalkSpeed = SPEED_SLOW

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 85, 100)
end
SWEP.SniperRifle = true
if CLIENT then
	SWEP.IronsightsMultiplier = 0.25
	
	function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			return pos --+ ang:Up() * 256, ang
		end

		return BaseClass.GetViewModelPosition(self, pos, ang)
	end
	
	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			self:DrawRegularScope()
		end
	end
end
