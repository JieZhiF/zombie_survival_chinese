-- ============================================================================
-- perf/client/buffthefps.lua - 客户端绘制性能优化核心（BuffedFPS）
-- 负责：以高性能实现重写 surface/draw 的部分绘制函数
--       （draw.SimpleText/DrawText/RoundedBox/TextShadow 等），
--       并缓存字体高度、材质 ID 等结果，避免逐帧重复测量与查询。
-- 重要：本文件必须最先加载（位于 cl_init.lua 加载链最前），
--       因为被重写的绘制函数不再返回有意义的值（除 GetFontHeight 外），
--       后续所有代码都必须基于这一约定；服务端会直接跳过本文件。
-- ============================================================================
-- This rewrites a few drawing methods to be slightly faster.
-- This file is to be included before everything else.

-- WARNING: Removes the functionality of any drawing functions returning values (except GetFontHeight).
-- This doesn't really matter in most cases because A: nobody uses it and B: they were returning wrong values most of the time anyway.

-- 防重复加载守卫：服务端不需要这些绘制重写，客户端也保证只执行一次
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

-- 字体高度缓存表：避免重复调用 surface.GetTextSize 测量文本高度
local CachedFontHeights = {}
-- ==== draw_GetFontHeight - 获取（并缓存）指定字体的行高 ====
local function draw_GetFontHeight(font)
	if CachedFontHeights[font] then
		return CachedFontHeights[font]
	end

	surface_SetFont(font)
	local _, h = surface_GetTextSize("W")
	CachedFontHeights[font] = h

	return h
end

-- ==== GM:EmptyCachedFontHeights - 清空字体高度缓存 ====
-- 字体资源重载后（如字体 DLC 加载完成）需调用，避免使用过期行高
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

-- ==== draw.RoundedBox - 高性能圆角矩形 ====
-- 用四条矩形边 + 四角圆角纹理拼接，替代原版实现
function draw.RoundedBox(bordersize, x, y, w, h, color)
	if type(color) == "table" then
		surface_SetDrawColor(color.r or 255, color.g or 255, color.b or 255, color.a or 255)
	else
		surface_SetDrawColor(color)
	end

	surface_DrawRect(x + bordersize, y, w - bordersize * 2, h)
	surface_DrawRect(x, y + bordersize, bordersize, h - bordersize * 2)
	surface_DrawRect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2)

	surface_SetTexture(bordersize > 8 and Tex_Corner16 or Tex_Corner8)
	surface_DrawTexturedRectRotated( x + bordersize/2 , y + bordersize/2, bordersize, bordersize, 0 )
	surface_DrawTexturedRectRotated( x + w - bordersize/2 , y + bordersize/2, bordersize, bordersize, 270 )
	surface_DrawTexturedRectRotated( x + bordersize/2 , y + h -bordersize/2, bordersize, bordersize, 90 )
	surface_DrawTexturedRectRotated( x + w - bordersize/2 , y + h - bordersize/2, bordersize, bordersize, 180 )
end

-- ==== draw.Text - 表格参数版文本绘制 ====
-- 按原版 draw.Text 的参数结构（tab 表）转调优化后的 draw.SimpleText
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

-- ==== draw.WordBox - 带背景盒的文字绘制 ====
-- 先按文本尺寸绘制圆角背景盒，再在盒内绘制文字
function draw.WordBox( bordersize, x, y, text, font, color, fontcolor )
	surface_SetFont( font )
	local w, h = surface_GetTextSize( text )

	draw.RoundedBox( bordersize, x, y, w+bordersize*2, h+bordersize*2, color )

	surface_SetTextColor( fontcolor.r, fontcolor.g, fontcolor.b, fontcolor.a )
	surface_SetTextPos( x + bordersize, y + bordersize )
	surface_DrawText( text )
end

-- ==== draw.TextShadow - 带投影的文字绘制 ====
-- 先画偏移指定距离的黑色文字作投影，再在原位置画前景文字
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

-- ==== draw.TexturedQuad - 简化版贴图绘制 ====
-- 表格参数版：设置纹理与颜色后直接绘制矩形
function draw.TexturedQuad(tab)
	surface_SetTexture(tab.texture)
	surface_SetDrawColor(tab.color or color_white)
	surface_DrawTexturedRect(tab.x, tab.y, tab.w, tab.h)
end

-- ==== draw.NoTexture - 切换到纯白贴图 ====
-- 用于绘制纯色矩形前取消贴图状态（白色纹理与任意颜色混合即得该颜色）
function draw.NoTexture()
	surface_SetTexture( Tex_white )
end

-- ==== draw.RoundedBoxEx - 支持四角独立开关的圆角矩形 ====
-- a/b/c/d 分别控制 左上/右上/左下/右下 是否使用圆角纹理，为 false 时画直角
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
	surface_SetTextColor(outlinecolour.r, outlinecolour.g, outlinecolour.b, outlinecolour.a)
    
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
-- 动画相关优化保持不变（原版已是良好实现），在游戏初始化时安装说话动画函数
hook.Add("Initialize", "InstallFunctions_Buffed", function()
	-- ==== GAMEMODE:MouthMoveAnimation - 根据语音音量驱动嘴部 Flex 权重 ====
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

	-- ==== GAMEMODE:GrabEarAnimation - 根据打字状态驱动聊天手势动画 ====
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

-- 清空驾驶（drive）相关回调：本模式不使用的移动钩子替换为空函数以减少开销
local function empty() end
drive.Move = empty
drive.FinishMove = empty
drive.StartMove = empty

-- 加载完成提示（用于确认性能优化已生效）
print("[BuffedFPS] Optimized drawing functions loaded (v2 - Fixed Alignment).")