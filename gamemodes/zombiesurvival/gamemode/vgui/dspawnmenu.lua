-- ============================================================================
-- DZombieSpawnMenu - 僵尸巢穴选择菜单（僵尸 ALT 菜单）
-- 按下 ALT 键后从右侧滑入，显示所有可用的僵尸巢穴和幼体
-- 点击后切换观察视角到对应目标
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 巢穴/幼体列表
-- [位置] RefreshContents()
-- [作用] 遍历缓存巢穴与幼体生成观察按钮
-- [常改] 按钮文字格式、字体
--
-- [区域] 点击观察
-- [位置] 各按钮 DoClick()
-- [作用] 发送 NESTSPEC 网络消息切换观察视角
-- [常改] 目标选择逻辑
-- ============================================================================

local PANEL = {}
PANEL.Base = "DZSSideMenuBase"

-- 每个项目之间的垂直间距
PANEL.Spacing = 12
-- 刷新间隔（秒）
PANEL.RefreshTime = 1

-- ============================================================================
-- RefreshSize - 根据屏幕 DPI 刷新菜单大小
-- ============================================================================
function PANEL:RefreshSize()
	self:SetSize(BetterScreenScale() * 320, ScrH())
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
			net.Start(NET_MSG.NESTSPEC)
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
			net.Start(NET_MSG.NESTSPEC)
				net.WriteEntity(baby)
			net.SendToServer()
		end

		self:AddItem(item)
	end

	self:InvalidateLayout()
end

vgui.Register("DZombieSpawnMenu", PANEL, "DZSSideMenuBase")
