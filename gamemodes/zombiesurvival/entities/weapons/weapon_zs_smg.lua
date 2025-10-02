AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_smg")
SWEP.Description = ""..translate.Get("weapon_zs_smg_description")

SWEP.SlotPos = 0

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	SWEP.SlotGroup = WEPSELECT_SMG
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 56

	SWEP.HUD3DBone = "v_weapon.MP5_Parent"
	SWEP.HUD3DPos = Vector(-1.1, -4.5, -5)
	SWEP.HUD3DAng = Angle(0, 0, -15)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_mp5.mdl" 
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["v_weapon.MP5_Parent"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["scope dot"] = { type = "Sprite", sprite = "sprites/redglow1", bone = "v_weapon.MP5_Parent", rel = "scope", pos = Vector(0, 0, 0), size = { x = 1, y = 1 }, color = Color(123, 123, 123, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = false, ignorez = false},
	["ironsight++"] = { type = "Model", model = "models/hunter/tubes/circle2x2d.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0.389, -2.014, 1.046), angle = Angle(0, -90, -90), size = Vector(0.009, 0.025, 0.057), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["trigger"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(-0.24, 3.009, -0.967), angle = Angle(0, 90, 90), size = Vector(0.052, 0.063, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Clip", rel = "", pos = Vector(0, 1.781, 0.001), angle = Angle(0, 0, 4.735), size = Vector(0.087, 0.279, 0.087), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -1.775, 1.447), angle = Angle(0, 0, 0), size = Vector(0.082, 0.046, 0.142), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope round things"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "scope", pos = Vector(-0.477, 0, 1.605), angle = Angle(90, 0, 0), size = Vector(0.028, 0.028, 0.009), color = Color(85, 85, 85, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 0.788, 3.569), angle = Angle(0, 0, 138.201), size = Vector(0.115, 0.156, 0.243), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 1.108, -4.541), angle = Angle(0, 0, 57.875), size = Vector(0.115, 0.156, 0.173), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["stock++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -0.255, 5.229), angle = Angle(0, 0, 13.89), size = Vector(0.021, 0.021, 0.143), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/props_c17/TrapPropeller_Lever.mdl", bone = "v_weapon.MP5_Bolt", rel = "", pos = Vector(-0.723, -0.318, 0.479), angle = Angle(0, 66.074, 0), size = Vector(0.328, 0.119, 0.328), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope round things+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "scope", pos = Vector(0, -0.639, 1.605), angle = Angle(90, -90, 0), size = Vector(0.028, 0.028, 0.009), color = Color(85, 85, 85, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight front"] = { type = "Model", model = "models/props_c17/TrapPropeller_Lever.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0.001, -1.805, -12.235), angle = Angle(0, 0, 0), size = Vector(0.115, 0.115, 0.115), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 2.134, 0.638), angle = Angle(0, 0, 65.699), size = Vector(0.041, 0.094, 0.086), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope+"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1c.mdl", bone = "v_weapon.MP5_Parent", rel = "scope thing", pos = Vector(0, -1.614, -2.721), angle = Angle(0, -90, 0), size = Vector(0.027, 0.027, 0.027), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -1.428, 3.628), angle = Angle(0, 0, 41.057), size = Vector(0.039, 0.043, 0.03), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope thing+++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -2.724, -2.649), angle = Angle(0, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body+++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 1.508, -0.914), angle = Angle(0, 0, 0), size = Vector(0.115, 0.156, 0.685), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope thing"] = { type = "Model", model = "models/mechanics/solid_steel/steel_beam_4.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -1.849, -2.155), angle = Angle(0, 0, 0), size = Vector(0.03, 0.014, 0.136), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -1.695, 1.447), angle = Angle(0, 0, -113.051), size = Vector(0.025, 0.025, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight+"] = { type = "Model", model = "models/hunter/tubes/circle2x2d.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(-0.378, -2.014, 1.046), angle = Angle(0, -90, -90), size = Vector(0.009, 0.025, 0.057), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope thing+"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -2.248, -2.155), angle = Angle(0, 0, 0), size = Vector(0.081, 0.065, 0.136), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -0.482, -15.428), angle = Angle(0, 0, 0), size = Vector(0.024, 0.024, 0.167), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope quad screen"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "scope quad", pos = Vector(0.49, 0.33, -0.033), angle = Angle(0, 0, 0), size = Vector(0.009, 0.019, 0.009), color = Color(121, 138, 88, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["body+++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 0.144, -5.607), angle = Angle(0, 0, 0), size = Vector(0.059, 0.059, 0.24), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["hold thingy"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 0.004, -9.002), angle = Angle(0, 0, 0), size = Vector(0.061, 0.101, 0.135), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["mag+"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Clip", rel = "mag", pos = Vector(0, 2.739, -0.362), angle = Angle(0, 0, 12.269), size = Vector(0.087, 0.279, 0.087), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["stock+"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 0.472, 11.196), angle = Angle(0, 0, 90), size = Vector(0.064, 0.068, 0.202), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight dots++"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "v_weapon.MP5_Parent", rel = "ironsight front", pos = Vector(0, -0.622, 0.158), angle = Angle(0, 0, 0), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["body"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "", pos = Vector(0.158, -3.715, -3.008), angle = Angle(0, 0, 0), size = Vector(0.115, 0.156, 0.912), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -0.32, 4.589), angle = Angle(0, 0, 0), size = Vector(0.021, 0.021, 0.143), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight dots"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "v_weapon.MP5_Parent", rel = "ironsight+", pos = Vector(-0.327, 1.001, 0), angle = Angle(0, 0, 0), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["body+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(-0.24, -1.356, -10.247), angle = Angle(0, 0, 0), size = Vector(0.028, 0.028, 0.12), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -1.275, -12.216), angle = Angle(0, 0, 0), size = Vector(0.039, 0.043, 0.361), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "v_weapon.MP5_Parent", rel = "scope thing", pos = Vector(0, -1.614, -1.558), angle = Angle(0, 0, 0), size = Vector(0.027, 0.027, 0.067), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["barrel+"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -0.482, -20.553), angle = Angle(0, 0, 0), size = Vector(0.059, 0.059, 0.207), color = Color(85, 85, 85, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope quad screen display"] = { type = "Quad", bone = "ValveBiped.Bip01_Spine4", rel = "scope quad", pos = Vector(0.564, 0.264, -0.151), angle = Angle(0, 90, 90), size = 0.025, draw_func = nil},
	["scope quad"] = { type = "Model", model = "models/props_lab/reciever01c.mdl", bone = "v_weapon.MP5_Parent", rel = "scope", pos = Vector(0, -0.801, 2.617), angle = Angle(90, -90, 0), size = Vector(0.094, 0.094, 0.094), color = Color(123, 123, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["ironsight dots+"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "v_weapon.MP5_Parent", rel = "ironsight++", pos = Vector(-0.327, 1.001, 0), angle = Angle(0, 0, 0), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["scope thing++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, -2.724, -1.596), angle = Angle(0, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.MP5_Parent", rel = "body", pos = Vector(0, 1.095, -5.368), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.202), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["mag++"] = { type = "Model", model = "models/weapons/shell.mdl", bone = "v_weapon.MP5_Clip", rel = "mag", pos = Vector(-0.322, -1.801, 0.001), angle = Angle(-90, 0, 0), size = Vector(0.504, 0.504, 0.504), color = Color(123, 123, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["scope dot"] = { type = "Sprite", sprite = "sprites/redglow1", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, 0, 0), size = { x = 1, y = 1 }, color = Color(123, 123, 123, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["ironsight++"] = { type = "Model", model = "models/hunter/tubes/circle2x2d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0.389, -2.014, 1.046), angle = Angle(0, -90, -90), size = Vector(0.009, 0.025, 0.057), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["trigger"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(-0.24, 3.009, -0.967), angle = Angle(0, 90, 90), size = Vector(0.032, 0.032, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -1.275, -12.216), angle = Angle(0, 0, 0), size = Vector(0.039, 0.043, 0.361), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -1.775, 1.447), angle = Angle(0, 0, 0), size = Vector(0.082, 0.046, 0.142), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["quad glow"] = { type = "Sprite", sprite = "sprites/animglow02", bone = "ValveBiped.Bip01_R_Hand", rel = "scope quad", pos = Vector(0.721, 0.305, 0), size = { x = 1, y = 0.776 }, color = Color(0, 171, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["scope round things"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-0.477, 0, 1.605), angle = Angle(90, 0, 0), size = Vector(0.028, 0.028, 0.009), color = Color(85, 85, 85, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 0.788, 3.569), angle = Angle(0, 0, 138.201), size = Vector(0.115, 0.156, 0.243), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 1.108, -4.541), angle = Angle(0, 0, 57.875), size = Vector(0.115, 0.156, 0.173), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -0.482, -15.428), angle = Angle(0, 0, 0), size = Vector(0.024, 0.024, 0.167), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["bolt"] = { type = "Model", model = "models/props_c17/TrapPropeller_Lever.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(-0.742, -1.611, -10), angle = Angle(0, 41.567, 0), size = Vector(0.263, 0.119, 0.263), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope round things+"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, -0.639, 1.605), angle = Angle(90, -90, 0), size = Vector(0.028, 0.028, 0.009), color = Color(85, 85, 85, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight front"] = { type = "Model", model = "models/props_c17/TrapPropeller_Lever.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0.001, -1.805, -12.235), angle = Angle(0, 0, 0), size = Vector(0.115, 0.115, 0.115), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 2.134, 0.638), angle = Angle(0, 0, 65.699), size = Vector(0.041, 0.094, 0.086), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope+"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope thing", pos = Vector(0, -1.614, -1.922), angle = Angle(0, -90, 0), size = Vector(0.027, 0.027, 0.009), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope thing+++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -2.724, -2.649), angle = Angle(0, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope thing"] = { type = "Model", model = "models/mechanics/solid_steel/steel_beam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -1.849, -2.155), angle = Angle(0, 0, 0), size = Vector(0.03, 0.014, 0.136), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -1.428, 3.628), angle = Angle(0, 0, 41.057), size = Vector(0.039, 0.043, 0.03), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope quad"] = { type = "Model", model = "models/props_lab/reciever01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0, -0.801, 2.617), angle = Angle(90, -90, 0), size = Vector(0.094, 0.094, 0.094), color = Color(123, 123, 123, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["scope thing+"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -2.248, -2.155), angle = Angle(0, 0, 0), size = Vector(0.081, 0.065, 0.136), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope thing++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -2.724, -1.596), angle = Angle(0, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.112, 0.723, -4.344), angle = Angle(0, 88.283, -78.133), size = Vector(0.115, 0.156, 0.912), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight dots+"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "ironsight++", pos = Vector(-0.327, 1.001, 0), angle = Angle(0, 0, 0), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["hold thingy"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 0.004, -9.002), angle = Angle(0, 0, 0), size = Vector(0.061, 0.101, 0.135), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["mag+"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "mag", pos = Vector(0, 2.979, -0.306), angle = Angle(0, 0, 12.269), size = Vector(0.087, 0.279, 0.118), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["stock+"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 0.55, 11.647), angle = Angle(0, 0, 90), size = Vector(0.123, 0.134, 0.286), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight dots++"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "ironsight front", pos = Vector(0, -0.622, 0.158), angle = Angle(0, 0, 0), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["scope quad screen"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope quad", pos = Vector(0.49, 0.33, -0.033), angle = Angle(0, 0, 0), size = Vector(0.009, 0.019, 0.009), color = Color(121, 138, 88, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["stock"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -0.32, 4.589), angle = Angle(0, 0, 0), size = Vector(0.037, 0.037, 0.152), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight dots"] = { type = "Model", model = "models/dav0r/hoverball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "ironsight+", pos = Vector(-0.327, 1.001, 0), angle = Angle(0, 0, 0), size = Vector(0.016, 0.016, 0.016), color = Color(255, 255, 255, 255), surpresslightning = true, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["body+++++"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 1.508, -0.914), angle = Angle(0, 0, 0), size = Vector(0.115, 0.156, 0.685), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["mag"] = { type = "Model", model = "models/hunter/blocks/cube025x025x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 3.778, -4.212), angle = Angle(0, 0, 0), size = Vector(0.087, 0.263, 0.123), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["scope"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope thing", pos = Vector(0, -1.614, -1.558), angle = Angle(0, 0, 0), size = Vector(0.027, 0.027, 0.067), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(-0.24, -1.356, -10.247), angle = Angle(0, 0, 0), size = Vector(0.028, 0.028, 0.12), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight+"] = { type = "Model", model = "models/hunter/tubes/circle2x2d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(-0.378, -2.014, 1.046), angle = Angle(0, -90, -90), size = Vector(0.009, 0.025, 0.057), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["stock++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -0.255, 5.229), angle = Angle(0, 0, 13.89), size = Vector(0.041, 0.041, 0.136), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["barrel+"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -0.482, -18.754), angle = Angle(0, 0, 0), size = Vector(0.059, 0.059, 0.135), color = Color(85, 85, 85, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["ironsight+++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, -1.695, 1.447), angle = Angle(0, 0, -113.051), size = Vector(0.025, 0.025, 0.017), color = Color(255, 255, 255, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body++++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 1.095, -5.368), angle = Angle(0, 0, 0), size = Vector(0.054, 0.054, 0.202), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} },
	["body+++++++"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "body", pos = Vector(0, 0.144, -5.607), angle = Angle(0, 0, 0), size = Vector(0.059, 0.059, 0.24), color = Color(123, 123, 123, 255), surpresslightning = false, material = "silly/sillymaterialfix", skin = 0, bodygroup = {} }
}
SWEP.UseHands = true
sound.Add( {
	name = "Weapon_GA4.SingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 250,//{80,85},
	sound = "weapons/g3sg1/g3sg1-1.wav"
} )
sound.Add( {
	name = "Weapon_GA4.SosilenceSingleHeavy",
	channel = CHAN_WEAPON,
	volume = 2.0,
	level = 100,
	pitch = 250,//{80,85},
	sound = "weapons/mac10/mac10-1.wav"
} )
SWEP.Primary.Sound = Sound("Weapon_GA4.SingleHeavy") 
SWEP.Primary.Damage = 21
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.09
SWEP.TracerName = "SillyTracer"
SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 5.5
SWEP.ConeMin = 2.5

SWEP.WalkSpeed = SPEED_SLOW

SWEP.Tier = 3

SWEP.IronSightsPos = Vector(-5.338, -4.637, 1.48)
SWEP.IronSightsAng = Vector(0, 0, 0)
function SWEP:Think()
	self.BaseClass.Think(self)
	if CLIENT then
		self.VElements["scope quad screen display"].draw_func = function( weapon )
		draw.SimpleText(self.Weapon:Clip1(), "DefaultFont", 0, 0, Color(127,255,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end
end
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_smg_r1"), ""..translate.Get("weapon_zs_smg_r1_description"), function(wept)
	wept.Primary.Delay = 0.15
	wept.ReloadSpeed = 0.9

	wept.BulletCallback = function(attacker, tr, dmginfo)
		local trent = tr.Entity

		if SERVER and trent and trent:IsValidZombie() then
			if trent:GetZombieClassTable().Skeletal then
				dmginfo:SetDamage(dmginfo:GetDamage() * 1.2)
			end

			if math.random(6) == 1 then
				trent:ThrowFromPositionSetZ(tr.StartPos, 150, nil, true)
			end
		end
	end
end)
