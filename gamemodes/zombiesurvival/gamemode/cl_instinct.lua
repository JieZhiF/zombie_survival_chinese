-- ============================================================================
-- 本文件将独立 addon "instinct"（声呐扫描/透视标记）的功能移植进 ZS gamemode。
-- 僵尸按下 F（impulse 100）时触发一次 InstinctScan 扫描：从玩家位置扩散的球形
-- 扫描波会标记范围内的目标，穿墙高亮（stencil 填充剪影）+ HUD 名牌标记。
-- 扫描目标：仅标"人类玩家"与"玩家放置物/建筑"（路障、炮塔、拆解器、补给/军械箱、障碍物等）。
--
-- 全局接口：
--   ZSInstinctScan()  触发一次扫描（受 cooldown 限制），仅本僵尸客户端本地效果。
--
-- ConVar：
--   zs_instinct_ui_players         是否显示玩家 HUD 标记
--   zs_instinct_ui_entities        是否显示实体 HUD 标记
--   zs_instinct_play_sound          是否播放扫描音效
--   zs_instinct_screen_shake        是否屏幕震动
--   zs_instinct_scan_maxradius      扫描最大半径
--   zs_instinct_scan_traveltime     扫描波扩张耗时
--   zs_instinct_scan_cooldown       扫描冷却
-- ============================================================================

if not CLIENT then return end

-- ============================================================================
-- UI 结构索引
-- [区域] 扫描波/穿墙高亮 (PostDrawTranslucentRenderables)
-- [位置] hook.Add("PostDrawTranslucentRenderables", "ZSInstinct") / MaskEntity / BorderSphereUnit
-- [作用] 渲染扩散中的扫描球波，并对已标记的实体用 stencil 填充剪影（穿墙透视）
-- [常改] SPHERE_CONFIG 颜色/粗细、SCAN_CONFIG 时长/半径、标记颜色 EntityColor
--
-- [区域] 玩家名牌 HUD (HUDPaint)
-- [位置] DrawPlayerMarker / GetPlayerStats
-- [作用] 在扫描标记的玩家头顶显示 头像/名字/距离/血量/护甲 名牌
-- [常改] HUD_CONFIG 尺寸颜色字体、动画时长、信息内容
--
-- [区域] 实体标记 HUD (HUDPaint)
-- [位置] DrawEntityMarker / CalculateEntityAnimationProgress
-- [作用] 准星瞄准被标记实体时显示 模型缩略图/名字/距离/血量
-- [常改] AIM_CONFIG 瞄准阈值/动画、BACKGROUND_COLORS 配色、模型面板朝向
-- ============================================================================

local CreateClientConVar = CreateClientConVar
local CurTime = CurTime
local Color = Color
local ColorAlpha = ColorAlpha
local Cam = cam
local Render = render
local Surface = surface
local Draw = draw
local Util = util
local TableHasValue = table.HasValue
local StringSub = string.sub
local StringFormat = string.format
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local EntsGetAll = ents.GetAll
local MathFloor = math.floor
local MathMin = math.min
local MathMax = math.max
local MathClamp = math.Clamp
local MathRound = math.Round
local MathPow = math.pow
local MathAbs = math.abs
local Tonumber = tonumber
local Tostring = tostring
local IPairs = ipairs
local Pairs = pairs

local UIMarkersPlayers = CreateClientConVar("zs_instinct_ui_players", "1", true, false)
local UIMarkersEntities = CreateClientConVar("zs_instinct_ui_entities", "1", true, false)

local PlaySound = CreateClientConVar("zs_instinct_play_sound", "1", true, false)
local ScreenShake = CreateClientConVar("zs_instinct_screen_shake", "1", true, false)

local MaxRadius = CreateClientConVar("zs_instinct_scan_maxradius", "10000", true, false)
local TravelTime = CreateClientConVar("zs_instinct_scan_traveltime", "5", true, false)
local Cooldown = CreateClientConVar("zs_instinct_scan_cooldown", "7", true, false)

local SPHERE_CONFIG = {
    COLOR = Color(255, 0, 0),
    DETAIL = 32,
    THICKNESS = 16,
}

local SCAN_CONFIG = {
    CURRENT_RADIUS = 0,
    START_SPEED = 300,
    FADE_START = 0.8,
    LAST_TIME = 0,
    START_TIME = 0,
    START_DURATION = 0.5,
    LAST_USE = 0,
    MARK_DURATION = 5,
    MARK_FADE_TIME = 2,
    IS_SCANNING = false,
}

-- 扫描命中的被标记实体表: [ent] = { time = <毫秒>, color = <Color>, modelPanel = <DModelPanel|nil> }
local markedEntities = {}

local function calculateAlpha()
    local currentTime = CurTime()
    local progressRatio = SCAN_CONFIG.CURRENT_RADIUS / MaxRadius:GetInt()
    local cooldownRatio = (currentTime - SCAN_CONFIG.LAST_USE) / Cooldown:GetInt()

    local fadeAlpha = 255
    if progressRatio >= SCAN_CONFIG.FADE_START then
        local fadeProgress = (progressRatio - SCAN_CONFIG.FADE_START) / (1 - SCAN_CONFIG.FADE_START)
        fadeAlpha = MathMax(0, MathFloor((1 - fadeProgress) * 255))
    end

    local cooldownAlpha = 255
    if cooldownRatio >= 0.8 then
        local cooldownFadeProgress = (cooldownRatio - 0.8) / 0.2
        cooldownAlpha = MathMax(0, MathFloor((1 - cooldownFadeProgress) * 255))
    end

    return MathMin(fadeAlpha, cooldownAlpha)
end

local function calculateSpeed(deltaTime)
    local currentTime = CurTime()
    local elapsedTime = currentTime - SCAN_CONFIG.START_TIME

    elapsedTime = MathMin(elapsedTime, TravelTime:GetFloat())

    local startProgress = MathMin(elapsedTime / SCAN_CONFIG.START_DURATION, 1)
    local startMultiplier = startProgress * startProgress

    if SCAN_CONFIG.CURRENT_RADIUS >= MaxRadius:GetInt() then
        return 0
    end

    local v0 = SCAN_CONFIG.START_SPEED
    local timeTotal = TravelTime:GetFloat()
    local acceleration = 2 * (MaxRadius:GetInt() - v0 * timeTotal) / (timeTotal * timeTotal)
    local speed = v0 + acceleration * elapsedTime

    return MathMax(0, speed * startMultiplier)
end

local function canUseInstinct()
    local canUse = CurTime() - SCAN_CONFIG.LAST_USE >= Cooldown:GetInt()
    if canUse then
        SCAN_CONFIG.IS_SCANNING = false
        SCAN_CONFIG.CURRENT_RADIUS = 0
    end
    return canUse
end

local friendlyNPCClasses = {
    "npc_citizen", "npc_breen", "npc_alyx", "npc_kleiner",
    "npc_magnusson", "npc_monk", "npc_mossman", "npc_odessa",
    "npc_vortigaunt", "npc_barney", "npc_dog", "npc_crow",
    "npc_seagull", "npc_pigeon", "npc_eli", "npc_fisherman", "npc_gman",
}

local function isHostileNPC(npc)
    if not IsValid(npc) then return false end
    return not TableHasValue(friendlyNPCClasses, npc:GetClass())
end

-- 依据实体类型返回标记颜色（玩家蓝 / 敌对NPC红 / 友军绿 / 僵尸橙 / 物品青 / 脚本紫 / 车辆深蓝）
local function EntityColor(ent)
    local baseColor

    if ent:IsPlayer() then
        baseColor = Color(0, 120, 255)
    elseif ent:IsNPC() then
        baseColor = isHostileNPC(ent) and Color(255, 0, 0) or Color(0, 255, 0)
    elseif ent:IsNextBot() then
        baseColor = Color(255, 150, 0)
    elseif ent:GetClass() == "class C_BaseEntity" then
        return Color(255, 251, 0)
    elseif ent:GetClass():find("item") or ent:GetClass():find("ammo") or
        ent:GetClass() == "rpg_missile" or ent:GetClass() == "prop_combine_ball" or
        ent:GetClass() == "npc_grenade_frag" then
        return Color(0, 250, 255)
    elseif ent:IsScripted() then
        return Color(160, 0, 255)
    elseif ent:IsVehicle() then
        return Color(50, 0, 255)
    else
        return Color(255, 255, 255)
    end

    if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
        local health = ent:Health()
        local maxHealth = ent:GetMaxHealth()

        if health and maxHealth and maxHealth > 0 then
            local healthPercentage = MathClamp(health / maxHealth, 0, 1)
            local darkenFactor = 0.15 + (healthPercentage * 0.75)

            return Color(
                MathRound(baseColor.r * darkenFactor),
                MathRound(baseColor.g * darkenFactor),
                MathRound(baseColor.b * darkenFactor),
                baseColor.a
            )
        end
    end

    return baseColor
end

-- 用 stencil 对标记实体做穿墙剪影填充（遮蔽在墙后的目标高亮）
local function MaskEntity(ent)
    local markData = markedEntities[ent]
    if not markData then return end

    local currentTime = CurTime()
    local color = markData.color

    local alpha = 255
    local timeSinceMark = currentTime - markData.time

    if timeSinceMark > SCAN_CONFIG.MARK_DURATION then
        local fadeProgress = (timeSinceMark - SCAN_CONFIG.MARK_DURATION) / SCAN_CONFIG.MARK_FADE_TIME
        alpha = MathMax(0, 255 * (1 - fadeProgress))

        if alpha == 0 then
            markedEntities[ent] = nil
            return
        end
    end

    Render.SetBlend(1)
    Render.SetColorModulation(1, 1, 1)

    Render.SetStencilEnable(true)
    Render.SetStencilReferenceValue(0)
    Render.SetStencilPassOperation(STENCIL_KEEP)
    Render.SetStencilZFailOperation(STENCIL_KEEP)
    Render.ClearStencil()

    Render.SetStencilCompareFunction(STENCIL_NEVER)
    Render.SetStencilFailOperation(STENCIL_REPLACE)
    Render.SetStencilReferenceValue(0x1C)
    Render.SetStencilWriteMask(0x55)

    ent:DrawModel()

    Render.SetStencilTestMask(0xF3)
    Render.SetStencilReferenceValue(0x10)
    Render.SetStencilCompareFunction(STENCIL_EQUAL)

    local markColor = Color(color.r, color.g, color.b, alpha)
    Render.ClearBuffersObeyStencil(markColor.r, markColor.g, markColor.b, markColor.a, false)

    Render.SetStencilEnable(false)
end

local function isInSphere(ent, spherePos, radius)
    if not IsValid(ent) then return false end
    return ent:GetPos():DistToSqr(spherePos) <= radius * radius
end

-- SPHERE_NUMBER_RULES: 根据半径个位决定 DrawSphere 细分步进的增量（0.5 或 1）
local SPHERE_NUMBER_RULES = { [0] = 2, [1] = 1, [3] = 2, [5] = 1, [7] = 2, [9] = 1 }

-- 绘制扩散中的扫描球波（stencil 画空壳球体，忽略深度以表现透墙波纹）
function ZSBorderSphereUnit(color, pos, radius, detail, thickness)
    radius = MathFloor(radius)
    thickness = MathFloor(thickness or 24)
    detail = MathMin(MathFloor(detail or 32), 100)

    if thickness >= radius then
        thickness = radius
    end

    local lastDigit = Tonumber(StringSub(Tostring(radius), -1))
    local rule = SPHERE_NUMBER_RULES[lastDigit]
    local subdivisionStep = 1
    if rule == 1 then
        subdivisionStep = 1
    elseif rule == 2 then
        subdivisionStep = 0.50
    end

    local ply = LocalPlayer()
    local viewEntity = ply:GetViewEntity()
    local cam_pos
    local cam_angle

    if viewEntity == ply then
        cam_pos = ply:EyePos()
        cam_angle = ply:GetAimVector():Angle()
    else
        cam_pos = viewEntity:GetPos()
        cam_angle = viewEntity:GetAngles()
    end

    local cam_normal = cam_angle:Forward()

    Render.SetStencilEnable(true)
    Render.SetStencilReferenceValue(0x55)
    Render.SetStencilTestMask(0x1C)
    Render.SetStencilWriteMask(0x1C)
    Render.ClearStencil()

    Render.SetColorMaterial()

    local detailWithStep = detail + subdivisionStep
    local radiusMinusThickness = radius - thickness

    Render.SetStencilReferenceValue(1)
    Render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    Render.SetStencilZFailOperation(STENCILOPERATION_INVERT)

    local invisibleColor = Color(0, 0, 0, 0)
    Render.DrawSphere(pos, -radius, detail, detail, invisibleColor)
    Render.DrawSphere(pos, radius, detail, detail, invisibleColor)
    Render.DrawSphere(pos, -radiusMinusThickness, detailWithStep, detailWithStep, invisibleColor)
    Render.DrawSphere(pos, radiusMinusThickness, detailWithStep, detailWithStep, invisibleColor)

    Render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
    Render.DrawSphere(pos, radius + 0.25, detailWithStep, detailWithStep, invisibleColor)

    Render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
    Cam.IgnoreZ(true)
    Render.SetStencilReferenceValue(1)
    Render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal, 10000, 10000, color, cam_angle.roll)

    Cam.IgnoreZ(false)
    Render.SetStencilEnable(false)
end

-- 玩家放置物/建筑：路障、钉子固定物、炮塔、拆解器、补给箱、军械箱、障碍物等
local PLACED_OBJECT_CLASSES = {
    [1] = "prop_gunturret", [2] = "prop_gunturret_assault",
    [3] = "prop_gunturret_buckshot", [4] = "prop_gunturret_pulse",
    [5] = "prop_gunturret_rocket", [6] = "prop_remantler",
    [7] = "prop_resupplybox", [8] = "prop_arsenalcrate",
    [9] = "prop_blocker", [10] = "env_protrusionspike",
}

-- 判断实体是否为玩家放置物/建筑（人类阻挡僵尸的路障、炮塔、补给箱等）
function ZSInstinctIsPlacedObject(ent)
    if not IsValid(ent) then return false end

    -- 路障 / 钉子固定物
    if ent.IsBarricadeProp and ent:IsBarricadeProp() then
        return true
    end

    -- 僵尸/人类建筑与可部署物
    if ent.ZombieConstruction or ent.Deployable then
        return true
    end

    local class = ent:GetClass()
    for _, placedClass in IPairs(PLACED_OBJECT_CLASSES) do
        if class == placedClass then
            return true
        end
    end

    return false
end

-- ---------------------------------------------------------------------------
-- 主扫描触发：僵尸按下 F 时调用（由 GAMEMODE:PlayerBindPress 接入）
-- ---------------------------------------------------------------------------
function ZSInstinctScan()
    if not LocalPlayer():Alive() then return end

    if canUseInstinct() then
        if PlaySound:GetBool() then
            Surface.PlaySound("instinct/ping3.mp3")
        end

        if ScreenShake:GetBool() then
            Util.ScreenShake(Vector(0, 0, 0), 2, 3, 2, 1000)
        end

        SCAN_CONFIG.CURRENT_RADIUS = 0
        SCAN_CONFIG.LAST_TIME = CurTime()
        SCAN_CONFIG.START_TIME = CurTime()
        SCAN_CONFIG.LAST_USE = CurTime()
        SCAN_CONFIG.IS_SCANNING = true
    end
end

-- 供控制台直接触发测试（等价于按 F）
concommand.Add("zs_instinct_scan", function()
    if LocalPlayer() and LocalPlayer():Team() == TEAM_UNDEAD then
        ZSInstinctScan()
    end
end)

hook.Add("PostDrawTranslucentRenderables", "ZSInstinct", function()
    local currentTime = CurTime()

    for ent, markData in Pairs(markedEntities) do
        if IsValid(ent) then
            markData.color = EntityColor(ent)
            MaskEntity(ent)
        else
            markedEntities[ent] = nil
        end
    end

    if currentTime - SCAN_CONFIG.LAST_USE >= Cooldown:GetInt() then
        SCAN_CONFIG.IS_SCANNING = false
        SCAN_CONFIG.CURRENT_RADIUS = 0
        return
    end

    if not SCAN_CONFIG.IS_SCANNING then return end

    local deltaTime = currentTime - SCAN_CONFIG.LAST_TIME
    SCAN_CONFIG.LAST_TIME = currentTime

    local speed = calculateSpeed(deltaTime)
    local newRadius = SCAN_CONFIG.CURRENT_RADIUS + speed * deltaTime
    SCAN_CONFIG.CURRENT_RADIUS = MathMin(newRadius, MaxRadius:GetInt())

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local spherePos = ply:WorldSpaceCenter()

    for _, ent in Pairs(EntsGetAll()) do
        local isHuman = IsValid(ent) and ent:IsPlayer() and ent:Team() == TEAM_HUMAN
        local isPlaced = IsValid(ent) and ZSInstinctIsPlacedObject(ent)

        if (isHuman or isPlaced) and ent ~= ply
            and isInSphere(ent, spherePos, SCAN_CONFIG.CURRENT_RADIUS) and not markedEntities[ent] then
            markedEntities[ent] = {
                time = currentTime,
                color = EntityColor(ent)
            }
        end
    end

    if SCAN_CONFIG.CURRENT_RADIUS < MaxRadius:GetInt() then
        local alpha = calculateAlpha()
        local sphereColor = Color(
            SPHERE_CONFIG.COLOR.r,
            SPHERE_CONFIG.COLOR.g,
            SPHERE_CONFIG.COLOR.b,
            alpha
        )

        ZSBorderSphereUnit(
            sphereColor,
            spherePos,
            SCAN_CONFIG.CURRENT_RADIUS,
            SPHERE_CONFIG.DETAIL,
            SPHERE_CONFIG.THICKNESS
        )
    else
        SCAN_CONFIG.IS_SCANNING = false
        SCAN_CONFIG.CURRENT_RADIUS = 0
    end
end)

-- ---------------------------------------------------------------------------
-- HUD 玩家名牌
-- ---------------------------------------------------------------------------
local HUD_CONFIG = {
    HEIGHT = 60,
    WIDTH = 200,
    PADDING = 20,
    CORNER_RADIUS = 8,
    BACKGROUND_COLOR = Color(0, 51, 102, 230),
    TEXT_COLOR = Color(255, 255, 255, 255),
    AVATAR_SIZE = 40,
    MIN_VERTICAL_OFFSET = 10,

    WIDTH_EXPANSION_TIME = 0.5,
    LENGTH_EXPANSION_TIME = 0.5,
    EXPANSION_DELAY = 0,
    CONTENT_FADE_TIME = 0.2,

    NAME_FONT = "Trebuchet24",
    STAT_FONT = "Trebuchet18",
    HAMMER_TO_METERS = 0.01904,
}

local avatarMaterials = {}

local function GetPlayerAvatar(ply)
    if not IsValid(ply) then return end

    if not avatarMaterials[ply] then
        local avatar = vgui.Create("AvatarImage")
        avatar:SetSize(HUD_CONFIG.AVATAR_SIZE, HUD_CONFIG.AVATAR_SIZE)
        avatar:SetPlayer(ply, HUD_CONFIG.AVATAR_SIZE)
        avatar:ParentToHUD()
        avatar:SetPaintedManually(true)
        avatarMaterials[ply] = avatar
    end

    return avatarMaterials[ply]
end

hook.Add("PlayerDisconnected", "ZSInstinctCleanupAvatars", function(ply)
    if avatarMaterials[ply] then
        avatarMaterials[ply]:Remove()
        avatarMaterials[ply] = nil
    end
end)

local function DrawRoundedBoxWithBorder(radius, x, y, w, h, color, borderColor, borderSize)
    Draw.RoundedBox(radius, x - borderSize, y - borderSize, w + borderSize * 2, h + borderSize * 2, borderColor)
    Draw.RoundedBox(radius, x, y, w, h, color)
end

local function GetPlayerScreenBounds(ent)
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local pos = ent:GetPos()

    local bottomPos = (pos + mins):ToScreen()
    local topPos = (pos + Vector(0, 0, maxs.z)):ToScreen()

    return bottomPos, topPos
end

local function easeOutCubic(x)
    return 1 - MathPow(1 - x, 3)
end

local function easeOutExpo(x)
    return x == 1 and 1 or 1 - MathPow(2, -10 * x)
end

-- 计算名牌/标记的展开动画进度（宽度展开 -> 高度展开 -> 内容淡入 -> 整体淡出）
local function CalculateAnimationProgress(markData)
    local currentTime = CurTime()
    local timeSinceMark = currentTime - markData.time
    local phase = true

    if timeSinceMark <= HUD_CONFIG.WIDTH_EXPANSION_TIME then
        local progress = timeSinceMark / HUD_CONFIG.WIDTH_EXPANSION_TIME
        return { width = easeOutExpo(progress), height = 0, alpha = 255, contentAlpha = 0 }
    end

    if timeSinceMark <= HUD_CONFIG.WIDTH_EXPANSION_TIME + HUD_CONFIG.EXPANSION_DELAY then
        return { width = 1, height = 0, alpha = 255, contentAlpha = 0 }
    end

    local heightStart = HUD_CONFIG.WIDTH_EXPANSION_TIME + HUD_CONFIG.EXPANSION_DELAY
    local heightTime = timeSinceMark - heightStart
    if heightTime <= HUD_CONFIG.LENGTH_EXPANSION_TIME then
        local progress = heightTime / HUD_CONFIG.LENGTH_EXPANSION_TIME
        return { width = 1, height = easeOutCubic(progress), alpha = 255, contentAlpha = 0 }
    end

    local contentStart = heightStart + HUD_CONFIG.LENGTH_EXPANSION_TIME
    local contentTime = timeSinceMark - contentStart
    if contentTime <= HUD_CONFIG.CONTENT_FADE_TIME then
        local fadeProgress = contentTime / HUD_CONFIG.CONTENT_FADE_TIME
        return { width = 1, height = 1, alpha = 255, contentAlpha = MathMin(255, fadeProgress * 255) }
    end

    if timeSinceMark > SCAN_CONFIG.MARK_DURATION then
        local fadeProgress = (timeSinceMark - SCAN_CONFIG.MARK_DURATION) / SCAN_CONFIG.MARK_FADE_TIME
        local fadeAlpha = MathMax(0, 255 * (1 - easeOutCubic(fadeProgress)))
        return { width = 1, height = 1, alpha = fadeAlpha, contentAlpha = fadeAlpha }
    end

    phase = false
    return { width = 1, height = 1, alpha = 255, contentAlpha = 255 }
end

local function GetPlayerStats(ply)
    if not IsValid(ply) then return end

    local health = MathClamp(ply:Health(), 0, ply:GetMaxHealth())
    local armor = MathClamp(ply:Armor(), 0, 100)
    local healthPercentage = MathRound((health / ply:GetMaxHealth()) * 100)
    local distance = LocalPlayer():GetPos():Distance(ply:GetPos()) * HUD_CONFIG.HAMMER_TO_METERS

    return {
        health = healthPercentage,
        armor = armor,
        distance = MathRound(distance, 1)
    }
end

local function DrawPlayerMarker(ply, markData)
    if not IsValid(ply) then return end

    local animation = CalculateAnimationProgress(markData)
    if animation.alpha <= 0 then return end

    local bottomPos, topPos = GetPlayerScreenBounds(ply)
    if not (bottomPos.visible or topPos.visible) then return end

    local stats = GetPlayerStats(ply)
    if not stats then return end

    local currentWidth = HUD_CONFIG.WIDTH * animation.width
    local currentHeight = HUD_CONFIG.HEIGHT * animation.height

    local boxX = topPos.x - (currentWidth / 2)
    local boxY = topPos.y - currentHeight - HUD_CONFIG.MIN_VERTICAL_OFFSET

    if animation.height <= 0 then
        Surface.SetDrawColor(ColorAlpha(markData.color, animation.alpha))
        Surface.DrawRect(boxX, topPos.y - HUD_CONFIG.MIN_VERTICAL_OFFSET, currentWidth, 2)
        return
    end

    local bgColor = ColorAlpha(HUD_CONFIG.BACKGROUND_COLOR, animation.alpha)
    DrawRoundedBoxWithBorder(
        HUD_CONFIG.CORNER_RADIUS,
        boxX,
        boxY,
        currentWidth,
        currentHeight,
        bgColor,
        ColorAlpha(markData.color, animation.alpha),
        2
    )

    if animation.width ~= 1 or animation.height ~= 1 then return end

    local avatar = GetPlayerAvatar(ply)
    if avatar then
        local avatarX = boxX + HUD_CONFIG.PADDING
        local avatarY = boxY + (HUD_CONFIG.HEIGHT - HUD_CONFIG.AVATAR_SIZE) / 2

        avatar:SetAlpha(animation.contentAlpha)
        avatar:SetPos(avatarX, avatarY)
        avatar:PaintManual()

        Surface.SetDrawColor(ColorAlpha(markData.color, animation.contentAlpha))
        Surface.DrawOutlinedRect(
            avatarX - 1,
            avatarY - 1,
            HUD_CONFIG.AVATAR_SIZE + 2,
            HUD_CONFIG.AVATAR_SIZE + 2,
            2
        )
    end

    local contentX = boxX + HUD_CONFIG.PADDING + HUD_CONFIG.AVATAR_SIZE + 10
    local nameY = boxY + 4
    local statsY = nameY + 30

    Draw.SimpleText(ply:Nick(), HUD_CONFIG.NAME_FONT, contentX, nameY,
        ColorAlpha(HUD_CONFIG.TEXT_COLOR, animation.contentAlpha))

    Draw.SimpleText(StringFormat("%.1fm", stats.distance), HUD_CONFIG.STAT_FONT, contentX, nameY + 17,
        ColorAlpha(HUD_CONFIG.TEXT_COLOR, animation.contentAlpha))

    local healthText = StringFormat("HP: %d%%", stats.health)
    Draw.SimpleText(healthText, HUD_CONFIG.STAT_FONT, contentX, statsY,
        Color(80, 255, 80, animation.contentAlpha))

    Surface.SetFont(HUD_CONFIG.STAT_FONT)
    local healthWidth = Surface.GetTextSize(healthText)

    if stats.armor > 0 then
        Draw.SimpleText(StringFormat("AP: %d%%", stats.armor),
            HUD_CONFIG.STAT_FONT,
            contentX + healthWidth + 10,
            statsY,
            Color(80, 180, 255, animation.contentAlpha)
        )
    end
end

-- ---------------------------------------------------------------------------
-- HUD 实体标记（准星瞄准时显示模型缩略图与信息）
-- ---------------------------------------------------------------------------
local AIM_CONFIG = {
    DOT_THRESHOLD = 0.98,
    ANIMATION_SPEED = 2,
    REVERSE_ANIMATION_TIME = 0.25
}

local aimedEntities = {}

local function isLookingAtEntity(ent)
    if not IsValid(ent) then return false end

    local ply = LocalPlayer()
    if not IsValid(ply) then return false end

    local directionToEnt = (ent:GetPos() + ent:OBBCenter() - ply:EyePos()):GetNormalized()
    return ply:GetAimVector():Dot(directionToEnt) > AIM_CONFIG.DOT_THRESHOLD
end

local function CalculateEntityAnimationProgress(markData)
    local currentTime = CurTime()
    local timeSinceMark = (currentTime - markData.time) * AIM_CONFIG.ANIMATION_SPEED

    if markData.reversing then
        local reverseProgress = (currentTime - markData.reverseStartTime) / AIM_CONFIG.REVERSE_ANIMATION_TIME
        if reverseProgress >= 1 then
            return { width = 0, height = 0, alpha = 0, contentAlpha = 0 }
        end
        reverseProgress = easeOutCubic(reverseProgress)
        return {
            width = 1 - reverseProgress,
            height = 1 - reverseProgress,
            alpha = 255 * (1 - reverseProgress),
            contentAlpha = 255 * (1 - reverseProgress)
        }
    end

    if timeSinceMark <= HUD_CONFIG.WIDTH_EXPANSION_TIME then
        local progress = timeSinceMark / HUD_CONFIG.WIDTH_EXPANSION_TIME
        return { width = easeOutExpo(progress), height = 0, alpha = 255, contentAlpha = 0 }
    end

    if timeSinceMark <= HUD_CONFIG.WIDTH_EXPANSION_TIME + HUD_CONFIG.EXPANSION_DELAY then
        return { width = 1, height = 0, alpha = 255, contentAlpha = 0 }
    end

    local heightStart = HUD_CONFIG.WIDTH_EXPANSION_TIME + HUD_CONFIG.EXPANSION_DELAY
    local heightTime = timeSinceMark - heightStart
    if heightTime <= HUD_CONFIG.LENGTH_EXPANSION_TIME then
        local progress = heightTime / HUD_CONFIG.LENGTH_EXPANSION_TIME
        return { width = 1, height = easeOutCubic(progress), alpha = 255, contentAlpha = 0 }
    end

    local contentStart = heightStart + HUD_CONFIG.LENGTH_EXPANSION_TIME
    local contentTime = timeSinceMark - contentStart
    if contentTime <= HUD_CONFIG.CONTENT_FADE_TIME then
        local fadeProgress = contentTime / HUD_CONFIG.CONTENT_FADE_TIME
        return { width = 1, height = 1, alpha = 255, contentAlpha = MathMin(255, fadeProgress * 255) }
    end

    return { width = 1, height = 1, alpha = 255, contentAlpha = 255 }
end

local BACKGROUND_COLORS = {
    PLAYER = Color(0, 51, 102, 230),
    HOSTILE = Color(102, 0, 0, 230),
    FRIENDLY = Color(0, 102, 0, 230),
    ITEM = Color(0, 102, 102, 230),
    ENTITY = Color(102, 0, 102, 230),
    VEHICLE = Color(0, 0, 102, 230),
}

local function GetEntityDisplayName(ent)
    if not IsValid(ent) then return "Unknown" end

    if ent.PrintName and ent.PrintName ~= "" then
        return ent.PrintName
    elseif ent.GetPrintName and ent:GetPrintName() ~= "" then
        return ent:GetPrintName()
    else
        return ent:GetClass()
    end
end

local function GetEntityBackgroundColor(ent)
    if ent:IsPlayer() then
        return BACKGROUND_COLORS.PLAYER
    elseif ent:IsNPC() then
        return isHostileNPC(ent) and BACKGROUND_COLORS.HOSTILE or BACKGROUND_COLORS.FRIENDLY
    elseif ent:IsNextBot() then
        return BACKGROUND_COLORS.HOSTILE
    elseif ent:IsVehicle() then
        return BACKGROUND_COLORS.VEHICLE
    elseif ent:GetClass():find("item") or ent:GetClass():find("ammo") or
        ent:GetClass() == "rpg_missile" or ent:GetClass() == "prop_combine_ball" or
        ent:GetClass() == "npc_grenade_frag" then
        return BACKGROUND_COLORS.ITEM
    else
        return BACKGROUND_COLORS.ENTITY
    end
end

local function WrapText(text, font, maxWidth)
    Surface.SetFont(font)

    if Surface.GetTextSize(text) <= maxWidth then
        return text
    end

    local ellipsis = "..."
    local currentText = text

    while Surface.GetTextSize(currentText .. ellipsis) > maxWidth and #currentText > 0 do
        currentText = StringSub(currentText, 1, #currentText - 1)
    end

    return currentText .. ellipsis
end

-- 为实体创建/复用旋转的 DModelPanel 模型缩略图，并设置朝向与视角
local function SetupModelPanel(ent, markData)
    if markData.modelPanel or markData.noValidModel then return end

    local model = ent:GetModel()
    if not model or model == "" or model == "models/error.mdl" then
        markData.noValidModel = true
        return
    end

    local panel = vgui.Create("DModelPanel")
    panel:SetSize(HUD_CONFIG.AVATAR_SIZE, HUD_CONFIG.AVATAR_SIZE)
    panel:SetModel(model)

    local originalPaint = panel.Paint
    panel.Paint = function(self, w, h)
        Surface.SetDrawColor(255, 255, 255, 255)
        Surface.DrawRect(0, 0, w, h)
        originalPaint(self, w, h)
    end

    local mins, maxs = ent:GetModelBounds()
    local center
    local size = 100

    if mins and maxs then
        size = MathMax(
            MathAbs(maxs.x - mins.x),
            MathAbs(maxs.y - mins.y),
            MathAbs(maxs.z - mins.z)
        )
        center = (mins + maxs) * 0.5
    end

    if ent:IsNPC() or ent:IsNextBot() then
        local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
            or ent:LookupBone("bip01_head")
            or ent:LookupBone("head")
            or ent:LookupBone("ValveBiped.Head1")

        if headBone then
            local headPos = ent:GetBonePosition(headBone)
            if headPos then
                local headOffset = headPos - ent:GetPos()
                panel:SetLookAt(headOffset)
                panel:SetCamPos(headOffset + Vector(size * 0.6, size * 0.6, size * 0.2))
                panel:SetFOV(20)
            end
        elseif center then
            panel:SetLookAt(center)
            panel:SetCamPos(center + Vector(size * 1.2, size * 1.2, size * 0.3))
            panel:SetFOV(40)
        else
            panel:SetLookAt(Vector(0, 0, 30))
            panel:SetCamPos(Vector(75, 75, 50))
            panel:SetFOV(40)
        end
    elseif ent:GetClass():find("item") or ent:GetClass():find("ammo") then
        if center then
            local camDistance = size * 1.7
            panel:SetLookAt(Vector(0, 0, center.z * 1.3))
            panel:SetCamPos(Vector(camDistance, camDistance, camDistance * 0.5))
            panel:SetFOV(35)
            panel.LayoutEntity = function(self, modelEnt)
                if not self.startTime then self.startTime = CurTime() end
                modelEnt:SetAngles(Angle(0, (CurTime() - self.startTime) * 45, 0))
                modelEnt:SetPos(Vector(0, 0, size * 0.25))
                return true
            end
        else
            panel:SetCamPos(Vector(25, 25, 20))
            panel:SetLookAt(Vector(0, 0, 5))
            panel:SetFOV(45)
        end
    elseif center then
        panel:SetCamPos(Vector(size, size, size * 0.5))
        panel:SetLookAt(Vector(0, 0, 0))
        panel:SetFOV(45)
    end

    if ent:IsNPC() or ent:IsNextBot() then
        panel.LayoutEntity = function(self, modelEnt)
            if not self.startTime then self.startTime = CurTime() end
            modelEnt:SetAngles(Angle(0, (CurTime() - self.startTime) * 30, 0))
            return true
        end
    end

    panel:SetPaintedManually(true)
    markData.modelPanel = panel
end

local function DrawEntityMarker(ent, markData)
    if not IsValid(ent) then return end

    -- 按钮 / C_BaseEntity 的 UI 标记看起来杂乱，跳过
    if ent:GetClass() == "class C_BaseEntity" or
        ent:GetClass() == "func_button" or
        ent:GetClass():find("button") then
        return
    end

    local animation = CalculateEntityAnimationProgress(markData)
    if animation.alpha <= 0 then return end

    local bottomPos, topPos = GetPlayerScreenBounds(ent)
    if not (bottomPos.visible or topPos.visible) then return end

    local currentWidth = HUD_CONFIG.WIDTH * animation.width
    local currentHeight = HUD_CONFIG.HEIGHT * animation.height

    local boxX = topPos.x - (currentWidth / 2)
    local boxY = topPos.y - currentHeight - HUD_CONFIG.MIN_VERTICAL_OFFSET

    if animation.height <= 0 then
        Surface.SetDrawColor(ColorAlpha(markData.color, animation.alpha))
        Surface.DrawRect(boxX, topPos.y - HUD_CONFIG.MIN_VERTICAL_OFFSET, currentWidth, 2)
        return
    end

    local bgColor = ColorAlpha(GetEntityBackgroundColor(ent), animation.alpha)
    DrawRoundedBoxWithBorder(
        HUD_CONFIG.CORNER_RADIUS,
        boxX,
        boxY,
        currentWidth,
        currentHeight,
        bgColor,
        ColorAlpha(markData.color, animation.alpha),
        2
    )

    if animation.width ~= 1 or animation.height ~= 1 then return end

    SetupModelPanel(ent, markData)

    local modelX = boxX + HUD_CONFIG.PADDING
    local modelY = boxY + (HUD_CONFIG.HEIGHT - HUD_CONFIG.AVATAR_SIZE) / 2

    if markData.modelPanel then
        markData.modelPanel:SetAlpha(animation.contentAlpha)
        markData.modelPanel:SetPos(modelX, modelY)
        markData.modelPanel:PaintManual()

        Surface.SetDrawColor(ColorAlpha(markData.color, animation.contentAlpha))
        Surface.DrawOutlinedRect(
            modelX - 1,
            modelY - 1,
            HUD_CONFIG.AVATAR_SIZE + 2,
            HUD_CONFIG.AVATAR_SIZE + 2,
            2
        )
    end

    local contentX = boxX + HUD_CONFIG.PADDING
    if markData.modelPanel then
        contentX = contentX + HUD_CONFIG.AVATAR_SIZE + 10
    end

    local nameY = boxY + 2
    local statsY = nameY + 30

    local availableWidth = currentWidth - (contentX - boxX) - HUD_CONFIG.PADDING
    local displayName = WrapText(GetEntityDisplayName(ent), HUD_CONFIG.NAME_FONT, availableWidth)

    Draw.SimpleText(displayName, HUD_CONFIG.NAME_FONT, contentX, nameY,
        ColorAlpha(HUD_CONFIG.TEXT_COLOR, animation.contentAlpha))

    local distance = LocalPlayer():GetPos():Distance(ent:GetPos()) * HUD_CONFIG.HAMMER_TO_METERS
    Draw.SimpleText(StringFormat("%.1fm", distance), HUD_CONFIG.STAT_FONT,
        contentX, nameY + 18,
        ColorAlpha(HUD_CONFIG.TEXT_COLOR, animation.contentAlpha))

    if (ent:IsNPC() or ent:IsNextBot()) and ent.Health and ent:Health() > 0 then
        local health = MathClamp(ent:Health(), 0, ent:GetMaxHealth())
        local healthPercentage = MathRound((health / ent:GetMaxHealth()) * 100)
        Draw.SimpleText(StringFormat("HP: %d%%", healthPercentage), HUD_CONFIG.STAT_FONT,
            contentX, statsY,
            Color(80, 255, 80, animation.contentAlpha)
        )
    end
end

hook.Add("EntityRemoved", "ZSInstinctCleanupPanels", function(ent)
    if markedEntities[ent] and markedEntities[ent].modelPanel then
        markedEntities[ent].modelPanel:Remove()
        markedEntities[ent].modelPanel = nil
    end
end)

local function calculateAimPriority(ent)
    if not IsValid(ent) then return -1 end

    local ply = LocalPlayer()
    if not IsValid(ply) then return -1 end

    local directionToEnt = (ent:GetPos() + ent:OBBCenter() - ply:EyePos()):GetNormalized()
    return ply:GetAimVector():Dot(directionToEnt)
end

-- 绘制所有被标记的玩家与准星指向实体的 HUD 标记
hook.Add("HUDPaint", "ZSInstinctMarkers", function()
    for ent, markData in Pairs(markedEntities) do
        if IsValid(ent) and ent:IsPlayer() and UIMarkersPlayers:GetBool() then
            DrawPlayerMarker(ent, markData)
        end
    end

    if not UIMarkersEntities:GetBool() then return end

    local currentTime = CurTime()

    for ent, aimData in Pairs(aimedEntities) do
        if IsValid(ent) and not ent:IsPlayer() and not ent:IsWeapon() and ent:GetClass() ~= "func_button" then
            local isAimed = isLookingAtEntity(ent)

            if isAimed then
                if not aimData then
                    aimedEntities[ent] = {
                        time = currentTime,
                        color = EntityColor(ent),
                        reversing = false
                    }
                elseif aimData.reversing then
                    aimData.reversing = false
                end
            elseif aimData and not aimData.reversing then
                aimData.reversing = true
                aimData.reverseStartTime = currentTime
            end
        end
    end

    for ent, aimData in Pairs(aimedEntities) do
        if not IsValid(ent) or not markedEntities[ent] or
            (aimData.reversing and CurTime() - aimData.reverseStartTime >= AIM_CONFIG.REVERSE_ANIMATION_TIME) then
            aimedEntities[ent] = nil
        end
    end

    local entitiesToDraw = {}
    for ent, aimData in Pairs(aimedEntities) do
        if IsValid(ent) and markedEntities[ent] then
            entitiesToDraw[#entitiesToDraw + 1] = {
                entity = ent,
                markData = aimData,
                priority = calculateAimPriority(ent)
            }
        end
    end

    table.sort(entitiesToDraw, function(a, b)
        return a.priority < b.priority
    end)

    for _, data in IPairs(entitiesToDraw) do
        DrawEntityMarker(data.entity, data.markData)
    end
end)
