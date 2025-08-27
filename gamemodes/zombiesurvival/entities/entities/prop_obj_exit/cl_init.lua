--local MAT_REFRACT  = Material("sprites/heatwave")
INC_CLIENT()

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 参数可调
local ROCK_MODEL   = "models/props_junk/rock001a.mdl"
local NUM_ROCKS    = 7
local ROCK_SCALE   = 1.0

local MIN_RADIUS       = 5        -- 石头初始半径
local FINAL_RADIUS_X   = 45       -- X方向最终半径
local FINAL_RADIUS_Y   = 60       -- Y方向最终半径

local MAX_ROT_SPEED    = 80       -- 最大自转速度
local MIN_ROT_SPEED    = 30       -- 最低自转速度

local MAX_ORBIT_SPEED  = 80      -- 最大公转速度
local MIN_ORBIT_SPEED  = 30       -- 最低公转速度


local MAT_GLOW     = Material("sprites/glow04_noz")
local MAT_BEAM     = Material("effects/blueblacklargebeam")
local MAT_REFRACT  = Material("sprites/heatwave")
local PORTAL_OFFSET = Vector(0, 0, 65)

local PORTAL_COLOR = Color(180, 220, 255) -- 整体颜色，可统一调整

function ENT:Initialize()
    self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

    self.currentOrbitAngle = 0

    self.Rocks = {}
    for i = 1, NUM_ROCKS do
        local rock = ClientsideModel(ROCK_MODEL, RENDERGROUP_OPAQUE)
        if IsValid(rock) then
            rock:SetNoDraw(true)
            rock:SetModelScale(ROCK_SCALE)
            
            rock:SetMaterial("models/shiny")
            rock:SetRenderMode(RENDERMODE_TRANSALPHA)
            
            table.insert(self.Rocks, {
                ent = rock,
                ang = AngleRand(-180, 180),
                speed_mult = math.Rand(0.7, 1.3)
            })
        end
    end
end

function ENT:OnRemove()
    for _, rockData in ipairs(self.Rocks or {}) do
        if IsValid(rockData.ent) then rockData.ent:Remove() end
    end
    self.Rocks = nil
end

ENT.NextEmit = 0

function ENT:DrawTranslucent()
    local ct = CurTime()
    local openPercent = self:GetOpenedPercent()
    local center = self:GetPos() + PORTAL_OFFSET
    local ft = FrameTime()

    -- 透明度
    local alpha = 120 + 175 * openPercent
    alpha = math.Clamp(alpha, 0, 255)

    -- 动态光...
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        local lightSize = 160 + openPercent * 200
        dlight.Pos = center
        dlight.r = PORTAL_COLOR.r
        dlight.g = PORTAL_COLOR.g
        dlight.b = PORTAL_COLOR.b
        dlight.Brightness = 1 + openPercent * 3
        dlight.Size = lightSize
        dlight.Decay = lightSize * 2
        dlight.DieTime = ct + 1
    end

    local ease = math.ease.InOutQuad(openPercent)

    local radiusX = MIN_RADIUS + (FINAL_RADIUS_X - MIN_RADIUS) * ease
    local radiusY = MIN_RADIUS + (FINAL_RADIUS_Y - MIN_RADIUS) * ease
    local orbitSpeed = MIN_ORBIT_SPEED + (MAX_ORBIT_SPEED - MIN_ORBIT_SPEED) * ease
    local selfRotSpeed = MIN_ROT_SPEED + (MAX_ROT_SPEED - MIN_ROT_SPEED) * ease

    self.currentOrbitAngle = self.currentOrbitAngle + orbitSpeed * ft

    -- 石头
    local rockPositions = {}
    for i, rockData in ipairs(self.Rocks or {}) do
        local rock = rockData.ent
        if IsValid(rock) then
            local base_angle = (360 / #self.Rocks) * i
            local current_angle = self.currentOrbitAngle + base_angle
            local x = math.cos(math.rad(current_angle)) * radiusX
            local y = math.sin(math.rad(current_angle)) * radiusY
            local pos = center + self:GetRight() * x + self:GetUp() * y

            rock:SetPos(pos)

            local angle_delta = selfRotSpeed * rockData.speed_mult * ft
            local delta = Angle(angle_delta, angle_delta, angle_delta)

            rockData.ang = rockData.ang + delta
            rock:SetAngles(rockData.ang)

            table.insert(rockPositions, pos)

            -- 【核心修改】使用组合方法为水晶上色
            local crystal_alpha = math.Clamp(alpha * 0.8, 0, 255)
            
            -- 1. 使用 SetColor 来设置透明度 (颜色设为白色，避免干扰)
            rock:SetColor(Color(255, 255, 255, crystal_alpha))
            
            -- 2. 使用 SetColorModulation 来“染上”我们想要的颜色
            --    (注意：这里的颜色值需要是 0-1 的范围，所以要除以 255)
            render.SetColorModulation(PORTAL_COLOR.r / 255, PORTAL_COLOR.g / 255, PORTAL_COLOR.b / 255)
            
            render.SuppressEngineLighting(true)
            rock:DrawModel()
            render.SuppressEngineLighting(false)
            
            -- 3. 绘制完毕后，立刻将颜色调制重置为白色，以免影响其他物体的渲染
            render.SetColorModulation(1, 1, 1)


            -- 发光...
            render.SetMaterial(MAT_GLOW)
            render.DrawSprite(pos, 14, 14, Color(PORTAL_COLOR.r, PORTAL_COLOR.g, PORTAL_COLOR.b, alpha * 0.5))
        end
    end

    -- 连线...
    render.SetMaterial(MAT_BEAM)
    local beamWidth = 6
    for i = 1, #rockPositions do
        local pos1 = rockPositions[i]
        local pos2 = rockPositions[(i % #rockPositions) + 1]
        render.DrawBeam(pos1, pos2, beamWidth, 0, 1, Color(PORTAL_COLOR.r, PORTAL_COLOR.g, PORTAL_COLOR.b, alpha))
    end

    -- 扭曲效果...
    if render.SupportsPixelShaders_2_0() then
        render.UpdateRefractTexture()
        render.SetMaterial(MAT_REFRACT)
        local twistSizeX = 2 * (MIN_RADIUS + (FINAL_RADIUS_X - MIN_RADIUS) * ease)
        local twistSizeY = 2 * (MIN_RADIUS + (FINAL_RADIUS_Y - MIN_RADIUS) * ease)
        render.DrawSprite(center, twistSizeX, twistSizeY, Color(PORTAL_COLOR.r, PORTAL_COLOR.g, PORTAL_COLOR.b, alpha * 0.8))
    end

    -- 粒子效果...
    if ct >= (self.NextEmit or 0) and alpha > 0 then
        self.NextEmit = ct + 0.02 + (1 - openPercent) * 0.12
        local emitter = ParticleEmitter(center)
        emitter:SetNearClip(24, 48)
        for i = 1, 6 do
            local dir = VectorRand():GetNormalized()
            local p = emitter:Add("sprites/glow04_noz", center + dir * 60)
            if p then
                p:SetDieTime(0.6 + math.Rand(0, 0.4))
                p:SetVelocity(dir * -200)
                p:SetStartAlpha(0)
                p:SetEndAlpha(alpha)
                p:SetStartSize(math.Rand(4, 8))
                p:SetEndSize(0)
                p:SetColor(PORTAL_COLOR.r, PORTAL_COLOR.g, PORTAL_COLOR.b)
                p:SetRoll(math.Rand(0, 360))
                p:SetRollDelta(math.Rand(-4, 4))
            end
        end
        emitter:Finish()
    end
end