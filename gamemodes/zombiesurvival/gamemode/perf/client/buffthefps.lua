-- This rewrites a few drawing methods to be slightly faster.
-- This file is to be included before everything else.

-- WARNING: Removes the functionality of any drawing functions returning values (except GetFontHeight).
-- This doesn't really matter in most cases because A: nobody uses it and B: they were returning wrong values most of the time anyway.

if SERVER or BuffedFPS then return end
BuffedFPS = true

-- 本地化全局变量和函数
local surface = surface
local Color = Color
local color_white = color_white
local string_sub = string.sub
local string_gmatch = string.gmatch
local math_ceil = math.ceil

-- 常量本地化
local TEXT_ALIGN_LEFT = 0
local TEXT_ALIGN_CENTER	= 1
local TEXT_ALIGN_RIGHT = 2
local TEXT_ALIGN_TOP = 3
local TEXT_ALIGN_BOTTOM	= 4

-- 本地化常用函数
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_DrawText = surface.DrawText
local surface_SetTexture = surface.SetTexture
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_DrawTexturedRectRotated = surface.DrawTexturedRectRotated
local surface_GetTextureID = surface.GetTextureID

-- 预先获取材质ID
local Tex_Corner8 = surface_GetTextureID( "gui/corner8" )
local Tex_Corner16 = surface_GetTextureID( "gui/corner16" )
local Tex_white = surface_GetTextureID( "vgui/white" )

local CachedFontHeights = {}
local function draw_GetFontHeight(font)
	if CachedFontHeights[font] then
		return CachedFontHeights[font]
	end

	surface_SetFont(font)
	local _, h = surface_GetTextSize("W")
	CachedFontHeights[font] = h

	return h
end

function GM:EmptyCachedFontHeights()
	CachedFontHeights = {}
end

-- 内部绘制函数，不进行对齐计算
local function draw_SimpleText_Internal(text, x, y, color)
    surface_SetTextPos(x, y)
    if color then
		surface_SetTextColor(color.r, color.g, color.b, color.a)
	else
		surface_SetTextColor(255, 255, 255, 255)
	end
    surface_DrawText(text)
end

-- 【已修正】恢复了原版的对齐逻辑
function draw.SimpleText(text, font, x, y, colour, xalign, yalign)
	if not text or text == "" then return end
    
	surface_SetFont(font)

    -- 水平对齐
	if xalign == TEXT_ALIGN_CENTER then
		local w, _ = surface_GetTextSize( text )
		x = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		local w, _ = surface_GetTextSize( text )
		x = x - w
	end

    -- 垂直对齐
	if yalign == TEXT_ALIGN_CENTER then
		local h = draw_GetFontHeight(font)
		y = y - h / 2
	elseif yalign == TEXT_ALIGN_BOTTOM then
		local h = draw_GetFontHeight(font)
		y = y - h
	end
	
	surface_SetTextPos(x, y)
	if colour then
		surface_SetTextColor(colour.r, colour.g, colour.b, colour.a)
	else
		surface_SetTextColor(255, 255, 255, 255)
	end
	surface_DrawText(text)
end

-- 【已修正】恢复原版行高逻辑，并使用优化后的 draw.SimpleText
function draw.DrawText(text, font, x, y, colour, xalign)
	if not text or text == "" then return end

	surface_SetFont(font)
	local lineHeight = draw_GetFontHeight(font)
    local curY = y

	for line in string_gmatch(text, "[^\n]+") do
		line = line:gsub("\t", "    ") -- 简单处理tab
		draw.SimpleText(line, font, x, curY, colour, xalign)
		curY = curY + lineHeight / 2 -- 【修正】恢复原版 lineheight/2 的行高，以保证兼容性
	end
end

function draw.RoundedBox(bordersize, x, y, w, h, color)
	surface_SetDrawColor(color)

	surface_DrawRect(x + bordersize, y, w - bordersize * 2, h)
	surface_DrawRect(x, y + bordersize, bordersize, h - bordersize * 2)
	surface_DrawRect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2)

	surface_SetTexture(bordersize > 8 and Tex_Corner16 or Tex_Corner8)
	surface_DrawTexturedRectRotated( x + bordersize/2 , y + bordersize/2, bordersize, bordersize, 0 )
	surface_DrawTexturedRectRotated( x + w - bordersize/2 , y + bordersize/2, bordersize, bordersize, 270 )
	surface_DrawTexturedRectRotated( x + bordersize/2 , y + h -bordersize/2, bordersize, bordersize, 90 )
	surface_DrawTexturedRectRotated( x + w - bordersize/2 , y + h - bordersize/2, bordersize, bordersize, 180 )
end

function draw.Text(tab)
    draw.SimpleText(
        tab.text,
        tab.font or "DermaDefault",
        tab.pos[1] or 0,
        tab.pos[2] or 0,
        tab.color,
        tab.xalign,
        tab.yalign
    )
end

function draw.WordBox( bordersize, x, y, text, font, color, fontcolor )
	surface_SetFont( font )
	local w, h = surface_GetTextSize( text )

	draw.RoundedBox( bordersize, x, y, w+bordersize*2, h+bordersize*2, color )

	surface_SetTextColor( fontcolor.r, fontcolor.g, fontcolor.b, fontcolor.a )
	surface_SetTextPos( x + bordersize, y + bordersize )
	surface_DrawText( text )
end

function draw.TextShadow( tab, distance, alpha )
	alpha = alpha or 200

	local origColor = tab.color
	local origX, origY = tab.pos[1], tab.pos[2]

	tab.color = Color( 0, 0, 0, alpha )
	tab.pos[1] = origX + distance
	tab.pos[2] = origY + distance
	draw.Text( tab )

	tab.color = origColor
	tab.pos[1] = origX
	tab.pos[2] = origY
	draw.Text( tab )
end

function draw.TexturedQuad(tab)
	surface_SetTexture(tab.texture)
	surface_SetDrawColor(tab.color or color_white)
	surface_DrawTexturedRect(tab.x, tab.y, tab.w, tab.h)
end

function draw.NoTexture()
	surface_SetTexture( Tex_white )
end

function draw.RoundedBoxEx( bordersize, x, y, w, h, color, a, b, c, d )
	surface_SetDrawColor(color)

	surface_DrawRect(x + bordersize, y, w - bordersize * 2, h)
	surface_DrawRect(x, y + bordersize, bordersize, h - bordersize * 2)
	surface_DrawRect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2)

	surface_SetTexture(bordersize > 8 and Tex_Corner16 or Tex_Corner8)

	if a then
		surface_DrawTexturedRectRotated( x + bordersize/2 , y + bordersize/2, bordersize, bordersize, 0 )
	else
		surface_DrawRect( x, y, bordersize, bordersize )
	end

	if b then
		surface_DrawTexturedRectRotated( x + w - bordersize/2 , y + bordersize/2, bordersize, bordersize, 270 )
	else
		surface_DrawRect( x + w - bordersize, y, bordersize, bordersize )
	end

	if c then
		surface_DrawTexturedRectRotated( x + bordersize/2 , y + h -bordersize/2, bordersize, bordersize, 90 )
	else
		surface_DrawRect( x, y + h - bordersize, bordersize, bordersize )
	end

	if d then
		surface_DrawTexturedRectRotated( x + w - bordersize/2 , y + h - bordersize/2, bordersize, bordersize, 180 )
	else
		surface_DrawRect( x + w - bordersize, y + h - bordersize, bordersize, bordersize )
	end
end

-- 【已修正】使用优化后的绘制方法，但修复了对齐逻辑
function draw.SimpleTextOutlined(text, font, x, y, colour, xalign, yalign, outlinewidth, outlinecolour)
	if not text or text == "" then return end
    
    -- 先进行一次完整的对齐计算
    local alignedX, alignedY = x, y
    surface_SetFont(font)

    -- 水平对齐
	if xalign == TEXT_ALIGN_CENTER then
		local w, _ = surface_GetTextSize( text )
		alignedX = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		local w, _ = surface_GetTextSize( text )
		alignedX = x - w
	end

    -- 垂直对齐
	if yalign == TEXT_ALIGN_CENTER then
		local h = draw_GetFontHeight(font)
		alignedY = y - h / 2
	elseif yalign == TEXT_ALIGN_BOTTOM then
		local h = draw_GetFontHeight(font)
		alignedY = y - h
	end
    
    -- 绘制轮廓
	surface_SetTextColor(outlinecolour.r, outlinecolour.g, outlinecolour.a, outlinecolour.a)
    
    -- 八方向绘制，性能高于原版的嵌套循环
    surface_SetTextPos(alignedX - outlinewidth, alignedY - outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX, alignedY - outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX + outlinewidth, alignedY - outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX - outlinewidth, alignedY); surface_DrawText(text)
    surface_SetTextPos(alignedX + outlinewidth, alignedY); surface_DrawText(text)
    surface_SetTextPos(alignedX - outlinewidth, alignedY + outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX, alignedY + outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX + outlinewidth, alignedY + outlinewidth); surface_DrawText(text)
	
	-- 绘制前景文字
	surface_SetTextColor(colour.r, colour.g, colour.b, colour.a)
	surface_SetTextPos(alignedX, alignedY)
	surface_DrawText(text)
end

-- 将重写后的函数赋值给 draw 表
draw.GetFontHeight = draw_GetFontHeight
-- draw.SimpleText, draw.DrawText, draw.RoundedBox, draw.Text 已经在上面定义了
draw.SimpleTextOutlined = draw.SimpleTextOutlined -- 确保覆盖

-- 动画部分保持不变，是良好的优化
local SpeakFlexes = {
	["jaw_drop"] = true,
	["right_part"] = true,
	["left_part"] = true,
	["right_mouth_drop"] = true,
	["left_mouth_drop"] = true
}
local GESTURE_SLOT_VCD = GESTURE_SLOT_VCD
local ACT_GMOD_IN_CHAT = ACT_GMOD_IN_CHAT
hook.Add("Initialize", "InstallFunctions_Buffed", function()
	function GAMEMODE:MouthMoveAnimation( pl )
		if pl:IsSpeaking() then
			pl.m_bWasSpeaking = true

			local FlexNum = pl:GetFlexNum() - 1
			if FlexNum <= 0 then return end
			local weight = math.Clamp(pl:VoiceVolume() * 2, 0, 2)
			for i = 0, FlexNum - 1 do
				if SpeakFlexes[pl:GetFlexName(i)] then
					pl:SetFlexWeight(i, weight)
				end
			end
		elseif pl.m_bWasSpeaking then
			pl.m_bWasSpeaking = false

			local FlexNum = pl:GetFlexNum() - 1
			if FlexNum <= 0 then return end
			for i = 0, FlexNum - 1 do
				if SpeakFlexes[pl:GetFlexName(i)] then
					pl:SetFlexWeight( i, 0 )
				end
			end
		end
	end

	function GAMEMODE:GrabEarAnimation(pl)
        local isTyping = pl:IsTyping()
		if isTyping then
			pl.ChatGestureWeight = math.Approach(pl.ChatGestureWeight or 0, 1, FrameTime() * 5)
		elseif pl.ChatGestureWeight and pl.ChatGestureWeight > 0 then
			pl.ChatGestureWeight = math.Approach(pl.ChatGestureWeight, 0, FrameTime() * 5)
			if pl.ChatGestureWeight == 0 then
				pl.ChatGestureWeight = nil
			end
		end

		if pl.ChatGestureWeight then
			if pl:IsPlayingTaunt() then return end

			pl:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
			pl:AnimSetGestureWeight(GESTURE_SLOT_VCD, pl.ChatGestureWeight)
		end
	end
end)

local function empty() end
drive.Move = empty
drive.FinishMove = empty
drive.StartMove = empty

print("[BuffedFPS] Optimized drawing functions loaded (v2 - Fixed Alignment).")