AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_peashooter")
SWEP.Description = ""..translate.Get("weapon_zs_peashooter_description")

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.p228_Slide"
	SWEP.HUD3DPos = Vector(-0.88, 0.35, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.CSMuzzleFlashes = true
SWEP.ShowWorldModel = false
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
SWEP.VElements = {
	["a_usm_base+++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.071, -1.874), angle = Angle(0, 0, 73.566), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.025, -1.701, -2.708), angle = Angle(90, 90, 180), size = Vector(0.098, 0.068, 0.089), color = Color(98, 95, 95, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["slide_base++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.385, -0.101, 0.312), angle = Angle(180, 180, 0), size = Vector(0.086, 0.048, 0.136), color = Color(182, 181, 176, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.717, -0.101, 0.634), angle = Angle(-90, 180, 177.526), size = Vector(0.074, 0.074, 0.074), color = Color(144, 134, 138, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(2.667, -0.11, 0.372), angle = Angle(180, 180, 0), size = Vector(0.349, 0.108, 0.137), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.558, 0.679), angle = Angle(0, 0, 71.824), size = Vector(0.035, 0.035, 0.093), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["maga"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.p228_Clip", rel = "", pos = Vector(0.15, 1.944, 0.734), angle = Angle(0, 180, 106.841), size = Vector(0.097, 0.097, 0.145), color = Color(60, 60, 55, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, 0.397, 2.418), angle = Angle(0, 0, -16.288), size = Vector(0.034, 0.354, 0.126), color = Color(98, 95, 95, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["slide_base++++++"] = { type = "Model", model = "models/props_c17/concrete_barrier001a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(-1.111, -0.101, 0.888), angle = Angle(-0.461, 90, 0), size = Vector(0.014, 0.009, 0.009), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.331, 3.93), angle = Angle(0, 0, -24.795), size = Vector(0.035, 0.009, 0.009), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.29, 0.158, 1.279), angle = Angle(174.951, 180, 0), size = Vector(0.086, 0.027, 0.029), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -0.015, -1.264), angle = Angle(0, 0, 12.138), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.29, -0.38, 1.279), angle = Angle(174.951, 180, 0), size = Vector(0.086, 0.027, 0.029), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -0.161, 0.321), angle = Angle(0, 0, -31.456), size = Vector(0.017, 0.017, 0.032), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(3.786, 0.102, 0.75), angle = Angle(-90, 180, 0), size = Vector(0.2, 0.2, 0.275), color = Color(144, 134, 138, 255), surpresslightning = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.331, 3.589), angle = Angle(0, 0, -4.104), size = Vector(0.035, 0.009, 0.009), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.55, 0.026), angle = Angle(0, 0, 0), size = Vector(0.032, 0.061, 0.186), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["sosilence"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(-1.644, 0, 0.624), angle = Angle(90, 180, 180), size = Vector(0.041, 0.041, 0.218), color = Color(81, 75, 81, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = false  },
	["a_usm_base+++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.025, -2.655, -3.218), angle = Angle(0, 0, 0), size = Vector(0.083, 0.083, 0.083), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "", pos = Vector(0.1, -1.221, -0.466), angle = Angle(0, 0, 0), size = Vector(0.014, 0.014, 0.122), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -0.673, -1.691), angle = Angle(0, 0, -90), size = Vector(0.014, 0.014, 0.075), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++"] = { type = "Model", model = "models/props_c17/trappropeller_lever.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.344, -0.166), angle = Angle(0, 180, -17.26), size = Vector(0.167, 0.167, 0.167), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.571, 1.531), angle = Angle(0, 0, 6.631), size = Vector(0.035, 0.009, 0.05), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	--["pussy"] = { type = "Model", model = "models/props_c17/canister01a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.162, 0.158, -11.855), angle = Angle(0, 0, 0), size = Vector(0.18, 0.18, 0.18), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal5", skin = 0, bodygroup = {}, bonemerge = false, active = false  },
	["a_usm_base++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.025, -1.448, 1.919), angle = Angle(0, 0, 0.652), size = Vector(0.035, 0.068, 0.14), color = Color(98, 95, 95, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.071, -1.543), angle = Angle(0, 0, 118.065), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -0.161, 0.592), angle = Angle(0, 0, 117.746), size = Vector(0.017, 0.032, 0.027), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -0.151, -1.601), angle = Angle(0, 0, 53.319), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "slide_base", pos = Vector(6.29, -0.101, 1.052), angle = Angle(180, 180, 0), size = Vector(0.086, 0.078, 0.046), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.897, 2.272), angle = Angle(0, 0, 71.824), size = Vector(0.035, 0.035, 0.093), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0, 0.568, -5.822), angle = Angle(90, 90, 180), size = Vector(0.126, 0.05, 0.126), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["lever"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.p228_Hammer", rel = "", pos = Vector(0.1, 0.078, 0.601), angle = Angle(0, 0, -30.09), size = Vector(0.039, 0.017, 0.054), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(-0.025, -1.701, -2.797), angle = Angle(0, 0, 0), size = Vector(0.043, 0.043, 0.092), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.489, 3.016), angle = Angle(0, 0, 113.334), size = Vector(0.035, 0.035, 0.025), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -1.714, 2.528), angle = Angle(0, 0, 58.903), size = Vector(0.035, 0.035, 0.014), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "v_weapon.p228_Parent", rel = "a_usm_base", pos = Vector(0, -0.005, -1.548), angle = Angle(0, 0, 12.637), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
    ["rumor+++"] = { type = "Model", model = "models/Mechanics/gears/gear16x12_small.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.533, -1.234, 0.62), angle = Angle(90, 180, 180), size = Vector(0.014, 0.014, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["rumor++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.14, -0.847, 0.964), angle = Angle(0, 0, 90), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["red_dot"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.16, -1.207, 0.064), angle = Angle(0, 0, 180), size = Vector(0.010, 0.010, 0.010), color = Color(255, 0, 0, 255), surpresslightning = true, material = "orange", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["rumor++++"] = { type = "Model", model = "models/Mechanics/gears/gear16x12_small.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.529, -0.946, 0.119), angle = Angle(90, 180, 180), size = Vector(0.014, 0.014, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["rumor+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.119, -0.766, 0.328), angle = Angle(0, 0, 90), size = Vector(0.061, 0.115, 0.05), color = Color(128, 113, 116, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["rumor"] = { type = "Model", model = "models/mechanics/articulating/arm_base_b.mdl", bone = "v_weapon.p228_Slide", rel = "", pos = Vector(0.476, -1.5, 0.328), angle = Angle(0, 0, 90), size = Vector(0.021, 0.057, 0.019), color = Color(128, 113, 116, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
    ["lasersigmaedit+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "v_weapon.p228_Parent", rel = "", pos = Vector(0.003, -2.166, -3.411), angle = Angle(90, 0, 90), size = Vector(0.019, 0.019, 0.019), color = Color(106, 108, 110, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["laserbeam"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "v_weapon.p228_Parent", rel = "", pos = Vector(0, -2.102, -4.468), angle = Angle(-90, 180, 0), size = Vector(0.976, 0.976, 0.976), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	
}

SWEP.WElements = {
	["a_usm_base++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.151, -1.601), angle = Angle(0, 0, 53.319), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.025, -1.701, -2.708), angle = Angle(90, 90, 180), size = Vector(0.098, 0.068, 0.089), color = Color(98, 95, 95, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["slide_base++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(6.35, -0.101, 0.312), angle = Angle(180, 180, 0), size = Vector(0.086, 0.048, 0.136), color = Color(182, 181, 176, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(6.717, -0.101, 0.634), angle = Angle(-90, 180, 177.526), size = Vector(0.074, 0.074, 0.074), color = Color(144, 134, 138, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(2.667, -0.11, 0.372), angle = Angle(180, 180, 0), size = Vector(0.349, 0.108, 0.137), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.558, 0.679), angle = Angle(0, 0, 71.824), size = Vector(0.035, 0.035, 0.093), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, 0.397, 2.418), angle = Angle(0, 0, -16.288), size = Vector(0.034, 0.354, 0.126), color = Color(98, 95, 95, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["slide_base++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(6.29, -0.101, 1.052), angle = Angle(180, 180, 0), size = Vector(0.086, 0.078, 0.046), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.331, 3.93), angle = Angle(0, 0, -24.795), size = Vector(0.035, 0.009, 0.009), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(6.29, 0.158, 1.279), angle = Angle(174.951, 180, 0), size = Vector(0.086, 0.027, 0.029), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.015, -1.264), angle = Angle(0, 0, 12.138), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(6.29, -0.38, 1.279), angle = Angle(174.951, 180, 0), size = Vector(0.086, 0.027, 0.029), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.161, 0.321), angle = Angle(0, 0, -31.456), size = Vector(0.017, 0.017, 0.032), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base+++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(3.329, 0.112, 0.75), angle = Angle(-90, 180, 0), size = Vector(0.2, 0.2, 0.275), color = Color(144, 134, 138, 255), surpresslightning = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.331, 3.589), angle = Angle(0, 0, -4.104), size = Vector(0.035, 0.009, 0.009), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.55, 0.026), angle = Angle(0, 0, 0), size = Vector(0.032, 0.061, 0.186), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["sosilence"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(-1.382, 0, 0.393), angle = Angle(90, -180, 180), size = Vector(0.039, 0.039, 0.143), color = Color(110, 98, 100, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = false  },
	["a_usm_base+++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.025, -2.655, -3.218), angle = Angle(0, 0, 0), size = Vector(0.079, 0.079, 0.079), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.258, 1.396, -1.012), angle = Angle(0, 89.133, -86.356), size = Vector(0.014, 0.014, 0.122), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.673, -1.691), angle = Angle(0, 0, -90), size = Vector(0.014, 0.014, 0.075), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++"] = { type = "Model", model = "models/props_c17/trappropeller_lever.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.344, -0.166), angle = Angle(0, 180, -17.26), size = Vector(0.167, 0.167, 0.167), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.025, -1.448, 1.919), angle = Angle(0, 0, 0.652), size = Vector(0.035, 0.068, 0.14), color = Color(98, 95, 95, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	--["pussy"] = { type = "Model", model = "models/props_c17/canister01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(-5.462, -0.119, 0.418), angle = Angle(-90, 180, 180), size = Vector(0.18, 0.18, 0.18), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal5", skin = 0, bodygroup = {}, bonemerge = false, active = false  },
	["a_usm_base++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.071, -1.543), angle = Angle(0, 0, 118.065), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.071, -1.874), angle = Angle(0, 0, 73.566), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.897, 2.272), angle = Angle(0, 0, 71.824), size = Vector(0.035, 0.035, 0.093), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.958, 1.5, -3.419), angle = Angle(3.358, 180, 180), size = Vector(0.126, 0.05, 0.126), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.161, 0.592), angle = Angle(0, 0, 117.746), size = Vector(0.017, 0.032, 0.027), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.571, 1.531), angle = Angle(0, 0, 6.631), size = Vector(0.035, 0.009, 0.05), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["slide_base++++++"] = { type = "Model", model = "models/props_c17/concrete_barrier001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(-1.111, -0.101, 0.888), angle = Angle(-0.461, 90, 0), size = Vector(0.014, 0.009, 0.009), color = Color(98, 96, 98, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/canister02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(-0.026, -1.701, -2.797), angle = Angle(0, 0, 0), size = Vector(0.039, 0.039, 0.087), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal4", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.489, 3.016), angle = Angle(0, 0, 113.334), size = Vector(0.035, 0.035, 0.025), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base+++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -1.714, 2.528), angle = Angle(0, 0, 58.903), size = Vector(0.035, 0.035, 0.014), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["a_usm_base++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "a_usm_base", pos = Vector(0, -0.005, -1.548), angle = Angle(0, 0, 12.637), size = Vector(0.014, 0.014, 0.019), color = Color(98, 95, 95, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["rumor"] = { type = "Model", model = "models/mechanics/articulating/arm_base_b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(6.114, -0.424, 1.768), angle = Angle(0, 90, 180), size = Vector(0.019, 0.054, 0.019), color = Color(120, 115, 120, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["lasersigmaedit+"] = { type = "Model", model = "models/props_wasteland/laundry_washer003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(0.876, -0, -1.339), angle = Angle(0, 0, 180), size = Vector(0.019, 0.019, 0.019), color = Color(100, 103, 101, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	["laserbeam"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "slide_base", pos = Vector(0, 0, -1.285), angle = Angle(0, 180, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}, bonemerge = false, active = true },
	
}

sound.Add( {
	name = "Weapon_KDP2011.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 150,//{80,85},
	sound = "weapons/357_fire2.wav"
} )
--[[
SWEP.IronSightsPos = Vector(-6.06, -0.784, 2.579)
SWEP.IronSightsAng = Vector(0.094, -0.08, -0.737)
SWEP.IronSightsPos_Rumor = Vector(-6.08, -6.532, 2.2)
SWEP.IronSightsAng_Rumor = Vector(0, 0, 0)
]]
SWEP.IronSightsPos = Vector(-6.08, -4, 2.2)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.ViewModelBoneMods = {
	["v_weapon.p228_Parent"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
sound.Add( {
	name = "Weapon_KDP2011.Silende",
	channel = CHAN_WEAPON,
	volume = 0.7,
	level = 100,
	pitch = 140,//{80,85},
	sound = "weapons/m4a1/m4a1-1.wav"
} )
SWEP.UseHands = true
SWEP.Primary.SilencedSound = Sound("Weapon_KDP2011.Silende") -- This is the sound of the weapon, when silenced.
SWEP.Primary.Sound = Sound("Weapon_KDP2011.SingleHeavy") 
SWEP.Primary.Damage = 15.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.18

SWEP.Primary.ClipSize = 9
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipMultiplier = 12/18 * 2 -- Battleaxe/Owens have 12 clip size, but this has half ammo usage
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4
SWEP.ConeMin = 0.75
-- 全局开关
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.1  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.1  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_peashooter_r1"), ""..translate.Get("weapon_zs_peashooter_r1_description"), function(wept)
	wept.Primary.Delay = 0.15
	wept.Primary.Automatic = true
	wept.Primary.ClipSize = math.floor(wept.Primary.ClipSize * 1.25)

	wept.ConeMin = 2.25
end)


function SWEP:SetAltUsage(usage)
	self:SetDTBool(1, usage)
end

function SWEP:GetAltUsage()
	return self:GetDTBool(1)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitFireSound()

	local altuse = self:GetAltUsage()
	if not altuse then
		self:TakeAmmo()
	end
	self:SetAltUsage(not altuse)

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

if not CLIENT then return end

function SWEP:GetDisplayAmmo(clip, spare, maxclip)
	local minus = self:GetAltUsage() and 0 or 1
	return math.max(0, (clip * 2) - minus), spare * 2, maxclip * 2
end
