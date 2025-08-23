AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = ""..translate.Get("weapon_zs_m4")
SWEP.Description = ""..translate.Get("weapon_zs_m4_description")
SWEP.Slot = 2
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = true
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.m4_Parent"
	SWEP.HUD3DPos = Vector(-1, -5, -5)
	SWEP.HUD3DAng = Angle(0, -5, -10)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(1.54, 1, -2) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, -0.5, 0), angle = Angle(-0.54, 0, 0) },
	["v_weapon.m4_Parent"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },

}

SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.VElements = {

	--------------------
	-- 核心 / 机匣 (Core / Receiver)
	--------------------
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "", pos = Vector(0.075, -4.651, -18.142), angle = Angle(-1.275, -6.612, 0), size = Vector(0.03, 0.03, 0.28), color = Color(139, 141, 138, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.167, 17.677), angle = Angle(0, 0, 0), size = Vector(0.075, 0.137, 0.451), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.169, 19.41), angle = Angle(0, 0, 42.525), size = Vector(0.075, 0.104, 0.135), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.008, 19.766), angle = Angle(0, 0, 0), size = Vector(0.075, 0.072, 0.144), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.091, 12.664), angle = Angle(0, 0, 0), size = Vector(0.045, 0.05, 0.152), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.091, 19.537), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.018), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.196, -0.098, 16.989), angle = Angle(14.508, 0, 0), size = Vector(0.029, 0.029, 0.054), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.728, -0.098, 18.743), angle = Angle(14.508, 0, 0), size = Vector(0.014, 0.014, 0.024), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++"] = { type = "Model", model = "models/props_junk/plasticbucket001a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.983, -0.099, 19.735), angle = Angle(14.508, 0, 0), size = Vector(0.039, 0.039, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -0.893, 16.062), angle = Angle(0, 0, 0), size = Vector(0.075, 0.037, 0.864), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -0.812, 16.062), angle = Angle(90, -90, 0), size = Vector(1.205, 1.299, 0.813), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.248, 15.71), angle = Angle(0, 0, 0), size = Vector(0.098, 0.115, 0.098), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.899, 14.248), angle = Angle(0, 0, 0), size = Vector(0.108, 0.166, 0.342), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 0.878, 12.85), angle = Angle(0, 0, 0), size = Vector(0.054, 0.02, 0.072), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 0.958, 15.083), angle = Angle(0, 0, 88.639), size = Vector(0.054, 0.02, 0.028), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.791, 0.875, 12.755), angle = Angle(90, 0, 0), size = Vector(0.014, 0.014, 0.035), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.42, -0.5, 16.523), angle = Angle(17.575, 0, 0), size = Vector(0.098, 0.098, 0.098), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.751, 0.479, 12.85), angle = Angle(0, 0, 0), size = Vector(0.009, 0.009, 0.075), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.556, -0.094, 16.166), angle = Angle(0, 0, 0), size = Vector(0.048, 0.097, 0.018), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.091, 12.345), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.014), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 3.078, 16.586), angle = Angle(0, 0, 0), size = Vector(0.035, 0.009, 0.206), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 2.003, 15.539), angle = Angle(0, 0, 41.062), size = Vector(0.071, 0.071, 0.071), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 2.571, 15.38), angle = Angle(0, 0, -19.043), size = Vector(0.071, 0.061, 0.071), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 2.806, 14.244), angle = Angle(0, 0, 5.09), size = Vector(0.138, 0.029, 0.365), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 2.395, 15.46), angle = Angle(0, 0, 4.679), size = Vector(0.071, 0.061, 0.071), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.368, 3, 15.654), angle = Angle(90, 0, 0), size = Vector(0.013, 0.013, 0.014), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.672, 15.09), angle = Angle(0, 0, 0), size = Vector(0.05, 0.014, 0.023), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 2.144, 17.756), angle = Angle(0, 0, -28.05), size = Vector(0.05, 0.054, 0.054), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.814, 17.496), angle = Angle(0, 0, 11.64), size = Vector(0.048, 0.054, 0.054), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 2.701, 17.759), angle = Angle(0, 0, 19.986), size = Vector(0.05, 0.054, 0.041), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 3.016, 17.75), angle = Angle(0, 0, 87.414), size = Vector(0.05, 0.083, 0.037), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.945, 17.087), angle = Angle(-32.82, 90, 180), size = Vector(0.054, 0.054, 0.134), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/MetalBucket01a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.058, 12.13), angle = Angle(179.559, 90, 180), size = Vector(0.146, 0.146, 0.056), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/tubes/circle4x4.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.091, 12.5), angle = Angle(0, 0, 0), size = Vector(0.013, 0.013, 0.013), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.062, 1.355, 15.876), angle = Angle(90, 0, 0), size = Vector(0.014, 0.019, 0.014), color = Color(81, 81, 81, 255), surpresslightning = false, material = "phoenix_storms/pack2/train_floor", skin = 0, bodygroup = {} },
	--["reciever_tryasun"] = { type = "Model", model = "models/props_trainstation/traincar_rack001.mdl", bone = "v_weapon.m4_Eject", rel = "", pos = Vector(0, -0.613, -0.429), angle = Angle(0, -101.689, 90), size = Vector(0.05, 0.025, 0.024), color = Color(125, 128, 121, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },

	--------------------
	-- 枪托 (Stock)
	--------------------
	["stock"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.08, 20.354), angle = Angle(180, -90, 180), size = Vector(0.048, 0.048, 0.009), color = Color(126, 126, 125, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stock+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 0, 20.566), angle = Angle(180, -90, 180), size = Vector(0.039, 0.039, 0.141), color = Color(126, 126, 125, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stock++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.087, 20.731), angle = Angle(180, -90, 180), size = Vector(0.05, 0.05, 0.14), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stock+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 0.711, 23.846), angle = Angle(180, -90, 180), size = Vector(0.052, 0.052, 0.754), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.769, 25.097), angle = Angle(130.621, -90, 180), size = Vector(0.052, 0.052, 0.601), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.662, 26.336), angle = Angle(180, 0, 180), size = Vector(0.043, 0.188, 0.137), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 3.315, 26.44), angle = Angle(180, 0, 180), size = Vector(0.043, 0.194, 0.116), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.34, 23.94), angle = Angle(180, 0, 180), size = Vector(0.037, 0.104, 0.467), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.703, 23.191), angle = Angle(180, 0, 180), size = Vector(0.052, 0.071, 0.24), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock_mark"] = { type = "Model", model = "models/weapons/w_eq_eholster.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 1.516, 24.385), angle = Angle(0, 90, 180), size = Vector(0.782, 0.342, 0.695), color = Color(126, 126, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["stock_mark+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 3.533, 26.37), angle = Angle(0, 180, 180), size = Vector(0.064, 0.134, 0.532), color = Color(123, 123, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["stock_mark++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, -0.055, 27.042), angle = Angle(0, 180, 180), size = Vector(0.064, 0.134, 0.36), color = Color(126, 125, 123, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },

	--------------------
	-- 握把 (Handle)
	--------------------
	["handle_skelet"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, -0.082, 5.217), angle = Angle(0, 0, 0), size = Vector(0.07, 0.085, 0.143), color = Color(181, 178, 179, 255), surpresslightning = false, material = "phoenix_storms/Future_vents", skin = 0, bodygroup = {}, active = false },
	["handle_magpul"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 0, 8.421), angle = Angle(90, 0, -90), size = Vector(0.061, 0.039, 0.041), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["handle_magpul+"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.573, 8.421), angle = Angle(90, 0, -90), size = Vector(1.421, 1.355, 1.421), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["handle_magpul++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.644, -0.093, 8.421), angle = Angle(90, 90, -90), size = Vector(1.421, 1.355, 1.421), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["handle_magpul+++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.602, -0.093, 8.421), angle = Angle(90, -90, -90), size = Vector(1.421, 1.355, 1.421), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },

	--------------------
	-- 前握把 (Foregrip)
	--------------------
	["foregrip_skeleton"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 2.546, 18.62), angle = Angle(0, 0, 0), size = Vector(0.07, 0.13, 0.19), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 4.007, 20.073), angle = Angle(0, 0, 56.181), size = Vector(0.07, 0.05, 0.421), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 4.408, 19.02), angle = Angle(0, 0, 56.181), size = Vector(0.07, 0.039, 0.377), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 5.552, 20.479), angle = Angle(0, 0, 63.895), size = Vector(0.07, 0.15, 0.054), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 4.1, 19.482), angle = Angle(0, 0, 63.895), size = Vector(0.07, 0.128, 0.059), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_mark"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 1.613, 19.416), angle = Angle(0, 0, 40.501), size = Vector(0.078, 0.118, 0.078), color = Color(144, 125, 121, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["foregrip_mark+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 5.215, 20.222), angle = Angle(0, 0, 65.353), size = Vector(0.078, 0.096, 0.018), color = Color(144, 125, 121, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["foregrip_normal"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 4.224, 19.513), angle = Angle(0, 0, -34.656), size = Vector(0.071, 0.27, 0.092), color = Color(144, 125, 116, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["foregrip_normal+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, 5.993, 19.513), angle = Angle(0, 0, -26.848), size = Vector(0.071, 0.041, 0.067), color = Color(144, 125, 116, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	
	--------------------
	-- 弹匣 (Magazine)
	--------------------
	["mag"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Clip", rel = "", pos = Vector(-0.246, 0.635, -0.29), angle = Angle(0, -8.188, 0), size = Vector(0.079, 0.263, 0.326), color = Color(201, 201, 201, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["mag+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Clip", rel = "", pos = Vector(-0.556, 3.142, -0.5), angle = Angle(0, -8.188, 8.534), size = Vector(0.075, 0.24, 0.326), color = Color(201, 202, 202, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },

	--------------------
	-- 枪口 / 消音器 (Muzzle / Silencer)
	--------------------
	["muzzlehui"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, -1.066, 4.797), angle = Angle(180, 180, 90), size = Vector(0.072, 0.072, 0.072), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false  },
	["muzzlehui+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, -2.26, 4.46), angle = Angle(180, 180, 90), size = Vector(0.009, 0.009, 0.012), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["muzzlehui++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(-0.241, -2.28, 4.46), angle = Angle(180, 180, 90), size = Vector(0.019, 0.019, 0.019), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["muzzlehui+++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.24, -2.274, 4.46), angle = Angle(180, 180, 90), size = Vector(0.019, 0.019, 0.019), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	--["sosilence"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -0.082, -2.25), angle = Angle(0, 0, 0), size = Vector(0.159, 0.159, 0.094), color = Color(131, 131, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false  },
	["sosilence+"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "v_weapon.m4_Silencer", rel = "stvol", pos = Vector(0, -0.082, 1.014), angle = Angle(0, 0, 0), size = Vector(0.104, 0.104, 0.263), color = Color(131, 131, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false  },
	--	["sosilence++"] = { type = "Model", model = "models/props_lab/tpplug.mdl", bone = "v_weapon.m4_Silencer", rel = "stvol", pos = Vector(0, -0.082, -6.94), angle = Angle(90, 0, 0), size = Vector(0.202, 0.187, 0.393), color = Color(131, 131, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false  },

	--------------------
	-- 瞄具 (Sights)
	--------------------
	-- Sights "Who Cares" Group
	["sights_whocares"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -1.418, 16.002), angle = Angle(0, 180, 90), size = Vector(0.125, 0.347, 0.024), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -1.591, 13.012), angle = Angle(0, 180, 90), size = Vector(0.104, 0.032, 0.043), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares++"] = { type = "Model", model = "models/mechanics/solid_steel/u_beam_12.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -2.306, 15.633), angle = Angle(0, 180, 93.474), size = Vector(0.064, 0.035, 0.041), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares+++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -1.821, 18.636), angle = Angle(0, 180, 90), size = Vector(0.104, 0.071, 0.02), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.398, -2.309, 18.636), angle = Angle(0, 180, 90), size = Vector(0.014, 0.086, 0.093), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.253, -2.309, 18.636), angle = Angle(0, 180, 90), size = Vector(0.014, 0.086, 0.093), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares+++++++"] = { type = "Model", model = "models/props_vehicles/tire001a_tractor.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.079, -2.389, 18.636), angle = Angle(90, 90, 0), size = Vector(0.009, 0.009, 0.009), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sights_whocares++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_24t3.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0.638, -2.31, 18.687), angle = Angle(90, 0, 0), size = Vector(0.014, 0.014, 0.014), color = Color(123, 118, 120, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	
	-- Sights "Reflux" Group
	["reflux"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -1.333, 15.619), angle = Angle(0, 0, 0), size = Vector(0.079, 0.043, 0.483), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	["reflux+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -1.42, 14.845), angle = Angle(0, 0, -90), size = Vector(0.112, 0.112, 0.018), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	["reflux++"] = { type = "Model", model = "models/hunter/tubes/tube2x2x025d.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.684, -2.185, 14.626), angle = Angle(0, -13.323, 0), size = Vector(0.025, 0.025, 0.025), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["reflux+++"] = { type = "Model", model = "models/hunter/tubes/tube2x2x025d.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(-0.524, -2.095, 14.626), angle = Angle(0, 108.412, 0), size = Vector(0.025, 0.025, 0.025), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	["reflux++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -2.458, 14.579), angle = Angle(0, 0.902, 0), size = Vector(0.089, 0.009, 0.041), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	["reflux+++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -1.555, 17.106), angle = Angle(-90, 90, 0), size = Vector(0.009, 0.019, 0.009), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	["reflux++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -2.06, 14.579), angle = Angle(0, 0, 0), size = Vector(0.012, 0.012, 0.009), color = Color(255, 255, 255, 255), surpresslightning = true, material = "red", skin = 0, bodygroup = {} , active = true},
	["reflux+++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_18t1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -1.563, 15.909), angle = Angle(-90, 90, 0), size = Vector(0.02, 0.02, 0.02), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	["reflux++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -1.333, 15.619), angle = Angle(0, 0, 0), size = Vector(0.079, 0.043, 0.483), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = true},
	
	-- Sights "Tango" Group
	["tango"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -2.353, 16.17), angle = Angle(0, 0, 0), size = Vector(0.261, 0.261, 0.395), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -1.67, 16.052), angle = Angle(180, 0, -90), size = Vector(0.104, 0.122, 0.046), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["tango++"] = { type = "Model", model = "models/props_junk/garbage_glassbottle003a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -2.399, 18.665), angle = Angle(180, 0, 0), size = Vector(0.328, 0.328, 0.328), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+++"] = { type = "Model", model = "models/props_junk/garbage_glassbottle003a.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -2.399, 12.777), angle = Angle(0, 0, 0), size = Vector(0.328, 0.328, 0.247), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_24t3.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -2.905, 15.942), angle = Angle(0, 0, 90), size = Vector(0.009, 0.009, 0.019), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["tango++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_24t3.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.51, -2.313, 16.021), angle = Angle(0, 90, 90), size = Vector(0.014, 0.014, 0.014), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+++++++"] = { type = "Model", model = "models/rtcircle.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-0.003, -2.396, 21.384), angle = Angle(90, 180, 90), size = Vector(0.266, 0.266, 0.266), color = Color(255, 255, 255, 255), surpresslightning = false, material = "!tfa_rtmaterial", skin = 0, bodygroup = {} , active = false},
	["tango++++++++"] = { type = "Model", model = "models/rtcircle.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -2.3, 19.84), angle = Angle(90, 180, 90), size = Vector(0.291, 0.291, 0.291), color = Color(255, 255, 255, 255), surpresslightning = false, material = "!tfa_rtmaterial", skin = 0, bodygroup = {} , active = false},

	--------------------
	-- 配件 (Accessories)
	--------------------
	["tyan"] = { type = "Model", model = "models/hunter/misc/roundthing2.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -1.134, 19.762), angle = Angle(90, 90, 0), size = Vector(0.009, 0.009, 0.009), color = Color(125, 125, 126, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lasersigmaedit+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-1.79, -0.069, 6.227), angle = Angle(90, 0, 0), size = Vector(0.023, 0.023, 0.023), color = Color(141, 139, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["laserbeam"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(-1.943, 0, 4.796), angle = Angle(-90, 180, 0), size = Vector(0.493, 0.493, 0.493), color = Color(141, 139, 144, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}, active = true },
	--	["acock"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, -2.293, 18.502), angle = Angle(0, 0, 0), size = Vector(0.409, 0.409, 0.409), color = Color(141, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	--	["acock+"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, -2.293, 14.84), angle = Angle(0, 0, 0), size = Vector(0.409, 0.409, 0.197), color = Color(141, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
}

SWEP.WElements = {

	--------------------
	-- 核心 / 机匣 (Core / Receiver)
	--------------------
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(22.183, 0.811, -6.818), angle = Angle(1.069, 88.811, -80.308), size = Vector(0.03, 0.03, 0.28), color = Color(139, 141, 138, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.167, 17.677), angle = Angle(0, 0, 0), size = Vector(0.075, 0.137, 0.451), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.169, 19.41), angle = Angle(0, 0, 42.525), size = Vector(0.075, 0.104, 0.135), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.008, 19.766), angle = Angle(0, 0, 0), size = Vector(0.075, 0.072, 0.144), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.091, 12.664), angle = Angle(0, 0, 0), size = Vector(0.045, 0.05, 0.152), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.091, 19.537), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.018), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.196, -0.098, 16.989), angle = Angle(14.508, 0, 0), size = Vector(0.029, 0.029, 0.054), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.728, -0.098, 18.743), angle = Angle(14.508, 0, 0), size = Vector(0.014, 0.014, 0.024), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++"] = { type = "Model", model = "models/props_junk/plasticbucket001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.983, -0.099, 19.735), angle = Angle(14.508, 0, 0), size = Vector(0.039, 0.039, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -0.893, 16.062), angle = Angle(0, 0, 0), size = Vector(0.075, 0.037, 0.864), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -0.812, 16.062), angle = Angle(90, -90, 0), size = Vector(1.205, 1.299, 0.813), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.248, 15.71), angle = Angle(0, 0, 0), size = Vector(0.098, 0.115, 0.098), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.899, 14.248), angle = Angle(0, 0, 0), size = Vector(0.108, 0.166, 0.342), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.878, 12.85), angle = Angle(0, 0, 0), size = Vector(0.054, 0.02, 0.072), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.958, 15.083), angle = Angle(0, 0, 88.639), size = Vector(0.054, 0.02, 0.028), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.791, 0.875, 12.755), angle = Angle(90, 0, 0), size = Vector(0.014, 0.014, 0.035), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.42, -0.5, 16.523), angle = Angle(17.575, 0, 0), size = Vector(0.098, 0.098, 0.098), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.751, 0.479, 12.85), angle = Angle(0, 0, 0), size = Vector(0.009, 0.009, 0.075), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.556, -0.094, 16.166), angle = Angle(0, 0, 0), size = Vector(0.048, 0.097, 0.018), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.091, 12.345), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.014), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 3.078, 16.586), angle = Angle(0, 0, 0), size = Vector(0.035, 0.009, 0.206), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.003, 15.539), angle = Angle(0, 0, 41.062), size = Vector(0.071, 0.071, 0.071), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.571, 15.38), angle = Angle(0, 0, -19.043), size = Vector(0.071, 0.061, 0.071), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.806, 14.244), angle = Angle(0, 0, 5.09), size = Vector(0.138, 0.029, 0.365), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.395, 15.46), angle = Angle(0, 0, 4.679), size = Vector(0.071, 0.061, 0.071), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.368, 3, 15.654), angle = Angle(90, 0, 0), size = Vector(0.013, 0.013, 0.014), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.672, 15.09), angle = Angle(0, 0, 0), size = Vector(0.05, 0.014, 0.023), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.144, 17.756), angle = Angle(0, 0, -28.05), size = Vector(0.05, 0.054, 0.054), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.814, 17.496), angle = Angle(0, 0, 11.64), size = Vector(0.048, 0.054, 0.054), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.701, 17.759), angle = Angle(0, 0, 19.986), size = Vector(0.05, 0.054, 0.041), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 3.016, 17.75), angle = Angle(0, 0, 87.414), size = Vector(0.05, 0.083, 0.037), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.945, 17.087), angle = Angle(-32.82, 90, 180), size = Vector(0.054, 0.054, 0.134), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_junk/MetalBucket01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.058, 12.13), angle = Angle(179.559, 90, 180), size = Vector(0.146, 0.146, 0.056), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/tubes/circle4x4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.091, 12.5), angle = Angle(0, 0, 0), size = Vector(0.013, 0.013, 0.013), color = Color(131, 133, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },

	--------------------
	-- 枪托 (Stock)
	--------------------
	["stock"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.08, 20.354), angle = Angle(180, -90, 180), size = Vector(0.048, 0.048, 0.009), color = Color(126, 126, 125, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stock+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0, 20.566), angle = Angle(180, -90, 180), size = Vector(0.039, 0.039, 0.141), color = Color(126, 126, 125, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stock++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.087, 20.731), angle = Angle(180, -90, 180), size = Vector(0.05, 0.05, 0.14), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stock+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.711, 23.846), angle = Angle(180, -90, 180), size = Vector(0.052, 0.052, 0.754), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.769, 25.097), angle = Angle(130.621, -90, 180), size = Vector(0.052, 0.052, 0.601), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.662, 26.336), angle = Angle(180, 0, 180), size = Vector(0.043, 0.188, 0.137), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 3.315, 26.44), angle = Angle(180, 0, 180), size = Vector(0.043, 0.194, 0.116), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.34, 23.94), angle = Angle(180, 0, 180), size = Vector(0.037, 0.104, 0.467), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.703, 23.191), angle = Angle(180, 0, 180), size = Vector(0.052, 0.071, 0.24), color = Color(126, 126, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["stock_mark"] = { type = "Model", model = "models/weapons/w_eq_eholster.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.516, 24.385), angle = Angle(0, 90, 180), size = Vector(0.782, 0.342, 0.695), color = Color(126, 126, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["stock_mark+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 3.533, 26.37), angle = Angle(0, 180, 180), size = Vector(0.064, 0.134, 0.532), color = Color(123, 123, 125, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false  },
	["stock_mark++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.055, 27.042), angle = Angle(0, 180, 180), size = Vector(0.064, 0.134, 0.36), color = Color(126, 125, 123, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },

	--------------------
	-- 握把 (Handle)
	--------------------
	["handle_skelet"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.082, 5.217), angle = Angle(0, 0, 0), size = Vector(0.07, 0.085, 0.136), color = Color(181, 178, 179, 255), surpresslightning = false, material = "phoenix_storms/Future_vents", skin = 0, bodygroup = {}, active = false },
	["handle_magpul"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0, 8.421), angle = Angle(90, 0, -90), size = Vector(0.061, 0.039, 0.041), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} , active = true },
	["handle_magpul+"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.573, 8.421), angle = Angle(90, 0, -90), size = Vector(1.421, 1.355, 1.421), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["handle_magpul++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.644, -0.093, 8.421), angle = Angle(90, 90, -90), size = Vector(1.421, 1.355, 1.421), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },
	["handle_magpul+++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.602, -0.093, 8.421), angle = Angle(90, -90, -90), size = Vector(1.421, 1.355, 1.421), color = Color(144, 146, 144, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },

	--------------------
	-- 前握把 (Foregrip)
	--------------------
	["foregrip_skeleton"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.546, 18.62), angle = Angle(0, 0, 0), size = Vector(0.07, 0.13, 0.19), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 4.007, 20.073), angle = Angle(0, 0, 56.181), size = Vector(0.07, 0.05, 0.421), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 4.408, 19.02), angle = Angle(0, 0, 56.181), size = Vector(0.07, 0.039, 0.377), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 5.552, 20.479), angle = Angle(0, 0, 63.895), size = Vector(0.07, 0.15, 0.054), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_skeleton++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 4.1, 19.482), angle = Angle(0, 0, 63.895), size = Vector(0.07, 0.128, 0.059), color = Color(141, 125, 126, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["foregrip_mark"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.613, 19.416), angle = Angle(0, 0, 40.501), size = Vector(0.078, 0.118, 0.078), color = Color(144, 125, 121, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["foregrip_mark+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 5.215, 20.222), angle = Angle(0, 0, 65.353), size = Vector(0.078, 0.096, 0.018), color = Color(144, 125, 121, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = false },
	["foregrip_normal"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 4.224, 19.513), angle = Angle(0, 0, -34.656), size = Vector(0.071, 0.27, 0.092), color = Color(144, 125, 116, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} , active = true},
	["foregrip_normal+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 5.993, 19.513), angle = Angle(0, 0, -26.848), size = Vector(0.071, 0.041, 0.067), color = Color(144, 125, 116, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, active = true },

	--------------------
	-- 弹匣 (Magazine)
	--------------------
	["mag"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 3.769, 14.187), angle = Angle(0, 0, 0), size = Vector(0.079, 0.263, 0.326), color = Color(201, 201, 201, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },
	["mag+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 5.781, 13.913), angle = Angle(0, 0, 16.746), size = Vector(0.074, 0.195, 0.324), color = Color(201, 202, 202, 255), surpresslightning = false, material = "models/gibs/metalgibs/metal_gibs", skin = 0, bodygroup = {} },

	--------------------
	-- 枪口 / 消音器 (Muzzle / Silencer)
	--------------------
	["muzzlehui"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.066, 4.797), angle = Angle(180, 180, 90), size = Vector(0.072, 0.072, 0.072), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["muzzlehui+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.293, 4.46), angle = Angle(180, 180, 90), size = Vector(0.009, 0.009, 0.009), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["muzzlehui++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.241, -2.28, 4.46), angle = Angle(180, 180, 90), size = Vector(0.019, 0.019, 0.019), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["muzzlehui+++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.24, -2.274, 4.46), angle = Angle(180, 180, 90), size = Vector(0.019, 0.019, 0.019), color = Color(134, 129, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	--["sosilence"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0, -1.864), angle = Angle(0, 0, 0), size = Vector(0.159, 0.159, 0.094), color = Color(131, 131, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["sosilence+"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.082, 1.014), angle = Angle(0, 0, 0), size = Vector(0.104, 0.104, 0.263), color = Color(131, 131, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false  },
	--["sosilence++"] = { type = "Model", model = "models/props_lab/tpplug.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.082, -6.94), angle = Angle(90, 0, 0), size = Vector(0.202, 0.187, 0.393), color = Color(131, 131, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false  },

	--------------------
	-- 瞄具 (Sights)
	--------------------
	-- Sights "Who Cares" Group
	["sights_whocares"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.418, 16.002), angle = Angle(0, 180, 90), size = Vector(0.125, 0.347, 0.024), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["sights_whocares+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.591, 13.012), angle = Angle(0, 180, 90), size = Vector(0.104, 0.032, 0.043), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["sights_whocares++"] = { type = "Model", model = "models/mechanics/solid_steel/u_beam_12.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -2.306, 15.633), angle = Angle(0, 180, 93.474), size = Vector(0.064, 0.035, 0.041), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["sights_whocares+++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.821, 18.636), angle = Angle(0, 180, 90), size = Vector(0.104, 0.071, 0.02), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true},
	["sights_whocares+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.398, -2.309, 18.636), angle = Angle(0, 180, 90), size = Vector(0.014, 0.086, 0.093), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["sights_whocares++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.253, -2.309, 18.636), angle = Angle(0, 180, 90), size = Vector(0.014, 0.086, 0.093), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["sights_whocares+++++++"] = { type = "Model", model = "models/props_vehicles/tire001a_tractor.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -2.389, 18.636), angle = Angle(90, 90, 0), size = Vector(0.009, 0.009, 0.009), color = Color(144, 141, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["sights_whocares++++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_24t3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.638, -2.31, 18.687), angle = Angle(90, 0, 0), size = Vector(0.014, 0.014, 0.014), color = Color(123, 118, 120, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },

	-- Sights "Reflux" Group
	["reflux"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.333, 15.619), angle = Angle(0, 0, 0), size = Vector(0.079, 0.043, 0.483), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["reflux+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.42, 14.845), angle = Angle(0, 0, -90), size = Vector(0.112, 0.112, 0.018), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["reflux++"] = { type = "Model", model = "models/hunter/tubes/tube2x2x025d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.684, -2.185, 14.626), angle = Angle(0, -13.323, 0), size = Vector(0.025, 0.025, 0.025), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["reflux+++"] = { type = "Model", model = "models/hunter/tubes/tube2x2x025d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.524, -2.095, 14.626), angle = Angle(0, 108.412, 0), size = Vector(0.025, 0.025, 0.025), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["reflux++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -2.458, 14.579), angle = Angle(0, 0.902, 0), size = Vector(0.089, 0.009, 0.041), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["reflux+++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.555, 17.106), angle = Angle(-90, 90, 0), size = Vector(0.009, 0.019, 0.009), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["reflux++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -2.06, 14.579), angle = Angle(0, 0, 0), size = Vector(0.019, 0.019, 0.009), color = Color(255, 255, 255, 255), surpresslightning = true, material = "red", skin = 0, bodygroup = {} , active = false},
	["reflux+++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_18t1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.563, 15.909), angle = Angle(-90, 90, 0), size = Vector(0.02, 0.02, 0.02), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["reflux++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.333, 15.619), angle = Angle(0, 0, 0), size = Vector(0.079, 0.043, 0.483), color = Color(136, 133, 131, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	
	-- Sights "Tango" Group
	["tango"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.353, 16.17), angle = Angle(0, 0, 0), size = Vector(0.261, 0.261, 0.395), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.67, 16.052), angle = Angle(180, 0, -90), size = Vector(0.104, 0.122, 0.046), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["tango++"] = { type = "Model", model = "models/props_junk/garbage_glassbottle003a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.399, 18.665), angle = Angle(180, 0, 0), size = Vector(0.328, 0.328, 0.328), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+++"] = { type = "Model", model = "models/props_junk/garbage_glassbottle003a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.399, 12.777), angle = Angle(0, 0, 0), size = Vector(0.328, 0.328, 0.247), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["tango+++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_24t3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.905, 15.942), angle = Angle(0, 0, 90), size = Vector(0.009, 0.009, 0.019), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
	["tango++++++"] = { type = "Model", model = "models/Mechanics/gears2/gear_24t3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.51, -2.313, 16.021), angle = Angle(0, 90, 90), size = Vector(0.014, 0.014, 0.014), color = Color(163, 164, 163, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },

	--------------------
	-- 配件 (Accessories)
	--------------------
	["tyan"] = { type = "Model", model = "models/hunter/misc/roundthing2.mdl", bone = "v_weapon.m4_Parent", rel = "stvol", pos = Vector(0, -1.134, 19.762), angle = Angle(90, 90, 0), size = Vector(0.009, 0.009, 0.009), color = Color(125, 125, 126, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lasersigmaedit+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-1.79, -0.069, 6.227), angle = Angle(90, 0, 0), size = Vector(0.023, 0.023, 0.023), color = Color(141, 139, 144, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	--["acock"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.293, 18.502), angle = Angle(0, 0, 0), size = Vector(0.409, 0.409, 0.409), color = Color(141, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	--["acock+"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.293, 14.84), angle = Angle(0, 0, 0), size = Vector(0.409, 0.409, 0.197), color = Color(141, 143, 143, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} , active = false},
}
--[[
-- 默认机械瞄准位置和角度
SWEP.IronSightsPos = Vector(-7.461, -7.408, 0.959)
SWEP.IronSightsAng = Vector(1.08, -1.371, -2.358)

-- "Reflux" 瞄具的瞄准位置和角度
SWEP.IronSightsPos_Reflux = Vector(-7.2175, -7.408, 1.4859)
SWEP.IronSightsAng_Reflux = Vector( 0, 0, -2.358)

-- "Tango" 瞄具的瞄准位置和角度
SWEP.IronSightsPos_Tango = Vector(-7.289, -9.008, 1.03)
SWEP.IronSightsAng_Tango = Vector(0, 0, -2.358)

-- "Pritsel" 瞄具的瞄准位置和角度
SWEP.IronSightsPos_Pritsel= Vector(-7.2589, -9.408, 1.153)
SWEP.IronSightsAng_Pritsel = Vector(0, 0, -2.358)

-- 检视武器的位置和角度
SWEP.InspectPos = Vector(5.464, -4.119, -4.261)
SWEP.InspectAng = Vector(24.42, 37.2, 6.224)

-- 跑动时的瞄准位置和角度
SWEP.RunSightsPos = Vector(-4.415, -6.211, -6.408)
SWEP.RunSightsAng = Vector(31.179, 1.087, -13.81)
]]
SWEP.IronSightsPos = Vector(-7.63, -2, 1.495)
SWEP.IronSightsAng = Angle( 0, -1.5, -1.23)

sound.Add( {
	name = "Weapon_Pyatnadtsat.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 120,//{80,85},
	sound = "weapons/m4a1/m4a1_unsil-1.wav"
} )
sound.Add( {
	name = "Weapon_PyatnadtsatSosilence.SingleHeavy",
	channel = CHAN_WEAoPON,
	volume = 0.7,
	level = 100,
	pitch = 150,//{80,85},
	sound = "weapons/usp/usp_unsil-1.wav"
} )
sound.Add( {
	name = "Weapon_PyatnadtsatMark.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = 150,//{80,85},
	sound = "weapons/sg550/sg550-1.wav"
} )
SWEP.Primary.Sound = Sound("Weapon_PyatnadtsatSosilence.SingleHeavy") 
SWEP.Primary.Damage = 24.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.11

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 5
SWEP.ConeMin = 1.5

SWEP.WalkSpeed = SPEED_SLOW

SWEP.Tier = 4
SWEP.MaxStock = 3


GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.625)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.187)
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_m4_r1"), ""..translate.Get("weapon_zs_m4_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 1.1
	wept.Primary.Delay = wept.Primary.Delay * 5.7
	wept.Primary.BurstShots = 3
	wept.ConeMin = wept.ConeMin * 0.6
	wept.ConeMax = wept.ConeMax * 0.5

	wept.PrimaryAttack = function(self)
		if not self:CanPrimaryAttack() then return end

		self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
		self:EmitFireSound()

		self:SetNextShot(CurTime())
		self:SetShotsLeft(self.Primary.BurstShots)

		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end

	wept.Think = function(self)
		BaseClass.Think(self)

		local shotsleft = self:GetShotsLeft()
		if shotsleft > 0 and CurTime() >= self:GetNextShot() then
			self:SetShotsLeft(shotsleft - 1)
			self:SetNextShot(CurTime() + self:GetFireDelay()/6)

			if self:Clip1() > 0 and self:GetReloadFinish() == 0 then
				self:EmitFireSound()
				self:TakeAmmo()
				self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())

				self.IdleAnimation = CurTime() + self:SequenceDuration()
			else
				self:SetShotsLeft(0)
			end
		end
	end

	wept.EmitFireSound = function(self)
		self:EmitSound("weapons/m4a1/m4a1_unsil-1.wav", 75, math.random(82, 86), 0.75)
		self:EmitSound("weapons/galil/galil-1.wav", 75, math.random(154, 156), 0.6, CHAN_WEAPON + 20)
	end

	if CLIENT then
		wept.VElements = {
			["lol"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top", pos = Vector(0.317, 0.012, -15.013), angle = Angle(180, 90, 180), size = Vector(0.201, 0.115, 0.261), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["SCOPE1"] = { type = "Model", model = "models/props_wasteland/light_spotlight01_lamp.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "LOL2", pos = Vector(-0.899, -0.706, -0.01), angle = Angle(0, -180, 90), size = Vector(0.136, 0.079, 0.079), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["LOL2"] = { type = "Model", model = "models/Mechanics/robotics/d1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "grip", pos = Vector(-6.801, 0.108, 2.618), angle = Angle(0, 0, 90), size = Vector(0.071, 0.056, 0.048), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["top"] = { type = "Model", model = "models/props_c17/FurnitureBoiler001a.mdl", bone = "v_weapon.m4_Parent", rel = "", pos = Vector(0.092, -4.251, -17.129), angle = Angle(-1.66, -8.7, 180), size = Vector(0.054, 0.054, 0.087), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["SCOPE1+"] = { type = "Model", model = "models/props_wasteland/light_spotlight01_lamp.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "SCOPE1", pos = Vector(-0.916, 0, 0), angle = Angle(0, 180, 0), size = Vector(0.136, 0.079, 0.079), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["grip"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top", pos = Vector(0.017, 0.479, -8.181), angle = Angle(90, 90, 0), size = Vector(0.063, 0.061, 0.057), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["rail"] = { type = "Model", model = "models/combine_apc.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "lol", pos = Vector(-0.225, 0.217, 1.909), angle = Angle(0, 90, 90), size = Vector(0.02, 0.045, 0.035), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["GLASS"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "SCOPE1", pos = Vector(0.37, 0, 0.319), angle = Angle(0, 0, 0), size = Vector(2.65, 0.027, 0.027), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_models/snip_awp/v_awp_scope", skin = 0, bodygroup = {} }
		}

		wept.WElements = {
			["GLASS"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "SCOPE1", pos = Vector(0.37, 0, 0.319), angle = Angle(0, 0, 0), size = Vector(2.65, 0.027, 0.027), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/weapons/v_models/snip_awp/v_awp_scope", skin = 0, bodygroup = {} },
			["SCOPE1"] = { type = "Model", model = "models/props_wasteland/light_spotlight01_lamp.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "LOL2", pos = Vector(-0.899, -0.706, -0.01), angle = Angle(0, -180, 90), size = Vector(0.136, 0.079, 0.079), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["LOL2"] = { type = "Model", model = "models/Mechanics/robotics/d1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "grip", pos = Vector(-9.316, 0.108, 2.97), angle = Angle(0, 0, 90), size = Vector(0.071, 0.056, 0.048), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["top"] = { type = "Model", model = "models/props_c17/FurnitureBoiler001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(23.756, 0.8, -6.969), angle = Angle(0, 90, 99.805), size = Vector(0.054, 0.054, 0.128), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["SCOPE1+"] = { type = "Model", model = "models/props_wasteland/light_spotlight01_lamp.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "SCOPE1", pos = Vector(-0.916, 0, 0), angle = Angle(0, 180, 0), size = Vector(0.136, 0.079, 0.079), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["grip"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top", pos = Vector(-0.062, 0.479, -8.021), angle = Angle(90, 90, 0), size = Vector(0.072, 0.061, 0.057), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["RAIL"] = { type = "Model", model = "models/combine_apc.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "lol", pos = Vector(0.172, 0.31, 1.508), angle = Angle(0, 90, 90), size = Vector(0.019, 0.054, 0.032), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
			["lol"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top", pos = Vector(0.393, 0.192, -17.122), angle = Angle(180, 90, 180), size = Vector(0.21, 0.115, 0.372), color = Color(175, 175, 165, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
		}

		wept.HUD3DPos = Vector(-1.2, -5, -1.2)
	end
end)
branch.Killicon = "weapon_zs_aspirant"

function SWEP:SetNextShot(nextshot)
	self:SetDTFloat(5, nextshot)
end

function SWEP:GetNextShot()
	return self:GetDTFloat(5)
end

function SWEP:SetShotsLeft(shotsleft)
	self:SetDTInt(1, shotsleft)
end

function SWEP:GetShotsLeft()
	return self:GetDTInt(1)
end

function SWEP:GetAuraRange()
	return 512
end
function SWEP:FireAnimationEvent( pos, ang, event, options )

	-- Disables animation based muzzle event
	--if ( event == 21 ) then return true end
	--if ( event == 20 ) then return true end

	-- Disable thirdperson muzzle flash
	if ( event == 5001 ) then return true end
	if ( event == 5003 ) then return true end
	if ( event == 5011 ) then return true end
	if ( event == 5021 ) then return true end
	if ( event == 5031 ) then return true end
	if ( event == 6001 ) then return true end
    
end
