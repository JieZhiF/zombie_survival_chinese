-- ============================================================
-- cl_scoreboard.lua - 计分板系统
-- 负责创建和管理游戏内的计分板用户界面，包括：
--   1. 玩家列表显示（按队伍分组）
--   2. 玩家信息（头像、名字、分数、延迟、转生等级、僵尸职业图标）
--   3. 静音/好友功能
--   4. 鼠标悬停时弹出的玩家详细信息卡片
--   5. 机器人的随机头像分配与缓存
-- ============================================================

-- 计分板主面板的全局引用
local ScoreBoard

-- 显示计分板：启用鼠标点击，创建面板，设置大小位置，淡入动画
function GM:ScoreboardShow() --面板显示
	gui.EnableScreenClicker(true) --启用光标移动
	PlayMenuOpenSound()

	if not ScoreBoard then
		ScoreBoard = vgui.Create("ZSScoreBoard")
	end

	local screenscale = BetterScreenScale()

	ScoreBoard:SetSize(math.min(974, ScrW() * 0.65) * math.max(1, screenscale), ScrH() * 0.85)
	ScoreBoard:AlignTop(ScrH() * 0.05)
	ScoreBoard:CenterHorizontal()
	ScoreBoard:SetAlpha(0)
	ScoreBoard:AlphaTo(255, 0.15, 0) --设置透明度（目前透明度，转化时间，延迟）
	ScoreBoard:SetVisible(true)
end

-- 重建计分板：先隐藏然后销毁面板引用
function GM:ScoreboardRebuild()
	self:ScoreboardHide()
	ScoreBoard = nil
end

-- 隐藏计分板：关闭鼠标点击，播放关闭音效，隐藏面板
function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)

	if ScoreBoard then
		PlayMenuCloseSound()
		ScoreBoard:SetVisible(false)
	end
end

-- ============================================================
-- 机器人头像缓存系统
-- 搜索 materials/botavatar/ 下的 .vmt 文件，随机分配头像。
-- ============================================================
local botAvatarList = nil

-- 获取一个随机的机器人头像材质路径
-- 返回值：材质路径字符串（如 "botavatar/bot_default"）
local function GetRandomBotAvatar()
    -- 如果缓存列表为空，则搜索文件系统
	if not botAvatarList then
        -- 搜索 .vmt 材质文件（GMod UI 可识别的格式）
        -- "GAME" 表示在游戏主目录和所有插件中搜索
		local files, _ = file.Find("materials/botavatar/*.vmt", "GAME", "sorted")
		
        -- 如果找到了文件，填充缓存列表
		if files and #files > 0 then
			botAvatarList = {} -- 创建新列表
			for _, vmtFile in ipairs(files) do
                -- SetImage 使用相对于 materials 文件夹且不带扩展名的路径
                -- 例如 materials/botavatar/bot1.vmt -> "botavatar/bot1"
				table.insert(botAvatarList, "botavatar/" .. string.gsub(vmtFile, ".vmt", ""))
			end
		else
            -- 未找到文件时打印错误并返回默认头像
			print("[BotAvatars] Error: No .vmt files found in materials/botavatar/. Using default.")
			return "botavatar/odoko" -- 默认头像兜底
		end
	end
    
    -- 从有效列表中随机返回一个头像路径
	if botAvatarList and #botAvatarList > 0 then
		return botAvatarList[math.random(1, #botAvatarList)]
	end

    -- 最终保险：返回默认头像
	return "botavatar/odoko"
end

-- ============================================================
-- ZSScoreBoard - 计分板主面板
-- 包含标题、服务器名、作者信息、队伍标题、分数列、两列可滚动的玩家列表（人类/僵尸）
-- ============================================================
local PANEL = {}

-- 刷新间隔（秒）
PANEL.RefreshTime = 1
-- 下次刷新时间戳
PANEL.NextRefresh = 0
-- 最大滚动值
PANEL.m_MaximumScroll = 0

-- 内部函数：为标签绘制字体模糊效果
local function BlurPaint(self)
	draw.SimpleTextBlur(self:GetValue(), self.Font, 0, 0, self:GetTextColor())

	return true
end

-- 初始化计分板面板的所有静态 UI 元素
function PANEL:Init()
	self.NextRefresh = RealTime() + 0.1

	-- 游戏模式名称标签
	self.m_TitleLabel = vgui.Create("DLabel", self) --游戏模式名字
	self.m_TitleLabel.Font = "ZSScoreBoardTitle"
	self.m_TitleLabel:SetFont(self.m_TitleLabel.Font)
	self.m_TitleLabel:SetText(GAMEMODE.Name)
	self.m_TitleLabel:SetTextColor(COLOR_GRAY)
	self.m_TitleLabel:SizeToContents()
	self.m_TitleLabel:NoClipping(true)
	self.m_TitleLabel.Paint = BlurPaint

	-- 服务器名称标签
	self.m_ServerNameLabel = vgui.Create("DLabel", self) --服务器名字
	self.m_ServerNameLabel.Font = "ZSScoreBoardSubTitle"
	self.m_ServerNameLabel:SetFont(self.m_ServerNameLabel.Font)
	self.m_ServerNameLabel:SetText(GetHostName())
	self.m_ServerNameLabel:SetTextColor(COLOR_GRAY)
	self.m_ServerNameLabel:SizeToContents()
	self.m_ServerNameLabel:NoClipping(true)
	self.m_ServerNameLabel.Paint = BlurPaint

	-- 作者和联系方式标签
	self.m_AuthorLabel = EasyLabel(self, "by "..GAMEMODE.Author.." ("..GAMEMODE.Email..")", "ZSScoreBoardPing", COLOR_GRAY) --作者
	self.m_ContactLabel = EasyLabel(self, GAMEMODE.Website, "ZSScoreBoardPing", COLOR_GRAY) --联系方式

	-- 人类队伍标题头
	self.m_HumanHeading = vgui.Create("DTeamHeading", self)
	self.m_HumanHeading:SetTeam(TEAM_HUMAN)

	-- 僵尸队伍标题头
	self.m_ZombieHeading = vgui.Create("DTeamHeading", self)
	self.m_ZombieHeading:SetTeam(TEAM_UNDEAD)

	-- 人类队伍的列标题：分数和转生等级
	self.m_PointsLabel = EasyLabel(self, "Score", "ZSScoreBoardPlayer", COLOR_GRAY)
	self.m_RemortCLabel = EasyLabel(self, "R.LVL", "ZSScoreBoardPlayer", COLOR_GRAY)

	-- 僵尸队伍的列标题：吃掉的大脑数和转生等级
	self.m_BrainsLabel = EasyLabel(self, "Brains", "ZSScoreBoardPlayer", COLOR_GRAY)
	self.m_RemortCZLabel = EasyLabel(self, "R.LVL", "ZSScoreBoardPlayer", COLOR_GRAY)

	-- 僵尸列表滚动面板
	self.ZombieList = vgui.Create("DScrollPanel", self) --僵尸列表
	self.ZombieList.Team = TEAM_UNDEAD

	-- 人类列表滚动面板
	self.HumanList = vgui.Create("DScrollPanel", self) --人类列表
	self.HumanList.Team = TEAM_HUMAN

	self:InvalidateLayout() --触发重新布局
end

-- 定义计分板内各 UI 元素的位置和大小
function PANEL:PerformLayout()
	local screenscale = math.max(0.95, BetterScreenScale())

	self.m_AuthorLabel:MoveBelow(self.m_TitleLabel)
	self.m_ContactLabel:MoveBelow(self.m_AuthorLabel)

	self.m_ServerNameLabel:SetPos(math.min(self:GetWide() - self.m_ServerNameLabel:GetWide(), self:GetWide() * 0.75 - self.m_ServerNameLabel:GetWide() * 0.5), 32 - self.m_ServerNameLabel:GetTall() / 2)

	-- 人类队伍标题头
	self.m_HumanHeading:SetSize(self:GetWide() / 2 - 32, 28 * screenscale)
	self.m_HumanHeading:SetPos(self:GetWide() * 0.25 - self.m_HumanHeading:GetWide() * 0.5, 110 * screenscale - self.m_HumanHeading:GetTall())

	-- 僵尸队伍标题头
	self.m_ZombieHeading:SetSize(self:GetWide() / 2 - 32, 28 * screenscale)
	self.m_ZombieHeading:SetPos(self:GetWide() * 0.75 - self.m_ZombieHeading:GetWide() * 0.5, 110 * screenscale - self.m_ZombieHeading:GetTall())

	-- 人类分数列标签
	self.m_PointsLabel:SizeToContents()
	self.m_PointsLabel:SetPos((self:GetWide() / 2 - 24) * 0.6 - self.m_PointsLabel:GetWide() * 0.35, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_PointsLabel:MoveBelow(self.m_HumanHeading, 1 * screenscale)

	-- 人类转生等级列标签
	self.m_RemortCLabel:SizeToContents()
	self.m_RemortCLabel:SetPos((self:GetWide() / 2 - 24) * 0.71 - self.m_RemortCLabel:GetWide() * 0.5, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_RemortCLabel:MoveBelow(self.m_HumanHeading, 1 * screenscale)

	-- 僵尸大脑数列标签
	self.m_BrainsLabel:SizeToContents()
	self.m_BrainsLabel:SetPos(self:GetWide() / 2 + 3 * screenscale + (self:GetWide() / 2 - 24) * 0.61 - self.m_BrainsLabel:GetWide() * 0.35, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_BrainsLabel:MoveBelow(self.m_ZombieHeading, 1 * screenscale)

	-- 僵尸转生等级列标签
	self.m_RemortCZLabel:SizeToContents()
	self.m_RemortCZLabel:SetPos(self:GetWide() / 2 + 3 * screenscale + (self:GetWide() / 2 - 24) * 0.71 - self.m_RemortCZLabel:GetWide() * 0.5, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_RemortCZLabel:MoveBelow(self.m_ZombieHeading, 1 * screenscale)

	-- 人类列表滚动面板
	self.HumanList:SetSize(self:GetWide() / 2 - 24, self:GetTall() - 150 * screenscale)
	self.HumanList:AlignBottom(16 * screenscale)
	self.HumanList:AlignLeft(8 * screenscale)

	-- 僵尸列表滚动面板
	self.ZombieList:SetSize(self:GetWide() / 2 - 24, self:GetTall() - 150 * screenscale)
	self.ZombieList:AlignBottom(16 * screenscale)
	self.ZombieList:AlignRight(8 * screenscale)
end

-- 定时器：周期刷新计分板内容
function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshScoreboard()
	end
end

-- 缓存的纹理 ID（用于绘制背景装饰）
local texRightEdge = surface.GetTextureID("gui/gradient")
local texCorner = surface.GetTextureID("zombiesurvival/circlegradient")
local texDownEdge = surface.GetTextureID("gui/gradient_down")

-- 绘制计分板的自定义背景和装饰性边框
function PANEL:Paint() --这个绘制的是背景
	local wid, hei = self:GetSize()
	local barw = 64

	surface.SetDrawColor(5, 5, 5, 180)--(5,5,5,180) --背景板
	surface.DrawRect(0, 64, wid, hei - 64)
	surface.SetDrawColor(90, 90, 90, 180)
	surface.DrawOutlinedRect(0, 64, wid, hei - 64)

	-- 顶部标题栏
	surface.SetDrawColor(5, 5, 5, 220)
	PaintGenericFrame(self, 0, 0, wid, 64, 32)

	-- 中间分割线及渐变装饰
	surface.SetDrawColor(5, 5, 5, 160)
	surface.DrawRect(wid * 0.5 - 16, 64, 32, hei - 128)
	surface.SetTexture(texRightEdge)
	surface.DrawTexturedRect(wid * 0.5 + 16, 64, barw, hei - 128)
	surface.DrawTexturedRectRotated(wid * 0.5 - 16 - barw / 2, 64 + (hei - 128) / 2, barw, hei - 128, 180)
	surface.SetTexture(texCorner)
	surface.DrawTexturedRectRotated(wid * 0.5 - 16 - barw / 2, hei - 32, barw, 64, 90)
	surface.DrawTexturedRectRotated(wid * 0.5 + 16 + barw / 2, hei - 32, barw, 64, 180)
	surface.SetTexture(texDownEdge)
	surface.DrawTexturedRect(wid * 0.5 - 16, hei - 64, 32, 64)
end

-- 根据玩家实体查找其对应的玩家行面板
function PANEL:GetPlayerPanel(pl)
	for _, panel in pairs(self.PlayerPanels) do
		if panel:IsValid() and panel:GetPlayer() == pl then
			return panel
		end
	end
end

-- 为指定玩家创建一个新的玩家行面板，并添加到对应的队伍列表中
function PANEL:CreatePlayerPanel(pl)
	local curpan = self:GetPlayerPanel(pl)
	if curpan and curpan:IsValid() then return curpan end

	if pl:Team() == TEAM_SPECTATOR then return end

	local panel = vgui.Create("ZSPlayerPanel", pl:Team() == TEAM_UNDEAD and self.ZombieList or self.HumanList)
	panel:SetPlayer(pl)
	panel:Dock(TOP)
	panel:DockMargin(8, 2, 8, 2)

	self.PlayerPanels[pl] = panel

	return panel
end

-- 核心刷新函数：同步游戏内玩家列表到 UI 上，添加新玩家并移除已断开玩家
function PANEL:RefreshScoreboard()
	self.m_ServerNameLabel:SetText(GetHostName())
	self.m_ServerNameLabel:SizeToContents()
	self.m_ServerNameLabel:SetPos(math.min(self:GetWide() - self.m_ServerNameLabel:GetWide(), self:GetWide() * 0.75 - self.m_ServerNameLabel:GetWide() * 0.5), 32 - self.m_ServerNameLabel:GetTall() / 2)

	if self.PlayerPanels == nil then self.PlayerPanels = {} end

	-- 移除无效或已转为观察者的玩家
	for pl, panel in pairs(self.PlayerPanels) do
		if not panel:IsValid() or pl:IsValid() and pl:IsSpectator() then
			self:RemovePlayerPanel(panel)
		end
	end

	-- 为所有活跃玩家创建或更新面板
	for _, pl in pairs(player.GetAllActive()) do
		self:CreatePlayerPanel(pl)
	end
end

-- 从 UI 中移除指定的玩家行面板
function PANEL:RemovePlayerPanel(panel)
	if panel:IsValid() then
		self.PlayerPanels[panel:GetPlayer()] = nil
		panel:Remove()
	end
end

-- 注册 ZSScoreBoard 面板类（继承自 Panel）
vgui.Register("ZSScoreBoard", PANEL, "Panel")

-- ============================================================
-- ZSPlayerPanel - 单个玩家行面板
-- 显示玩家头像、名字、分数、延迟、转生等级、僵尸职业图标、
-- 静音按钮和好友按钮。鼠标悬停时弹出详细信息卡片。
-- ============================================================
PANEL = {}

-- 刷新间隔（秒）
PANEL.RefreshTime = 1

-- 关联的玩家实体
PANEL.m_Player = NULL
-- 下次刷新时间戳
PANEL.NextRefresh = 0

-- 静音按钮的点击回调：切换静音状态
local function MuteDoClick(self)
	local pl = self:GetParent():GetPlayer()
	if pl:IsValid() then
		pl:SetMuted(not pl:IsMuted())
		self:GetParent().NextRefresh = RealTime()
	end
end

-- 好友系统全局表
GM.ZSFriends = {}

-- 好友按钮点击回调：添加/移除好友
local function ToggleZSFriend(self)
	if MySelf.LastFriendAdd and MySelf.LastFriendAdd + 2 > CurTime() then return end

	local pl = self:GetParent():GetPlayer()
	if pl:IsValid() then
		if GAMEMODE.ZSFriends[pl:SteamID()] then
			GAMEMODE.ZSFriends[pl:SteamID()] = nil
		else
			GAMEMODE.ZSFriends[pl:SteamID()] = true
		end

		self:GetParent().NextRefresh = RealTime()

		net.Start(NET_MSG.ZSFRIEND)
			net.WriteString(pl:SteamID())
			net.WriteBool(GAMEMODE.ZSFriends[pl:SteamID()])
		net.SendToServer()

		MySelf.LastFriendAdd = CurTime()
	end
end

-- 接收服务器确认的好友添加结果
net.Receive(NET_MSG.ZSFRIENDADDED, function()
	local pl = net:ReadEntity()
	pl.ZSFriendAdded = net:ReadBool()
end)

-- 头像按钮点击回调：打开玩家的 Steam 资料页
local function AvatarDoClick(self)
	local pl = self.PlayerPanel:GetPlayer()
	if pl:IsValidPlayer() then
		pl:ShowProfile()
	end
end

-- 空绘制函数（用于透明按钮）
local function empty() end

-- 初始化玩家行面板的所有 UI 元素
function PANEL:Init()
	local screenscale = math.max(0.95, BetterScreenScale())
	self:SetTall(32 * screenscale)

	-- 头像按钮（点击打开 Steam 资料）
	self.m_AvatarButton = self:Add("DButton", self)
	self.m_AvatarButton:SetText(" ")
	self.m_AvatarButton:SetSize(32 * screenscale, 32 * screenscale)
	self.m_AvatarButton:Center()
	self.m_AvatarButton.DoClick = AvatarDoClick
	self.m_AvatarButton.Paint = empty
	self.m_AvatarButton.PlayerPanel = self

	-- 真人头像（AvatarImage）
	self.m_Avatar = vgui.Create("AvatarImage", self.m_AvatarButton)
	self.m_Avatar:SetSize(32 * screenscale, 32 * screenscale)
	self.m_Avatar:SetVisible(false)
	self.m_Avatar:SetMouseInputEnabled(false)

	-- 机器人头像（DImage）
	self.m_BotAvatar = vgui.Create("DImage", self.m_AvatarButton)
	self.m_BotAvatar:SetSize(32 * screenscale, 32 * screenscale)
	self.m_BotAvatar:SetVisible(false)
	self.m_BotAvatar:SetMouseInputEnabled(false)

	-- 特殊人物标记图标
	self.m_SpecialImage = vgui.Create("DImage", self)
	self.m_SpecialImage:SetSize(16, 16)
	self.m_SpecialImage:SetMouseInputEnabled(true)
	self.m_SpecialImage:SetVisible(false)

	-- AFK 标记（长时间未移动时显示，类似特殊身份图标）
	self.m_AFK = EasyLabel(self, " ", "ZSScoreBoardPlayerSmall", COLOR_RED)
	self.m_AFK:SetVisible(false)

	-- 僵尸职业图标
	self.m_ClassImage = vgui.Create("DImage", self)
	self.m_ClassImage:SetSize(22 * screenscale, 22 * screenscale)
	self.m_ClassImage:SetMouseInputEnabled(false)
	self.m_ClassImage:SetVisible(false)

	-- 玩家名字、分数、转生等级标签
	self.m_PlayerLabel = EasyLabel(self, " ", "ZSScoreBoardPlayer", COLOR_WHITE)
	self.m_ScoreLabel = EasyLabel(self, " ", "ZSScoreBoardPlayerSmall", COLOR_WHITE)
	self.m_RemortLabel = EasyLabel(self, " ", "ZSScoreBoardPlayerSmaller", COLOR_WHITE)

	-- 延迟指示器
	self.m_PingMeter = vgui.Create("DPingMeter", self)
	self.m_PingMeter.PingBars = 5

	-- 静音按钮
	self.m_Mute = vgui.Create("DImageButton", self)
	self.m_Mute.DoClick = MuteDoClick

	-- 好友按钮
	self.m_Friend = vgui.Create("DImageButton", self)
	self.m_Friend.DoClick = ToggleZSFriend

end

-- 临时颜色变量（用于绘制背景）
local colTemp = Color(255, 255, 255, 200)

-- 绘制玩家行背景色（根据队伍颜色、悬停状态和个人高亮）
function PANEL:Paint()
	local col = color_black_alpha220
	local mul = 0.5
	local pl = self:GetPlayer()
	if pl:IsValid() then
		col = team.GetColor(pl:Team())

		if self.m_Flash then
			mul = 0.6 + math.abs(math.sin(RealTime() * 2)) * 0.4
		elseif pl == MySelf then
			mul = 0.8
		end
	end

	if self.Hovered then
		mul = math.min(1, mul * 1.5)
	end

	colTemp.r = col.r * mul
	colTemp.g = col.g * mul
	colTemp.b = col.b * mul
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), colTemp)
	
	return true
end

-- 玩家行点击回调：触发 ClickedPlayerButton 游戏模式回调
function PANEL:DoClick()
	local pl = self:GetPlayer()
	if pl:IsValid() then
		gamemode.Call("ClickedPlayerButton", pl, self)
	end
end

-- 鼠标光标进入玩家行时：显示玩家信息悬停卡片
function PANEL:OnCursorEntered()
    if not IsValid(PlayerHoverCard) then return end
    
    PlayerHoverCard:ShowAndUpdate(self)
end

-- 排列玩家行内部各元素的位置
function PANEL:PerformLayout()
	self.m_AvatarButton:AlignLeft(16)
	self.m_AvatarButton:CenterVertical()

	self.m_PlayerLabel:SizeToContents()
	self.m_PlayerLabel:MoveRightOf(self.m_AvatarButton, 4)
	self.m_PlayerLabel:CenterVertical()

	self.m_AFK:SizeToContents()
	self.m_AFK:MoveRightOf(self.m_PlayerLabel, 6)
	self.m_AFK:CenterVertical()

	self.m_ScoreLabel:SizeToContents()
	self.m_ScoreLabel:SetPos(self:GetWide() * 0.6 - self.m_ScoreLabel:GetWide() / 2, 0)
	self.m_ScoreLabel:CenterVertical()

	self.m_SpecialImage:CenterVertical()

	self.m_ClassImage:SetSize(self:GetTall(), self:GetTall())
	self.m_ClassImage:SetPos(self:GetWide() * 0.75 - self.m_ClassImage:GetWide() * 0.5, 0)
	self.m_ClassImage:CenterVertical()

	local pingsize = self:GetTall() - 4

	self.m_PingMeter:SetSize(pingsize, pingsize)
	self.m_PingMeter:AlignRight(8)
	self.m_PingMeter:CenterVertical()

	self.m_Mute:SetSize(16, 16)
	self.m_Mute:MoveLeftOf(self.m_PingMeter, 8)
	self.m_Mute:CenterVertical()

	self.m_Friend:SetSize(16, 16)
	self.m_Friend:MoveLeftOf(self.m_Mute, 8)
	self.m_Friend:CenterVertical()

	self.m_RemortLabel:SizeToContents()
	self.m_RemortLabel:MoveLeftOf(self.m_ClassImage, 2)
	self.m_RemortLabel:CenterVertical()

	-- 确保全局名片面板存在
    if not IsValid(PlayerHoverCard) then
        PlayerHoverCard = vgui.Create("ZSPlayerHoverCard")
    end
	
end

-- 用最新的玩家数据更新 UI 显示
function PANEL:RefreshPlayer()
	local pl = self:GetPlayer()
	if not pl:IsValid() then
		self:Remove()
		return
	end

	-- 更新玩家名称（超过23字符则截断）
	local name = pl:Name()
	if #name > 23 then
		name = string.sub(name, 1, 21)..".."
	end
	self.m_PlayerLabel:SetText(name)
	self.m_PlayerLabel:SetAlpha(240)

	-- AFK 状态显示
	if pl.ZSAFK then
		self.m_AFK:SetText(translate.Get("afk_tab_label"))
		self.m_AFK:SetVisible(true)
	else
		self.m_AFK:SetVisible(false)
	end

	-- 更新分数
	self.m_ScoreLabel:SetText(pl:Frags())
	self.m_ScoreLabel:SetAlpha(240)

	-- 更新转生等级（0 时不显示）
	local rlvl = pl:GetZSRemortLevel()
	self.m_RemortLabel:SetText(rlvl > 0 and rlvl or "")

	-- 根据转生等级计算颜色（每40级一个循环，每4级一种颜色）
	local rlvlmod = math.floor((rlvl % 40) / 4)
	local hcolor, hlvl = COLOR_GRAY, 0
	for rlvlr, rcolor in pairs(GAMEMODE.RemortColors) do
		if rlvlmod >= rlvlr and rlvlr >= hlvl then
			hlvl = rlvlr
			hcolor = rcolor
		end
	end
	self.m_RemortLabel:SetColor(hcolor)
	self.m_RemortLabel:SetAlpha(240)

	-- 显示僵尸职业图标（仅僵尸队伍看僵尸）
	if MySelf:Team() == TEAM_UNDEAD and pl:Team() == TEAM_UNDEAD and pl:GetZombieClassTable().Icon then
		self.m_ClassImage:SetVisible(true)
		self.m_ClassImage:SetImage(pl:GetZombieClassTable().Icon)
		self.m_ClassImage:SetImageColor(pl:GetZombieClassTable().IconColor or color_white)
	else
		self.m_ClassImage:SetVisible(false)
	end

	-- 更新静音和好友按钮状态（不显示自己的按钮）
	if pl == MySelf then
		self.m_Mute:SetVisible(false)
		self.m_Friend:SetVisible(false)
	else
		if pl:IsMuted() then
			self.m_Mute:SetImage("icon16/sound_mute.png")
		else
			self.m_Mute:SetImage("icon16/sound.png")
		end

		self.m_Friend:SetColor(pl.ZSFriendAdded and COLOR_LIMEGREEN or COLOR_GRAY)
		self.m_Friend:SetImage(GAMEMODE.ZSFriends[pl:SteamID()] and "icon16/heart_delete.png" or "icon16/heart.png")
	end

	-- 按分数排序（Z-Pos 越大越靠上）
	self:SetZPos(-pl:Frags())

	-- 如果玩家更换了队伍，移动到对应的列表
	if pl:Team() ~= self._LastTeam then
		self._LastTeam = pl:Team()
		self:SetParent(self._LastTeam == TEAM_HUMAN and ScoreBoard.HumanList or ScoreBoard.ZombieList)
	end

	self:InvalidateLayout()
end

-- 定时器：周期刷新玩家信息
function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshPlayer()
	end
end

-- 关联玩家实体到该面板，设置头像和队伍相关显示
function PANEL:SetPlayer(pl)
	self.m_Player = pl or NULL
    self.m_BotAvatarMaterial = nil -- 默认先清空机器人头像材质

	if not IsValid(pl) then return end

	if pl:IsBot() then
		self.m_Avatar:SetVisible(false)
		self.m_SpecialImage:SetVisible(false)

		-- 调用函数获取随机头像，并将其路径保存在面板变量中
		local randomAvatarMaterial = GetRandomBotAvatar()
		self.m_BotAvatarMaterial = randomAvatarMaterial -- 保存材质路径
		self.m_BotAvatar:SetImage(self.m_BotAvatarMaterial) -- 设置图片
		self.m_BotAvatar:SetVisible(true)
	else
		self.m_BotAvatar:SetVisible(false)
		self.m_Avatar:SetPlayer(pl, 64)
		self.m_Avatar:SetVisible(true)

		-- 检查是否为特殊人物（如开发者、捐赠者等）
		if gamemode.Call("IsSpecialPerson", pl, self.m_SpecialImage) then
			self.m_SpecialImage:SetVisible(true)
		else
			self.m_SpecialImage:SetTooltip()
			self.m_SpecialImage:SetVisible(false)
		end

		self.m_Flash = pl:SteamID() == LocalPlayer():SteamID()
	end

	self.m_PingMeter:SetPlayer(pl)
	self:RefreshPlayer()
end

-- 获取与该面板关联的玩家实体
function PANEL:GetPlayer()
	return self.m_Player
end

-- 获取该面板的机器人头像材质路径（供悬停卡片使用）
function PANEL:GetBotAvatarMaterial()
    return self.m_BotAvatarMaterial
end

-- 注册 ZSPlayerPanel 面板类（继承自 Button）
vgui.Register("ZSPlayerPanel", PANEL, "Button")

-- ============================================================
-- ZSPlayerHoverCard - 玩家信息悬停卡片
-- 当鼠标悬停在玩家行上时弹出，显示大头像、名字、SteamID、分数
-- ============================================================
local PlayerHoverCard = nil
local PANEL = {}

-- 初始化悬停卡片的所有 UI 元素
function PANEL:Init()
    self:SetSize(320, 100)
    self:SetPaintBackground(false)
    self:SetVisible(false)
    self:MakePopup()
    
    self.bIsThinking = false 
    self.SourcePanel = nil

    -- 大头像（真人）
    self.PlayerAvatar = vgui.Create("AvatarImage", self)
    self.PlayerAvatar:SetSize(64, 64)

    -- 大头像（机器人）
    self.BotAvatar = vgui.Create("DImage", self)
    self.BotAvatar:SetSize(64, 64)

    -- 玩家名字标签
    self.NameLabel = self:Add("DLabel")
    self.NameLabel:SetFont("ZS2DFontHarmonySmall")
    self.NameLabel:SetColor(COLOR_WHITE)

    -- SteamID 或"机器人"标签
    self.SteamIDLabel = self:Add("DLabel")
    self.SteamIDLabel:SetFont("ZS2DFontHarmonySmall")
    self.SteamIDLabel:SetColor(Color(200, 200, 200))
    
    -- 分数标签
    self.ScoreLabel = self:Add("DLabel")
    self.ScoreLabel:SetFont("ZS2DFontHarmonySmall")
    self.ScoreLabel:SetColor(Color(200, 200, 200))
end

-- 绘制悬停卡片的半透明背景和边框
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
    surface.SetDrawColor(Color(100, 100, 100, 150))
    surface.DrawOutlinedRect(0, 0, w, h)
end

-- 排列悬停卡片内部各元素的位置
function PANEL:PerformLayout()
    self.PlayerAvatar:SetPos(10, 10)
    self.BotAvatar:SetPos(10, 10)

    self.NameLabel:SizeToContents()
    self.NameLabel:SetPos(80, 15)
    self.SteamIDLabel:SizeToContents()
    self.SteamIDLabel:SetPos(80, 35)
    self.ScoreLabel:SizeToContents()
    self.ScoreLabel:SetPos(80, 55)
end

-- 使用玩家数据更新卡片显示（支持真人玩家和机器人）
function PANEL:UpdateWithPlayer(ply, botAvatarMaterial)
    if not IsValid(ply) then return end

    self.NameLabel:SetText(ply:Name())
    self.ScoreLabel:SetText("分数 " .. ply:Frags())

    if ply:IsBot() then
        self.PlayerAvatar:SetVisible(false)
        self.BotAvatar:SetVisible(true)
		-- 使用传递进来的 botAvatarMaterial 参数设置图片
        self.BotAvatar:SetImage(botAvatarMaterial) 
        self.SteamIDLabel:SetText("机器人 (Bot)")
    else
        self.PlayerAvatar:SetVisible(true)
        self.BotAvatar:SetVisible(false)
        self.PlayerAvatar:SetPlayer(ply, 64)
        self.SteamIDLabel:SetText(ply:SteamID())
    end

    self:InvalidateLayout(true)
end

-- 显示悬停卡片并将其定位在源玩家行旁边，同时更新内容
function PANEL:ShowAndUpdate(sourcePanel)
    if not IsValid(sourcePanel) or not IsValid(sourcePanel:GetPlayer()) then 
        self:HideAndStopThinking()
        return
    end

    self.SourcePanel = sourcePanel
    
    -- 从 sourcePanel 获取玩家实体和机器人头像材质
    local player = sourcePanel:GetPlayer()
    local botAvatar = sourcePanel:GetBotAvatarMaterial() -- 调用新增的函数

    -- 将两个信息都传递给 UpdateWithPlayer
    self:UpdateWithPlayer(player, botAvatar)
    
    local x, y = sourcePanel:LocalToScreen(sourcePanel:GetWide() + 5, 0)
    self:SetPos(x, y)
    self:SetVisible(true)
    self.bIsThinking = true
end

-- 定时器：检查鼠标是否在源面板或卡片上，不在则隐藏
function PANEL:Think()
    if not self.bIsThinking then return end
    if not IsValid(self.SourcePanel) or (not self.SourcePanel:IsHovered() and not self:IsHovered()) then
        self:HideAndStopThinking()
    end
end

-- 隐藏悬停卡片并停止其 Think 逻辑
function PANEL:HideAndStopThinking()
    self:SetVisible(false)
    self.SourcePanel = nil
    self.bIsThinking = false
end

-- 鼠标离开卡片时的事件（当前为空）
function PANEL:OnCursorExited()
end

-- 注册 ZSPlayerHoverCard 面板类（继承自 DPanel）
vgui.Register("ZSPlayerHoverCard", PANEL, "DPanel")
