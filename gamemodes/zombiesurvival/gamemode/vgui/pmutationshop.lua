-- ============================================================================
-- PMutationShop - 突变/变异商店界面
-- 允许僵尸玩家使用突变点数购买各种变异能力
-- 包含商店配置、项目行(ItemRow)和主窗口(MutationShopFrame)
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 商店主窗口
-- [位置] MutationShopFrame / Init() / Paint() / PerformLayout() / Close()
-- [作用] 全屏遮罩 + 标题栏(标题/突变点数/关闭按钮) + 内容区
-- [常改] 窗口比例、颜色、标题栏高度
--
-- [区域] 分类标签栏
-- [位置] CreateCategoryTabs() / SwitchCategory() / TabsContainer:PerformLayout()
-- [作用] 按类别切换突变列表，选中白底+绿色高亮线
-- [常改] 标签字体、间距、选中样式
--
-- [区域] 突变项目列表
-- [位置] PopulateItemList() / StyleScrollbar()
-- [作用] 滚动列出当前分类的突变项目行
-- [常改] 滚动条样式、内容内边距
--
-- [区域] 项目行
-- [位置] ZSMutationItemRow / Init() / PerformLayout() / SetMutation() / Purchase()
-- [作用] 图标+名称+描述+价格+购买按钮，悬停动画，已拥有态
-- [常改] 行高、按钮尺寸、购买逻辑
-- ============================================================================

-- ============================================================================
-- 商店配置 (Shop Configuration)
-- ============================================================================
local ShopConfig = {
    Title = ""..translate.Get("mutation_MutationShop").."",
    WindowWidthScale = 0.48,
    WindowHeightScale = 0.6,
    TitleBarHeight = 50,
    CategoryBarHeight = 50,

    ItemRowHeight = 85,
    ItemIconSize = 56,
    ItemButtonWidth = 80,
    ItemButtonHeight = 60,

    ContentPadding = 10,
    
    AnimationSpeed = 10,

    Fonts = {
        Title = "ZSHUDFont",
        Tab = "ZSHUDFontSmall",
        ItemName = "ZSHUDFontSmall",
        ItemDesc = "ZSHUDFontTiny",
        Button = "ZSHUDFontTiny",
        CloseButton = "ZSHUDFontSmall",
        ItemPrice = "ZSHUDFontSmall"
    },

    Colors = {
        Background = Color(20, 20, 20, 240),
        TitleBar = Color(24, 24, 24, 255),
        CategoryBar = Color(22, 22, 22, 255),
        TextPrimary = Color(220, 221, 222),
        TextSecondary = Color(150, 152, 155),
        TextTitle = Color(235, 235, 235),
        TextPrice = Color(215, 180, 100),
        Accent = Color(90, 255, 120),
        ButtonBuy = Color(50, 170, 95),
        ButtonBuyHover = Color(70, 200, 115),
        ButtonOwned = Color(180, 70, 70),
        ButtonDisabled = Color(100, 100, 100),
        CloseButtonHover = Color(255, 110, 110),
        ListItem = Color(0, 0, 0, 80),
        ListItemHover = Color(255, 255, 255, 26),
        ScrollbarGrip = Color(255, 255, 255, 55),
        ScrollbarTrack = Color(0, 0, 0, 35)
    }
}

-- 辅助函数：颜色插值
local function LerpColor(fraction, from, to)
    local r = Lerp(fraction, from.r, to.r)
    local g = Lerp(fraction, from.g, to.g)
    local b = Lerp(fraction, from.b, to.b)
    local a = Lerp(fraction, from.a, to.a)
    return Color(r, g, b, a)
end

-- 辅助函数：绘制垂直线性渐变
local function DrawVerticalGradient(x, y, w, h, startColor, endColor)
    for i = 0, h - 1 do
        local frac = (h == 1) and 0 or (i / (h - 1))
        local r = Lerp(frac, startColor.r, endColor.r)
        local g = Lerp(frac, startColor.g, endColor.g)
        local b = Lerp(frac, startColor.b, endColor.b)
        local a = Lerp(frac, startColor.a, endColor.a)
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x, y + i, w, 1)
    end
end


-- ============================================================================
-- ZSMutationItemRow - 单个突变项目行面板
-- ============================================================================
local PANEL = {}

-- ============================================================================
-- Init - 初始化项目行
-- ============================================================================
function PANEL:Init()
    self:SetTall(ShopConfig.ItemRowHeight)
    self:Dock(TOP)
    self:DockMargin(0, 0, 0, 5)

    -- 突变图标
    self.Icon = vgui.Create("DImage", self)
    self.Icon:SetSize(ShopConfig.ItemIconSize, ShopConfig.ItemIconSize)
    
    -- 突变名称
    self.NameLabel = vgui.Create("DLabel", self)
    self.NameLabel:SetFont(ShopConfig.Fonts.ItemName)
    self.NameLabel:SetTextColor(ShopConfig.Colors.TextPrimary)
    self.NameLabel:SetWrap(true)
    self.NameLabel:SetAutoStretchVertical(true)

    -- 突变描述
    self.DescLabel = vgui.Create("DLabel", self)
    self.DescLabel:SetFont(ShopConfig.Fonts.ItemDesc)
    self.DescLabel:SetTextColor(ShopConfig.Colors.TextSecondary)
    self.DescLabel:SetWrap(true)
    self.DescLabel:SetAutoStretchVertical(true)
    
    -- 价格标签
    self.PriceLabel = vgui.Create("DLabel", self)
    self.PriceLabel:SetFont(ShopConfig.Fonts.ItemPrice)
    self.PriceLabel:SetTextColor(ShopConfig.Colors.TextPrice)
    self.PriceLabel:SetContentAlignment(5)

    -- 购买按钮
    self.PurchaseButton = vgui.Create("DButton", self)
    self.PurchaseButton:SetText(translate.Get("mutation_Purchase"))
    self.PurchaseButton:SetFont(ShopConfig.Fonts.Button)
    self.PurchaseButton:SetSize(ShopConfig.ItemButtonWidth, ShopConfig.ItemButtonHeight)
    self.PurchaseButton:SetTextColor(color_white)
    self.PurchaseButton.DoClick = function() self:Purchase() end
    
    self.PurchaseButton.CurrentColor = ShopConfig.Colors.ButtonBuy
    self.PurchaseButton.Paint = function(btn, w, h)
        local targetColor = btn:IsHovered() and ShopConfig.Colors.ButtonBuyHover or ShopConfig.Colors.ButtonBuy
        btn.CurrentColor = LerpColor(FrameTime() * ShopConfig.AnimationSpeed, btn.CurrentColor, targetColor)
        draw.RoundedBox(8, 0, 0, w, h, btn.CurrentColor)
        DrawVerticalGradient(0, 0, w, h * 0.5, Color(255, 255, 255, 20), Color(255, 255, 255, 0))
    end

    -- 当前背景颜色（用于悬停动画）
    self.CurrentBGColor = ShopConfig.Colors.ListItem
end

-- ============================================================================
-- PerformLayout - 布局项目行的各个元素
-- ============================================================================
function PANEL:PerformLayout(w, h)
    local iconMargin = (h - ShopConfig.ItemIconSize) / 2
    self.Icon:SetPos(10, iconMargin)

    self.PurchaseButton:SetPos(w - ShopConfig.ItemButtonWidth - 10, (h - ShopConfig.ItemButtonHeight) / 2)
    
    -- 布局价格标签
    self.PriceLabel:SizeToContents()
    self.PriceLabel:SetPos(self.PurchaseButton.x - self.PriceLabel:GetWide() - 10, 0)
    self.PriceLabel:SetTall(h)

    local textStartX = self.Icon.x + self.Icon:GetWide() + 15
    local textMaxWidth = self.PriceLabel.x - textStartX - 15
    
    self.NameLabel:SetWide(textMaxWidth)
    self.DescLabel:SetWide(textMaxWidth)
    
    local nameHeight = self.NameLabel:GetTall()
    local descHeight = self.DescLabel:GetTall()
    local textBlockHeight = nameHeight + descHeight + 4
    local textBlockStartY = (h - textBlockHeight) / 2
    
    self.NameLabel:SetPos(textStartX, textBlockStartY)
    self.DescLabel:SetPos(textStartX, textBlockStartY + nameHeight + 4)
end

-- ============================================================================
-- Paint - 绘制项目行悬停背景
-- ============================================================================
function PANEL:Paint(w, h)
    local targetColor = self:IsHovered() and ShopConfig.Colors.ListItemHover or ShopConfig.Colors.ListItem
    self.CurrentBGColor = LerpColor(FrameTime() * ShopConfig.AnimationSpeed, self.CurrentBGColor, targetColor)
    draw.RoundedBox(4, 0, 0, w, h, self.CurrentBGColor)
end

-- ============================================================================
-- SetMutation - 设置突变项目的数据
-- ============================================================================
function PANEL:SetMutation(mutationData)
    self.Data = mutationData
    if not self.Data then return end
    
    self.Data.Name = self.Data.Name or "未设置名字"
    self.Data.Description = self.Data.Description or "未设置描述"
   
    self.NameLabel:SetText(self.Data.Name)
    self.DescLabel:SetText(self.Data.Description)
    
    -- 设置价格文本
    self.PriceLabel:SetText(self.Data.Price or "??")
    
    self.Icon:SetVisible(true)
    if not self.Data.Icon then
        self.Icon:SetVisible(false)
    end
    self.Data.Icon = self.Data.Icon or "icon16/package.png"
    self.Icon:SetImage(self.Data.Icon) 
    
    self:InvalidateLayout(true)
    -- 可重复购买项（如迷你BOSS变身）永远不显示"已拥有"
    local isOwned = false
    if not self.Data.Repeatable then
        for _, sig in pairs(UsedMutations or {}) do
            if sig == self.Data.Signature then isOwned = true; break end
        end
    end
    if isOwned then
        self.PriceLabel:SetVisible(false)
        self.PurchaseButton:SetText(translate.Get("mutation_owned"))
        self.PurchaseButton:SetEnabled(false)
        self.PurchaseButton.Paint = function(btn, w, h) draw.RoundedBox(8, 0, 0, w, h, ShopConfig.Colors.ButtonOwned) end
    end
end

-- ============================================================================
-- Purchase - 执行购买操作
-- ============================================================================
function PANEL:Purchase()
    if not self.Data then return end
    local myTokens = LocalPlayer():GetTokens() or 0
    local CanPurchase = gamemode.Call("ZombieCanPurchase", LocalPlayer())
    RunConsoleCommand("zs_mutationshop_click", self.Data.Signature)
    -- 可重复购买项不本地记入 UsedMutations，避免界面立即显示"已拥有"
    if myTokens >= self.Data.Price and CanPurchase then
        if not self.Data.Repeatable then
            table.insert(UsedMutations, self.Data.Signature)
        end
        self:SetMutation(self.Data)
    end
end
vgui.Register("ZSMutationItemRow", PANEL, "DPanel")


-- ============================================================================
-- MutationShopFrame - 突变商店主窗口
-- ============================================================================
local pMutationShop

-- ============================================================================
-- OpenMutationShop - 打开突变商店
-- ============================================================================
function OpenMutationShop(used)
    if IsValid(pMutationShop) then pMutationShop:Remove() end

    if used then
        UsedMutations = used
    end

    UsedMutations = UsedMutations or {}

    pMutationShop = vgui.Create("MutationShopFrame")
end

PANEL = {}
PANEL.TitleBarHeight = ShopConfig.TitleBarHeight
PANEL.CategoryBarHeight = ShopConfig.CategoryBarHeight

-- ============================================================================
-- GetSortedCategories - 获取排序后的类别ID列表
-- ============================================================================
function PANEL:GetSortedCategories()
    local sortable = {}
    for id, data in pairs(GAMEMODE.ZombieShopCategories) do
        table.insert(sortable, {id = id, order = data.Order or 999})
    end
    table.sort(sortable, function(a, b) return a.order < b.order end)
    local sortedIDs = {}
    for _, item in ipairs(sortable) do table.insert(sortedIDs, item.id) end
    return sortedIDs
end

-- ============================================================================
-- Init - 初始化主窗口
-- ============================================================================
function PANEL:Init()
    local BetterScreenScale = BetterScreenScale and BetterScreenScale() or 1
    local wid, hei = ScrW() * ShopConfig.WindowWidthScale * BetterScreenScale, ScrH() * ShopConfig.WindowHeightScale * BetterScreenScale
    self:SetSize(wid, hei)
    self:SetTitle("")
    self:SetDraggable(true)
    self:SetDeleteOnClose(true)
    self:ShowCloseButton(false)
    self:MakePopup()
    self.m_bFirstThink = true
    self.CategoryTabs = {}
    self.ActiveCategory = nil

    -- 标题
    self.TitleLabel = vgui.Create("DLabel", self)
    self.TitleLabel:SetText(ShopConfig.Title)
    self.TitleLabel:SetFont(ShopConfig.Fonts.Title)
    self.TitleLabel:SetTextColor(ShopConfig.Colors.TextTitle)
    self.TitleLabel:SetContentAlignment(5)

    -- 突变点数显示（小字号，避免与 42px 标题冲突）
    self.MutationPointsLabel = vgui.Create("DLabel", self)
    self.MutationPointsLabel:SetFont("ZSHUDFontSmaller")
    self.MutationPointsLabel:SetTextColor(ShopConfig.Colors.TextPrimary)

    -- 关闭按钮（X）
    self.CloseButton = vgui.Create("DButton", self)
    self.CloseButton:SetText("X")
    self.CloseButton:SetFont(ShopConfig.Fonts.CloseButton)
    self.CloseButton:SetTextColor(color_white)
    self.CloseButton.DoClick = function() self:Close() end
    
    self.CloseButton.CurrentBGColor = Color(0, 0, 0, 0)
    self.CloseButton.Paint = function(btn, w, h)
        local targetColor = btn:IsHovered() and ShopConfig.Colors.CloseButtonHover or Color(0, 0, 0, 0)
        btn.CurrentBGColor = LerpColor(FrameTime() * ShopConfig.AnimationSpeed, btn.CurrentBGColor, targetColor)
        draw.RoundedBox(0, 0, 0, w, h, btn.CurrentBGColor)
    end

    -- 分类标签容器
    self.TabsContainer = vgui.Create("DPanel", self)
    self.TabsContainer:SetPaintBackground(false)
    self.TabsContainer.PerformLayout = function(container, w, h)
        local inner = container:GetChildren()[1]
        if not IsValid(inner) then return end; local tabs = inner:GetChildren()
        if #tabs == 0 then return end; local defaultHPadding, minHPadding, tabMargin = 15, 5, 5
        local textWidths, totalTextW = {}, 0; for i, tab in ipairs(tabs) do
        tab:SizeToContents(); textWidths[i] = tab:GetWide(); totalTextW = totalTextW + textWidths[i] end
        local totalDefaultPaddingW = #tabs * defaultHPadding * 2; local totalMarginW = #tabs * tabMargin * 2
        local totalIdealW = totalTextW + totalDefaultPaddingW + totalMarginW; local finalHPadding = defaultHPadding
        if totalIdealW > w then local availableSpaceForPadding = w - totalTextW - totalMarginW
        if availableSpaceForPadding > 0 then finalHPadding = math.max(minHPadding, math.floor((availableSpaceForPadding / #tabs) / 2))
        else finalHPadding = minHPadding end end; local currentX = 0
        for i, tab in ipairs(tabs) do local tabW = textWidths[i] + (finalHPadding * 2); local tabY = 5
        local tabH = h - 10; tab:SetSize(tabW, tabH); tab:SetPos(currentX + tabMargin, tabY)
        currentX = currentX + tabW + (tabMargin * 2) end; inner:SetSize(currentX, h); inner:Center()
    end

    -- 项目列表滚动面板
    self.ItemList = vgui.Create("DScrollPanel", self)
    local pad = ShopConfig.ContentPadding
    self.ItemList:GetCanvas():DockPadding(pad, pad, pad, pad)
    self:StyleScrollbar()
    
    local sortedKeys = self:GetSortedCategories()
    if sortedKeys[1] then self.ActiveCategory = sortedKeys[1] end
    
    self:CreateCategoryTabs()
    self:Center()

    self:SetAlpha(0)
    self:AlphaTo(255, 0.1, 0)
end

-- ============================================================================
-- Think - 每帧逻辑：更新突变点数显示
-- ============================================================================
function PANEL:Think()
    local Tokens = math.floor(LocalPlayer():GetTokens() or 0)
    self.MutationPointsLabel:SetText(translate.Get("mutation_MutationPoints").. Tokens)

    if self.m_bFirstThink then
        self.m_bFirstThink = false
        if self.ActiveCategory then self:SwitchCategory(self.ActiveCategory, true) end
    end
end

-- ============================================================================
-- Paint - 绘制窗口背景和标题栏
-- ============================================================================
function PANEL:Paint(w, h)
    -- 全屏黑色遮罩：压暗游戏画面，避免背景干扰 UI 阅读（与僵尸选择界面一致）
    DisableClipping(true)
    local sx, sy = self:LocalToScreen(0, 0)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(-sx, -sy, ScrW(), ScrH())
    DisableClipping(false)

    draw.RoundedBox(12, 0, 0, w, h, ShopConfig.Colors.Background)
    DrawVerticalGradient(0, 0, w, self.TitleBarHeight, ShopConfig.Colors.TitleBar, ShopConfig.Colors.CategoryBar)

    -- 窗口细边框
    surface.SetDrawColor(255, 255, 255, 35)
    surface.DrawOutlinedRect(0, 0, w, h)

    -- 分类栏底部绿色分隔线（弱化显示）
    surface.SetDrawColor(ShopConfig.Colors.Accent.r, ShopConfig.Colors.Accent.g, ShopConfig.Colors.Accent.b, 80)
    surface.DrawRect(0, self.TitleBarHeight + self.CategoryBarHeight, w, 1)
end

-- ============================================================================
-- PerformLayout - 布局主窗口元素
-- ============================================================================
function PANEL:PerformLayout(w, h)
    self.CloseButton:SetSize(self.TitleBarHeight, self.TitleBarHeight)
    self.CloseButton:SetPos(w - self.TitleBarHeight, 0)
    local pointsMargin = 15
    self.MutationPointsLabel:SetPos(pointsMargin, 0)
    self.MutationPointsLabel:SetTall(self.TitleBarHeight)
    self.MutationPointsLabel:SizeToContentsX()
    self.MutationPointsLabel:SetContentAlignment(6)
    self.TitleLabel:SetPos(0, 0)
    self.TitleLabel:SetSize(w, self.TitleBarHeight)
    self.TitleLabel:SetContentAlignment(5)
    self.TabsContainer:SetPos(0, self.TitleBarHeight); self.TabsContainer:SetSize(w, self.CategoryBarHeight)
    local contentY = self.TitleBarHeight + self.CategoryBarHeight + 1
    self.ItemList:SetPos(0, contentY)
    self.ItemList:SetSize(w, h - contentY)
end

-- ============================================================================
-- CreateCategoryTabs - 创建分类标签
-- ============================================================================
function PANEL:CreateCategoryTabs()
    local sortedKeys = self:GetSortedCategories()
    local innerContainer = vgui.Create("DPanel", self.TabsContainer)
    innerContainer:SetPaintBackground(false)

    for _, categoryID in ipairs(sortedKeys) do
        local data = GAMEMODE.ZombieShopCategories[categoryID]
        local tab = vgui.Create("DButton", innerContainer)
        tab:SetText(data.Name)
        tab:SetFont(ShopConfig.Fonts.Tab)
        tab:SetTextColor(ShopConfig.Colors.TextPrimary)
        tab.CategoryID = categoryID
        tab.DoClick = function(btn) self:SwitchCategory(btn.CategoryID) end

        tab.IndicatorColor = Color(0,0,0,0)
        tab.Paint = function(btn, w, h)
            local active = (self.ActiveCategory == btn.CategoryID)
            if active then
                -- 选中：白底 + 深色文字 + 底部绿色高亮线（与僵尸选择界面标签一致）
                btn:SetTextColor(Color(20, 20, 20))
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 235))
                surface.SetDrawColor(90, 255, 120, 230)
                surface.DrawRect(2, h - 3, w - 4, 3)
            else
                -- 未选中：半透明黑底 + 白色文字
                btn:SetTextColor(btn:IsHovered() and Color(255, 255, 255) or Color(210, 210, 210))
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, btn:IsHovered() and 110 or 80))
            end
        end
        self.CategoryTabs[categoryID] = tab
    end
end

-- ============================================================================
-- SwitchCategory - 切换当前显示的分类
-- ============================================================================
function PANEL:SwitchCategory(categoryID, bForce)
    if not bForce and self.ActiveCategory == categoryID then return end
    self.ActiveCategory = categoryID
    surface.PlaySound("ui/buttonclick.wav")
    for _, tab in pairs(self.CategoryTabs) do if IsValid(tab) and tab.Invalidate then tab:Invalidate(true) end end
    self:PopulateItemList()
end

-- ============================================================================
-- PopulateItemList - 填充当前分类下的突变项目列表
-- ============================================================================
function PANEL:PopulateItemList()
    self.ItemList:Clear()
    if not self.ActiveCategory then return end
    local activeCategoryData = GAMEMODE.ZombieShopCategories[self.ActiveCategory]
    if not activeCategoryData then return end
    for _, mutationData in ipairs(GAMEMODE.Mutations) do
        if mutationData.Category == activeCategoryData then
            local itemRow = vgui.Create("ZSMutationItemRow", self.ItemList:GetCanvas())
            itemRow:SetMutation(mutationData)
        end
    end
    self.ItemList:InvalidateLayout(true)
end

-- ============================================================================
-- StyleScrollbar - 自定义滚动条样式
-- ============================================================================
function PANEL:StyleScrollbar()
    local scrollBar = self.ItemList:GetVBar()
    local scale = BetterScreenScale()
    scrollBar:SetWide(math.floor(4 * scale))
    if scrollBar.btnUp then scrollBar.btnUp:SetVisible(false) end
    if scrollBar.btnDown then scrollBar.btnDown:SetVisible(false) end

    scrollBar.Paint = function(pnl, w, h)
        surface.SetDrawColor(0, 0, 0, 35)
        surface.DrawRect(0, 0, w, h)
    end
    scrollBar.btnGrip.Paint = function(pnl, w, h)
        local alpha = pnl:IsHovered() and 85 or 55
        surface.SetDrawColor(255, 255, 255, alpha)
        draw.RoundedBox(w * 0.5, 1, 1, math.max(1, w - 2), math.max(4, h - 2), Color(255, 255, 255, alpha))
    end
    scrollBar.btnUp.Paint = function() end
    scrollBar.btnDown.Paint = function() end
end

-- ============================================================================
-- Close - 关闭窗口（带淡出动画）
-- ============================================================================
function PANEL:Close()
    self:AlphaTo(0, 0.15, 0, function() self:Remove() end)
end

vgui.Register("MutationShopFrame", PANEL, "DFrame")
