-- ============================================================================
-- PClassSelect - 僵尸职业选择界面（按 F3 打开）
-- 包含 ClassSelect（主面板）、ClassButton（职业按钮）和 ClassInfo（悬停描述）
-- 支持普通僵尸/BOSS切换、波次解锁和进化版本显示
-- ============================================================================

-- 创建客户端变量保存选择的 BOSS 职业
CreateClientConVar("zs_bossclass", "", true, true)

-- 主窗口和悬停信息窗口
local Window
local HoveredClassWindow

-- ============================================================================
-- CreateHoveredClassWindow - 创建鼠标悬停时显示的职业详情窗口
-- ============================================================================
local function CreateHoveredClassWindow(classtable)
	if HoveredClassWindow and HoveredClassWindow:IsValid() then
		HoveredClassWindow:Remove()
	end

	HoveredClassWindow = vgui.Create("ClassInfo")
	HoveredClassWindow:SetSize(ScrW() * 0.5, 128)
	HoveredClassWindow:CenterHorizontal()
	HoveredClassWindow:MoveBelow(Window, 32)
	HoveredClassWindow:SetClassTable(classtable)
end

-- ============================================================================
-- OpenClassSelect - 打开职业选择界面
-- ============================================================================
function GM:OpenClassSelect()
	if Window and Window:IsValid() then Window:Remove() end

	Window = vgui.Create("ClassSelect")
	Window:SetAlpha(0)
	Window:AlphaTo(255, 0.1)

	Window:MakePopup()

	Window:InvalidateLayout()

	PlayMenuOpenSound()
end

-- ============================================================================
-- ClassSelect 主面板
-- ============================================================================
local PANEL = {}

PANEL.Rows = 2

local bossmode = false

-- BOSS/僵尸模式切换按钮点击
local function BossTypeDoClick(self)
	bossmode = not bossmode
	GAMEMODE:OpenClassSelect()
end

-- ============================================================================
-- Init - 初始化职业选择面板
-- ============================================================================
function PANEL:Init()
	self.ClassButtons = {}

	-- 切换 BOSS/僵尸模式的按钮
	self.ClassTypeButton = EasyButton(nil, translate.Get(bossmode and "zombieselect_OpenZombiePanel" or "zombieselect_OpenBossPanel"), 8, 4)

	self.ClassTypeButton:SetFont("ZSHUDFontSmall")
	self.ClassTypeButton:SizeToContents()
	self.ClassTypeButton.DoClick = BossTypeDoClick
	
	-- 关闭按钮
	self.CloseButton = EasyButton(nil, translate.Get("zombieselect_Close"), 8, 4)
	
	self.CloseButton:SetFont("ZSHUDFontSmall")
	self.CloseButton:SizeToContents()
	self.CloseButton.DoClick = function() Window:Remove() end

	-- 职业按钮网格
	self.ButtonGrid = vgui.Create("DGrid", self)
	self.ButtonGrid:SetContentAlignment(5)
	self.ButtonGrid:Dock(FILL)
	local already_added = {}
	local use_better_versions = GAMEMODE:ShouldUseBetterVersionSystem()

	-- 遍历所有僵尸职业，创建可用的职业按钮
	for i=1, #GAMEMODE.ZombieClasses do
		local classtab = GAMEMODE.ZombieClasses[GAMEMODE:GetBestAvailableZombieClass(i)]

		if classtab and not classtab.Disabled and not already_added[classtab.Index] then
			already_added[classtab.Index] = true

			local ok
			if bossmode then
				ok = classtab.Boss
			else
				ok = not classtab.Boss and
					(not classtab.Hidden or classtab.CanUse and classtab:CanUse(MySelf)) and
					(not GAMEMODE.ObjectiveMap or classtab.Unlocked)
			end

			if ok then
				if not use_better_versions or not classtab.BetterVersionOf or GAMEMODE:IsClassUnlocked(classtab.Index) then
					local button = vgui.Create("ClassButton")
					button:SetClassTable(classtab)
					button.Wave = classtab.Wave or 1

					table.insert(self.ClassButtons, button)

					self.ButtonGrid:AddItem(button)
				end
			end
		end
	end

	self.ButtonGrid:SortByMember("Wave")
	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局职业按钮网格
-- ============================================================================
function PANEL:PerformLayout()
	if #self.ClassButtons < 8 then self.Rows = 1 end

	local cols = math.ceil(#self.ClassButtons / self.Rows)
	local cell_size = ScrW() / cols
	cell_size = math.min(ScrW() / 7, cell_size)

	self:SetSize(ScrW(), self.Rows * cell_size)
	self:CenterHorizontal()
	self:CenterVertical(0.35)

	self.ClassTypeButton:MoveAbove(self, 16)
	self.ClassTypeButton:CenterHorizontal()

	self.CloseButton:MoveAbove(self, 16)
	self.CloseButton:CenterHorizontal(0.9)
	self.ButtonGrid:SetCols(cols)
	self.ButtonGrid:SetColWide(cell_size)
	self.ButtonGrid:SetRowHeight(cell_size)
end

-- ============================================================================
-- OnRemove - 清理按钮
-- ============================================================================
function PANEL:OnRemove()
	self.ClassTypeButton:Remove()
	self.CloseButton:Remove()
end

-- 渐变纹理
local texUpEdge = surface.GetTextureID("gui/gradient_up")
local texDownEdge = surface.GetTextureID("gui/gradient_down")

-- ============================================================================
-- Paint - 绘制背景半透明层和边缘渐变
-- ============================================================================
function PANEL:Paint()
	local wid, hei = self:GetSize()
	local edgesize = 16

	DisableClipping(true)
	surface.SetDrawColor(Color(0, 0, 0, 220))
	surface.DrawRect(0, 0, wid, hei)
	surface.SetTexture(texUpEdge)
	surface.DrawTexturedRect(0, -edgesize, wid, edgesize)
	surface.SetTexture(texDownEdge)
	surface.DrawTexturedRect(0, hei, wid, edgesize)
	DisableClipping(false)

	return true
end

vgui.Register("ClassSelect", PANEL, "Panel")

-- ============================================================================
-- ClassButton - 单个职业选择按钮
-- ============================================================================
PANEL = {}

-- ============================================================================
-- Init - 初始化职业按钮
-- ============================================================================
function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetContentAlignment(5)

	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("ZSHUDFontSmaller")
	self.NameLabel:SetAlpha(170)

	self.Image = vgui.Create("DImage", self)

	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局按钮内的图标和名称
-- ============================================================================
function PANEL:PerformLayout()
	local cell_size = self:GetParent():GetColWide()

	self:SetSize(cell_size, cell_size)

	self.Image:SetSize(cell_size * 0.75, cell_size * 0.75)
	self.Image:AlignTop(8)
	self.Image:CenterHorizontal()

	self.NameLabel:SizeToContents()
	self.NameLabel:AlignBottom(8)
	self.NameLabel:CenterHorizontal()
end

-- ============================================================================
-- SetClassTable - 设置职业数据
-- ============================================================================
function PANEL:SetClassTable(classtable)
	self.ClassTable = classtable

	local len = #translate.Get(classtable.TranslationName)

	self.NameLabel:SetText(translate.Get(classtable.TranslationName))
	self.NameLabel:SetFont(len > 15 and "ZSHUDFontTiny" or len > 11 and "ZSHUDFontSmallest" or "ZSHUDFontSmaller")

	self.Image:SetImage(classtable.Icon)
	self.Image:SetImageColor(classtable.IconColor or color_white)

	self:InvalidateLayout()
end

-- ============================================================================
-- DoClick - 点击选择职业
-- ============================================================================
function PANEL:DoClick()
	if self.ClassTable then
		if self.ClassTable.Boss then
			RunConsoleCommand("zs_bossclass", self.ClassTable.Name)
			GAMEMODE:CenterNotify(translate.Format("boss_class_select", self.ClassTable.Name))
		else
			net.Start("zs_changeclass")
				net.WriteString(self.ClassTable.Name)
				net.WriteBool(GAMEMODE.SuicideOnChangeClass)
			net.SendToServer()
		end
	end

	surface.PlaySound("buttons/button15.wav")

	Window:Remove()
	bossmode = false
end

-- ============================================================================
-- Paint - 透明
-- ============================================================================
function PANEL:Paint()
	return true
end

-- ============================================================================
-- OnCursorEntered - 鼠标进入时高亮名称并显示详情
-- ============================================================================
function PANEL:OnCursorEntered()
	self.NameLabel:SetAlpha(230)

	CreateHoveredClassWindow(self.ClassTable)
end

-- ============================================================================
-- OnCursorExited - 鼠标离开时恢复透明度并关闭详情
-- ============================================================================
function PANEL:OnCursorExited()
	self.NameLabel:SetAlpha(170)

	if HoveredClassWindow and HoveredClassWindow:IsValid() and HoveredClassWindow.ClassTable == self.ClassTable then
		HoveredClassWindow:Remove()
	end
end

-- ============================================================================
-- Think - 更新按钮状态（已选择/已解锁/未解锁）
-- ============================================================================
function PANEL:Think()
	if not self.ClassTable then return end

	local enabled
	if MySelf:GetZombieClass() == self.ClassTable.Index then
		enabled = 2
	elseif self.ClassTable.Boss or gamemode.Call("IsClassUnlocked", self.ClassTable.Index) then
		enabled = 1
	else
		enabled = 0
	end

	if enabled ~= self.LastEnabledState then
		self.LastEnabledState = enabled

		if enabled == 2 then
			self.NameLabel:SetTextColor(COLOR_GREEN)
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)
			self.Image:SetAlpha(245)
		elseif enabled == 1 then
			self.NameLabel:SetTextColor(COLOR_GRAY)
			self.Image:SetImageColor(self.ClassTable.IconColor or color_white)
			self.Image:SetAlpha(245)
		else
			self.NameLabel:SetTextColor(COLOR_DARKRED)
			self.Image:SetImageColor(COLOR_DARKRED)
			self.Image:SetAlpha(170)
		end
	end
end

vgui.Register("ClassButton", PANEL, "Button")

-- ============================================================================
-- ClassInfo - 职业详情描述面板（鼠标悬停时显示）
-- ============================================================================
PANEL = {}

-- ============================================================================
-- Init - 初始化详情面板
-- ============================================================================
function PANEL:Init()
	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("ZSHUDFontSmaller")

	self.DescLabels = self.DescLabels or {}

	self:InvalidateLayout()
end

-- ============================================================================
-- SetClassTable - 设置职业数据并生成描述
-- ============================================================================
function PANEL:SetClassTable(classtable)
	self.ClassTable = classtable

	self.NameLabel:SetText(translate.Get(classtable.TranslationName))
	self.NameLabel:SizeToContents()

	self:CreateDescLabels()

	self:InvalidateLayout()
end

-- ============================================================================
-- RemoveDescLabels - 移除所有描述标签
-- ============================================================================
function PANEL:RemoveDescLabels()
	for _, label in pairs(self.DescLabels) do
		label:Remove()
	end

	self.DescLabels = {}
end

-- ============================================================================
-- CreateDescLabels - 创建职业描述文本标签
-- 包含解锁波次、进化版本信息和职业描述
-- ============================================================================
function PANEL:CreateDescLabels()
	self:RemoveDescLabels()

	self.DescLabels = {}

	local classtable = self.ClassTable
	if not classtable or not classtable.Description then return end

	local lines = {}

	if classtable.Wave and classtable.Wave > 0 then
		table.insert(lines, translate.Format("unlocked_on_wave_x", classtable.Wave))
	end

	if classtable.BetterVersion then
		local betterclasstable = GAMEMODE.ZombieClasses[classtable.BetterVersion]
		if betterclasstable then
			table.insert(lines, translate.Format("evolves_in_to_x_on_wave_y", betterclasstable.Wave,betterclasstable.Name))
		end
	end

	table.insert(lines, " ")
	table.Add(lines, string.Explode("\n", translate.Get(classtable.Description)))

	if classtable.Help then
		table.insert(lines, " ")
		table.Add(lines, string.Explode("\n", translate.Get(classtable.Help)))
	end

	for i, line in ipairs(lines) do
		local label = vgui.Create("DLabel", self)
		local notwaveone = classtable.Wave and classtable.Wave > 0

		label:SetText(line)
		if i == (notwaveone and 2 or 1) and classtable.BetterVersion then
			label:SetColor(COLOR_RORANGE)
		end
		label:SetFont(i == 1 and notwaveone and "ZSBodyTextFontBig" or "ZSBodyTextFont")
		label:SizeToContents()
		table.insert(self.DescLabels, label)
	end
end

-- ============================================================================
-- PerformLayout - 布局描述文本
-- ============================================================================
function PANEL:PerformLayout()
	self.NameLabel:SizeToContents()
	self.NameLabel:CenterHorizontal()

	local maxw = self.NameLabel:GetWide()
	for _, label in pairs(self.DescLabels) do
		maxw = math.max(maxw, label:GetWide())
	end
	self:SetWide(maxw + 64)
	self:CenterHorizontal()

	for i, label in ipairs(self.DescLabels) do
		label:MoveBelow(self.DescLabels[i - 1] or self.NameLabel)
		label:CenterHorizontal()
	end

	local lastlabel = self.DescLabels[#self.DescLabels] or self.NameLabel
	local _, y = lastlabel:GetPos()
	self:SetTall(y + lastlabel:GetTall())
end

-- ============================================================================
-- Think - 当主窗口关闭时自动移除
-- ============================================================================
function PANEL:Think()
	if not Window or not Window:IsValid() or not Window:IsVisible() then
		self:Remove()
	end
end

-- ============================================================================
-- Paint - 绘制默认框架皮肤
-- ============================================================================
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h)

	return true
end

vgui.Register("ClassInfo", PANEL, "Panel")
