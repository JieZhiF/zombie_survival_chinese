AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "Aldarhtf"
SWEP.Description = "Magnum pistol from famous action movie"

SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.p228_Slide"
	SWEP.HUD3DPos = Vector(-0.88, 0.35, 0)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end
--[[
//sosilence 消音器 tfa_htf_supp
红点瞄准镜 rumor
	["VElements"] = {
	["slide_base+++++"] = {
			["active"] = false
		},
	["slide_base+++++++"] = {
			["active"] = false
		},
		["rumor"] = {
			["active"] = true
		},
		["red_dot"] = {
			["active"] = true
		},
				["rumor+"] = {
			["active"] = true
		},
				["rumor++"] = {
			["active"] = true
		},
				["rumor+++"] = {
			["active"] = true
		},
				["rumor++++"] = {
			["active"] = true
		},
	},
	["WElements"] = {
		["slide_base+++++"] = {
			["active"] = false
		},
	["slide_base+++++++"] = {
			["active"] = false
		},
		["rumor"] = {
			["active"] = true
		}
	},

	killerwave红点瞄准镜
		["VElements"] = {
	["reflux++++"] = {
			["active"] = true
		},
	["reflux+++"] = {
			["active"] = true
		},
		["reflux++"] = {
			["active"] = true
		},
		["reflux+"] = {
			["active"] = true
		},
				["reflux"] = {
			["active"] = true
		},
	},
	["WElements"] = {
	["reflux++++"] = {
			["active"] = true
		},
	["reflux+++"] = {
			["active"] = true
		},
		["reflux++"] = {
			["active"] = true
		},
		["reflux+"] = {
			["active"] = true
		},
				["reflux"] = {
			["active"] = true
		},
	},
]]
SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["v_weapon.p228_Hammer"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.p228_Parent"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.p228_Slide"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.StandOffset = -1.5
SWEP.SCKMaterials = {}

SWEP.VElements = {
	["a_usm_base"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "", pos = Vector(0.1, -1.221, -0.465), angle = Angle(0, 0, 0), size = Vector(0.015, 0.015, 0.122), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-7e-05, -0.01538, -1.26367), angle = Angle(0, 0, 12.139), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00022, -0.15015, -1.60034), angle = Angle(0, 0, 53.319), size = Vector(0.015, 0.015, 0.02), color = Color(187, 187, 187, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00105, -0.67285, -1.69092), angle = Angle(0, 0, -90), size = Vector(0.015, 0.015, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00027, -0.00464, -1.5481), angle = Angle(0, 0, 12.63803), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00105, 0.39673, 2.41919), angle = Angle(0, 0, -16.287), size = Vector(0.034, 0.354, 0.126), color = Color(180, 180, 180, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00011, -1.55713, 0.6792), angle = Angle(-1e-05, -1e-05, 71.82499), size = Vector(0.035, 0.035, 0.094), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00049, -0.16089, 0.32153), angle = Angle(0, 0, -31.456), size = Vector(0.017, 0.017, 0.033), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00038, -0.16089, 0.59229), angle = Angle(-1e-05, -1e-05, 132.08199), size = Vector(0.017, 0.032, 0.027), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.02291, -1.44751, 1.92017), angle = Angle(0, 0, 0.65201), size = Vector(0.036, 0.069, 0.14), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.025, -1.7, -2.708), angle = Angle(90, -90, 0), size = Vector(0.14, 0.068, 0.089), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00018, -1.5498, 0.02612), angle = Angle(0, 0, 0), size = Vector(0.032, 0.062, 0.186), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++"] = { type = "Model", model = "models/props_c17/trappropeller_lever.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00095, -1.34375, -0.16528), angle = Angle(1e-05, -180, -17.25902), size = Vector(0.168, 0.168, 0.168), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00076, -1.07104, -1.54126), angle = Angle(-1e-05, -1e-05, 118.06499), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00031, -1.07104, -1.87329), angle = Angle(-1e-05, -1e-05, 73.56601), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00095, -1.89673, 2.27222), angle = Angle(-1e-05, -1e-05, 71.82499), size = Vector(0.035, 0.035, 0.094), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00135, -1.48926, 3.01563), angle = Angle(-1e-05, -1e-05, 113.33498), size = Vector(0.035, 0.035, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00054, -1.57031, 1.53027), angle = Angle(0, 0, 6.63099), size = Vector(0.035, 0.01, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00098, -1.32983, 3.58936), angle = Angle(0, 0, -4.103), size = Vector(0.035, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00033, -1.32983, 3.92993), angle = Angle(0, 0, -24.794), size = Vector(0.035, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0.00019, -1.71289, 2.52783), angle = Angle(0, 0, 58.90401), size = Vector(0.035, 0.035, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.024, -1.7, -5.884), angle = Angle(0, 0, 0), size = Vector(0.044, 0.044, 0.1), color = Color(98, 95, 95, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.023, -2.655, -4.208), angle = Angle(0, 0, 0), size = Vector(0.084, 0.084, 0.16), color = Color(98, 95, 95, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal4", skin = 0, bodygroup = {} },
	["lasers"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "a_usm_base", pos = Vector(-0.103, -4.484, 2.983), angle = Angle(0, 90, 180), size = Vector(0.047, 0.047, 0.228), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["lasers+"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "a_usm_base", pos = Vector(-0.10261, -4.48413, 2.12402), angle = Angle(3e-05, 89.99999, -180), size = Vector(0.411, 0.411, 0.411), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["lasers++"] = { type = "Model", model = "models/wystan/attachments_tfa/akrailmount.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "a_usm_base", pos = Vector(-0.28, -3.628, 0.227), angle = Angle(-90, 90, 0), size = Vector(0.53, 0.53, 0.893), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["lasers+++"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "a_usm_base", pos = Vector(-0.2, -4.443, -5.549), angle = Angle(-90, 90, 0), size = Vector(0.53, 0.53, 0.893), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {}, active = false},
	["lever"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.p228_Hammer", rel = "", pos = Vector(0.1, 0.078, 0.601), angle = Angle(0, 0, -30.089), size = Vector(0.039, 0.017, 0.055), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["maga"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.p228_Clip", rel = "", pos = Vector(0.15, 1.944, 0.734), angle = Angle(0, 180, 106.841), size = Vector(0.097, 0.097, 0.146), color = Color(182, 182, 182, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0, 0.568, -5.821), angle = Angle(90, 90, 180), size = Vector(0.4, 0.051, 0.126), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.291, -0.1, 1.053), angle = Angle(180, 180, 0), size = Vector(0.094, 0.078, 0.047), color = Color(106, 106, 106, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(1, -0.11, 0.353), angle = Angle(180, 180, 0), size = Vector(0.481, 0.109, 0.138), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.351, -0.1, 0.313), angle = Angle(180, 180, 0), size = Vector(0.086, 0.049, 0.137), color = Color(180, 180, 180, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.8, -0.48, 1.28), angle = Angle(180, 180, 0), size = Vector(0.016, 0.05, 0.03), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++"] = { type = "Model", model = "models/props_c17/concrete_barrier001a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(-4.315, -0.1, 0.888), angle = Angle(-0.46, 90, 0), size = Vector(0.015, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.8, 0.2506, 1.28), angle = Angle(180, 180, 0), size = Vector(0.016, 0.05, 0.03), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.718, -0.1, 0.635), angle = Angle(-90, 180, 177.526), size = Vector(0.074, 0.074, 0.074), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(3.787, 0.112, 0.751), angle = Angle(-90, 180, 0), size = Vector(0.2, 0.2, 0.276), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal4", skin = 0, bodygroup = {} },
	["rumor+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.119, -0.766, 0.328), angle = Angle(0, 0, 90), size = Vector(0.061, 0.115, 0.05), color = Color(128, 113, 116, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["rumor"] = { type = "Model", model = "models/mechanics/articulating/arm_base_b.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.456, -1.5, 0.328), angle = Angle(0, 0, 90), size = Vector(0.021, 0.057, 0.019), color = Color(128, 113, 116, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
    ["rumor+++"] = { type = "Model", model = "models/Mechanics/gears/gear16x12_small.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.533, -1.234, 0.62), angle = Angle(90, 180, 180), size = Vector(0.014, 0.014, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["rumor++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.14, -0.847, 0.964), angle = Angle(0, 0, 90), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["red_dot"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.14, -1.207, 0.064), angle = Angle(0, 0, 180), size = Vector(0.010, 0.010, 0.010), color = Color(255, 0, 0, 255), surpresslightning = true, material = "orange", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["sosilence"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(-4.944, 0, 0.624), angle = Angle(90, 180, 180), size = Vector(0.041, 0.041, 0.218), color = Color(81, 75, 81, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = false  },

}

SWEP.WElements = {
	
	["a_usm_base"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.287, 1.574, -1.166), angle = Angle(0, 90, -82.597), size = Vector(0.015, 0.015, 0.122), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.01392, -1.26318), angle = Angle(0, 0, 12.139), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.00098, -0.1499, -1.59888), angle = Angle(0, 0, 53.31898), size = Vector(0.015, 0.015, 0.02), color = Color(187, 187, 187, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00098, -0.67187, -1.69067), angle = Angle(0, 0, -89.99999), size = Vector(0.015, 0.015, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00049, -0.00464, -1.54858), angle = Angle(1e-05, -1e-05, 12.63798), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00128, 0.39746, 2.41895), angle = Angle(1e-05, -1e-05, -16.28699), size = Vector(0.034, 0.354, 0.126), color = Color(180, 180, 180, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00049, -1.5564, 0.67871), angle = Angle(1e-05, -1e-05, 71.82494), size = Vector(0.035, 0.035, 0.094), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.00043, -0.16113, 0.32227), angle = Angle(1e-05, -1e-05, -31.45602), size = Vector(0.017, 0.017, 0.033), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(6e-05, -0.16113, 0.59326), angle = Angle(0, 0, 132.082), size = Vector(0.017, 0.032, 0.027), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.02203, -1.44751, 1.9209), angle = Angle(1e-05, -1e-05, 0.65194), size = Vector(0.036, 0.069, 0.14), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.02496, -1.69995, -2.72754), angle = Angle(89.99998, -89.99998, 0), size = Vector(0.15, 0.068, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.5498, 0.02637), angle = Angle(0, 0, 0), size = Vector(0.032, 0.062, 0.186), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++"] = { type = "Model", model = "models/props_c17/trappropeller_lever.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00104, -1.34399, -0.16479), angle = Angle(0, -180, -17.259), size = Vector(0.168, 0.168, 0.168), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.07104, -1.54077), angle = Angle(0, 0, 118.06499), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00049, -1.0708, -1.87207), angle = Angle(1e-05, -1e-05, 73.56596), size = Vector(0.015, 0.015, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00128, -1.896, 2.27197), angle = Angle(1e-05, -1e-05, 71.82494), size = Vector(0.035, 0.035, 0.094), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00098, -1.48901, 3.01611), angle = Angle(0, 0, 113.33498), size = Vector(0.035, 0.035, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00098, -1.57031, 1.5293), angle = Angle(0, 0, 6.631), size = Vector(0.035, 0.01, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.0011, -1.3291, 3.58984), angle = Angle(0, 0, -4.103), size = Vector(0.035, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.00104, -1.32983, 3.93115), angle = Angle(0, 0, -24.79399), size = Vector(0.035, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-6e-05, -1.71313, 2.52905), angle = Angle(0, 0, 58.904), size = Vector(0.035, 0.035, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.02405, -1.69897, -5.88379), angle = Angle(0, 0, 0), size = Vector(0.044, 0.044, 0.1), color = Color(98, 95, 95, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.02289, -2.65454, -4.20703), angle = Angle(1e-05, -1e-05, 0), size = Vector(0.084, 0.084, 0.16), color = Color(98, 95, 95, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal4", skin = 0, bodygroup = {} },
	["lasers"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.10352, -4.48389, 2.98413), angle = Angle(-1e-05, 89.99982, -179.99998), size = Vector(0.047, 0.047, 0.228), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["lasers+"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.10327, -4.48364, 2.12476), angle = Angle(-1e-05, 89.99982, -179.99998), size = Vector(0.411, 0.411, 0.411), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["lasers++"] = { type = "Model", model = "models/wystan/attachments_tfa/akrailmount.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.28027, -3.62793, 0.22827), angle = Angle(-89.99994, 89.99978, 0), size = Vector(0.53, 0.53, 0.893), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["lasers+++"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.19995, -4.44312, -5.54761), angle = Angle(-89.99994, 89.99978, 0), size = Vector(0.53, 0.53, 0.893), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {}, active = false },
	["maga"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.03998, 1.11035, 2.40527), angle = Angle(0, -180, 106.84097), size = Vector(0.097, 0.097, 0.146), color = Color(182, 182, 182, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.09998, -1.96533, -3.95581), angle = Angle(89.99998, -89.99998, 0), size = Vector(0.4, 0.051, 0.126), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-6e-05, -3.01758, 2.33618), angle = Angle(89.99987, 89.99992, 0), size = Vector(0.094, 0.078, 0.047), color = Color(106, 106, 106, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00928, -2.31812, -2.95508), angle = Angle(89.99992, 89.99986, 0), size = Vector(0.481, 0.109, 0.138), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.00049, -2.27832, 2.39575), angle = Angle(89.99982, 89.99993, 0), size = Vector(0.086, 0.049, 0.137), color = Color(180, 180, 180, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0.38043, -3.24463, 2.84497), angle = Angle(89.9999, 89.99995, 0), size = Vector(0.016, 0.05, 0.03), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++"] = { type = "Model", model = "models/props_c17/concrete_barrier001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.00024, -2.85303, -8.27026), angle = Angle(-3e-05, -0.45998, -89.99992), size = Vector(0.015, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.40649, -3.24536, 2.84497), angle = Angle(89.99993, 89.99994, 0), size = Vector(0.016, 0.05, 0.03), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.00049, -2.59985, 2.7627), angle = Angle(-6e-05, -89.99997, -2.47403), size = Vector(0.074, 0.074, 0.074), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.21198, -2.71606, -0.16797), angle = Angle(-2e-05, -89.99997, -180), size = Vector(0.2, 0.2, 0.276), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal4", skin = 0, bodygroup = {} }
}
sound.Add( {
	name = "Weapon_HArdballsere.Single",
	channel = CHAN_WEAPON,
	volume = 0.7,
	level = 100,
	pitch = 150,//{80,85},
	sound = "weapons/aug/aug-1.wav"
} )
SWEP.IronSightsPos = Vector(-6.05, -6.532, 2.2)
SWEP.IronSightsAng = Vector(0,0,0)
--[[
SWEP.IronSightsPos_Rumor = Vector(-6.05, -6.532, 2.2)
SWEP.IronSightsAng_Rumor = Vector(0, 0, 0)
SWEP.IronSightsPos = Vector(-6.06, -0.784, 2.579)
SWEP.IronSightsAng = Vector(0.094, -0.08, -0.737)
]]
sound.Add( {
	name = "Weapon_HArdballsere.Silende",
	channel = CHAN_WEAPON,
	volume = 0.7,
	level = 100,
	pitch = 150,//{80,85},
	sound = "weapons/sg550/sg550-1.wav"
} )
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_HArdballsere.Silende") 
SWEP.Primary.Damage = 23.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.5
SWEP.ConeMin = 1.25

SWEP.ReloadSpeed = 1
SWEP.HeadshotMulti = 2

SWEP.Tier = 2

SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.15  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.1  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEADSHOT_MULTI, 0.07)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, "Aldarhtf", ""..translate.Get("weapon_zs_eraser_r1_description"), function(wept)
	wept.ConeMax = wept.ConeMax * 1.7
	wept.ConeMin = wept.ConeMin * 2.1
	wept.ReloadSpeed = wept.ReloadSpeed * 0.7
	wept.HeadshotMulti = wept.HeadshotMulti * 0.9

	wept.BulletCallback = function(attacker, tr, dmginfo)
		dmginfo:SetDamage(dmginfo:GetDamage() + dmginfo:GetDamage() * GAMEMODE:GetWave()/15)
	end
end)


function SWEP:ShootBullets(dmg, numbul, cone)
	dmg = dmg + dmg * (1 - self:Clip1() / self.Primary.ClipSize)

	BaseClass.ShootBullets(self, dmg, numbul, cone)
end

