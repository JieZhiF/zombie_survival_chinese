INC_CLIENT()
include("cl_animations.lua")

ENT.ColorModulation = Color(0.15, 0.8, 1)

--[[-------------------------------------------------------------------------
    配置参数
    将所有可调整的参数集中在此处，方便管理。
---------------------------------------------------------------------------]]
local CONFIG = {
    -- 距离和缩放
    MAX_DISTANCE = 800,          -- 最大显示距离（单位）
    FADE_START_DISTANCE = 600,   -- 开始淡出的距离
    MIN_SCALE = 0.06,            -- 最小缩放比例 (在最远距离时)
    MAX_SCALE = 0.1,             -- 最大缩放比例 (在最近距离时)

    -- 字体
    FONT_TITLE = "ZS2DFontHarmonyMiddle",
    FONT_SUBTITLE = "ZS2DFontHarmony",

    -- UI布局
    PADDING = 20,                -- 内容与边框的间距
    TITLE_OFFSET_Y = -40,        -- 标题Y轴偏移
    TIER_OFFSET_Y = -5,          -- 等级Y轴偏移
    STARS_OFFSET_Y = 30,         -- 星级Y轴偏移
    STARS_HEIGHT = 30,           -- 星级区域的高度
    BASE_HEIGHT = 100,           -- UI基础高度
    BORDER_THICKNESS = 2,        -- 边框粗细
    Z_OFFSET = 25                -- 3D2D界面在实体上的高度偏移
}

--[[-------------------------------------------------------------------------
    预计算和颜色定义 (全局常量)
    这些值在脚本加载时计算一次，无需在运行时重复计算。
---------------------------------------------------------------------------]]
local MAX_DIST_SQR = CONFIG.MAX_DISTANCE * CONFIG.MAX_DISTANCE
local FADE_DIST_RANGE = CONFIG.MAX_DISTANCE - CONFIG.FADE_START_DISTANCE

local COLOR_SCHEME = {
    TIER = {
        [1] = Color(160, 160, 160), -- 灰
        [2] = Color(80, 200, 120),  -- 绿
        [3] = Color(80, 160, 255),  -- 蓝
        [4] = Color(170, 110, 255), -- 紫
        [5] = Color(255, 200, 50)   -- 金
    },
    BACKGROUND = Color(20, 25, 30, 220),
    BORDER = Color(60, 70, 80, 150),
    QUALITY_STAR = Color(255, 180, 50),
    TEXT = color_white
}
 
--[[-------------------------------------------------------------------------
    Think: 当武器类型改变时更新实体属性和缓存UI数据
---------------------------------------------------------------------------]]
function ENT:Think()
    local class = self:GetWeaponType()
    if class == self.LastWeaponType then return end -- 如果类型未变，则无需执行任何操作

    self.LastWeaponType = class
    self:RemoveModels()

    local weptab = weapons.Get(class)
    if not weptab then return end

    -- 1. 更新武器基础属性
    self.ShowBaseModel = weptab.ShowWorldModel == nil or weptab.ShowWorldModel
    if weptab.Base == "weapon_zs_basefood" then
        self.IsFood = true
        self.ShowBaseModel = true 
    end
    if weptab.WElements then
        self.WElements = table.FullCopy(weptab.WElements)
        self:CreateModels(self.WElements)
    end

    self.ColorModulation = weptab.DroppedColorModulation or self.ColorModulation
    self.PropWeapon = true

    -- 2. 更新用于UI的数据
    self.Name = weptab.PrintName or "UNKNOWN"
    self.Tier = weptab.Tier or 1
    self.QualityTier = weptab.QualityTier

    -- 3. 【性能优化】缓存UI尺寸和文本
    --    这些内容仅在武器切换时变化，因此在这里预先计算，避免在Draw中每帧计算。
    self.HasQuality = self.QualityTier and self.QualityTier > 0
    self.StarText = self.HasQuality and string.rep("★", math.Clamp(self.QualityTier, 1, 5)) or ""

    surface.SetFont(CONFIG.FONT_TITLE)
    local title_w = surface.GetTextSize(self.Name)

    surface.SetFont(CONFIG.FONT_SUBTITLE)
    local tier_w = surface.GetTextSize("TIER " .. self.Tier)
    local star_w = self.HasQuality and surface.GetTextSize(self.StarText) or 0

    -- 缓存计算出的宽度和高度
    self.ContentWidth = math.max(title_w, tier_w, star_w) + CONFIG.PADDING * 2
    self.ContentHeight = CONFIG.BASE_HEIGHT + (self.HasQuality and CONFIG.STARS_HEIGHT or 0)
end

--[[-------------------------------------------------------------------------
    Draw: 每帧渲染实体和3D2D UI
---------------------------------------------------------------------------]]
function ENT:Draw()
    -- 绘制基础模型
    if self.ShowBaseModel then
        self:DrawModel()
    end

    -- 如果没有有效名称（例如，在Think完成之前），则不绘制UI
    if not self.Name then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or ply:Team() ~= TEAM_HUMAN then return end

    -- 1. 【性能优化】距离计算
    --    直接使用预计算的平方距离进行比较，避免每帧都计算平方。
    local eye_pos = EyePos()
    local ent_pos = self:GetPos()
    local dist_sqr = eye_pos:DistToSqr(ent_pos)

    if dist_sqr > MAX_DIST_SQR then return end

    -- 2. 动态效果计算 (透明度和缩放)
    local dist = math.sqrt(dist_sqr) -- 仅在需要线性插值时才开方
    local alpha_multiplier = 1
    if dist > CONFIG.FADE_START_DISTANCE then
        -- 使用预计算的FADE_DIST_RANGE，避免减法运算
        alpha_multiplier = 1 - (dist - CONFIG.FADE_START_DISTANCE) / FADE_DIST_RANGE
    end
    
    -- 使用Lerp函数更清晰地表达意图
    local scale = Lerp(dist / CONFIG.MAX_DISTANCE, CONFIG.MAX_SCALE, CONFIG.MIN_SCALE)
    local final_scale = math.Clamp(scale, CONFIG.MIN_SCALE, CONFIG.MAX_SCALE)

    -- 3. 颜色计算
    --    将Alpha值应用到基础颜色上
    local text_alpha = alpha_multiplier * 255
    local bg_color = ColorAlpha(COLOR_SCHEME.BACKGROUND, alpha_multiplier * COLOR_SCHEME.BACKGROUND.a)
    local border_color = ColorAlpha(COLOR_SCHEME.BORDER, alpha_multiplier * COLOR_SCHEME.BORDER.a)
    local text_color = ColorAlpha(COLOR_SCHEME.TEXT, text_alpha)
    local tier_color = ColorAlpha(COLOR_SCHEME.TIER[self.Tier] or COLOR_SCHEME.TIER[1], text_alpha)
    local star_color = ColorAlpha(COLOR_SCHEME.QUALITY_STAR, text_alpha)
    local text = "TIER"
    -- 4. 3D2D 绘制
    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    cam.Start3D2D(ent_pos + Vector(0, 0, CONFIG.Z_OFFSET), ang, final_scale)
        -- 【性能优化】使用在Think中缓存的尺寸
        local half_w = self.ContentWidth / 2
        
        -- 背景和边框
        draw.RoundedBox(0, -half_w, -50, self.ContentWidth, self.ContentHeight, bg_color)
        surface.SetDrawColor(border_color)
        surface.DrawOutlinedRect(-half_w, -50, self.ContentWidth, self.ContentHeight, CONFIG.BORDER_THICKNESS)

        -- 文本绘制 (使用CONFIG中的参数进行布局)
        draw.SimpleText(
            string.upper(self.Name),
            CONFIG.FONT_TITLE,
            0,
            CONFIG.TITLE_OFFSET_Y,
            text_color,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP
        )
        if self.IsFood then
            draw.SimpleText(
                "食物",
                CONFIG.FONT_SUBTITLE,
                0,
                CONFIG.TIER_OFFSET_Y,
                tier_color,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_TOP
            )
        else
            draw.SimpleText(
                text .. self.Tier,
                CONFIG.FONT_SUBTITLE,
                0,
                CONFIG.TIER_OFFSET_Y,
                tier_color,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_TOP
            )
        end
        -- 仅在有品质时绘制星号
        if self.HasQuality then
            draw.SimpleText(
                self.StarText,
                CONFIG.FONT_SUBTITLE,
                0,
                CONFIG.STARS_OFFSET_Y,
                star_color,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_TOP
            )
        end
    cam.End3D2D()
end