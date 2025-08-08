INC_CLIENT()

SWEP.PrintName = ""..translate.Get("weapon_zs_crow")
SWEP.DrawCrosshair = false

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Think()
end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
