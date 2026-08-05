-- ============================================================================
-- MainMenu - 主菜单界面
-- 这是 NOX 团队时期使用的主菜单，当前版本已不再使用
-- 包含"开始游戏"、"观战"、"帮助"、"指南"、"致谢"、"支持者"和"退出"按钮
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 主菜单窗口
-- [位置] GM:OpenMainMenu()
-- [作用] 创建全屏菜单：退出/支持者/致谢/指南/帮助/观战/开始按钮与底部致谢栏
-- [常改] 按钮文本、DockMargin、工具提示、背景
--
-- [区域] 菜单按钮组件
-- [位置] ZSMenuButton / PANEL:Init() / PANEL:Paint()
-- [作用] 通用的菜单按钮面板
-- [常改] 字体、对齐、绘制样式
-- ============================================================================

-- 游戏版本号
GM.REVISION = 4352

-- ============================================================================
-- OpenMainMenu - 打开主菜单
-- ============================================================================
function GM:OpenMainMenu()
	if MainMenu and MainMenu:IsValid() then
		MainMenu:MakePopup()
		return
	end

	-- 创建主菜单根面板
	MainMenu = vgui.Create("DEXRoundedPanel")
	MainMenu:SetCurve(false)
	MainMenu:SetColor(color_black_alpha220)
	MainMenu:Dock(FILL)
	MainMenu:DockPadding(0, 0, 0, 0)
	MainMenu:DockMargin(0, 0, 0, 0)

	-- 底部致谢栏
	local creditbar = vgui.Create("DEXRoundedPanel", MainMenu)
	creditbar:SetCurve(false)
	creditbar:SetColor(color_black_alpha220)
	creditbar:SetTall(40)
	creditbar:Dock(BOTTOM)
	creditbar:DockPadding(0, 8, 8, 8)

	local credittext = vgui.Create("DLabel", creditbar)
	credittext:SetFont("ZSScoreBoardSubTitle")
	credittext:SetTextColor(COLOR_LIGHTGRAY)
	credittext:SetText("Zombie Survival (r"..self.REVISION..") - created by William \"JetBoom\" Moodhe")
	credittext:SetContentAlignment(6)
	credittext:Dock(FILL)

	-- Tooltip section...

	-- 退出按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("QUIT")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(90, 8, 0, 220)
	button.Tooltip = "mainmenu_tooltip_quit"

	-- 支持者按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("BECOME A SUPPORTER")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(80, 8, 0, 0)
	button.Tooltip = "mainmenu_tooltip_supporter"

	-- 致谢按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("CREDITS")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(70, 8, 0, 0)
	button.Tooltip = "mainmenu_tooltip_credits"

	-- 指南按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("GUIDES")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(60, 8, 0, 0)
	button.Tooltip = "mainmenu_tooltip_guides"

	-- 帮助按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("HELP")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(50, 8, 0, 0)
	button.Tooltip = "mainmenu_tooltip_help"

	-- 观战按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("SPECTATE")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(40, 8, 0, 0)
	button.Tooltip = "mainmenu_tooltip_spectate"

	-- 开始游戏按钮
	button = vgui.Create("ZSMenuButton", MainMenu)
	button:SetText("PLAY")
	button:SizeToContents()
	button:Dock(BOTTOM)
	button:DockMargin(30, 8, 0, 0)
	button.Tooltip = "mainmenu_tooltip_play"

	MainMenu:MakePopup()
end

-- ============================================================================
-- ZSMenuButton - 菜单按钮面板
-- ============================================================================
local PANEL = {}

-- ============================================================================
-- Init - 初始化菜单按钮
-- ============================================================================
function PANEL:Init()
	self:SetContentAlignment(4)
	self:SetFont("ZSHUDFontSmall")
end

-- ============================================================================
-- Paint - 按钮绘制（空实现，沿用基类 Button 的默认样式）
-- ============================================================================
function PANEL:Paint()
end

vgui.Register("ZSMenuButton", PANEL, "Button")
