DEFINE_BASECLASS("weapon_zs_base")
local BaseClassMelee = baseclass.Get("weapon_zs_basemelee")

SWEP.PrintName = "'Tropyer' M1 Garand"
SWEP.Category = "ZS Guns unofficial"

if CLIENT then

	SWEP.ViewModelFOV = 75
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "ValveBiped.garand_base"
	SWEP.HUD3DPos = Vector(-2.79, -1.361, 8.834)
	SWEP.HUD3DAng = Angle(180, 90, 0)
	SWEP.HUD3DScale = 0.022

    SWEP.VMPos = Vector(0, -1, 1)
    SWEP.VMAng = Angle(0, 0, 0)

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -40.755, 0) }
}

SWEP.VElements = {
	["base"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope+", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope+", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base_scope"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped", rel = "rail", pos = Vector(-0.015, 1.758, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["base_scope+"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped", rel = "rail", pos = Vector(-0.015, -1.37, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["rail"] = { type = "Model", model = "models/props_phx/gears/rack18.mdl", bone = "ValveBiped.garand_base", rel = "", pos = Vector(-3.409, 0.504, 15.094), angle = Angle(0, -90, 89.767), size = Vector(0.207, 0.079, 0.053), color = Color(161, 161, 161, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_blur"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.garand_base", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = true, nocull = false, material = "pp/dof", skin = 0, bodygroup = {} },
	["scope_back_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, 1.5, 1.3), angle = Angle(-135.69901, 0, 90), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_back_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.garand_base", rel = "scope_back_sight", pos = Vector(0, 0, -4.161), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(182, 182, 182, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/screenspace", skin = 0, bodygroup = {} },
	["scope_back_lens+"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.garand_base", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_lens++"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.garand_base", rel = "scope_front_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, 0.418, 1.3), angle = Angle(0, 0, -90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, -1.7, 1.3), angle = Angle(-135.69901, 0, 87.641), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.garand_base", rel = "scope_front_sight", pos = Vector(0, 0, -4.15), angle = Angle(90, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_front_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, -0.418, 1.3), angle = Angle(0, 0, 90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_middle"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, -1.725, 1.28), angle = Angle(0, 0, 90), size = Vector(0.02, 0.02, 0.078), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} }
}
 
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope+", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope+", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base_scope"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(-0.015, 1.758, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["base_scope+"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(-0.015, -1.37, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["rail"] = { type = "Model", model = "models/props_phx/gears/rack18.mdl", bone = "ValveBiped.Anim_Attachment_RH", rel = "", pos = Vector(-0.371, -6.851, 13.073), angle = Angle(-180, -4.528, -81.509), size = Vector(0.207, 0.079, 0.053), color = Color(161, 161, 161, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_blur"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = true, nocull = false, material = "pp/dof", skin = 0, bodygroup = {} },
	["scope_back_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, 1.5, 1.3), angle = Angle(-135.69901, 0, 90), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_back_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_back_sight", pos = Vector(0, 0, -4.161), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(182, 182, 182, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/screenspace", skin = 0, bodygroup = {} },
	["scope_back_lens+"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_lens++"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_front_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, 0.418, 1.3), angle = Angle(0, 0, -90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, -1.7, 1.3), angle = Angle(-135.69901, 0, 87.641), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_front_sight", pos = Vector(0, 0, -4.15), angle = Angle(90, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_front_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, -0.418, 1.3), angle = Angle(0, 0, 90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_middle"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, -1.725, 1.28), angle = Angle(0, 0, 90), size = Vector(0.02, 0.02, 0.078), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} }
}


end

SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"
SWEP.WeaponType = "rifle"

SWEP.ViewModel = "models/weapons/tfa_dods/c_garand.mdl"
SWEP.WorldModel = "models/weapons/w_garand.mdl"
SWEP.UseHands = true

SWEP.Primary.Damage = 65
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.36

SWEP.Primary.ClipSize = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 25

SWEP.ReloadSpeed = 0.64

SWEP.MeleeDamage = 45
SWEP.MeleeRange = 72
SWEP.MeleeSize = 0.95
SWEP.MeleeKnockBack = 0

SWEP.SwingTime = 0.35
SWEP.SwingRotation = Angle(-8, -20, 0)
SWEP.SwingOffset = Vector(0, -30, 0)

SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 1.3

SWEP.ConeMax = 2.75
SWEP.ConeMin = 1.25

SWEP.Recoil = 1.4

SWEP.WalkSpeed = SPEED_SLOW

sound.Add( {
	name = "Weapon_Garand.BoltForward",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {100},
	sound = "weapons/weapon_zs_garand/garand_boltforward.wav"
} )

sound.Add( {
	name = "Weapon_Garand.ClipIn1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "weapons/weapon_zs_garand/garand_clipin1.wav"
} )

sound.Add( {
	name = "Weapon_Garand.ClipIn2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "weapons/weapon_zs_garand/garand_clipin2.wav"
} )

sound.Add( {
	name = "Weapon_Garand.Draw",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {100},
	sound = "weapons/draw_rifle.wav"
} )

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

if CLIENT then

function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			return pos + ang:Up() * 256, ang
		end

		return BaseClass.GetViewModelPosition(self, pos, ang)
end

function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			self:DrawRegularScope()
		end
end

end

SWEP.MeleeFlagged = true

function SWEP:EmitFireSound()
	self:EmitSound("weapons/ak47/ak47-1.wav", 75, 76, 0.53)
	self:EmitSound("weapons/scout/scout_fire-1.wav", 75, 86, 0.67, CHAN_AUTO+20)
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(4)..".ogg")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("weapons/knife/knife_stab.wav", 70, math.random(95, 105), 1, CHAN_AUTO+20)
end

function SWEP:ShootBullets(dmg, numbul, cone)
	if self:Clip1() == 0 then
		self:EmitSound("npc/roller/blade_out.wav", 70, math.random(80, 84), 0.5)
		self:EmitSound("weapons/weapon_zs_garand/garand_clipding.wav", 70, 100, 0.5, CHAN_AUTO+21)
	end

	BaseClass.ShootBullets(self, dmg, numbul, cone)
end