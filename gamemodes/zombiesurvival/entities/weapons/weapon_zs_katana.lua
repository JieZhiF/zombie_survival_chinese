AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_katana")
SWEP.Description = ""..translate.Get("weapon_zs_katana_desc")

if CLIENT then
	SWEP.ViewModelFOV = 75

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
    SWEP.ShowWorldModelOriginal = false -- 自定义变量避免覆盖
	SWEP.VElements={
		["1"]={type="Model",model="models/props_foliage/driftwood_01a.mdl",bone="ValveBiped.Bip01_R_Hand",rel="",pos=Vector(2.674,2.345,1.289),angle=Angle(-100.454,180,88.791),size=Vector(0.019,0.054,0.043),color=Color(100,100,100,255),surpresslightning=false,material="models/shadertest/shader2",skin=0,bodygroup={}},
		["2"]={type="Model",model="models/XQM/cylinderx1.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(4.008,0,0.763),angle=Angle(0,0,0),size=Vector(0.045,0.4,0.3),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
		["2++"]={type="Model",model="models/hunter/tubes/circle2x2d.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(3.9,-0.713,0.769),angle=Angle(0,90,0),size=Vector(0.029,0.949,0.15),color=Color(255,50,50,255),surpresslightning=false,material="models/props/cs_office/snowmana",skin=0,bodygroup={}},
		["2+++"]={type="Model",model="models/hunter/plates/plate05x1.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(4.61,0,0.763),angle=Angle(90,-90,0.5),size=Vector(0.026,0.025,0.5),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
		["2++++"]={type="Model",model="models/hunter/misc/sphere1x1.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(-3.658,0,0.779),angle=Angle(90,-90,90),size=Vector(0.045,0.054,0.019),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}}
	}
	SWEP.WElements={
		["1"]={type="Model",model="models/props_foliage/driftwood_01a.mdl",bone="ValveBiped.Bip01_R_Hand",rel="",pos=Vector(2.674,2.345,0.3),angle=Angle(-100.454,180,88.791),size=Vector(0.019,0.054,0.043),color=Color(100,100,100,255),surpresslightning=false,material="models/shadertest/shader2",skin=0,bodygroup={}},
		["2"]={type="Model",model="models/XQM/cylinderx1.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(4.008,0,0.763),angle=Angle(0,0,0),size=Vector(0.045,0.4,0.3),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
		["2++"]={type="Model",model="models/hunter/tubes/circle2x2d.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(3.9,-0.713,0.769),angle=Angle(0,90,0),size=Vector(0.029,0.75,0.15),color=Color(255,50,50,255),surpresslightning=false,material="models/props/cs_office/snowmana",skin=0,bodygroup={}},
		["2+++"]={type="Model",model="models/hunter/plates/plate05x1.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(4.61,0,0.763),angle=Angle(90,-90,0.5),size=Vector(0.026,0.025,0.5),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
		["2++++"]={type="Model",model="models/hunter/misc/sphere1x1.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(-3.658,0,0.779),angle=Angle(90,-90,90),size=Vector(0.045,0.054,0.019),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}}
	}
	SWEP.ViewModelBoneMods={["ValveBiped.Bip01_L_UpperArm"]={scale=Vector(1,1,1),pos=Vector(-1,0,0),angle=Angle(0,0,0)}}
	SWEP.VMPos = Vector(0,-5, 0)
	SWEP.VMAng = Angle(0, 0, 0)
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"


SWEP.MeleeDamage = 94
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.MeleeRange = 70
SWEP.MeleeSize = 1.3
SWEP.MeleeKnockBack = -90

SWEP.Primary.Delay = 1.05

SWEP.SwingTime = 0.2
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true

SWEP.HitAnim = ACT_VM_MISSCENTER

SWEP.Tier = 3

SWEP.DefendingDamageBlockedDefault = 4
SWEP.DefendingDamageBlocked = 4

SWEP.BlockPos = Vector(-22.19, -5.29, 9.319)
SWEP.BlockAng = Angle(0.732, -14.687, -66.086)

function SWEP:PlaySwingSound()
self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav",75,math.random(130,160))
end
function SWEP:PlayHitSound()
	--self:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav",100, math.Rand(86, 100))
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(1,4)..".ogg",100, math.Rand(100, 110))
end
function SWEP:PlayHitFleshSound()
	--self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(1,4)..".ogg",100, math.Rand(110, 130), 0.75, CHAN_WEAPON + 20)
	--self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.Rand(86, 90), 0.75, CHAN_WEAPON + 20) 
	self:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav",100, math.Rand(130, 150), 0.75, CHAN_WEAPON + 20)
end

function SWEP:Deploy()

	self.Weapon:EmitSound("weapons/katana/draw.wav", 100, math.random(95,110))

	return true
end

--[[function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and hitent:Team() == TEAM_UNDEAD and hitent:IsHeadcrab() and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then
		hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, self:GetOwner(), self, tr.HitPos)
	end
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and hitent:Team() == TEAM_UNDEAD and hitent:IsHeadcrab() and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then
		self.MeleeDamage = hitent:GetMaxHealth() * 10
	end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end --]]
