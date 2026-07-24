-- ============================================================================
-- DZombieSpawnMenu - 僵尸巢穴选择菜单（僵尸 ALT 菜单）
-- 按下 ALT 键后从右侧滑入，显示所有可用的僵尸巢穴和幼体
-- 点击后切换观察视角到对应目标
-- ============================================================================

local PANEL = {}

-- 每个项目之间的垂直间距
PANEL.Spacing = 12
-- 滑动动画时间（已禁用，设为 0）
PANEL.SlideTime = 0
-- 下次刷新时间
PANEL.NextRefresh = 0
-- 刷新间隔（秒）
PANEL.RefreshTime = 1

-- ============================================================================
-- Init - 初始化菜单
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
	self:SetSize(BetterScreenScale() * 320, ScrH())
end

-- ============================================================================
-- OpenMenu - 打开菜单
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
-- CloseMenu - 关闭菜单
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
-- AddItem - 添加项目到菜单
-- ============================================================================
function PANEL:AddItem(item)
	item:SetParent(self)
	item:SetWide(self:GetWide() - 16)

	table.insert(self.Items, item)
end

-- ============================================================================
-- RefreshContents - 刷新巢穴/幼体列表
-- 遍历所有缓存巢穴和幼体，生成对应的观察按钮
-- ============================================================================
function PANEL:RefreshContents()
	for k, v in pairs(self.Items) do
		v:Remove()
	end
	self.Items = {}

	local occurs = {}

	-- 遍历所有巢穴，为每个巢穴创建观察按钮
	for k, nest in ipairs(GAMEMODE.CachedNests) do
		if not nest:IsValid() then continue end
		local nown = nest:GetNestOwner()
		occurs[nown] = (occurs[nown] or 0) + 1
		local ownname = nown:IsValidZombie() and nown:ClippedName() or ""

		local item = EasyButton(self, "巢 (" .. ownname .. " - " .. occurs[nown] .. ")", 8, 4)
		item:SetFont("ZSHUDFontSmall")
		item:SizeToContents()
		item.DoClick = function()
			net.Start("zs_nestspec")
				net.WriteEntity(nest)
			net.SendToServer()
		end

		self:AddItem(item)
	end

	-- 遍历所有幼体（熊孩子BOSS扔出的婴儿），为每个创建观察按钮
	for k, baby in ipairs(GAMEMODE.CachedBabies) do
		if not baby:IsValid() then continue end

		local item = EasyButton(self, "Gore Child", 8, 4)
		item:SetFont("ZSHUDFontSmall")
		item:SizeToContents()
		item.DoClick = function()
			net.Start("zs_nestspec")
				net.WriteEntity(baby)
			net.SendToServer()
		end

		self:AddItem(item)
	end

	self:InvalidateLayout()
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

vgui.Register("DZombieSpawnMenu", PANEL, "DPanel")
