-- ============================================================================
-- ZSStatusArea - 状态效果 HUD 区域组件
-- 显示玩家身上的各种状态效果（燃烧、中毒、流血、冰冻等）
-- 每个状态以图标+名称+剩余时间的方式展示，带平滑动画
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 状态容器
-- [位置] ZSStatusArea / Init() / PerformLayout() / Think()
-- [作用] 按配置创建全部状态面板，动态调整高度并逐帧刷新
-- [常改] 容器位置、状态面板高度与间距
--
-- [区域] 状态配置数据
-- [位置] 文件顶部 statusdisplays 表 / statusValueFunction()
-- [作用] 定义各状态的名称、颜色、图标与数值来源
-- [常改] 新增状态条目、颜色、图标材质
--
-- [区域] 单个状态面板
-- [位置] ZSStatusModern / StatusThink() / Paint() / DrawTextWithOutline()
-- [作用] 图标 + 名称 + 剩余时间，宽度/透明度平滑动画
-- [常改] 动画速度、绘制样式、文字描边
-- ============================================================================

-- 共享函数：计算状态效果的剩余持续时间
function statusValueFunction(statusname)
	return function(self, lp)
		local status = lp:GetStatus(statusname)
		if status and status:IsValid() then
			return math.max(status:GetStartTime() + status:GetDuration() - CurTime(), 0)
		end
		return 0
	end
end

-- 现代风格状态字体
surface.CreateFont("ZsStatusFontModern", {
    font = "Roboto",
    size = 26,
    weight = 500,
    antialias = true,
    extended = true
})
 
-- 状态效果配置列表
local statusdisplays = {
	{
        Color = Color(255, 100, 0),
        Name = translate.Get("Status_Burning"),
        ValFunc = function(self, lp)
            for _, flame in pairs(ents.FindByClass("entityflame")) do
                if flame:IsValid() and flame:GetParent() == lp then
					local dieTime = lp:GetNWFloat("FireDieTime", 0)
					return math.max(dieTime - CurTime(), 0)
                end
            end
            return 0
        end,
        Max = 999,
        Icon = Material("zombiesurvival/killicons/burn")
    },
	{
		Color = Color(220, 255, 0),
		Name = translate.Get("Status_Poison"),
		ValFunc = function(self, lp) return lp:GetPoisonDamage() end,
		Max = GM.MaxPoisonDamage or 50,
		Icon = Material("zombiesurvival/poison.png")
	},
		{
		Color = Color(60, 245, 60),
		Name = translate.Get("Status_ZombieSpawn"),
		ValFunc = statusValueFunction("zombiespawnbuff"),
		Max = 50,
		Icon = Material("zombiesurvival/reaper.png")
	},
	{
		Color = Color(255, 60, 60),
		Name = translate.Get("Status_Bleed"),
		ValFunc = function(self, lp) return lp:GetBleedDamage() end,
		Max = GM.MaxBleedDamage or 50,
		Icon = Material("zombiesurvival/bleed.png")
	},
	{
		Color = Color(255, 60, 60),
		Name = translate.Get("Status_Redmarrow"),
		ValFunc = statusValueFunction("redmarrow"),
		Max = 10,
		Icon = Material("zombiesurvival/defense.png")
	},
	{
		Color = Color(255, 80, 80),
		Name = translate.Get("Status_Enfeeble"),
		ValFunc = statusValueFunction("enfeeble"),
		Max = 10,
		Icon = Material("zombiesurvival/infeeble.png")
	},
	{
		Color = Color(120, 120, 120),
		Name = translate.Get("Status_DimVision"),
		ValFunc = statusValueFunction("dimvision"),
		Max = 10,
		Icon = Material("zombiesurvival/dim_vision.png")
	},
	{
		Color = Color(120, 120, 120),
		Name = "混乱",
		ValFunc = statusValueFunction("chaos"),
		Max = 12,
		Icon = Material("zombiesurvival/chaos.png")
	},
	{
		Color = Color(100, 180, 100),
		Name = translate.Get("Status_Slow"),
		ValFunc = statusValueFunction("slow"),
		Max = 8,
		Icon = Material("zombiesurvival/slow.png")
	},
	{
		Color = Color(0, 160, 255),
		Name = translate.Get("Status_Frost"),
		ValFunc = statusValueFunction("frost"),
		Max = 9,
		Icon = Material("zombiesurvival/frost.png")
	},
	{
		Color = Color(0, 200, 255),
		Name = "冰冻",
		ValFunc = statusValueFunction("freeze"),
		Max = 4,
		Icon = Material("zombiesurvival/frost.png")
	},
	{
		Color = Color(180, 0, 255),
		Name = translate.Get("Status_Tremor"),
		ValFunc = statusValueFunction("frightened"),
		Max = 10,
		Icon = Material("zombiesurvival/tremors.png")
	},
	{
		Color = Color(255, 140, 50),
		Name = translate.Get("Status_Sickness"),
		ValFunc = statusValueFunction("sickness"),
		Max = 15,
		Icon = Material("zombiesurvival/sickness.png")
	},
	{
		Color = Color(255, 140, 50),
		Name = "快速换弹",
		ValFunc = statusValueFunction("fastreload"),
		Max = 15,
		Icon = Material("zombiesurvival/fastreload.png")
	},
	{
		Color = Color(180, 100, 50),
		Name = translate.Get("Status_KnockDown"),
		ValFunc = statusValueFunction("knockdown"),
		Max = 5,
		Icon = Material("zombiesurvival/knock_down.png")
	},
	{
		Color = Color(255, 60, 0),
		Name = "快速射击",
		ValFunc = statusValueFunction("fastshoot"),
		Max = 10,
		Icon = Material("zombiesurvival/fastshoot.png")
	},
	{
		Color = Color(220, 120, 110),
		Name = translate.Get("Status_Strength"),
		ValFunc = statusValueFunction("strengthdartboost"),
		Max = 10,
		Icon = Material("zombiesurvival/strength_shot.png")
	},
	{
		Color = Color(190, 220, 140),
		Name = translate.Get("Status_Adrenaline"),
		ValFunc = statusValueFunction("adrenalineamp"),
		Max = 10,
		Icon = Material("zombiesurvival/speed_up.png")
	},
	{
		Color = Color(150, 240, 130),
		Name = translate.Get("Status_Speed"),
		ValFunc = statusValueFunction("healdartboost"),
		Max = 10,
		Icon = Material("zombiesurvival/speed_up.png")
	},
	{
		Color = Color(110, 140, 240),
		Name = translate.Get("Status_Defence"),
		ValFunc = statusValueFunction("medrifledefboost"),
		Max = 10,
		Icon = Material("zombiesurvival/defense.png")
	},
	{
		Color = Color(160, 60, 170),
		Name = translate.Get("Status_Reaper"),
		ValFunc = statusValueFunction("reaper"),
		Max = 14,
		Icon = Material("zombiesurvival/reaper.png")
	},
	{
		Color = Color(235, 160, 40),
		Name = translate.Get("Status_Renegade"),
		ValFunc = statusValueFunction("renegade"),
		Max = 14,
		Icon = Material("zombiesurvival/headshot_stacks.png")
	}
}

-- 状态栏高度和间距
local statustall = 44
local spacing = 6

-- ============================================================================
-- ZSStatusArea - 状态效果容器
-- ============================================================================
local PANEL = {}

PANEL.StatusPanels = {}

-- ============================================================================
-- Init - 初始化状态容器
-- ============================================================================
function PANEL:Init()
	self:DockPadding(0, 0, 0, 0)
	self.StatusPanels = {}

	-- 遍历所有状态配置，创建对应的状态面板
	for _, statusdisp in pairs(statusdisplays) do
		local status = vgui.Create("ZSStatusModern", self)
		status:SetColor(statusdisp.Color)
		status:SetMemberName(statusdisp.Name)
		status.GetMemberValue = statusdisp.ValFunc
		status.MemberMaxValue = statusdisp.Max or 0
		status.Icon = statusdisp.Icon
		status:Dock(TOP)
        status:DockMargin(0, spacing, 0, 0)
		table.insert(self.StatusPanels, status)
	end

	self:ParentToHUD()
	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 动态调整容器高度
-- ============================================================================
function PANEL:PerformLayout()
    local visibleChildren = 0
    local children = self:GetChildren()
    for i = 1, #children do
        if children[i]:IsVisible() then
            visibleChildren = visibleChildren + 1
        end
    end

    local childTall = BetterScreenScale() * statustall
    local totalHeight = (childTall * visibleChildren) + (spacing * math.max(0, visibleChildren - 1))

    self:SetSize(BetterScreenScale() * 220, totalHeight)
    self:AlignBottom(math.max(0, ScrH() * 0.07))
    self:AlignLeft(math.max(0, ScrW() * 0.01))
end

-- ============================================================================
-- Think - 每帧更新所有状态面板
-- ============================================================================
function PANEL:Think()
	local lp = LocalPlayer()
	if lp and lp:IsValid() then
		for _, panel in pairs(self.StatusPanels) do
			panel:StatusThink(lp)
		end
	end
end

vgui.Register("ZSStatusArea", PANEL, "Panel")

-- ============================================================================
-- ZSStatusModern - 单个状态效果面板
-- 显示状态图标、名称和剩余时间，带平滑动画
-- ============================================================================
PANEL = {}

-- ============================================================================
-- Init - 初始化状态面板
-- ============================================================================
function PANEL:Init()
	self:SetColor(Color(255, 255, 255))
	self:SetTall(BetterScreenScale() * statustall)
	self:SetWide(0)
    self:SetVisible(false)

    -- 动画属性
    self.animatedWidth = 0
    self.animatedAlpha = 0
    self.lastValue = 0
end

-- 颜色存取器
function PANEL:SetColor(col) self.m_Color = col end
function PANEL:GetColor() return self.m_Color end
function PANEL:SetMemberName(n) self.MemberName = n end
function PANEL:GetMemberName() return self.MemberName end

-- ============================================================================
-- StatusThink - 每帧更新状态值并驱动动画
-- ============================================================================
function PANEL:StatusThink(lp)
	local currentValue = self.GetMemberValue and self:GetMemberValue(lp) or 0
	self.lastValue = currentValue

    local maxWidth = self:GetParent():GetWide()
    local targetWidth, targetAlpha = 0, 0

	if currentValue > 0 then
        if not self:IsVisible() then
            self:SetVisible(true)
            self.animatedWidth = 0
            self:GetParent():InvalidateLayout(true)
        end

		targetAlpha = 220
        targetWidth = self.MemberMaxValue > 0 and math.Clamp(currentValue / self.MemberMaxValue, 0, 1) * maxWidth or maxWidth
	else
		targetWidth = 0
		targetAlpha = 0
	end

	-- 使用 math.Approach 平滑动画过渡
	self.animatedWidth = math.Approach(self.animatedWidth, targetWidth, FrameTime() * maxWidth * 3)
	self.animatedAlpha = math.Approach(self.animatedAlpha, targetAlpha, FrameTime() * 255 * 4)

	self:SetWide(self.animatedWidth)

	if self.animatedAlpha < 1 and self:IsVisible() and currentValue <= 0 then
        self:SetVisible(false)
        self:GetParent():InvalidateLayout(true)
	end
end

-- ============================================================================
-- DrawTextWithOutline - 绘制带描边的文字
-- ============================================================================
local function DrawTextWithOutline(text, font, x, y, textColor, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x - 1, y, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x + 1, y, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x, y - 1, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x, y + 1, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x, y, textColor, xAlign, yAlign)
end

-- 渐变纹理
local texUpEdge = surface.GetTextureID("gui/gradient_up")
local texDownEdge = surface.GetTextureID("gui/gradient_down")
local texRightEdge = surface.GetTextureID("gui/gradient")

-- ============================================================================
-- Paint - 绘制状态面板的现代化风格
-- ============================================================================
function PANEL:Paint(w, h)
	if self.animatedAlpha <= 0 then return end

	local col = self:GetColor()
    local alpha = self.animatedAlpha
	local cornerCut = h * 0.4
	local r,g,b = col.r - 35, col.g -35, col.b -35
	surface.SetTexture(texDownEdge)
	surface.SetDrawColor(255, 255, 255, 180) 
	surface.DrawTexturedRect(0, 0, w * 0.015, h)
	surface.SetDrawColor(r,g,b,180) 
	surface.DrawTexturedRect(w * 0.015, 0, w * 0.075, h)
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRect(w * 0.125, 0, w , h)
	if self.Icon and w > h then
		surface.SetMaterial(self.Icon)
		surface.SetDrawColor(255, 255, 255, 255)

		local iconSize = h - 8
		local iconCenterX = w * 0.1075
		local xPos = iconCenterX - (iconSize / 2)
		local yPos = (h - iconSize -8) / 2

		surface.DrawTexturedRect(xPos, yPos, iconSize, iconSize)
	end

    local textColor = Color(col.r+50, col.g+50, col.b+50, 255)
    local outlineColor = Color(0, 0, 0, 220)
    local iconOffset = h + 4

	-- 状态名称
	if w > iconOffset + 60 then
		local name = self:GetMemberName()
		DrawTextWithOutline(name, "ZS2DFontHarmonyMiddle", iconOffset, h / 2, textColor, outlineColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	-- 剩余时间显示
	if w > 40 then
		local valueText = self.MemberMaxValue > 0 and string.format("%.1f", self.lastValue) or string.format("%f", self.lastValue)
        local font = self.MemberMaxValue > 0 and "ZS2DFontHarmonyMiddle" or "ZsStatusFontModern"
		DrawTextWithOutline(valueText, font, w - 8, h / 2, textColor, outlineColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
end

vgui.Register("ZSStatusModern", PANEL, "DPanel")
