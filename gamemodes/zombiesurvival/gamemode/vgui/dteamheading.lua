local PANEL = {}
//这个就是按下TAB键时候的面板
//注释状态：已完成
PANEL.m_Team = 0//默认队伍ID
PANEL.NextRefresh = 0//下次刷新时间
PANEL.RefreshTime = 2//刷新间隔

function PANEL:Init()
	self.m_TeamNameLabel = EasyLabel(self, " ", "ZSScoreBoardHeading", color_black)//队伍名称
	self.m_TeamCountLabel = EasyLabel(self, " ", "ZSScoreBoardHeading", color_black)//队伍人数

	self.m_Icon = vgui.Create("DImage", self)//队伍图标
	self.m_Icon:SetVisible(false)//默认不显示
	self.m_Icon:NoClipping(true)//不裁剪

	self:InvalidateLayout()//刷新布局
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then//如果当前时间大于下次刷新时间
		self.NextRefresh = RealTime() + self.RefreshTime//下次刷新时间=当前时间+刷新间隔
		self:RefreshContents()//刷新内容
	end
end

function PANEL:PerformLayout()
	self.m_TeamNameLabel:Center()//居中

	self.m_TeamCountLabel:AlignRight(16)//右对齐,右边距16
	self.m_TeamCountLabel:CenterVertical()//垂直居中

	self.m_Icon:AlignLeft(2)//对齐,左边距2
	self.m_Icon:CenterVertical()//垂直居中
end

function PANEL:RefreshContents()
	local teamid = self:GetTeam()//获取队伍ID

	self.m_TeamNameLabel:SetText(team.GetName(teamid))//设置队伍名称
	self.m_TeamNameLabel:SizeToContents()//自适应大小

	self.m_TeamCountLabel:SetText(team.NumPlayers(teamid))//设置队伍人数
	self.m_TeamCountLabel:SizeToContents()

	self:InvalidateLayout()
end

function PANEL:Paint()//这个就是按下TAB时显示的那个灰色背景
	local wid, hei = self:GetWide(), self:GetTall()//获取宽高

	surface.SetDrawColor(130, 130, 130, 180)//设置颜色
	surface.DrawRect(0, 0, wid, hei)//绘制矩形
	surface.SetDrawColor(60, 60, 60, 180)//设置颜色
	surface.DrawOutlinedRect(0, 0, wid, hei)

	return true
end

function PANEL:SetTeam(teamid)//设置队伍ID
	self.m_Team = teamid

	if teamid == TEAM_HUMAN then//如果是人类
		self.m_Icon:SetVisible(true)//显示队伍图标
		self.m_Icon:SetImage("zombiesurvival/humanhead")//设置队伍图标
		self.m_Icon:SizeToContents()//自适应大小
		self:InvalidateLayout()//刷新布局
	elseif teamid == TEAM_UNDEAD then//如果是不死族/
		self.m_Icon:SetVisible(true)//显示队伍图标
		self.m_Icon:SetImage("zombiesurvival/zombiehead")//设置队伍图标
		self.m_Icon:SizeToContents()//自适应大小
		self:InvalidateLayout()//刷新布局
	else
		self.m_Icon:SetVisible(false)//隐藏队伍图标
	end
end
function PANEL:GetTeam() return self.m_Team end//获取队伍ID

vgui.Register("DTeamHeading", PANEL, "Panel")
