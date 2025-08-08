EFFECT.Duration	= 0.8
EFFECT.Size	= 25

local MaterialGlow = Material("effects/combinemuzzle2")
local MaterialGlow2 = Material("effects/combinemuzzle1")

function EFFECT:Init(data)
    self.Weapon = data:GetEntity()
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.LifeTime = self.Duration
	

	--particles
	local emitter = ParticleEmitter(self.Position)
	if(emitter) then
		
		for i = 1, 30 do-- for i = 1, 150 do -- Reduced the amount of particles so that players get more FPS. You can keep them to 150 they won't lose like 5-10 FPS as long as you keep the EFFECT.Duration = 0.8

			local particle = emitter:Add("effects/spark", self.Position + self.Normal * 0.7)
			particle:SetVelocity((self.Normal + VectorRand() * 0.4):GetNormal() * math.Rand(20, 35))
			particle:SetDieTime(math.Rand(0.4, 0.7 ))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(2, 5))
			particle:SetEndSize(0)
			particle:SetRoll(math.random(2,2.5))
			particle:SetRollDelta( math.Rand(-6,6))
			particle:SetColor(0, 160, 255)
			particle:SetCollide(false)
			particle:SetBounce(0.3)
			particle:SetAirResistance(5)

		end
		
		for i = 1, 1 do

		local particle2 = emitter:Add("effects/select_ring", self.Position + self.Normal * 0)
			particle2:SetVelocity((self.Normal + VectorRand() * 0):GetNormal())
			particle2:SetDieTime(0.25)
			particle2:SetStartAlpha(155)
			particle2:SetEndAlpha(0)
			particle2:SetStartSize(0)
			particle2:SetEndSize(15)
			particle2:SetColor(0, 190, 255)
			particle2:SetCollide(false)
			particle2:SetBounce(0.3)
		    particle2:SetAirResistance(5)
		end
		emitter:Finish()
	end
	
	--light
	local light = DynamicLight(0)
	if(light) then

		light.Pos = self.Position
		light.Size = 50
		light.Decay = 256
		light.R = 0
		light.G = 155
		light.B = 255
		light.Brightness = 2
		light.DieTime = CurTime() + self.Duration
	end
	--hit sound
	local normal = data:GetNormal()
	local pos = data:GetOrigin()

	pos = pos + normal * 2
	self.Pos = pos
	self.Normal = normal

	sound.Play("ambient/office/zap1.wav", pos, 80, math.random(165, 180))
end

function EFFECT:Think()
	self.LifeTime = self.LifeTime - FrameTime()
	return self.LifeTime > 0
end


function EFFECT:Render()
	local frac = math.max(0, self.LifeTime / self.Duration)
	local rgb = 255 * frac
	local color = Color(rgb, rgb, rgb, 255)

	render.SetMaterial(MaterialGlow2)
	render.DrawQuadEasy(self.Position + self.Normal, self.Normal, self.Size, self.Size, color)
	render.SetMaterial(MaterialGlow)
	render.DrawQuadEasy(self.Position + self.Normal, self.Normal, self.Size, self.Size, color)
end
