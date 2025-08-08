local colorPrimary = Color(0, 180, 0, 255)
local colorOutline = Color(0, 0, 0, 255)
local textColor = Color(colorPrimary.r, colorPrimary.g, colorPrimary.b, 255)

-- Cached functions
local start3D2D = cam.Start3D2D
local end3D2D = cam.End3D2D
local simpleText = draw.SimpleText
local simpleTextOutlined = draw.SimpleTextOutlined

local getEyeAngles = EyeAngles
local textAlignCenter = TEXT_ALIGN_CENTER
local textAlignLeft = TEXT_ALIGN_LEFT
local textAlignRight = TEXT_ALIGN_RIGHT
local vectorUp = vector_up

-- Other utilities
local vectorScale = Vector(1.3, 1.3, 1)
local randomVector = Vector(200, 200, 200)

local mathRand = math.Rand
local mathClamp = math.Clamp

-- Rendering utilities
local suppressLighting = render.SuppressEngineLighting
local materialOverride = render.MaterialOverride
local setColorModulation = render.SetColorModulation
local setBlend = render.SetBlend
local setMaterial = render.SetMaterial
local updateRefractTexture = render.UpdateRefractTexture
local drawQuad = render.DrawQuadEasy

-- Effect properties
EFFECT.FadeInTime = 0.4

-- Initialization function
function EFFECT:Init(data)
    local randomZOffset = math.random(0, 30)
    local pos = data:GetOrigin() + Vector(0, 20, randomZOffset)
    local lifeTime = 2.4

    self.FlexFrame = data:GetScale()
    self.Ent = data:GetEntity()
    self.Pos = pos
    self.DieTime = CurTime() + lifeTime
end

-- Think function
function EFFECT:Think()
    return self.DieTime and self.DieTime > CurTime() and IsValid(self.Ent)
end

-- Render function
function EFFECT:Render()
    if self.Pos and self.DieTime and self.FadeInTime then
        self.ScrollTime = self.ScrollTime or CurTime() + self.FadeInTime
        local eyeAngles = getEyeAngles()
        local right = eyeAngles:Right()
        eyeAngles:RotateAroundAxis(eyeAngles:Up(), 270)
        eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90)

        -- Calculate fade and alpha
        local fadeFactor = mathClamp(1 - (self.ScrollTime - CurTime()) / self.FadeInTime, 0, 1)
        local alphaFactor = mathClamp(self.DieTime - CurTime(), 0, 1) * 255

        -- Sinusoidal effect parameters
        local waveSpeed = 2  -- speed of the motion
        local waveAmplitude = 10  -- how much the text moves up and down

        -- Loop to draw the text
        for i = 0, 0 do
            local pos = self.Pos
            if pos then
                -- Adding the wave effect by modifying the Z position with a sine function
                local waveOffset = math.sin(CurTime() * waveSpeed + i) * waveAmplitude * fadeFactor

                -- Apply waveOffset to the Z position
                local displayPos = pos - vectorUp * (i * 16 * fadeFactor + waveOffset)

                -- Start the 3D rendering
                start3D2D(displayPos, eyeAngles, 0.2 - 0.04 * i ^ 1.1)

                -- Render the text with slight randomized offsets
                simpleTextOutlined(""..translate.Get("melee_perfectblocked"), "zs_floatingtext_melee", -210 + i * 20 * fadeFactor + mathRand(-1 * (i + 2), i + 2), mathRand(-1 * (i + 2), i + 2), colorPrimary, textAlignCenter, textAlignCenter, 5, colorOutline)

                -- End the 3D rendering
                end3D2D()
            end
        end
    end
end