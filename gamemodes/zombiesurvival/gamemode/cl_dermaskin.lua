--[[
	该脚本文件定义了Garry's Mod中 "Zombie Survival" 游戏模式的自定义Derma皮肤.
	Derma是Garry's Mod的默认GUI工具包,用于创建窗口,按钮,列表等用户界面元素.
	此皮肤文件通过重写默认的绘制函数和颜色,为游戏提供了独特的外观和感觉.
]]

-- 强制游戏模式使用此Derma皮肤.
-- 每当Derma需要知道使用哪个皮肤时,它都会调用这个钩子.
-- 返回 "zombiesurvival" 会告诉Derma加载下面定义的皮肤.
function GM:ForceDermaSkin()
	return "zombiesurvival"
end

-- 创建一个名为SKIN的本地表,用于存放皮肤的所有定义.
local SKIN = {}

-- 皮肤的显示名称.
SKIN.PrintName = "Zombie Survival Derma Skin"
-- 皮肤的作者.
SKIN.Author = "William \"JetBoom\" Moodhe"
-- 此皮肤兼容的Derma版本.
SKIN.DermaVersion = 1

-- 定义皮肤使用的基础颜色.
-- 通用背景颜色.
SKIN.bg_color = Color(25, 25, 25, 120)         -- 主要背景色 (深灰,半透明)
-- 非活动或"睡眠"状态的背景颜色.
SKIN.bg_color_sleep = Color(40, 40, 40, 255)
-- 较暗的背景颜色,用于需要更深背景的元素.
SKIN.bg_color_dark = Color(30, 30, 30, 180)
-- 较亮的背景颜色,用于高亮或需要更突出显示的元素.

SKIN.bg_color_bright = Color(55, 55, 55, 240)  -- 亮一点的背景色 (用于悬停等)
SKIN.text_color_normal = Color(220, 220, 220, 255) -- 普通文本颜色 (亮灰色)
SKIN.text_color_bright = Color(255, 255, 255, 255) -- 高亮文本颜色 (纯白)
SKIN.border_color = Color(10, 10, 10, 255)       -- 边框颜色
SKIN.highlight_color = Color(0, 150, 255, 255)   -- 高亮/选中项颜色 (示例为蓝色,可换成图片中的白色或绿色)
SKIN.OutlineColor = Color(255,255,255,255)
-- 为不同类型的控件定义颜色.
SKIN.Colors = {}
SKIN.Colors.Panel = {}
-- 定义普通面板的颜色.
SKIN.Colors.Panel.Normal = Color(35, 35, 35, 220)
-- 绘制通用面板(Panel)的函数.
-- @param panel 要绘制的面板对象.
-- @param w 面板的宽度.
-- @param h 面板的高度.
function SKIN:PaintPanel(panel, w, h)
	-- 如果面板的m_bBackground属性为false,则不绘制背景.
	if not panel.m_bBackground then return end

	-- 设置绘制颜色为面板的普通颜色.
	surface.SetDrawColor(self.Colors.Panel.Normal)
	-- 绘制一个覆盖整个面板的矩形作为背景.
	surface.DrawRect(0, 0, w, h)
end

-- 被注释掉的工具提示颜色定义.
--SKIN.tooltip = Color(190, 190, 190, 230)

-- 定义框架(Frame)的背景颜色.
local color_frame_background = Color(45, 45, 45, 230)
SKIN.color_frame_background = color_frame_background
-- 定义框架的边框颜色.
SKIN.color_frame_border = Color(0, 80, 0, 255)

-- 定义文本输入框(TextEntry)的颜色.
-- 文本颜色.
SKIN.colTextEntryText = Color(200, 200, 200)
-- 文本高亮(选中时)的颜色.
SKIN.colTextEntryTextHighlight = Color(30, 255, 0)
-- 文本输入框的边框颜色.
SKIN.colTextEntryTextBorder = Color(70, 90, 70, 255)

-- 定义属性表(PropertySheet)和标签页(Tab)的颜色.
-- 属性表的背景颜色.
SKIN.colPropertySheet = Color(30, 30, 30, 255)
-- 活动标签页的颜色,与属性表相同.
SKIN.colTab = Color(55, 55, 55, 255)          -- 活动标签页颜色
-- 非活动标签页的颜色.
SKIN.colTabInactive = Color(35, 35, 35, 255) -- 非活动标签页颜色
-- 标签页的阴影颜色.
SKIN.colTabShadow = Color(20, 30, 20, 255)
-- 标签页上的文本颜色.
SKIN.colTabText	= Color(240, 255, 240, 255)
-- 非活动标签页上的文本颜色.
SKIN.colTabTextInactive	= Color(240, 255, 240, 120)

--[[ 一段被注释掉的旧的文本输入框颜色定义.
SKIN.colTextEntryBG	= Color( 240, 240, 240, 255 )
SKIN.colTextEntryBorder	= Color( 20, 20, 20, 255 )
SKIN.colTextEntryText = Color( 20, 20, 20, 255 )
SKIN.colTextEntryTextHighlight = Color( 20, 200, 250, 255 )
SKIN.colTextEntryTextCursor	= Color( 0, 0, 100, 255 )]]

-- 2. 修改绘制函数
function SKIN:PaintPropertySheet(panel, w, h)
	-- 只绘制一个简单的背景
	surface.SetDrawColor(SKIN.bg_color)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintTab(panel, w, h)
	-- 非活动标签页
	surface.SetDrawColor(SKIN.colTabInactive)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintActiveTab(panel, w, h)
	-- 活动标签页
	surface.SetDrawColor(SKIN.colTab)
	surface.DrawRect(0, 0, w, h)

	-- 为活动标签页添加一个下划线以突出显示
	surface.SetDrawColor(SKIN.highlight_color)
	surface.DrawRect(0, h - 2, w, 2)
end

--[[ 另一段被注释掉的文本输入框颜色定义.
SKIN.color_textentry_background = Color(40, 40, 40, 255)
SKIN.color_textentry_border = Color(70, 90, 70, 255)]]

-- 预先加载绘制框架所需的纹理ID,以提高性能.
local texCorner = surface.GetTextureID("zombiesurvival/circlegradient") -- 角落的渐变纹理
local texUpEdge = surface.GetTextureID("gui/gradient_up") -- 顶部边缘的渐变纹理
local texDownEdge = surface.GetTextureID("gui/gradient_down") -- 底部边缘的渐变纹理
local texRightEdge = surface.GetTextureID("gui/gradient") -- 右侧边缘的渐变纹理

-- 一个通用的绘制函数,用于创建带有渐变边缘和圆角的框架.
-- @param panel 面板对象
-- @param x x坐标
-- @param y y坐标
-- @param wid 宽度
-- @param hei 高度
-- @param edgesize 边缘大小
-- 彻底替换掉旧的 SKIN:PaintFrame 和 PaintGenericFrame
function SKIN:PaintFrame(panel, w, h)
	-- 绘制一个半透明的深色背景
	surface.SetDrawColor(SKIN.color_frame_background)
	surface.DrawRect(0, 0, w, h)

	-- 绘制一个细细的顶部边框作为标题栏的分割线
	surface.SetDrawColor(SKIN.border_color)
	surface.DrawRect(0, 24, w, 1) -- 假设标题栏高度为24

	-- (可选) 绘制整个窗口的轮廓
	surface.SetDrawColor(SKIN.border_color)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PaintGenericFrame(panel, x, y, wid, hei, edgesize)
	edgesize = edgesize or math.ceil(math.min(hei * 0.1, math.min(16, wid * 0.1)))
	local hedgesize = edgesize * 0.5
	DisableClipping(true)
	surface.DrawRect(x, y, wid, hei)
	surface.SetTexture(texUpEdge)
	surface.DrawTexturedRect(x, y - edgesize, wid, edgesize)
	surface.SetTexture(texDownEdge)
	surface.DrawTexturedRect(x, y + hei, wid, edgesize)
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRect(wid, y, edgesize, hei)
	surface.DrawTexturedRectRotated(x + hedgesize * -1, y + hei * 0.5, edgesize, hei, 180)
	surface.SetTexture(texCorner)
	surface.DrawTexturedRect(x - edgesize, y - edgesize, edgesize, edgesize)
	surface.DrawTexturedRectRotated(x + wid + hedgesize, y - hedgesize, edgesize, edgesize, 270)
	surface.DrawTexturedRectRotated(x + wid + hedgesize, y + hei + hedgesize, edgesize, edgesize, 180)
	surface.DrawTexturedRectRotated(x - hedgesize, y + hei + hedgesize, edgesize, edgesize, 90)
	DisableClipping(false)
end
--[[ 一段被注释掉的旧的绘制函数.
-- 绘制边框的函数.
function SKIN:DrawBorder(x, y, w, h, border)
	surface.SetDrawColor(border)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.SetDrawColor(border.r * 0.75, border.g * 0.75, border.b * 0.5, border.a)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
	surface.SetDrawColor(border.r * 0.5, border.g * 0.5, border.b * 0.5, border.a)
	surface.DrawOutlinedRect(x + 2, y + 2, w - 4, h - 4)
end

-- 绘制工具提示(Tooltip)的函数.
function SKIN:PaintTooltip(panel)
	local w, h = panel:GetSize()

	DisableClipping(true)

	self:DrawGenericBackground(0, 0, w, h, self.tooltip)
	panel:DrawArrow(0, 0)

	DisableClipping(false)
end

-- 绘制按钮(Button)的函数.
function SKIN:PaintButton(panel)
	local w, h = panel:GetSize()

	if panel.m_bBackground then
		local col = self.control_color
		if panel:GetDisabled() then
			col = self.control_color_dark
		elseif panel.Depressed then
			col = self.control_color_active
		elseif panel.Hovered then
			col = self.control_color_highlight
		end

		draw.RoundedBox(8, 0, 0, w, h, col)
	end
end]]

-- 这部分似乎是为GWEN GUI系统(一个替代Derma的系统)定义的颜色.
-- GWEN.TextureColor从一个纹理图谱(spritesheet)中获取颜色.
SKIN.Colours = {}

SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive			= GWEN.TextureColor( 4 + 8 * 0, 508 );
SKIN.Colours.Window.TitleInactive		= GWEN.TextureColor( 4 + 8 * 1, 508 );

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal				= Color(200, 200, 200, 220)
SKIN.Colours.Button.Hover				= Color(255, 255, 255, 220)
SKIN.Colours.Button.Down				= Color(255, 255, 255, 255)
SKIN.Colours.Button.Disabled			= Color(160, 160, 160, 220)

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal			= GWEN.TextureColor( 4 + 8 * 4, 508 );
SKIN.Colours.Tab.Active.Hover			= GWEN.TextureColor( 4 + 8 * 5, 508 );
SKIN.Colours.Tab.Active.Down			= GWEN.TextureColor( 4 + 8 * 4, 500 );
SKIN.Colours.Tab.Active.Disabled		= GWEN.TextureColor( 4 + 8 * 5, 500 );

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal		= GWEN.TextureColor( 4 + 8 * 6, 508 );
SKIN.Colours.Tab.Inactive.Hover			= GWEN.TextureColor( 4 + 8 * 7, 508 );
SKIN.Colours.Tab.Inactive.Down			= GWEN.TextureColor( 4 + 8 * 6, 500 );
SKIN.Colours.Tab.Inactive.Disabled		= GWEN.TextureColor( 4 + 8 * 7, 500 );

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default				= GWEN.TextureColor( 4 + 8 * 8, 508 );
SKIN.Colours.Label.Bright				= GWEN.TextureColor( 4 + 8 * 9, 508 );
SKIN.Colours.Label.Dark					= GWEN.TextureColor( 4 + 8 * 8, 500 );
SKIN.Colours.Label.Highlight			= GWEN.TextureColor( 4 + 8 * 9, 500 );

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines					= GWEN.TextureColor( 4 + 8 * 10, 508 );		---- !!!
SKIN.Colours.Tree.Normal				= GWEN.TextureColor( 4 + 8 * 11, 508 );
SKIN.Colours.Tree.Hover					= GWEN.TextureColor( 4 + 8 * 10, 500 );
SKIN.Colours.Tree.Selected				= GWEN.TextureColor( 4 + 8 * 11, 500 );

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal			= GWEN.TextureColor( 4 + 8 * 12, 508 );
SKIN.Colours.Properties.Line_Selected		= GWEN.TextureColor( 4 + 8 * 13, 508 );
SKIN.Colours.Properties.Line_Hover			= GWEN.TextureColor( 4 + 8 * 12, 500 );
SKIN.Colours.Properties.Title				= GWEN.TextureColor( 4 + 8 * 13, 500 );
SKIN.Colours.Properties.Column_Normal		= GWEN.TextureColor( 4 + 8 * 14, 508 );
SKIN.Colours.Properties.Column_Selected		= GWEN.TextureColor( 4 + 8 * 15, 508 );
SKIN.Colours.Properties.Column_Hover		= GWEN.TextureColor( 4 + 8 * 14, 500 );
SKIN.Colours.Properties.Border				= GWEN.TextureColor( 4 + 8 * 15, 500 );
SKIN.Colours.Properties.Label_Normal		= GWEN.TextureColor( 4 + 8 * 16, 508 );
SKIN.Colours.Properties.Label_Selected		= GWEN.TextureColor( 4 + 8 * 17, 508 );
SKIN.Colours.Properties.Label_Hover			= GWEN.TextureColor( 4 + 8 * 16, 500 );

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header				= GWEN.TextureColor( 4 + 8 * 18, 500 );
SKIN.Colours.Category.Header_Closed			= GWEN.TextureColor( 4 + 8 * 19, 500 );
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text				= GWEN.TextureColor( 4 + 8 * 20, 508 );
SKIN.Colours.Category.Line.Text_Hover		= GWEN.TextureColor( 4 + 8 * 21, 508 );
SKIN.Colours.Category.Line.Text_Selected	= GWEN.TextureColor( 4 + 8 * 20, 500 );
SKIN.Colours.Category.Line.Button			= GWEN.TextureColor( 4 + 8 * 21, 500 );
SKIN.Colours.Category.Line.Button_Hover		= GWEN.TextureColor( 4 + 8 * 22, 508 );
SKIN.Colours.Category.Line.Button_Selected	= GWEN.TextureColor( 4 + 8 * 23, 508 );
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text				= GWEN.TextureColor( 4 + 8 * 22, 500 );
SKIN.Colours.Category.LineAlt.Text_Hover		= GWEN.TextureColor( 4 + 8 * 23, 500 );
SKIN.Colours.Category.LineAlt.Text_Selected		= GWEN.TextureColor( 4 + 8 * 24, 508 );
SKIN.Colours.Category.LineAlt.Button			= GWEN.TextureColor( 4 + 8 * 25, 508 );
SKIN.Colours.Category.LineAlt.Button_Hover		= GWEN.TextureColor( 4 + 8 * 24, 500 );
SKIN.Colours.Category.LineAlt.Button_Selected	= GWEN.TextureColor( 4 + 8 * 25, 500 );

SKIN.Colours.TooltipText	= GWEN.TextureColor( 4 + 8 * 26, 500 );

-- 这是当前皮肤中实际使用的按钮绘制函数.
-- 这个函数会为所有按钮（包括 DComboBox 下拉菜单中的选项）进行绘制
function SKIN:PaintButton(panel, w, h)
	if not panel.m_bBackground then return end

	-- 1. 定义默认的背景色和文本颜色
	local bgColor = SKIN.bg_color -- 默认背景颜色
	local textColor = Color(220, 220, 220, 255) -- << 修改这里：未选中项的默认文本颜色

	if panel.Depressed or panel:IsSelected() then
		-- 按下或选中状态 (您图片中高亮的“医疗用品”就属于这个状态)
		bgColor = SKIN.highlight_color -- 这就是您图片里那个蓝色
		textColor = Color(255, 255, 255, 255) -- << 修改这里：选中项的文本颜色（当前是白色）

	elseif panel.Hovered then
		-- 悬停状态 (鼠标移到选项上但未点击)
		-- 注意：在您的代码中，悬停状态会覆盖默认状态，但不会覆盖选中状态
		bgColor = SKIN.bg_color_bright
		textColor = Color(255, 255, 255, 255) -- << 修改这里：悬停项的文本颜色
	end

	-- 3. 绘制背景
	surface.SetDrawColor(bgColor)
	surface.DrawRect(0, 0, w, h)

	-- 绘制悬停时的边框
	if panel.Hovered and not panel:IsSelected() then -- 最好在选中时不要绘制边框，避免重叠
		surface.SetDrawColor(SKIN.OutlineColor)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	-- 4. 应用最终计算出的文本颜色
	-- 这行代码至关重要，它会将上面逻辑中确定的 textColor 应用到按钮上
	panel:SetTextColor(textColor)

end
-- 绘制下拉菜单(ComboBox)的向下箭头,特别用于职业选择.
-- 这个函数名表明它可能是一个特定用途的重写.
function SKIN:PaintComboDownArrowClassSel(panel, w, h)
	-- 使用正弦函数创建一个上下浮动的动画效果.
	local y = math.sin(UnPredictedCurTime() * 3) * 5 * (w/15) - 1

	-- 根据下拉菜单的状态,使用不同的纹理来绘制箭头.
	-- 这是一个复杂的纹理系统,可能依赖于另一个未在此处定义的表 `self.tex`.
	if panel.ComboBox:GetDisabled() then
		return self.tex.Input.ComboBox.Button.Disabled(0, 0, w, h)
	end

	if panel.ComboBox.Depressed or panel.ComboBox:IsMenuOpen() then
		return self.tex.Input.Slider.H.Down(0, y, w, h)
	end

	if panel.ComboBox.Hovered then
		return self.tex.Input.Slider.H.Hover(0, y, w, h)
	end

	self.tex.Input.Slider.H.Normal(0, y, w, h)
end


--[[
	绘制下拉框主体 (DComboBox)
]]
function SKIN:PaintComboBox(panel, w, h)
	-- 1. 根据状态定义背景和文本颜色
	local bgColor = SKIN.bg_color or Color(45, 45, 45, 180)
	local textColor = Color(200, 200, 200, 255) -- << 添加：默认状态的文本颜色

	if (panel:GetDisabled()) then
		-- 如果控件被禁用
		bgColor = Color(50, 50, 50, 150)
		textColor = Color(100, 100, 100) -- << 添加：禁用状态的文本颜色

	elseif (panel.Hovered or panel:IsMenuOpen()) then
		-- 如果鼠标悬停或菜单已打开
		bgColor = SKIN.bg_color_bright or Color(65, 65, 65, 255)
		textColor = Color(255, 255, 255, 255) -- << 添加：悬停状态的文本颜色
	end

	-- 2. 绘制背景
	surface.SetDrawColor(bgColor)
	surface.DrawRect(0, 0, w, h)

	-- 3. 绘制边框
	surface.SetDrawColor(SKIN.border_color or Color(80, 80, 80, 255))
	surface.DrawOutlinedRect(0, 0, w, h)
	
	-- 4. 应用文本颜色 (这是最关键的一步)
	-- 这个函数会告诉 DComboBox 它内部的那个 DLabel 应该用什么颜色来显示文字
	panel:SetTextColor(textColor)
end
--[[
	绘制下拉框的箭头 (DComboBoxDownArrow)
]]
function SKIN:PaintComboBoxDownArrow(panel, w, h)
	-- 定义三角形的大小和颜色
	local size = 4 -- 三角形边长的一半
	local color = Color(200, 200, 200, 255)

	-- 鼠标悬停或下拉菜单打开时,箭头更亮
	if (panel.ComboBox.Hovered or panel.ComboBox:IsMenuOpen()) then
		color = Color(255, 255, 255, 255)
	end
	-- 计算三角形的三个顶点坐标,使其居中
	local x, y = w / 2, h / 2
	local vertices = {
		{ x = x - size, y = y - size / 2 },
		{ x = x + size, y = y - size / 2 },
		{ x = x,        y = y + size / 2 }
	}

	-- 绘制三角形
	surface.SetDrawColor(color)
	surface.DrawPoly(vertices)
end

--[[
	绘制弹出菜单的背景 (DMenu)
]]
function SKIN:PaintMenu(panel, w, h)
	-- 绘制一个简单的深色背景
	surface.SetDrawColor(SKIN.bg_color_dark or Color(30, 30, 30, 100))
	surface.DrawRect(0, 0, w, h)

	-- 绘制边框
	surface.SetDrawColor(SKIN.border_color or Color(80, 80, 80, 255))
	surface.DrawOutlinedRect(0, 0, w, h)
end

--[[
	绘制弹出菜单中的每一个选项 (DMenuOption)
]]
function SKIN:PaintMenuOption(panel, w, h)
	-- 如果鼠标悬停在这个选项上
	if (panel.Hovered) then
		-- 绘制一个亮色的背景作为高亮
		surface.SetDrawColor(SKIN.highlight_color or Color(0, 150, 255, 255)) 
		surface.DrawRect(0, 0, w, h)
	end
end
-- 最后,将整个SKIN表注册到Derma系统中.
-- "zombiesurvival" 是皮肤的内部名称.
-- 第二个参数是皮肤的描述.
-- SKIN 是包含所有皮肤数据的表.
-- "Default" 指定此皮肤继承自默认皮肤,这意味着任何未在此处定义的函数或颜色都将使用默认皮肤的设置.
derma.DefineSkin("zombiesurvival", "The default Derma skin for Zombie Survival", SKIN, "Default")