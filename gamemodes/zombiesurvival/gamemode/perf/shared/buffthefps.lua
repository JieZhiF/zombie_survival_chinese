-- This rewrites a few drawing methods to be slightly faster.
-- This file is to be included before everything else.

-- WARNING: Removes the functionality of any drawing functions returning values (except GetFontHeight).
-- This doesn't really matter in most cases because A: nobody uses it and B: they were returning wrong values most of the time anyway.

if SERVER or BuffedFPS then return end
BuffedFPS = true

-- 本地化全局变量和常用函数，这是性能优化的第一步
local surface = surface
local Color = Color
local color_white = color_white
local string_gmatch = string.gmatch -- 仅预先获取需要用到的函数
local math_ceil = math.ceil
local FrameTime = FrameTime
local hook = hook

-- 常量本地化
local TEXT_ALIGN_CENTER	= 1
local TEXT_ALIGN_RIGHT = 2
local TEXT_ALIGN_BOTTOM	= 4

-- surface库函数本地化
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


-- 字体高度缓存，原实现已经很好，予以保留
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


-- 【优化点 1】: `draw_SimpleText` 是核心函数，保持其原有的、正确的对齐逻辑。
-- 这个函数在原脚本中是正确的，我们将基于它来优化其他函数。
local function draw_SimpleText(text, font, x, y, colour, xalign, yalign)
	surface_SetFont(font)

	if xalign == TEXT_ALIGN_CENTER then
		local w, _ = surface_GetTextSize( text )
		x = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		local w, _ = surface_GetTextSize( text )
		x = x - w
	end

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


-- 【优化点 2】: `draw_DrawText` (处理多行文本)
-- 原实现逐字符循环并拼接字符串，效率低下。
-- 优化后：使用 `string.gmatch` 按行分割，性能远超原版。
local function draw_DrawText_Optimized(text, font, x, y, colour, xalign)
	if not text or text == "" then return end

	surface_SetFont(font)
	local lineHeight = draw_GetFontHeight(font)
	local curY = y

	for line in string_gmatch(text, "[^\n]+") do
        -- 原版对制表符 `\t` 的处理非常耗性能（GetTextSize），这里简化为替换成空格
        line = line:gsub("\t", "    ")
		draw_SimpleText(line, font, x, curY, colour, xalign)
		curY = curY + lineHeight / 2 -- 保持与原版完全一致的行高逻辑
	end
end


-- `draw_RoundedBox` 的原实现已经是标准且高效的，无需改动。
local function draw_RoundedBox(bordersize, x, y, w, h, color)
	surface_SetDrawColor(color)

	surface_DrawRect(x + bordersize, y, w - bordersize * 2, h)
	surface_DrawRect(x, y + bordersize, bordersize, h - bordersize * 2)
	surface_DrawRect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2)

	surface_SetTexture(bordersize > 8 and Tex_Corner16 or Tex_Corner8)
	surface_DrawTexturedRectRotated( x + bordersize/2, y + bordersize/2, bordersize, bordersize, 0 )
	surface_DrawTexturedRectRotated( x + w - bordersize/2, y + bordersize/2, bordersize, bordersize, 270 )
	surface_DrawTexturedRectRotated( x + bordersize/2, y + h - bordersize/2, bordersize, bordersize, 90 )
	surface_DrawTexturedRectRotated( x + w - bordersize/2, y + h - bordersize/2, bordersize, bordersize, 180 )
end


-- `draw_Text` 可以简化为直接调用 draw_SimpleText，逻辑更清晰
local function draw_Text_Optimized(tab)
	draw_SimpleText(
        tab.text,
        tab.font or "DermaDefault",
        tab.pos[1] or 0,
        tab.pos[2] or 0,
        tab.color,
        tab.xalign,
        tab.yalign
    )
end


-- 【优化点 3】: `draw.TextShadow`
-- 原实现创建了一个新的 pos 表 `{ pos[1] + distance, pos[2] + distance }`，增加了GC压力。
-- 优化后：直接修改传入的 `tab.pos`，用完再恢复，避免了内存分配。
function draw.TextShadow( tab, distance, alpha )
	alpha = alpha or 200

	local origColor = tab.color
	local origX, origY = tab.pos[1], tab.pos[2]

	-- 绘制阴影
	tab.color = Color( 0, 0, 0, alpha )
	tab.pos[1] = origX + distance
	tab.pos[2] = origY + distance
	draw_Text_Optimized( tab ) -- 使用优化后的函数

	-- 恢复原值并绘制前景
	tab.color = origColor
	tab.pos[1] = origX
	tab.pos[2] = origY
	draw_Text_Optimized( tab ) -- 使用优化后的函数
end


-- 【优化点 4】: `draw.SimpleTextOutlined`
-- 原实现使用嵌套循环，每次循环都完整调用一次 `draw_SimpleText`，包含大量重复的对齐计算。
-- 优化后：先做一次对齐计算，然后只调用8次轻量级的绘制指令，性能提升巨大。
function draw.SimpleTextOutlined(text, font, x, y, colour, xalign, yalign, outlinewidth, outlinecolour)
	if not text or text == "" then return end
    
    -- 1. 先进行一次完整的对齐计算
    local alignedX, alignedY = x, y
    surface_SetFont(font)

	if xalign == TEXT_ALIGN_CENTER then
		local w, _ = surface_GetTextSize( text )
		alignedX = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		local w, _ = surface_GetTextSize( text )
		alignedX = x - w
	end

	if yalign == TEXT_ALIGN_CENTER then
		local h = draw_GetFontHeight(font)
		alignedY = y - h / 2
	elseif yalign == TEXT_ALIGN_BOTTOM then
		local h = draw_GetFontHeight(font)
		alignedY = y - h
	end
    
    -- 2. 绘制轮廓 (八个方向)
	surface_SetTextColor(outlinecolour.r, outlinecolour.g, outlinecolour.b, outlinecolour.a)
    
    -- 这种八方向绘制比嵌套循环快得多
    surface_SetTextPos(alignedX - outlinewidth, alignedY - outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX,                   alignedY - outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX + outlinewidth, alignedY - outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX - outlinewidth, alignedY);                   surface_DrawText(text)
    surface_SetTextPos(alignedX + outlinewidth, alignedY);                   surface_DrawText(text)
    surface_SetTextPos(alignedX - outlinewidth, alignedY + outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX,                   alignedY + outlinewidth); surface_DrawText(text)
    surface_SetTextPos(alignedX + outlinewidth, alignedY + outlinewidth); surface_DrawText(text)
	
	-- 3. 绘制前景文字
	surface_SetTextColor(colour.r, colour.g, colour.b, colour.a)
	surface_SetTextPos(alignedX, alignedY)
	surface_DrawText(text)
end


-- 将优化后的函数或未改动的函数覆盖到全局 `draw` 表中
draw.GetFontHeight = draw_GetFontHeight
draw.SimpleText = draw_SimpleText
draw.DrawText = draw_DrawText_Optimized
draw.RoundedBox = draw_RoundedBox
draw.Text = draw_Text_Optimized

-- 以下函数原实现已很高效或没有优化空间，保持原样
function draw.WordBox( bordersize, x, y, text, font, color, fontcolor )
	surface_SetFont( font )
	local w, h = surface_GetTextSize( text )
	draw_RoundedBox( bordersize, x, y, w + bordersize * 2, h + bordersize * 2, color )
	surface_SetTextColor( fontcolor.r, fontcolor.g, fontcolor.b, fontcolor.a )
	surface_SetTextPos( x + bordersize, y + bordersize )
	surface_DrawText( text )
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

-- 动画部分的优化已经很好了，予以保留。
-- 预先缓存玩家语音Flex名称的哈希表是很好的实践。
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
			if not pl.m_bWasSpeaking then
                pl.m_bWasSpeaking = true
            end
			local weight = math.Clamp(pl:VoiceVolume() * 2, 0, 2)
			for i = 0, pl:GetFlexNum() - 1 do
				if SpeakFlexes[pl:GetFlexName(i)] then
					pl:SetFlexWeight(i, weight)
				end
			end
		elseif pl.m_bWasSpeaking then
			pl.m_bWasSpeaking = false
			for i = 0, pl:GetFlexNum() - 1 do
				if SpeakFlexes[pl:GetFlexName(i)] then
					pl:SetFlexWeight(i, 0)
				end
			end
		end
	end

	function GAMEMODE:GrabEarAnimation(pl)
		if pl:IsTyping() then
			pl.ChatGestureWeight = math.Approach(pl.ChatGestureWeight or 0, 1, FrameTime() * 5)
		elseif pl.ChatGestureWeight and pl.ChatGestureWeight > 0 then
			pl.ChatGestureWeight = math.Approach(pl.ChatGestureWeight, 0, FrameTime() * 5)
			if pl.ChatGestureWeight <= 0 then
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

-- 清空不使用的函数，保持不变
local function empty() end
drive.Move = empty
drive.FinishMove = empty
drive.StartMove = empty

print("[BuffedFPS] Heavily optimized drawing functions loaded.")