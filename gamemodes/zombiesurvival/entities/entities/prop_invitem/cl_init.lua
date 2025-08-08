-- 客户端脚本标识
INC_CLIENT()

-- 包含动画文件
include("cl_animations.lua")

--[[-------------------------------------------------------------------------
    常量和预缓存资源
    将所有固定配置和资源预加载到局部变量中，以加快访问速度。
---------------------------------------------------------------------------]]
local COLOR_SCHEME = {
    TIER = {
        [1] = Color(160, 160, 160), -- 等级1: 灰色 (饰品)
        [2] = Color(255, 215, 0)   -- 等级2: 金色 (职业)
    },
    BACKGROUND = Color(20, 25, 30, 220),
    BORDER = Color(60, 70, 80, 150),
    QUALITY_STAR = Color(255, 180, 50)
}

-- 预计算和缓存常用值
local CUR_TIME = CurTime
local MATH_SIN = math.sin
local MATH_CLAMP = math.clamp
local MATH_MAX = math.max
local MATH_SQRT = math.sqrt
local STRING_REP = string.rep
local STRING_UPPER = string.upper

local COLOR_WHITE = Color(240, 240, 240)
local COLOR_BLACK_SHADOW = Color(0, 0, 0, 150)

local VEC_UP = Vector(0, 0, 25)
local VEC_OFFSET_LOW = Vector(0, 0, 50)
local VEC_OFFSET_HIGH = Vector(0, 0, 80)

-- 字体名称
local FONT_MIDDLE = "ZS2DFontHarmonyMiddle"
local FONT_NORMAL = "ZS2DFontHarmony"

--[[-------------------------------------------------------------------------
    辅助函数
---------------------------------------------------------------------------]]
-- 带阴影的文字绘制函数
function draw.TextShadow(params)
    -- 绘制阴影
    draw.SimpleText(
        params.text,
        params.font,
        params.x + 1,
        params.y + 1,
        params.shadowcolor or COLOR_BLACK_SHADOW,
        params.align,
        params.valign
    )
    -- 绘制前景文字
    draw.SimpleText(
        params.text,
        params.font,
        params.x,
        params.y,
        params.color,
        params.align,
        params.valign
    )
end


--[[-------------------------------------------------------------------------
    实体函数
---------------------------------------------------------------------------]]
-- [OPTIMIZED] 使用 Initialize 替代 Think 来进行一次性设置
function ENT:Initialize()
    -- 初始时不应绘制任何HUD
    self.ShouldDrawHUD = false
    self.ColorModulation = Color(1, 0.5, 0)

    -- 延迟调用数据更新，确保 GetInventoryItemType() 可用
    self:NextThink(CurTime())
end

-- [MOVED & REFACTORED] 将原 Think 的逻辑移至此，并进行优化
-- 这个函数只在实体初始化时或物品类型发生变化时调用一次。
function ENT:UpdateItemData()
    local itemType = self:GetInventoryItemType()
    if itemType == self.LastInvItemType then return end -- 如果类型未变，则不执行任何操作
    self.LastInvItemType = itemType

    self:RemoveModels()

    local invData = GAMEMODE.ZSInventoryItemData[itemType]
    if not invData then
        self.ShouldDrawHUD = false -- 如果没有物品数据，则不绘制HUD
        return
    end

    -- 设置模型
    local droppedEles = invData.DroppedEles
    self.ShowBaseModel = not istable(droppedEles)
    if istable(droppedEles) then
        self.WElements = table.FullCopy(droppedEles)
        self:CreateModels(self.WElements)
    end

    -- 存储显示所需的数据
    self.Name = invData.PrintName or "UNKNOWN"
    self.IsPro = invData.Pro
    self.QualityTier = invData.CanUp4 and 3 or invData.CanUp3 and 2 or invData.CanUp2 and 1 or 0
    self.PropWeapon = true

    -- [OPTIMIZED] 缓存文本和布局尺寸，避免在Draw中每帧计算
    self:CacheLayoutData()

    -- 标记此实体需要绘制HUD
    self.ShouldDrawHUD = true
    self.IsInvItemHUD = true -- 添加一个标识，方便全局钩子识别
end

-- [NEW] 新增函数：缓存布局所需的数据
function ENT:CacheLayoutData()
    local name = self.Name
    local quality = self.QualityTier
    local isPro = self.IsPro

    -- 1. 计算所有文本的尺寸
    surface.SetFont(FONT_MIDDLE)
    local title_w = surface.GetTextSize(STRING_UPPER(name))
    local title_h = 32

    surface.SetFont(FONT_NORMAL)
    local tier_text = isPro and "职业" or "饰品"
    local tier_w, tier_h = surface.GetTextSize(tier_text)
    tier_h = 28 -- 修正高度

    local star_w, star_h = 0, 0
    if quality > 0 then
        self.StarText = STRING_REP("★", MATH_CLAMP(quality, 1, 5))
        star_w, star_h = surface.GetTextSize(self.StarText)
        star_h = 28 -- 修正高度
    end

    -- 2. 计算整体布局尺寸
    local max_width = MATH_MAX(title_w, tier_w, star_w)
    self.ContentWidth = max_width + 40 -- 左右各20px留白
    
    local line_count = (quality > 0) and 3 or 2
    self.ContentHeight = (title_h + tier_h * (line_count - 1)) + (line_count * 8) -- 累加行高和间距

    -- 3. 缓存其他绘制信息
    self.TierText = tier_text
    self.TierColor = isPro and COLOR_SCHEME.TIER[2] or COLOR_SCHEME.TIER[1]
    self.TitleHeight = title_h
    self.TierHeight = tier_h
end

-- [REMOVED] ENT:Think 已被移除，其逻辑被移至 ENT:UpdateItemData 和全局钩子
-- function ENT:Think() ... end

-- [OPTIMIZED & SIMPLIFIED] Draw函数现在只负责绘制，不进行计算
function ENT:Draw()
    -- 如果不应绘制或玩家无效，则直接返回
    if not self.ShouldDrawHUD or not IsValid(LocalPlayer()) or LocalPlayer():Team() ~= TEAM_HUMANS then
        return
    end

    local ent_pos = self:GetPos()
    local dist_sqr = LocalPlayer():EyePos():DistToSqr(ent_pos)

    -- 距离剔除
    if dist_sqr > 1440000 then return end -- 1200^2

    -- 计算动态缩放和角度
    local final_scale = 0.1 * Lerp(MATH_SQRT(dist_sqr) / 1200, 1.0, 0.6)
    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(ent_pos + VEC_UP, ang, final_scale)
        -- 从 self 中直接获取缓存的宽度和高度
        local content_width = self.ContentWidth
        local content_height = self.ContentHeight
        local half_w = content_width / 2
        local half_h = content_height / 2

        -- 绘制背景和边框
        surface.SetDrawColor(COLOR_SCHEME.BACKGROUND)
        surface.DrawRect(-half_w, -half_h, content_width, content_height)
        surface.SetDrawColor(COLOR_SCHEME.BORDER)
        surface.DrawOutlinedRect(-half_w, -half_h, content_width, content_height, 2)

        -- 动态文本布局
        local current_y = -half_h + 12 -- 顶部起始Y坐标

        -- 绘制名称 (已缓存)
        draw.TextShadow({
            text = STRING_UPPER(self.Name),
            font = FONT_MIDDLE,
            x = 0, y = current_y,
            color = COLOR_WHITE,
            shadowcolor = COLOR_BLACK_SHADOW,
            align = TEXT_ALIGN_CENTER
        })
        current_y = current_y + self.TitleHeight + 8

        -- 绘制Tier等级 (已缓存)
        draw.TextShadow({
            text = self.TierText,
            font = FONT_NORMAL,
            x = 0, y = current_y,
            color = self.TierColor,
            shadowcolor = COLOR_BLACK_SHADOW,
            align = TEXT_ALIGN_CENTER
        })
        current_y = current_y + self.TierHeight + 8

        -- 绘制品质星号 (如果存在)
        if self.QualityTier > 0 then
            local star_alpha = 200 + MATH_SIN(CUR_TIME() * 3) * 55
            draw.TextShadow({
                text = self.StarText,
                font = FONT_NORMAL,
                x = 0, y = current_y,
                color = Color(255, 180, 50, star_alpha),
                shadowcolor = COLOR_BLACK_SHADOW,
                align = TEXT_ALIGN_CENTER
            })
        end

    cam.End3D2D()
end

function ENT:OnRemove()
    self:RemoveModels()
end

--[[-------------------------------------------------------------------------
    全局钩子优化
    这个钩子现在负责两件事：
    1. 触发新实体的 `UpdateItemData`。
    2. 为靠近玩家的实体更新渲染边界，以确保HUD可见。
---------------------------------------------------------------------------]]
-- [REVISED & FIXED] 修正并重构全局Think钩子
local think_entities = {}
local think_index = 1
local think_batch = 30 -- 每帧处理数量

hook.Add("Think", "WeaponHUDOptimization", function()
    local player = LocalPlayer()
    if not IsValid(player) then return end

    -- 当索引超出范围时，重新查找所有相关实体
    if think_index > #think_entities then
        think_entities = ents.FindByClass("prop_invitem")
        think_index = 1
        if #think_entities == 0 then return end -- 如果没有实体，则返回
    end
    
    local now = RealTime()
    local player_pos = player:GetPos()

    for i = 1, think_batch do
        if not think_entities[think_index] then
            -- 如果实体列表在此期间变动，重置索引
            think_index = #think_entities + 1
            break
        end

        local ent = think_entities[think_index]
        if IsValid(ent) then
            -- 如果实体是首次被处理，调用其数据更新函数
            if not ent.IsInvItemHUD then
                ent:UpdateItemData()
            end

            -- 仅为需要绘制HUD的实体更新渲染边界
            if ent.ShouldDrawHUD then
                local ent_pos = ent:GetPos()
                -- 正确的距离平方计算
                if player_pos:DistToSqr(ent_pos) < 640000 then -- 800^2
                    if ent.last_update == nil or (now - ent.last_update) > 0.1 then
                        ent:SetRenderBoundsWS(ent_pos - VEC_OFFSET_LOW, ent_pos + VEC_OFFSET_HIGH)
                        ent.last_update = now
                    end
                end
            end
        end

        think_index = think_index + 1
        -- 如果处理完所有实体，则跳出循环
        if think_index > #think_entities then break end
    end
end)