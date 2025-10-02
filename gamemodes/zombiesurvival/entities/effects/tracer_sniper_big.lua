EFFECT.Mat = Material("trails/laser")
EFFECT.SmokeMat = Material("particle/particle_smokegrenade")

function EFFECT:Init(data)
    self.Position = data:GetStart()
    self.WeaponEnt = data:GetEntity()
    self.Attachment = data:GetAttachment()

    if self.WeaponEnt:GetIronsights() then
        self.StartPos = data:GetStart()
    else
        self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
    end

    self.EndPos = data:GetOrigin()
    self.LifeTime = 1.4
    self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local fraction = 1 - ((self.DieTime - CurTime()) / self.LifeTime)
    render.SetMaterial(self.Mat)

    local tracerPos = self.EndPos
    local startPos = LerpVector(math.Clamp(fraction * 0.1, 0, 1), self.StartPos, tracerPos)

    render.DrawBeam(self.StartPos, tracerPos, 6, 0, 1, Color(255, 255, 255, 50 / fraction))

    local emitter = ParticleEmitter(LerpVector(fraction, self.StartPos, self.EndPos))
    if emitter then
        for i = 1, 2 do
            local particle = emitter:Add(self.SmokeMat, LerpVector(fraction * 5, startPos, tracerPos))
            if particle then
                particle:SetVelocity(VectorRand() * 1)
                particle:SetLifeTime(0)
                particle:SetDieTime(1.4)
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(0.2)
                particle:SetEndSize(3)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetColor(255, 255, 255)
            end
        end
        emitter:Finish()
    end
end