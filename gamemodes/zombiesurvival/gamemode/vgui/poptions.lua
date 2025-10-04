-- 将基础控件从 DFrame 更换为 DPanel
local PANEL = {}

-- 定义常量以便于统一修改样式
local COLOR_BG = Color(45, 45, 55, 240)
local COLOR_BG_INNER = Color(35, 35, 45, 220)
local COLOR_ACCENT = Color(40, 155, 255)
local COLOR_TEXT = Color(248, 248, 248, 240)
local FONT_TOP_CATEGORY = "ZS2DFontHarmony" --顶部大类标签的字体
local FONT_SUB_CATEGORY = "ZS2DFontHarmony" --左侧次一级分类标签的字体
local FONT_LABEL = "ZS2DFontHarmonySmall"
local FONT_LABEL_SMALL = "DermaDefaultSmall"

function PANEL:Init()
    -- 1. 基本框架设置
    local scale = BetterScreenScale and BetterScreenScale() or 1
    self:SetSize(ScrW() * 0.45 * scale, ScrH() * 0.55 * scale)
    self:Center()
    self:MakePopup()

    -- DPanel 没有这些 DFrame 的函数，所以移除它们
    -- self:SetTitle("")
    -- self:ShowCloseButton(false)
    -- self:SetDraggable(true)

    -- 填充所有选项数据
    self:PopulateOptionsData()

    -- 2. 创建UI布局
    self:CreateLayout()
    -- 3. 创建自定义关闭按钮 (在布局创建后，确保它在顶层)
    self:CreateCloseButton()

    if not IsValid(self) or not IsValid(self.TopCategoryBar) then return end
    -- 查找第一个DButton并模拟点击，不播放声音
    for _, child in ipairs(self.TopCategoryBar:GetChildren()) do
        if IsValid(child) and isfunction(child.DoClick) then
            child:DoClick(false) -- 传递 false 来静音
            break -- 找到并点击第一个后就退出循环
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
end

function PANEL:CreateLayout()
    -- 1. 创建顶部主分类栏
    self:CreateTopCategoryBar()

    -- 2. 创建一个主内容容器，位于顶部栏下方
    local mainArea = vgui.Create("DPanel", self)
    mainArea:Dock(FILL)
    mainArea:DockMargin(0, 8, 0, 0) -- 与顶部分割线留出间距
    mainArea.Paint = function() end -- 透明背景

    -- 3. 创建左侧的次级分类列表
    local sub_category_width = self:GetWide() * 0.15
    self.SubCategoryList = vgui.Create("DScrollPanel", mainArea)
    self.SubCategoryList:SetWide(sub_category_width)
    self.SubCategoryList:Dock(LEFT)
    self.SubCategoryList:DockMargin(8, 0, 4, 8)

    -- 4. 创建右侧的内容面板
    self.ContentPanel = vgui.Create("DPanel", mainArea)
    self.ContentPanel:Dock(FILL)
    self.ContentPanel:DockMargin(4, 0, 8, 8)
    self.ContentPanel.Paint = function(pnl, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLOR_BG_INNER)
    end
end

function PANEL:CreateCloseButton()
    local closeBtn = vgui.Create("DButton", self)
    closeBtn:SetSize(50, 50)
    closeBtn:SetPos(self:GetWide() - 75, 0)
    closeBtn:SetZPos(1) -- 确保按钮在顶部类别栏之上
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

function PANEL:PopulateOptionsData()
    -- 大类和次一级的结构定义
    self.SettingsData = {
        { name = "Interface", text = "界面和HUD", subCategories = {
            {name = "HUD", text = translate.Get("Category_HUD")},
            {name = "Crosshair", text = translate.Get("Category_Crosshair")},
            {name = "Color", text = translate.Get("Category_Color")},
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

    -- 具体的设置项
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
            --{ type = "slider", label = "Option_wepslot_trinkets", convar = "zs_wepslot_trinkets",min = 0, max = 6, decimals = 0 },
            --{ type = "slider", label = "Option_wepslot_flasks", convar = "zs_wepslot_flasks",min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_deployables", convar = "zs_wepslot_deployables", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_misctools", convar = "zs_wepslot_misctools", min = 0, max = 6, decimals = 0 },
          --  { type = "slider", label = "Option_wepslot_conoffensive", convar = "zs_wepslot_conoffensive" },
            { type = "slider", label = "Option_wepslot_explosives", convar = "zs_wepslot_explosives", min = 0, max = 6, decimals = 0 },
            { type = "slider", label = "Option_wepslot_food", convar = "zs_wepslot_food", min = 0, max = 6, decimals = 0 },
            --{ type = "slider", label = "Option_wepslot_potions", convar = "zs_wepslot_potions", min = 0, max = 6, decimals = 0 },
            --{ type = "slider", label = "Option_wepslot_consupportive", convar = "zs_wepslot_consupportive",min = 0, max = 6, decimals = 0 },
        }
    }
end

function PANEL:CreateTopCategoryBar()
    self.TopCategoryBar = vgui.Create("DPanel", self)
    self.TopCategoryBar:Dock(TOP)
    self.TopCategoryBar:SetTall(50)
    self.TopCategoryBar:DockMargin(0, 0, 0, 0)

    --[[-------------------------------------------------------------------------
        新增: 为顶部大类栏添加拖拽功能
    ---------------------------------------------------------------------------]]
    self.TopCategoryBar.m_bDragging = false
    self.TopCategoryBar.m_DragStart = {}
    self.TopCategoryBar.OnMousePressed = function( pnl, mcode )
        if mcode == MOUSE_LEFT then
            pnl.m_bDragging = true
            -- self 指向的是 PANEL, 即我们的主窗口
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
            -- 检查鼠标左键是否仍然被按下
            if input.IsMouseDown( MOUSE_LEFT ) then
                self:SetPos( gui.MouseX() - pnl.m_DragStart[1], gui.MouseY() - pnl.m_DragStart[2] )
            else
                -- 如果鼠标被释放了（例如在窗口外），则停止拖动
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
            -- 自动点击第一个子分类
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
        end
    end
end
---------------------------------------------------------------------------
-- 辅助函数 (创建UI控件) - 新的简约高级感样式
---------------------------------------------------------------------------
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

-- 确保这里使用的是 DPanel
vgui.Register("ZSOptions", PANEL, "DPanel")

local WindowInstance = nil
function MakepOptions()
    if IsValid(WindowInstance) then
        WindowInstance:Remove()
    end

    WindowInstance = vgui.Create("ZSOptions")
    WindowInstance:SetAlpha(0)
    WindowInstance:AlphaTo(255, 0.2)
end