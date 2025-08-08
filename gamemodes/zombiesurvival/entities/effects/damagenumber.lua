EFFECT.LifeTime = 3

local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local TEXT_ALIGN_BOTTOM = TEXT_ALIGN_BOTTOM
local draw = draw
local cam = cam

local Particles = {}

local col = Color(220, 0, 0)
local colprop = Color(220, 220, 0)
hook.Add("PostDrawTranslucentRenderables", "DrawDamage", function()
    if #Particles == 0 then return end

    local done = true
    local curtime = CurTime()

    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    local throughWalls = GAMEMODE and GAMEMODE.DamageNumberThroughWalls or false
    if throughWalls then
        cam.IgnoreZ(true)
    end

    for _, particle in pairs(Particles) do
        -- 检查 particle 及其 DieTime 是否存在
        if particle and particle.DieTime and curtime < particle.DieTime then
            local c = particle.Type == 1 and colprop or col

            done = false

            c.a = math.Clamp(particle.DieTime - curtime, 0, 1) * 220

            local scale = GAMEMODE and GAMEMODE.DamageNumberScale or 1
            cam.Start3D2D(particle:GetPos(), ang, 0.1 * scale)
                draw.SimpleText(particle.Amount, "ZS3D2DFont2", 0, 0, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            cam.End3D2D()
        end
    end

    if throughWalls then
        cam.IgnoreZ(false)
    end

    if done then
        Particles = {}
    end
end)
local gravity = Vector(0, 0, -500)
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local amount = data:GetMagnitude()
    local Type = data:GetScale()
    
    -- 检查并设置DamageNumberSpeed的默认值
    local velscal = GAMEMODE and GAMEMODE.DamageNumberSpeed or 1

    local vel = VectorRand()
    vel.z = math.Rand(0.7, 0.98)
    vel:Normalize()

    local emitter = ParticleEmitter(pos)
    local particle = emitter:Add("sprites/glow04_noz", pos)
    particle:SetDieTime(2)
    particle:SetStartAlpha(0)
    particle:SetEndAlpha(0)
    particle:SetStartSize(0)
    particle:SetEndSize(0)
    particle:SetCollide(true)
    particle:SetBounce(0.7)
    particle:SetAirResistance(32)
    particle:SetGravity(gravity * (velscal ^ 2))
    particle:SetVelocity(math.Clamp(amount, 5, 50) * 4 * vel * velscal)

    particle.Amount = amount
    
    -- 检查并设置DamageNumberLifetime的默认值
    local lifetime = GAMEMODE and GAMEMODE.DamageNumberLifetime or 1
    particle.DieTime = CurTime() + 2 * lifetime
    particle.Type = Type

    table.insert(Particles, particle)

    emitter:Finish() emitter = nil collectgarbage("step", 64)
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end