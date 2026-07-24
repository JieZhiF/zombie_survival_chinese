-- ============================================================================
-- DAmmoCounter - ALT菜单右侧界面的弹药计数器组件
-- 显示当前选中弹药的类型图标、数量、丢弃和给予按钮
-- ============================================================================

local PANEL = {}

-- 下一次刷新时间
PANEL.NextRefresh = 0
-- 刷新间隔（秒）
PANEL.RefreshTime = 1

-- 子弹类型文字颜色（棕金色）
local col2 = Color(190, 150, 80, 210)
-- 子弹数量文字颜色（深色）
local coldark = Color(0, 0, 0, 100)

-- 获取目标玩家实体索引（用于给予弹药）
local function GetTargetEntIndex()
	return GAMEMODE.HumanMenuLockOn and GAMEMODE.HumanMenuLockOn:IsValid() and GAMEMODE.HumanMenuLockOn:EntIndex() or 0
end

-- 丢弃按钮点击回调：发送丢弃弹药命令
local function DropDoClick(self)
	RunConsoleCommand("zsdropammo", self:GetParent():GetAmmoType())
end

-- 给予按钮点击回调：发送给予弹药命令
local function GiveDoClick(self)
	RunConsoleCommand("zsgiveammo", self:GetParent():GetAmmoType(), GetTargetEntIndex())
end

-- ============================================================================
-- Init - 初始化弹药计数器面板
-- ============================================================================
function PANEL:Init()
	local font = "ZSAmmoName"
	-- 弹药数量标签
	self.m_AmmoCountLabel = EasyLabel(self, "0", font, color_black)

	-- 弹药类型名称标签
	self.m_AmmoTypeLabel = EasyLabel(self, " ", font, col2)

	-- 丢弃按钮（盒子图标）
	self.m_DropButton = vgui.Create("DImageButton", self)
	self.m_DropButton:SetImage("icon16/box.png")
	self.m_DropButton:SizeToContents()
	self.m_DropButton:SetTooltip("Drop")
	self.m_DropButton.DoClick = DropDoClick

	-- 给予按钮（用户图标）
	self.m_GiveButton = vgui.Create("DImageButton", self)
	self.m_GiveButton:SetImage("icon16/user_go.png")
	self.m_GiveButton:SizeToContents()
	self.m_GiveButton:SetTooltip("Give")
	self.m_GiveButton.DoClick = GiveDoClick

	-- 默认弹药类型为手枪弹
	self:SetAmmoType("pistol")
end

-- 面板背景颜色（深色半透明）
local colBG = Color(5, 5, 5, 180)

-- ============================================================================
-- Paint - 绘制弹药计数器背景
-- ============================================================================
function PANEL:Paint()
	local tall = self:GetTall()
	local csize = tall - 8
	draw.RoundedBoxEx(8, 0, 0, self:GetWide(), tall, colBG)
	draw.RoundedBox(4, 8, tall * 0.5 - csize * 0.5, csize, csize, col2)
	return true
end

-- ============================================================================
-- Think - 定时刷新弹药数据
-- ============================================================================
function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshContents()
	end
end

-- ============================================================================
-- RefreshContents - 刷新弹药数量和显示
-- ============================================================================
function PANEL:RefreshContents()
	local count = MySelf:GetAmmoCount(self:GetAmmoType())

	self.m_AmmoCountLabel:SetTextColor(count == 0 and coldark or color_black)
	self.m_AmmoCountLabel:SetText(count)
	self.m_AmmoCountLabel:SizeToContents()

	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局子控件位置
-- ============================================================================
function PANEL:PerformLayout()
	self.m_AmmoTypeLabel:Center()

	self.m_AmmoCountLabel:SetPos(8 + (self:GetTall() - 8) * 0.5 - self.m_AmmoCountLabel:GetWide() / 2, 0)
	self.m_AmmoCountLabel:CenterVertical()

	self.m_DropButton:AlignTop(1)
	self.m_DropButton:AlignRight(8)

	self.m_GiveButton:AlignBottom(1)
	self.m_GiveButton:AlignRight(8)
end

-- ============================================================================
-- SetAmmoType - 设置当前弹药类型
-- ============================================================================
function PANEL:SetAmmoType(ammotype)
	self.m_AmmoType = ammotype

	self.m_AmmoTypeLabel:SetText(GAMEMODE.AmmoNames[ammotype] or ammotype)
	self.m_AmmoTypeLabel:SizeToContents()

	self:RefreshContents()
end

-- ============================================================================
-- GetAmmoType - 获取当前弹药类型
-- ============================================================================
function PANEL:GetAmmoType()
	return self.m_AmmoType
end

vgui.Register("DAmmoCounter", PANEL, "DPanel")
