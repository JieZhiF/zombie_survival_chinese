-- ============================================================================
-- PHelp - 帮助/致谢界面
-- 包含 MakepHelp（帮助窗口，分页显示游戏指南）
-- 和 MakepCredits（致谢窗口，显示所有贡献者名单）
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 帮助窗口
-- [位置] MakepHelp() / GM:BuildHelpMenu()
-- [作用] 分页帮助文档，每页用 DHTML 渲染指南内容，底部致谢按钮
-- [常改] 窗口尺寸、HTML 模板、帮助数据
--
-- [区域] 致谢窗口
-- [位置] MakepCredits()
-- [作用] 逐行显示贡献者名单
-- [常改] 行布局、字体
-- ============================================================================

-- 帮助内容定义
GM.Help = {
{Name = "help_cat_introduction",
Content = "help_cont_introduction"},

{Name = "help_cat_survival",
Content = "help_cont_survival"},

{Name = "help_cat_barricading",
Content = "help_cont_barricading"},

{Name = "help_cat_upgrades",
Content = "help_cont_upgrades"},

{Name = "help_cat_being_a_zombie",
Content = "help_cont_being_a_zombie"}
}

-- ============================================================================
-- MakepCredits - 创建致谢窗口
-- 显示游戏制作人员名单
-- ============================================================================
function MakepCredits()
	PlayMenuOpenSound()

	local wid = math.min(ScrW(), 750)

	local y = 8

	local frame = vgui.Create("DEXRoundedFrame")
	frame:SetColorAlpha(230)
	frame:SetWide(wid)
	frame:SetTitle(" ")
	frame:SetKeyboardInputEnabled(false)

	local label = EasyLabel(frame, GAMEMODE.Name.." Credits", "ZSHUDFontNS", color_white)
	label:AlignTop(y)
	label:CenterHorizontal()
	y = y + label:GetTall() + 8

	-- 遍历贡献者列表
	for authorindex, authortab in ipairs(GAMEMODE.Credits) do
		local lineleft = EasyLabel(frame, string.Replace(authortab[1], "@", "(at)"), "ZSHUDFontSmallestNS", color_white)
		local linemid = EasyLabel(frame, "-", "ZSHUDFontSmallestNS", color_white)
		local lineright = EasyLabel(frame, authortab[3], "ZSHUDFontSmallestNS", color_white)
		local linesub
		if authortab[2] then
			linesub = EasyLabel(frame, authortab[2], "DefaultFont", color_white)
		end

		lineleft:AlignLeft(8)
		lineleft:AlignTop(y)
		lineright:AlignRight(8)
		lineright:AlignTop(y)
		linemid:CenterHorizontal()
		linemid:AlignTop(y)

		y = y + lineleft:GetTall()
		if linesub then
			linesub:AlignTop(y)
			linesub:AlignLeft(8)
			y = y + linesub:GetTall()
		end
		y = y + 10
	end

	frame:SetTall(y + 8)
	frame:Center()
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.15, 0)
	frame:MakePopup()
end

-- ============================================================================
-- MakepHelp - 创建帮助窗口
-- 使用 DHTML 渲染每个帮助类别的 HTML 内容
-- ============================================================================
function MakepHelp()
	PlayMenuOpenSound()

	if pHelp then
		pHelp:SetAlpha(0)
		pHelp:AlphaTo(255, 0.15, 0)
		pHelp:SetVisible(true)
		pHelp:MakePopup()
		return
	end

	local wide, tall = 500, 480

	local Window = vgui.Create("DFrame")
	Window:SetSize(wide, tall)
	Window:Center()
	Window:SetTitle(" ")
	Window:SetDraggable(false)
	Window:SetDeleteOnClose(false)
	Window:SetKeyboardInputEnabled(false)
	Window:SetCursor("pointer")
	pHelp = Window

	local label = EasyLabel(Window, translate.Get("help_title"), "ZSHUDFont", color_white)
	label:CenterHorizontal()
	label:AlignTop(8)

	-- 帮助内容分页属性表
	local propertysheet = vgui.Create("DPropertySheet", Window)
	propertysheet:StretchToParent(12, 52, 12, 64)

	-- 遍历每个帮助类别，用 HTML 渲染内容
	for _, helptab in ipairs(GAMEMODE.Help) do
		local htmlpanel = vgui.Create("DHTML", propertysheet)
		htmlpanel:StretchToParent(4, 4, 4, 24)
		htmlpanel:SetHTML([[<html>
		<head>
		<style type="text/css">
		body
		{
			font-family:tahoma;
			font-size:11px;
			color:white;
			background-color:black;
			width:]].. htmlpanel:GetWide() - 48 ..[[px;
		}
		div p
		{
			margin:10px;
			padding:2px;
		}
		</style>
		</head>
		<body>
<center><span style="font-size:22px;font-weight:bold;color:limegreen;text-decoration:underline;">Zombie Survival</span><br>
]]..translate.Get(helptab.Name)..[[</center><br><br><div>]]..translate.Get(helptab.Content)..[[</div>
</body>
</html>]])
		propertysheet:AddSheet(translate.Get(helptab.Name), htmlpanel, helptab.Icon, false, false)
	end

	Window:Center()
	Window:MakePopup()

	-- 致谢按钮
	local button = EasyButton(Window, "Credits", 8, 4)
	button:SetPos(wide - button:GetWide() - 12, tall - button:GetTall() - 12)
	button:SetText("Credits")
	button.DoClick = function(btn) MakepCredits() end

	gamemode.Call("BuildHelpMenu", Window, propertysheet)

	Window:SetAlpha(0)
	Window:AlphaTo(255, 0.15, 0)
	Window:MakePopup()
end

-- ============================================================================
-- BuildHelpMenu - 构建帮助菜单的回调（可由其他模块扩展）
-- ============================================================================
function GM:BuildHelpMenu(window, propertysheet)
end
