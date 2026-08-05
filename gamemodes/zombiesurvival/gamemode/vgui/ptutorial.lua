-- ============================================================================
-- PTutorial - 新手教程界面
-- 该图片显示在窗口左上角，角色名字放在图片正下方
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 教程主窗口
-- [位置] MakepTutorial()
-- [作用] 创建 DEXRoundedFrame 窗口，关闭时通知服务器完成教程
-- [常改] 窗口最大尺寸、背景透明度、淡入时长
--
-- [区域] 角色头像
-- [位置] RenderPage() 第 1 段
-- [作用] 左上角显示角色图片，名字位于正下方
-- [常改] 头像尺寸、图片路径、名字位置
--
-- [区域] 教程文字
-- [位置] TypewriteTextLines() / RenderPage() 第 2 段
-- [作用] 标题 + 逐行打字机效果的教程文本
-- [常改] 打字速度、行间距、文字宽度
--
-- [区域] 教学图片
-- [位置] RenderPage() 打字机完成回调
-- [作用] 文字全部显示后居中展示教学大图
-- [常改] 图片缩放比例、最低高度
--
-- [区域] 底部按钮
-- [位置] RenderPage() 第 3 段 / StyleTutorialButton()
-- [作用] 开始/下一步/跳过按钮，科幻风格三态绘制
-- [常改] 按钮文字、三态颜色、圆角、尺寸
--
-- [区域] 扫描线背景
-- [位置] MakepTutorial() 中 scanlinePanel
-- [作用] 内容区背景上的 CRT 扫描线装饰
-- [常改] 扫描线间距、颜色
-- ============================================================================
local TUTORIAL_CHARACTER_IMAGE_PATH = "zstutorial/laoda.png"
-- 教程页面数据
-- 每个页面包含：
--   type  : 页面标识，仅用于代码区分
--   texts : 该页逐行显示的占位文字，会依次以打字机效果出现
--   image : 该页正文下方显示的教学大图路径，填 nil 表示该页不显示图片
local TutorialPages = {
	{
		type = "intro",
		texts = {
			">我是牢大，欢迎来到僵尸生存！",
			">我将带你了解如何坠机",
			">点击开始按钮，进入下一步教程"
		},
		image = nil
	},
	{
		type = "step1",
		texts = {
			">首先是初始菜单",
			">它会在你第一次进入游戏时自动弹出",
			">你可以用它来获得初始武器"
		},
		image = "zstutorial/tutorial_step1.jpg"
	},
	{
		type = "step2",
		texts = {
			">接下来是游戏界面",
			">左下角显示你的生命值",
			">左上角角显示人数和你的积分"
		},
		image = "zstutorial/tutorial_step2.jpg"
	},
	{
		type = "step3",
		texts = {
			">然后是游戏内的天赋系统",
			">按下F3来打开天赋界面（人类）",
			">点击图标进入对应天赋树",
			">所有天赋点击即可生效",
			">鼠标不在按钮上可以右键退出"
		},
		image = "zstutorial/tutorial_step3.jpg"
	},
	{
		type = "step4",
		texts = {
			">最后是按下F4来打开设置",
			">你可以在这里调整，直至你觉得舒服为止",
		},
		image = "zstutorial/tutorial_step4.jpg"
	},
	{
		type = "step5",
		texts = {
			">好了，孩子们，牢大我要坠机了",
			">你一定要活下去啊！",
		},
		image = nil
	},
}

local TYPEWRITER_CHAR_DELAY = 0.03 -- 打字机效果：每显示一个字符的间隔时间（秒），数值越小打字速度越快
local TYPEWRITER_LINE_PAUSE = 0.25-- 打字机效果：每行文字完全显示后，开始下一行前的停顿时间（秒）
local AVATAR_SIZE = 128-- 角色头像尺寸（宽高相同，单位：像素）
local TEXT_MAX_WIDTH = 800 -- 教程文字区域最大宽度（像素），防止文字区域过宽影响阅读
-- 教程图片缩放比例（相对可用空间的 0~1)
local TUTORIAL_IMAGE_WIDE = 0.85 --宽度缩放
local TUTORIAL_IMAGE_TALL = 0.9 --高度缩放

-- ============================================================================
-- 界面布局配置
-- ============================================================================

local WINDOW_MAX_WIDTH = 1733-- 窗口最大尺寸（2K 屏下约为该尺寸，更小屏幕会自动收缩）
local WINDOW_MAX_HEIGHT = 1200
local WINDOW_SCREEN_MARGIN = 128 -- 窗口与屏幕边缘保留的最小间距（像素）
local MARGIN = 12 -- 内容区与窗口边缘的边距（像素）
local CONTENT_TOP_OFFSET = 32-- 内容区距离窗口顶部的偏移（像素，给标题栏留空间）
local BUTTON_HEIGHT = 64 -- 底部按钮高度（像素）
local BUTTON_GAP = 24 -- 底部按钮之间的间距（像素）
local BUTTON_AREA_EXTRA = 24 -- 按钮区域在按钮高度之外额外占用的空间（像素）
local BUTTON_BOTTOM_OFFSET = 30 -- 按钮底部距离窗口底边的距离（像素）

-- ============================================================================
-- 字体与文字配置
-- ============================================================================

local FONT_TITLE = "zstutorial" -- 标题与角色名字使用的字体
local FONT_TEXT = "zstutorial_text" -- 正文与按钮使用的字体
local TITLE_TEXT_PADDING = 4 -- 标题标签额外高度（像素），用于上下留白
local TITLE_TO_TEXT_SPACING = 10 -- 标题与正文之间的间距（像素）
local TEXT_LINE_GAP = 8 -- 正文每行之间的间距（像素）
local AVATAR_NAME_TEXT = "牢大" -- 角色名字（头像下方显示）
local TITLE_TEXT = "新手教程" -- 初始页标题文字
local BUTTON_TEXT_START = "开始" -- 第一页左侧按钮文字
local BUTTON_TEXT_SKIP = "跳过" -- 右侧“跳过”按钮文字
local BUTTON_TEXT_NEXT = "下一步" -- 后续页中间“下一步”按钮文字
local FADE_IN_DURATION = 0.15 -- 窗口淡入动画持续时间（秒）
local WINDOW_BACKGROUND_ALPHA = 240 -- 教程窗口背景透明度（0~255，255 为完全不透明）
local TEXT_LINE_HEIGHT_PADDING = 2 -- 打字机每行文字的固定高度 = 字体高度 + 该额外留白（像素），防止高度变化导致跳动
local AVATAR_NAME_GAP = 8 -- 头像与角色名字之间的间距（像素）
local MIN_IMAGE_HEIGHT = 64 -- 正文下方图片显示最低可用高度（像素），低于此值不显示图片
local IMAGE_TO_TEXT_GAP = 2-- 教学图片与上方文字之间的间距（像素），数值越大间距越大
local FIRST_PAGE_BUTTON_WIDTH_FACTOR = 1.75 -- 第一页按钮宽度计算系数：按钮总宽度 = (窗口宽 - contentX * 该系数 - 按钮间距) / 2. 数值小于 2 会让两个按钮整体更靠近窗口中央，大于 2 则更靠两边

-- ============================================================================
-- 按钮与 CRT 扫描线视觉效果配置（可选，仅影响外观）
-- ============================================================================

local BUTTON_CORNER_RADIUS = 10 -- 按钮圆角半径（像素）
local BUTTON_BORDER_COLOR = Color(130, 160, 190, 180) -- 统一描边颜色（淡钢蓝，与深色背景协调）
-- "开始"按钮三态颜色（深蓝灰底 + 青色倾向）
local BUTTON_COLOR_START_IDLE  = Color(25, 45, 70, 230)
local BUTTON_COLOR_START_HOVER = Color(40, 75, 115, 240)
local BUTTON_COLOR_START_PRESS = Color(20, 55, 90, 255)
-- "下一步"按钮三态颜色（深蓝灰底 + 青绿倾向）
local BUTTON_COLOR_NEXT_IDLE  = Color(25, 55, 65, 230)
local BUTTON_COLOR_NEXT_HOVER = Color(40, 90, 110, 240)
local BUTTON_COLOR_NEXT_PRESS = Color(20, 65, 85, 255)
-- "跳过"按钮三态颜色（深灰底 + 暗红倾向，视觉权重更低）
local BUTTON_COLOR_SKIP_IDLE  = Color(50, 40, 45, 230)
local BUTTON_COLOR_SKIP_HOVER = Color(75, 60, 65, 240)
local BUTTON_COLOR_SKIP_PRESS = Color(55, 40, 45, 255)
-- CRT 扫描线参数
local SCANLINE_SPACING = 4 -- 扫描线间距（像素）
local SCANLINE_COLOR = Color(50, 50, 50, 140) -- 扫描线颜色（深灰细线）

-- ============================================================================
-- StyleTutorialButton - 为底部按钮应用科幻风格自定义绘制
-- 圆角背景 + 空闲/悬停/按下三态颜色 + 描边 + 居中文字
-- ============================================================================
local function StyleTutorialButton(btn, idleColor, hoverColor, pressColor)
	btn:SetTextColor(color_white)
	btn.Paint = function(me, w, h)
		local bg = idleColor
		if me:IsDown() then
			bg = pressColor
		elseif me:IsHovered() then
			bg = hoverColor
		end
		-- 先画略大的圆角矩形作为描边，再在其上画背景，形成 1px 圆角边框
		draw.RoundedBox(BUTTON_CORNER_RADIUS, 0, 0, w, h, BUTTON_BORDER_COLOR)
		draw.RoundedBox(BUTTON_CORNER_RADIUS, 1, 1, w - 2, h - 2, bg)
		draw.SimpleText(me:GetText(), FONT_TEXT, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

-- ============================================================================
-- TypewriteTextLines - 打字机效果逐行显示文字
-- 使用一个隐藏的 Think 面板驱动，避免切换页面时遗留全局 timer。
-- 参数：父面板、文本数组、字体、颜色、X 坐标、起始 Y、宽度、行间距、
--       每行完成回调（参数：当前行 Label、下一行应使用的 Y 坐标）、
--       全部完成回调（参数：所有 Label 表）
-- ============================================================================
local function TypewriteTextLines(parent, texts, font, textcolor, x, startY, wide, lineGap, onLineFinished, onAllFinished)
	local currentLine = 1
	local labels = {}
	local charIndex = 0
	local nextCharTime = 0
	local nextLineTime = 0
	local state = "idle"
	-- 固定行高，避免打字过程中高度变化导致跳动
	local lineHeight = draw.GetFontHeight(font) + TEXT_LINE_HEIGHT_PADDING

	local controller = vgui.Create("Panel", parent)
	controller:SetSize(1, 1)
	controller:SetPos(0, 0)

	local function startLine()
		if currentLine > #texts then
			if onAllFinished then onAllFinished(labels) end
			controller:Remove()
			return
		end

		local fullText = texts[currentLine]
		local label = EasyLabel(parent, "", font, textcolor)
		label:SetPos(x, startY)
		label:SetWide(wide)
		label:SetTall(lineHeight)
		-- 单行固定高度，不自动换行/伸缩，避免跳动；文字在标签内水平居中
		label:SetWrap(false)
		label:SetContentAlignment(5)
		labels[currentLine] = label

		charIndex = 0
		nextCharTime = CurTime()
		state = "typing"
	end

	controller.Think = function(me)
		if state == "typing" then
			if CurTime() >= nextCharTime then
				local label = labels[currentLine]
				local fullText = texts[currentLine]
				charIndex = charIndex + 1

				if charIndex <= utf8.len(fullText) then
					label:SetText(utf8.sub(fullText, 1, charIndex))
					nextCharTime = CurTime() + TYPEWRITER_CHAR_DELAY
				else
					local nextY = startY + lineHeight + lineGap
					if onLineFinished then onLineFinished(label, nextY) end
					startY = nextY
					currentLine = currentLine + 1
					nextLineTime = CurTime() + TYPEWRITER_LINE_PAUSE
					state = "waiting"
				end
			end
		elseif state == "waiting" then
			if CurTime() >= nextLineTime then
				startLine()
			end
		end
	end

	startLine()
end

-- ============================================================================
-- MakepTutorial - 创建并显示教程窗口
-- ============================================================================
function MakepTutorial()
	PlayMenuOpenSound()

	if pTutorial and pTutorial:IsValid() then
		pTutorial:SetVisible(true)
		pTutorial:MakePopup()
		return
	end

	-- 在 2K(2560x1440) 屏幕上约为 WINDOW_MAX_WIDTH x WINDOW_MAX_HEIGHT，更小屏幕上自动收缩留出边距
	local wide = math.min(ScrW() - WINDOW_SCREEN_MARGIN, WINDOW_MAX_WIDTH)
	local tall = math.min(ScrH() - WINDOW_SCREEN_MARGIN, WINDOW_MAX_HEIGHT)

	local frame = vgui.Create("DEXRoundedFrame")
	frame:SetSize(wide, tall)
	frame:Center()
	frame:SetTitle(" ")
	frame:SetDraggable(false)
	frame:SetDeleteOnClose(true)
	frame:SetKeyboardInputEnabled(false)
	frame:SetColorAlpha(WINDOW_BACKGROUND_ALPHA)

	-- 关闭窗口时通知服务器已完成教程
	local oldClose = frame.Close
	frame.Close = function(me)
		net.Start(NET_MSG.TUTORIAL_DONE)
		net.SendToServer()

		if oldClose then
			oldClose(me)
		else
			me:Remove()
		end
	end

	pTutorial = frame

	-- 预计算布局参数，供扫描线跳过按钮区域使用
	local margin = MARGIN
	local contentX = margin
	local contentY = CONTENT_TOP_OFFSET
	local buttonHeight = BUTTON_HEIGHT
	local buttonAreaTall = buttonHeight + BUTTON_AREA_EXTRA
	local buttonY = tall - buttonHeight - BUTTON_BOTTOM_OFFSET

	-- 扫描线背景面板：覆盖内容区背景，位于 contentPanel 之后、子元素之前
	-- 这样扫描线只作为背景，不会覆盖头像、文字、图片和按钮
	local scanlinePanel = vgui.Create("Panel", frame)
	scanlinePanel:SetPos(contentX, contentY)
	scanlinePanel:SetSize(wide - contentX * 2, tall - contentY - buttonAreaTall)
	scanlinePanel.Paint = function(me, w, h)
		surface.SetDrawColor(SCANLINE_COLOR)
		for y = 0, h, SCANLINE_SPACING do
			surface.DrawLine(0, y, w, y)
		end
	end

	-- 内容面板：文字与图片放在这里，底部留给按钮
	-- 默认背景透明，子元素会遮住下方扫描线，空白处扫描线仍可见
	local contentPanel = vgui.Create("Panel", frame)
	contentPanel:SetPos(contentX, contentY)
	contentPanel:SetSize(wide - contentX * 2, tall - contentY - buttonAreaTall)

	-- 当前页码
	local currentPage = 1

	-- 底部按钮容器
	local buttonGap = BUTTON_GAP
	local startButton, nextButton, skipButton

	-- 渲染指定页面
	local function RenderPage(pageIndex)
		local page = TutorialPages[pageIndex]
		if not page then return end

		contentPanel:Clear()

		-- ------------------------------------------------------------------
		-- 1. 左上角：角色头像，名字放在头像正下方
		-- ------------------------------------------------------------------
		local avatarSize = AVATAR_SIZE
		local avatar = vgui.Create("DImage", contentPanel)
		avatar:SetPos(0, 0)
		avatar:SetSize(avatarSize, avatarSize)
		avatar:SetImage(TUTORIAL_CHARACTER_IMAGE_PATH)

		local nameLabel = EasyLabel(contentPanel, AVATAR_NAME_TEXT, FONT_TITLE, color_white)
		nameLabel:SizeToContents()
		nameLabel:SetPos((avatarSize - nameLabel:GetWide()) / 2, avatarSize + AVATAR_NAME_GAP)

		-- ------------------------------------------------------------------
		-- 2. 内容区居中：标题（仅初始页）+ 打字机效果的教程文本
		-- ------------------------------------------------------------------
		local textTop = 0
		-- 文字区域收窄并在内容区水平居中，同时避免与左侧头像重叠
		local textWide = math.min(contentPanel:GetWide() - margin * 2, TEXT_MAX_WIDTH)
		local textX = math.max(avatarSize + margin, (contentPanel:GetWide() - textWide) / 2)

		local textStartY = textTop

		-- 标题只在初始页（intro）显示
		if pageIndex == 1 then
			local titleHeight = draw.GetFontHeight(FONT_TITLE) + TITLE_TEXT_PADDING
			local title = EasyLabel(contentPanel, TITLE_TEXT, FONT_TITLE, color_white)
			title:SetPos(textX, textTop)
			title:SetWide(textWide)
			title:SetTall(titleHeight)
			title:SetContentAlignment(5)
			textStartY = textTop + titleHeight + TITLE_TO_TEXT_SPACING
		end

		local lastTextY = textStartY

		TypewriteTextLines(
			contentPanel,
			page.texts,
			FONT_TEXT,
			color_white,
			textX,
			textStartY,
			textWide,
			TEXT_LINE_GAP,
			function(label, nextY)
				lastTextY = nextY
			end,
			function(labels)
				-- 文字全部显示完成后，如果当前页有教程图片则显示
				if not page.image then return end

				local avatarColumnBottom = avatarSize + AVATAR_NAME_GAP + nameLabel:GetTall()
				local imageTop = math.max(lastTextY, avatarColumnBottom) + IMAGE_TO_TEXT_GAP
				local availableTall = contentPanel:GetTall() - imageTop - IMAGE_TO_TEXT_GAP
				local availableWide = contentPanel:GetWide() - MARGIN * 2

				if availableTall > MIN_IMAGE_HEIGHT then
					local imageWide = availableWide * TUTORIAL_IMAGE_WIDE
					local imageTall = availableTall * TUTORIAL_IMAGE_TALL
					local imageX = (contentPanel:GetWide() - imageWide) / 2
					local imageY = imageTop + (availableTall - imageTall) / 2

					local tutorialImage = vgui.Create("DImage", contentPanel)
					tutorialImage:SetPos(imageX, imageY)
					tutorialImage:SetSize(imageWide, imageTall)
					tutorialImage:SetImage(page.image)
				end
			end
		)

		-- ------------------------------------------------------------------
		-- 3. 更新底部按钮
		-- ------------------------------------------------------------------
		if IsValid(startButton) then startButton:Remove() end
		if IsValid(nextButton) then nextButton:Remove() end
		if IsValid(skipButton) then skipButton:Remove() end

		if pageIndex == 1 then
			-- 第一页：左侧“我要开始”，右侧“跳过”
			local buttonWide = (wide - contentX * FIRST_PAGE_BUTTON_WIDTH_FACTOR - buttonGap) / 2

			startButton = vgui.Create("DButton", frame)
			startButton:SetPos(contentX, buttonY)
			startButton:SetSize(buttonWide, buttonHeight)
			startButton:SetText(BUTTON_TEXT_START)
			startButton:SetFont(FONT_TEXT)
			startButton.DoClick = function()
				currentPage = currentPage + 1
				if currentPage > #TutorialPages then
					frame:Close()
				else
					RenderPage(currentPage)
				end
			end
			StyleTutorialButton(startButton, BUTTON_COLOR_START_IDLE, BUTTON_COLOR_START_HOVER, BUTTON_COLOR_START_PRESS)

			skipButton = vgui.Create("DButton", frame)
			skipButton:SetPos(contentX + buttonWide + buttonGap, buttonY)
			skipButton:SetSize(buttonWide, buttonHeight)
			skipButton:SetText(BUTTON_TEXT_SKIP)
			skipButton:SetFont(FONT_TEXT)
			skipButton.DoClick = function()
				frame:Close()
			end
			StyleTutorialButton(skipButton, BUTTON_COLOR_SKIP_IDLE, BUTTON_COLOR_SKIP_HOVER, BUTTON_COLOR_SKIP_PRESS)
		else
			-- 后续页：中间“下一步”，右侧“跳过”
			local buttonWide = (wide - contentX * 2 - buttonGap * 2) / 3

			nextButton = vgui.Create("DButton", frame)
			nextButton:SetPos(contentX + buttonWide + buttonGap, buttonY)
			nextButton:SetSize(buttonWide, buttonHeight)
			nextButton:SetText(BUTTON_TEXT_NEXT)
			nextButton:SetFont(FONT_TEXT)
			nextButton.DoClick = function()
				currentPage = currentPage + 1
				if currentPage > #TutorialPages then
					frame:Close()
				else
					RenderPage(currentPage)
				end
			end
			StyleTutorialButton(nextButton, BUTTON_COLOR_NEXT_IDLE, BUTTON_COLOR_NEXT_HOVER, BUTTON_COLOR_NEXT_PRESS)

			skipButton = vgui.Create("DButton", frame)
			skipButton:SetPos(contentX + buttonWide * 2 + buttonGap * 2, buttonY)
			skipButton:SetSize(buttonWide, buttonHeight)
			skipButton:SetText(BUTTON_TEXT_SKIP)
			skipButton:SetFont(FONT_TEXT)
			skipButton.DoClick = function()
				frame:Close()
			end
			StyleTutorialButton(skipButton, BUTTON_COLOR_SKIP_IDLE, BUTTON_COLOR_SKIP_HOVER, BUTTON_COLOR_SKIP_PRESS)
		end
	end

	RenderPage(currentPage)

	frame:SetAlpha(0)
	frame:AlphaTo(255, FADE_IN_DURATION, 0)
	frame:MakePopup()
end

-- ============================================================================
-- 关闭教程的便捷函数
-- ============================================================================
function ClosepTutorial()
	if pTutorial and pTutorial:IsValid() then
		pTutorial:Close()
	end
end
