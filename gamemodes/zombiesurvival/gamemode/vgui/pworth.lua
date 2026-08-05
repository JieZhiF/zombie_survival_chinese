-- ============================================================================
-- PWorth - 价值/起始装备菜单（开局购买界面）
-- 玩家可以在开局前使用 Worth 点数购买装备
-- 支持保存/加载配置方案、快速购买、随机装备等功能
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 价值菜单主窗口
-- [位置] MakepWorth()
-- [作用] 创建三栏主窗口并管理生命周期
-- [常改] 窗口尺寸、背景、三栏宽度分配
--
-- [区域] 左侧购物车
-- [位置] cartpanel / cartlist / UpdateCurrentCart()
-- [作用] 显示已选物品，空状态居中提示，每项含移除按钮
-- [常改] 条目高度、空状态样式、移除按钮
--
-- [区域] 中间分类浏览
-- [位置] propertysheet / 物品分页 / ZSWorthButton
-- [作用] 收藏夹方案页 + 按类别网格展示可购物品
-- [常改] 网格列数、卡片尺寸、标签样式
--
-- [区域] 右侧详情查看器
-- [位置] GAMEMODE:CreateItemInfoViewer() (parsenal.lua 定义)
-- [作用] 图标/属性条/描述，由 ZSWorthButton:OnCursorEntered 驱动
-- [常改] 查看器宽度、图标尺寸
--
-- [区域] 底部操作栏
-- [位置] worthlab / checkout / randombutton / clearbutton
-- [作用] 剩余价值显示与结账/随机/清空按钮
-- [常改] 按钮尺寸、颜色、文字
--
-- [区域] 方案管理
-- [位置] SaveDoClick() / LoadDoClick() / DeleteDoClick() / QuickCheckDoClick()
--        / DefaultDoClick() / SaveCurrentCart() / LoadCart()
-- [作用] 收藏夹方案的保存/加载/删除/快速购买/默认方案
-- [常改] 方案文件读写、按钮图标
-- ============================================================================

-- ============================================================================
-- Worth 界面结构索引
-- 左侧：MakepWorth() 内的 cartpanel/cartlist，显示已选择的购买物品
-- 中间：MakepWorth() 内的 propertysheet/grid，显示分类标签和武器购买卡片
-- 右侧：由 parsenal.lua 的 CreateItemInfoViewer() 创建，显示图标、属性和描述
-- 底部：Worth 数值、Checkout、Clear、Random 操作按钮
-- 交互：ZSWorthButton:OnCursorEntered() 更新右侧详情，DoClick() 更新购物车和余额
-- ============================================================================

-- ============================================================================
-- InitialWorthMenu - 等待技能加载完成后打开价值菜单
-- ============================================================================
function InitialWorthMenu()
	timer.Create("WaitUntilSkillsLoaded", 0, 0, function()
		if GAMEMODE.ReceivedInitialSkills then
			timer.Remove("WaitUntilSkillsLoaded")
			MakepWorth()
		end
	end)
end

-- 第一波开始时关闭价值菜单
hook.Add("SetWave", "CloseWorthOnWave1", function(wave)
	if wave > 0 then
		if pWorth and pWorth:IsValid() then
			pWorth:Close()
		end

		hook.Remove("SetWave", "CloseWorthOnWave1")
	end
end)

-- 额外起始价值（由服务器网络设置）
local ExtraStartingWorth = 0

-- 面板背景/悬停/选中颜色
-- 必须声明在 UpdateCurrentCart 之前，否则其内部 Paint 闭包会把 colBG/colHover 解析为 nil 全局变量
local colBG = Color(25, 25, 25, 110)
local colHover = Color(255, 255, 255, 10)
local colSelLine = Color(50, 255, 50, 255)

-- ============================================================================
-- GetStartingWorth - 获取总起始价值
-- ============================================================================
local function GetStartingWorth()
	return GAMEMODE.StartingWorth + ExtraStartingWorth
end

-- 接收服务器发送的额外起始价值
net.Receive(NET_MSG.EXTRASTARTINGWORTH, function(len)
	ExtraStartingWorth = net.ReadUInt(16)
end)

-- 默认方案客户端变量
local cvarDefaultCart = CreateClientConVar("zs_defaultcart", "", true, false)

-- ============================================================================
-- DefaultDoClick - 设置/取消默认方案
-- ============================================================================
local function DefaultDoClick(btn)
	if cvarDefaultCart:GetString() == btn.Name then
		RunConsoleCommand("zs_defaultcart", "")
		surface.PlaySound("buttons/button11.wav")
	else
		RunConsoleCommand("zs_defaultcart", btn.Name)
		surface.PlaySound("buttons/button14.wav")
	end

	timer.Simple(0.1, MakepWorth)
end

-- 剩余价值和所有购买按钮
local remainingworth = 0
local WorthButtons = {}

-- ============================================================================
-- Checkout - 结账购买
-- ============================================================================
local function Checkout(tobuy)
	if tobuy and #tobuy > 0 then
		gamemode.Call("SuppressArsenalUpgrades", 1)

		RunConsoleCommand("worthcheckout", unpack(tobuy))

		if pWorth and pWorth:IsValid() then
			pWorth:Close()
		end
	else
		surface.PlaySound("buttons/combine_button_locked.wav")
	end
end

-- ============================================================================
-- CheckoutDoClick - 结账按钮点击
-- ============================================================================
local function CheckoutDoClick(self)
	local tobuy = {}
	for _, btn in pairs(WorthButtons) do
		if btn and btn.On and btn.ID then
			table.insert(tobuy, btn.ID)
		end
	end

	if remainingworth >= 0 then
		Checkout(tobuy)
	else
		surface.PlaySound("buttons/button8.wav")
	end
end

-- ============================================================================
-- RandDoClick - 随机装备按钮
-- ============================================================================
local function RandDoClick(self)
	gamemode.Call("SuppressArsenalUpgrades", 1)

	RunConsoleCommand("worthrandom")

	if pWorth and pWorth:IsValid() then
		pWorth:Close()
	end
end

-- 保存的方案列表（保留旧值以支持 lua_openscript_cl 热重载）
GM.SavedCarts = GM.SavedCarts or {}

-- 从文件加载已保存的方案
hook.Add("Initialize", "LoadCarts", function()
	if file.Exists(GAMEMODE.CartFile, "DATA") then
		GAMEMODE.SavedCarts = Deserialize(file.Read(GAMEMODE.CartFile)) or {}
	end
end)

-- ============================================================================
-- ClearCartDoClick - 清空当前选择
-- ============================================================================
local function ClearCartDoClick()
	for _, btn in ipairs(WorthButtons) do
		if btn.On then
			btn:DoClick(true, true)
		end
	end

	surface.PlaySound("buttons/button11.wav")
end

-- ============================================================================
-- ClickWorthButton - 模拟点击指定 ID 的价值按钮
-- ============================================================================
local function ClickWorthButton(id)
	local result = true
	for _, btn in pairs(WorthButtons) do
		if btn and (btn.ID == id or btn.Signature == id) then
			result = btn:DoClick(true, true)
			break
		end
	end
	return result
end

-- ============================================================================
-- LoadCart - 加载方案
-- ============================================================================
local function LoadCart(cartid, silent)
	if not GAMEMODE.SavedCarts[cartid] then return end

	MakepWorth()

	for _, id in pairs(GAMEMODE.SavedCarts[cartid][2]) do
		if not ClickWorthButton(id) then
			surface.PlaySound("buttons/button8.wav")
			return false
		end
	end

	if not silent then
		surface.PlaySound("buttons/combine_button1.wav")
	end

	return true
end

-- ============================================================================
-- LoadDoClick - 加载方案按钮点击
-- ============================================================================
local function LoadDoClick(self)
	LoadCart(self.ID)
end

-- ============================================================================
-- SaveCurrentCart - 保存当前选择为方案
-- ============================================================================
local function SaveCurrentCart(name)
	local tobuy = {}
	for _, btn in pairs(WorthButtons) do
		if btn and btn.On and btn.ID then
			table.insert(tobuy, FindStartingItem(btn.ID).Signature)
		end
	end

	for i, cart in ipairs(GAMEMODE.SavedCarts) do
		if string.lower(cart[1]) == string.lower(name) then
			cart[1] = name
			cart[2] = tobuy

			file.Write(GAMEMODE.CartFile, Serialize(GAMEMODE.SavedCarts))
			print(string.format(translate.Get("Worth_SavedCart"), tostring(name)))

			LoadCart(i, true)
			return
		end
	end

	GAMEMODE.SavedCarts[#GAMEMODE.SavedCarts + 1] = {name, tobuy}

	file.Write(GAMEMODE.CartFile, Serialize(GAMEMODE.SavedCarts))
	print(string.format(translate.Get("Worth_SavedCart"), tostring(name)))

	LoadCart(#GAMEMODE.SavedCarts, true)
end

-- ============================================================================
-- SaveDoClick - 保存方案按钮点击
-- ============================================================================
local function SaveDoClick(self)
    local frame = Derma_StringRequest(
        translate.Get("Worth_SaveCart"),
        translate.Get("Worth_EnterCartName"),
        translate.Get("Worth_DefaultName"),
        function(strTextOut) SaveCurrentCart(strTextOut) end,
        function(strTextOut) end,
        translate.Get("Worth_OK"),
        translate.Get("Worth_Cancel")
    )

    frame:GetChildren()[5]:GetChildren()[2]:SetTextColor(Color(30, 30, 30))
end

-- ============================================================================
-- DeleteDoClick - 删除方案
-- ============================================================================
local function DeleteDoClick(self)
	if GAMEMODE.SavedCarts[self.ID] then
		table.remove(GAMEMODE.SavedCarts, self.ID)
		file.Write(GAMEMODE.CartFile, Serialize(GAMEMODE.SavedCarts))
		surface.PlaySound("buttons/button19.wav")
		MakepWorth()
	end
end

-- ============================================================================
-- QuickCheckDoClick - 快速结账：加载方案并直接购买
-- ============================================================================
local function QuickCheckDoClick(self)
	if GAMEMODE.SavedCarts[self.ID] and LoadCart(self.ID, true) then
		Checkout(GAMEMODE.SavedCarts[self.ID][2])
	end
end

-- ============================================================================
-- WorthThink - 检查玩家是否仍为人类，否则关闭
-- ============================================================================
local function WorthThink(self)
	if MySelf:Team() ~= TEAM_HUMAN then
		self:Close()
		hook.Remove("WorthButtonChanged", "UpdateCurrentCart")
	end
end

-- ============================================================================
-- MakepWorth - 创建价值菜单主窗口
-- ============================================================================
function MakepWorth()
	if pWorth and pWorth:IsValid() then
		pWorth:Remove()
		pWorth = nil
	end

	WorthButtons = {}
	remainingworth = GetStartingWorth()

	local screenscale = BetterScreenScale()
	local wid, hei = ScrW() * 0.667, ScrH() * 0.833
	local tabhei = 30 * screenscale

	local frame = vgui.Create("DFrame")
	pWorth = frame
	frame:SetSize(wid, hei)
	frame:SetDeleteOnClose(true)
	frame:SetKeyboardInputEnabled(false)
	frame:SetTitle(" ")
	frame.Paint = function(self, w, h)
		-- 半透明背景，游戏画面可见（v4.0: alpha 150-190）
		draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 200))
		--draw.RoundedBox(6, 1, 1, w - 2, h - 2, Color(255, 255, 255, 0))
		--[[
		draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 190))
		draw.RoundedBox(6, 1, 1, w - 2, h - 2, Color(255, 255, 255, 8))
		]]
	end
	frame.Think = WorthThink

	-- 顶部空间
	local topspace = vgui.Create("DPanel", frame)
	topspace:SetWide(wid * 0.75)
	topspace:SetPaintBackground(false)

	local title = EasyLabel(topspace, translate.Get("Worth_MenuTitle"), "DermaLarge", COLOR_WHITE)
	title:CenterHorizontal()
	local subtitle = EasyLabel(topspace, translate.Get("Worth_MenuSubtitle"), "DermaDefault", COLOR_WHITE)
	subtitle:CenterHorizontal()
	subtitle:MoveBelow(title, 4)

	local _, y = subtitle:GetPos()
	topspace:SetTall(math.max(1, (y + subtitle:GetTall() + 4) * 0.85))
	topspace:AlignTop(8)
	topspace:CenterHorizontal()

	-- 底部空间
	local bottomspace = vgui.Create("DPanel", frame)
	bottomspace:SetWide(topspace:GetWide())
	bottomspace:SetPaintBackground(false)

	local lab = EasyLabel(bottomspace, " ", "ZSHUDFontTiny")
	lab:AlignTop(4)
	lab:AlignRight(4)
	frame.m_SpacerBottomLabel = lab

	_, y = lab:GetPos()
	bottomspace:SetTall(y + lab:GetTall() + 4)
	bottomspace:AlignBottom(16)
	bottomspace:CenterHorizontal()

	local __, topy = topspace:GetPos()
	local ___, boty = bottomspace:GetPos()

	local panelgap = 8 * screenscale
	local cartwid = wid * 0.18
	local browserwid = 700
	-- 查看器与 propertysheet 的间隙 = panelgap*2 + 8 + 4*ss - 2*panelgap - 8 = 4*ss（原为 2*panelgap-8 ≈ 12px）
	local viewerwid = wid - cartwid - browserwid - panelgap * 2 - 8 - 4 * screenscale
	local minviewerwid = 320 * screenscale
	if viewerwid < minviewerwid then
		viewerwid = minviewerwid
		browserwid = wid - cartwid - viewerwid - panelgap * 2 - 8 - 4 * screenscale
	end
	local contenttall = boty - topy - 8 - topspace:GetTall()
	local middlewid = browserwid  -- 浏览器宽度固定

	-- 三栏主体：cartpanel（左）| propertysheet（中）| Viewer（右）
	-- 左侧当前购物车面板
	local cartpanel = vgui.Create("DPanel", frame)
	cartpanel:SetSize(cartwid, contenttall)
	cartpanel:SetPos(panelgap, topy + topspace:GetTall() + 4)
	cartpanel:SetPaintBackground(false)
	cartpanel.Paint = function(self, w, h)
		-- 清单风格：淡背景，不抢视觉中心
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
	end
	frame.CartPanel = cartpanel

	local cartlist = vgui.Create("DPanelList", cartpanel)
	cartlist:SetSize(cartwid - 8, contenttall)
	cartlist:SetPos(4, 0)
	cartlist:EnableVerticalScrollbar(true)
	cartlist:SetSpacing(1)
	cartlist:SetPadding(2)

	-- 当前购物车更新函数
	local function UpdateCurrentCart()
		cartlist:Clear()

		local cartitems = {}
		for _, btn in pairs(WorthButtons) do
			if btn and btn.On and btn.ID then
				table.insert(cartitems, btn)
			end
		end

		if #cartitems == 0 then
			-- 空状态：撑满列表高度并居中显示，避免悬在顶部
			local emptylabel = EasyLabel(cartlist, translate.Get("Worth_CartEmpty"), "ZSHUDFontSmallest", COLOR_GRAY)
			emptylabel:SetWrap(true)
			emptylabel:SetMultiline(true)
			emptylabel:SetWide(cartlist:GetWide() - 8)
			emptylabel:SetTall(cartlist:GetTall() - 8)
			emptylabel:SetContentAlignment(5)
			cartlist:AddItem(emptylabel)
		else
			for _, btn in ipairs(cartitems) do
				local tab = FindStartingItem(btn.ID)
				if tab then
					local cartitem = vgui.Create("DPanel")
					local itemhei = 72 * screenscale
					cartitem:SetSize(cartlist:GetWide(), itemhei)
					cartitem.Paint = function(self, w, h)
						draw.RoundedBox(2, 1, 1, w - 2, h - 2, colBG)
						if self.Hovered then
							draw.RoundedBox(2, 1, 1, w - 2, h - 2, colHover)
						end
					end

					local screenscale = BetterScreenScale()

					-- 移除按钮：内缩留呼吸空间，低透明度 hover 显示
					local removebutton = vgui.Create("DButton", cartitem)
					removebutton:SetText("x")
					removebutton:SetFont("ZSHUDFontTiny")
					removebutton:SetSize(16 * screenscale, 16 * screenscale)
					removebutton:SetPos(cartitem:GetWide() - removebutton:GetWide() - 8, 4)
					removebutton:SetTextColor(COLOR_RED)
					removebutton.Paint = function(self, w, h)
						self:SetAlpha(self:IsHovered() and 255 or 70)
					end
					removebutton.DoClick = function()
						btn:DoClick(true, true)
					end

					-- 物品图标（左侧紧凑显示）
					local iconpanel = vgui.Create("DPanel", cartitem)
					iconpanel:SetSize(44 * screenscale, 32 * screenscale)
					iconpanel:SetPos(6 * screenscale, (itemhei - 32 * screenscale) * 0.5)
					iconpanel.Paint = function() end

					local kitbl = killicon.Get(GAMEMODE.ZSInventoryItemData[tab.SWEP] and "weapon_zs_craftables" or tab.SWEP or tab.Model)
					if kitbl and #kitbl == 2 then
						local img = vgui.Create("DImage", iconpanel)
						img:SetImage(kitbl[1])
						if kitbl[2] then img:SetImageColor(kitbl[2]) end
						img:SizeToContents()
						local natw, nath = img:GetWide(), img:GetTall()
						local scale = math.min(iconpanel:GetWide() / natw, iconpanel:GetTall() / nath, 1)
						img:SetSize(natw * scale, nath * scale)
						img:Center()
					elseif kitbl and #kitbl == 3 then
						local label = vgui.Create("DLabel", iconpanel)
						label:SetText(kitbl[2])
						local iconfont = kitbl[1] .. "cart"
						surface.CreateFont(iconfont, {font = kitbl[1]:match("cs$") and "csd" or "HL2MP", size = iconpanel:GetTall(), weight = 100, antialias = true})
						label:SetFont(iconfont)
						label:SetTextColor(kitbl[3] or color_white)
						label:SizeToContents()
						label:Center()
					elseif tab.Model then
						local mdlpanel = vgui.Create("DModelPanel", iconpanel)
						mdlpanel:SetSize(iconpanel:GetSize())
						mdlpanel:SetModel(tab.Model)
						local mins, maxs = mdlpanel.Entity:GetRenderBounds()
						mdlpanel:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
						mdlpanel:SetLookAt((mins + maxs) / 2)
					end

					-- 价格标签
					local pricelabel = EasyLabel(cartitem, tostring(tab.Price).." "..translate.Get("Worth"), "ZSHUDFontTiny", COLOR_LIMEGREEN)
					pricelabel:SetPos(58 * screenscale, 4)

					-- 弹药类型图标
					local sweptable = tab.SWEP and (GAMEMODE.ZSInventoryItemData[tab.SWEP] or weapons.Get(tab.SWEP))
					if sweptable and sweptable.Primary and sweptable.Primary.Ammo and GAMEMODE.AmmoIcons[string.lower(sweptable.Primary.Ammo)] then
						local lower = string.lower(sweptable.Primary.Ammo)
						local ki = killicon.Get(GAMEMODE.AmmoIcons[lower])
						local ammoicon = vgui.Create("DImage", cartitem)
						ammoicon:SetImage(ki[1])
						if ki[2] then ammoicon:SetImageColor(ki[2]) end
						ammoicon:SetSize(18 * screenscale, 18 * screenscale)
						ammoicon:SetPos(58 * screenscale, 4)
						pricelabel:SetPos(58 * screenscale + 18 * screenscale + 4, 4)
					end

					-- 物品名称
					local namelabel = EasyLabel(cartitem, tab.Name or "", "ZSHUDFontTiny", COLOR_WHITE)
					namelabel:SetWrap(true)
					namelabel:SetMultiline(true)
					namelabel:SetAutoStretchVertical(false)
					namelabel:SetContentAlignment(4)
					namelabel:SetPos(58 * screenscale, 25 * screenscale)
					namelabel:SetSize(cartitem:GetWide() - 66 * screenscale, itemhei - 29 * screenscale)

					cartlist:AddItem(cartitem)
				end
			end
		end
	end

	hook.Add("WorthButtonChanged", "UpdateCurrentCart", function()
		if pWorth and pWorth:IsValid() then
			UpdateCurrentCart()
		end
	end)

	-- 主属性表（中间）- 浏览器
	local propertysheet = vgui.Create("DPropertySheet", frame)
	propertysheet:SetSize(browserwid, contenttall)
	propertysheet:SetPos(panelgap * 2 + cartwid, topy + topspace:GetTall() + 4)
	propertysheet:SetPadding(1)
	propertysheet.Paint = function() end
	frame.PropertySheet = propertysheet

	-- 收藏夹页面（已保存的方案列表）
	local list = vgui.Create("DPanelList", propertysheet)
	local sheet = propertysheet:AddSheet(translate.Get("Favorites_TabTitle"), list, "icon16/heart.png", false, false)
	sheet.Panel:SetPos(0, tabhei + 2)
	list:EnableVerticalScrollbar(true)
	list:SetWide(propertysheet:GetWide() - 16)
	list:SetSpacing(2)
	list:SetPadding(2)
	
	local savebutton = EasyButton(nil, translate.Get("Save_CurrentCart"), 0, 10)
	
	savebutton.DoClick = SaveDoClick
	savebutton:SetFont("ZSHUDFontTiny")
	list:AddItem(savebutton)

	local panfont = "ZSHUDFontSmall"
	local panhei = 50 * screenscale

	local defaultcart = cvarDefaultCart:GetString()

	-- 遍历已保存方案列表
	for i, savetab in ipairs(GAMEMODE.SavedCarts) do
		local cartpan = vgui.Create("DEXRoundedPanel")
		cartpan:SetCursor("pointer")
		cartpan:SetSize(list:GetWide(), panhei)

		local cartname = savetab[1]

		local x = 8
		local limitedscale = math.Clamp(screenscale, 1, 1.5)

		-- 默认方案图标
		if defaultcart == cartname then
			local defimage = vgui.Create("DImage", cartpan)
			defimage:SetImage("icon16/heart.png")
			defimage:SizeToContents()
			defimage:SetSize(16 * limitedscale, 16 * limitedscale)
			defimage:SetMouseInputEnabled(true)
			defimage:SetTooltip(translate.Get("DefaultCartTooltip"))

			defimage:SetPos(x, cartpan:GetTall() * 0.5 - defimage:GetTall() * 0.5)
			x = x + defimage:GetWide() + 4
		end

		-- 方案名称
		local cartnamelabel = EasyLabel(cartpan, cartname, panfont)
		cartnamelabel:SetPos(x, cartpan:GetTall() * 0.5 - cartnamelabel:GetTall() * 0.5)

		x = cartpan:GetWide()

		-- 快速购买按钮
		local checkbutton = vgui.Create("DImageButton", cartpan)
		checkbutton:SetImage("icon16/accept.png")
		checkbutton:SizeToContents()
		checkbutton:SetSize(16 * limitedscale, 16 * limitedscale)
		checkbutton:SetTooltip(translate.Get("Worth_PurchaseSavedCart"))
		x = x - checkbutton:GetWide() - 8
		checkbutton:SetPos(x, cartpan:GetTall() * 0.5 - checkbutton:GetTall() * 0.5)
		checkbutton.ID = i
		checkbutton.DoClick = QuickCheckDoClick

		-- 加载方案按钮
		local loadbutton = vgui.Create("DImageButton", cartpan)
		loadbutton:SetImage("icon16/folder_go.png")
		loadbutton:SizeToContents()
		loadbutton:SetSize(16 * limitedscale, 16 * limitedscale)
		loadbutton:SetTooltip(translate.Get("Worth_LoadSavedCart"))
		x = x - loadbutton:GetWide() - 8
		loadbutton:SetPos(x, cartpan:GetTall() * 0.5 - loadbutton:GetTall() * 0.5)
		loadbutton.ID = i
		loadbutton.DoClick = LoadDoClick

		-- 设为默认按钮
		local defaultbutton = vgui.Create("DImageButton", cartpan)
		defaultbutton:SetImage("icon16/heart.png")
		defaultbutton:SizeToContents()
		defaultbutton:SetSize(16 * limitedscale, 16 * limitedscale)
		if cartname == defaultcart then
			defaultbutton:SetTooltip(translate.Get("Worth_RemoveDefaultCart"))
		else
			defaultbutton:SetTooltip(translate.Get("Worth_SetDefaultCart"))
		end
		x = x - defaultbutton:GetWide() - 8
		defaultbutton:SetPos(x, cartpan:GetTall() * 0.5 - defaultbutton:GetTall() * 0.5)
		defaultbutton.Name = cartname
		defaultbutton.DoClick = DefaultDoClick

		-- 删除方案按钮
		local deletebutton = vgui.Create("DImageButton", cartpan)
		deletebutton:SetImage("icon16/bin.png")
		deletebutton:SizeToContents()
		deletebutton:SetSize(16 * limitedscale, 16 * limitedscale)
		deletebutton:SetTooltip(translate.Get("Worth_DeleteSavedCart"))
		x = x - deletebutton:GetWide() - 8
		deletebutton:SetPos(x, cartpan:GetTall() * 0.5 - loadbutton:GetTall() * 0.5)
		deletebutton.ID = i
		deletebutton.DoClick = DeleteDoClick

		list:AddItem(cartpan)
	end

	-- 按类别创建物品分页
	for catid, catname in ipairs(GAMEMODE.ItemCategories) do
		local itemframe = vgui.Create("DScrollPanel", propertysheet)
		local trinkets = catid == ITEMCAT_TRINKETS

		-- 滚动条宽度减半（默认 16px → 8px），canvas 按 VBar:GetWide() 自动加宽
		itemframe:GetVBar():SetWide(8 * screenscale)
		-- 滚动条样式：透明轨道 + 半透明白色圆角滑块（隐藏上下箭头按钮）
		local vbar = itemframe:GetVBar()
		vbar:SetHideButtons(true)
		vbar.Paint = function(self, w, h)
			draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 15))
		end
		vbar.btnGrip.Paint = function(self, w, h)
			local alpha = self.Depressed and 140 or (self.Hovered and 110 or 70)
			draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, alpha))
		end

		local grid = vgui.Create("DGrid", itemframe)
		-- 满宽网格 + 紧密间距（目标图信息密度：一屏显示更多武器）
		grid:SetSize(propertysheet:GetWide() - 4, propertysheet:GetTall() - 16) --
		grid:SetCols(2) -- 2 列，保证每个物品卡片宽度足够显示图标和文字
		grid:SetColWide((propertysheet:GetWide() ) / 2)
		grid:SetRowHeight((trinkets and 64 or 88) * screenscale + 8)

		local catsheet = propertysheet:AddSheet(catname, itemframe, GAMEMODE.ItemCategoryIcons[catid], false, false)
		catsheet.Panel:SetPos(0, tabhei + 2)

		for i, tab in ipairs(GAMEMODE.Items) do
			if tab.Category == catid and tab.WorthShop then
				local button = vgui.Create("ZSWorthButton")
				button:SetWide(grid:GetColWide())
				button:SetWorthID(i)
				grid:AddItem(button)
				WorthButtons[i] = button
			end
		end
	end

	-- 底部操作栏：剩余价值、结账、随机、清空
	local worthlab = EasyLabel(frame, translate.Get("Worth_Label")..tostring(remainingworth), "DermaLarge", COLOR_YELLOW)
	worthlab:SetPos(8, frame:GetTall() - worthlab:GetTall() - 16)
	frame.WorthLab = worthlab

	local checkout = vgui.Create("DButton", frame)
	checkout:SetFont("ZSHUDFontSmall")
	checkout:SetText(translate.Get("Checkout"))
	checkout:SizeToContents()
	checkout:SetSize(130 * screenscale, 30 * screenscale)
	checkout:AlignBottom(8)
	checkout:CenterHorizontal()
	checkout.DoClick = CheckoutDoClick
	checkout.Paint = function(self, w, h)
		local hover = self.Hovered
		local col = Color(35, 75, 35, 210)
		if hover then col = Color(50, 110, 50, 235) end
		if self.Depressed then col = Color(70, 150, 70, 255) end
		draw.RoundedBox(4, 0, 0, w, h, col)
		if hover then draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(255, 255, 255, 22)) end
		draw.SimpleText(self:GetText(), self:GetFont(), w * 0.5, h * 0.5, Color(240, 255, 240, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local randombutton = vgui.Create("DButton", frame)
	randombutton:SetFont("ZSHUDFontTiny")
	randombutton:SetText(translate.Get("Random"))
	randombutton:SetSize(64 * screenscale, 16 * screenscale)
	randombutton:AlignBottom(8)
	randombutton:AlignRight(8)
	randombutton.DoClick = RandDoClick

	local clearbutton = vgui.Create("DButton", frame)
	clearbutton:SetFont("ZSHUDFontTiny")
	clearbutton:SetText(translate.Get("Clear"))
	clearbutton:SetSize(64 * screenscale, 16 * screenscale)
	clearbutton:AlignBottom(8)
	clearbutton:MoveLeftOf(randombutton, 8)
	clearbutton.DoClick = ClearCartDoClick

	frame.OnClose = function()
		hook.Remove("WorthButtonChanged", "UpdateCurrentCart")
	end

	frame:Center()
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.15, 0)
	frame:MakePopup()

	local scroller = propertysheet:GetChildren()[1]
	local dragbase = scroller:GetChildren()[1]
	local tabs = dragbase:GetChildren()

	GAMEMODE:CreateItemInfoViewer(frame, propertysheet, topspace, bottomspace, MENU_WORTH, viewerwid, tabhei)
	GAMEMODE:ConfigureMenuTabs(tabs, tabhei)

	-- 关闭默认的 5px 负间距，配合下方 tabs 宽度加成实现 12px padding + 5px 间距
	propertysheet.tabScroller:SetOverlap(0)

	-- 标签行不再受 propertysheet 宽度限制：解除 Dock 并移至 frame 层，从中间栏左缘延伸至窗口右缘
	-- 内容网格仍以 propertysheet 宽度布局（dpropertysheet.lua 内部 SetWide），位置不变
	local tabrowx = panelgap * 2 + cartwid                    -- 标签行左起点（= 中间栏左缘）
	local tabrowy = topy + topspace:GetTall() + 4             -- 标签行 y 位置
	local tabroww = frame:GetWide() - tabrowx * 2             -- 标签行总宽度 ← 改这里
	local tabsrc = propertysheet.tabScroller
	tabsrc:Dock(0)
	tabsrc:SetParent(frame)
	tabsrc:SetPos(tabrowx, tabrowy)
	tabsrc:SetWide(tabroww)

	local tabFont = "weapon_name_ssp_small"
	local availW = tabroww
	local equalW = math.floor(availW / math.max(1, #tabs))

	-- 计算指定字体下最宽标签的内容宽度（文字+图标16+左右内边距20）
	local function CalcMaxW(font)
		surface.SetFont(font)
		local maxw = 0
		for _, tab in pairs(tabs) do
			maxw = math.max(maxw, math.ceil(surface.GetTextSize(tab:GetText())) + 36)
		end
		return maxw
	end

	local maxW = CalcMaxW(tabFont)
	-- 最宽标签放不下等宽时按 2px 步进缩小字体，保证所有标签等宽且文字完整显示
	if maxW > equalW then
		local conf = ZSFontDLC.GetConfig()["weapon_name_ssp_small"]
		local size = conf.size
		while maxW > equalW and size > 12 do
			size = size - 2
			tabFont = "weapon_name_ssp_small_tab" .. size
			surface.CreateFont(tabFont, { font = conf.font, size = size, weight = conf.weight, extended = conf.extended, antialias = conf.antialias })
			maxW = CalcMaxW(tabFont)
		end
	end
	for _, tab in pairs(tabs) do
		tab:SetFont(tabFont)
		local baseapply = tab.ApplySchemeSettings
		tab.ApplySchemeSettings = function(me)
			baseapply(me)
			me:SetWide(equalW)
		end

		tab.PerformLayout = function(me)
			me:ApplySchemeSettings()
			if me.Image then
				me.Image:SetVisible(true)
				me.Image:SetSize(12, 12)
			end
		end

		tab.Paint = function(me, w, h)
			local active = me:IsActive()

			if active then
				-- 活动标签：绿色底线（v3.0 规范）
				surface.SetDrawColor(50, 255, 50, 255)
				surface.DrawRect(0, h - 3, w, 3)
			elseif me.Hovered then
				draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 10))
			end

			local textcol = active and Color(255, 255, 255, 255) or (me.Hovered and Color(255, 255, 255, 210) or Color(255, 255, 255, 110))
			surface.SetFont(me:GetFont())
			local textWidth = surface.GetTextSize(me:GetText())
			local iconWidth = me.Image and me.Image:IsValid() and me.Image:IsVisible() and me.Image:GetWide() + 4 or 0
			local startX = (w - textWidth - iconWidth) * 0.5
			if iconWidth > 0 then
				me.Image:SetPos(startX, h * 0.5 - me.Image:GetTall() * 0.5)
			end
			draw.SimpleText(me:GetText(), me:GetFont(), startX + iconWidth, h * 0.5, textcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			return true
		end
	end
	dragbase:InvalidateLayout(true)
	propertysheet.tabScroller:InvalidateLayout(true)

	if #GAMEMODE.SavedCarts == 0 then
		propertysheet:SetActiveTab(propertysheet.Items[math.min(2, #propertysheet.Items)].Tab)
	end

	UpdateCurrentCart()

	return frame
end

-- ============================================================================
-- ItemAmountCounter - 物品数量计数器（显示已拥有数量）
-- ============================================================================
local PANEL = {}
PANEL.m_ItemID = 0
PANEL.RefreshTime = 1
PANEL.NextRefresh = 0

function PANEL:Init()
	local screenscale = BetterScreenScale()

	self:SetFont(screenscale > 1.5 and "DefaultFontLargest" or "DefaultFontSmall")
end

function PANEL:Think()
	if CurTime() >= self.NextRefresh then
		self.NextRefresh = CurTime() + self.RefreshTime
		self:RefreshWorth()
	end
end

function PANEL:RefreshWorth()
	local count = GAMEMODE:GetCurrentEquipmentCount(self:GetItemID())
	if count == 0 then
		self:SetText(" ")
	else
		self:SetText(count)
	end

	self:SizeToContents()
end

function PANEL:SetItemID(id) self.m_ItemID = id end
function PANEL:GetItemID() return self.m_ItemID end

vgui.Register("ItemAmountCounter", PANEL, "DLabel")

-- ============================================================================
-- ZSWorthButton - 价值菜单中的单个物品按钮
-- ============================================================================
PANEL = {}

-- ============================================================================
-- Init - 初始化价值按钮
-- ============================================================================
function PANEL:Init()
	self:SetText("")

	local screenscale = BetterScreenScale()

	self:SetWide(316 * screenscale)  -- 默认值，MakepWorth 会按网格宽度覆盖
	self:SetTall(80 * screenscale)
	self.ModelFrame = vgui.Create("DPanel", self)
	self.ModelFrame:SetSize(96 * screenscale, 52 * screenscale)
	self.ModelFrame:SetPos(8 * screenscale, (self:GetTall() - self.ModelFrame:GetTall()) * 0.5)  -- 垂直居中
	self.ModelFrame:SetVisible(false)
	self.ModelFrame:SetMouseInputEnabled(false)
	self.ModelFrame.Paint = function() end

	-- 物品名称 - 设置固定宽度以支持换行
	self.NameLabel = EasyLabel(self, "", "ZSHUDFontTiny")
	self.NameLabel:SetContentAlignment(4)
	self.NameLabel:DockPadding(0, 0, 0, 0)
	self.NameLabel:DockMargin(0, 0, 0, 0)
	self.NameLabel:SetWide(200 * screenscale)  -- 保留足够宽度用于换行
	self.NameLabel:SetWrap(true)
	self.NameLabel:SetMultiline(true)

	-- 价格标签
	self.PriceLabel = EasyLabel(self, "", "ZSHUDFontTiny")
	self.PriceLabel:SetContentAlignment(4)
	self.PriceLabel:DockPadding(0, 0, 0, 0)
	self.PriceLabel:DockMargin(8, 0, 8 * screenscale, 0)

	-- 弹药类型图标
	self.AmmoIcon = vgui.Create("DImage", self)
	self.AmmoIcon:SetSize(20 * screenscale, 20 * screenscale)
	self.AmmoIcon:SetPos(8 * screenscale, 6 * screenscale)
	self.AmmoIcon:SetVisible(false)

	-- 数量计数器
	self.ItemCounter = vgui.Create("ItemAmountCounter", self)

	self:SetWorthID(nil)
end

-- ============================================================================
-- SetWorthID - 设置价值物品 ID 并更新显示
-- ============================================================================
function PANEL:SetWorthID(id)
	self.ID = id

	local tab = FindStartingItem(id)
	local screenscale = BetterScreenScale()

	if not tab then
		self.ModelFrame:SetVisible(false)
		self.AmmoIcon:SetVisible(false)
		self.ItemCounter:SetVisible(false)
		self.NameLabel:SetText("")
		return
	end

	self.Signature = tab.Signature
	self.Price = tab.Price

	local missing_skill = tab.SkillRequirement and not MySelf:IsSkillActive(tab.SkillRequirement)

	local nottrinkets = tab.Category ~= ITEMCAT_TRINKETS
	self:SetTall((nottrinkets and 88 or 64) * screenscale)

	-- 设置弹药类型图标
	local sweptable = tab.SWEP and (GAMEMODE.ZSInventoryItemData[tab.SWEP] or weapons.Get(tab.SWEP))
	if sweptable and sweptable.Primary and sweptable.Primary.Ammo and GAMEMODE.AmmoIcons[string.lower(sweptable.Primary.Ammo)] then
		local lower = string.lower(sweptable.Primary.Ammo)
		local ki = killicon.Get(GAMEMODE.AmmoIcons[lower])
		self.AmmoIcon:SetImage(ki[1])
		if ki[2] then self.AmmoIcon:SetImageColor(ki[2]) end
		self.AmmoIcon:SetVisible(true)
	else
		self.AmmoIcon:SetVisible(false)
	end

	if nottrinkets then
		self.ModelFrame:SetVisible(true)
		self.ModelFrame:SetPos(8 * screenscale, (self:GetTall() - self.ModelFrame:GetTall()) * 0.5)
		local kitbl = killicon.Get(GAMEMODE.ZSInventoryItemData[tab.SWEP] and "weapon_zs_craftables" or tab.SWEP or tab.Model)
		if kitbl then
			GAMEMODE:AttachKillicon(kitbl, self, self.ModelFrame, tab.Category == ITEMCAT_AMMO, missing_skill)
		elseif tab.Model then
			local mdlpanel = vgui.Create("DModelPanel", self.ModelFrame)
			mdlpanel:SetSize(self.ModelFrame:GetSize())
			mdlpanel:SetModel(tab.Model)
			local mins, maxs = mdlpanel.Entity:GetRenderBounds()
			mdlpanel:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
			mdlpanel:SetLookAt((mins + maxs) / 2)
		end
	end

	if tab.SWEP or tab.Countables then
		self.ItemCounter:SetItemID(id)
		self.ItemCounter:SetVisible(true)
		self.ItemCounter:SizeToContents()
		self.ItemCounter:SetPos(30 * screenscale, 8 * screenscale)
	else
		self.ItemCounter:SetVisible(false)
	end

	if missing_skill then
		self.PriceLabel:SetTextColor(COLOR_RED)
		self.PriceLabel:SetText(GAMEMODE.Skills[tab.SkillRequirement].Name)
	elseif tab.Price then
		self.PriceLabel:SetText(tostring(tab.Price).." "..translate.Get("Worth"))
	else
		self.PriceLabel:SetText("")
	end
	self.PriceLabel:SizeToContents()
	-- 价格右上角；有弹药图标时价格左移让位，弹药图标贴右上角
	local ammooffset = self.AmmoIcon:IsVisible() and (self.AmmoIcon:GetWide() + 4 * screenscale) or 0
	self.PriceLabel:SetPos(
		self:GetWide() - self.PriceLabel:GetWide() - 8 * screenscale - ammooffset,
		6 * screenscale
	)
	self.AmmoIcon:SetPos(self:GetWide() - 8 * screenscale - self.AmmoIcon:GetWide(), 6 * screenscale)

	self:SetTooltip(tab.Description)

	if missing_skill or tab.NoClassicMode and GAMEMODE:IsClassicMode() or tab.NoZombieEscape and GAMEMODE.ZombieEscape then
		self:SetAlpha(120)
		self.Locked = true
	else
		self:SetAlpha(255)
	end

	if not nottrinkets and tab.SubCategory then
		local catlabel = EasyLabel(self, GAMEMODE.ItemSubCategories[tab.SubCategory], "ZSBodyTextFont")
		catlabel:SizeToContents()
		catlabel:SetPos(10, self:GetTall() * 0.3 - catlabel:GetTall() * 0.5)
	end

	self.NameLabel:SetText(tab.Name or "")
	self.NameLabel:SetWrap(true)
	self.NameLabel:SetMultiline(true)
	self.NameLabel:SetAutoStretchVertical(false)
	self.NameLabel:SetContentAlignment(4)

	local nameX = nottrinkets and 112 * screenscale or 8 * screenscale
	local priceX = select(1, self.PriceLabel:GetPos())
	local counterWidth = self.ItemCounter:IsVisible() and self.ItemCounter:GetWide() + 6 * screenscale or 0
	local nameWidth = math.max(72 * screenscale, priceX - nameX - 6 * screenscale - counterWidth)
	self.NameLabel:SetPos(nameX, 26 * screenscale)
	self.NameLabel:SetSize(nameWidth, self:GetTall() - 30 * screenscale)

	if self.ItemCounter:IsVisible() then
		self.ItemCounter:SetPos(nameX + nameWidth + 4 * screenscale, (self:GetTall() - self.ItemCounter:GetTall()) * 0.5)
	end
end

-- ============================================================================
-- Paint - 绘制选中/悬停状态边框
-- ============================================================================
function PANEL:Paint(w, h)
	if self.On then
		-- 选中：2px 绿色边框 + 底部绿色线
		draw.RoundedBox(2, 0, 0, w, h, colSelLine)
		draw.RoundedBox(2, 2, 2, w - 4, h - 4, colBG)
		draw.RoundedBox(0, 2, h - 4, w - 4, 2, colSelLine)
	else
		draw.RoundedBox(2, 1, 1, w - 2, h - 2, colBG)
	end

	if self.Hovered then
		draw.RoundedBox(2, 2, 2, w - 4, h - 4, colHover)
	end

	return true
end

-- ============================================================================
-- OnCursorEntered - 鼠标进入时在查看器中显示详情
-- ============================================================================
function PANEL:OnCursorEntered()
	local shoptbl = FindStartingItem(self.ID)
	if not shoptbl then return end

	local sweptable = GAMEMODE.ZSInventoryItemData[shoptbl.SWEP] or weapons.Get(shoptbl.SWEP)
	if sweptable then
		GAMEMODE:SupplyItemViewerDetail(pWorth.Viewer, sweptable, shoptbl)
	end
end

-- ============================================================================
-- DoClick - 点击切换选择/取消选择物品
-- ============================================================================
function PANEL:DoClick(silent, force)
	local id = self.ID
	local tab = FindStartingItem(id)
	local goodcart = true

	if not tab then return end

	if self.On then
		-- 取消选择
		self.On = nil
		if not silent then
			surface.PlaySound("buttons/button18.wav")
		end
		remainingworth = remainingworth + tab.Price
	elseif tab.SkillRequirement and not MySelf:IsSkillActive(tab.SkillRequirement) then
		surface.PlaySound("buttons/button8.wav")
		return
	else
		-- 选择物品
		if remainingworth < tab.Price then
			if not force then
				surface.PlaySound("buttons/button8.wav")
				return
			else
				goodcart = false
			end
		end
		self.On = true
		if not silent then
			surface.PlaySound("buttons/button17.wav")
		end
		remainingworth = remainingworth - tab.Price
	end

	-- 更新剩余价值显示和颜色
	pWorth.WorthLab:SetText(translate.Get("Worth_Label")..tostring(remainingworth))
	if remainingworth <= 0 then
		pWorth.WorthLab:SetTextColor(COLOR_RED)
		pWorth.WorthLab:InvalidateLayout()
	elseif remainingworth < GetStartingWorth() then
		pWorth.WorthLab:SetTextColor(COLOR_YELLOW)
		pWorth.WorthLab:InvalidateLayout()
	else
		pWorth.WorthLab:SetTextColor(COLOR_LIMEGREEN)
		pWorth.WorthLab:InvalidateLayout()
	end
	pWorth.WorthLab:SizeToContents()

	-- 触发购物车更新
	hook.Call("WorthButtonChanged")

	return goodcart
end

vgui.Register("ZSWorthButton", PANEL, "DButton")
