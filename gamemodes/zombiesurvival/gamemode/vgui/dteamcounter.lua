local PANEL = {}
//描述：应该是用来显示队伍人数的
//注释状态：已完成
PANEL.m_Team = 0//默认队伍ID

PANEL.NextRefresh = 0//下一次刷新

local function ImageThink(self)//图像思考
	self:SetRotation(math.sin((RealTime() + self.Seed) * 0.5) * 25)//设置旋转
	self:OldPaint()//旧画
end

function PANEL:Init()
	self.m_Image = vgui.Create("DEXRotatedImage", self)//创建DEXRotatedImage
	self.m_Image:SetImage("icon16/check_off.png")//设置图像
	//self.m_Image:SetImage("icon16/check_off.png")
	self.m_Image.Seed = math.Rand(0, 1000)//种子.随机(0,1000)
	self.m_Image.OldPaint = self.m_Image.Paint//旧画
	self.m_Image.Paint = ImageThink//图像思考

	self.m_Counter = vgui.Create("DLabel", self)//创建DLabel
	self.m_Counter:SetFont("ZSHUDFontSmaller")//设置字体

	self:RefreshContents()//刷新内容
end

function PANEL:Paint()
	return true
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then//如果当前时间大于等于下一次刷新
		self.NextRefresh = RealTime() + 1//下一次刷新=当前时间+1
		self:RefreshContents()////刷新内容
	end
end

function PANEL:SetTeam(teamid)//设置队伍
	self.m_Team = teamid//队伍
	self.m_Counter:SetTextColor(team.GetColor(teamid))//设置文本颜色
end

function PANEL:SetImage(mat)//设置图像
	self.m_Image:SetImage(mat)//设置图像

	self:InvalidateLayout()//重新布局
end

function PANEL:PerformLayout()//布局
	self.m_Image:SetSize(self:GetSize())//设置大小
	self.m_Counter:AlignBottom()//对齐底部
	self.m_Counter:AlignRight()//对齐右边
end

function PANEL:RefreshContents()//刷新内容
	local numplayers = team.NumPlayers(self.m_Team)//队伍玩家数量
	self.m_PrevPlayers = self.m_PrevPlayers or numplayers//上一个玩家数量

	self.m_Counter:SetText(numplayers)//设置文本
	self.m_Counter:SizeToContents()//大小到内容

	if self.m_PrevPlayers ~= numplayers then
		self.m_Counter:Stop()
		self.m_Counter:SetColor(numplayers > self.m_PrevPlayers and color_white or COLOR_RED)
		self.m_Counter:ColorTo(team.GetColor(self.m_Team), 2)

		self.m_PrevPlayers = numplayers
	end

	self:InvalidateLayout()
end

vgui.Register("DTeamCounter", PANEL, "DPanel")
