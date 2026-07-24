-- ============================================================
-- cl_draw.lua - 客户端绘制辅助函数
-- 提供带模糊效果的文本绘制、圆角矩形边框、任意四边形、
-- 圆弧/空心圆环、余弦插值及加粗描边等自定义绘制功能
-- ============================================================

-- 缓存原始绘制函数引用以提高性能（避免重复查表）
local draw_SimpleText = draw.SimpleText
local draw_DrawText = draw.DrawText

-- 字体模糊偏移量变量，由定时器不断随机更新以产生动态抖动效果
local FontBlurX = 0
local FontBlurX2 = 0
local FontBlurY = 0
local FontBlurY2 = 0

-- 定时器：每0.1秒更新一次字体模糊偏移量，模拟屏幕抖动/发光效果
timer.Create("fontblur", 0.1, 0, function()
	FontBlurX = math.random(-8, 8)
	FontBlurX2 = math.random(-8, 8)
	FontBlurY = math.random(-8, 8)
	FontBlurY2 = math.random(-8, 8)
end)

-- 两层模糊效果所使用的颜色常量
local color_blur1 = Color(60, 60, 60, 220)  -- 第一层模糊（较亮，透明度较高）
local color_blur2 = Color(40, 40, 40, 140)  -- 第二层模糊（较暗，透明度较低）

-- 带双重偏移模糊效果的 SimpleText 绘制函数
function draw.SimpleTextBlur(text, font, x, y, col, xalign, yalign)
	if GAMEMODE.FontEffects then
		color_blur1.a = col.a * 0.85
		color_blur2.a = col.a * 0.55
		draw_SimpleText(text, font, x + FontBlurX, y + FontBlurY, color_blur1, xalign, yalign)
		draw_SimpleText(text, font, x + FontBlurX2, y + FontBlurY2, color_blur2, xalign, yalign)
	end
	draw_SimpleText(text, font, x, y, col, xalign, yalign)
end

-- 带双重偏移模糊效果的 DrawText 绘制函数
function draw.DrawTextBlur(text, font, x, y, col, xalign)
	if GAMEMODE.FontEffects then
		color_blur1.a = col.a * 0.85
		color_blur2.a = col.a * 0.55
		draw_DrawText(text, font, x + FontBlurX, y + FontBlurY, color_blur1, xalign)
		draw_DrawText(text, font, x + FontBlurX2, y + FontBlurY2, color_blur2, xalign)
	end
	draw_DrawText(text, font, x, y, col, xalign)
end

-- 用于 SimpleTextBlurry/DrawTextBlurry 的临时颜色变量，避免重复创建
local colBlur = Color(0, 0, 0)

-- 带单层随机透明度模糊的 SimpleText 绘制函数（使用独立的 Blur 字体变体）
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

-- 带单层随机透明度模糊的 DrawText 绘制函数（使用独立的 Blur 字体变体）
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

-- 缓存圆角纹理的材质ID（8像素和16像素两种尺寸）
local corner8 = surface.GetTextureID("gui/corner8")
local corner16 = surface.GetTextureID("gui/corner16")

-- 绘制空心圆角矩形（使用四条边框矩形 + 四角圆角纹理）
function draw.RoundedBoxHollow(borderWidth, x, y, width, height, color)
    local halfBorder = borderWidth - 1
    x = math.Round(x)
    y = math.Round(y)
    width = math.Round(width)
    height = math.Round(height)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    -- 上边框
    surface.DrawRect(x + halfBorder, y, width - halfBorder * 2, halfBorder)
    -- 下边框
    surface.DrawRect(x + halfBorder, y + height - halfBorder, width - halfBorder * 2, halfBorder)
    -- 左边框
    surface.DrawRect(x, y + halfBorder, halfBorder, height - halfBorder * 2)
    -- 右边框
    surface.DrawRect(x + width - halfBorder, y + halfBorder, halfBorder, height - halfBorder * 2)
    -- 根据边框宽度选择合适的圆角纹理
    local texture = corner8
    if borderWidth > 8 then 
        texture = corner16 
    end
    surface.SetTexture(texture)
    -- 绘制四个角的圆角纹理
    surface.DrawTexturedRectUV(x, y, borderWidth, borderWidth, 0, 0, 1, 1)       -- 左上角
    surface.DrawTexturedRectUV(x + width - borderWidth, y, borderWidth, borderWidth, 1, 0, 0, 1) -- 右上角
    surface.DrawTexturedRectUV(x, y + height - borderWidth, borderWidth, borderWidth, 0, 1, 1, 0) -- 左下角
    surface.DrawTexturedRectUV(x + width - borderWidth, y + height - borderWidth, borderWidth, borderWidth, 1, 1, 0, 0) -- 右下角
end

-- 存储四边形顶点坐标，复用此表避免重复创建表对象（性能优化）
local quadVerts = {{}, {}, {}, {}}

-- ============================================================
-- 绘制任意四边形（使用 DrawPoly 绘制多边形）
-- x1~y4：四个顶点的屏幕坐标
-- color：填充颜色
-- ============================================================
function surface.DrawQuad(x1, y1, x2, y2, x3, y3, x4, y4,color)
    quadVerts[1].x, quadVerts[1].y = x1, y1
    quadVerts[2].x, quadVerts[2].y = x2, y2
    quadVerts[3].x, quadVerts[3].y = x3, y3
    quadVerts[4].x, quadVerts[4].y = x4, y4
    -- 注：原代码中有一行被注释掉的 surface.DrawPoly(quadVerts)，此处已移除
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.DrawPoly(quadVerts)
end

-- 角度转换常量：度转弧度（math.pi / 180）
local degToRad = math.pi / 180
local drawQuad = surface.DrawQuad

-- ============================================================
-- 绘制圆弧环形（从内半径到外半径）
-- centerX, centerY：圆心坐标
-- innerRadius：内圈半径
-- outerRadius：外圈半径
-- startAngle：起始角度（度）
-- endAngle：结束角度（度）
-- segments：分段数，值越大圆弧越平滑
-- color：填充颜色
-- ============================================================
function surface.DrawArc(centerX, centerY, innerRadius, outerRadius, startAngle, endAngle, segments,color)
    startAngle, endAngle = startAngle * degToRad, endAngle * degToRad
    local angleStep = (endAngle - startAngle) / segments
    local prevX, prevY = math.cos(startAngle), math.sin(startAngle)
    
    -- 逐段绘制环形四边形
    for i = 0, segments - 1 do
        local angle = i * angleStep + startAngle
        local currX, currY = prevX, prevY
        prevX, prevY = math.cos(angle + angleStep), math.sin(angle + angleStep)

        -- 使用 DrawQuad 绘制每段环形分段
        drawQuad(
            centerX + currX * innerRadius, centerY + currY * innerRadius,
            centerX + currX * outerRadius, centerY + currY * outerRadius,
            centerX + prevX * outerRadius, centerY + prevY * outerRadius,
            centerX + prevX * innerRadius, centerY + prevY * innerRadius,
            color
        )
    end
end

-- 用于 HollowCircle 背景的纹理，确保半透明颜色能正确渲染（alpha混合必需）
local alphaBackTexture = surface.GetTextureID("vgui/white")

-- 绘制圆弧段的便捷封装函数（自动设置纹理后调用 DrawArc）
function DrawArcSegment(centerX, centerY, innerR, outerR, startAng, endAng, color, segments)
    surface.SetTexture(alphaBackTexture)
    surface.DrawArc(centerX, centerY, innerR, outerR, startAng, endAng, segments, color)
end

-- ============================================================
-- 画一个空心圆弧（Hollow Circle），即环形/圆环
-- centerX, centerY：圆心坐标
-- radius：内半径
-- thickness：圆环厚度
-- startAngle：起始角度（度）
-- endAngle：结束角度（度）
-- color：填充颜色
-- ============================================================
function draw.HollowCircle(centerX, centerY, radius, thickness, startAngle, endAngle, color, linesTable)
    surface.SetTexture(alphaBackTexture)
    surface.DrawArc(centerX, centerY, radius, radius + thickness, startAngle, endAngle, 36, color)
end

-- ============================================================
-- 余弦插值函数（用于平滑动画过渡）
-- y1：起始值
-- y2：结束值
-- mu：插值进度（0.0 ~ 1.0）
-- 返回值：插值后的中间值
-- ============================================================
function CosineInterpolation(y1, y2, mu)
    local mu2 = (1 - math.cos(mu * math.pi)) / 2
    return y1 * (1 - mu2) + y2 * mu2
end

-- ============================================================
-- 画加粗矩形描边（通过多次绘制向外扩展轮廓）
-- x, y：矩形左上角坐标
-- width, height：矩形宽高
-- thickness：描边宽度
-- color：颜色
-- ============================================================
function DrawThickOutline(x, y, width, height, thickness, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    for i = 0, thickness - 1 do
        -- 每次循环向外扩展一层像素绘制轮廓框
        surface.DrawOutlinedRect(x - i, y - i, width + 2 * i, height + 2 * i)
    end
end
