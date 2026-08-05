-- ============================================================================
-- DPingMeter - Ping 值显示组件
-- 以柱状条形式可视化显示玩家的网络延迟（Ping值）
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] Ping 柱状图
-- [位置] Paint()
-- [作用] 按 Ping 值绘制绿→黄→红渐变柱状条与数值
-- [常改] 柱状条数量、颜色、理想/最大 Ping 阈值
--
-- [区域] 数据刷新
-- [位置] Think() / RefreshContents()
-- [作用] 定时读取玩家 Ping 值
-- [常改] 刷新间隔、数据来源
--
-- [区域] 目标玩家/数值存取
-- [位置] SetPlayer() / GetPlayer() / SetPing() / GetPing()
-- [作用] 设置要显示 Ping 的玩家并读写数值
-- [常改] 存取方式
-- ============================================================================

local PANEL = {}

-- 理想 Ping 值（低于此值显示全绿）
PANEL.IdealPing = 50
-- 最大 Ping 值（超过此值显示全红）
PANEL.MaxPing = 400
-- 刷新间隔（秒）
PANEL.RefreshTime = 1
-- Ping 柱状条数量
PANEL.PingBars = 5

-- 目标玩家
PANEL.m_Player = NULL
-- 当前 Ping 值
PANEL.m_Ping = 0
-- 下次刷新时间
PANEL.NextRefresh = 0

-- ============================================================================
-- Init - 初始化
-- ============================================================================
function PANEL:Init()
end

-- Ping 柱状条颜色（初始黄色）
local colPing = Color(255, 255, 60, 255)

-- ============================================================================
-- Paint - 绘制 Ping 柱状图
-- 根据 Ping 值动态改变颜色（绿→黄→红）
-- ============================================================================
function PANEL:Paint()
	local ping = self:GetPing()
	local pingmul = 1 - math.Clamp((ping - self.IdealPing) / self.MaxPing, 0, 1)
	local wid, hei = self:GetWide(), self:GetTall()
	local pingbars = math.max(1, self.PingBars)
	local barwidth = math.floor(wid / pingbars)
	local baseheight = math.floor(hei / pingbars)

	-- 根据 Ping 比例计算颜色（低Ping绿色，高Ping红色）
	colPing.r = (1 - pingmul) * 255
	colPing.g = pingmul * 255

	-- 绘制每一根柱状条
	for i=1, pingbars do
		local barheight = math.floor(baseheight * i)
		local x, y = (i - 1) * barwidth, hei - barheight

		surface.SetDrawColor(20, 20, 20, 255)
		surface.DrawRect(x, y, barwidth, barheight)

		-- 如果 Ping 比例足够高，填充对应柱状条颜色
		if i == 1 or pingmul >= i / pingbars then
			surface.SetDrawColor(colPing)
			surface.DrawRect(x, y, barwidth, barheight)
		end

		surface.SetDrawColor(80, 80, 80, 255)
		surface.DrawOutlinedRect(x, y, barwidth, barheight)
	end

	draw.SimpleText(ping, "ZSScoreBoardPing", 0, 0, colPing)

	return true
end

-- ============================================================================
-- RefreshContents - 刷新 Ping 数据
-- ============================================================================
function PANEL:RefreshContents()
	local pl = self:GetPlayer()
	if pl:IsValid() then
		self:SetPing(pl:Ping())
	else
		self:SetPing(0)
	end
end

-- ============================================================================
-- Think - 定时刷新 Ping 显示
-- ============================================================================
function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshContents()
	end
end

-- ============================================================================
-- SetPlayer - 设置要显示 Ping 的玩家
-- ============================================================================
function PANEL:SetPlayer(pl)
	self.m_Player = pl or NULL
	self:RefreshContents()
end

-- ============================================================================
-- GetPlayer - 获取当前显示 Ping 的玩家
-- ============================================================================
function PANEL:GetPlayer()
	return self.m_Player
end

-- ============================================================================
-- SetPing - 设置 Ping 值
-- ============================================================================
function PANEL:SetPing(ping)
	self.m_Ping = ping
end

-- ============================================================================
-- GetPing - 获取当前 Ping 值
-- ============================================================================
function PANEL:GetPing()
	return self.m_Ping
end

vgui.Register("DPingMeter", PANEL, "Panel")
