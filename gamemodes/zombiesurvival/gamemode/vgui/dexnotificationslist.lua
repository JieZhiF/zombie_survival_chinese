-- 放在你 NotifyFadeTime 附近
GM.NotifyFadeTime = 4
--========================
-- 叠加计数版 DEXNotification
--========================

-- 这两个字体变量沿用你前面定义的 DefaultFont / DefaultFontEntity
-- 若为空会回退到默认字体
local DefaultFont = "ZSHUDFontSmallest"
local DefaultFontEntity = "ZSHUDFontSmallest"


local COUNT_FONT  = DefaultFont or "DermaDefaultBold"
-- ========================
-- DEXNotification (manual layout, independent count label)
-- ========================
--========================
-- 叠加计数（不延长淡出）版 DEXNotification
--========================
local COUNT_COLOR = Color(255, 210, 64)   -- 计数颜色（与正文区分）
local COUNT_FONT  = DefaultFont or "DermaDefaultBold"

local PANEL = {}

function PANEL:Init()
    self:DockPadding(8, 2, 8, 2)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)

    self.StackCount   = 1          -- 当前叠加计数
    self._rawtext     = ""         -- 用于判定同一消息的键
    self._countLabel  = nil        -- 计数独立标签（不 Dock）
    self.OrigDieTime  = nil        -- 初始淡出时间点（不随叠加改变）
end

local matGrad = Material("VGUI/gradient-r")
function PANEL:Paint()
    surface.SetMaterial(matGrad)
    surface.SetDrawColor(0, 0, 0, 180)

    local align = self:GetParent():GetAlign()
    if align == RIGHT then
        surface.DrawTexturedRect(self:GetWide() * 0.25, 0, self:GetWide(), self:GetTall())
    elseif align == CENTER then
        surface.DrawTexturedRect(self:GetWide() * 0.25, 0, self:GetWide() * 0.25, self:GetTall())
        surface.DrawTexturedRectRotated(self:GetWide() * 0.625, self:GetTall() / 2, self:GetWide() * 0.25, self:GetTall(), 180)
    else
        surface.DrawTexturedRectRotated(self:GetWide() * 0.25, self:GetTall() / 2, self:GetWide() / 2, self:GetTall(), 180)
    end
end

--=== 计数相关（独立标签 + 非 Dock 摆放） ===--
function PANEL:EnsureCountLabel()
    if IsValid(self._countLabel) then return self._countLabel end
    local lbl = vgui.Create("DLabel", self)
    lbl:SetFont(COUNT_FONT)
    lbl:SetTextColor(COUNT_COLOR)
    lbl:SetText("")          -- 初始隐藏
    lbl:SetVisible(false)
    lbl:SetMouseInputEnabled(false)
    lbl:SetKeyboardInputEnabled(false)
    self._countLabel = lbl
    return lbl
end

function PANEL:SetStackCount(n)
    self.StackCount = math.max(1, tonumber(n) or 1)
    local lbl = self:EnsureCountLabel()
    if self.StackCount > 1 then
        lbl:SetText(" x" .. self.StackCount)
        lbl:SizeToContents()
        lbl:SetVisible(true)
        self:InvalidateLayout(true) -- 触发布局来重新摆放计数
    else
        lbl:SetText("")
        lbl:SetVisible(false)
    end
end

-- 非 Dock 的手动定位：把计数摆在当前内容最右边 +4 像素处
function PANEL:PositionCountLabel()
    if not IsValid(self._countLabel) or not self._countLabel:IsVisible() then return end
    local maxRight = 0
    for _, p in ipairs(self:GetChildren()) do
        if p ~= self._countLabel and IsValid(p) then
            local x, _ = p:GetPos()
            maxRight = math.max(maxRight, x + p:GetWide())
        end
    end
    local cx = maxRight + 4
    local cy = (self:GetTall() - self._countLabel:GetTall()) / 2
    self._countLabel:SetPos(cx, cy)
    self._countLabel:MoveToFront()
end

function PANEL:PerformLayout(w, h)
    self:PositionCountLabel()
end

--=== 构建内容，同时积累 _rawtext 作为“相同消息”的匹配键 ===--
function PANEL:AddLabel(text, col, font, extramargin)
    local label = vgui.Create("DLabel", self)
    label:SetText(text)
    label:SetFont(font or DefaultFont)
    label:SetTextColor(col or color_white)
    label:SizeToContents()
    if extramargin then
        label:SetContentAlignment(7)
        label:DockMargin(0, label:GetTall() * 0.2, 0, 0)
    else
        label:SetContentAlignment(4)
    end
    label:Dock(LEFT)
    self._rawtext = (self._rawtext or "") .. tostring(text or "")
end

function PANEL:AddImage(mat, col)
    local img = vgui.Create("DImage", self)
    img:SetImage(mat)
    if col then img:SetImageColor(col) end
    img:SizeToContents()
    local height = img:GetTall()
    if height > self:GetTall() then
        img:SetSize(self:GetTall() / height * img:GetWide(), self:GetTall())
    end
    img:DockMargin(0, (self:GetTall() - img:GetTall()) / 2, 0, 0)
    img:Dock(LEFT)
    self._rawtext = (self._rawtext or "") .. "[img]"
end

function PANEL:AddKillIcon(class)
    local icondata = killicon.GetIcon(class)
    if icondata then
        self:AddImage(icondata[1], icondata[2])
    else
        local fontdata = killicon.GetFont(class) or killicon.GetFont("default")
        if fontdata then
            self:AddLabel(fontdata[2], fontdata[3], fontdata[1], true)
        end
    end
    self._rawtext = (self._rawtext or "") .. "[kill:" .. tostring(class) .. "]"
end

function PANEL:SetNotification(...)
    local args = {...}

    local defaultcol = color_white
    local defaultfont
    for _, v in ipairs(args) do
        local vtype = type(v)
        if vtype == "table" then
            if v.r and v.g and v.b then
                defaultcol = v
            elseif v.font then
                if v.font == "" then
                    defaultfont = nil
                else
                    local th = draw.GetFontHeight(v.font)
                    if th then defaultfont = v.font end
                end
            elseif v.killicon then
                self:AddKillIcon(v.killicon)
                if v.headshot then
                    self:AddKillIcon("headshot")
                end
            elseif v.image then
                self:AddImage(v.image, v.color)
            end
        elseif vtype == "Player" then
            local avatar = vgui.Create("AvatarImage", self)
            local size = self:GetTall() >= 32 and 32 or 16
            avatar:SetSize(size, size)
            if v:IsValid() then avatar:SetPlayer(v, size) end
            avatar:SetAlpha(220)
            avatar:Dock(LEFT)
            avatar:DockMargin(0, (self:GetTall() - avatar:GetTall()) / 2, 0, 0)

            if v:IsValid() then
                self:AddLabel(" "..v:Name(), team.GetColor(v:Team()), DefaultFontEntity)
                self._rawtext = (self._rawtext or "") .. " "..v:Name()
            else
                self:AddLabel(" ?", team.GetColor(TEAM_UNASSIGNED), DefaultFontEntity)
                self._rawtext = (self._rawtext or "") .. " ?"
            end
        elseif vtype == "Entity" then
            self:AddLabel("["..(v:IsValid() and v:GetClass() or "?").."]", COLOR_RED, DefaultFontEntity)
            self._rawtext = (self._rawtext or "") .. "["..(v:IsValid() and v:GetClass() or "?").."]"
        else
            local text = tostring(v)
            self:AddLabel(text, defaultcol, defaultfont)
            self._rawtext = (self._rawtext or "") .. text
        end
    end

    -- 初始化计数标签（独立显示，默认隐藏）
    self:SetStackCount(1)
end

function PANEL:GetKey()
    return string.Trim(string.lower(self._rawtext or ""))
end

-- 把原来的 IncrementStackNoExtend 替换为下面这个
function PANEL:IncrementStackResetTime()
    -- 增加计数
    self:SetStackCount((self.StackCount or 1) + 1)

    -- 视觉/动画：停止旧动画并立即满显，随后基于新的 FadeTime 重新开始淡出（重置时间）
    self:Stop()
    local now = CurTime()
    local fade = self.FadeTime or GAMEMODE.NotifyFadeTime or 8

    -- 重置淡出时间点（关键：这里会延长/重置到现在起 fade 秒后）
    self.OrigDieTime = now + fade
    self.DieTime = self.OrigDieTime

    -- 立即可视化反馈
    self:SetAlpha(255)

    -- 保持与初次相同的动画行为：最后 1 秒做淡出，前面保留显示
    local fadeHold = math.max(0, fade - 1)
    local fadeDur  = math.min(1, fade)
    self:AlphaTo(1, fadeDur, fadeHold)
end


-- 根据内容总宽重新调整 DockPadding，保证右/中对齐在计数增长后仍然对齐
function PANEL:RecalcPaddingFor(listPanel)
    if not IsValid(listPanel) then return end
    local align = listPanel:GetAlign()
    local total = 0
    for _, p in ipairs(self:GetChildren()) do
        if IsValid(p) then total = total + p:GetWide() end
    end
    if align == RIGHT then
        local leftpad = math.max(8, listPanel:GetWide() - total - 32)
        self:DockPadding(leftpad, 0, 8, 0)
    elseif align == CENTER then
        local leftpad = math.max(0, (listPanel:GetWide() - total) / 2)
        self:DockPadding(leftpad, 0, 0, 0)
    else
        self:DockPadding(8, 0, 8, 0)
    end
end

vgui.Register("DEXNotification", PANEL, "Panel")

--========================
-- 列表：相同消息叠加但不延长淡出
--========================
local PANEL = {}

AccessorFunc(PANEL, "m_Align", "Align", FORCE_NUMBER)
AccessorFunc(PANEL, "m_MessageHeight", "MessageHeight", FORCE_NUMBER)

function PANEL:Init()
    self:SetAlign(LEFT)
    self:SetMessageHeight(32)
    self:ParentToHUD()
    self:InvalidateLayout()
end

function PANEL:PerformLayout()
    for _, pan in ipairs(self:GetChildren()) do
        if IsValid(pan) and pan.RecalcPaddingFor then
            pan:RecalcPaddingFor(self)
        end
    end
end

function PANEL:Paint() end

local function BuildKeyFromArgs(args)
    local parts = {}
    for _, v in ipairs(args) do
        local t = type(v)
        if t == "string" or t == "number" or t == "boolean" then
            table.insert(parts, tostring(v))
        elseif t == "table" then
            if v.killicon then
                table.insert(parts, "[kill:"..tostring(v.killicon).."]")
            elseif v.image then
                table.insert(parts, "[img]")
            elseif v.font then
                table.insert(parts, "[f:"..tostring(v.font).."]")
            end
        elseif t == "Player" then
            table.insert(parts, " "..(IsValid(v) and v:Name() or "?"))
        elseif t == "Entity" then
            table.insert(parts, "["..(IsValid(v) and v:GetClass() or "?").."]")
        end
    end
    return string.Trim(string.lower(table.concat(parts)))
end

function PANEL:AddNotification(...)
    local args = {...}
    local FadeTime = GAMEMODE.NotifyFadeTime

    -- 自定义时间判断修正
    for _, v in ipairs(args) do
        if istable(v) and v.CustomTime and isnumber(v.CustomTime) then
            FadeTime = v.CustomTime
            break
        end
    end

    -- 尝试叠加
    local wantedKey = BuildKeyFromArgs(args)
    for _, child in ipairs(self:GetChildren()) do
        if IsValid(child) and child.GetKey and child:GetKey() == wantedKey then
            -- 改回：叠加时**重置**淡出时间
            child:IncrementStackResetTime()
            child:RecalcPaddingFor(self)
            return child
        end
    end

    -- 新建分支里，记录 FadeTime
    local notif = vgui.Create("DEXNotification", self)
    notif:SetTall(BetterScreenScale() * self:GetMessageHeight())
    notif:SetNotification(...)
    notif._rawtext = wantedKey ~= "" and wantedKey or (notif._rawtext or "")

    -- 保存 fade 时间以便以后叠加时重置
    notif.FadeTime = FadeTime

    notif:RecalcPaddingFor(self)
    notif:Dock(TOP)

    -- 入场 + 首次淡出时间（记录 OrigDieTime）
    notif:SetAlpha(1)
    notif:AlphaTo(255, 0.15)
    notif.OrigDieTime = CurTime() + FadeTime
    notif.DieTime     = notif.OrigDieTime
    notif:AlphaTo(1, math.min(1, FadeTime), math.max(0, FadeTime - 1))

    return notif
end

function PANEL:Think()
    local time = CurTime()
    for _, pan in ipairs(self:GetChildren()) do
        if IsValid(pan) and pan.DieTime and time >= pan.DieTime then
            pan:Remove()
            local dummy = vgui.Create("Panel", self)
            dummy:SetTall(0)
            dummy:Dock(TOP)
            dummy:Remove()
        end
    end
end

vgui.Register("DEXNotificationsList", PANEL, "Panel")
