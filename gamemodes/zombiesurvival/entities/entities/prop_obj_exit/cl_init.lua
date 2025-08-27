INC_CLIENT()

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--[[
"effects/strider_pinch_dudv" → HL2 stock dudv texture (used for Combine shield distortions)"effects/strider_pinch_dudv" →HL2 库存 dudv 纹理（用于联合盾牌扭曲）

"effects/warp01" → classic HL2 vortex warp texture"effects/warp01" →经典 HL2 涡旋扭曲纹理

"effects/blueblacklargebeam" → additive beam, not refract but nice layered look"effects/blueblacklargebeam" →附加光束，不折射，但有漂亮的分层外观

"sprites/heatwave" → this is in base HL2 and supports refract if you call render.UpdateRefractTexture() before drawing."sprites/heatwave" → 这是基础 HL2 中的功能 ，如果在绘制之前调用 render.UpdateRefractTexture() ，则支持折射
]]

-- 参数可调
local ROCK_MODEL = "models/props_junk/rock001a.mdl"
local NUM_ROCKS = 8
local ROCK_SCALE = 1.0
local RING_SPRITES = 24
local ELLIPSE_RX = 50
local ELLIPSE_RY = 70

local MAT_GLOW = Material("sprites/glow04_noz")
local MAT_RING = Material("effects/blueflare1")
local MAT_REFRACT = Material("effects/bluelaser1")
local PORTAL_OFFSET = Vector(0, -20, 0)

function ENT:Initialize()
    self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

    -- 环绕的石头
    self.Rocks = {}
    for i = 1, NUM_ROCKS do
        local rock = ClientsideModel(ROCK_MODEL, RENDERGROUP_OPAQUE)
        if IsValid(rock) then
            rock:SetNoDraw(true)
            rock:SetModelScale(ROCK_SCALE)
            table.insert(self.Rocks, rock)
        end
    end
end

function ENT:OnRemove()
    for _, r in ipairs(self.Rocks or {}) do
        if IsValid(r) then r:Remove() end
    end
    self.Rocks = nil
end

ENT.NextEmit = 0

function ENT:DrawTranslucent()
    local ct = CurTime()
    local openPercent = self:GetOpenedPercent()    -- 开门进度
    local risePercent = self:GetRise()             -- 出生渐显
	local center = self:GetPos() + PORTAL_OFFSET

    -- 最终透明度：出生渐显 + 开门变亮
    local alpha = 120 * risePercent + 175 * openPercent
    alpha = math.Clamp(alpha, 0, 255)

    -- 动态光
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
		local lightSize = 160 + openPercent * 200
        dlight.Pos = center
        dlight.r = 160
        dlight.g = 200
        dlight.b = 255
        dlight.Brightness = 1 + openPercent * 3
        dlight.Size = lightSize
        dlight.Decay = lightSize * 2
        dlight.DieTime = ct + 1
    end

    -- 中心扭曲
    if render.SupportsPixelShaders_2_0() then
        render.UpdateRefractTexture()
        render.SetMaterial(MAT_REFRACT)
        render.DrawSprite(center, ELLIPSE_RX * 2, ELLIPSE_RY * 2, Color(180, 220, 255, alpha * 0.8))
    end

    -- 环绕光圈
    render.SetMaterial(MAT_RING)
    local ringsize = 28 + 28 * openPercent
    for i = 0, RING_SPRITES - 1 do
        local a = (i / RING_SPRITES) * math.pi * 2 + ct * 0.8
        local x = math.cos(a) * ELLIPSE_RX
        local y = math.sin(a) * ELLIPSE_RY
        local pos = center + self:GetRight() * x + self:GetUp() * y
        render.DrawSprite(pos, ringsize, ringsize, Color(180, 210, 255, alpha))
    end

    -- 石头
    for i, rock in ipairs(self.Rocks or {}) do
        if IsValid(rock) then
            local base_angle = (360 / #self.Rocks) * i
            local current_angle = ct * 40 + base_angle
            local x = math.cos(math.rad(current_angle)) * ELLIPSE_RX
            local y = math.sin(math.rad(current_angle)) * ELLIPSE_RY
            local pos = center + self:GetRight() * x + self:GetUp() * y

            rock:SetPos(pos)
            rock:SetAngles(Angle(ct * 80, ct * 80, ct * 80))

            render.SuppressEngineLighting(true)
            render.SetColorModulation(0.65, 0.8, 1)
            rock:DrawModel()
            render.SetColorModulation(1, 1, 1)
            render.SuppressEngineLighting(false)

            render.SetMaterial(MAT_GLOW)
            render.DrawSprite(pos, 14, 14, Color(200, 230, 255, alpha * 0.5))
        end
    end

    -- 粒子效果
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
                p:SetColor(200, 230, 255)
                p:SetRoll(math.Rand(0, 360))
                p:SetRollDelta(math.Rand(-4, 4))
            end
        end
        emitter:Finish()
    end
end
