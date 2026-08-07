-- ============================================================================
-- PArsenal - 积分商店界面（按 F2 打开）
-- 包含物品列表（按类别分页）、物品详情查看器、购买/快速购买系统
-- 以及物品统计条和弹药购买等完整功能
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 商店主窗口
-- [位置] GM:OpenArsenalMenu()
-- [作用] 创建积分商店框架，鼠标移出自动隐藏，锁鼠标居中
-- [常改] 窗口尺寸、顶部/底部栏
--
-- [区域] 分类标签页
-- [位置] GM:OpenArsenalMenu() 类别循环 / GM:ConfigureMenuTabs()
-- [作用] 按物品类别分页，枪支/近战/饰品带 Tier/子类筛选按钮
-- [常改] 标签高度、网格列数、子分类按钮
--
-- [区域] 物品卡片
-- [位置] GM:AddShopItem() / ItemPanelThink() / ItemPanelPaint() / ItemPanelDoClick()
-- [作用] 图标/名称/价格/库存卡片，可购买性变色，点击选购买
-- [常改] 卡片尺寸、边框颜色、右键菜单
--
-- [区域] 详情查看器
-- [位置] GM:CreateItemInfoViewer() / GM:SupplyItemViewerDetail() / GM:ViewerStatBarUpdate()
-- [作用] 标题/模型/描述/属性条/弹药信息/购买按钮
-- [常改] 查看器布局、属性行数、购买按钮
--
-- [区域] 属性条组件
-- [位置] ZSItemStatBar / Paint()
-- [作用] 平滑渐变的属性对比条
-- [常改] 条体颜色、渐变材质
--
-- [区域] 快速购买开关
-- [位置] QuickBuyButton / quickbuyDoClick()
-- [作用] iOS 风格开关，切换 zs_alwaysquickbuy
-- [常改] 开关配色、动画速度
-- ============================================================================

-- ============================================================================
-- pointslabelThink - 刷新剩余积分显示
-- ============================================================================
local function pointslabelThink(self)
	local points = MySelf:GetPoints()
	if self.m_LastPoints ~= points then
		self.m_LastPoints = points

		self:SetText(translate.Get("arsenal_PointsToSpend") .. points)

		self:SizeToContents()
	end
end

-- 当鼠标移出商店界面时自动关闭
hook.Add("Think", "ArsenalMenuThink", function()
	local pan = GAMEMODE.ArsenalInterface
	if pan and pan:IsValid() and pan:IsVisible() then
		local mx, my = gui.MousePos()
		local x, y = pan:GetPos()
		if mx < x - 16 or my < y - 16 or mx > x + pan:GetWide() + 16 or my > y + pan:GetTall() + 16 then
			pan:SetVisible(false)
		end
	end
end)

-- 将鼠标指针锁定在商店窗口中心
local function ArsenalMenuCenterMouse(self)
	local x, y = self:GetPos()
	local w, h = self:GetSize()
	gui.SetMousePos(x + w / 2, y + h / 2)
end

-- 打开价值/装备菜单
local function worthmenuDoClick()
	MakepWorth()
	GAMEMODE.ArsenalInterface:Close()
end

-- ============================================================================
-- CanBuy - 检查玩家是否可购买该物品
-- 检查经典模式、层级锁定、库存和积分条件
-- ============================================================================
local function CanBuy(item, pan)
	if item.NoClassicMode and GAMEMODE:IsClassicMode() then
		return false
	end

	if item.Tier and GAMEMODE.LockItemTiers and not GAMEMODE.ZombieEscape and not GAMEMODE.ObjectiveMap and not GAMEMODE:IsClassicMode() then
		if not GAMEMODE:GetWaveActive() then
			if GAMEMODE:GetWave() + 1 < item.Tier then
				return false
			end
		elseif GAMEMODE:GetWave() < item.Tier then
			return false
		end
	end

	if item.MaxStock and not GAMEMODE:HasItemStocks(item.Signature) then
		return false
	end

	if not pan.NoPoints and MySelf:GetPoints() < math.floor(item.Price * (MySelf.ArsenalDiscount or 1)) then
		return false
	elseif pan.NoPoints and MySelf:GetAmmoCount("scrap") < math.ceil(GAMEMODE:PointsToScrap(item.Price)) then
		return false
	end

	return true
end

-- ============================================================================
-- ItemPanelThink - 物品面板的每帧逻辑
-- 更新购买状态（文字颜色）和库存显示
-- ============================================================================
local function ItemPanelThink(self)
	-- 菜单关闭（SetVisible(false)）时 Think 仍每帧调用，直接跳过
	if not self:IsVisible() then return end

	local itemtab = FindItem(self.ID)
	if itemtab then
		local newstate = CanBuy(itemtab, self)
		if newstate ~= self.m_LastAbleToBuy then
			self.m_LastAbleToBuy = newstate
			if newstate then
				self.NameLabel:SetTextColor(COLOR_WHITE)
				self.NameLabel:InvalidateLayout()
			else
				self.NameLabel:SetTextColor(COLOR_RED)
				self.NameLabel:InvalidateLayout()
			end
		end

		if self.StockLabel then
			local stocks = GAMEMODE:GetItemStocks(self.ID)
			if stocks ~= self.m_LastStocks then
				self.m_LastStocks = stocks

				self.StockLabel:SetText(stocks.." "..translate.Get("aresnal_remaining"))
				self.StockLabel:SizeToContents()
				self.StockLabel:AlignRight(10)
				self.StockLabel:SetTextColor(stocks > 0 and COLOR_GRAY or COLOR_RED)
				self.StockLabel:InvalidateLayout()
			end
		end
	end
end

-- 快速购买按钮点击回调
local function quickbuyDoClick()
	RunConsoleCommand("zs_alwaysquickbuy", GAMEMODE.AlwaysQuickBuy and "0" or "1")
end

-- 物品面板背景颜色
local colBG = Color(20, 20, 20)

-- ============================================================================
-- ItemPanelPaint - 物品面板的绘制函数
-- 显示边框（根据可购买状态变色）和库存持有状态
-- ============================================================================
local function ItemPanelPaint(self, w, h)
	if self.Hovered or self.On then
		local outline
		if self.m_LastAbleToBuy then
			outline = self.Depressed and COLOR_GREEN or COLOR_DARKGREEN
		else
			outline = self.Depressed and COLOR_RED or COLOR_DARKRED
		end

		draw.RoundedBox(8, 0, 0, w, h, outline)
	end

	if self.ShopTabl.SWEP and MySelf:HasInventoryItem(self.ShopTabl.SWEP) then
		draw.RoundedBox(8, 2, 2, w - 4, h - 4, COLOR_RORANGE)
	end

	draw.RoundedBox(2, 4, 4, w - 8, h - 8, colBG)

	return true
end

-- ============================================================================
-- ViewerStatBarUpdate - 更新物品详情查看器的统计条
-- ============================================================================
function GM:ViewerStatBarUpdate(viewer, display, sweptable)
	local speedtotext = GAMEMODE.SpeedToText

	-- 先清空所有属性行
	for i = 1, 10 do
		viewer.ItemStats[i]:SetText("")
		viewer.ItemStatValues[i]:SetText("")
		viewer.ItemStatBars[i]:SetVisible(false)
	end

	if display then return end

	-- 固定显示前 10 个 WeaponStatBarVals，缺失值显示 0
	for i = 1, 10 do
		local stat = GAMEMODE.WeaponStatBarVals[i]
		if not stat then break end

		local statnum = 0
		if stat[6] then
			local sub = sweptable[stat[6]]
			if sub and sub[stat[1]] and sub[stat[1]] ~= -1 then
				statnum = sub[stat[1]]
			end
		elseif sweptable[stat[1]] and sweptable[stat[1]] ~= -1 then
			statnum = sweptable[stat[1]]
		end

		local stattext
		if stat[1] == "Damage" and sweptable.Primary and sweptable.Primary.NumShots and sweptable.Primary.NumShots > 1 then
			stattext = statnum .. " x " .. sweptable.Primary.NumShots
		elseif stat[1] == "HeadshotMulti" then
			local damage = sweptable.Primary and sweptable.Primary.Damage or sweptable.Damage or 0
			stattext = math.Round(damage * statnum)
			statnum = damage * statnum
		elseif stat[1] == "WalkSpeed" then
			stattext = speedtotext[SPEED_NORMAL]
			if speedtotext[sweptable[stat[1]]] then
				stattext = speedtotext[sweptable[stat[1]]]
			elseif sweptable[stat[1]] and sweptable[stat[1]] < SPEED_SLOWEST then
				stattext = speedtotext[-1]
			end
		elseif stat[1] == "ClipSize" then
			local requiredclip = sweptable.RequiredClip or 1
			stattext = statnum / requiredclip
		else
			stattext = statnum
		end

		viewer.ItemStats[i]:SetText(stat[2])
		viewer.ItemStatValues[i]:SetText(stattext)

		if stat[1] == "Damage" and sweptable.Primary and sweptable.Primary.NumShots then
			statnum = statnum * sweptable.Primary.NumShots
		elseif stat[1] == "ClipSize" then
			statnum = statnum / (sweptable.RequiredClip or 1)
		elseif stat[1] == "HeadshotMulti" then
			local damage = sweptable.Primary and sweptable.Primary.Damage or sweptable.Damage or 0
			statnum = damage * statnum
		end

		viewer.ItemStatBars[i].Stat = statnum
		viewer.ItemStatBars[i].StatMin = stat[3]
		viewer.ItemStatBars[i].StatMax = stat[4]
		viewer.ItemStatBars[i].BadHigh = stat[5]
		viewer.ItemStatBars[i]:SetVisible(true)
	end
end

-- ============================================================================
-- HasPurchaseableAmmo - 检查武器是否有可购买的弹药
-- ============================================================================
function GM:HasPurchaseableAmmo(sweptable)
	if sweptable.Primary and self.AmmoToPurchaseNames[sweptable.Primary.Ammo] then
		return true
	end
end

-- ============================================================================
-- SupplyItemViewerDetail - 在查看器中显示物品详情
-- 包括模型预览、描述文字、统计数据、弹药信息
-- ============================================================================
function GM:SupplyItemViewerDetail(viewer, sweptable, shoptbl)
	viewer.m_Title:SetText(sweptable.PrintName)
	viewer.m_Title:PerformLayout()

	local desctext = sweptable.Description or ""
	
	if viewer.IconDisplay then
		if IsValid(viewer.m_Icon) then viewer.m_Icon:Remove() end
		if IsValid(viewer.m_Padlock) then viewer.m_Padlock:Remove() end

		local iconname = self.ZSInventoryItemData[shoptbl.SWEP] and "weapon_zs_craftables" or shoptbl.SWEP or shoptbl.Model
		local kitbl = iconname and killicon.Get(iconname) or nil
		kitbl = kitbl or killicon.Get("default")
		if kitbl then
			self:AttachKillicon(kitbl, viewer, viewer.IconDisplay, false, false)
		end

		viewer.m_VBG:SetVisible(true)
		if not self.ZSInventoryItemData[shoptbl.SWEP] then
			if sweptable.NoDismantle then
				desctext = desctext .. "\n" .. translate.Get("arsenal_CannotDismantle")
			end
			viewer.m_Desc:SetFont("ZSBodyTextFont")
		else
			viewer.m_Desc:SetFont("ZSBodyTextFontBig")
		end
	else
		if not self.ZSInventoryItemData[shoptbl.SWEP] then
			viewer.ModelPanel:SetModel(sweptable.WorldModel)
			local mins, maxs = viewer.ModelPanel.Entity:GetRenderBounds()
			viewer.ModelPanel:SetCamPos(mins:Distance(maxs) * Vector(1.15, 0.75, 0.5))
			viewer.ModelPanel:SetLookAt((mins + maxs) / 2)
			viewer.m_VBG:SetVisible(true)

			if sweptable.NoDismantle then
				desctext = desctext .. "\n" .. translate.Get("arsenal_CannotDismantle")
			end

			viewer.m_Desc:MoveBelow(viewer.m_VBG, 8)
			viewer.m_Desc:SetFont("ZSBodyTextFont")
		else
			viewer.ModelPanel:SetModel("")
			viewer.m_VBG:SetVisible(false)

			viewer.m_Desc:MoveBelow(viewer.m_Title, 20)
			viewer.m_Desc:SetFont("ZSBodyTextFontBig")
		end
	end

	-- 只有武器/近战类显示属性条，其余类别隐藏
	local displaystats = shoptbl.Category ~= ITEMCAT_GUNS and shoptbl.Category ~= ITEMCAT_MELEE
	self:ViewerStatBarUpdate(viewer, displaystats, sweptable)

	viewer.m_Desc:SetText(desctext)
	-- 无属性条时描述直接贴图标区下方，避免留出整块属性区空白
	-- （craftables 且无 IconDisplay 时图标区隐藏，改贴标题下方）
	if displaystats then
		if self.ZSInventoryItemData[shoptbl.SWEP] and not viewer.IconDisplay then
			viewer.m_Desc:MoveBelow(viewer.m_Title, 20)
		else
			viewer.m_Desc:MoveBelow(viewer.m_VBG, 8)
		end
	else
		viewer.m_Desc:MoveBelow(viewer.ItemStats[10], 8)
	end

	if self:HasPurchaseableAmmo(sweptable) and self.AmmoNames[string.lower(sweptable.Primary.Ammo)] then
		local lower = string.lower(sweptable.Primary.Ammo)

		viewer.m_AmmoType:SetText(self.AmmoNames[lower])
		viewer.m_AmmoType:PerformLayout()

		local ki = killicon.Get(self.AmmoIcons[lower])

		viewer.m_AmmoIcon:SetImage(ki[1])
		if ki[2] then viewer.m_AmmoIcon:SetImageColor(ki[2]) end

		viewer.m_AmmoIcon:SetVisible(true)
	else
		viewer.m_AmmoType:SetText("")
		viewer.m_AmmoIcon:SetVisible(false)
	end
end

-- ============================================================================
-- ItemPanelDoClick - 物品面板点击回调
-- 选中物品并更新查看器，显示购买按钮和价格
-- ============================================================================
local function ItemPanelDoClick(self)
	local shoptbl = self.ShopTabl
	local viewer = self.NoPoints and GAMEMODE.RemantlerInterface.TrinketsFrame.Viewer or GAMEMODE.ArsenalInterface.Viewer

	if not shoptbl then return end
	local sweptable = GAMEMODE.ZSInventoryItemData[shoptbl.SWEP] or weapons.Get(shoptbl.SWEP)

	if not sweptable or GAMEMODE.AlwaysQuickBuy then
		RunConsoleCommand("zs_pointsshopbuy", self.ID, self.NoPoints and "scrap")
		return
	end

	for _, v in pairs(self:GetParent():GetChildren()) do
		v.On = false
	end
	self.On = true

	GAMEMODE:SupplyItemViewerDetail(viewer, sweptable, shoptbl)

	local screenscale = BetterScreenScale()
	local canammo = GAMEMODE:HasPurchaseableAmmo(sweptable)

	local purb = viewer.m_PurchaseB
	purb.ID = self.ID
	purb.DoClick = function() RunConsoleCommand("zs_pointsshopbuy", self.ID, self.NoPoints and "scrap") end
	purb:SetPos(canammo and viewer:GetWide() / 4 - viewer:GetWide() / 8 - 20 or viewer:GetWide() / 4, viewer:GetTall() - 64 * screenscale)
	purb:SetVisible(true)

	local purl = viewer.m_PurchaseLabel
	purl:SetPos(purb:GetWide() / 2 - purl:GetWide() / 2, purb:GetTall() * 0.35 - purl:GetTall() * 0.5)
	purl:SetVisible(true)

	local ppurbl = viewer.m_PurchasePrice
	local price = self.NoPoints and math.ceil(GAMEMODE:PointsToScrap(shoptbl.Worth)) or math.floor(shoptbl.Worth * (MySelf.ArsenalDiscount or 1))
	ppurbl:SetText(price .. (self.NoPoints and translate.Get("arsenal_Scrap") or translate.Get("arsenal_Points")))

	ppurbl:SizeToContents()
	ppurbl:SetPos(purb:GetWide() / 2 - ppurbl:GetWide() / 2, purb:GetTall() * 0.75 - ppurbl:GetTall() * 0.5)
	ppurbl:SetVisible(true)

	purb = viewer.m_AmmoB
	if canammo then
		purb.AmmoType = GAMEMODE.AmmoToPurchaseNames[sweptable.Primary.Ammo]
		purb.DoClick = function() RunConsoleCommand("zs_pointsshopbuy", "ps_"..purb.AmmoType) end
	end
	purb:SetPos(viewer:GetWide() * (3/4) - purb:GetWide() / 2, viewer:GetTall() - 64 * screenscale)
	purb:SetVisible(canammo)

	purl = viewer.m_AmmoL
	purl:SetPos(purb:GetWide() / 2 - purl:GetWide() / 2, purb:GetTall() * 0.35 - purl:GetTall() * 0.5)
	purl:SetVisible(canammo)

	ppurbl = viewer.m_AmmoPrice
	price = math.floor(9 * (MySelf.ArsenalDiscount or 1))
	ppurbl:SetText(price .. translate.Get("arsenal_Points"))

	ppurbl:SizeToContents()
	ppurbl:SetPos(purb:GetWide() / 2 - ppurbl:GetWide() / 2, purb:GetTall() * 0.75 - ppurbl:GetTall() * 0.5)
	ppurbl:SetVisible(canammo)
end

-- ============================================================================
-- ArsenalMenuThink - 商店菜单 Think（预留）
-- ============================================================================
local function ArsenalMenuThink(self)
end

-- ============================================================================
-- AttachKillicon - 在物品面板上附加击杀图标
-- ============================================================================
function GM:AttachKillicon(kitbl, itempan, mdlframe, ammo, missing_skill)
	local function imgAdj(img, maximgx, maximgy)
		img:SizeToContents()
		local iwidth, height = img:GetSize()
		if height > maximgy then
			img:SetSize(maximgy / height * img:GetWide(), maximgy)
			iwidth, height = img:GetSize()
		end
		if iwidth > maximgx then
			img:SetWidth(maximgx)
		end

		img:Center()
	end

	if #kitbl == 2 then
		local img = vgui.Create("DImage", mdlframe)
		img:SetImage(kitbl[1])
		if kitbl[2] then
			img:SetImageColor(kitbl[2])
		end
		if missing_skill then img:SetAlpha(50) end

		imgAdj(img, mdlframe:GetWide() - 6, mdlframe:GetTall() - 3)
		if ammo then img:SetSize(img:GetWide() + 3, img:GetTall() + 3) end

		img:Center()
		itempan.m_Icon = img
	elseif #kitbl == 3 then
		local label = vgui.Create("DLabel", mdlframe)
		label:SetText(kitbl[2])
		local screenscale = BetterScreenScale()
		local basefont = kitbl[1]:match("cs$") and "csd" or "HL2MP"
		local iconfont = kitbl[1] .. "pa"
		-- pa 字体(72px)超出卡片图标区高度(52px)，按区域高度动态缩放字号
		surface.SetFont(iconfont)
		local _, fh = surface.GetTextSize(kitbl[2])
		local maxh = mdlframe:GetTall() - 4
		if fh > maxh then
			iconfont = kitbl[1] .. "pafit"
			surface.CreateFont(iconfont, {font = basefont, size = math.max(8, math.ceil(72 * screenscale * maxh / fh)), weight = 100, antialias = true})
		end
		label:SetFont(iconfont)
		label:SetTextColor(kitbl[3] or color_white)
		label:SizeToContents()
		-- 与材质图标一致：绝对居中（原为中下对齐+Dock，导致字体图标位置偏移）
		label:SetContentAlignment(5)
		label:SetPos((mdlframe:GetWide() - label:GetWide()) / 2, (mdlframe:GetTall() - label:GetTall()) / 2)
		itempan.m_Icon = label
	end

	if missing_skill then
		local img = vgui.Create("DImage", mdlframe)
		img:SetImage("zombiesurvival/padlock.png")
		img:SetImageColor(Color(255, 30, 30))
		imgAdj(img, mdlframe:GetWide(), mdlframe:GetTall())

		img:Center()
		itempan.m_Padlock = img
	end
end

-- ============================================================================
-- AddShopItem - 向商店列表中添加物品面板
-- ============================================================================
function GM:AddShopItem(list, i, tab, issub, nopointshop)
	local screenscale = BetterScreenScale()

	local nottrinkets = tab.Category ~= ITEMCAT_TRINKETS
	local missing_skill = tab.SkillRequirement and not MySelf:IsSkillActive(tab.SkillRequirement)
	local wid = 280

	local itempan = vgui.Create("DButton")
	itempan:SetText("")
	itempan:SetSize(wid * screenscale, (nottrinkets and 100 or 60) * screenscale)
	itempan.ID = tab.Signature or i
	itempan.NoPoints = nopointshop
	itempan.ShopTabl = tab
	itempan.Think = ItemPanelThink
	itempan.Paint = ItemPanelPaint
	itempan.DoClick = ItemPanelDoClick
	itempan.DoRightClick = function()
		local menu = DermaMenu(itempan)
		menu:AddOption("Buy", function() RunConsoleCommand("zs_pointsshopbuy", itempan.ID, itempan.NoPoints and "scrap") end)
		menu:Open()
	end
	list:AddItem(itempan)

	if nottrinkets then
		local mdlframe = vgui.Create("DPanel", itempan)
		mdlframe:SetSize(wid/2 * screenscale, 100/2 * screenscale)
		mdlframe:SetPos(wid/4 * screenscale, 100/5 * screenscale)
		mdlframe:SetMouseInputEnabled(false)
		mdlframe.Paint = function() end

		
		local kitbl = killicon.Get(GAMEMODE.ZSInventoryItemData[tab.SWEP] and "weapon_zs_craftables" or tab.SWEP or tab.Model)
		if kitbl then
			self:AttachKillicon(kitbl, itempan, mdlframe, tab.Category == ITEMCAT_AMMO, missing_skill)
		elseif tab.Model then
			if tab.Model then
				print(tab.Model)
				local mdlpanel = vgui.Create("DModelPanel", mdlframe)
				mdlpanel:SetSize(mdlframe:GetSize())
				mdlpanel:SetModel(tab.Model)
				local mins, maxs = mdlpanel.Entity:GetRenderBounds()
				mdlpanel:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
				mdlpanel:SetLookAt((mins + maxs) / 2)
				
			end
		end
		
	end

	if tab.SWEP or tab.Countables then
		local counter = vgui.Create("ItemAmountCounter", itempan)
		counter:SetItemID(i)
	end

	local name = tab.Name or ""
	local namelab = EasyLabel(itempan, name, "ZSHUDFontSmaller", COLOR_WHITE)
	namelab:SetPos(12 * screenscale, itempan:GetTall() * (nottrinkets and 0.8 or 0.7) - namelab:GetTall() * 0.5)
	if missing_skill then
		namelab:SetAlpha(30)
	end
	itempan.NameLabel = namelab

	local alignri = (issub and (320 + 32) or (nopointshop and 32 or 20)) * screenscale

	local pricelabel = EasyLabel(itempan, "", "ZSHUDFontTiny")
	if missing_skill then
		pricelabel:SetTextColor(COLOR_RED)
		pricelabel:SetText(GAMEMODE.Skills[tab.SkillRequirement].Name)
	else
		local points = math.floor(tab.Price * (MySelf.ArsenalDiscount or 1))
		local price = tostring(points)
		if nopointshop then
			price = tostring(math.ceil(self:PointsToScrap(tab.Price)))
		end
		pricelabel:SetText(price..(nopointshop and translate.Get("arsenal_Scrap") or translate.Get("arsenal_Points")))

	end
	pricelabel:SizeToContents()
	pricelabel:AlignRight(alignri)

	if tab.MaxStock then
		local stocklabel = EasyLabel(itempan, translate.Get("arsenal_StockRemaining"):format(tab.MaxStock), "ZSHUDFontTiny")

		stocklabel:SizeToContents()
		stocklabel:AlignRight(alignri)
		stocklabel:SetPos(itempan:GetWide() - stocklabel:GetWide(), itempan:GetTall() * 0.45 - stocklabel:GetTall() * 0.5)
		itempan.StockLabel = stocklabel
	end
	pricelabel:SetPos(
		itempan:GetWide() - pricelabel:GetWide() - 12 * screenscale,
		itempan:GetTall() * (nottrinkets and 0.15 or 0.3) - pricelabel:GetTall() * 0.5
	)

	if missing_skill or tab.NoClassicMode and isclassic or tab.NoZombieEscape and GAMEMODE.ZombieEscape then
		itempan:SetAlpha(160)
	end

	if not nottrinkets and tab.SubCategory then
		local catlabel = EasyLabel(itempan, GAMEMODE.ItemSubCategories[tab.SubCategory], "ZSBodyTextFont")
		catlabel:SizeToContents()
		catlabel:SetPos(10, itempan:GetTall() * 0.3 - catlabel:GetTall() * 0.5)
	end

	return itempan
end

-- ============================================================================
-- ConfigureMenuTabs - 配置菜单属性的标签按钮样式和行为
-- ============================================================================
function GM:ConfigureMenuTabs(tabs, tabhei, callback)
	local screenscale = BetterScreenScale()

	for _, tab in pairs(tabs) do
		tab:SetFont(screenscale > 0.85 and "ZSHUDFontTiny" or "DefaultFontAA")
		tab.GetTabHeight = function()
			return tabhei
		end
		tab.PerformLayout = function(me)
			me:ApplySchemeSettings()

			if not me.Image then return end
			me.Image:SetPos(7, me:GetTabHeight()/2 - me.Image:GetTall()/2 + 3)
			me.Image:SetImageColor(Color(255, 255, 255, not me:IsActive() and 155 or 255))
		end
		tab.DoClick = function(me)
			me:GetPropertySheet():SetActiveTab(me)

			if callback then callback(tab) end
		end
	end
end

-- ============================================================================
-- ZSItemStatBar - 武器属性条组件
-- 显示伤害、射速等属性的横向对比条
-- ============================================================================
local PANEL = {}

PANEL.Stat = 50
PANEL.StatMin = 0
PANEL.StatMax = 100
PANEL.BadHigh = false
PANEL.LerpStat = 50

function PANEL:Init()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})

-- ============================================================================
-- Paint - 绘制属性渐变条
-- ============================================================================
function PANEL:Paint(w, h)
	self.LerpStat = Lerp(FrameTime() * 4, self.LerpStat, self.Stat)
	local progress = math.Clamp((self.StatMax - self.LerpStat)/(self.StatMax - self.StatMin), 0, 1)
	if not self.BadHigh then
		progress = 1 - progress
	end

	local barh = math.max(2, h)

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(0, 0, w, barh)
	surface.SetDrawColor(250, 250, 250, 20)
	surface.DrawRect(math.min(w * 0.95, w * progress), 0, 1, barh)
	surface.SetDrawColor(200 * (1 - progress), 200 * progress, 10, 160)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(0, 0, w * progress, barh - 1)
end
vgui.Register("ZSItemStatBar", PANEL, "Panel")

-- ============================================================================
-- CreateItemViewerGenericElems - 创建物品查看器的通用 UI 元素
-- 包括标题、弹药类型、弹药图标、模型面板、描述、统计条
-- ============================================================================
function GM:CreateItemViewerGenericElems(viewer, style)
	local screenscale = BetterScreenScale()

	local vtitle = EasyLabel(viewer, "", "ZSHUDFontSmaller", COLOR_GRAY)
	vtitle:SetContentAlignment(2)
	vtitle:SetSize(viewer:GetWide(), 40 * screenscale)
	vtitle:SetWrap(true)
	vtitle:SetMultiline(true)
	vtitle:SetAutoStretchVertical(true)
	viewer.m_Title = vtitle

	local vammot = EasyLabel(viewer, "", "ZSBodyTextFontBig", COLOR_GRAY)
	vammot:SetContentAlignment(2)
	vammot:SetSize(viewer:GetWide(), 16 * screenscale)
	vammot:MoveBelow(vtitle, 20)
	vammot:CenterHorizontal(0.35)
	viewer.m_AmmoType = vammot

	local vammoi = vgui.Create("DImage", viewer)
	vammoi:SetSize(40, 40)
	vammoi:MoveBelow(vtitle, 8)
	vammoi:CenterHorizontal(0.7)
	viewer.m_AmmoIcon = vammoi

	local vbg = vgui.Create("DPanel", viewer)
	vbg:SetSize(240 * screenscale, 140 * screenscale)
	vbg:CenterHorizontal()
	vbg:MoveBelow(vammot, 24)
	vbg:SetBackgroundColor(Color(0, 0, 0, 255))
	vbg:SetVisible(false)
	viewer.m_VBG = vbg

	if style then
		local iconWidth = style.iconW <= 1 and viewer:GetWide() * style.iconW or style.iconW * screenscale
		vbg:SetSize(iconWidth, style.iconH * screenscale)
		vbg:CenterHorizontal()
		vbg:SetBackgroundColor(Color(0, 0, 0, 150))
		-- 标题/弹药类型已移入 vbg 内部，上移 vbg 消除初始布局（vtitle+vammot）留下的顶部空隙
		vbg:AlignTop(8)
	end

	if style then
		local bx, by = vbg:GetPos()
		if style.titleFont then
			vtitle:SetFont(style.titleFont)
		end
		vtitle:SetPos(bx + 8 * screenscale, by + 6 * screenscale)
		vtitle:SetSize(vbg:GetWide() - 16 * screenscale, 42 * screenscale)
		vtitle:SetWrap(true)
		vtitle:SetMultiline(true)
		vtitle:SetAutoStretchVertical(false)
		vtitle:SetContentAlignment(4)
		vtitle:SetTextInset(0, 0)
		vtitle:SetZPos(10)

		vammot:SetPos(bx + 8 * screenscale, by + vbg:GetTall() - 20 * screenscale)
		vammot:SetSize(vbg:GetWide() - 48 * screenscale, 16 * screenscale)
		vammot:SetContentAlignment(6)
		vammot:SetTextInset(0, 0)
		vammot:SetZPos(10)

		vammoi:SetSize(24 * screenscale, 24 * screenscale)
		vammoi:SetPos(bx + vbg:GetWide() - 32 * screenscale, by + vbg:GetTall() - 28 * screenscale)
		vammoi:SetZPos(10)

		local icondisplay = vgui.Create("DPanel", vbg)
		icondisplay:SetPos(8 * screenscale, 50 * screenscale)
		icondisplay:SetSize(vbg:GetWide() - 16 * screenscale, vbg:GetTall() - 74 * screenscale)
		icondisplay.Paint = function() end
		viewer.IconDisplay = icondisplay
	else
		local modelpanel = vgui.Create("DModelPanelEx", vbg)
		modelpanel:SetModel("")
		modelpanel:AutoCam()
		modelpanel:Dock(FILL)
		modelpanel:SetDirectionalLight(BOX_TOP, Color(100, 255, 100))
		modelpanel:SetDirectionalLight(BOX_FRONT, Color(255, 100, 100))
		viewer.ModelPanel = modelpanel
	end

	local itemdesc = vgui.Create("DLabel", viewer)
	itemdesc:SetFont("ZSBodyTextFont")
	itemdesc:SetTextColor(COLOR_GRAY)
	itemdesc:SetMultiline(true)
	itemdesc:SetWrap(true)
	itemdesc:SetAutoStretchVertical(true)
	itemdesc:SetTextInset(0, 0)
	itemdesc:SetWide(viewer:GetWide() - 16)
	itemdesc:CenterHorizontal()
	itemdesc:SetText("")
	itemdesc:MoveBelow(vbg, 8)
	viewer.m_Desc = itemdesc

	local itemstats, itemsbs, itemsvs = {}, {}, {}
	for i = 1, 10 do
		local itemstat = vgui.Create("DLabel", viewer)
		itemstat:SetFont("ZSBodyTextFont")
		itemstat:SetTextColor(COLOR_GRAY)
		itemstat:SetWide(viewer:GetWide() * 0.35)
		itemstat:SetText("")
		itemstat:CenterHorizontal(0.2)
		itemstat:SetContentAlignment(4)
		
		local itemsb = vgui.Create("ZSItemStatBar", viewer)
		itemsb:SetWide(viewer:GetWide() * 0.35)
		itemsb:SetTall(6 * screenscale)
		itemsb:CenterHorizontal(0.55)
		itemsb:SetVisible(false)
		
		local itemsv = vgui.Create("DLabel", viewer)
		itemsv:SetFont("ZSBodyTextFont")
		itemsv:SetTextColor(COLOR_GRAY)
		itemsv:SetWide(viewer:GetWide() * 0.3)
		itemsv:SetText("")
		itemsv:CenterHorizontal(0.85)
		itemsv:SetContentAlignment(6)
		
		if style then
			-- 新样式布局
			local _, vbgY = vbg:GetPos()
			local rowy = vbgY + vbg:GetTall() + style.iconGap * screenscale + (i - 1) * style.statRowH * screenscale
			-- 视觉分组：从 groupStart 行起额外下移并绘制分组线
			if style.groupStart and i >= style.groupStart then
				rowy = rowy + style.groupGap * screenscale
			end
			
			-- 设置标题样式
			if style.titleFont then
				vtitle:SetFont(style.titleFont)
			end
			if style.titleColor then
				vtitle:SetTextColor(style.titleColor)
			end
			
			-- 属性文字加大（原 15px 过小），数值列加宽避免显示不全
			itemstat:SetFont("zs_wortharsenal")
			itemsv:SetFont("zs_wortharsenal")
			itemstat:SetTextInset(0, 0)
			itemsv:SetTextInset(0, 0)
			
			-- 设置统计条高度
			itemsb:SetTall(style.barTall * screenscale)
			
			-- 分组分隔线（位于分组起点上方）
			if style.groupStart and i == style.groupStart then
				local gline = vgui.Create("DPanel", viewer)
				gline:SetPos(8 * screenscale, rowy - style.groupGap * screenscale * 0.5 - 1)
				gline:SetSize(viewer:GetWide() - 16 * screenscale, 1)
				gline.Paint = function(self, w, h)
					surface.SetDrawColor(255, 255, 255, 70)
					surface.DrawRect(0, 0, w, h)
				end
			end
			
			-- 设置位置
			itemstat:SetPos(8 * screenscale, rowy)
			itemstat:SetWide(viewer:GetWide() * 0.28)
			
			local barx = viewer:GetWide() * 0.40
			local bary = rowy + (style.statRowH * screenscale - itemsb:GetTall()) / 2
			itemsb:SetPos(barx, bary)
			itemsb:SetWide(viewer:GetWide() * 0.30)
			
			local valx = viewer:GetWide() - 8 * screenscale - viewer:GetWide() * 0.24
			itemsv:SetPos(valx, rowy)
			itemsv:SetWide(viewer:GetWide() * 0.24)
			
			-- 分隔符
			if style.separator then
				local separator = vgui.Create("DLabel", viewer)
				separator:SetFont("ZSBodyTextFont")
				separator:SetText("-----")
				separator:SetTextColor(Color(110, 110, 110, 200))
				separator:SetPos(viewer:GetWide() * 0.30, rowy + 2)
				separator:SetWide(viewer:GetWide() * 0.07)
				separator:SetContentAlignment(5)
			end
		else
			-- 旧样式布局（保持向后兼容）
			itemstat:MoveBelow(i == 1 and vbg or itemstats[i-1], (i == 1 and 140 or 6) * screenscale)
			
			itemsb:MoveBelow(i == 1 and vbg or itemstats[i-1], ((i == 1 and 140 or 6) + 5) * screenscale)
			
			itemsv:MoveBelow(i == 1 and vbg or itemstats[i-1], (i == 1 and 140 or 6) * screenscale)
		end
		
		table.insert(itemstats, itemstat)
		table.insert(itemsbs, itemsb)
		table.insert(itemsvs, itemsv)
	end
	viewer.ItemStats = itemstats
	viewer.ItemStatValues = itemsvs
	viewer.ItemStatBars = itemsbs
end

-- 菜单类型常量
MENU_POINTSHOP = 1
MENU_WORTH = 2
MENU_REMANTLER = 3

-- ============================================================================
-- CreateItemInfoViewer - 创建物品信息查看器框架
-- ============================================================================
function GM:CreateItemInfoViewer(frame, propertysheet, topspace, bottomspace, menutype, viewerWidth, tabHeight)
	local __, topy = topspace:GetPos()
	local ___, boty = bottomspace:GetPos()
	local screenscale = BetterScreenScale()

	local worthmenu = menutype == MENU_WORTH
	local remantler = menutype == MENU_REMANTLER

	local viewer = vgui.Create("DPanel", frame)

	viewer:SetPaintBackground(false)
	if worthmenu then
		viewer.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 110))
		end
	end
	local viewerwid
	if remantler then
		viewerwid = frame:GetWide() * 0.40
	elseif worthmenu then
		viewerwid = viewerWidth or frame:GetWide() * 0.30
	else
		viewerwid = frame:GetWide() - propertysheet:GetWide() - 16 * screenscale
	end
	viewer:SetSize(viewerwid, boty - topy - 8 - topspace:GetTall())

	viewer:MoveBelow(topspace, 4)
	if worthmenu then
		viewer:AlignRight(8)
		if tabHeight then
			local x, y = viewer:GetPos()
			viewer:SetPos(x, y + tabHeight + 2)
			viewer:SetTall(viewer:GetTall() - tabHeight - 2)
		end
	elseif menutype == MENU_POINTSHOP then
		viewer:MoveRightOf(propertysheet, 8)
	else
		viewer:Dock(RIGHT)
	end
	frame.Viewer = viewer

	-- 为价值菜单创建样式表
	local viewerstyle
	if worthmenu then
		viewerstyle = {
			titleFont = "ZSHUDFontTiny",
			titleColor = COLOR_WHITE,
			-- Worth 菜单使用 2D 图标而不是 3D 模型
			iconW = 0.96, -- 图标宽度（相对于查看器宽度的比例）
			iconH = 300,    -- 图标高度
			iconGap = 12, -- 图标与属性条之间的间距
			statRowH = 24, -- 每行属性条高度
			barTall = 8, -- 属性条高度
			separator = false,
			groupStart = 0,  -- 第 8 行（精度/机动组）前插入视觉分组
			groupGap = 12,
		}
	end
	self:CreateItemViewerGenericElems(viewer, viewerstyle)

	-- 购买按钮
	local purchaseb = vgui.Create("DButton", viewer)
	purchaseb:SetText("")
	purchaseb:SetSize(viewer:GetWide() / 2, 54 * screenscale)
	purchaseb:SetVisible(false)
	viewer.m_PurchaseB = purchaseb

	local namelab = EasyLabel(purchaseb, translate.Get("arsenal_Purchase"), "ZSBodyTextFontBig", COLOR_WHITE)

	namelab:SetVisible(false)
	viewer.m_PurchaseLabel = namelab

	local pricelab = EasyLabel(purchaseb, "", "ZSBodyTextFont", COLOR_WHITE)
	pricelab:SetVisible(false)
	viewer.m_PurchasePrice = pricelab

	-- 弹药购买按钮
	local ammopb = vgui.Create("DButton", viewer)
	ammopb:SetText("")
	ammopb:SetSize(viewer:GetWide() / 4, 54 * screenscale)
	ammopb:SetVisible(false)
	viewer.m_AmmoB = ammopb

	namelab = EasyLabel(ammopb, translate.Get("arsenal_Ammo"), "ZSBodyTextFontBig", COLOR_WHITE)

	namelab:SetVisible(false)
	viewer.m_AmmoL = namelab

	pricelab = EasyLabel(ammopb, "", "ZSBodyTextFont", COLOR_WHITE)
	pricelab:SetVisible(false)
	viewer.m_AmmoPrice = pricelab
end

-- ============================================================================
-- OpenArsenalMenu - 打开积分商店主窗口
-- ============================================================================
function GM:OpenArsenalMenu()
	if self.ArsenalInterface and self.ArsenalInterface:IsValid() then
		self.ArsenalInterface:SetVisible(true)
		self.ArsenalInterface:CenterMouse()
		return
	end

	local screenscale = BetterScreenScale()
	local wid, hei = math.min(ScrW(), 900) * screenscale, math.min(ScrH(), 800) * screenscale
	local tabhei = 24 * screenscale

	-- 创建主窗口框架
	local frame = vgui.Create("DFrame")
	frame:SetSize(wid, hei)
	frame:Center()
	frame:SetDeleteOnClose(false)
	frame:SetTitle(" ")
	frame:SetDraggable(false)
	if frame.btnClose and frame.btnClose:IsValid() then frame.btnClose:SetVisible(false) end
	if frame.btnMinim and frame.btnMinim:IsValid() then frame.btnMinim:SetVisible(false) end
	if frame.btnMaxim and frame.btnMaxim:IsValid() then frame.btnMaxim:SetVisible(false) end
	frame.CenterMouse = ArsenalMenuCenterMouse
	frame.Think = ArsenalMenuThink
	self.ArsenalInterface = frame

	-- 顶部空间：标题、副标题、快速购买开关
	local topspace = vgui.Create("DPanel", frame)
	topspace:SetWide(wid - 16)

	local title = EasyLabel(topspace, translate.Get("arsenal_PointsShopTitle"), "ZSHUDFontSmall", COLOR_WHITE)
	title:CenterHorizontal()
	local subtitle = EasyLabel(topspace, translate.Get("arsenal_PointsShopSubtitle"), "ZSHUDFontTiny", COLOR_WHITE)
	
	subtitle:CenterHorizontal()
	subtitle:MoveBelow(title, 4)

	-- 快速购买开关（自定义 iOS 风格切换按钮）
	local QuickBuyButton = vgui.Create("DCheckBox", topspace)
	QuickBuyButton:SetSize(80 * screenscale, 30* screenscale)
	QuickBuyButton:SetText(""..translate.Get("Option_AlwaysQuickBuy"))
	QuickBuyButton:SetFont("ZSHUDFontSmallest")
	QuickBuyButton.DoClick = quickbuyDoClick

	QuickBuyButton:SetConVar("zs_alwaysquickbuy")

    local convar_state = GetConVar("zs_alwaysquickbuy"):GetBool()
    QuickBuyButton:SetValue(convar_state)
	QuickBuyButton.animProgress = QuickBuyButton:GetChecked() and 1 or 0
    QuickBuyButton.lastAnimTime = CurTime()
    QuickBuyButton.Paint = function(self, w, h)
        local checked = self:GetChecked()
        local targetProgress = checked and 1 or 0
        local deltaTime = CurTime() - self.lastAnimTime
        self.lastAnimTime = CurTime()
        self.animProgress = Lerp(deltaTime * 12, self.animProgress, targetProgress)

        local padding = 3
        local knobSize = h - padding * 2

        local COLOR_TRACK_OFF = Color(80, 85, 95, 255)
		local COLOR_TRACK_ON = Color(155, 155, 155, 255)
        local COLOR_KNOB_OFF = Color(180, 185, 195, 255)
        local COLOR_KNOB_ON = Color(255, 255, 255, 255)

        local trackColor = Color(
            Lerp(self.animProgress, COLOR_TRACK_OFF.r, COLOR_TRACK_ON.r),
            Lerp(self.animProgress, COLOR_TRACK_OFF.g, COLOR_TRACK_ON.g),
            Lerp(self.animProgress, COLOR_TRACK_OFF.b, COLOR_TRACK_ON.b)
        )
        local knobColor = Color(
            Lerp(self.animProgress, COLOR_KNOB_OFF.r, COLOR_KNOB_ON.r),
            Lerp(self.animProgress, COLOR_KNOB_OFF.g, COLOR_KNOB_ON.g),
            Lerp(self.animProgress, COLOR_KNOB_OFF.b, COLOR_KNOB_ON.b)
        )

        if self:IsHovered() then
            trackColor.r = math.min(255, trackColor.r + 20)
            trackColor.g = math.min(255, trackColor.g + 20)
            trackColor.b = math.min(255, trackColor.b + 20)
        end

        local startX = padding
        local endX = w - knobSize - padding
        local knobX = Lerp(self.animProgress, startX, endX)

        draw.RoundedBoxEx(h / 2, 0, 0, w, h, trackColor)
        draw.RoundedBoxEx(knobSize / 2, knobX, padding, knobSize, knobSize, knobColor)
    end

	local _, y = subtitle:GetPos()
	topspace:SetTall(y + subtitle:GetTall() + 4)
	topspace:AlignTop(8)
	topspace:CenterHorizontal()

	-- 价值菜单按钮
	local wsb = EasyButton(topspace, translate.Get("arsenal_WorthMenu"), 8, 4)

	wsb:SetFont("ZSHUDFontSmaller")
	wsb:SizeToContents()
	wsb:AlignRight(8)
	wsb:AlignTop(8)
	wsb.DoClick = worthmenuDoClick

	-- 底部空间：剩余积分显示
	local bottomspace = vgui.Create("DPanel", frame)
	bottomspace:SetWide(topspace:GetWide())

	local pointslabel = EasyLabel(bottomspace, translate.Get("arsenal_PointsToSpend") .. "0", "ZSHUDFontTiny", COLOR_GREEN)

	pointslabel:AlignTop(4)
	pointslabel:AlignLeft(8)
	pointslabel.Think = pointslabelThink

	local lab = EasyLabel(bottomspace, " ", "ZSHUDFontTiny")
	lab:AlignTop(4)
	lab:AlignRight(4)
	frame.m_SpacerBottomLabel = lab

	_, y = lab:GetPos()
	bottomspace:SetTall(y + lab:GetTall() + 4)
	bottomspace:AlignBottom(8)
	bottomspace:CenterHorizontal()

	local __, topy = topspace:GetPos()
	local ___, boty = bottomspace:GetPos()

	-- 创建分页属性表（按物品类别分页）
	local propertysheet = vgui.Create("DPropertySheet", frame)
	propertysheet:SetSize(wid - 320 * screenscale, boty - topy - 8 - topspace:GetTall())
	propertysheet:MoveBelow(topspace, 4)
	propertysheet:SetPadding(1)
	propertysheet:CenterHorizontal(0.33)

	-- 遍历物品类别，为每个类别创建标签页
	for catid, catname in ipairs(GAMEMODE.ItemCategories) do
		local hasitems = false
		for i, tab in ipairs(GAMEMODE.Items) do
			if tab.Category == catid and tab.PointShop then
				hasitems = true
				break
			end
		end

		if hasitems then
			local tabpane = vgui.Create("DPanel", propertysheet)
			tabpane.Paint = function() end
			tabpane.Grids = {}
			tabpane.Buttons = {}

			local usecats = catid == ITEMCAT_GUNS or catid == ITEMCAT_MELEE or catid == ITEMCAT_TRINKETS
			local trinkets = catid == ITEMCAT_TRINKETS
			local offset = 64 * screenscale

			local itemframe = vgui.Create("DScrollPanel", tabpane)
			itemframe:SetSize(propertysheet:GetWide(), propertysheet:GetTall() - (usecats and (32 + offset) or 32))
			itemframe:SetPos(0, usecats and offset or 0)

			-- 创建网格布局辅助函数
			local mkgrid = function()
				local list = vgui.Create("DGrid", itemframe)
				list:SetPos(0, 0)
				list:SetSize(propertysheet:GetWide() - 312, propertysheet:GetTall())
				list:SetCols(2)
				list:SetColWide(280 * screenscale)
				list:SetRowHeight((trinkets and 64 or 100) * screenscale)

				return list
			end

			local subcats = GAMEMODE.ItemSubCategories
			if usecats then
				-- 子分类标签按钮（Tier 1-5 或饰品子类）
				local ind, tbn = 1
				for i = ind, (trinkets and #subcats or 5) do
					local ispacer = trinkets and ((i-1) % 3)+1 or i
					local start = i == (catid == ITEMCAT_GUNS and 2 or ind)

					tbn = EasyButton(tabpane, trinkets and subcats[i] or ("Tier " .. i), 2, 8)
					tbn:SetFont(trinkets and "ZSHUDFontSmallest" or "ZSHUDFontSmall")
					tbn:SetAlpha(start and 255 or 70)
					tbn:AlignRight((trinkets and -35 or -15) * screenscale -
						(ispacer - ind) * (ind == 1 and (trinkets and 190 or 110) or 145) * screenscale
					)
					tbn:AlignTop(trinkets and i <= 3 and 0 or trinkets and 28 or 16)
					tbn:SetContentAlignment(5)
					tbn:SizeToContents()
					tbn.DoClick = function(me)
						for k, v in pairs(tabpane.Grids) do
							v:SetVisible(k == i)
							tabpane.Buttons[k]:SetAlpha(k == i and 255 or 70)
						end
					end

					tabpane.Grids[i] = mkgrid()
					tabpane.Grids[i]:SetVisible(start)
					tabpane.Buttons[i] = tbn
				end
			else
				tabpane.Grid = mkgrid()
			end

			local sheet = propertysheet:AddSheet(catname, tabpane, GAMEMODE.ItemCategoryIcons[catid], false, false)
			sheet.Panel:SetPos(0, tabhei + 2)

			-- 将物品添加到对应的网格
			for i, tab in ipairs(GAMEMODE.Items) do
				if tab.PointShop and tab.Category == catid then
					self:AddShopItem(
						trinkets and tabpane.Grids[tab.SubCategory] or tabpane.Grid or tabpane.Grids[tab.Tier or 1],
						i, tab
					)
				end
			end

			-- 配置标签按钮样式
			local scroller = propertysheet:GetChildren()[1]
			local dragbase = scroller:GetChildren()[1]
			local tabs = dragbase:GetChildren()

			self:ConfigureMenuTabs(tabs, tabhei)
		end
	end

	self:CreateItemInfoViewer(frame, propertysheet, topspace, bottomspace, MENU_POINTSHOP)

	frame:MakePopup()
	frame:CenterMouse()
end
