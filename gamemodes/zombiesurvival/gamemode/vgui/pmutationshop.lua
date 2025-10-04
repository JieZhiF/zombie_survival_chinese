-- ============================================================================
-- 商店配置 (Shop Configuration) - (原版设计 + 价格 + 快速动画)
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
    
    AnimationSpeed = 10, -- [[ MODIFIED ]] -- 动画速度乘数 (原为8)

    Fonts = {
        Title = "ZSHUDFontSmall",
        Tab = "ZSHUDFontSmall",
        ItemName = "ZSHUDFontSmall",
        ItemDesc = "ZSHUDFontTiny",
        Button = "ZSHUDFontTiny",
        CloseButton = "ZSHUDFontSmall",
        ItemPrice = "ZSHUDFontSmall" -- [[ NEW ]] -- 价格字体
    },

    Colors = {
        Background = Color(40, 42, 48, 245),
        TitleBar = Color(50, 52, 58, 255),
        CategoryBar = Color(45, 47, 53, 255),
        TextPrimary = Color(220, 221, 222),
        TextSecondary = Color(150, 152, 155),
        TextTitle = Color(200, 220, 255),
        TextPrice = Color(255, 199, 71), -- [[ NEW ]] -- 价格颜色 (金色)
        Accent = Color(35, 180, 220),
        ButtonBuy = Color(40, 160, 90),
        ButtonBuyHover = Color(60, 190, 110),
        ButtonOwned = Color(180, 70, 70),
        ButtonDisabled = Color(100, 100, 100),
        CloseButtonHover = Color(220, 50, 50),
        ListItem = Color(255, 255, 255, 8),
        ListItemHover = Color(255, 255, 255, 16),
        ScrollbarGrip = Color(255, 255, 255, 60),
        ScrollbarTrack = Color(0, 0, 0, 50)
    }
}

-- 辅助函数：动画颜色
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
-- VGUI 面板: 单个突变项目行 (ZSMutationItemRow)
-- ============================================================================
local PANEL = {}

function PANEL:Init()
    self:SetTall(ShopConfig.ItemRowHeight)
    self:Dock(TOP)
    self:DockMargin(0, 0, 0, 5)

    self.Icon = vgui.Create("DImage", self)
    self.Icon:SetSize(ShopConfig.ItemIconSize, ShopConfig.ItemIconSize)
    
    self.NameLabel = vgui.Create("DLabel", self)
    self.NameLabel:SetFont(ShopConfig.Fonts.ItemName)
    self.NameLabel:SetTextColor(ShopConfig.Colors.TextPrimary)
    self.NameLabel:SetWrap(true)
    self.NameLabel:SetAutoStretchVertical(true)

    self.DescLabel = vgui.Create("DLabel", self)
    self.DescLabel:SetFont(ShopConfig.Fonts.ItemDesc)
    self.DescLabel:SetTextColor(ShopConfig.Colors.TextSecondary)
    self.DescLabel:SetWrap(true)
    self.DescLabel:SetAutoStretchVertical(true)
    
    -- [[ NEW ]] -- 创建价格标签
    self.PriceLabel = vgui.Create("DLabel", self)
    self.PriceLabel:SetFont(ShopConfig.Fonts.ItemPrice)
    self.PriceLabel:SetTextColor(ShopConfig.Colors.TextPrice)
    self.PriceLabel:SetContentAlignment(5) -- 居中对齐

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

    self.CurrentBGColor = ShopConfig.Colors.ListItem
end

function PANEL:PerformLayout(w, h)
    local iconMargin = (h - ShopConfig.ItemIconSize) / 2
    self.Icon:SetPos(10, iconMargin)

    self.PurchaseButton:SetPos(w - ShopConfig.ItemButtonWidth - 10, (h - ShopConfig.ItemButtonHeight) / 2)
    
    -- [[ MODIFIED ]] -- 布局价格标签
    self.PriceLabel:SizeToContents()
    self.PriceLabel:SetPos(self.PurchaseButton.x - self.PriceLabel:GetWide() - 10, 0)
    self.PriceLabel:SetTall(h)

    local textStartX = self.Icon.x + self.Icon:GetWide() + 15
    local textMaxWidth = self.PriceLabel.x - textStartX - 15 -- 调整文本宽度以避免与价格重叠
    
    self.NameLabel:SetWide(textMaxWidth)
    self.DescLabel:SetWide(textMaxWidth)
    
    local nameHeight = self.NameLabel:GetTall()
    local descHeight = self.DescLabel:GetTall()
    local textBlockHeight = nameHeight + descHeight + 4
    local textBlockStartY = (h - textBlockHeight) / 2
    
    self.NameLabel:SetPos(textStartX, textBlockStartY)
    self.DescLabel:SetPos(textStartX, textBlockStartY + nameHeight + 4)
end

function PANEL:Paint(w, h)
    local targetColor = self:IsHovered() and ShopConfig.Colors.ListItemHover or ShopConfig.Colors.ListItem
    self.CurrentBGColor = LerpColor(FrameTime() * ShopConfig.AnimationSpeed, self.CurrentBGColor, targetColor)
    draw.RoundedBox(4, 0, 0, w, h, self.CurrentBGColor)
end

function PANEL:SetMutation(mutationData)
    self.Data = mutationData
    if not self.Data then return end
    
    self.Data.Name = self.Data.Name or "未设置名字"
    self.Data.Description = self.Data.Description or "未设置描述"
   
    self.NameLabel:SetText(self.Data.Name)
    self.DescLabel:SetText(self.Data.Description)
    
    -- [[ NEW ]] -- 设置价格文本
    self.PriceLabel:SetText(self.Data.Price or "??")
    
    self.Icon:SetVisible(true)
    if not self.Data.Icon then
        self.Icon:SetVisible(false)
    end
    self.Data.Icon = self.Data.Icon or "icon16/package.png"
    self.Icon:SetImage(self.Data.Icon) 
    
    self:InvalidateLayout(true)
    local isOwned = false
    for _, sig in pairs(UsedMutations or {}) do
        if sig == self.Data.Signature then isOwned = true; break end
    end
    if isOwned then
        self.PriceLabel:SetVisible(false) -- 如果已拥有，则隐藏价格
        self.PurchaseButton:SetText("已拥有")
        self.PurchaseButton:SetEnabled(false)
        self.PurchaseButton.Paint = function(btn, w, h) draw.RoundedBox(8, 0, 0, w, h, ShopConfig.Colors.ButtonOwned) end
    end
end

function PANEL:Purchase()
    if not self.Data then return end
    local myTokens = LocalPlayer():GetTokens() or 0
    local CanPurchase = gamemode.Call("ZombieCanPurchase", LocalPlayer())
    RunConsoleCommand("zs_mutationshop_click", self.Data.Signature)
    if myTokens >= self.Data.Price and CanPurchase then
        --surface.PlaySound("buttons/button17.wav")
        table.insert(UsedMutations, self.Data.Signature)
        self:SetMutation(self.Data)
    end
end
vgui.Register("ZSMutationItemRow", PANEL, "DPanel")


-- ============================================================================
-- VGUI 面板: 商店主窗口 (MutationShopFrame)
-- ============================================================================
local pMutationShop
function OpenMutationShop(used)
    if IsValid(pMutationShop) then pMutationShop:Remove() end
    -- [[ FIX START ]] --
    -- 仅当传入新的 `used` 数据时才更新全局列表。
    -- 这可以防止在没有新数据的情况下打开商店时（例如通过按键绑定）重置玩家的已拥有物品列表。
    if used then
        UsedMutations = used
    end

    -- 确保 `UsedMutations` 至少被初始化为一个空表，以防万一。
    UsedMutations = UsedMutations or {}
    -- [[ FIX END ]] --

    pMutationShop = vgui.Create("MutationShopFrame")
end

PANEL = {}
PANEL.TitleBarHeight = ShopConfig.TitleBarHeight
PANEL.CategoryBarHeight = ShopConfig.CategoryBarHeight

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

    self.TitleLabel = vgui.Create("DLabel", self)
    self.TitleLabel:SetText(ShopConfig.Title)
    self.TitleLabel:SetFont(ShopConfig.Fonts.Title)
    self.TitleLabel:SetTextColor(ShopConfig.Colors.TextTitle)
    self.TitleLabel:SetContentAlignment(5)

    self.MutationPointsLabel = vgui.Create("DLabel", self)
    self.MutationPointsLabel:SetFont(ShopConfig.Fonts.Title)
    self.MutationPointsLabel:SetTextColor(ShopConfig.Colors.TextPrimary)

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

    self.ItemList = vgui.Create("DScrollPanel", self)
    local pad = ShopConfig.ContentPadding
    self.ItemList:GetCanvas():DockPadding(pad, pad, pad, pad)
    self:StyleScrollbar()
    
    local sortedKeys = self:GetSortedCategories()
    if sortedKeys[1] then self.ActiveCategory = sortedKeys[1] end
    
    self:CreateCategoryTabs()
    self:Center()

    -- [[ MODIFIED ]] -- 窗口出现动画时间改为0.1秒
    self:SetAlpha(0)
    self:AlphaTo(255, 0.1, 0)
end

function PANEL:Think()
    local Tokens = math.floor(LocalPlayer():GetTokens() or 0)
    self.MutationPointsLabel:SetText(translate.Get("mutation_MutationPoints").. Tokens)

    if self.m_bFirstThink then
        self.m_bFirstThink = false
        if self.ActiveCategory then self:SwitchCategory(self.ActiveCategory, true) end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(12, 0, 0, w, h, ShopConfig.Colors.Background)
    DrawVerticalGradient(0, 0, w, self.TitleBarHeight, ShopConfig.Colors.TitleBar, ShopConfig.Colors.CategoryBar)
    surface.SetDrawColor(ShopConfig.Colors.Accent)
    surface.DrawRect(0, self.TitleBarHeight + self.CategoryBarHeight, w, 1)
end

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
            if btn:IsHovered() and self.ActiveCategory ~= btn.CategoryID then
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 20))
            end
            local targetColor = (self.ActiveCategory == btn.CategoryID) and ShopConfig.Colors.Accent or Color(0, 0, 0, 0)
            btn.IndicatorColor = LerpColor(FrameTime() * ShopConfig.AnimationSpeed, btn.IndicatorColor, targetColor)
            surface.SetDrawColor(btn.IndicatorColor)
            surface.DrawRect(0, h - 3, w, 3)
        end
        self.CategoryTabs[categoryID] = tab
    end
end

function PANEL:SwitchCategory(categoryID, bForce)
    if not bForce and self.ActiveCategory == categoryID then return end
    self.ActiveCategory = categoryID
    surface.PlaySound("ui/buttonclick.wav")
    for _, tab in pairs(self.CategoryTabs) do if IsValid(tab) and tab.Invalidate then tab:Invalidate(true) end end
    self:PopulateItemList()
end

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

function PANEL:StyleScrollbar()
    local scrollBar = self.ItemList:GetVBar()
    scrollBar.Paint = function(pnl, w, h) draw.RoundedBox(4, 0, 0, w, h, ShopConfig.Colors.ScrollbarTrack) end
    scrollBar.btnGrip.Paint = function(pnl, w, h)
        local margin = 2
        draw.RoundedBox(4, margin, 0, w - (margin * 2), h, ShopConfig.Colors.ScrollbarGrip)
    end
    scrollBar.btnUp.Paint = function() end
    scrollBar.btnDown.Paint = function() end
end

function PANEL:Close()
    -- [[ MODIFIED ]] -- 窗口关闭动画时间改为0.1秒
    self:AlphaTo(0, 0.15, 0, function() self:Remove() end)
end

vgui.Register("MutationShopFrame", PANEL, "DFrame")