AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")
SWEP.PrintName = "Ebanator-1000"
SWEP.Description = "Heavy rifle used by Kargen operators"


SWEP.SlotPos = 0


if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
	SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.aug_Parent"
	SWEP.HUD3DPos = Vector(1.2,-5.08,7.8)
	SWEP.HUD3DAng = Angle(0, -10, -30)
	SWEP.HUD3DScale = 0.008
	--SWEP.VMPos = Vector(-1.453, -0.212, -0.098)
	--SWEP.VMAng = Angle(0, 0, -6.572)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"
//schitalochka 文字显示
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["v_weapon.aug_Bolt"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.aug_Parent"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 8, 0) },

}

SWEP.ViewModel = "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel = "models/htfovichi/invpistol.mdl"
SWEP.ShowWorldModel = false
SWEP.VElements = {
	["reciever++"] = { type = "Model", model = "models/tfa/lbeam.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(1.639, -0.5, 3.884), angle = Angle(-90, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/props_lab/blastdoor001c.mdl", bone = "v_weapon.aug_Clip", rel = "", pos = Vector(-0.902, 2.68, -1.371), angle = Angle(-3.001, -10.004, -0.003), size = Vector(0.09, 0.029, 0.029), color = Color(172, 172, 172, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, 0, 18.078), angle = Angle(90, 0, 0), size = Vector(0.951, 0.16, 0.16), color = Color(110, 155, 98, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, -0.896, 14.652), angle = Angle(90, 90, 0), size = Vector(0.51, 0.13, 0.107), color = Color(141, 180, 131, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -0.896, 22.814), angle = Angle(60.611, 90, 0), size = Vector(0.03, 0.134, 0.099), color = Color(126, 187, 111, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -1.458, 23.1), angle = Angle(54.91, 90, 0), size = Vector(0.001, 0.101, 0.05), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.2, 2.279, 21.854), angle = Angle(90, 90, 0), size = Vector(0.11, 0.17, 0.144), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.2, 1.4, 24.935), angle = Angle(90, -90, 0), size = Vector(0.3, 0.166, 0.148), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.2, 2.279, 21.854), angle = Angle(90, 90, 0), size = Vector(0.11, 0.17, 0.144), color = Color(126, 170, 115, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.2, 4.113, 28.576), angle = Angle(105.134, -90, 0), size = Vector(0.082, 0.19, 0.213), color = Color(153, 153, 153, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++"] = { type = "Model", model = "models/weapons/w_pist_glock18.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.2, 6.156, 16.253), angle = Angle(-90, 90, 0), size = Vector(1, 1, 1), color = Color(133, 133, 133, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.297, 5.354, 8.463), angle = Angle(-90, 90, 0), size = Vector(0.04, 0.04, 0.085), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.297, -1.088, 5.521), angle = Angle(0, 90, 0), size = Vector(0.05, 0.05, 0.05), color = Color(114, 114, 114, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++"] = { type = "Model", model = "models/props_phx/construct/metal_tube.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -3.188, 16.511), angle = Angle(0, 0, 0), size = Vector(0.03, 0.03, 0.03), color = Color(165, 165, 165, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["reciever++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.04, -0.495, 11.432), angle = Angle(180, 90, 0), size = Vector(0.014, 0.18, 0.394), color = Color(121, 121, 121, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, -1.75, 18.144), angle = Angle(-90, 90, 0), size = Vector(0.02, 0.035, 0.035), color = Color(127, 127, 127, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, -1.75, 16.446), angle = Angle(90, -90, 0), size = Vector(0.02, 0.035, 0.035), color = Color(129, 129, 129, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -3.188, 16.511), angle = Angle(0, 0, 0), size = Vector(0.02, 0.02, 0.02), color = Color(255, 255, 255, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "red", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -0.994, 20.552), angle = Angle(136.15601, -90, 0), size = Vector(0.12, 0.566, 0.123), color = Color(255, 144, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -0.83, 20.739), angle = Angle(140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 144, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -1.4, 20.2), angle = Angle(140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 161, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -1.4, 20.7), angle = Angle(-140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 174, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -0.86, 20.2), angle = Angle(-140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 144, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, -0.583, 7.588), angle = Angle(67.554, -90, 0), size = Vector(0.057, 0.53, 0.505), color = Color(255, 131, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, -0.583, 8.388), angle = Angle(67.554, -90, 0), size = Vector(0.057, 0.53, 0.505), color = Color(255, 114, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.05, -0.583, 9.19), angle = Angle(67.554, -90, 0), size = Vector(0.057, 0.53, 0.505), color = Color(255, 114, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.297, 1.9, 8.27), angle = Angle(-90, 90, 0), size = Vector(0.021, 0.021, 0.021), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["schitalochka"] = { type = "Quad", bone = "ValveBiped.Bip01_Spine4", rel = "stvol", pos = Vector(0.1, -1.92, 22.82), angle = Angle(0, 0, -34.458), size = 0.04, draw_func = nil},
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.aug_Parent", rel = "", pos = Vector(-0.4, -3.8, -15.294), angle = Angle(-3,-10, 0), size = Vector(0.05, 0.05, 0.547), color = Color(144, 144, 144, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["mag"] = { type = "Model", model = "models/props_lab/blastdoor001c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0,-1, 0.95), angle = Angle(0, 90, 95), size = Vector(0.09, 0.029, 0.029), color = Color(172, 172, 172, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever"] = { type = "Model", model = "models/mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, 0, 18.078), angle = Angle(90, 0, 0), size = Vector(0.951, 0.16, 0.16), color = Color(110, 155, 98, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, -0.896, 14.652), angle = Angle(90, 90, 0), size = Vector(0.51, 0.13, 0.107), color = Color(141, 180, 131, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -0.896, 22.814), angle = Angle(60.611, 90, 0), size = Vector(0.03, 0.134, 0.099), color = Color(126, 187, 111, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -1.458, 23.1), angle = Angle(54.91, 90, 0), size = Vector(0.001, 0.101, 0.05), color = Color(0, 0, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.2, 2.279, 21.854), angle = Angle(90, 90, 0), size = Vector(0.11, 0.17, 0.144), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.2, 1.4, 24.935), angle = Angle(90, -90, 0), size = Vector(0.3, 0.166, 0.148), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.2, 2.279, 21.854), angle = Angle(90, 90, 0), size = Vector(0.11, 0.17, 0.144), color = Color(126, 170, 115, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.2, 4.113, 28.576), angle = Angle(105.134, -90, 0), size = Vector(0.082, 0.19, 0.213), color = Color(153, 153, 153, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++"] = { type = "Model", model = "models/weapons/w_pist_glock18.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.2, 6.156, 16.253), angle = Angle(-90, 90, 0), size = Vector(1, 1, 1), color = Color(133, 133, 133, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.297, 5.354, 8.463), angle = Angle(-90, 90, 0), size = Vector(0.04, 0.04, 0.085), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0, -1.088, 6.325), angle = Angle(0, 90, 0), size = Vector(0.05, 0.05, 0.05), color = Color(114, 114, 114, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++"] = { type = "Model", model = "models/props_phx/construct/metal_tube.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -3.188, 16.511), angle = Angle(0, 0, 0), size = Vector(0.03, 0.03, 0.03), color = Color(165, 165, 165, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["reciever++++++++++++++"] = { type = "Model", model = "models/props_c17/SuitCase001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.04, -0.495, 11.432), angle = Angle(180, 90, 0), size = Vector(0.014, 0.18, 0.394), color = Color(121, 121, 121, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, -1.75, 18.144), angle = Angle(-90, 90, 0), size = Vector(0.02, 0.035, 0.035), color = Color(127, 127, 127, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++"] = { type = "Model", model = "models/hunter/triangles/trapezium3x3x1c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, -1.75, 16.446), angle = Angle(90, -90, 0), size = Vector(0.02, 0.035, 0.035), color = Color(129, 129, 129, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++"] = { type = "Model", model = "models/props_junk/PopCan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -3.188, 16.511), angle = Angle(0, 0, 0), size = Vector(0.02, 0.02, 0.02), color = Color(255, 255, 255, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "red", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -0.994, 20.552), angle = Angle(136.15601, -90, 0), size = Vector(0.12, 0.566, 0.123), color = Color(255, 144, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -0.83, 20.739), angle = Angle(140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 144, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -1.4, 20.2), angle = Angle(140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 161, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -1.4, 20.7), angle = Angle(-140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 174, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.1, -0.86, 20.2), angle = Angle(-140, -90, 0), size = Vector(0.15, 0.566, 0.02), color = Color(255, 144, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, -0.583, 7.588), angle = Angle(67.554, -90, 0), size = Vector(0.057, 0.53, 0.505), color = Color(255, 131, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, -0.583, 8.388), angle = Angle(67.554, -90, 0), size = Vector(0.057, 0.53, 0.505), color = Color(255, 114, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever+++++++++++++++++++++++++"] = { type = "Model", model = "models/hunter/plates/plate.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.05, -0.583, 9.19), angle = Angle(67.554, -90, 0), size = Vector(0.057, 0.53, 0.505), color = Color(255, 114, 0, 255), surpresslightning = true, bonemerge = false, highrender = false, nocull = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["reciever++++++++++++++++++++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "stvol", pos = Vector(0.297, 1.612, 8.463), angle = Angle(-90, 90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(142, 142, 142, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} },
	["stvol"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(22,1,-8.4), angle = Angle(0, 90, -78), size = Vector(0.05, 0.05, 0.547), color = Color(144, 144, 144, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "metal2", skin = 0, bodygroup = {} }
}

SWEP.UseHands = true

sound.Add( {
	name = "Weapon_enamtpr.Silende",
	channel = CHAN_WEAPON,
	volume = 0.65,
	level = 60,
	pitch = 210,//{80,85},
	sound = "weapons/ar2/npc_ar2_altfire.wav"
} )
SWEP.WeaponType = "rifle"
SWEP.Primary.Sound = Sound("Weapon_enamtpr.Silende")
SWEP.Primary.Damage = 21.75
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.12

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.65
SWEP.ConeMin = 1.275

SWEP.WalkSpeed = SPEED_SLOW
SWEP.TracerName = "tracer_htfov"
SWEP.Tier = 4
SWEP.MaxStock = 3
SWEP.StandOffset = -1
SWEP.IronSightsPos = Vector(-7.02, -5, 1.8)
SWEP.IronSightsAng = Vector(0.35, -3.18, -2.2	)
SWEP.BulletCallback = function(attacker, tr, dmginfo)
	local ent = tr.Entity
	if SERVER and ent:IsValidLivingZombie() then
		ent:Ignite(3)
		ent:SetNWFloat("FireDieTime", CurTime() + 3)
		for __, fire in pairs(ents.FindByClass("entityflame")) do
			if fire:IsValid() and fire:GetParent() == ent then
				fire:SetOwner(attacker)
				fire:SetPhysicsAttacker(attacker)
				fire.AttackerForward = attacker
			end
		end
	end
end