SWEP.VElements = {
	["DavidBattery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.slide_left", rel = "", pos = Vector(0, 0, 1.916), angle = Angle(0, 90, 180), size = Vector(0.35, 0.35, 0.9), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["DavidBody"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "v_weapon.elite_left", rel = "", pos = Vector(0.75, -2.3, 2.66), angle = Angle(-90, 90, -90), size = Vector(0.014, 0.018, 0.006), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["DavidMag"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.magazine_left", rel = "", pos = Vector(0, -0.8, -0.2), angle = Angle(180, 0, 0), size = Vector(0.01, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["GoliathBarrel"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "v_weapon.elite_right", rel = "", pos = Vector(0, -2.3, 3.832), angle = Angle(180, 0, -90), size = Vector(0.011, 0.018, 0.012), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	--["GoliathButton"] = { type = "Model", model = "models/props_combine/combinebutton.mdl", bone = "v_weapon.elite_right", rel = "", pos = Vector(0.79, -1.8, 0.9), angle = Angle(-90, 0, -90), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	--["GoliathButton+"] = { type = "Model", model = "models/props_combine/combinebutton.mdl", bone = "v_weapon.elite_left", rel = "", pos = Vector(-1.2, -1.9, 0.958), angle = Angle(-90, 90, 180), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["GoliathMag"] = { type = "Model", model = "models/props_combine/CombineThumper002.mdl", bone = "v_weapon.magazine_right", rel = "", pos = Vector(-0.2, 1, -1.2), angle = Angle(0, 0, -90), size = Vector(0.026, 0.03, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["GoliathSlide"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "v_weapon.slide_right", rel = "", pos = Vector(0, 0.8, -4.2), angle = Angle(90, 0, -90), size = Vector(0.01, 0.006, 0.006), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["David"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(12.455, 2.3, 3.832), angle = Angle(90, 170, 180), size = Vector(0.5, 0.5, 1.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["DavidUnder"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "David", pos = Vector(-0.9, -1.55, 4.79), angle = Angle(-90, 90, 180), size = Vector(0.015, 0.01, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Goliath"] = { type = "Model", model = "models/props_combine/combine_train02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.707, 1.7, -2.98), angle = Angle(0, 80, 180), size = Vector(0.018, 0.017, 0.012), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Goliath+"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.2, 1.24, -1.7), angle = Angle(0, -10, 180), size = Vector(0.01, 0.011, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["v_weapon.hammer_left"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.hammer_right"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.magazine_left"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.magazine_right"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.slide_left"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.slide_right"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.PrintName = "'大卫与歌利亚' 双能量手枪"
SWEP.Description = "一对强大的能量手枪。不准确但伤害高。"
SWEP.Base					= "weapon_zs_base"
SWEP.UseHands = true
SWEP.Recoil = 0.3

SWEP.Tier = 4
SWEP.Slot					= 1
SWEP.SlotPos				= 0

SWEP.ViewModel 				= "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_elite.mdl"
SWEP.ViewModelFlip 			= false
SWEP.HoldType = "duel"

SWEP.Primary.Damage			= 26
SWEP.Primary.NumShots		= 1
SWEP.Primary.Sound			= Sound("weapons/davidgoliath2.wav")
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Delay			= 0.13
SWEP.Primary.Ammo			= "pulse"
SWEP.Primary.Automatic 		= true
SWEP.TracerName = "AR2Tracer"

SWEP.HUD3DBone = "v_weapon.slide_right"
SWEP.HUD3DPos = Vector(1, 0.1, -1)
SWEP.HUD3DScale = 0.015

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
	if ( self:Clip1() == self.Primary.ClipSize or self:Ammo1() == 0 ) then return end

	self.Weapon:EmitSound( "weapons/reload.wav")
	timer.Simple(3.2, function()
		if ( not IsValid( self ) ) then return end
		self.Weapon:EmitSound( "weapons/reload_push.wav")
	end)
end

function SWEP:GetTracerOrigin()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local vm = owner:GetViewModel()
		if vm and vm:IsValid() then
			local attachment = vm:GetAttachment(self:Clip1() % 2 + 3)
			if attachment then
				return attachment.Pos
			end
		end
	end
end
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(self:Clip1() % 2 == 0 and ACT_VM_PRIMARYATTACK or ACT_VM_SECONDARYATTACK)
end


SWEP.IronSightsPos 			= Vector(-0.76, -9.68, 2.4)
SWEP.IronSightsAng 			= Vector(0, 0, 0)


--[[
SWEP.PrintName			= "Autopulse Shotgun"			

SWEP.PrintName				= "'Citadel' Plasma Machinegun"
SWEP.Description			= "Light plasma machinegun with high power and firerate but has heavy recoil."

SWEP.PrintName				= "'David and Goliath' Dual Energy Pistols"
SWEP.Description			= "A pair of powerful energy pistols. Innaccurate with high damage"

SWEP.PrintName				= "'Ender' Plasma Bullpup"
SWEP.Description			= "Multi-purpose plasma rifle, fires energy bolts at high velocities and has well rounded stats."


SWEP.PrintName				= "'Epsilon' Plasma Shotgun"
SWEP.Description			= "Fully automatic plasma shotgun with high damage and good range. Fires magnetic balls of plasma that will split into multiple 'shots', acting similar to buckshot."

SWEP.PrintName				= "'Nexus' Assault Rifle"
SWEP.Description			= "Scoped assault rifle with superior firerate, damage, and accuracy."


SWEP.PrintName    = "Tesla katana"

SWEP.PrintName				= "'Tokamak' Proton Gun"
SWEP.Description			= "Nuclear particle accelerator that fires proton bolts. Has medium-high damage and good accuracy"
]]