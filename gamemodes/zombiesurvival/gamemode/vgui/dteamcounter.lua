-- ============================================================================
-- DTeamCounter - 队伍人数计数器组件
-- 显示某个队伍的玩家数量，带旋转图标动画和颜色闪烁效果
-- 用于 HUD 顶部的队伍状态显示
-- ============================================================================

local PANEL = {}

-- 默认队伍ID
PANEL.m_Team = 0
-- 下次刷新时间
PANEL.NextRefresh = 0

-- 图标旋转动画函数
local function ImageThink(self)
	self:SetRotation(math.sin((RealTime() + self.Seed) * 0.5) * 25)
	self:OldPaint()
end

-- ============================================================================
-- Init - 初始化队伍计数器
-- ============================================================================
function PANEL:Init()
	-- 创建旋转图标（队伍图标）
	self.m_Image = vgui.Create("DEXRotatedImage", self)
	self.m_Image:SetImage("icon16/check_off.png")
	self.m_Image.Seed = math.Rand(0, 1000)
	self.m_Image.OldPaint = self.m_Image.Paint
	self.m_Image.Paint = ImageThink

	-- 创建队伍人数标签
	self.m_Counter = vgui.Create("DLabel", self)
	self.m_Counter:SetFont("ZSHUDFontSmaller")

	self:RefreshContents()
end

-- ============================================================================
-- Paint - 透明背景
-- ============================================================================
function PANEL:Paint()
	return true
end

-- ============================================================================
-- Think - 定时刷新队伍人数
-- ============================================================================
function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + 1
		self:RefreshContents()
	end
end

-- ============================================================================
-- SetTeam - 设置要统计的队伍ID
-- ============================================================================
function PANEL:SetTeam(teamid)
	self.m_Team = teamid
	self.m_Counter:SetTextColor(team.GetColor(teamid))
end

-- ============================================================================
-- SetImage - 设置队伍图标材质
-- ============================================================================
function PANEL:SetImage(mat)
	self.m_Image:SetImage(mat)

	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局图标和数字
-- ============================================================================
function PANEL:PerformLayout()
	self.m_Image:SetSize(self:GetSize())
	self.m_Counter:AlignBottom()
	self.m_Counter:AlignRight()
end

-- ============================================================================
-- RefreshContents - 刷新队伍人数并触发颜色动画
-- ============================================================================
function PANEL:RefreshContents()
	local numplayers = team.NumPlayers(self.m_Team)
	self.m_PrevPlayers = self.m_PrevPlayers or numplayers

	self.m_Counter:SetText(numplayers)
	self.m_Counter:SizeToContents()

	-- 人数变化时触发颜色闪烁动画
	if self.m_PrevPlayers ~= numplayers then
		self.m_Counter:Stop()
		self.m_Counter:SetColor(numplayers > self.m_PrevPlayers and color_white or COLOR_RED)
		self.m_Counter:ColorTo(team.GetColor(self.m_Team), 2)

		self.m_PrevPlayers = numplayers
	end

	self:InvalidateLayout()
end

vgui.Register("DTeamCounter", PANEL, "DPanel")
