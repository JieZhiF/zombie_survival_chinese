include('shared.lua')

function ENT:Initialize()	
game.AddParticles( "particles/chappi_explosion.pcf" )
self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
White = Color(180,180,255)
end

function ENT:Draw()
self:DrawModel()
self.Entity:SetModelScale(math.Rand(0.3,1.2),0)
render.SetMaterial(Material("sprites/glow04_noz"))
render.DrawSprite(self.Entity:GetPos(),math.Rand(300,100),40,White)
render.DrawSprite(self.Entity:GetPos(),math.Rand(300,100),40,White)
end

