-- ============================================================================
-- DEXRoundedFrame - 增强型圆角窗口框架
-- 继承自 DFrame，支持自定圆角半径和每个角的独立曲线控制
-- ============================================================================

local PANEL = {}

-- 圆角半径存取器
AccessorFunc(PANEL, "m_iBorderRadius", "BorderRadius", FORCE_NUMBER)
-- 四个角的曲线开关
AccessorFunc(PANEL, "m_bCurveTopLeft", "CurveTopLeft", FORCE_BOOL)
AccessorFunc(PANEL, "m_bCurveTopRight", "CurveTopRight", FORCE_BOOL)
AccessorFunc(PANEL, "m_bCurveBottomLeft", "CurveBottomLeft", FORCE_BOOL)
AccessorFunc(PANEL, "m_bCurveBottomRight", "CurveBottomRight", FORCE_BOOL)

-- 背景颜色存取器
AccessorFunc(PANEL, "m_tColor", "Color")

-- ============================================================================
-- CloseDoClick - 关闭按钮点击回调
-- ============================================================================
local function CloseDoClick(self)
	self:GetParent():Close()
end

-- ============================================================================
-- Init - 初始化圆角窗口框架
-- ============================================================================
function PANEL:Init()
	self:SetBorderRadius(8)
	self:SetCurve(true)

	self:SetColor(Color(0, 0, 0, 180))

	self:ShowCloseButton(false)
	self:SetTitle(" ")

	-- 自定义关闭按钮（错误图标样式）
	self.CloseButton = vgui.Create("DImageButton", self)
	self.CloseButton:SetImage("VGUI/notices/error")
	self.CloseButton:SetSize(32, 32)
	self.CloseButton:NoClipping(true)
	self.CloseButton:SetZPos(-10)
	self.CloseButton.DoClick = CloseDoClick
	local oldpaint = self.CloseButton.m_Image.Paint
	self.CloseButton.m_Image.Paint = function(me)
		surface.DisableClipping(true)
		oldpaint(me)
		surface.DisableClipping(false)
	end

	self.lblTitle:SetFont("dexfont_med")

	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局子控件位置
-- ============================================================================
function PANEL:PerformLayout()
	self.lblTitle:SetWide(self:GetWide() - 25)
	self.lblTitle:SetPos(8, 2)

	self.CloseButton:AlignRight(self.CloseButton:GetWide() * -0.25)
	self.CloseButton:AlignTop(self.CloseButton:GetTall() * -0.25)
end

-- ============================================================================
-- SetTitle - 设置窗口标题
-- ============================================================================
function PANEL:SetTitle(title)
	self.lblTitle:SetText(title)
	self.lblTitle:SizeToContents()

	self:InvalidateLayout()
end

-- ============================================================================
-- SetCurve - 同时设置所有四个角的曲线开关
-- ============================================================================
function PANEL:SetCurve(curve)
	self:SetCurveTopLeft(curve)
	self:SetCurveTopRight(curve)
	self:SetCurveBottomLeft(curve)
	self:SetCurveBottomRight(curve)
end

-- ============================================================================
-- SetColorAlpha - 设置背景颜色的透明度
-- ============================================================================
function PANEL:SetColorAlpha(a)
	self:GetColor().a = a
end

-- ============================================================================
-- Paint - 绘制圆角矩形背景
-- ============================================================================
function PANEL:Paint()
	draw.RoundedBoxEx(self:GetBorderRadius(), 0, 0, self:GetWide(), self:GetTall(), self:GetColor(), self:GetCurveTopLeft(), self:GetCurveTopRight(), self:GetCurveBottomLeft(), self:GetCurveBottomRight())
end

vgui.Register("DEXRoundedFrame", PANEL, "DFrame")
