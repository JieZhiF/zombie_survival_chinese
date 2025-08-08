--[[
    优化说明:
    1.  数据驱动:
        - 所有UI选项都被移至 `PANEL:PopulateOptionsData()` 中的 `self.OptionsData` 表。
        - 若要添加新选项，只需在此表中添加一行数据，无需修改UI创建逻辑。
        - 这极大地简化了 `UpdateContent` 函数，消除了巨大的 if/elseif 结构。

    2.  代码复用:
        - 创建了 `AddCheckbox`, `AddSlider`, `AddColorMixer`, `AddComboBox` 等辅助函数。
        - 这些函数封装了创建和配置VGUI控件的重复代码，使主逻辑更简洁。

    3.  UI/UX 改进:
        - 使用了更柔和的背景色和圆角矩形 (`draw.RoundedBox`)。
        - 左侧分类列表有了更清晰的选中和悬停效果 (左侧蓝色指示条)。
        - 控件之间有统一的间距和边距，布局更整洁。
        - 将颜色、字体等常量集中定义，方便全局调整。

    4.  结构清晰:
        - `PANEL:Init` 函数现在只负责调用各个初始化函数，逻辑一目了然。
        - UI创建被分解为 `CreateCategoryList` 和 `CreateContentPanel` 等部分。
]]

local PANEL = {}

-- 定义常量以便于统一修改样式
local COLOR_BG = Color(45, 45, 55, 240)
local COLOR_BG_INNER = Color(35, 35, 45, 220)
local COLOR_ACCENT = Color(40, 155, 255)
local COLOR_TEXT = Color(248, 248, 248, 240)
local FONT_CATEGORY = "ZS2DFontHarmony" //分类标签的字体
local FONT_LABEL = "ZS2DFontHarmonySmall"
local FONT_LABEL_SMALL = "DermaDefaultSmall"
function PANEL:Init()
    -- 1. 基本框架设置
    local scale = BetterScreenScale and BetterScreenScale() or 1
    self:SetSize(ScrW() * 0.45 * scale, ScrH() * 0.6 * scale)
    self:Center()
    self:SetTitle("")
    self:MakePopup()
    self:SetDraggable(true)
    --self:SetAlpha(0)

    -- 填充所有选项数据
    self:PopulateOptionsData()

    -- 2. 创建UI布局
    self:CreateLayout()
    --self:AlphaTo(255,1)
    -- 3. 默认加载第一个分类
    local initialCategory = self.CategoryData[1]
    if initialCategory then
        self:UpdateContent(initialCategory.name)
        -- 让第一个按钮被默认选中
        if IsValid(self.CategoryList) and #self.CategoryList:GetChildren() > 0 then
            self.CategoryList:GetChildren()[1]:SetSelected(true)
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, COLOR_BG)
end


function PANEL:CreateLayout()
    self:CreateCategoryList()
    self.ContentPanel = vgui.Create("DPanel", self)
    self.ContentPanel:Dock(FILL)
    self.ContentPanel.Paint = function(pnl, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, COLOR_BG_INNER, false, true, false, true)
    end
end

function PANEL:PopulateOptionsData()
    self.CategoryData = {
        {name = "HUD", text = translate.Get("Category_HUD")},
        {name = "Environment", text = translate.Get("Category_Environment")},
        {name = "Crosshair", text = translate.Get("Category_Crosshair")},
        {name = "Color", text = translate.Get("Category_Color")},
        {name = "Effect", text = translate.Get("Category_Effect")},
        {name = "Other", text = translate.Get("Category_Other")},
    }

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
            { type = "slider", label = "Option_TransparencyRadius", convar = "zs_transparencyradius", min = 0, max = 2048, decimals = 0 },
            { type = "slider", label = "Option_ThirdPersonTransparencyRadius", convar = "zs_transparencyradius3p", min = 0, max = 2048, decimals = 0 },
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
        },
        Crosshair = {
            { type = "checkbox", label = "Option_DrawCrosshairOnAim", convar = "zs_ironsightscrosshair" },
            { type = "checkbox", label = "Option_DisableCrosshairRotate", convar = "zs_nocrosshairrotate" },
            { type = "checkbox", label = "Option_Usecirclecrosshair", convar = "zs_crosshair_cicrle" },
            { type = "slider", label = "Option_CrosshairLineCount", convar = "zs_crosshairlines", min = 2, max = 8, decimals = 0 },
            { type = "slider", label = "Option_CrosshairAngleOffset", convar = "zs_crosshairoffset", min = 0, max = 90, decimals = 0 },
            { type = "slider", label = "Option_CrosshairThickness", convar = "zs_crosshairthickness", min = 0.5, max = 2, decimals = 1 },
            { type = "color", label = "Option_CrosshairColor", r = "zs_crosshair_colr", g = "zs_crosshair_colg", b = "zs_crosshair_colb", a = "zs_crosshair_cola" },
            { type = "color", label = "Option_CrosshairAuxiliaryColor", r = "zs_crosshair_colr2", g = "zs_crosshair_colg2", b = "zs_crosshair_colb2", a = "zs_crosshair_cola2" },
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
            { type = "checkbox", label = "Option_ShowFog", convar = "fog_override" },
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
        }
    }
end
 local math_sin = math.sin
function PANEL:CreateCategoryList()
    local w, h = self:GetSize()
    local category_width = math.min(200, w * 0.25)

    self.CategoryList = vgui.Create("DScrollPanel", self)
    self.CategoryList:SetWide(category_width)
    self.CategoryList:Dock(LEFT)
    self.CategoryList:DockMargin(8, 8, 4, 8)
    
    -- *** FIX 1: 保存主面板的引用 ***
    local rootPanel = self

    for i, cat in ipairs(self.CategoryData) do
        local btn = vgui.Create("DButton", self.CategoryList)
        btn:SetText(cat.text)
        btn:SetTextColor(COLOR_TEXT)
        btn:SetFont(FONT_CATEGORY)
        btn:SetContentAlignment(5)
        btn:Dock(TOP)
        btn:SetTall(75)
        btn:DockMargin(0, 0, 0, 4)
        btn.categoryName = cat.name
        btn.isSelected = false

        -- 新增：动画属性 --
        btn.animStartTime = 0  -- 动画开始的时间
        btn.animDuration = 0.2 -- 动画持续时间（秒）

        function btn:SetSelected(b)
            -- 仅当选择状态实际改变时才执行，避免重复触发
            if self.isSelected ~= b then
                self.isSelected = b

                -- 如果按钮被选中，记录当前时间以启动动画
                if b then
                    self.animStartTime = CurTime()
                end
            end
        end

        -- 重写：Paint 函数以实现动画效果 --
        function btn:Paint(w, h)
            local bgColor = COLOR_BG -- 默认背景颜色
            local hovercolor = COLOR_ACCENT
            if self.isSelected then
                -- 如果按钮被选中，则执行渐变动画
                -- 1. 计算动画进度（一个从 0.0 到 1.0 的值）
                local progress = math.Clamp((CurTime() - self.animStartTime) / self.animDuration, 0, 1)

                -- 2. 使用 Lerp 函数根据进度计算当前的透明度
                --    这里我们让透明度从 40 渐变到 255，实现从浅到深的效果
                local animatedAlpha = Lerp(progress, 40, 240)
                
                -- 3. 将带有动画透明度的颜色作为背景色
                bgColor = ColorAlpha(COLOR_ACCENT, animatedAlpha)
            elseif self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, hovercolor)
            end
            -- 绘制最终的背景
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
        end

        function btn:DoClick()
            for _, child in ipairs(self:GetParent():GetChildren()) do
                if child.SetSelected and child != self then
                    child:SetSelected(false)
                end
            end
            self:SetSelected(true)
            
            -- *** FIX 1: 使用保存的引用来调用 UpdateContent ***
            rootPanel:UpdateContent(self.categoryName)
            
            surface.PlaySound("ui/buttonclick.wav")
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
-- 辅助函数 (用于创建UI控件，避免代码重复)
---------------------------------------------------------------------------
function PANEL:AddCheckbox(parent, data)
    -- 1. 创建容器 DPanel, 它将作为我们布局的上下文
    local container = vgui.Create("DPanel", parent)
    container:SetTall(30) -- 设置整行的高度
    container:SetPaintBackground(false) -- 关闭容器自身的背景绘制

    -- 2. 创建 DCheckBox (开关)
    local checkbox = vgui.Create("DCheckBox", container)
    checkbox:SetSize(70, 29) -- 首先定义好开关本身的大小
    checkbox:Dock(LEFT) -- 【核心】让开关停靠在容器的左侧
    -- 设置停靠边距: 在开关的右侧留出 8px 的间隙
    -- 参数顺序: 上, 右, 下, 左
    checkbox:DockMargin(0, 0,12, 0)
    checkbox:SetConVar(data.convar)

    checkbox.Paint = function (self,w,h)
        -- 根据轨道高度动态计算旋钮大小和边距
        local padding = math.max(1, math.floor(h * 0.1)) -- 10% 的内边距
        local knobSize = h - (padding * 2)
        -- 计算Y轴位置
        local trackY = 0 -- 轨道从顶部开始
        local knobY = padding
        local bgColor, knobColor, knobX
        if (checkbox:GetChecked()) then
            -- "On" 状态
            bgColor = Color(255, 255, 255, 200)
            knobColor = Color(50, 50, 50, 255)
            -- 将旋钮定位到右侧
            knobX = w - knobSize - padding
        else
            -- "Off" 状态
            bgColor = Color(50, 50, 50, 200)
            knobColor = Color(255, 255, 255, 255)
            -- 将旋钮定位到左侧
            knobX = padding
        end
        if (checkbox.Hovered) then
            bgColor.r = math.min(255, bgColor.r + 20)
            bgColor.g = math.min(255, bgColor.g + 20)
            bgColor.b = math.min(255, bgColor.b + 20)
        end
        
        -- 绘制背景
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, trackY, w, h)
        
        -- 绘制旋钮
        surface.SetDrawColor(knobColor)
        surface.DrawRect(knobX, knobY, knobSize, knobSize)
    end
    -- 3. 创建 DLabel (文字标签)
    local label = vgui.Create("DLabel", container)
    label:Dock(FILL) -- 【核心】让标签填充容器中所有剩余的空间！
    label:SetMouseInputEnabled(true)
    label:SetFont(FONT_LABEL)
    label:SetText(translate.Get(data.label) or data.label)
    label:SetTextColor(COLOR_TEXT)

    -- 让文字在标签自己的区域内垂直居中
    label:SetContentAlignment(4)
    
    -- 4. (可选但推荐) 让点击标签也能触发开关
    label.DoClick = function()
        checkbox:SetValue(not checkbox:GetValue())
        checkbox:OnChange()
    end
    
    -- 将我们精心布局好的容器添加到列表中
    parent:AddItem(container)
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
    
    -- *** FIX 2: 将 NumDisplay 修改为正确的 NumEntry ***
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

vgui.Register("ZSOptions", PANEL, "DFrame")

local WindowInstance = nil
function MakepOptions()
    if IsValid(WindowInstance) then
        WindowInstance:Remove()
    end

    WindowInstance = vgui.Create("ZSOptions")
    WindowInstance:SetAlpha(0)
    WindowInstance:AlphaTo(255, 0.2)

end