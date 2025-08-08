//描述：这个文件是按ALT时右边出现的界面，也就是那个子弹界面
//注释状态：已完成，

local PANEL = {}

PANEL.NextRefresh = 0//下一次刷新时间
PANEL.RefreshTime = 1//刷新时间

local col2 = Color(190, 150, 80, 210)//子弹类型颜色
local coldark = Color(0, 0, 0, 100)//子弹数量颜色

local function GetTargetEntIndex()//获取目标玩家的索引
	return GAMEMODE.HumanMenuLockOn and GAMEMODE.HumanMenuLockOn:IsValid() and GAMEMODE.HumanMenuLockOn:EntIndex() or 0
end

local function DropDoClick(self)//丢弃
	RunConsoleCommand("zsdropammo", self:GetParent():GetAmmoType())//zsdropammo 丢弃子弹,参数是子弹类型
end

local function GiveDoClick(self)//给予
	RunConsoleCommand("zsgiveammo", self:GetParent():GetAmmoType(), GetTargetEntIndex())//zsgiveammo 给予子弹,参数是子弹类型和目标玩家
end

function PANEL:Init()
	local font = "ZSAmmoName"//字体
	self.m_AmmoCountLabel = EasyLabel(self, "0", font, color_black)//子弹数量

	self.m_AmmoTypeLabel = EasyLabel(self, " ", font, col2)//子弹类型

	self.m_DropButton = vgui.Create("DImageButton", self)//丢弃按钮
	self.m_DropButton:SetImage("icon16/box.png")--盒子图标,丢弃的那个
	self.m_DropButton:SizeToContents()//自适应大小
	self.m_DropButton:SetTooltip("Drop")//提示
	self.m_DropButton.DoClick = DropDoClick//点击事件,上面那个丢弃函数

	self.m_GiveButton = vgui.Create("DImageButton", self)//给予按钮
	self.m_GiveButton:SetImage("icon16/user_go.png")--小人
	self.m_GiveButton:SizeToContents()//自适应大小
	self.m_GiveButton:SetTooltip("Give")//提示
	self.m_GiveButton.DoClick = GiveDoClick//点击事件,上面那个给予函数

	self:SetAmmoType("pistol")//默认是手枪子弹
end

local colBG = Color(5, 5, 5, 180)//背景颜色,也就是那个背景板
function PANEL:Paint()
	local tall = self:GetTall()//高度
	local csize = tall - 8//子弹数量的大小
	draw.RoundedBoxEx(8, 0, 0, self:GetWide(), tall, colBG)//画背景板,圆角8,x,y的位置，宽度,高度,颜色
	draw.RoundedBox(4, 8, tall * 0.5 - csize * 0.5, csize, csize, col2)//画子弹数量的背景

	return true
end

function PANEL:Think()//刷新
	if RealTime() >= self.NextRefresh then//如果当前时间大于下一次刷新时间
		self.NextRefresh = RealTime() + self.RefreshTime//下一次刷新时间等于当前时间加上刷新时间
		self:RefreshContents()//刷新内容
	end
end

function PANEL:RefreshContents()//刷新内容
	local count = MySelf:GetAmmoCount(self:GetAmmoType())//获取子弹数量

	self.m_AmmoCountLabel:SetTextColor(count == 0 and coldark or color_black)//如果子弹数量为0，就是黑色，否则就是白色
	self.m_AmmoCountLabel:SetText(count)//设置子弹数量
	self.m_AmmoCountLabel:SizeToContents()//自适应大小

	self:InvalidateLayout()//重新布局
end

function PANEL:PerformLayout()//重新布局
	self.m_AmmoTypeLabel:Center()//居中

	self.m_AmmoCountLabel:SetPos(8 + (self:GetTall() - 8) * 0.5 - self.m_AmmoCountLabel:GetWide() / 2, 0)//设置子弹数量的位置,8+(高度-8)*0.5-子弹数量的宽度/2,0
	self.m_AmmoCountLabel:CenterVertical()//垂直居中

	self.m_DropButton:AlignTop(1)//对齐顶部,1是间隔
	self.m_DropButton:AlignRight(8)//对齐右边,8是间隔

	self.m_GiveButton:AlignBottom(1)//对齐底部
	self.m_GiveButton:AlignRight(8)//对齐右边
end

function PANEL:SetAmmoType(ammotype)//设置子弹类型
	self.m_AmmoType = ammotype//子弹类型

	self.m_AmmoTypeLabel:SetText(GAMEMODE.AmmoNames[ammotype] or ammotype)//设置子弹类型的文字,这里是获取的游戏ammonames列表里面的参数，传输的是子弹类型
	self.m_AmmoTypeLabel:SizeToContents()//自适应大小

	self:RefreshContents()//刷新内容
end

function PANEL:GetAmmoType()//获取子弹类型
	return self.m_AmmoType//子弹类型
end

vgui.Register("DAmmoCounter", PANEL, "DPanel")
