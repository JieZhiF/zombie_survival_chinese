-- We'll use a shared function to calculate the remaining duration of a status.
-- This keeps our code clean and avoids repetition.
function statusValueFunction(statusname)
	return function(self, lp)
		local status = lp:GetStatus(statusname)
		if status and status:IsValid() then
			-- Return the time remaining for the status effect.
			return math.max(status:GetStartTime() + status:GetDuration() - CurTime(), 0)
		end
		return 0
	end
end

-- A more modern, clean font for the UI.
surface.CreateFont("ZsStatusFontModern", {
    font = "Roboto", -- Using a clean, widely available font.
    size = 26,
    weight = 500,
    antialias = true,
    extended = true
})
 
-- Configuration for each status effect. This data-driven approach is great for extensibility.
local statusdisplays = {
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
		Color = Color(180, 100, 50),
		Name = translate.Get("Status_KnockDown"),
		ValFunc = statusValueFunction("knockdown"),
		Max = 5,
		Icon = Material("zombiesurvival/knock_down.png")
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
local statustall = 40 //状态栏的高度
local spacing = 6 //间距
-- The main container for all our status panels.
local PANEL = {}

PANEL.StatusPanels = {}

function PANEL:Init()
	-- No ugly margins needed, we'll control spacing in the child panel's Layout function.
	self:DockPadding(0, 0, 0, 0)
	self.StatusPanels = {}

	for _, statusdisp in pairs(statusdisplays) do
		local status = vgui.Create("ZSStatusModern", self)
		status:SetColor(statusdisp.Color)
		status:SetMemberName(statusdisp.Name)
		status.GetMemberValue = statusdisp.ValFunc
		status.MemberMaxValue = statusdisp.Max or 0
		status.Icon = statusdisp.Icon
		status:Dock(TOP)
		-- We add a small margin between panels for a cleaner look.
        status:DockMargin(0, 4, 0, 0)
		table.insert(self.StatusPanels, status)
	end

	self:ParentToHUD()
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
    local visibleChildren = 0
    local children = self:GetChildren()
    for i = 1, #children do
        if children[i]:IsVisible() then
            visibleChildren = visibleChildren + 1
        end
    end

	-- Dynamically adjust height based on visible status panels.
    local childTall = BetterScreenScale() * statustall
    local totalHeight = (childTall * visibleChildren) + (spacing * math.max(0, visibleChildren - 1))

    self:SetSize(BetterScreenScale() * 220, totalHeight)
    -- Positioned more towards the center for better focus.
    self:AlignBottom(math.max(0, ScrH() * 0.07))
    self:AlignLeft(math.max(0, ScrW() * 0.01))
end


function PANEL:Think()
	local lp = LocalPlayer()
	if lp and lp:IsValid() then
		for _, panel in pairs(self.StatusPanels) do
			-- Let each status panel update itself.
			panel:StatusThink(lp)
		end
	end
end

vgui.Register("ZSStatusArea", PANEL, "Panel")


-- The modernized individual status panel.
PANEL = {}
	

function PANEL:Init()
	self:SetColor(Color(255, 255, 255))
	self:SetTall(BetterScreenScale() * statustall)
	self:SetWide(0)
    self:SetVisible(false)

    -- Properties for smooth animations.
    self.animatedWidth = 0
    self.animatedAlpha = 0
    self.lastValue = 0
end

function PANEL:SetColor(col) self.m_Color = col end
function PANEL:GetColor() return self.m_Color end
function PANEL:SetMemberName(n) self.MemberName = n end
function PANEL:GetMemberName() return self.MemberName end

function PANEL:StatusThink(lp)
	local currentValue = self.GetMemberValue and self:GetMemberValue(lp) or 0
	self.lastValue = currentValue

    local maxWidth = self:GetParent():GetWide()
    local targetWidth, targetAlpha = 0, 0

	if currentValue > 0 then
        -- If the panel becomes active, trigger a relayout of the parent container.
        if not self:IsVisible() then
            self:SetVisible(true)
            self.animatedWidth = 0
            self:GetParent():InvalidateLayout(true)
        end

		targetAlpha = 220 -- Slightly transparent for a modern look.
        targetWidth = self.MemberMaxValue > 0 and math.Clamp(currentValue / self.MemberMaxValue, 0, 1) * maxWidth or maxWidth
	else
		targetWidth = 0
		targetAlpha = 0
	end

	-- Approach our target values for smooth animation.
	self.animatedWidth = math.Approach(self.animatedWidth, targetWidth, FrameTime() * maxWidth * 3)
	self.animatedAlpha = math.Approach(self.animatedAlpha, targetAlpha, FrameTime() * 255 * 4)

	self:SetWide(self.animatedWidth)

	if self.animatedAlpha < 1 and self:IsVisible() and currentValue <= 0 then
        self:SetVisible(false)
        -- Once hidden, trigger a relayout to collapse the space.
        self:GetParent():InvalidateLayout(true)
	end
end

local function DrawTextWithOutline(text, font, x, y, textColor, outlineColor, xAlign, yAlign)
    -- Draw the outline by drawing the text in the outline color at 4 offset positions.
    draw.SimpleText(text, font, x - 1, y, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x + 1, y, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x, y - 1, outlineColor, xAlign, yAlign)
    draw.SimpleText(text, font, x, y + 1, outlineColor, xAlign, yAlign)

    -- Draw the main text on top.
    draw.SimpleText(text, font, x, y, textColor, xAlign, yAlign)
end

local texUpEdge = surface.GetTextureID("gui/gradient_up") -- 顶部边缘的渐变纹理
local texDownEdge = surface.GetTextureID("gui/gradient_down") -- 底部边缘的渐变纹理
local texRightEdge = surface.GetTextureID("gui/gradient") -- 右侧边缘的渐变纹理
-- The new and improved Paint function for a modern look.
function PANEL:Paint(w, h)
	if self.animatedAlpha <= 0 then return end

	local col = self:GetColor()
    local alpha = self.animatedAlpha
	local cornerCut = h * 0.4 -- The size of the angled corner.
	local r,g,b = col.r - 35, col.g -35, col.b -35
	surface.SetTexture(texDownEdge)
	surface.SetDrawColor(255, 255, 255, 180) 
	surface.DrawTexturedRect(0, 0, w * 0.015, h)
	surface.SetDrawColor(r,g,b,180) 
	surface.DrawTexturedRect(w * 0.015, 0, w * 0.075, h)
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRect(w * 0.125, 0, w , h)
	-- 图像显示
	if self.Icon and w > h then
		surface.SetMaterial(self.Icon)
		surface.SetDrawColor(255, 255, 255,255)
		local iconSize = h - 12
		surface.DrawTexturedRect(w * 0.1075 - iconSize / 2  , 0, iconSize, iconSize)
	end

    local textColor = Color(col.r+50, col.g+50, col.b+50, 255)
    local outlineColor = Color(0, 0, 0, 220) -- 使用近乎不透明的黑色作为描边
    local iconOffset = h + 4

	-- 状态名字.
	if w > iconOffset + 60 then
		local name = self:GetMemberName()
		DrawTextWithOutline(name, "ZS2DFontHarmonyMiddle", iconOffset, h / 2, textColor, outlineColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	--时间显示.
	if w > 40 then
		local valueText = self.MemberMaxValue > 0 and string.format("%.1f", self.lastValue) or string.format("%f", self.lastValue)
        local font = self.MemberMaxValue > 0 and "ZS2DFontHarmonyMiddle" or "ZsStatusFontModern"
		DrawTextWithOutline(valueText, font, w - 8, h / 2, textColor, outlineColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	
end

vgui.Register("ZSStatusModern", PANEL, "DPanel")