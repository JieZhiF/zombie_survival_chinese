INC_CLIENT()

SWEP.PrintName = ""..translate.Get("weapon_zs_chemzombie")
SWEP.DrawCrosshair = false

function SWEP:Think()
end

function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end
