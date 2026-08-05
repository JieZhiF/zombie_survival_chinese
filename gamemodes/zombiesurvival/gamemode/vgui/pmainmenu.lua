-- ============================================================================
-- PMainMenu - 主菜单/帮助菜单界面（按 F1 或 ? 键打开）
-- 包含"帮助"、"玩家模型"、"玩家颜色"、"武器颜色"、"设置"、"武器库"、
-- "技能"、"致谢"和"关闭"按钮
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 帮助菜单
-- [位置] GM:ShowHelp() / HelpMenuPaint()
-- [作用] F1 打开的主菜单：标题 + 帮助/模型/颜色/设置/武器库/技能/致谢/关闭按钮
-- [常改] 按钮文本、按钮高度、间距
--
-- [区域] 玩家模型选择窗口
-- [位置] MakepPlayerModel() / SwitchPlayerModel()
-- [作用] 网格展示全部可用玩家模型，点击切换并写 cl_playermodel
-- [常改] 列数、格子尺寸、模型来源
--
-- [区域] 颜色选择窗口
-- [位置] MakepPlayerColor()
-- [作用] 玩家颜色与武器颜色两个颜色选择器，实时写入 ConVar
-- [常改] 窗口宽度、选择器尺寸
-- ============================================================================

-- 帮助菜单背景模糊绘制
local function HelpMenuPaint(self)
	Derma_DrawBackgroundBlur(self, self.Created)
	Derma_DrawBackgroundBlur(self, self.Created)
end

local pPlayerModel

-- ============================================================================
-- SwitchPlayerModel - 切换玩家模型
-- ============================================================================
local function SwitchPlayerModel(self)
	surface.PlaySound("buttons/button14.wav")
	RunConsoleCommand("cl_playermodel", self.m_ModelName)
	chat.AddText(COLOR_LIMEGREEN, translate.Format("mainmenu_ChangedPlayerModel", tostring(self.m_ModelName)))
 

	pPlayerModel:Close()
end

-- ============================================================================
-- MakepPlayerModel - 创建玩家模型选择窗口
-- ============================================================================
function MakepPlayerModel()
	if pPlayerModel and pPlayerModel:IsValid() then pPlayerModel:Remove() end

	PlayMenuOpenSound()

	local numcols = 8
	local wid = numcols * 68 + 24
	local hei = 400

	pPlayerModel = vgui.Create("DFrame")
	pPlayerModel:SetSkin("Default")
	pPlayerModel:SetTitle(translate.Get("mainmenu_PlayerModelSelection"))

	pPlayerModel:SetSize(wid, hei)
	pPlayerModel:Center()
	pPlayerModel:SetDeleteOnClose(true)

	-- 模型列表
	local list = vgui.Create("DPanelList", pPlayerModel)
	list:StretchToParent(8, 24, 8, 8)
	list:EnableVerticalScrollbar()

	local grid = vgui.Create("DGrid", pPlayerModel)
	grid:SetCols(numcols)
	grid:SetColWide(68)
	grid:SetRowHeight(68)

	-- 遍历所有可用玩家模型
	for name, mdl in pairs(player_manager.AllValidModels()) do
		local button = vgui.Create("SpawnIcon", grid)
		button:SetPos(0, 0)
		button:SetModel(mdl)
		button.m_ModelName = name
		button.OnMousePressed = SwitchPlayerModel
		grid:AddItem(button)
	end
	grid:SetSize(wid - 16, math.ceil(table.Count(player_manager.AllValidModels()) / numcols) * grid:GetRowHeight())

	list:AddItem(grid)

	pPlayerModel:SetSkin("Default")
	pPlayerModel:MakePopup()
end

-- ============================================================================
-- MakepPlayerColor - 创建玩家颜色/武器颜色选择窗口
-- ============================================================================
function MakepPlayerColor()
	if pPlayerColor and pPlayerColor:IsValid() then pPlayerColor:Remove() end

	PlayMenuOpenSound()

	pPlayerColor = vgui.Create("DFrame")
	pPlayerColor:SetWide(math.min(ScrW(), 500))
	pPlayerColor:SetTitle(" ")
	pPlayerColor:SetDeleteOnClose(true)

	local y = 8

	local label = EasyLabel(pPlayerColor, translate.Get("mainmenu_Colors"), "ZSHUDFont", color_white)
	label:SetPos((pPlayerColor:GetWide() - label:GetWide()) / 2, y)
	y = y + label:GetTall() + 8
	
	-- 玩家颜色选择器
	local lab = EasyLabel(pPlayerColor, translate.Get("mainmenu_PlayerColor"))
	
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	local colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_playercolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	local r, g, b = string.match(GetConVar("cl_playercolor"):GetString(), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	-- 武器颜色选择器
	lab = EasyLabel(pPlayerColor, translate.Get("mainmenu_WeaponColor"))

	lab:SetPos(8, y)
	y = y + lab:GetTall()

	colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_weaponcolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	r, g, b = string.match(GetConVar("cl_weaponcolor"):GetString(), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	pPlayerColor:SetTall(y + 8)
	pPlayerColor:Center()
	pPlayerColor:MakePopup()
end

-- ============================================================================
-- ShowHelp - 显示主帮助菜单
-- ============================================================================
function GM:ShowHelp()
	if self.HelpMenu and self.HelpMenu:IsValid() then
		self.HelpMenu:Remove()
	end

	PlayMenuOpenSound()

	local screenscale = BetterScreenScale()
	local menu = vgui.Create("Panel")
	menu:SetSize(screenscale * 420, ScrH())
	menu:Center()
	menu.Paint = HelpMenuPaint
	menu.Created = SysTime()

	local header = EasyLabel(menu, self.Name, "ZSHUDFont")
	header:SetContentAlignment(8)
	header:DockMargin(0, ScrH() * 0.25, 0, 64)
	header:Dock(TOP)

	local buttonhei = 32 * screenscale

	-- 帮助按钮
	local but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_Help"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepHelp() end
	
	-- 玩家模型按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_PlayerModel"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepPlayerModel() end
	
	-- 玩家颜色按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_PlayerColor"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepPlayerColor() end
	
	-- 设置按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_Options"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepOptions() end
	
	-- 武器数据库按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_WeaponDatabase"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepWeapons() end
	
	-- 技能按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_Skills"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() GAMEMODE:ToggleSkillWeb() end
	
	-- 致谢按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_Credits"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepCredits() end
	
	-- 关闭按钮
	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText(translate.Get("mainmenu_Close"))
	but:SetTall(buttonhei)
	but:DockMargin(0, 24, 0, 0)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() menu:Remove() end
	

	menu:MakePopup()
end
