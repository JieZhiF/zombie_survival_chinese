-- ============================================================================
-- POptions - 游戏设置界面（ZSOptions）
-- 包含界面/HUD、游戏性、环境与效果、武器设置等分类
-- 支持复选框、滑块、颜色选择器、下拉框和字体编辑器
-- ============================================================================

local PANEL = {}

-- 定义常量以便于统一修改样式
local COLOR_BG = Color(45, 45, 55, 240)
local COLOR_BG_INNER = Color(35, 35, 45, 220)
local COLOR_ACCENT = Color(40, 155, 255)
local COLOR_TEXT = Color(248, 248, 248, 240)
local FONT_TOP_CATEGORY = "ZS2DFontHarmony"
local FONT_SUB_CATEGORY = "ZS2DFontHarmony"
local FONT_LABEL = "ZS2DFontHarmonySmall"
local FONT_LABEL_SMALL = "ZS2DFontHarmonySmall"

-- ============================================================================
-- Init - 初始化设置面板
-- ============================================================================
function PANEL:Init()
    local scale = BetterScreenScale and BetterScreenScale() or 1
    self:SetSize(ScrW() * 0.45 * scale, ScrH() * 0.55 * scale)
    self:Center()
    self:MakePopup()

    self:PopulateOptionsData()
    self:CreateLayout()
    self:CreateCloseButton()

    if not IsValid(self) or not IsValid(self.TopCategoryBar) then return end
    -- 自动选中第一个顶级分类
    for _, child in ipairs(self.TopCategoryBar:GetChildren()) do
        if IsValid(child) and isfunction(child.DoClick) then
            child:DoClick(false)
            break
        end
    end
end

-- ============================================================================
-- Paint - 绘制圆角背景
-- ============================================================================
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
end

-- ============================================================================
-- CreateLayout - 创建界面布局
-- ============================================================================
function PANEL:CreateLayout()
    self:CreateTopCategoryBar()

    local mainArea = vgui.Create("DPanel", self)
    mainArea:Dock(FILL)
    mainArea:DockMargin(0, 8, 0, 0)
    mainArea.Paint = function() end

    local sub_category_width = self:GetWide() * 0.15
    self.SubCategoryList = vgui.Create("DScrollPanel", mainArea)
    self.SubCategoryList:SetWide(sub_category_width)
    self.SubCategoryList:Dock(LEFT)
    self.SubCategoryList:DockMargin(8, 0, 4, 8)

    self.ContentPanel = vgui.Create("DPanel", mainArea)
    self.ContentPanel:Dock(FILL)
    self.ContentPanel:DockMargin(4, 0, 8, 8)
    self.ContentPanel.Paint = function(pnl, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLOR_BG_INNER)
    end
end

-- ============================================================================
-- CreateCloseButton - 创建关闭按钮
-- ============================================================================
function PANEL:CreateCloseButton()
    local closeBtn = vgui.Create("DButton", self)
    closeBtn:SetSize(50, 50)
    closeBtn:SetPos(self:GetWide() - 75, 0)
    closeBtn:SetZPos(1)
    closeBtn:SetText("×")
    closeBtn:SetFont("ZS3D2DFontSmall")
    closeBtn:SetTextColor(COLOR_TEXT)
    closeBtn:SetContentAlignment(5)

    closeBtn.Paint = function(pnl, w, h)
        if pnl:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(220, 50, 50, 230))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 0))
        end
    end

    closeBtn.DoClick = function()
        self:Remove()
    end
end

-- ============================================================================
-- PopulateOptionsData - 填充设置数据
-- ============================================================================
function PANEL:PopulateOptionsData()
    self.SettingsData = {
        { name = "Interface", text = "界面和HUD", subCategories = {
            {name = "HUD", text = translate.Get("Category_HUD")},
            {name = "Crosshair", text = translate.Get("Category_Crosshair")},
            {name = "Color", text = translate.Get("Category_Color")},
            {name = "Fonts", text = "字体设置"},
        }},
        { name = "Gameplay", text = "游戏性", subCategories = {
            {name = "Other", text = translate.Get("Category_Other")},
        }},
        { name = "Visuals", text = "环境与效果", subCategories = {
            {name = "Environment", text = translate.Get("Category_Environment")},
            {name = "Effect", text = translate.Get("Category_Effect")},
        }},
        { name = "Weapon", text = "武器设置", subCategories = {
            {name = "WeaponSlot", text = translate.Get("Category_WeaponSlot")},
        }},
    }

    -- 自动生成字体列表数据
    local fontOptions = {}
    
    for fontID, def in pairs(ZSFontDLC.FontDefinitions) do
        table.insert(fontOptions, {
            type = "font_entry",
            label = def.name,
            fontID = fontID,
            default = def.default
        })
    end
    
    table.sort(fontOptions, function(a, b) return a.label < b.label end)

    self.OptionsData = {
        HUD = {
            { type = "checkbox", label = "Option_AlwaysShowNailHealth", convar = "zs_alwaysshownails" },
            { type = "checkbox", label = "Option_ShowXP", convar = "zs_drawxp" },
            { type = "checkbox", label = "Option_NoFloatingScore", convar = "zs_nofloatingscore" },
            { type = "checkbox", label = "Option_HideWeaponAndPack", convar = "zs_hidepacks" },
            { type = "checkbox", label = "Option_NoFriendOpacity", convar = "zs_showfriends" },
            { type = "checkbox", label = "Option_EnablePostProcessing", convar = "zs_postprocessing" },
            { type = "checkbox", label = "Option_EnableFilmGrain", convar = "zs_filmgrain" },
            { type = "checkbox", label = "Option_EnableColorMod", convar = "zs_colormod" },
            { type = "checkbox", label = "Option_EnableHumanHealthFlash", convar = "zs_drawpainflash" },
            { type = "checkbox", label = "Option_EnableFontEffects", convar = "zs_fonteffects" },
            { type = "checkbox", label = "Option_EnableHealthAura", convar = "zs_auras" },
            { type = "checkbox", label = "Option_EnableDamageIndicators", convar = "zs_damagefloaters" },
            { type = "checkbox", label = "Option_EnableMovementViewRoll", convar = "zs_movementviewroll" },
            { type = "checkbox", label = "Option_EnableMessageBeaconVisibility", convar = "zs_messagebeaconshow" },
            { type = "checkbox", label = "Option_FilmMode", convar = "zs_filmmode" },
            { type = "checkbox", label = "Option_HideViewModels", convar = "zs_hideviewmodels" },
            { type = "checkbox", label = "Option_DamageFloatersWalls", convar = "zs_damagefloaterswalls" },
            { type = "slider", label = "Option_InterfaceHUDScale", convar = "zs_interfacesize", min = 0.7, max = 1.6, decimals = 1 },
            { type = "slider", label = "Option_IronsightZoom", convar = "zs_ironsightzoom", min = 0, max = 1, decimals = 2 },
            { type = "slider", label = "Option_FilmGrain", convar = "zs_filmgrainopacity", min = 0, max = 255, decimals = 0 },
            { type = "slider", label = "Option_TransparencyRadius", convar = "zs_transparencyradius", min = 0, max = 8192, decimals = 0 },
            { type = "slider", label = "Option_ThirdPersonTransparencyRadius", convar = "zs_transparencyradius3p", min = 0, max = 8192, decimals = 0 },
            { type = "combobox", label = "Option_WeaponHUDDisplay", choices = {
                { text = translate.Get("Option_3DDisplay"), value = 0 },
                { text = translate.Get("Option_2DDisplay"), value = 1 },
                { text = translate.Get("Option_AllDisplay"), value = 2 }
            }, onselect = function(index, value) RunConsoleCommand("zs_weaponhudmode", value) end, getdefault = function() return GetConVarNumber("zs_weaponhudmode") end },
            { type = "combobox", label = "Option_HumanHealthDisplay", choices = {
                { text = translate.Get("Option_PercentageHealth"), value = 0 },
                { text = translate.Get("Option_NumericHealth"), value = 1 }
            }, onselect = function(index, value) RunConsoleCommand("zs_healthtargetdisplay", value) end, getdefault = function() return GetConVarNumber("zs_healthtargetdisplay") end }
        },
        Environment = {
            { type = "checkbox", label = "Option_EnableAmbientMusic", convar = "zs_beats" },
            { type = "checkbox", label = "Option_EnableLastManMusic", convar = "zs_playmusic" },
            { type = "slider", label = "Option_MusicVolume", convar = "zs_beatsvolume", min = 0, max = 100, decimals = 0 },
            {
                type = "combobox",
                label = "Option_HumanAmbientMusic",
                choices = (function()
                    local t = {}
                    if not GAMEMODE or not GAMEMODE.Beats then return t end
                    for setname in pairs(GAMEMODE.Beats) do
                        if setname ~= GAMEMODE.BeatSetHumanDefault then
                            table.insert(t, { text = setname, value = setname })
                        end
                    end
                    table.insert(t, { text = "none", value = "none" })
                    table.insert(t, { text = "default", value = "default" })
                    return t
                end)(),
                onselect = function(index, value)
                    RunConsoleCommand("zs_beatset_human", value)
                end,
                getdefault = function()
                    if not GAMEMODE then return "default" end
                    local current = GAMEMODE.BeatSetHuman
                    return current == GAMEMODE.BeatSetHumanDefault and "default" or current
                end
            },
            {
                type = "combobox",
                label = "Option_ZombieAmbientMusic",
                choices = (function()
                    local t = {}
                    if not GAMEMODE or not GAMEMODE.Beats then return t end
                    for setname in pairs(GAMEMODE.Beats) do
                        if setname ~= GAMEMODE.BeatSetZombieDefault then
                            table.insert(t, { text = setname, value = setname })
                        end
                    end
                    table.insert(t, { text = "none", value = "none" })
                    table.insert(t, { text = "default", value = "default" })
                    return t
                end)(),
                onselect = function(index, value)
                    RunConsoleCommand("zs_beatset_zombie", value)
                end,
                getdefault = function()
                    if not GAMEMODE then return "default" end
                    local current = GAMEMODE.BeatSetZombie
                    return current == GAMEMODE.BeatSetZombieDefault and "default" or current
                end
            },
        },
        Crosshair = {
            { type = "checkbox", label = "Option_DrawCrosshairOnAim", convar = "zs_ironsightscrosshair" },
            { type = "checkbox", label = "Option_DisableCrosshairRotate", convar = "zs_nocrosshairrotate" },
            { type = "checkbox", label = "Option_Usecirclecrosshair", convar = "zs_crosshair_cicrle" },
            { type = "checkbox", label = "Option_zsw_Cooldown_Enable", convar = "zsw_enable_cooldown" },
            { type = "checkbox", label = "Option_zsw_enable_hud", convar = "zsw_enable_hud" },
            { type = "checkbox", label = "Option_zsw_rts_hud", convar = "zsw_enable_rts_hud" },
            { type = "checkbox", label = "Option_zsw_crosshair_mode", convar = "zsw_crosshair_mode" },
            { type = "slider", label = "Option_CrosshairLineCount", convar = "zs_crosshairlines", min = 2, max = 8, decimals = 0 },
            { type = "slider", label = "Option_CrosshairAngleOffset", convar = "zs_crosshairoffset", min = 0, max = 90, decimals = 0 },
            { type = "slider", label = "Option_CrosshairThickness", convar = "zs_crosshairthickness", min = 0.5, max = 2, decimals = 1 },
        },
        Color = {
            { type = "color", label = "Option_CrosshairColor", r = "zs_crosshair_colr", g = "zs_crosshair_colg", b = "zs_crosshair_colb", a = "zs_crosshair_cola" },
            { type = "color", label = "Option_CrosshairAuxiliaryColor", r = "zs_crosshair_colr2", g = "zs_crosshair_colg2", b = "zs_crosshair_colb2", a = "zs_crosshair_cola2" },
            { type = "color", label = "Option_HumanHealthIndicatorHigh", r = "zs_auracolor_full_r", g = "zs_auracolor_full_g", b = "zs_auracolor_full_b", noalpha = true },
            { type = "color", label = "Option_HumanHealthIndicatorLow", r = "zs_auracolor_empty_r", g = "zs_auracolor_empty_g", b = "zs_auracolor_empty_b", noalpha = true },
        },
        Effect = {
            { type = "checkbox", label = "Option_ReflectObjects", convar = "mat_specular" },
            { type = "checkbox", label = "Option_CharacterEyes", convar = "r_eyes" },
            { type = "checkbox", label = "Option_FixCharacterEyes", convar = "r_eyemove" },
            { type = "checkbox", label = "Option_ShowOwnShadow", convar = "cl_drawownshadow" },
            { type = "checkbox", label = "Option_ReduceEffects", convar = "mat_reduceparticles" },
            { type = "checkbox", label = "Option_ShowWaterReflection", convar = "r_WaterDrawReflection" },
            { type = "checkbox", label = "Option_ShowWaterRefraction", convar = "r_WaterDrawRefraction" },
            { type = "checkbox", label = "Option_ShowZombieBlood", convar = "violence_ablood" },
            { type = "checkbox", label = "Option_ShowZombieSkull", convar = "violence_agibs" },
            { type = "checkbox", label = "Option_ShowHumanBlood", convar = "violence_hblood" },
            { type = "checkbox", label = "Option_ShowHumanSkull", convar = "violence_hgibs" },
            { type = "slider", label = "Option_ModelDetailLevel", convar = "r_lod", min = -1, max = 2, decimals = 0 },
        },
        Other = {
            { type = "checkbox", label = "Option_ThirdPersonKnockdown", convar = "zs_thirdpersonknockdown" },
            { type = "checkbox", label = "Option_AlwaysBecomeZombie", convar = "zs_alwaysvolunteer" },
            { type = "checkbox", label = "Option_AlwaysQuickBuy", convar = "zs_alwaysquickbuy" },
            { type = "checkbox", label = "Option_SuicideOnZombieSwitch", convar = "zs_suicideonchange" },
            { type = "checkbox", label = "Option_DisableAutoRevive", convar = "zs_noredeem" },
            { type = "checkbox", label = "Option_DisableAmmoFromBoxes", convar = "zs_nousetodeposit" },
            { type = "checkbox", label = "Option_DisablePropPickup", convar = "zs_nopickupprops" },
            { type = "checkbox", label = "Option_DisableIronSights", convar = "zs_noironsights" },
            { type = "checkbox", label = "Option_DisableScopes", convar = "zs_disablescopes" },
            { type = "checkbox", label = "Option_PreventBossPick", convar = "zs_nobosspick" },
            { type = "checkbox", label = "Option_OneClickUnluck", convar = "zs_one_click_unlock" },
            { type = "slider", label = "Option_DamageNumberSize", convar = "zs_dmgnumberscale", min = 0.5, max = 2, decimals = 1 },
            { type = "slider", label = "Option_DamageNumberSpeed", convar = "zs_dmgnumberspeed", min = 0, max = 1, decimals = 1 },
            { type = "slider", label = "Option_DamageNumberLife", convar = "zs_dmgnumberlife", min = 0.2, max = 1.5, decimals = 1 },
            { type = "slider", label = "Option_PropRotationSensitivity", convar = "zs_proprotationsens", min = 0.1, max = 4, decimals = 1 },
            { type = "combobox", label = "Option_PropRotationAngle", choices = {
                { text = translate.Get("Option_PropRotationAngle_NONE"), value = 0 },
                { text = translate.Get("Option_PropRotationAngle_15"), value = 15 },
                { text = translate.Get("Option_PropRotationAngle_30"), value = 30 },
                { text = translate.Get("Option_PropRotationAngle_45"), value = 45 },
            }, onselect = function(index, value) RunConsoleCommand("zs_proprotationsnap", value) end, getdefault = function() return GetConVarNumber("zs_proprotationsnap") end },
        },
        WeaponSlot = {
            {type = "slider", label = "Option_wepslot_unarmed", convar = "zs_wepslot_unarmed", min = 0, max = 6, decimals = 0},
            { type = "slider", label = "Option_wepslot_melee", convar = "zs_wepslot_melee", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_repairtools", convar = "zs_wepslot_repairtools", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_pistols", convar = "zs_wepslot_pistols", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_smgs", convar = "zs_wepslot_smgs", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_assaultrifles", convar = "zs_wepslot_assaultrifles", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_rifles", convar = "zs_wepslot_rifles", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_shotguns", convar = "zs_wepslot_shotguns", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_bolt", convar = "zs_wepslot_bolt", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_medicaltools", convar = "zs_wepslot_medicaltools", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_medkits", convar = "zs_wepslot_medkits", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_deployables", convar = "zs_wepslot_deployables", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_misctools", convar = "zs_wepslot_misctools", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_explosives", convar = "zs_wepslot_explosives", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_food", convar = "zs_wepslot_food", min = 0, max = 6, decimals = 0 },
        },
        Fonts = fontOptions,
    }
end

-- ============================================================================
-- CreateTopCategoryBar - 创建顶部主分类栏（带拖拽功能）
-- ============================================================================
function PANEL:CreateTopCategoryBar()
    self.TopCategoryBar = vgui.Create("DPanel", self)
    self.TopCategoryBar:Dock(TOP)
    self.TopCategoryBar:SetTall(50)
    self.TopCategoryBar:DockMargin(0, 0, 0, 0)

    -- 为顶部大类栏添加拖拽功能
    self.TopCategoryBar.m_bDragging = false
    self.TopCategoryBar.m_DragStart = {}
    self.TopCategoryBar.OnMousePressed = function( pnl, mcode )
        if mcode == MOUSE_LEFT then
            pnl.m_bDragging = true
            pnl.m_DragStart = { gui.MouseX() - self.x, gui.MouseY() - self.y }
        end
    end
    self.TopCategoryBar.OnMouseReleased = function( pnl, mcode )
        if mcode == MOUSE_LEFT then
            pnl.m_bDragging = false
        end
    end
    self.TopCategoryBar.Think = function( pnl )
        if pnl.m_bDragging then
            if input.IsMouseDown( MOUSE_LEFT ) then
                self:SetPos( gui.MouseX() - pnl.m_DragStart[1], gui.MouseY() - pnl.m_DragStart[2] )
            else
                pnl.m_bDragging = false
            end
        end
    end

    self.TopCategoryBar.PerformLayout = function(pnl, w, h)
        local buttons = {}
        for _, child in ipairs(pnl:GetChildren()) do
           table.insert(buttons, child)
        end
        if #buttons == 0 then return end

        local buttonMargin = 4
        local totalButtonWidth = 0
        for _, btn in ipairs(buttons) do
            totalButtonWidth = totalButtonWidth + btn:GetWide()
        end
        totalButtonWidth = totalButtonWidth + buttonMargin * (#buttons - 1)

        local currentX = (w - totalButtonWidth) / 2
        local buttonY = (h - buttons[1]:GetTall() - 2) / 2

        for _, btn in ipairs(buttons) do
            btn:SetPos(currentX, buttonY)
            currentX = currentX + btn:GetWide() + buttonMargin
        end
    end

    self.TopCategoryBar.Paint = function(pnl, w, h)
        surface.SetDrawColor(COLOR_BG_INNER)
        surface.DrawRect(0, h - 2, w, 2)
    end

    local rootPanel = self

    -- 创建每个顶级分类按钮
    for _, catData in ipairs(self.SettingsData) do
        local btn = vgui.Create("DButton", self.TopCategoryBar)
        btn:SetText(catData.text)
        btn:SetTextColor(COLOR_TEXT)
        btn:SetFont(FONT_TOP_CATEGORY)
        btn:SetContentAlignment(5)
        btn:SetSize(140, 35)
        btn.subCategories = catData.subCategories
        btn.isSelected = false

        function btn:SetSelected(b) self.isSelected = b end

        function btn:Paint(w, h)
            local bgColor = Color(0,0,0,0)
            if self.isSelected then
                bgColor = COLOR_ACCENT
            elseif self:IsHovered() then
                bgColor = ColorAlpha(COLOR_ACCENT, 100)
            end
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
        end

        function btn:DoClick(play_sound)
            for _, child in ipairs(self:GetParent():GetChildren()) do
                if IsValid(child) and child.SetSelected then child:SetSelected(false) end
            end
            self:SetSelected(true)
            rootPanel:UpdateSubCategoryList(self.subCategories)
            timer.Simple(0, function()
                if not IsValid(rootPanel) then return end
                local subCategoryList = rootPanel.SubCategoryList
                if IsValid(subCategoryList) and IsValid(subCategoryList:GetCanvas()) then
                    local children = subCategoryList:GetCanvas():GetChildren()
                    if #children > 0 then
                        local firstBtn = children[1]
                        if IsValid(firstBtn) and isfunction(firstBtn.DoClick) then
                            firstBtn:DoClick(false)
                        end
                    end
                end
            end)
            if play_sound ~= false then
                surface.PlaySound("ui/buttonclick.wav")
            end
        end
    end
end

-- ============================================================================
-- UpdateSubCategoryList - 更新左侧子分类列表
-- ============================================================================
function PANEL:UpdateSubCategoryList(subCategories)
    if not IsValid(self.SubCategoryList) then return end
    self.SubCategoryList:Clear()

    local rootPanel = self

    for _, cat in ipairs(subCategories) do
        local btn = vgui.Create("DButton", self.SubCategoryList)
        btn:SetText(cat.text)
        btn:SetTextColor(COLOR_TEXT)
        btn:SetFont(FONT_SUB_CATEGORY)
        btn:SetContentAlignment(5)
        btn:Dock(TOP)
        btn:SetTall(50)
        btn:DockMargin(0, 0, 0, 4)
        btn.categoryName = cat.name
        btn.isSelected = false
        btn.animStartTime = 0
        btn.animDuration = 0.2

        function btn:SetSelected(b)
            if self.isSelected ~= b then
                self.isSelected = b
                if b then self.animStartTime = CurTime() end
            end
        end

        function btn:Paint(w, h)
            local bgColor = COLOR_BG
            if self.isSelected then
                local progress = math.Clamp((CurTime() - self.animStartTime) / self.animDuration, 0, 1)
                local animatedAlpha = Lerp(progress, 40, 240)
                bgColor = ColorAlpha(COLOR_ACCENT, animatedAlpha)
            elseif self:IsHovered() then
                 draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(COLOR_ACCENT, 100))
            end
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
        end

        function btn:DoClick(play_sound)
            for _, child in ipairs(self:GetParent():GetChildren()) do
                if child.SetSelected and child != self then
                    child:SetSelected(false)
                end
            end
            self:SetSelected(true)
            rootPanel:UpdateContent(self.categoryName)

            if play_sound ~= false then
                surface.PlaySound("ui/buttonclick.wav")
            end
        end
    end
end

-- ============================================================================
-- UpdateContent - 根据选中的子分类更新右侧内容面板
-- ============================================================================
function PANEL:UpdateContent(category)
    if not IsValid(self.ContentPanel) then return end
    self.ContentPanel:Clear()

    local options = self.OptionsData[category]
    if not options then return end

    local list = vgui.Create("DPanelList", self.ContentPanel)
    list:Dock(FILL)
    list:EnableVerticalScrollbar(true)
    list:SetPadding(15)
    list:SetSpacing(15)

    for _, data in ipairs(options) do
        if data.type == "checkbox" then
            self:AddCheckbox(list, data)
        elseif data.type == "slider" then
            self:AddSlider(list, data)
        elseif data.type == "color" then
            self:AddColorMixer(list, data)
        elseif data.type == "combobox" then
            self:AddComboBox(list, data)
        elseif data.type == "font_entry" then
            self:AddFontUsageEntry(list, data)
        end
    end
end

-- 辅助函数 (创建UI控件) - 新的简约高级感样式

-- ============================================================================
-- AddCheckbox - 添加自定义 iOS 风格复选框
-- ============================================================================
function PANEL:AddCheckbox(parent, data)
    local container = vgui.Create("DPanel", parent)
    container:SetTall(30)
    container:SetPaintBackground(false)
    parent:AddItem(container)

    local checkbox = vgui.Create("DCheckBox", container)
    checkbox:SetSize(90, 30)
    checkbox:Dock(LEFT)
    checkbox:DockMargin(0, 2, 0, 0)
    checkbox:SetConVar(data.convar)

    local convar_state = GetConVar(data.convar):GetBool()
    checkbox:SetValue(convar_state)

    checkbox.animProgress = checkbox:GetChecked() and 1 or 0
    checkbox.lastAnimTime = CurTime()

    checkbox.Paint = function(self, w, h)
        local checked = self:GetChecked()
        local targetProgress = checked and 1 or 0
        local deltaTime = CurTime() - self.lastAnimTime
        self.lastAnimTime = CurTime()
        self.animProgress = Lerp(deltaTime * 12, self.animProgress, targetProgress)

        local padding = 3
        local knobSize = h - padding * 2

        local COLOR_TRACK_OFF = Color(80, 85, 95, 255)
        local COLOR_KNOB_OFF = Color(180, 185, 195, 255)
        local COLOR_KNOB_ON = Color(255, 255, 255, 255)

        local trackColor = Color(
            Lerp(self.animProgress, COLOR_TRACK_OFF.r, COLOR_ACCENT.r),
            Lerp(self.animProgress, COLOR_TRACK_OFF.g, COLOR_ACCENT.g),
            Lerp(self.animProgress, COLOR_TRACK_OFF.b, COLOR_ACCENT.b)
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

    local label = vgui.Create("DLabel", container)
    label:Dock(FILL)
    label:SetMouseInputEnabled(true)
    label:SetFont(FONT_LABEL)
    label:SetText(translate.Get(data.label) or data.label)
    label:SetTextColor(COLOR_TEXT)
    label:SetContentAlignment(4)
    label:DockMargin(10, 0, 0, 0)

    label.DoClick = function()
        checkbox:SetValue(not checkbox:GetValue())
    end
end

-- ============================================================================
-- AddSlider - 添加滑块控件
-- ============================================================================
function PANEL:AddSlider(parent, data)
    local slider = vgui.Create("DNumSlider")
    slider:SetText(translate.Get(data.label) or data.label)
    slider:SetMin(data.min or 0)
    slider:SetMax(data.max or 100)
    slider:SetDecimals(data.decimals or 0)
    slider:SetConVar(data.convar)
    slider:SetDark(true)
    slider.Label:SetFont(FONT_LABEL)
    slider.Label:SetTextColor(COLOR_TEXT)

    if IsValid(slider.NumEntry) then
        slider.NumEntry:SetFont(FONT_LABEL)
    end

    parent:AddItem(slider)
end

-- ============================================================================
-- AddColorMixer - 添加颜色选择器
-- ============================================================================
function PANEL:AddColorMixer(parent, data)
    local label = vgui.Create("DLabel")
    label:SetText(translate.Get(data.label) or data.label)
    label:SetFont(FONT_LABEL)
    label:SetTextColor(COLOR_TEXT)
    label:SetDark(true)
    parent:AddItem(label)

    local picker = vgui.Create("DColorMixer")
    picker:SetAlphaBar(not data.noalpha)
    picker:SetPalette(false)
    picker:SetConVarR(data.r)
    picker:SetConVarG(data.g)
    picker:SetConVarB(data.b)
    if not data.noalpha and data.a then
        picker:SetConVarA(data.a)
    end
    picker:SetTall(120)
    parent:AddItem(picker)
end

-- ============================================================================
-- AddComboBox - 添加下拉选择框
-- ============================================================================
function PANEL:AddComboBox(parent, data)
    local label = vgui.Create("DLabel")
    label:SetText(translate.Get(data.label) or data.label)
    label:SetFont(FONT_LABEL)
    label:SetTextColor(COLOR_TEXT)
    label:SetDark(true)
    parent:AddItem(label)

    local combo = vgui.Create("DComboBox")
    local defaultVal = data.getdefault and data.getdefault()

    for i, choice in ipairs(data.choices) do
        combo:AddChoice(choice.text, choice.value)
        if defaultVal and choice.value == defaultVal then
            combo:SetText(choice.text)
        end
    end

    combo.OnSelect = function(pnl, index, text, val)
        if data.onselect then
            data.onselect(index, val)
        end
    end
    parent:AddItem(combo)
end

-- ============================================================================
-- AddFontUsageEntry - 添加字体设置行
-- ============================================================================
function PANEL:AddFontUsageEntry(parent, data)
    local container = vgui.Create("DPanel")
    container:SetTall(50)
    container.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 65, 150))
        surface.SetDrawColor(COLOR_ACCENT)
        surface.DrawRect(0, 0, 4, h)
    end

    local label = vgui.Create("DLabel", container)
    label:SetText(data.label)
    label:SetFont("ZS2DFontHarmony")
    label:SetTextColor(Color(240, 240, 240))
    label:Dock(LEFT)
    label:DockMargin(20, 0, 0, 0)
    label:SetWide(350)

    local btn = vgui.Create("DButton", container)
    btn:SetText("修改设置")
    btn:Dock(RIGHT)
    btn:DockMargin(0, 10, 10, 10)
    btn:SetWide(100)
    btn.DoClick = function()
        self:OpenRealtimeFontEditor(data.fontID, data.label, data.default)
    end

    parent:AddItem(container)
end

-- ============================================================================
-- OpenRealtimeFontEditor - 打开字体实时编辑器
-- ============================================================================
function PANEL:OpenRealtimeFontEditor(fontID, friendlyName, defaultData)
    local currentConfig = ZSFontDLC.GetConfig()[fontID] or defaultData
    local PREVIEW_FONT_ID = "ZSFontDLC_Temp_Preview"

    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 600)
    frame:SetTitle("编辑字体: " .. friendlyName)
    frame:Center()
    frame:MakePopup()
    frame:SetBackgroundBlur(true)

    -- 左侧预览区
    local leftPnl = vgui.Create("DPanel", frame)
    leftPnl:Dock(LEFT); leftPnl:SetWide(450); leftPnl:DockMargin(5,5,5,5)
    leftPnl.Paint = function(s,w,h) draw.RoundedBox(4,0,0,w,h,Color(30,30,30)) end

    local previewLabel = vgui.Create("DLabel", leftPnl)
    previewLabel:Dock(FILL); previewLabel:SetContentAlignment(5)
    previewLabel:SetText("预览 Text\n1234567890\n中文测试\nWeapon Name")
    previewLabel:SetFont(fontID)
    previewLabel:SetWrap(true)

    -- 右侧设置区
    local rightPnl = vgui.Create("DScrollPanel", frame)
    rightPnl:Dock(FILL)

    local entryFont, sliderSize, sliderWeight, checkAA, checkOutline, checkShadow, entryPreviewText

    -- 实时刷新函数
    local function UpdateRealtimePreview()
        local fontName = entryFont:GetValue()
        if fontName == "" then fontName = "Arial" end

        local newParams = {
            font = fontName,
            size = math.Round(sliderSize:GetValue()),
            weight = math.Round(sliderWeight:GetValue()),
            antialias = checkAA:GetChecked(),
            outline = checkOutline:GetChecked(),
            shadow = checkShadow:GetChecked(),
            extended = true
        }

        surface.CreateFont(PREVIEW_FONT_ID, newParams)
        previewLabel:SetFont(PREVIEW_FONT_ID)
        previewLabel:SetText(entryPreviewText:GetValue())
        leftPnl:InvalidateLayout()
    end

    -- 创建控件 (输入框、滑块等)
    local function AddLabel(txt) local l = vgui.Create("DLabel", rightPnl); l:SetText(txt); l:Dock(TOP); return l end
    
    AddLabel("自定义预览文字:")
    entryPreviewText = vgui.Create("DTextEntry", rightPnl); entryPreviewText:Dock(TOP); entryPreviewText:SetTall(30); entryPreviewText:SetText("预览 Text\nWeapon Name")
    entryPreviewText.OnTextChanged = UpdateRealtimePreview

    AddLabel("字体名称 (如: Microsoft YaHei):")
    entryFont = vgui.Create("DTextEntry", rightPnl); entryFont:Dock(TOP); entryFont:SetTall(30); entryFont:SetText(currentConfig.font)
    entryFont.OnValueChange = UpdateRealtimePreview

    sliderSize = vgui.Create("DNumSlider", rightPnl); sliderSize:Dock(TOP); sliderSize:SetText("大小"); sliderSize:SetMinMax(10,150); sliderSize:SetValue(currentConfig.size)
    sliderSize.OnValueChanged = UpdateRealtimePreview

    sliderWeight = vgui.Create("DNumSlider", rightPnl); sliderWeight:Dock(TOP); sliderWeight:SetText("粗细"); sliderWeight:SetMinMax(100,1000); sliderWeight:SetValue(currentConfig.weight)
    sliderWeight.OnValueChanged = UpdateRealtimePreview

    checkAA = vgui.Create("DCheckBoxLabel", rightPnl); checkAA:Dock(TOP); checkAA:SetText("抗锯齿"); checkAA:SetValue(currentConfig.antialias); checkAA.OnChange = UpdateRealtimePreview
    checkShadow = vgui.Create("DCheckBoxLabel", rightPnl); checkShadow:Dock(TOP); checkShadow:SetText("阴影"); checkShadow:SetValue(currentConfig.shadow or false); checkShadow.OnChange = UpdateRealtimePreview
    checkOutline = vgui.Create("DCheckBoxLabel", rightPnl); checkOutline:Dock(TOP); checkOutline:SetText("描边"); checkOutline:SetValue(currentConfig.outline or false); checkOutline.OnChange = UpdateRealtimePreview

    -- 保存按钮
    local btnSave = vgui.Create("DButton", frame)
    btnSave:Dock(BOTTOM); btnSave:SetTall(40); btnSave:SetText("保存并应用")
    btnSave.DoClick = function()
        local finalData = {
            font = entryFont:GetValue(),
            size = math.Round(sliderSize:GetValue()),
            weight = math.Round(sliderWeight:GetValue()),
            antialias = checkAA:GetChecked(),
            shadow = checkShadow:GetChecked(),
            outline = checkOutline:GetChecked(),
            extended = true
        }
        local allConfig = ZSFontDLC.GetConfig()
        allConfig[fontID] = finalData
        ZSFontDLC.SaveConfig(allConfig)
        surface.CreateFont(fontID, finalData)
        frame:Close()
    end
    
    UpdateRealtimePreview()
end

vgui.Register("ZSOptions", PANEL, "DPanel")

local WindowInstance = nil

-- ============================================================================
-- MakepOptions - 打开设置窗口
-- ============================================================================
function MakepOptions()
    if IsValid(WindowInstance) then
        WindowInstance:Remove()
    end

    WindowInstance = vgui.Create("ZSOptions")
    WindowInstance:SetAlpha(0)
    WindowInstance:AlphaTo(255, 0.2)
end
