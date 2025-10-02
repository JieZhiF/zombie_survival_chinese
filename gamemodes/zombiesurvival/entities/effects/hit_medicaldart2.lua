function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local ent = data:GetEntity()
	local magnitude = data:GetMagnitude()

	local undeadeffect = magnitude == 0
	
	if ent then
		if ent:IsValid() then
			ent:EmitSound("ambient/machines/steam_release_2.wav", 70, 255)
			if ent:IsPlayer() then
				ent:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav", 70, 140)
			end
		else
			self:EmitSound("ambient/machines/steam_release_2.wav", 90, 255)
		end	
	end

	--self:EmitSound("ambient/machines/steam_release_2.wav", 100, 255)

	local offset, particle
	local axis = AngleRand()
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	for i = 1, 69 do
		local ang = norm:Angle()
		ang:RotateAroundAxis(ang:Up(), math.Rand(0, 360))
		ang:RotateAroundAxis(ang:Right(), math.Rand(-80, 80))

		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(ang:Forward() * math.Rand(4, 32))
		particle:SetDieTime(math.Rand(0.75, 1.25))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(3)
		particle:SetEndSize(10)
		if magnitude == 0 then
			particle:SetColor(0, 190, 255)
		else
			particle:SetColor(75, 75, 255)
		end
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetGravity(Vector(0, 0, -10))
		particle:SetAirResistance(100)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

