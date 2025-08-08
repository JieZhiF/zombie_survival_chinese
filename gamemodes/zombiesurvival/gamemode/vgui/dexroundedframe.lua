local PANEL = {}
//描述：这个应该是作者做的一个增强版的绘制圆角矩形的一个东西
//注释状态：已完成
AccessorFunc(PANEL, "m_iBorderRadius", "BorderRadius", FORCE_NUMBER)//添加函数,应该是圆角的角度？
AccessorFunc(PANEL, "m_bCurveTopLeft", "CurveTopLeft", FORCE_BOOL)//添加函数,左上角的曲线
AccessorFunc(PANEL, "m_bCurveTopRight", "CurveTopRight", FORCE_BOOL)//添加函数,右上角的曲线
AccessorFunc(PANEL, "m_bCurveBottomLeft", "CurveBottomLeft", FORCE_BOOL)//添加函数,左下角的曲线
AccessorFunc(PANEL, "m_bCurveBottomRight", "CurveBottomRight", FORCE_BOOL)//添加函数,右下角的曲线

AccessorFunc(PANEL, "m_tColor", "Color")//添加函数,设置颜色

local function CloseDoClick(self)//关闭按钮的点击事件
	self:GetParent():Close()//关闭父面板
end

function PANEL:Init()//初始化
	self:SetBorderRadius(8)//设置圆角的角度
	self:SetCurve(true)//设置曲线

	self:SetColor(Color(0, 0, 0, 180))//设置颜色

	self:ShowCloseButton(false)//显示关闭按钮，false为不显示
	self:SetTitle(" ")

	self.CloseButton = vgui.Create("DImageButton", self)//创建一个带图片的按钮
	self.CloseButton:SetImage("VGUI/notices/error")//设置图片
	self.CloseButton:SetSize(32, 32)//设置大小
	self.CloseButton:NoClipping(true)//设置不裁剪
	self.CloseButton:SetZPos(-10)//设置Z轴位置
	self.CloseButton.DoClick = CloseDoClick//设置点击事件
	local oldpaint = self.CloseButton.m_Image.Paint//获取按钮的图片的绘制函数
	self.CloseButton.m_Image.Paint = function(me)//重写按钮的图片的绘制函数
		surface.DisableClipping(true)//禁用裁剪
		oldpaint(me)//调用原来的绘制函数
		surface.DisableClipping(false)//启用裁剪
	end

	self.lblTitle:SetFont("dexfont_med")//设置字体

	self:InvalidateLayout()//重新布局
end

function PANEL:PerformLayout()
	self.lblTitle:SetWide(self:GetWide() - 25)//设置标题的宽度
	self.lblTitle:SetPos(8, 2)//设置标题的位置

	self.CloseButton:AlignRight(self.CloseButton:GetWide() * -0.25)//设置关闭按钮的右边距
	self.CloseButton:AlignTop(self.CloseButton:GetTall() * -0.25)//设置关闭按钮的上边距
end

function PANEL:SetTitle(title)//设置标题
	self.lblTitle:SetText(title)//设置标题的文本
	self.lblTitle:SizeToContents()//设置标题的大小

	self:InvalidateLayout()///重新布局
end

function PANEL:SetCurve(curve)//设置曲线
	self:SetCurveTopLeft(curve)//设置左上角的曲线
	self:SetCurveTopRight(curve)//设置右上角的曲线
	self:SetCurveBottomLeft(curve)//设置左下角的曲线
	self:SetCurveBottomRight(curve)//设置右下角的曲线
end

function PANEL:SetColorAlpha(a)
	self:GetColor().a = a
end

function PANEL:Paint()//绘制
	draw.RoundedBoxEx(self:GetBorderRadius(), 0, 0, self:GetWide(), self:GetTall(), self:GetColor(), self:GetCurveTopLeft(), self:GetCurveTopRight(), self:GetCurveBottomLeft(), self:GetCurveBottomRight())
end

vgui.Register("DEXRoundedFrame", PANEL, "DFrame")
