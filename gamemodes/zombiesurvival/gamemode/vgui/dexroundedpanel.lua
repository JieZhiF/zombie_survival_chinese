-- ============================================================================
-- DEXRoundedPanel - 圆角面板组件
-- 与 DEXRoundedFrame 类似，但继承自 DPanel 而非 DFrame
-- 支持自定义圆角半径和每个角的独立曲线控制
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 主面板
-- [位置] Init() / Paint()
-- [作用] 绘制带圆角和透明度的背景面板
-- [常改] 圆角半径、背景颜色、透明度
--
-- [区域] 圆角/颜色控制
-- [位置] SetCurve() / SetColorAlpha() / 文件顶部 AccessorFunc
-- [作用] 提供四角独立曲线与颜色透明度设置接口
-- [常改] 存取器定义、默认值
-- ============================================================================

-- 创建该组件使用的字体
surface.CreateFont("dexfont_med", {font = "impact", size = 19, weight = 0, antialias = false, shadow = false, outline = true})

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
-- Init - 初始化圆角面板
-- ============================================================================
function PANEL:Init()
	self:SetBorderRadius(8)
	self:SetCurve(true)

	self:SetColor(Color(10, 10, 10, 120))
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
function PANEL:Paint(w, h)
	draw.RoundedBoxEx(self:GetBorderRadius(), 0, 0, w, h, self:GetColor(), self:GetCurveTopLeft(), self:GetCurveTopRight(), self:GetCurveBottomLeft(), self:GetCurveBottomRight())
end

vgui.Register("DEXRoundedPanel", PANEL, "DPanel")
