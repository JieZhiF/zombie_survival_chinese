-- ============================================================================
-- DTeamHeading - 队伍标题栏组件（Tab 计分板用）
-- 显示队伍名称、人数和对应的图标（人类/僵尸头部图标）
-- ============================================================================

local PANEL = {}

-- 默认队伍ID
PANEL.m_Team = 0
-- 下次刷新时间
PANEL.NextRefresh = 0
-- 刷新间隔（秒）
PANEL.RefreshTime = 2

-- ============================================================================
-- Init - 初始化队伍标题栏
-- ============================================================================
function PANEL:Init()
	-- 队伍名称标签
	self.m_TeamNameLabel = EasyLabel(self, " ", "ZSScoreBoardHeading", color_black)
	-- 队伍人数标签
	self.m_TeamCountLabel = EasyLabel(self, " ", "ZSScoreBoardHeading", color_black)

	-- 队伍图标（人类头/僵尸头）
	self.m_Icon = vgui.Create("DImage", self)
	self.m_Icon:SetVisible(false)
	self.m_Icon:NoClipping(true)

	self:InvalidateLayout()
end

-- ============================================================================
-- Think - 定时刷新队伍数据
-- ============================================================================
function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshContents()
	end
end

-- ============================================================================
-- PerformLayout - 布局标题栏控件
-- ============================================================================
function PANEL:PerformLayout()
	self.m_TeamNameLabel:Center()

	self.m_TeamCountLabel:AlignRight(16)
	self.m_TeamCountLabel:CenterVertical()

	self.m_Icon:AlignLeft(2)
	self.m_Icon:CenterVertical()
end

-- ============================================================================
-- RefreshContents - 刷新队伍名称和人数
-- ============================================================================
function PANEL:RefreshContents()
	local teamid = self:GetTeam()

	self.m_TeamNameLabel:SetText(team.GetName(teamid))
	self.m_TeamNameLabel:SizeToContents()

	self.m_TeamCountLabel:SetText(team.NumPlayers(teamid))
	self.m_TeamCountLabel:SizeToContents()

	self:InvalidateLayout()
end

-- ============================================================================
-- Paint - 绘制灰色标题栏背景
-- ============================================================================
function PANEL:Paint()
	local wid, hei = self:GetWide(), self:GetTall()

	surface.SetDrawColor(130, 130, 130, 180)
	surface.DrawRect(0, 0, wid, hei)
	surface.SetDrawColor(60, 60, 60, 180)
	surface.DrawOutlinedRect(0, 0, wid, hei)

	return true
end

-- ============================================================================
-- SetTeam - 设置队伍ID并显示对应图标
-- ============================================================================
function PANEL:SetTeam(teamid)
	self.m_Team = teamid

	if teamid == TEAM_HUMAN then
		self.m_Icon:SetVisible(true)
		self.m_Icon:SetImage("zombiesurvival/humanhead")
		self.m_Icon:SizeToContents()
		self:InvalidateLayout()
	elseif teamid == TEAM_UNDEAD then
		self.m_Icon:SetVisible(true)
		self.m_Icon:SetImage("zombiesurvival/zombiehead")
		self.m_Icon:SizeToContents()
		self:InvalidateLayout()
	else
		self.m_Icon:SetVisible(false)
	end
end

-- ============================================================================
-- GetTeam - 获取当前队伍ID
-- ============================================================================
function PANEL:GetTeam() return self.m_Team end

vgui.Register("DTeamHeading", PANEL, "Panel")
