local HealIcon = Material("zombiesurvival/killicons/medpower_ammo_icon")
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
			particle:SetColor(0, 255, 0)
		else
			particle:SetColor(255, 255, 5)
		end
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetGravity(Vector(0, 0, -10))
		particle:SetAirResistance(100)
	end
	emitter:Finish()

 	local duration = 1.5
    self.HealSprites = {}
    for i = 1, 5 do
        table.insert(self.HealSprites, {Pos = pos + VectorRand() * 4,Vel = VectorRand() * 10 + Vector(0, 0, 30), LifeTime = duration, DieTime = CurTime() + duration, Size = math.random(2,6)})
    end
end

function EFFECT:Think()
    if not self.HealSprites then return false end

    for k, spr in pairs(self.HealSprites) do
        spr.Pos = spr.Pos + spr.Vel * FrameTime()
        spr.Vel = spr.Vel + Vector(0, 0, -30) * FrameTime()
        if CurTime() > spr.DieTime then
		    self.HealSprites[k] = nil
		end
    end

    return next(self.HealSprites) ~= nil 
end

function EFFECT:Render()
    if not self.HealSprites then return end

    render.SetMaterial(HealIcon)
    for _, spr in pairs(self.HealSprites) do
    	local remaining = spr.DieTime - CurTime()
		local frac = math.Clamp(remaining / spr.LifeTime, 0, 1)
		local alpha = 255 * frac
        render.DrawSprite(spr.Pos, spr.Size, spr.Size, Color(0, 255, 0, alpha))
    end
end