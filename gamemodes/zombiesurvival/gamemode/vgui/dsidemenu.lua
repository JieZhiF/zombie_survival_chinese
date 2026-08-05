-- ============================================================================
-- DZSSideMenuBase - 侧边菜单公共基类（DSideMenu 与 DZombieSpawnMenu 共享）
-- 按下 ALT 键后从右侧滑入；子类自定义 Spacing/宽度/RefreshContents
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 侧边菜单基类
-- [位置] DZSSideMenuBase / Init() / OpenMenu() / CloseMenu() / Think()
-- [作用] ALT 键从右侧滑入的菜单框架，管理项目增删与居中布局
-- [常改] 菜单宽度、滑动时长、按键检测
--
-- [区域] 项目列表
-- [位置] AddItem() / RemoveItem() / PerformLayout()
-- [作用] 垂直居中排列可见项目
-- [常改] 项目间距、排列方式
--
-- [区域] 人类弹药菜单
-- [位置] DSideMenu / RefreshContents()
-- [作用] 按弹药余量自动显示/隐藏对应的弹药计数器行
-- [常改] 显隐判定条件
-- ============================================================================

local PANEL = {}

-- 每个项目之间的垂直间距
PANEL.Spacing = 8
-- 滑动动画时间（已禁用，设为 0）
PANEL.SlideTime = 0
-- 下次刷新时间
PANEL.NextRefresh = 0

-- ============================================================================
-- Init - 初始化侧边菜单
-- ============================================================================
function PANEL:Init()
	self:RefreshSize()
	self:SetPos(ScrW() - 1, 0)

	self.Items = {}
end

-- ============================================================================
-- Think - 每帧逻辑：检测按键释放以关闭菜单
-- ============================================================================
function PANEL:Think()
	local time = RealTime()
	if self.CloseTime and time >= self.CloseTime then
		self.CloseTime = nil
		self:SetVisible(false)
	elseif self.StartChecking and time >= self.StartChecking then
		if not MySelf:KeyDown(GAMEMODE.MenuKey) then
			self:CloseMenu()
		end
	end
end

-- ============================================================================
-- RefreshSize - 根据屏幕 DPI 刷新菜单大小
-- ============================================================================
function PANEL:RefreshSize()
	self:SetSize(BetterScreenScale() * 256, ScrH())
end

-- ============================================================================
-- OpenMenu - 打开侧边菜单
-- ============================================================================
function PANEL:OpenMenu()
	if self.StartChecking and RealTime() < self.StartChecking then return end

	self.CloseTime = nil

	self:RefreshSize()
	self:SetPos(ScrW() - self:GetWide(), 0, self.SlideTime, 0, self.SlideTime * 0.8)
	self:SetVisible(true)
	self:MakePopup()
	self.StartChecking = RealTime() + 0.1
	self:RefreshContents()

	timer.Simple(0, function()
		gui.SetMousePos(ScrW() * 0.5, ScrH() * 0.5)
	end)
end

-- ============================================================================
-- CloseMenu - 关闭侧边菜单
-- ============================================================================
function PANEL:CloseMenu()
	self:RefreshContents()

	if self.CloseTime then return end
	self.CloseTime = RealTime() + self.SlideTime
end

-- 右侧渐变纹理
local texRightEdge = surface.GetTextureID("gui/gradient")

-- ============================================================================
-- Paint - 绘制菜单背景渐变
-- ============================================================================
function PANEL:Paint()
	surface.SetDrawColor(5, 5, 5, 180)
	surface.DrawRect(self:GetWide() * 0.4, 0, self:GetWide() * 0.6 + 1, self:GetTall())
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRectRotated(self:GetWide() * 0.2, self:GetTall() * 0.5, self:GetWide() * 0.4, self:GetTall(), 180)
end

-- ============================================================================
-- AddItem - 添加项目到侧边菜单
-- ============================================================================
function PANEL:AddItem(item)
	item:SetParent(self)
	item:SetWide(self:GetWide() - 16)

	table.insert(self.Items, item)

	self:InvalidateLayout()
end

-- ============================================================================
-- RemoveItem - 从侧边菜单移除项目
-- ============================================================================
function PANEL:RemoveItem(item)
	for k, v in ipairs(self.Items) do
		if v == item then
			item:Remove()
			table.remove(self.Items, k)
			self:InvalidateLayout()
			break
		end
	end
end

-- ============================================================================
-- RefreshContents - 子类实现具体内容
-- ============================================================================
function PANEL:RefreshContents()
end

-- ============================================================================
-- PerformLayout - 垂直居中排列所有可见项目
-- ============================================================================
function PANEL:PerformLayout()
	local y = ScrH() / 2
	for k, item in ipairs(self.Items) do
		if item and item:IsValid() and item:IsVisible() then
			y = y - (item:GetTall() + self.Spacing) / 2
		end
	end

	for k, item in ipairs(self.Items) do
		if item and item:IsValid() and item:IsVisible() then
			item:SetPos(0, y)
			item:CenterHorizontal()
			y = y + item:GetTall() + self.Spacing
		end
	end
end

vgui.Register("DZSSideMenuBase", PANEL, "DPanel")

-- ============================================================================
-- DSideMenu - 侧边菜单面板（人类 ALT 菜单右侧界面）
-- 按下 ALT 键后从右侧滑入，显示弹药计数器列表
-- 根据弹药是否为空自动隐藏/显示对应的弹药行
-- ============================================================================

local PANEL = {}
PANEL.Base = "DZSSideMenuBase"

-- 每个项目之间的垂直间距
PANEL.Spacing = 8

-- ============================================================================
-- RefreshSize - 根据屏幕 DPI 刷新菜单大小
-- ============================================================================
function PANEL:RefreshSize()
	self:SetSize(BetterScreenScale() * 256, ScrH())
end

-- ============================================================================
-- RefreshContents - 根据弹药数量显示/隐藏对应的弹药计数器
-- ============================================================================
function PANEL:RefreshContents()
	local changed = false

	for k, v in ipairs(self.Items) do
		if v.GetAmmoType then
			if MySelf:GetAmmoCount(v:GetAmmoType()) <= 0 then
				if v:IsVisible() then
					v:SetVisible(false)
					changed = true
				end
			elseif not v:IsVisible() then
				v:SetVisible(true)
				changed = true
			end
		end
	end

	if changed then
		self:InvalidateLayout()
	end
end

vgui.Register("DSideMenu", PANEL, "DZSSideMenuBase")
