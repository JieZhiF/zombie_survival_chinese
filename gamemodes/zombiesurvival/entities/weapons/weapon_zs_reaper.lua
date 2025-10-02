AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_reaper")
SWEP.Description = ""..translate.Get("weapon_zs_reaper_description")


SWEP.SlotPos = 0

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	SWEP.SlotGroup = WEPSELECT_SMG
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 70
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false
	SWEP.HUD3DBone = "v_weapon.ump45_Release"
	SWEP.HUD3DPos = Vector(-1.5, -3, 2)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
//mag_extend 武器弹容扩展
//sosilence 消音器 tfa_htf_supp
--[[
瞄准镜
	["pritsel"] = {
			["active"] = true
		},
		["pritsel+++"] = {
			["active"] = true
		},
		["kalimatar"] = {
			["active"] = true
		},
			["kalimatar+"] = {
			["active"] = true
]]
SWEP.ViewModelBoneMods = {
	["v_weapon.ump45_Parent"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {
	["sosilence"] = { type = "Model", model = "models/mechanics/various/211.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -0.033, 1.881), angle = Angle(0, 180, 180), size = Vector(0.708, 0.708, 1.309), color = Color(136, 136, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["pritsel"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -2.566, 14.909), angle = Angle(0, 0, 0), size = Vector(0.103, 0.149, 0.252), color = Color(139, 144, 138, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["kalimatar"] = { type = "Model", model = "models/props_vehicles/tire001b_truck.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -4.128, 14.909), angle = Angle(90, 0, 0), size = Vector(0.112, 0.045, 0.043), color = Color(148, 151, 153, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = true },
	["kalimatar+"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -4.128, 14.909), angle = Angle(180, 0, 0), size = Vector(0.03, 0.03, 0.03), color = Color(255, 255, 255, 255), surpresslightning = true, material = "red", skin = 0, bodygroup = {}, active = true },
	["mag_extend"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "v_weapon.ump45_Clip", rel = "", pos = Vector(0, 8.35, -1.572), angle = Angle(0, 0, -180), size = Vector(0.06, 0.06, 0.06), color = Color(139, 138, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
    ["ironas++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.055, -2.784, 18.83), angle = Angle(90, 0, 180), size = Vector(0.009, 0.079, 0.101), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["ironas"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.039, -2.309, 19.606), angle = Angle(0, 0, 0), size = Vector(0.12, 0.075, 0.275), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
   	["ironas+"] = { type = "Model", model = "models/props_phx/construct/metal_angle90.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.432, -2.082, 18.648), angle = Angle(0, -90, -90), size = Vector(0.035, 0.041, 0.085), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
    ["ironas+++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.035, -3.435, 19.01), angle = Angle(0, 0, 180), size = Vector(0.009, 0.009, 0.009), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["ironas++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.292, -3.373, 19.073), angle = Angle(90, 0, 180), size = Vector(0.009, 0.045, 0.029), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
    ["ironas++"] = { type = "Model", model = "models/props_phx/construct/metal_angle90.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.653, -2.008, 18.69), angle = Angle(0, -90, -90), size = Vector(0.035, 0.041, 0.085), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["ironas+++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.349, -3.352, 18.614), angle = Angle(90, 0, 180), size = Vector(0.009, 0.045, 0.029), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stocks+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -0.596, 22.153), angle = Angle(180, 0, -19.004), size = Vector(0.127, 0.119, 0.444), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.4, -0.075, 3.845), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(-0.038, 1.396, 19.701), angle = Angle(0, 0, 70.15), size = Vector(0.119, 0.108, 0.119), color = Color(174, 174, 174, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stocks++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, 0.788, 28.566), angle = Angle(180, 0, 0), size = Vector(0.127, 0.25, 0.66), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stocks+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, 2.755, 31.659), angle = Angle(180, 0, 0), size = Vector(0.127, 0.601, 0.136), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["reciever"] = { type = "Model", model = "models/props_junk/TrashDumpster01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(-0, 0.001, 15.796), angle = Angle(0, 0, 90), size = Vector(0.035, 0.158, 0.072), color = Color(173, 176, 174, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -3.001, 2.571), angle = Angle(180, 180, 180), size = Vector(0.019, 0.019, 0.019), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 3.536, 13.788), angle = Angle(0, 0, 80.584), size = Vector(0.075, 0.122, 0.393), color = Color(174, 176, 176, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+"] = { type = "Model", model = "models/wystan/attachments/rail.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.495, 0.048, 5.958), angle = Angle(90, 90, 0), size = Vector(1.004, 1.516, 1.004), color = Color(139, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, -1.292, 15.85), angle = Angle(90, 90, 180), size = Vector(1.756, 1.786, 1.756), color = Color(173, 173, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++"] = { type = "Model", model = "models/props_junk/TrashDumpster02.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(-0.42, -0.064, 12.449), angle = Angle(-90, 180, 0), size = Vector(0.014, 0.014, 0.009), color = Color(139, 141, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.006, -2.846, 3.155), angle = Angle(180, 180, 90), size = Vector(0.026, 0.009, 0.014), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.034, 4.142, 16.84), angle = Angle(0, 0, 50.143), size = Vector(0.075, 0.098, 0.048), color = Color(174, 176, 171, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.034, 4.969, 19.19), angle = Angle(0, 0, 56.71), size = Vector(0.076, 0.204, 0.558), color = Color(139, 138, 139, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["reciever+++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 4.591, 15.628), angle = Angle(0, 0, 80.584), size = Vector(0.075, 0.187, 0.046), color = Color(178, 173, 174, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stocks"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, 0.472, 23.416), angle = Angle(180, 0, 0), size = Vector(0.127, 0.197, 0.66), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, -0.223, 6.401), angle = Angle(180, 180, 0), size = Vector(0.216, 0.187, 0.284), color = Color(151, 149, 151, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["magazine"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Clip", rel = "", pos = Vector(0, 4.074, -1.007), angle = Angle(0, 0, 8.55), size = Vector(0.123, 0.864, 0.235), color = Color(146, 148, 151, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.034, 2.599, 17.854), angle = Angle(0, 0, 80.526), size = Vector(0.076, 0.204, 0.241), color = Color(143, 138, 139, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["handle++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.76, -1.38, 6.607), angle = Angle(90, 90, 0), size = Vector(0.344, 0.016, 0.048), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["tyan"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "v_weapon.ump45_Bolt", rel = "", pos = Vector(-1.29, -0.616, -0.318), angle = Angle(89.597, -119.019, -76.831), size = Vector(0.041, 0.041, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 1.968, 18.811), angle = Angle(0, 0, 26.906), size = Vector(0.119, 0.108, 0.119), color = Color(173, 171, 176, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++"] = { type = "Model", model = "models/wystan/attachments/rail.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.7, -0.433, 5.958), angle = Angle(90, 180, 0), size = Vector(1.004, 1.516, 1.004), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.401, -0.099, 8.965), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.401, -0.075, 4.755), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "v_weapon.ump45_Eject", rel = "", pos = Vector(-0.445, -0.227, -1.344), angle = Angle(-90, 180, 4.414), size = Vector(0.218, 0.167, 0.127), color = Color(139, 141, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.4, -0.099, 9.062), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++"] = { type = "Model", model = "models/wystan/attachments/rail.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.736, 0.208, 5.958), angle = Angle(90, 0, 0), size = Vector(1.004, 1.516, 1.004), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.034, 2.575, 11.505), angle = Angle(0, 0, 95.745), size = Vector(0.127, 0.316, 0.201), color = Color(176, 176, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.006, -1.685, 3.338), angle = Angle(180, 180, 90), size = Vector(0.085, 0.085, 0.074), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.079, 2.058, 14.265), angle = Angle(0, 0, 90), size = Vector(0.108, 0.859, 0.12), color = Color(174, 178, 179, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0, 4.39, 5.995), angle = Angle(0, 0, -90), size = Vector(0.16, 0.16, 0.15), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++"] = { type = "Model", model = "models/props_junk/wood_crate001a.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.022, 1.735, 6.198), angle = Angle(0, 0, -90), size = Vector(0.028, 0.054, 0.014), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.ump45_Parent", rel = "", pos = Vector(0.221, -5.986, -17.362), angle = Angle(0, -2, 0), size = Vector(0.028, 0.028, 0.351), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0, 2.739, 16.576), angle = Angle(0, 90, 180), size = Vector(0.1, 0.1, 0.331), color = Color(139, 141, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
["sosilence"] = { type = "Model", model = "models/mechanics/various/211.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.033, 1.881), angle = Angle(0, 180, 180), size = Vector(0.708, 0.708, 1.309), color = Color(136, 136, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["pritsel"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -2.566, 14.909), angle = Angle(0, 0, 0), size = Vector(0.103, 0.149, 0.252), color = Color(139, 144, 138, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
		["kalimatar"] = { type = "Model", model = "models/props_vehicles/tire001b_truck.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -4.128, 14.909), angle = Angle(90, 0, 0), size = Vector(0.112, 0.045, 0.043), color = Color(148, 151, 153, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
	["kalimatar+"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -4.128, 14.909), angle = Angle(180, 0, 0), size = Vector(0.03, 0.03, 0.03), color = Color(255, 255, 255, 255), surpresslightning = true, material = "red", skin = 0, bodygroup = {}, active = false}, 
	["mag_extend"] = { type = "Model", model = "models/props_wasteland/laundry_washer001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 11.277, 10.746), angle = Angle(0, 0, 4.256), size = Vector(0.057, 0.057, 0.057), color = Color(138, 139, 136, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {}, active = false },
["ironas++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.055, -2.784, 18.83), angle = Angle(90, 0, 180), size = Vector(0.009, 0.079, 0.101), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
  ["ironas+"] = { type = "Model", model = "models/props_phx/construct/metal_angle90.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.432, -2.082, 18.648), angle = Angle(0, -90, -90), size = Vector(0.035, 0.041, 0.085), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
    ["ironas+++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.051, -3.435, 19.01), angle = Angle(0, 0, 180), size = Vector(0.009, 0.009, 0.009), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["ironas++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.382, -3.373, 19.073), angle = Angle(90, 0, 180), size = Vector(0.009, 0.045, 0.029), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
    ["ironas++"] = { type = "Model", model = "models/props_phx/construct/metal_angle90.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(-0.653, -2.008, 18.69), angle = Angle(0, -90, -90), size = Vector(0.035, 0.041, 0.085), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
    ["ironas+++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.ump45_Parent", rel = "stvol", pos = Vector(0.34, -3.352, 18.614), angle = Angle(90, 0, 180), size = Vector(0.009, 0.045, 0.029), color = Color(161, 164, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stocks+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.596, 22.153), angle = Angle(180, 0, -19.004), size = Vector(0.127, 0.119, 0.444), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.4, -0.075, 3.845), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.038, 1.396, 19.701), angle = Angle(0, 0, 70.15), size = Vector(0.119, 0.108, 0.119), color = Color(174, 174, 174, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stocks++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.788, 28.566), angle = Angle(180, 0, 0), size = Vector(0.127, 0.25, 0.66), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["stocks+++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.755, 31.659), angle = Angle(180, 0, 0), size = Vector(0.127, 0.601, 0.136), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["reciever"] = { type = "Model", model = "models/props_junk/TrashDumpster01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0, 0.001, 15.796), angle = Angle(0, 0, 90), size = Vector(0.035, 0.158, 0.072), color = Color(173, 176, 174, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -3.001, 2.571), angle = Angle(180, 180, 180), size = Vector(0.019, 0.019, 0.019), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 3.536, 13.788), angle = Angle(0, 0, 80.584), size = Vector(0.075, 0.122, 0.393), color = Color(174, 176, 176, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+"] = { type = "Model", model = "models/wystan/attachments/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.495, 0.048, 5.958), angle = Angle(90, 90, 0), size = Vector(1.004, 1.516, 1.004), color = Color(139, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++"] = { type = "Model", model = "models/wystan/attachments_tfa/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, -1.292, 15.85), angle = Angle(90, 90, 180), size = Vector(1.756, 1.786, 1.756), color = Color(173, 173, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.006, -2.846, 3.155), angle = Angle(180, 180, 90), size = Vector(0.026, 0.009, 0.014), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.034, 4.142, 16.84), angle = Angle(0, 0, 50.143), size = Vector(0.075, 0.098, 0.048), color = Color(174, 176, 171, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.034, 4.969, 19.19), angle = Angle(0, 0, 56.71), size = Vector(0.076, 0.204, 0.558), color = Color(139, 138, 139, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["reciever+++++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 4.591, 15.628), angle = Angle(0, 0, 80.584), size = Vector(0.075, 0.187, 0.046), color = Color(178, 173, 174, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stocks"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 0.472, 23.416), angle = Angle(180, 0, 0), size = Vector(0.127, 0.197, 0.66), color = Color(143, 143, 141, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -0.223, 6.401), angle = Angle(180, 180, 0), size = Vector(0.216, 0.187, 0.284), color = Color(151, 149, 151, 255), surpresslightning = false, material = "rubber", skin = 0, bodygroup = {} },
	["reciever+++++++++++"] = { type = "Model", model = "models/props_c17/playground_swingset_seat01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 2.739, 16.576), angle = Angle(0, 90, 180), size = Vector(0.1, 0.1, 0.331), color = Color(139, 141, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.034, 2.599, 17.854), angle = Angle(0, 0, 80.526), size = Vector(0.076, 0.204, 0.241), color = Color(143, 138, 139, 255), surpresslightning = false, material = "rubber2", skin = 0, bodygroup = {} },
	["handle++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.76, -1.38, 7.366), angle = Angle(90, 90, 0), size = Vector(0.344, 0.016, 0.048), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 1.968, 18.811), angle = Angle(0, 0, 26.906), size = Vector(0.119, 0.108, 0.119), color = Color(173, 171, 176, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++++++"] = { type = "Model", model = "models/wystan/attachments/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.7, -0.433, 5.958), angle = Angle(90, 180, 0), size = Vector(1.004, 1.516, 1.004), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20.773, 1.521, -8.011), angle = Angle(0, 87.489, -78.903), size = Vector(0.028, 0.028, 0.351), color = Color(255, 255, 255, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.401, -0.099, 8.965), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.401, -0.075, 4.755), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle++++++"] = { type = "Model", model = "models/props_junk/wood_crate001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.022, 1.735, 7.172), angle = Angle(0, 0, -90), size = Vector(0.028, 0.054, 0.014), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.4, -0.099, 9.062), angle = Angle(0, 90, 90), size = Vector(0.174, 0.174, 0.224), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++++"] = { type = "Model", model = "models/props_junk/metalgascan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.006, -1.685, 3.338), angle = Angle(180, 180, 90), size = Vector(0.085, 0.085, 0.074), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.034, 2.575, 11.505), angle = Angle(0, 0, 95.745), size = Vector(0.127, 0.316, 0.201), color = Color(176, 176, 173, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++++++"] = { type = "Model", model = "models/wystan/attachments/rail.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.736, 0.208, 5.958), angle = Angle(90, 0, 0), size = Vector(1.004, 1.516, 1.004), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.079, 2.058, 14.265), angle = Angle(0, 0, 90), size = Vector(0.108, 0.859, 0.12), color = Color(174, 178, 179, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["handle+++++"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, 4.39, 7.315), angle = Angle(0, 0, -90), size = Vector(0.16, 0.16, 0.15), color = Color(134, 138, 141, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["magazine"] = { type = "Model", model = "models/props_junk/cardboard_box004a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.086, 7.297, 10.956), angle = Angle(0, 0, 6.309), size = Vector(0.108, 0.837, 0.351), color = Color(146, 148, 151, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++"] = { type = "Model", model = "models/props_junk/TrashDumpster02.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(-0.42, -0.064, 12.449), angle = Angle(-90, 180, 0), size = Vector(0.014, 0.014, 0.009), color = Color(139, 141, 148, 255), surpresslightning = false, material = "metal2", skin = 0, bodygroup = {} }
}
SWEP.UseHands = true

SWEP.Primary.SilencedSound = Sound("Weapon_IVP.SosilenceSingleHeavy") 
--SWEP.Primary.Sound = Sound("Weapon_IVP.SingleHeavy") 
SWEP.Primary.Sound = Sound("Weapon_UMP45.Single")

SWEP.Primary.Damage = 19.125
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.09

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

SWEP.ConeMax = 4
SWEP.ConeMin = 2.1

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.ReloadSpeed = 1.05

SWEP.Tier = 4
SWEP.MaxStock = 3
sound.Add( {
	name = "Weapon_IVP.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 250,//{80,85},
	sound = "weapons/galil/galil-1.wav"
} )
sound.Add( {
	name = "Weapon_IVP.SosilenceSingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 250,//{80,85},
	sound = "weapons/357_fire2.wav"
} )

--SWEP.IronSightsPos = Vector(-8.671, -13.983, 2.88)
--SWEP.IronSightsAng = Vector(1.399, -0.101, -1.333)
SWEP.IronSightsPos = Vector(-8.641, -14, 2.4)
SWEP.IronSightsAng = Vector(0, 0, -2.429)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 2)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.004)

function SWEP:OnZombieKilled()
	local killer = self:GetOwner()

	if killer:IsValid() then
		local reaperstatus = killer:GiveStatus("reaper", 14)
		if reaperstatus and reaperstatus:IsValid() then
			reaperstatus:SetDTInt(1, math.min(reaperstatus:GetDTInt(1) + 1, 3))
			killer:EmitSound("hl1/ambience/particle_suck1.wav", 55, 150 + reaperstatus:GetDTInt(1) * 30, 0.45)
		end
	end
end

function SWEP.BulletCallback(attacker, tr)
	local hitent = tr.Entity
	--
	if hitent:IsValidLivingZombie() and hitent:Health() <= hitent:GetMaxHealthEx() * 0.04 and gamemode.Call("PlayerShouldTakeDamage", hitent, attacker) then
		if SERVER then
			hitent:SetWasHitInHead()
		end
		hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, attacker, attacker:GetActiveWeapon(), tr.HitPos)
		hitent:EmitSound("npc/roller/blade_out.wav", 80, 125)
	end
	--attacker:GiveStatus("fastreload",10)
	--attacker:GiveStatus("fastshoot",10)
	--attacker:GiveStatus("chaos",5)
end

function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	owner:DoAttackEvent()

	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end

	owner:LagCompensation(true)
	owner:FireBulletsLua(owner:GetShootPos(), owner:GetAimVector(), cone, numbul, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false)

	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end
end

if not CLIENT then return end

function SWEP:Draw3DHUD(vm, pos, ang)
	self.BaseClass.Draw3DHUD(self, vm, pos, ang)

	local wid, hei = 180, 200
	local x, y = wid * -0.6, hei * -0.5

	cam.Start3D2D(pos, ang, self.HUD3DScale)
		local owner = self:GetOwner()
		local ownerstatus = owner:GetStatus("reaper")
		if ownerstatus then
			local text = ""
			for i = 0, ownerstatus:GetDTInt(1)-1 do
				text = text .. "+"
			end
			draw.SimpleTextBlurry(text, "ZS3D2DFontSmall", x + wid/2, y + hei * 0.15, Color(60, 30, 175, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

