INC_CLIENT()

DEFINE_BASECLASS("weapon_zs_baseproj")
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotMedicalTools")
SWEP.SlotGroup = WEPSELECT_MEDICAL_TOOL
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60

SWEP.HUD3DBone = "ValveBiped.square"
SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
SWEP.HUD3DScale = 0.015

SWEP.WElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.5, 2, -3.701), angle = Angle(0, -90, -8), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2+"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/healthvial.mdl", bone = "ValveBiped.square", rel = "", pos = Vector(0, 0.5, 3), angle = Angle(0, 0, 90), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["2+"] = { type = "Model", model = "models/airboatgun.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, -3, 0), angle = Angle(0, 90, 180), size = Vector(0.25, 0.25, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Draw2DHUD()
	BaseClass.Draw2DHUD(self)

	local owner = self:GetOwner()
	if not owner:IsSkillActive(SKILL_SMARTTARGETING) then return end

	local player = self:GetSeekedPlayer()
	local screenscale = BetterScreenScale()
	surface.SetFont("ZSHUDFont")
	local text = player:IsValidLivingHuman() and player:Name() or "No Target"
	local _, nTEXH = surface.GetTextSize(text)

	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - 218 * screenscale, ScrH() - nTEXH * 3.5, text ~= "No Target" and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)
end

function SWEP:Draw3DHUD(vm, pos, ang)
	BaseClass.Draw3DHUD(self, vm, pos, ang)

	local owner = self:GetOwner()
	if not owner:IsSkillActive(SKILL_SMARTTARGETING) then return end

	local wid, hei = 180, 200
	local x, y = wid * 0, hei * -1

	local player = self:GetSeekedPlayer()
	surface.SetFont("ZS3D2DFontSmall")
	local text = player:IsValidLivingHuman() and player:Name() or "No Target"

	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		draw.SimpleTextBlurry(text, "ZS3D2DFontSmall", x, y, text ~= "No Target" and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
function SWEP:DrawCooldowns()
	local cooldownIcon = self:GetCooldownIcon()
    local coneGap = self:GetCone() / 2
    local betterscale = BetterScreenScale()
    local remaining = self:CooldownRingBinding()
    local maximum = self:CooldownRingMaximumBinding()
    local ringSize = math.Clamp(CrosshairCoolPrimaryCircleSize, 0.5, 16) * 2
    local ringSpacing = math.Clamp(CrosshairCoolPrimaryCircleSize, 0, 16) * 2
    local ringColor = Color(40, 255, 40, 255)
    local backgroundColor = Color(12, 12, 12, 30)

    if remaining > 0 and maximum > 0 and remaining ~= math.huge and maximum ~= math.huge then
        local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5

        if CurTime() >= self:GetReloadStart() and CurTime() <= self:GetReloadFinish() then
            local innerRadius = (ringSpacing) * 10 * betterscale
            draw.HollowCircle(centerX, centerY, innerRadius, 2 * ringSize, 270, 270 + 360 * remaining / maximum, ringColor)
            draw.HollowCircle(centerX, centerY, innerRadius, 2 * ringSize, 270, 270 + 360, backgroundColor)
            draw.SimpleTextBlurry(math.Round(remaining, 1), "RemingtonNoiseless", centerX - innerRadius * 2, centerY,ringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local iw, ih = cooldownIcon:Width(), cooldownIcon:Height()
            if iw == 0 or ih == 0 then iw, ih = 64, 64 end
            local pad = math.max(2, ringSize * 0.8)
            local iconMax = (innerRadius - pad) * 2
            local s = math.min(iconMax / iw, iconMax / ih)
            local w, h = math.floor(iw * s), math.floor(ih * s)
            local rotation = CurTime() * 90

            surface.SetMaterial(cooldownIcon)
            surface.SetDrawColor(ringColor)
            surface.DrawTexturedRectRotated(centerX, centerY, w, h, rotation)
        end
    end
end