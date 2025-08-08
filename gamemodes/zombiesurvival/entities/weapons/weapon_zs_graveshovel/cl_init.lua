INC_CLIENT()

SWEP.ViewModelFOV = 80

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

SWEP.VElements = {
	["eye+"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-3.097, 1.175, 32.965), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["skull"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-0.245, 1.638, 32.466), angle = Angle(0, -159.118, 0), size = Vector(0.85, 0.85, 0.85), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["eye"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-3.097, 1.175, 32.965), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["spade2"] = { type = "Model", model = "models/Gibs/HGIBS_scapula.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-1.019, -0.357, -22.178), angle = Angle(24.246, -107.839, 6.21), size = Vector(2.15, 2.15, 2.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["eye+++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-2.108, 3.815, 32.942), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["spade"] = { type = "Model", model = "models/Gibs/HGIBS_scapula.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-1.538, 0.66, -21.781), angle = Angle(0, 59.147, 30.173), size = Vector(2.15, 2.15, 2.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["eye++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_Spine4", rel = "spine", pos = Vector(-2.108, 3.815, 32.942), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["spine"] = { type = "Model", model = "models/Gibs/HGIBS_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.125, 1.445, -21.761), angle = Angle(6.393, -2.498, -3.169), size = Vector(0.899, 0.665, 3.928), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["eye+"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-3.097, 1.175, 33.444), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["eye"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-3.097, 1.175, 33.444), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["skull"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-0.245, 1.603, 32.875), angle = Angle(0, -159.118, 0), size = Vector(0.85, 0.85, 0.85), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["spade+"] = { type = "Model", model = "models/Gibs/HGIBS_scapula.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-1.019, -0.357, -25.78), angle = Angle(24.246, -107.839, 6.21), size = Vector(2.15, 2.15, 2.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["eye+++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-2.108, 3.815, 33.444), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["spade"] = { type = "Model", model = "models/Gibs/HGIBS_scapula.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-1.538, 0.66, -26.781), angle = Angle(0, 59.147, 30.173), size = Vector(2.15, 2.15, 2.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["spine"] = { type = "Model", model = "models/Gibs/HGIBS_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.831, 2.115, -21.778), angle = Angle(-2.964, 174.585, -0.41), size = Vector(0.899, 0.665, 4.128), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["eye++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "spine", pos = Vector(-2.108, 3.815, 33.444), size = { x = 2.072, y = 2.072 }, color = Color(255, 0, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
}



