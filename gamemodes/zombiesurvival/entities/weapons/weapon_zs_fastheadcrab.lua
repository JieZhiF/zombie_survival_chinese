AddCSLuaFile()

SWEP.Base = "weapon_zs_headcrab"

SWEP.PrintName = ""..translate.Get("weapon_zs_fastheadcrab")

SWEP.PounceDamage = 6

SWEP.NoHitRecovery = 0.6
SWEP.HitRecovery = 0.75

function SWEP:EmitBiteSound()
	self:GetOwner():EmitSound("NPC_FastHeadcrab.Bite")
end

function SWEP:EmitIdleSound()
	self:GetOwner():EmitSound("NPC_FastHeadcrab.Idle")
end

function SWEP:EmitAttackSound()
	self:GetOwner():EmitSound("NPC_FastHeadcrab.Attack")
end

function SWEP:Reload()
end
