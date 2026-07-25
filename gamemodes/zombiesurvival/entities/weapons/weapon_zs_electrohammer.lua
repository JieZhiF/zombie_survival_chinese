AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_electrohammer")

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRepairTools")
	SWEP.SlotGroup = WEPSELECT_REPAIR_TOOL
	SWEP.ViewModelFOV = 90
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VMPos = Vector(1, -10, 2)
	SWEP.VMAng = Angle(0,0,0)

	SWEP.VElements = {
		["hammer"] = { type = "Model", model = "models/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.048, 1.048, 1.048), color = Color(100, 100, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["hammer+"] = { type = "Model", model = "models/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.09, 1.09, 1.05), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/props_combine/portalball001_sheet", skin = 0, bodygroup = {} },
		["powerbox"] = { type = "Model", model = "models/props_lab/powerbox02d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0.431, 0.228, 10.017), angle = Angle(180, 0, 0), size = Vector(0.197, 0.197, 0.377), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["sprite"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(-1.094, 0.228, 9.793), size = { x = 4.635, y = 4.635 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["sprite+"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(-1.336, 0.247, 9.793), size = { x = 8.537, y = 8.537 }, color = Color(0, 0, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["teleport_ring"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(0, 0, 3.834), angle = Angle(0, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["teleport_ring+"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(0, 0, 7.11), angle = Angle(180, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} }
	}
	
	SWEP.WElements = {
		["hammer"] = { type = "Model", model = "models/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.048, 1.048, 1.048), color = Color(100, 100, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["hammer+"] = { type = "Model", model = "models/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.09, 1.09, 1.05), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/props_combine/portalball001_sheet", skin = 0, bodygroup = {} },
		["powerbox"] = { type = "Model", model = "models/props_lab/powerbox02d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0.431, 0.228, 10.017), angle = Angle(180, 0, 0), size = Vector(0.197, 0.197, 0.377), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["sprite"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(-1.094, 0.228, 9.793), size = { x = 4.635, y = 4.635 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["sprite+"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(-1.336, 0.247, 9.793), size = { x = 8.537, y = 8.537 }, color = Color(0, 0, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["teleport_ring"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0, 0, 3.834), angle = Angle(0, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["teleport_ring+"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0, 0, 7.11), angle = Angle(180, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_hammer"

SWEP.MeleeDamage = 15    --40
SWEP.HealStrength = 2.25

SWEP.ViewModel = "models/weapons/v_hammer/c_hammer.mdl"
SWEP.WorldModel = "models/weapons/w_hammer.mdl"

SWEP.AllowQualityWeapons = true

function SWEP:PostDrawViewModel(vm, pl, wep)
    local veles = self.VElements
    if not veles then return end

    local ring1ang = veles["teleport_ring"].angle
    local ring2ang = veles["teleport_ring+"].angle
    local rotatespeed = CurTime() * 200 -- velocidad de giro, ajusta el 200 a gusto

    -- Rotamos sobre Pitch (X)
    ring1ang.y = (rotatespeed) % 360
    ring2ang.y = (rotatespeed) % 360

    if self.BaseClass.PostDrawViewModel then
        self.BaseClass.PostDrawViewModel(self, vm, pl, wep)
    end
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if owner:IsValid() and owner.ShadowMan then return end

    local weles = self.WElements
    if not weles then return end

    local ring1ang = weles["teleport_ring"].angle
    local ring2ang = weles["teleport_ring+"].angle
    local rotatespeed = CurTime() * 200

    ring1ang.y = (rotatespeed) % 360
    ring2ang.y = (rotatespeed) % 360

    self:Anim_DrawWorldModel()
end

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)
