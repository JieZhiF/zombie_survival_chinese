local HealIcon = Material("zombiesurvival/killicons/medpower_ammo_icon")
local GasSound = "ambient/machines/steam_release_2.wav"

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local ent = data:GetEntity()
    local magnitude = data:GetMagnitude()

    if IsValid(ent) then
        ent:EmitSound(GasSound, 75, 150, 1)
    else
        self:EmitSound(GasSound, 75, 150, 1)
    end

    local emitter = ParticleEmitter(pos)
    emitter:SetNearClip(16, 24)

    for i = 1, 40 do
        local particle = emitter:Add("particle/smokestack", pos)
        if particle then
            local ang = AngleRand()
            particle:SetVelocity(ang:Forward() * math.Rand(10, 40))
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(20)
            particle:SetColor(255, 220, math.random(50, 100))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetGravity(Vector(0, 0, 15))
            particle:SetAirResistance(50)
        end
    end
    emitter:Finish()

    local duration = 1.5
    self.HealSprites = {}
    for i = 1, 5 do
        table.insert(self.HealSprites, {Pos = pos + VectorRand() * 4,Vel = VectorRand() * 10 + Vector(0, 0, 30), LifeTime = duration, DieTime = CurTime() + duration, Size = math.random(2,9)})
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