local PANEL = {}
//这是是用来显示玩家的ping值的
//注释状态
PANEL.IdealPing = 50//理想的ping值
PANEL.MaxPing = 400//最大的ping值
PANEL.RefreshTime = 1//刷新时间
PANEL.PingBars = 5//ping条数

PANEL.m_Player = NULL//玩家
PANEL.m_Ping = 0//玩家ping值
PANEL.NextRefresh = 0//下次刷新时间

function PANEL:Init()
end

local colPing = Color(255, 255, 60, 255)//ping值的颜色
function PANEL:Paint()
	local ping = self:GetPing()//获取ping值
	local pingmul = 1 - math.Clamp((ping - self.IdealPing) / self.MaxPing, 0, 1)//ping值的比例，这是是传入了玩家ping值减去理想的ping值除以最大的ping值，然后限制在0到1之间，然后用1减去这个值
	local wid, hei = self:GetWide(), self:GetTall()//获取宽高
	local pingbars = math.max(1, self.PingBars)//ping条数
	local barwidth = math.floor(wid / pingbars)//ping条宽度
	local baseheight = math.floor(hei / pingbars)//ping条高度

	colPing.r = (1 - pingmul) * 255//ping值的红色
	colPing.g = pingmul * 255//ping值的绿色

	for i=1, pingbars do//循环ping条数
		local barheight = math.floor(baseheight * i)//ping条高度
		local x, y = (i - 1) * barwidth, hei - barheight//ping条的x和y

		surface.SetDrawColor(20, 20, 20, 255)//设置颜色
		surface.DrawRect(x, y, barwidth, barheight)//绘制ping条

		if i == 1 or pingmul >= i / pingbars then//如果是第一条或者ping值的比例大于等于i除以ping条数
			surface.SetDrawColor(colPing)//设置颜色
			surface.DrawRect(x, y, barwidth, barheight)//绘制ping条
		end

		surface.SetDrawColor(80, 80, 80, 255)//设置颜色
		surface.DrawOutlinedRect(x, y, barwidth, barheight)
	end

	draw.SimpleText(ping, "ZSScoreBoardPing", 0, 0, colPing)

	return true
end

function PANEL:RefreshContents()//刷新内容
	local pl = self:GetPlayer()//获取玩家
	if pl:IsValid() then//如果玩家有效
		self:SetPing(pl:Ping())//设置ping值
	else
		self:SetPing(0)//设置ping值为0
	end
end

function PANEL:Think()//思考,这是是每帧都会调用的，说人话就是会刷新
	if RealTime() >= self.NextRefresh then//如果当前时间大于等于下次刷新时间
		self.NextRefresh = RealTime() + self.RefreshTime//设置下次刷新时间
		self:RefreshContents()//刷新内容
	end
end

function PANEL:SetPlayer(pl)//设置玩家
	self.m_Player = pl or NULL//设置玩家
	self:RefreshContents()//刷新内容
end

function PANEL:GetPlayer()//获取玩家
	return self.m_Player
end

function PANEL:SetPing(ping)//设置ping值
	self.m_Ping = ping
end

function PANEL:GetPing()//获取ping值
	return self.m_Ping
end

vgui.Register("DPingMeter", PANEL, "Panel")
