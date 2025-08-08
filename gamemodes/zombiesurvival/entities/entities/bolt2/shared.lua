

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false


function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end
