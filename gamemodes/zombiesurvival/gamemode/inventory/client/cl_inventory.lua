-- ========== 客户端库存数据表 ==========

-- 本地玩家当前的库存物品表（从服务器同步）
GM.ZSInventory = {}

-- ========== 库存物品类别常量定义（客户端扩展） ==========

INVCAT_TRINKETS = 1
INVCAT_COMPONENTS = 2
INVCAT_CONSUMABLES = 3
INVCAT_WEAPONS = 4

-- ========== 获取Player元表用于扩展客户端玩家方法 ==========

local meta = FindMetaTable("Player")

-- ========== 获取客户端库存物品表 ==========

function meta:GetInventoryItems()
	return GAMEMODE.ZSInventory
end

-- ========== 检查客户端玩家是否拥有物品 ==========

function meta:HasInventoryItem(item)
	return GAMEMODE.ZSInventory[item] and GAMEMODE.ZSInventory[item] > 0
end

-- ========== 处理服务器发送的库存更新 ==========

-- 接收服务器发来的单个库存物品数量更新
net.Receive(NET_MSG.INVENTORYITEM, function()
	local item = net.ReadString()
	local count = net.ReadUInt(8)
	local prevcount = GAMEMODE.ZSInventory[item] or 0

	GAMEMODE.ZSInventory[item] = count

	-- 如果库存界面打开，同步更新网格显示
	if GAMEMODE.InventoryMenu and GAMEMODE.InventoryMenu:IsValid() then
		if count > prevcount then
			GAMEMODE:InventoryAddGridItem(item, GAMEMODE:GetInventoryItemType(item))
		else
			GAMEMODE:InventoryRemoveGridItem(item)
		end
	end

	-- 更新本地玩家饰品效果
	if MySelf and MySelf:IsValid() then
		MySelf:ApplyTrinkets()
	end
end)

-- ========== 处理服务器发送的库存清空 ==========

-- 接收服务器清空库存指令
net.Receive(NET_MSG.WIPEINVENTORY, function()
	GAMEMODE.ZSInventory = {}

	if GAMEMODE.InventoryMenu and GAMEMODE.InventoryMenu:IsValid() then
		GAMEMODE:InventoryWipeGrid()
	end

	MySelf:ApplyTrinkets()
end)

-- ========== 发送合成请求到服务器 ==========

-- 将玩家选择的合成配方发送至服务器处理
local function TryCraftWithComponent(me)
	net.Start(NET_MSG.TRYCRAFT)
		net.WriteString(me.Item)
		net.WriteString(me.WeaponCraft)
	net.SendToServer()
end

-- ========== 库存物品面板点击处理 ==========

-- 当玩家点击库存网格中的物品时的处理逻辑
local function ItemPanelDoClick(self)
    local item = self.Item
    if not item then return end
    local viewer = GAMEMODE.InventoryMenu.Viewer
    local shoptbl
    local category, sweptable = self.Category
    -- 根据类别获取武器或库存物品数据
    if category == INVCAT_WEAPONS then
        sweptable = weapons.Get( item )
    else
        sweptable = GAMEMODE.ZSInventoryItemData[ item ]
    end
    local screenscale = BetterScreenScale()
    -- 如果已选中，取消选中
    if self.On then
        self.On = false
        GAMEMODE.InventoryMenu.SelInv = false
        GAMEMODE.InventoryMenu.Category = false
        GAMEMODE:DoAltSelectedItemUpdate()
        return
    else
        -- 取消同组其他面板的选中状态
        for _, v in pairs( self:GetParent():GetChildren() ) do
            v.On = false
        end
        self.On = true
        GAMEMODE.InventoryMenu.SelInv = item
        GAMEMODE.InventoryMenu.Category = category
        GAMEMODE:DoAltSelectedItemUpdate()
    end
    -- 隐藏所有合成按钮
    for i = 1, 3 do
        local crab, cral = viewer.m_CraftBtns[ i ][ 1 ], viewer.m_CraftBtns[ i ][ 2 ]
        crab:SetVisible( false )
        cral:SetVisible( false )
    end
    -- 查找该物品作为组件可以合成的所有配方
    local assembles = {}
    for k,v in pairs( GAMEMODE.Assemblies ) do
        if v[1] == item then
            assembles[ v[ 2 ] ] = k
        end
    end
    -- 显示可用的合成选项按钮
    local count = 0
    for k,v in pairs( assembles ) do
        count = count + 1
        local crab, cral = viewer.m_CraftBtns[ count ][ 1 ], viewer.m_CraftBtns[ count ][ 2 ]
        local iitype = GAMEMODE:GetInventoryItemType( k ) ~= -1
        crab.Item = item
        crab.WeaponCraft = k
        crab.DoClick = TryCraftWithComponent
        crab:SetPos( viewer:GetWide() / 2 - crab:GetWide() / 2, ( viewer:GetTall() - 33 * screenscale ) - ( count - 1 ) * 33 * screenscale )
        crab:SetVisible( true )
        cral:SetText( ( iitype and GAMEMODE.ZSInventoryItemData[ k ] or weapons.Get( k ) ).PrintName )
        cral:SetPos( crab:GetWide() / 2 - cral:GetWide() / 2, ( crab:GetTall() * 0.5 - cral:GetTall() * 0.5 ) )
        cral:SetContentAlignment( 5 )
        cral:SetVisible( true )
    end
    if count > 0 then
        viewer.m_CraftWith:SetPos( viewer:GetWide() / 2 - viewer.m_CraftWith:GetWide() / 2, ( viewer:GetTall() - 33 * screenscale ) - 33 * count * screenscale )
        viewer.m_CraftWith:SetContentAlignment( 5 )
        viewer.m_CraftWith:SetVisible( true )
    else
        viewer.m_CraftWith:SetVisible( false )
    end
    -- 更新详细信息面板
    GAMEMODE:SupplyItemViewerDetail( viewer, sweptable, { SWEP = self.Item } )
end

-- ========== 装饰品类别颜色定义 ==========

-- 各类别物品在库存网格中的颜色方案（选中/未选中）
local categorycolors = {
	[INVCAT_TRINKETS] = {COLOR_RED, COLOR_DARKRED},
	[INVCAT_COMPONENTS] = {COLOR_BLUE, COLOR_DARKBLUE},
	[INVCAT_CONSUMABLES] = {COLOR_YELLOW, COLOR_DARKYELLOW}
}

-- ========== 网格面板绘制变量 ==========

-- 面板背景色（深色半透明）
local colBG = Color(10, 10, 10, 252)
-- 面板悬停高亮色
local colBGH = Color(200, 200, 200, 5)
-- 模糊材质
local blur = Material( "pp/blurscreen" )

-- ========== 装饰品网格面板绘制函数 ==========

-- 自定义绘制库存物品网格按钮（含类别颜色和选中高亮）
local function TrinketPanelPaint( self, w, h )
    -- 绘制类别颜色边框
    if categorycolors[ self.Category ] then
        draw.RoundedBox( 2, 0, 0, w, h, ( self.Depressed or self.On ) and categorycolors[ self.Category ][ 1 ] or categorycolors[ self.Category ][ 2 ] )
    end
    
    -- 绘制黑色背景
    draw.RoundedBox( 2, 2, 2, w - 4, h - 4, colBG )
    
    -- 选中或悬停时显示高亮
    if self.On or self.Hovered then
        draw.RoundedBox( 2, 2, 2, w - 4, h - 4, colBGH )
    end
    -- 显示武器名称
     if self.SWEP then
        draw.SimpleText( self.SWEP.PrintName, "ZSHUDFontTiny", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	
    end
     return true
end

-- ========== 注释掉的旧版本库存视图创建函数 ==========

--[[
function GM:CreateInventoryInfoViewer()
	if self.m_InvViewer and self.m_InvViewer:IsValid() then
		self.m_InvViewer:SetVisible(true)
		return
	end

	local leftframe = self.InventoryMenu
	local viewer = vgui.Create("DFrame")

	local screenscale = BetterScreenScale()

	viewer:SetDeleteOnClose(false)
	viewer:SetTitle(" ")
	viewer:SetDraggable(false)
	if viewer.btnClose and viewer.btnClose:IsValid() then viewer.btnClose:SetVisible(false) end
	if viewer.btnMinim and viewer.btnMinim:IsValid() then viewer.btnMinim:SetVisible(false) end
	if viewer.btnMaxim and viewer.btnMaxim:IsValid() then viewer.btnMaxim:SetVisible(false) end

	viewer:SetSize(leftframe:GetWide() / 1.25, leftframe:GetTall())
	viewer:MoveRightOf(leftframe, 32)
	viewer:MoveAbove(leftframe, -leftframe:GetTall())
	self.m_InvViewer = viewer

	self:CreateItemViewerGenericElems(viewer)

	local craftbtns = {}
	for i = 1, 3 do
		local craftb = vgui.Create("DButton", viewer)
		craftb:SetText("")
		craftb:SetSize(viewer:GetWide() / 1.15, 27 * screenscale)
		craftb:SetVisible(false)

		local namelab = EasyLabel(craftb, "...", "ZSBodyTextFont", COLOR_WHITE)
		namelab:SetWide(craftb:GetWide())
		namelab:SetVisible(false)

		craftbtns[i] = {craftb, namelab}
	end
	viewer.m_CraftBtns = craftbtns

	local craftwith = EasyLabel(viewer, translate.Get("Inventory_CraftWith"), "ZSBodyTextFontBig", COLOR_WHITE)

	craftwith:SetSize(viewer:GetWide() / 1.15, 27 * screenscale)
	craftwith:SetVisible(false)
	viewer.m_CraftWith = craftwith
end
]]

-- ========== 创建库存界面合成元素 ==========

-- 在库存查看器中创建合成按钮和标签
function GM:CreateInventoryElements()
    local screenscale = BetterScreenScale()
    local viewer = self.InventoryMenu.Viewer 
    local craftbtns = {}
    for i = 1, 3 do
        local craftb = vgui.Create( "DButton", viewer )
        craftb:SetText( "" )
        craftb:SetSize( viewer:GetWide() / 1.15, 27 * screenscale )
        craftb:SetVisible(false)
        local namelab = EasyLabel( craftb, "...", "ZSBodyTextFont", COLOR_WHITE )
        namelab:SetWide( craftb:GetWide() )
        namelab:SetVisible( false )
        craftbtns[i] = { craftb, namelab }
    end
    viewer.m_CraftBtns = craftbtns
    local craftwith = EasyLabel( viewer, ""..translate.Get("Inventory_CraftWith"), "ZSBodyTextFontBig", COLOR_WHITE )
    craftwith:SetSize( viewer:GetWide() / 1.15, 27 * screenscale )
    craftwith:SetVisible( false )
    viewer.m_CraftWith = craftwith
end

-- ========== 数字到罗马数字转换表 ==========

local NumToRomanNumeral = {
	"I", "II", "III", "IV", "V", "VI"
}

-- ========== 向库存网格添加物品 ==========

-- 在库存界面中为指定物品创建新的网格按钮
function GM:InventoryAddGridItem(item, category)
    local screenscale = BetterScreenScale()
    local grid = self.InventoryMenu.Grids[ self:GetInventoryItemType( item ) ]
    local types = nodes
    if grid and grid:IsValid() then
        local itempan = vgui.Create("DButton")
        itempan:SetText( "" )
        itempan.Paint = TrinketPanelPaint
        itempan.Item = item
        itempan.SWEP = self.ZSInventoryItemData[ item ]
        itempan.DoClick = ItemPanelDoClick
        itempan.Category = category
        grid:AddItem( itempan )
        grid:SortByMember( "Category" )
        local mdlframe = vgui.Create("DPanel", itempan)
        mdlframe:SetSize( 100 * screenscale, 50 * screenscale )
        mdlframe:Center()
        mdlframe:SetMouseInputEnabled( false )
        mdlframe.Paint = function() end
        local trintier = EasyLabel( itempan, "", "ZSHUDFontSmaller", COLOR_WHITE )
        trintier:CenterHorizontal( 0.8 )
        trintier:CenterVertical( 0.8 )
        local kitbl = killicon.Get( category == INVCAT_WEAPONS and item )
        if kitbl then
            self:AttachKillicon( kitbl, itempan, mdlframe )
        end
    end
end

-- ========== 注释掉的旧杀死图标处理 ==========

--[[	
	local kitbl = killicon.Get(category == INVCAT_TRINKETS and "weapon_zs_trinket" or "weapon_zs_craftables")
	if kitbl then
		self:AttachKillicon(kitbl, itempan, mdlframe)
	end
]]

-- ========== 从库存网格移除物品 ==========

-- 当物品数量减少或移除时，更新库存网格显示
function GM:InventoryRemoveGridItem(item)
    for i, grid in pairs( self.InventoryMenu.Grids ) do
        for k, v in pairs( grid:GetChildren() ) do
            if v.Item == item then
                grid:RemoveItem( v )
                break
            end
        end
        grid:SortByMember( "Name" )
    end
    -- 如果被移除的物品是当前选中的，取消选中状态
    if self.InventoryMenu.SelInv == item then
        if self.m_InvViewer and self.m_InvViewer:IsValid() and self.InventoryMenu.SelInv then
            self.m_InvViewer:SetVisible( false )
        end
        self.InventoryMenu.SelInv = nil
        self:DoAltSelectedItemUpdate()
    end
end

-- ========== 清空库存网格 ==========

-- 移除库存界面中的所有网格项
function GM:InventoryWipeGrid()
	for i, grid in pairs( self.InventoryMenu.Grids ) do
		for k, v in pairs( grid:GetChildren() ) do
			grid:RemoveItem( v )
		end
	end
	if self.m_InvViewer and self.m_InvViewer:IsValid() then
		self.m_InvViewer:SetVisible( false )
	end
	self.InventoryMenu.SelInv = nil
	self:DoAltSelectedItemUpdate()
end

-- ========== 刷新冷却变量 ==========

local NextRefresh = 0
local RefreshTime = 0.1

-- ========== 打开库存界面 ==========

-- 创建或显示库存面板的完整UI（含标签页、网格、合成元素）
function GM:OpenInventory()
    -- 如果库存界面已存在，直接显示
    if self.InventoryMenu and self.InventoryMenu:IsValid() then
		self.InventoryMenu:SetVisible( true )
		if self.Inv_NearestFrame and self.Inv_NearestFrame:IsValid() then
		    self.Inv_NearestFrame:SetVisible( true )
	    end
	    if self.m_InvViewer and self.m_InvViewer:IsValid() and self.InventoryMenu.SelInv then
		    self.m_InvViewer:SetVisible( true )
	    end
	    return
	end
	-- 创建新的库存界面框架
	local screenscale = BetterScreenScale()
	local w, h = 700 * screenscale, 700 * screenscale
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( w, h )
	frame:Center()
	frame:SetTitle( "" )
	frame.Grids = {}
	self.InventoryMenu = frame
	-- 隐藏默认窗口按钮
	if frame.btnClose and frame.btnClose:IsValid() then frame.btnClose:SetVisible( false ) end
	if frame.btnMinim and frame.btnMinim:IsValid() then frame.btnMinim:SetVisible( false ) end
	if frame.btnMaxim and frame.btnMaxim:IsValid() then frame.btnMaxim:SetVisible( false ) end
	-- 顶部空间
	local topspace = vgui.Create( "DPanel", frame )
	topspace:Dock( TOP )
	topspace:DockMargin( 4 * screenscale, 4 * screenscale, 4 * screenscale, 4 * screenscale )
	topspace:SetTall( 40 * screenscale )
	topspace:SetMouseInputEnabled( false )
	-- 底部空间
	local bottomspace = vgui.Create( "DPanel", frame )
	bottomspace:Dock( BOTTOM )
	bottomspace:DockMargin( 4 * screenscale, 4 * screenscale, 4 * screenscale, 4 * screenscale )
	bottomspace:SetTall( 20 * screenscale )
	-- 标题标签
	local title = EasyLabel( topspace, translate.Get( "inventory_title" ), "ZSHUDFontSmall", COLOR_WHITE )
	title:Dock( FILL )
	title:SetContentAlignment( 5 )
	-- 属性页组件（分类标签页）
	local invprop = vgui.Create( "DPropertySheet", frame )
	invprop:Dock( FILL )
	invprop:SetWide( frame:GetWide() - 320 * screenscale )
	invprop:DockMargin( 2 * screenscale, 2 * screenscale, 2 * screenscale, 2 * screenscale )
	
	-- 遍历类别创建标签页和网格
	for i, con in pairs( self.ZSInventoryCategories ) do
	    local itemframe = vgui.Create( "DScrollPanel", invprop )
	    itemframe:Dock( FILL )
	    itemframe:DockMargin( 4 * screenscale, 4 * screenscale, 4 * screenscale, 4 * screenscale )
	    -- 创建网格布局
	    local invgrid = vgui.Create( "DGrid", itemframe )
	    invgrid:Dock( FILL )
	    invgrid:DockMargin( 2 * screenscale, 2 * screenscale, 2 * screenscale, 2 * screenscale )
	    invgrid:SetCols( 2 )
	    invgrid:SetColWide( 179 * screenscale )
	    invgrid:SetRowHeight( 74 * screenscale )
	    -- 网格项大小自适应
	    invgrid.Think = function( sf )
			for i, item in pairs( sf:GetItems() ) do
				if item and item:IsValid() and not item.Grided then
					item:SetWide( sf:GetColWide() - 4 * screenscale )
					item:SetTall( sf:GetRowHeight() - 4 * screenscale )
					item.Grided = true
				end
			end
		end
	    itemframe.Grid = invgrid
	    self.InventoryMenu.Grids[ i ] = invgrid
	    invprop:AddSheet( con, itemframe )
	end
	self.InventoryMenu.Grid = invprop:GetActiveTab():GetPanel().Grid
	local scroller = invprop:GetChildren()[ 1 ]
	local dragbase = scroller:GetChildren()[ 1 ]
	local tabs = dragbase:GetChildren()
	
	-- 配置标签页切换事件
	self:ConfigureMenuTabs( tabs, 32 * screenscale, function( tab )
		    self.InventoryMenu.Grid = tab:GetPanel().Grid
	end )
	-- 加载玩家已有物品到网格
	for item, count in pairs( self.ZSInventory ) do
		if count > 0 then
		    for i = 1, count do
		        self:InventoryAddGridItem( item, self:GetInventoryItemType( item ) )
			end
		end
	end
	-- 创建详细信息查看器和合成元素
	self:CreateItemInfoViewer( frame, invprop, topspace, bottomspace )
	self:CreateInventoryElements()
end
