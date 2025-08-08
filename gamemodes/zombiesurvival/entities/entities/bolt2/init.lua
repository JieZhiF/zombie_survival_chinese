AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
 
function ENT:Initialize()


	self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
	self.Entity:SetModelScale(0.7,0)
	self.Entity:SetMaterial("models/alyx/emptool_glow")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetElasticity(50000000)
	self.Entity:GetPhysicsObject():SetMass(5)
	self.Entity:GetPhysicsObject():SetDragCoefficient( 0)
	util.SpriteTrail(self.Entity,0,Color(255,200,200,255),3,70,5,0.5,1 / ( 20 + 0 ) * 0.5,"sprites/rollermine_shock.vmt")
	local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
end

function ENT:PhysicsCollide(data,phy)
	tr = util.TraceLine({start = self:GetPos()+Vector(0,0,-10),endpos = self:GetPos()+Vector(0,0,-20)})
	
	self.Entity:EmitSound(Sound( "npc/strider/strider_minigun.wav" ),75,110+math.Rand(0,20))
	
	--util.BlastDamage(self,self.Owner,self:GetPos(),50,7.5)
	local owner = self:GetOwner()
	print(owner)
	local dmg = DamageInfo()
	dmg:SetAttacker(owner)
	dmg:SetInflictor(self)
	dmg:SetDamageType(67108864)
	dmg:IsExplosionDamage(true)
	dmg:SetDamage(45) 
	util.BlastDamageInfo(dmg,self:GetPos(),230)
	local effectdata = EffectData()
	effectdata:SetOrigin( self.Entity:GetPos() )
	util.Effect( "plasma_boom3", effectdata )
	if tr.Hit then
	self:Remove()
	end
end

--function ENT:Touch(ent)
--if ent:IsValid() then	
	--self.Entity:Fire("kill", "", 0)
	--ParticleEffect("chappi_explosion",ent:GetPos(),Angle(0,math.Rand(180,-180),0),nil)
	--self:Remove()
	--end
--end

function ENT:Draw()
	self:DrawModel() 
end

function ENT:Think()
	
if not self.Entity:IsValid() then return end		
--self.Entity:GetPhysicsObject():ApplyForceCenter((self.Entity:GetPhysicsObject():GetVelocity()+Vector(0,0,220))*1)

end