-- 确保此代码只在客户端运行
INC_CLIENT()
--[[-------------------------------------------------------------------------
    配置常量 (Constants)
    - 将这些值移出Draw函数，避免每帧重复定义，提升性能。
---------------------------------------------------------------------------]]
-- 距离和淡出效果设置
local MAX_DRAW_DISTANCE = 3000      -- HUD可见的最大距离
local FADE_START_DISTANCE = 2500    -- 开始淡出的距离 (必须小于最大距离)
local MAX_DRAW_DISTANCE_SQR = MAX_DRAW_DISTANCE * MAX_DRAW_DISTANCE -- 使用距离的平方进行比较，避免开方运算
local FADE_DISTANCE_RANGE = MAX_DRAW_DISTANCE - FADE_START_DISTANCE -- 淡出效果作用的距离范围

-- 3D2D 面板外观设置
local PANEL_WIDTH = 200
local PANEL_HEIGHT = 70
local CORNER_RADIUS = 4

-- 预计算居中所需的一半尺寸
local HALF_PANEL_WIDTH = PANEL_WIDTH / 2
local HALF_PANEL_HEIGHT = PANEL_HEIGHT / 2

-- 颜色定义 (定义一次，重复使用)
local COLOR_BACKGROUND = Color(20, 25, 30, 220)
local COLOR_BORDER = Color(60, 70, 80, 150)
local COLOR_SPLITTER = COLOR_BORDER -- 分割线颜色与边框一致

-- UI 布局
local SPLITTER_X_POS = -HALF_PANEL_WIDTH + 60
local ICON_SIZE = 48
local ICON_PADDING_X = 7

-- 字体
local FONT_NAME = "ZS2DFontHarmonyBig"

-- 材质缓存表，用于存储已创建的材质，避免重复创建
local materialCache = {}


-- 设置实体基础颜色
ENT.ColorModulation = Color(0.25, 1, 0.25)


--[[-------------------------------------------------------------------------
    ENT:Draw()
    - 每帧调用以绘制实体。此函数已为性能进行优化。
---------------------------------------------------------------------------]]
function ENT:Draw()
    -- 基础有效性检查
    if not self:IsValid() then return end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- [[ 1. 距离与可见性计算 ]]
    local eyePos = EyePos()
    local entPos = self:GetPos() + Vector(0, 0, 5)
    local distSqr = eyePos:DistToSqr(entPos)

    -- 如果距离太远，则完全不绘制 (这是最重要的性能优化)
    if distSqr > MAX_DRAW_DISTANCE_SQR then return end

    -- 仅在需要时计算实际距离 (开方运算消耗较大)
    local dist = math.sqrt(distSqr)

    -- [[ 2. Alpha (透明度) 计算，用于淡出效果 ]]
    local alpha = 1
    if dist > FADE_START_DISTANCE then
        -- 根据距离计算透明度，从1 (完全不透明) 渐变到 0 (完全透明)
        alpha = 1 - ((dist - FADE_START_DISTANCE) / FADE_DISTANCE_RANGE)
    end
    -- 确保 alpha 值在 0 和 1 之间
    alpha = math.Clamp(alpha, 0, 1)

    -- 如果完全透明，则无需绘制
    if alpha <= 0 then return end

    -- [[ 3. 缩放比例计算 ]]
    -- Lerp函数根据距离在 0.1 和 0.06 之间进行插值
    -- 距离越远，图标越小
    local scale = Lerp(dist / MAX_DRAW_DISTANCE, 0.1, 0.06)
    local finalScale = math.Clamp(scale, 0.06, 0.1) -- 限制缩放范围

    -- [[ 4. 3D2D 绘制准备 ]]
    local eyeAng = EyeAngles()
    -- 旋转角度，使面板始终朝向玩家
    eyeAng:RotateAroundAxis(eyeAng:Up(), -90)
    eyeAng:RotateAroundAxis(eyeAng:Forward(), 90)

    cam.Start3D2D(entPos, eyeAng, finalScale)

        -- 获取实体网络数据
        local ammoType = self:GetNWString("AmmoType", "pistol")
        local ammoAmount = self:GetNWString("AmmoAmount", "0")
        local iconName = GAMEMODE.AmmoIcons[ammoType] or ""

        -- [[ 5. 绘制UI元素 ]]
        -- 组合带有 alpha 的背景颜色
        local finalBackgroundColor = Color(COLOR_BACKGROUND.r, COLOR_BACKGROUND.g, COLOR_BACKGROUND.b, COLOR_BACKGROUND.a * alpha)

        -- 绘制背景 (直接将颜色作为参数传递)
        draw.RoundedBox(CORNER_RADIUS, -HALF_PANEL_WIDTH, -HALF_PANEL_HEIGHT, PANEL_WIDTH, PANEL_HEIGHT, finalBackgroundColor)

        -- 绘制边框
        surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, COLOR_BORDER.a * alpha)
        surface.DrawOutlinedRect(-HALF_PANEL_WIDTH, -HALF_PANEL_HEIGHT, PANEL_WIDTH, PANEL_HEIGHT)

        -- 绘制分割线
        surface.SetDrawColor(COLOR_SPLITTER.r, COLOR_SPLITTER.g, COLOR_SPLITTER.b, COLOR_SPLITTER.a * alpha)
        surface.DrawLine(SPLITTER_X_POS, -HALF_PANEL_HEIGHT + 5, SPLITTER_X_POS, HALF_PANEL_HEIGHT - 5)

        -- 绘制边框
        surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, COLOR_BORDER.a * alpha)
        surface.DrawOutlinedRect(-HALF_PANEL_WIDTH, -HALF_PANEL_HEIGHT, PANEL_WIDTH, PANEL_HEIGHT)

        -- 绘制分割线
        surface.SetDrawColor(COLOR_SPLITTER.r, COLOR_SPLITTER.g, COLOR_SPLITTER.b, COLOR_SPLITTER.a * alpha)
        surface.DrawLine(SPLITTER_X_POS, -HALF_PANEL_HEIGHT + 5, SPLITTER_X_POS, HALF_PANEL_HEIGHT - 5)

        -- 绘制图标和文字
        local killiconData = killicon.Get(iconName)
        if killiconData and killicon.GetIcon(iconName) then
            local matData = killicon.GetIcon(iconName)
            local materialPath = matData[1]

            -- [[ 性能关键: 从缓存获取材质，如果不存在则创建并存入缓存 ]]
            local mat = materialCache[materialPath]
            if not mat then
                -- 1. 如果材质在缓存中不存在，则创建它
                mat = Material(materialPath, "smooth")
                materialCache[materialPath] = mat
            elseif not mat:IsError() then
                -- 2. 如果缓存中的对象已失效 (不是一个有效材质了)，也重新创建它
                -- 这个检查只有在 mat 不是 nil 的情况下才会执行
                mat = Material(materialPath, "smooth")
                materialCache[materialPath] = mat
            end

            -- 绘制图标
            local iconColor = Color(matData[2].r, matData[2].g, matData[2].b, 255 * alpha)
            surface.SetMaterial(mat)
            surface.SetDrawColor(iconColor)
            surface.DrawTexturedRect(-HALF_PANEL_WIDTH + ICON_PADDING_X, -ICON_SIZE / 2, ICON_SIZE, ICON_SIZE)

            -- 绘制弹药数量
            surface.SetFont(FONT_NAME)
            surface.SetTextColor(iconColor)

            -- 计算文本位置使其在右侧区域居中
            local textWidth = surface.GetTextSize(ammoAmount)
            local textX = SPLITTER_X_POS + (PANEL_WIDTH - 60 - textWidth) / 2
            local textY = -PANEL_HEIGHT / 3 -- 可能需要根据字体微调

            surface.SetTextPos(textX, textY)
            surface.DrawText(ammoAmount)
        end

    cam.End3D2D()
end