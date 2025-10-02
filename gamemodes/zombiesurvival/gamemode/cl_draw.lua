local draw_SimpleText = draw.SimpleText
local draw_DrawText = draw.DrawText

local FontBlurX = 0
local FontBlurX2 = 0
local FontBlurY = 0
local FontBlurY2 = 0

timer.Create("fontblur", 0.1, 0, function()
	FontBlurX = math.random(-8, 8)
	FontBlurX2 = math.random(-8, 8)
	FontBlurY = math.random(-8, 8)
	FontBlurY2 = math.random(-8, 8)
end)

local color_blur1 = Color(60, 60, 60, 220)
local color_blur2 = Color(40, 40, 40, 140)
function draw.SimpleTextBlur(text, font, x, y, col, xalign, yalign)
	if GAMEMODE.FontEffects then
		color_blur1.a = col.a * 0.85
		color_blur2.a = col.a * 0.55
		draw_SimpleText(text, font, x + FontBlurX, y + FontBlurY, color_blur1, xalign, yalign)
		draw_SimpleText(text, font, x + FontBlurX2, y + FontBlurY2, color_blur2, xalign, yalign)
	end
	draw_SimpleText(text, font, x, y, col, xalign, yalign)
end

function draw.DrawTextBlur(text, font, x, y, col, xalign)
	if GAMEMODE.FontEffects then
		color_blur1.a = col.a * 0.85
		color_blur2.a = col.a * 0.55
		draw_DrawText(text, font, x + FontBlurX, y + FontBlurY, color_blur1, xalign)
		draw_DrawText(text, font, x + FontBlurX2, y + FontBlurY2, color_blur2, xalign)
	end
	draw_DrawText(text, font, x, y, col, xalign)
end

local colBlur = Color(0, 0, 0)
function draw.SimpleTextBlurry(text, font, x, y, col, xalign, yalign)
	if GAMEMODE.FontEffects then
		colBlur.r = col.r
		colBlur.g = col.g
		colBlur.b = col.b
		colBlur.a = col.a * math.Rand(0.35, 0.6)

		draw_SimpleText(text, font.."Blur", x, y, colBlur, xalign, yalign)
	end
	draw_SimpleText(text, font, x, y, col, xalign, yalign)
end

function draw.DrawTextBlurry(text, font, x, y, col, xalign)
	if GAMEMODE.FontEffects then
		colBlur.r = col.r
		colBlur.g = col.g
		colBlur.b = col.b
		colBlur.a = col.a * math.Rand(0.35, 0.6)

		draw_DrawText(text, font.."Blur", x, y, colBlur, xalign)
	end
	draw_DrawText(text, font, x, y, col, xalign)
end

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
    if borderWidth > 8 then 
        texture = corner16 
    end
    surface.SetTexture(texture)
    -- Draw corner textures
    surface.DrawTexturedRectUV(x, y, borderWidth, borderWidth, 0, 0, 1, 1) -- Top-left
    surface.DrawTexturedRectUV(x + width - borderWidth, y, borderWidth, borderWidth, 1, 0, 0, 1) -- Top-right
    surface.DrawTexturedRectUV(x, y + height - borderWidth, borderWidth, borderWidth, 0, 1, 1, 0) -- Bottom-left
    surface.DrawTexturedRectUV(x + width - borderWidth, y + height - borderWidth, borderWidth, borderWidth, 1, 1, 0, 0) -- Bottom-right
end
-- 存储四边形顶点，复用避免重复创建表
local quadVerts = {{}, {}, {}, {}}

----------------------------------------------------
-- 绘制任意四边形（使用 DrawPoly）
-- x1~y4 -> 四个顶点坐标
----------------------------------------------------
function surface.DrawQuad(x1, y1, x2, y2, x3, y3, x4, y4,color)
    quadVerts[1].x, quadVerts[1].y = x1, y1
    quadVerts[2].x, quadVerts[2].y = x2, y2
    quadVerts[3].x, quadVerts[3].y = x3, y3
    quadVerts[4].x, quadVerts[4].y = x4, y4
    --surface.DrawPoly(quadVerts)
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.DrawPoly(quadVerts)
end

-- 角度转换常量（度转弧度）
local degToRad = math.pi / 180
local drawQuad = surface.DrawQuad

----------------------------------------------------
-- 绘制圆弧（内半径 -> 外半径）
-- centerX, centerY -> 圆心
-- innerRadius       -> 内圈半径
-- outerRadius       -> 外圈半径
-- startAngle        -> 起始角度（度）
-- endAngle          -> 结束角度（度）
-- segments          -> 圆弧分段数量，越多越平滑
----------------------------------------------------
function surface.DrawArc(centerX, centerY, innerRadius, outerRadius, startAngle, endAngle, segments,color)
    startAngle, endAngle = startAngle * degToRad, endAngle * degToRad
    local angleStep = (endAngle - startAngle) / segments
    local prevX, prevY = math.cos(startAngle), math.sin(startAngle)
    
    for i = 0, segments - 1 do
        local angle = i * angleStep + startAngle
        local currX, currY = prevX, prevY
        prevX, prevY = math.cos(angle + angleStep), math.sin(angle + angleStep)

        -- 使用 DrawQuad 绘制每段环形
        drawQuad(
            centerX + currX * innerRadius, centerY + currY * innerRadius,
            centerX + currX * outerRadius, centerY + currY * outerRadius,
            centerX + prevX * outerRadius, centerY + prevY * outerRadius,
            centerX + prevX * innerRadius, centerY + prevY * innerRadius,
            color
        )
    end
end

-- 用于 HollowCircle 背景
--local alphaBackTexture = surface.GetTextureID("vgui/alpha-back")
-- Required dummy texture to render arcs with alpha correctly
local alphaBackTexture = surface.GetTextureID("vgui/white")

-- Convenience wrapper for drawing arc segments
function DrawArcSegment(centerX, centerY, innerR, outerR, startAng, endAng, color, segments)
    surface.SetTexture(alphaBackTexture)
    surface.DrawArc(centerX, centerY, innerR, outerR, startAng, endAng, segments, color)
end
----------------------------------------------------
-- 画一个空心圆弧（Hollow Circle）
-- centerX, centerY -> 圆心坐标
-- radius           -> 内半径
-- thickness        -> 圆环厚度
-- startAngle       -> 起始角度（度）
-- endAngle         -> 结束角度（度）
-- color            -> 颜色
----------------------------------------------------
function draw.HollowCircle(centerX, centerY, radius, thickness, startAngle, endAngle, color, linesTable)
    surface.SetTexture(alphaBackTexture)
    surface.DrawArc(centerX, centerY, radius, radius + thickness, startAngle, endAngle, 36, color)
end
----------------------------------------------------
-- 余弦插值函数（平滑动画用）
-- y1, y2 -> 起点和终点
-- mu     -> 0~1 进度
-- 返回值 -> 插值结果
----------------------------------------------------
function CosineInterpolation(y1, y2, mu)
    local mu2 = (1 - math.cos(mu * math.pi)) / 2
    return y1 * (1 - mu2) + y2 * mu2
end

----------------------------------------------------
-- 画加粗矩形描边
-- x, y      -> 左上角
-- width, height -> 宽高
-- thickness -> 描边宽度
-- color     -> 颜色
----------------------------------------------------
function DrawThickOutline(x, y, width, height, thickness, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    for i = 0, thickness - 1 do
        -- 每次向外扩展一层
        surface.DrawOutlinedRect(x - i, y - i, width + 2 * i, height + 2 * i)
    end
end
