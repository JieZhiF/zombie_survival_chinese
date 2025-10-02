AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_medicalkit")
SWEP.Description = ""..translate.Get("weapon_zs_medicalkit_description")

SWEP.SlotPos = 0

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotMedkits")
	SWEP.SlotGroup = WEPSELECT_MEDICAL_KIT
	SWEP.ViewModelFOV = 57
	SWEP.ViewModelFlip = false

	SWEP.BobScale = 2
	SWEP.SwayScale = 1.5
end

SWEP.Base = "weapon_zs_base"

SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.UseHands = true

SWEP.Heal = 15
SWEP.Primary.Delay = 10

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.DelayMul = 20 / SWEP.Primary.Delay
SWEP.Secondary.HealMul = 10 / SWEP.Heal

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.HealRange = 36

--SWEP.NoDismantle = true

SWEP.NoMagazine = true
SWEP.AllowQualityWeapons = true

SWEP.HoldType = "slam"


GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_HEALCOOLDOWN, -0.8)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEALRANGE, 4, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEALING, 1.5)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_medicalkit_r1"), ""..translate.Get("weapon_zs_medicalkit_r1_description"), function(wept)
	wept.FixUsage = true
	wept.Primary.Delay = wept.Primary.Delay * 1.3
end)

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	GAMEMODE:DoChangeDeploySpeed(self)
end

function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	local trtbl = owner:CompensatedPenetratingMeleeTrace(self.HealRange, 2, nil, nil, true)
	local ent
	for _, tr in pairs(trtbl) do
		local test = tr.Entity
		if test and test:IsValidLivingHuman() and gamemode.Call("PlayerCanBeHealed", test) then
			ent = test

			break
		end
	end

	if not ent then return end

	local multiplier = self.MedicHealMul or 1
	local cooldownmultiplier = self.MedicCooldownMul or 1
	local healed = owner:HealPlayer(ent, math.min(self:GetCombinedPrimaryAmmo(), self.Heal))
	local totake = self.FixUsage and 15 or math.ceil(healed / multiplier)

	local effect = EffectData()
	effect:SetStart(ent:GetPos())
	effect:SetOrigin(ent:GetPos() + Vector(0,0,40))
	effect:SetEntity(ent)

	util.Effect("hit_medical", effect)
	if totake > 0 then
		self:SetNextCharge(CurTime() + self.Primary.Delay * math.min(1, healed / self.Heal) * cooldownmultiplier)
		owner.NextMedKitUse = self:GetNextCharge()

		self:TakeCombinedPrimaryAmmo(totake)

		self:EmitSound("items/medshot4.wav")

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		owner:DoAttackEvent()
		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if not self:CanPrimaryAttack() or not gamemode.Call("PlayerCanBeHealed", owner) then return end

	local multiplier = self.MedicHealMul or 1
	local cooldownmultiplier = self.MedicCooldownMul or 1
	local healed = owner:HealPlayer(owner, math.min(self:GetCombinedPrimaryAmmo(), self.Heal * self.Secondary.HealMul))
	local totake = self.FixUsage and 10 or math.ceil(healed / multiplier)


	local effect = EffectData()
	effect:SetStart(owner:GetPos())
	effect:SetOrigin(self:GetPos() + Vector(0,0,10))
	effect:SetEntity(owner)

	util.Effect("hit_medical", effect)
	if totake > 0 then
		self:SetNextCharge(CurTime() + self.Primary.Delay * self.Secondary.DelayMul * math.min(1, healed / self.Heal * self.Secondary.HealMul) * cooldownmultiplier)
		owner.NextMedKitUse = self:GetNextCharge()

		self:TakeCombinedPrimaryAmmo(totake)

		self:EmitSound("items/smallmedkit1.wav")

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		owner:DoAttackEvent()
		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end
end

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	if CLIENT then
		hook.Add("PostPlayerDraw", "PostPlayerDrawMedical", GAMEMODE.PostPlayerDrawMedical)
		GAMEMODE.MedicalAura = true
	end

	return true
end

function SWEP:Holster()
	if CLIENT and self:GetOwner() == MySelf then
		hook.Remove("PostPlayerDraw", "PostPlayerDrawMedical")
		GAMEMODE.MedicalAura = false
	end

	return true
end

function SWEP:OnRemove()
	if CLIENT and self:GetOwner() == MySelf then
		hook.Remove("PostPlayerDraw", "PostPlayerDrawMedical")
		GAMEMODE.MedicalAura = false
	end
end

function SWEP:Reload()
end

function SWEP:SetNextCharge(tim)
	self:SetDTFloat(0, tim)
end

function SWEP:GetNextCharge()
	return self:GetDTFloat(0)
end

function SWEP:CanPrimaryAttack()
	local owner = self:GetOwner()
	if owner:IsHolding() or owner:GetBarricadeGhosting() then return false end

	if self:GetPrimaryAmmoCount() <= 0 then
		self:EmitSound("items/medshotno1.wav")

		self:SetNextCharge(CurTime() + 0.75)
		return false
	end

	return self:GetNextCharge() <= CurTime() and (owner.NextMedKitUse or 0) <= CurTime()
end

if not CLIENT then return end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

local texGradDown = surface.GetTextureID("VGUI/gradient_down")
local SpriteGlow   = Material("sprites/glow04_noz")
local HealthSprite = Material("zombiesurvival/killicons/medpower_ammo_icon", "noclamp smooth")

function SWEP:DrawHUD()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local scale = BetterScreenScale()
    local wid, hei = 384 * scale, 16 * scale
    local x, y = ScrW() - wid - 32 * scale, ScrH() - hei - 72 * scale
    local texty = y - 4 - draw.GetFontHeight("Typenoksidi")

    -- Cooldown real
    local nextCharge = owner.NextMedKitUse or self:GetNextCharge()
    local timeleft = nextCharge - CurTime()
    local startTime = self.LastChargeStart or (CurTime() - math.max(timeleft, 0))
    local cooldownTotal = math.max(nextCharge - startTime, 0)
    local fraction = math.Clamp(timeleft / cooldownTotal, 0, 1)

    local iconSize = 45 * scale
    surface.SetMaterial(HealthSprite)

    if timeleft <= 0 then
        surface.SetDrawColor(0, 255, 0, 255)
    else
        surface.SetDrawColor(math.min(255, 50 * timeleft), 0, 0, 255)
    end
    surface.DrawTexturedRect(x, y - 150 * scale, iconSize, iconSize)

    if timeleft > 0 then
        surface.SetDrawColor(5, 5, 5, 180)
        surface.DrawRect(x, y, wid, hei)

        local barWidth = fraction * wid

        surface.SetDrawColor(50, 255, 50, 180)
        surface.SetTexture(texGradDown)
        surface.DrawTexturedRect(x, y, barWidth, hei)

        surface.SetDrawColor(50, 255, 50, 180)
        surface.DrawOutlinedRect(x, y, wid, hei)

        surface.SetMaterial(SpriteGlow)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawTexturedRect(x + math.max(0, barWidth - 6), y + 1 - hei / 2, 6, hei * 2)

        draw.SimpleText(math.Round(fraction * 100) .. "%", "Typenoksidi", x - 64 * scale, texty + hei * 1.75, COLOR_GREEN, TEXT_ALIGN_LEFT)
    end

    draw.SimpleText("Heal Potency: " .. self.Heal, "Typenoksidi", x, texty - 40 * scale, Color(255, 0, 0), TEXT_ALIGN_LEFT)
    draw.SimpleText(self.PrintName, "Typenoksidi", x, texty, COLOR_GREEN, TEXT_ALIGN_LEFT)

    local charges = self:GetPrimaryAmmoCount()
    local chargeColor = charges > 0 and COLOR_GREEN or COLOR_DARKRED
    draw.SimpleText(charges, "Typenoksidi", x + wid, texty, chargeColor, TEXT_ALIGN_RIGHT)

    if GetConVar("crosshair"):GetInt() == 1 then
        self:DrawCrosshairDot()
    end
    self:DrawCooldowns()
end

function SWEP:CooldownRingBinding()
    return math.max(0, self:GetNextCharge() - CurTime())
end

function SWEP:CooldownRingMaximumBinding()
    return math.max(self.Primary.Delay, self:GetNextCharge() - (self.LastChargeStart or CurTime()))
end

function SWEP:DrawCooldowns()
    if self:GetPrimaryAmmoCount() <= 0 then return end

    local cooldownIcon = self:GetCooldownIcon()
    local betterscale = BetterScreenScale()
    local remaining = self:CooldownRingBinding()
    local maximum = self:CooldownRingMaximumBinding()
    local ringSize = math.Clamp(CrosshairCoolPrimaryCircleSize, 0.5, 16)
    local ringSpacing = ringSize + (self.CooldownExtraSize or 0)
    local ringColor = Color(40, 255, 40, 255)
    local backgroundColor = Color(12, 12, 12, 30)

    if remaining > 0 and maximum > 0 then
        local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5
        local fraction = remaining / maximum
        local innerRadius = ringSpacing * 10 * betterscale

        draw.HollowCircle(centerX, centerY, innerRadius, 2 * ringSize, 270, 270 + 360, backgroundColor)
        draw.HollowCircle(centerX, centerY, innerRadius, 2 * ringSize, 270, 270 + 360 * fraction, ringColor)

        draw.SimpleTextBlurry(math.Round(remaining, 1), "RemingtonNoiseless", centerX - innerRadius * 2, centerY, ringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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