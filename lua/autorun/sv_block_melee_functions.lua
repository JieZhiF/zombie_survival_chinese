-- Enable/Disable the melee blocking feature
CreateConVar("zsw_enable_block", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Enable or disable the melee blocking feature")

-- Enable/Disable the melee cooldown feature
CreateClientConVar("zsw_enable_cooldown", 1, true, false, "Enable or disable the melee cooldown feature")

-- Enable/Disable the custom HUD
CreateClientConVar("zsw_enable_hud", 1, true, false, "Enable or disable the custom HUD")

-- Enable/Disable RTS Hud
CreateClientConVar("zsw_enable_rts_hud", 1, true, false, "Enable or disable the RTS HUD")

-- Crosshair mode: 0 = Classic, 1 = Remastered
CreateClientConVar("zsw_crosshair_mode", 1, true, false, "Select the crosshair mode: 0 for Classic, 1 for Remastered")

-- Define the client CVAR for font choice
CreateClientConVar("zsw_font_choice", "1", true, false, "Choose the font to use: 1 = ZSM_Coolvetica (default), 2 = Remington Noiseless, 3 = Typenoksidi, 4 = Ghoulish Fright AOE")

if CLIENT then
    
    surface.CreateFont( "zs_floatingtext_melee", {
        font = "typenoksidi", --typenoksidi -- Original: Remington Noiseless
        extended = false,
        size = 40,
        shadow = true,
        outline = true,
    })
    
    surface.CreateFont( "ZSM_Coolvetica", {
        font = "Coolvetica", --Ghoulish Fright AOE --Remington Noiseless
        extended = false,
        size = 25,
        shadow = true,
        outline = true,
    })
    
    surface.CreateFont( "ZSM_CoolveticaBlur", {
        font = "Coolvetica", --Ghoulish Fright AOE --Remington Noiseless
        extended = false,
        size = 25,
        shadow = true,
        outline = true,
        blursize = 3,
    })
    
    surface.CreateFont( "csfont", {
    font = "csd", 
    extended = false,
    size = 65,
    weight = 0,
    blursize = 0,
    scanlines = 0, 
    })
    
    -- New font definitions
    surface.CreateFont("RemingtonNoiseless", {
        font = "Remington Noiseless", -- The font name as recognized by the system
        extended = false,
        size = 22, -- Adjust the size as needed
        shadow = true,
        outline = true,
    })
    
    surface.CreateFont("RemingtonNoiselessBlur", {
        font = "Remington Noiseless", -- The font name as recognized by the system
        extended = false,
        size = 22, -- Adjust the size as needed
        shadow = true,
        outline = true,
        blursize = 3, -- Adding blursize for the blurred version
    })
    
    surface.CreateFont("Typenoksidi", {
        font = "typenoksidi", -- The font name as recognized by the system
        extended = false,
        size = 22, -- Adjust the size as needed
        shadow = true,
        outline = true,
    })
    
    surface.CreateFont("TypenoksidiBlur", {
        font = "typenoksidi", -- The font name as recognized by the system
        extended = false,
        size = 22, -- Adjust the size as needed
        shadow = true,
        outline = true,
        blursize = 3, -- Adding blursize for the blurred version
    })
    
    surface.CreateFont("GhoulishFrightAOE", {
        font = "Ghoulish Fright AOE", -- The font name as recognized by the system
        extended = false,
        size = 35, -- Adjust the size as needed
        shadow = true,
        outline = true,
    })
    
    surface.CreateFont("GhoulishFrightAOEBlur", {
        font = "Ghoulish Fright AOE", -- The font name as recognized by the system
        extended = false,
        size = 35, -- Adjust the size as needed
        shadow = true,
        outline = true,
        blursize = 3, -- Adding blursize for the blurred version
    })

end

function ZS_Blocking(target, dmginfo)
    if target:IsPlayer() and target:Alive() and target ~= dmginfo:GetAttacker() then
        local wep = target:GetActiveWeapon()
        local block = wep and wep.IsBlocking and wep:IsBlocking()
        local blockPercent = wep and wep.DefendingDamageBlocked
        local blockPercentDefault = wep and wep.DefendingDamageBlockedDefault
        local parryWindow = 0.2  -- Parry time window in seconds
        local effectPos = target:GetShootPos() + target:GetAimVector() * 20

        if block and (dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_GENERIC) or dmginfo:IsDamageType(DMG_CLUB)) then
            target:EmitSound(wep.BlockSound, 100, wep.BlockSoundPitch)

            -- Check if it's within the perfect parry window
            local isPerfectParry = (CurTime() - wep.ParryStartTime) <= parryWindow

            if isPerfectParry then
                -- Perfect parry effect and damage reduction
                if IsFirstTimePredicted() then
                target:EmitSound("zombiesurvival/ui/survival_medal.wav", 50, math.random(100,wep.BlockSoundPitch+20), 0.75, CHAN_WEAPON+7)  -- Play a special sound for perfect parry
                dmginfo:ScaleDamage(0)  -- Completely negate the damage for a perfect parry
                end

                local parryEffect = EffectData()
                parryEffect:SetOrigin(effectPos)
                parryEffect:SetEntity(target)
                parryEffect:SetAttachment(1)
                util.Effect("melee_parry_text", parryEffect)
            elseif blockPercent < blockPercentDefault then

                local deflectionEffect = EffectData()
                deflectionEffect:SetOrigin(effectPos)
                deflectionEffect:SetEntity(target)
                deflectionEffect:SetAttachment(1)
                util.Effect("stundeflection", deflectionEffect)

                local blockTextEffect = EffectData()
                blockTextEffect:SetOrigin(effectPos)
                blockTextEffect:SetEntity(target)
                blockTextEffect:SetAttachment(1)
                util.Effect("melee_block_text", blockTextEffect)

                dmginfo:ScaleDamage(0.95 / blockPercent)
            else
                
                local pierceEffect = EffectData()
                pierceEffect:SetOrigin(effectPos)
                pierceEffect:SetEntity(target)
                pierceEffect:SetAttachment(1)
                util.Effect("spearpierce", pierceEffect)

                dmginfo:ScaleDamage(1 / blockPercent)
            end
        end
    end
end

hook.Add("EntityTakeDamage", "ZSBlocking-System", ZS_Blocking)

function IsDefending(pl)
    local wep = pl:GetActiveWeapon()
    return wep and wep.IsBlocking and wep:IsBlocking()
end

function GetBlockDefense()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    return wep and wep.DefendingDamageBlocked
end

function GetBlockDefenseDefault()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    return wep and wep.DefendingDamageBlockedDefault
end

if CLIENT then
    local corner8 = surface.GetTextureID("gui/corner8")
    local corner16 = surface.GetTextureID("gui/corner16")

    function draw.RoundedBoxHollow(borderWidth, x, y, width, height, color)
        local halfBorder = borderWidth - 1
        x = math.Round(x)
        y = math.Round(y)
        width = math.Round(width)
        height = math.Round(height)

        surface.SetDrawColor(color.r, color.g, color.b, color.a)
        -- Top border
        surface.DrawRect(x + halfBorder, y, width - halfBorder * 2, halfBorder)
        -- Bottom border
        surface.DrawRect(x + halfBorder, y + height - halfBorder, width - halfBorder * 2, halfBorder)
        -- Left border
        surface.DrawRect(x, y + halfBorder, halfBorder, height - halfBorder * 2)
        -- Right border
        surface.DrawRect(x + width - halfBorder, y + halfBorder, halfBorder, height - halfBorder * 2)

        local texture = corner8
        if borderWidth > 8 then texture = corner16 end

        surface.SetTexture(texture)
        -- Draw corner textures
        surface.DrawTexturedRectUV(x, y, borderWidth, borderWidth, 0, 0, 1, 1) -- Top-left
        surface.DrawTexturedRectUV(x + width - borderWidth, y, borderWidth, borderWidth, 1, 0, 0, 1) -- Top-right
        surface.DrawTexturedRectUV(x, y + height - borderWidth, borderWidth, borderWidth, 0, 1, 1, 0) -- Bottom-left
        surface.DrawTexturedRectUV(x + width - borderWidth, y + height - borderWidth, borderWidth, borderWidth, 1, 1, 0, 0) -- Bottom-right
    end

    local quadVerts = {{}, {}, {}, {}}

    function surface.DrawQuad(x1, y1, x2, y2, x3, y3, x4, y4)
        quadVerts[1].x, quadVerts[1].y = x1, y1
        quadVerts[2].x, quadVerts[2].y = x2, y2
        quadVerts[3].x, quadVerts[3].y = x3, y3
        quadVerts[4].x, quadVerts[4].y = x4, y4
        surface.DrawPoly(quadVerts)
    end

    local degToRad = math.pi / 180
    local drawQuad = surface.DrawQuad

    function surface.DrawArc(centerX, centerY, innerRadius, outerRadius, startAngle, endAngle, segments)
        startAngle, endAngle = startAngle * degToRad, endAngle * degToRad
        local angleStep = (endAngle - startAngle) / segments
        local prevX, prevY = math.cos(startAngle), math.sin(startAngle)

        for i = 0, segments - 1 do
            local angle = i * angleStep + startAngle
            local currX, currY = prevX, prevY
            prevX, prevY = math.cos(angle + angleStep), math.sin(angle + angleStep)

            drawQuad(
                centerX + currX * innerRadius, centerY + currY * innerRadius,
                centerX + currX * outerRadius, centerY + currY * outerRadius,
                centerX + prevX * outerRadius, centerY + prevY * outerRadius,
                centerX + prevX * innerRadius, centerY + prevY * innerRadius
            )
        end
    end

    local alphaBackTexture = surface.GetTextureID("vgui/alpha-back")

    function draw.HollowCircle(centerX, centerY, radius, thickness, startAngle, endAngle, color)
        surface.SetTexture(alphaBackTexture)
        surface.SetDrawColor(color)
        surface.DrawArc(centerX, centerY, radius, radius + thickness, startAngle, endAngle, 36)
    end
end

function CosineInterpolation(y1, y2, mu)
    local mu2 = (1 - math.cos(mu * math.pi)) / 2
    return y1 * (1 - mu2) + y2 * mu2
end

-- 正确的代码
function DrawThickOutline(x, y, width, height, thickness, color)
    -- 从颜色对象中解包 R, G, B, A 值
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    for i = 0, thickness - 1 do
        surface.DrawOutlinedRect(x - i, y - i, width + 2 * i, height + 2 * i)
    end
end