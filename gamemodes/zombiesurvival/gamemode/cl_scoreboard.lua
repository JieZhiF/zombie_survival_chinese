-- 本文件主要负责创建和管理游戏内的计分板（Scoreboard）用户界面。它包括显示玩家列表、队伍信息、分数，并提供了如静音玩家、查看玩家资料以及一个当鼠标悬停在玩家上时显示详细信息卡片的功能。同时，它还包含一个为机器人（Bot）随机分配并缓存头像的系统。

-- GM:ScoreboardShow 显示计分板界面。
-- GM:ScoreboardRebuild 重建计分板界面（当前仅实现隐藏）。
-- GM:ScoreboardHide 隐藏计分板界面。
-- GetRandomBotAvatar 从文件系统中查找并随机返回一个机器人头像的材质路径，以用于UI显示。
-- ZSScoreBoard VGUI面板，作为整个计分板的主容器。
-- ZSScoreBoard:Init 初始化计分板的静态元素，如标题、服务器名和队伍列表容器。
-- ZSScoreBoard:PerformLayout 定义并排列计分板内各个UI元素的位置和大小。
-- ZSScoreBoard:Think 定时器，周期性地刷新计分板内容。
-- ZSScoreBoard:Paint 绘制计分板的自定义背景和装饰性元素。
-- ZSScoreBoard:GetPlayerPanel 查找与特定玩家关联的玩家行面板。
-- ZSScoreBoard:CreatePlayerPanel 为一个新玩家创建一个专属的玩家行面板并添加到队伍列表中。
-- ZSScoreBoard:RefreshScoreboard 核心刷新函数，同步游戏内的玩家列表到UI上，添加新玩家并移除已断开的玩家。
-- ZSScoreBoard:RemovePlayerPanel 从UI中移除一个指定的玩家行面板。

-- ZSPlayerPanel VGUI面板，代表计分板中的单个玩家行。
-- ZSPlayerPanel:Init 初始化玩家行内的所有UI元素，如头像、名字、分数、静音按钮等。
-- ZSPlayerPanel:Paint 绘制玩家行的背景，颜色会根据队伍和鼠标悬停状态变化。
-- ZSPlayerPanel:DoClick 处理对玩家行的点击事件。
-- ZSPlayerPanel:OnCursorEntered 当鼠标光标进入玩家行区域时，触发显示玩家信息悬停卡。
-- ZSPlayerPanel:PerformLayout 排列玩家行内部各元素的位置。
-- ZSPlayerPanel:RefreshPlayer 用最新的玩家数据（如分数、转生等级、僵尸职业图标）更新UI显示。
-- ZSPlayerPanel:Think 定时器，周期性地调用刷新函数。
-- ZSPlayerPanel:SetPlayer 将一个玩家实体与该面板关联，并设置其头像（真人或机器人）。
-- ZSPlayerPanel:GetPlayer 获取与该面板关联的玩家实体。
-- ZSPlayerPanel:GetBotAvatarMaterial 获取分配给该机器人玩家行的特定头像材质路径。

-- ZSPlayerHoverCard VGUI面板，当鼠标悬停在玩家行上时弹出的详细信息卡。
-- ZSPlayerHoverCard:Init 初始化信息卡内的元素，如大头像、名字、SteamID等。
-- ZSPlayerHoverCard:Paint 绘制信息卡的背景。
-- ZSPlayerHoverCard:PerformLayout 排列信息卡内部各元素的位置。
-- ZSPlayerHoverCard:UpdateWithPlayer 使用特定玩家的数据填充信息卡，并能正确显示机器人的头像。
-- ZSPlayerHoverCard:ShowAndUpdate 显示信息卡，将其定位在源玩家行的旁边，并更新其内容。
-- ZSPlayerHoverCard:Think 检查鼠标是否还在源玩家行或信息卡上，如果不在则隐藏卡片。
-- ZSPlayerHoverCard:HideAndStopThinking 隐藏信息卡并停止其Think逻辑。
-- ZSPlayerHoverCard:OnCursorExited 当鼠标离开信息卡时触发的事件。
local ScoreBoard
function GM:ScoreboardShow() //面板显示
	gui.EnableScreenClicker(true) //启用光标移动
	PlayMenuOpenSound() 

	if not ScoreBoard then
		ScoreBoard = vgui.Create("ZSScoreBoard")
	end

	local screenscale = BetterScreenScale()

	ScoreBoard:SetSize(math.min(974, ScrW() * 0.65) * math.max(1, screenscale), ScrH() * 0.85)
	ScoreBoard:AlignTop(ScrH() * 0.05)
	ScoreBoard:CenterHorizontal()
	ScoreBoard:SetAlpha(0)
	ScoreBoard:AlphaTo(255, 0.15, 0) //设置透明度（目前透明度，转化时间，延迟）
	ScoreBoard:SetVisible(true)
end

function GM:ScoreboardRebuild()
	self:ScoreboardHide()
	ScoreBoard = nil
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)

	if ScoreBoard then
		PlayMenuCloseSound()
		ScoreBoard:SetVisible(false)
	end
end

--[[
    机器人头像缓存
    这个列表会缓存找到的所有机器人头像材质，以提高效率。
    在GMod中，我们应该搜索.vmt文件而不是.png文件。
]]
local botAvatarList = nil

--[[
    @function GetRandomBotAvatar
    @description 获取一个随机的机器人头像材质路径。
    @returns string 材质路径，例如 "botavatar/bot_default"
]]
local function GetRandomBotAvatar()
    -- 如果列表是空的，就搜索一次文件。
	if not botAvatarList then
        -- 搜索.vmt文件，这是GMod UI能识别的材质文件
        -- "GAME"表示在游戏主目录和所有插件中搜索。
		local files, _ = file.Find("materials/botavatar/*.vmt", "GAME", "sorted")
		
        -- 如果找到了文件，就填充列表
		if files and #files > 0 then
			botAvatarList = {} -- 创建一个新列表
			for _, vmtFile in ipairs(files) do
                -- SetImage使用的是材质路径，它相对于materials文件夹且不带扩展名。
                -- 例如, materials/botavatar/bot1.vmt -> "botavatar/bot1"
				table.insert(botAvatarList, "botavatar/" .. string.gsub(vmtFile, ".vmt", ""))
			end
		else
            -- 如果没有找到任何文件，记录一个错误并返回一个默认头像以防UI出错。
			print("[BotAvatars] Error: No .vmt files found in materials/botavatar/. Using default.")
			return "botavatar/odoko" -- 确保你有一个名为 botimage.vmt 的默认头像
		end
	end
    
    -- 从有效的列表中随机返回一个头像路径
	if botAvatarList and #botAvatarList > 0 then
		return botAvatarList[math.random(1, #botAvatarList)]
	end

    -- 最终的保险，以防万一
	return "botavatar/odoko"
end


local PANEL = {}

PANEL.RefreshTime = 1
PANEL.NextRefresh = 0
PANEL.m_MaximumScroll = 0

local function BlurPaint(self)
	draw.SimpleTextBlur(self:GetValue(), self.Font, 0, 0, self:GetTextColor())

	return true
end

function PANEL:Init()
	self.NextRefresh = RealTime() + 0.1

	self.m_TitleLabel = vgui.Create("DLabel", self) //游戏模式名字
	self.m_TitleLabel.Font = "ZSScoreBoardTitle"
	self.m_TitleLabel:SetFont(self.m_TitleLabel.Font)
	self.m_TitleLabel:SetText(GAMEMODE.Name)
	self.m_TitleLabel:SetTextColor(COLOR_GRAY)
	self.m_TitleLabel:SizeToContents()
	self.m_TitleLabel:NoClipping(true)
	self.m_TitleLabel.Paint = BlurPaint

	self.m_ServerNameLabel = vgui.Create("DLabel", self) //服务器名字
	self.m_ServerNameLabel.Font = "ZSScoreBoardSubTitle"
	self.m_ServerNameLabel:SetFont(self.m_ServerNameLabel.Font)
	self.m_ServerNameLabel:SetText(GetHostName())
	self.m_ServerNameLabel:SetTextColor(COLOR_GRAY)
	self.m_ServerNameLabel:SizeToContents()
	self.m_ServerNameLabel:NoClipping(true)
	self.m_ServerNameLabel.Paint = BlurPaint

	self.m_AuthorLabel = EasyLabel(self, "by "..GAMEMODE.Author.." ("..GAMEMODE.Email..")", "ZSScoreBoardPing", COLOR_GRAY) //作者
	self.m_ContactLabel = EasyLabel(self, GAMEMODE.Website, "ZSScoreBoardPing", COLOR_GRAY) //联系方式

	self.m_HumanHeading = vgui.Create("DTeamHeading", self)
	self.m_HumanHeading:SetTeam(TEAM_HUMAN)

	self.m_ZombieHeading = vgui.Create("DTeamHeading", self)
	self.m_ZombieHeading:SetTeam(TEAM_UNDEAD)

	self.m_PointsLabel = EasyLabel(self, "Score", "ZSScoreBoardPlayer", COLOR_GRAY)
	self.m_RemortCLabel = EasyLabel(self, "R.LVL", "ZSScoreBoardPlayer", COLOR_GRAY)

	self.m_BrainsLabel = EasyLabel(self, "Brains", "ZSScoreBoardPlayer", COLOR_GRAY)
	self.m_RemortCZLabel = EasyLabel(self, "R.LVL", "ZSScoreBoardPlayer", COLOR_GRAY)

	self.ZombieList = vgui.Create("DScrollPanel", self) //僵尸列表
	self.ZombieList.Team = TEAM_UNDEAD

	self.HumanList = vgui.Create("DScrollPanel", self) //人类列表
	self.HumanList.Team = TEAM_HUMAN

	self:InvalidateLayout() //重新布局
end

function PANEL:PerformLayout()
	local screenscale = math.max(0.95, BetterScreenScale())

	self.m_AuthorLabel:MoveBelow(self.m_TitleLabel)
	self.m_ContactLabel:MoveBelow(self.m_AuthorLabel)

	self.m_ServerNameLabel:SetPos(math.min(self:GetWide() - self.m_ServerNameLabel:GetWide(), self:GetWide() * 0.75 - self.m_ServerNameLabel:GetWide() * 0.5), 32 - self.m_ServerNameLabel:GetTall() / 2)

	self.m_HumanHeading:SetSize(self:GetWide() / 2 - 32, 28 * screenscale)
	self.m_HumanHeading:SetPos(self:GetWide() * 0.25 - self.m_HumanHeading:GetWide() * 0.5, 110 * screenscale - self.m_HumanHeading:GetTall())

	self.m_ZombieHeading:SetSize(self:GetWide() / 2 - 32, 28 * screenscale)
	self.m_ZombieHeading:SetPos(self:GetWide() * 0.75 - self.m_ZombieHeading:GetWide() * 0.5, 110 * screenscale - self.m_ZombieHeading:GetTall())

	self.m_PointsLabel:SizeToContents()
	self.m_PointsLabel:SetPos((self:GetWide() / 2 - 24) * 0.6 - self.m_PointsLabel:GetWide() * 0.35, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_PointsLabel:MoveBelow(self.m_HumanHeading, 1 * screenscale)

	self.m_RemortCLabel:SizeToContents()
	self.m_RemortCLabel:SetPos((self:GetWide() / 2 - 24) * 0.71 - self.m_RemortCLabel:GetWide() * 0.5, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_RemortCLabel:MoveBelow(self.m_HumanHeading, 1 * screenscale)

	self.m_BrainsLabel:SizeToContents()
	self.m_BrainsLabel:SetPos(self:GetWide() / 2 + 3 * screenscale + (self:GetWide() / 2 - 24) * 0.61 - self.m_BrainsLabel:GetWide() * 0.35, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_BrainsLabel:MoveBelow(self.m_ZombieHeading, 1 * screenscale)

	self.m_RemortCZLabel:SizeToContents()
	self.m_RemortCZLabel:SetPos(self:GetWide() / 2 + 3 * screenscale + (self:GetWide() / 2 - 24) * 0.71 - self.m_RemortCZLabel:GetWide() * 0.5, 110 * screenscale - self.m_HumanHeading:GetTall())
	self.m_RemortCZLabel:MoveBelow(self.m_ZombieHeading, 1 * screenscale)

	self.HumanList:SetSize(self:GetWide() / 2 - 24, self:GetTall() - 150 * screenscale)
	self.HumanList:AlignBottom(16 * screenscale)
	self.HumanList:AlignLeft(8 * screenscale)

	self.ZombieList:SetSize(self:GetWide() / 2 - 24, self:GetTall() - 150 * screenscale)
	self.ZombieList:AlignBottom(16 * screenscale)
	self.ZombieList:AlignRight(8 * screenscale)
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshScoreboard()
	end
end

local texRightEdge = surface.GetTextureID("gui/gradient")
local texCorner = surface.GetTextureID("zombiesurvival/circlegradient")
local texDownEdge = surface.GetTextureID("gui/gradient_down")
function PANEL:Paint() //这个绘制的是背景
	local wid, hei = self:GetSize()
	local barw = 64

	surface.SetDrawColor(5, 5, 5, 180)--(5,5,5,180) //背景板
	surface.DrawRect(0, 64, wid, hei - 64)
	surface.SetDrawColor(90, 90, 90, 180)
	surface.DrawOutlinedRect(0, 64, wid, hei - 64)

	surface.SetDrawColor(5, 5, 5, 220)
	PaintGenericFrame(self, 0, 0, wid, 64, 32)

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

function PANEL:GetPlayerPanel(pl)
	for _, panel in pairs(self.PlayerPanels) do
		if panel:IsValid() and panel:GetPlayer() == pl then
			return panel
		end
	end
end

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

function PANEL:RefreshScoreboard()
	self.m_ServerNameLabel:SetText(GetHostName())
	self.m_ServerNameLabel:SizeToContents()
	self.m_ServerNameLabel:SetPos(math.min(self:GetWide() - self.m_ServerNameLabel:GetWide(), self:GetWide() * 0.75 - self.m_ServerNameLabel:GetWide() * 0.5), 32 - self.m_ServerNameLabel:GetTall() / 2)

	if self.PlayerPanels == nil then self.PlayerPanels = {} end

	for pl, panel in pairs(self.PlayerPanels) do
		if not panel:IsValid() or pl:IsValid() and pl:IsSpectator() then
			self:RemovePlayerPanel(panel)
		end
	end

	for _, pl in pairs(player.GetAllActive()) do
		self:CreatePlayerPanel(pl)
	end
end

function PANEL:RemovePlayerPanel(panel)
	if panel:IsValid() then
		self.PlayerPanels[panel:GetPlayer()] = nil
		panel:Remove()
	end
end

vgui.Register("ZSScoreBoard", PANEL, "Panel")

//玩家的面板
PANEL = {}

PANEL.RefreshTime = 1

PANEL.m_Player = NULL
PANEL.NextRefresh = 0

local function MuteDoClick(self)
	local pl = self:GetParent():GetPlayer()
	if pl:IsValid() then
		pl:SetMuted(not pl:IsMuted())
		self:GetParent().NextRefresh = RealTime()
	end
end

GM.ZSFriends = {}
--[[hook.Add("Initialize", "LoadZSFriends", function()
	if file.Exists(GAMEMODE.FriendsFile, "DATA") then
		GAMEMODE.ZSFriends = Deserialize(file.Read(GAMEMODE.FriendsFile)) or {}
	end
end)]]

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

		net.Start("zs_zsfriend")
			net.WriteString(pl:SteamID())
			net.WriteBool(GAMEMODE.ZSFriends[pl:SteamID()])
		net.SendToServer()

		MySelf.LastFriendAdd = CurTime()
		--file.Write(GAMEMODE.FriendsFile, Serialize(GAMEMODE.ZSFriends))
	end
end

net.Receive("zs_zsfriendadded", function()
	local pl = net:ReadEntity()
	pl.ZSFriendAdded = net:ReadBool()
end)

local function AvatarDoClick(self)
	local pl = self.PlayerPanel:GetPlayer()
	if pl:IsValidPlayer() then
		pl:ShowProfile()
	end
end

local function empty() end

function PANEL:Init()
	local screenscale = math.max(0.95, BetterScreenScale())
	self:SetTall(32 * screenscale)

	self.m_AvatarButton = self:Add("DButton", self)
	self.m_AvatarButton:SetText(" ")
	self.m_AvatarButton:SetSize(32 * screenscale, 32 * screenscale)
	self.m_AvatarButton:Center()
	self.m_AvatarButton.DoClick = AvatarDoClick
	self.m_AvatarButton.Paint = empty
	self.m_AvatarButton.PlayerPanel = self

	self.m_Avatar = vgui.Create("AvatarImage", self.m_AvatarButton)
	self.m_Avatar:SetSize(32 * screenscale, 32 * screenscale)
	self.m_Avatar:SetVisible(false)
	self.m_Avatar:SetMouseInputEnabled(false)

	self.m_BotAvatar = vgui.Create("DImage", self.m_AvatarButton)
	self.m_BotAvatar:SetSize(32 * screenscale, 32 * screenscale)
	self.m_BotAvatar:SetVisible(false)
	self.m_BotAvatar:SetMouseInputEnabled(false)

	self.m_SpecialImage = vgui.Create("DImage", self)
	self.m_SpecialImage:SetSize(16, 16)
	self.m_SpecialImage:SetMouseInputEnabled(true)
	self.m_SpecialImage:SetVisible(false)

	self.m_ClassImage = vgui.Create("DImage", self)
	self.m_ClassImage:SetSize(22 * screenscale, 22 * screenscale)
	self.m_ClassImage:SetMouseInputEnabled(false)
	self.m_ClassImage:SetVisible(false)

	self.m_PlayerLabel = EasyLabel(self, " ", "ZSScoreBoardPlayer", COLOR_WHITE)
	self.m_ScoreLabel = EasyLabel(self, " ", "ZSScoreBoardPlayerSmall", COLOR_WHITE)
	self.m_RemortLabel = EasyLabel(self, " ", "ZSScoreBoardPlayerSmaller", COLOR_WHITE)



	self.m_PingMeter = vgui.Create("DPingMeter", self)
	self.m_PingMeter.PingBars = 5

	self.m_Mute = vgui.Create("DImageButton", self)
	self.m_Mute.DoClick = MuteDoClick

	self.m_Friend = vgui.Create("DImageButton", self)
	self.m_Friend.DoClick = ToggleZSFriend


end

local colTemp = Color(255, 255, 255, 200)
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

function PANEL:DoClick()
	local pl = self:GetPlayer()
	if pl:IsValid() then
		gamemode.Call("ClickedPlayerButton", pl, self)
	end
end

-- 用下面的代码替换你旧的 OnCursorEntered 函数
function PANEL:OnCursorEntered()
    if not IsValid(PlayerHoverCard) then return end
    
    -- 调用我们新的显示函数，将自己 (self) 作为源面板传入
    PlayerHoverCard:ShowAndUpdate(self)
end


function PANEL:PerformLayout()
	self.m_AvatarButton:AlignLeft(16)
	self.m_AvatarButton:CenterVertical()

	self.m_PlayerLabel:SizeToContents()
	self.m_PlayerLabel:MoveRightOf(self.m_AvatarButton, 4)
	self.m_PlayerLabel:CenterVertical()

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

	    -- 新增代码: 确保全局名片面板存在
    if not IsValid(PlayerHoverCard) then
        PlayerHoverCard = vgui.Create("ZSPlayerHoverCard")
    end
	
end

function PANEL:RefreshPlayer()
	local pl = self:GetPlayer()
	if not pl:IsValid() then
		self:Remove()
		return
	end

	local name = pl:Name()
	if #name > 23 then
		name = string.sub(name, 1, 21)..".."
	end
	self.m_PlayerLabel:SetText(name)
	self.m_PlayerLabel:SetAlpha(240)

	self.m_ScoreLabel:SetText(pl:Frags())
	self.m_ScoreLabel:SetAlpha(240)

	local rlvl = pl:GetZSRemortLevel()
	self.m_RemortLabel:SetText(rlvl > 0 and rlvl or "")

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

	if MySelf:Team() == TEAM_UNDEAD and pl:Team() == TEAM_UNDEAD and pl:GetZombieClassTable().Icon then
		self.m_ClassImage:SetVisible(true)
		self.m_ClassImage:SetImage(pl:GetZombieClassTable().Icon)
		self.m_ClassImage:SetImageColor(pl:GetZombieClassTable().IconColor or color_white)
	else
		self.m_ClassImage:SetVisible(false)
	end

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

	self:SetZPos(-pl:Frags())

	if pl:Team() ~= self._LastTeam then
		self._LastTeam = pl:Team()
		self:SetParent(self._LastTeam == TEAM_HUMAN and ScoreBoard.HumanList or ScoreBoard.ZombieList)
	end

	self:InvalidateLayout()
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshPlayer()
	end
end


function PANEL:SetPlayer(pl)
	self.m_Player = pl or NULL
    self.m_BotAvatarMaterial = nil -- [修改] 默认先清空机器人头像材质

	if not IsValid(pl) then return end

	if pl:IsBot() then
		self.m_Avatar:SetVisible(false)
		self.m_SpecialImage:SetVisible(false)

		-- [核心修改] 调用函数获取随机头像，并将其路径保存在面板变量中
		local randomAvatarMaterial = GetRandomBotAvatar()
		self.m_BotAvatarMaterial = randomAvatarMaterial -- 保存这个材质路径
		self.m_BotAvatar:SetImage(self.m_BotAvatarMaterial) -- 使用保存的路径设置图片
		self.m_BotAvatar:SetVisible(true)
	else
		self.m_BotAvatar:SetVisible(false)
		self.m_Avatar:SetPlayer(pl, 64)
		self.m_Avatar:SetVisible(true)

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

function PANEL:GetPlayer()
	return self.m_Player
end

-- [新增] 创建一个新的函数，让外部可以获取到机器人头像的材质
function PANEL:GetBotAvatarMaterial()
    return self.m_BotAvatarMaterial
end

vgui.Register("ZSPlayerPanel", PANEL, "Button")


local PlayerHoverCard = nil
local PANEL = {}

function PANEL:Init()
    -- ... (Init函数内容保持不变) ...
    self:SetSize(320, 100)
    self:SetPaintBackground(false)
    self:SetVisible(false)
    self:MakePopup()
    
    self.bIsThinking = false 
    self.SourcePanel = nil

    self.PlayerAvatar = vgui.Create("AvatarImage", self)
    self.PlayerAvatar:SetSize(64, 64)

    self.BotAvatar = vgui.Create("DImage", self)
    self.BotAvatar:SetSize(64, 64)

    self.NameLabel = self:Add("DLabel")
    self.NameLabel:SetFont("ZS2DFontHarmonySmall")
    self.NameLabel:SetColor(COLOR_WHITE)

    self.SteamIDLabel = self:Add("DLabel")
    self.SteamIDLabel:SetFont("ZS2DFontHarmonySmall")
    self.SteamIDLabel:SetColor(Color(200, 200, 200))
    
    self.ScoreLabel = self:Add("DLabel")
    self.ScoreLabel:SetFont("ZS2DFontHarmonySmall")
    self.ScoreLabel:SetColor(Color(200, 200, 200))
end

function PANEL:Paint(w, h)
    -- ... (Paint函数内容保持不变) ...
    draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
    surface.SetDrawColor(Color(100, 100, 100, 150))
    surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:PerformLayout()
    -- ... (PerformLayout函数内容保持不变) ...
    self.PlayerAvatar:SetPos(10, 10)
    self.BotAvatar:SetPos(10, 10)

    self.NameLabel:SizeToContents()
    self.NameLabel:SetPos(80, 15)
    self.SteamIDLabel:SizeToContents()
    self.SteamIDLabel:SetPos(80, 35)
    self.ScoreLabel:SizeToContents()
    self.ScoreLabel:SetPos(80, 55)
end


-- [核心修改] 更新函数现在可以接收机器人头像材质
function PANEL:UpdateWithPlayer(ply, botAvatarMaterial)
    if not IsValid(ply) then return end

    self.NameLabel:SetText(ply:Name())
    self.ScoreLabel:SetText("分数 " .. ply:Frags())

    if ply:IsBot() then
        self.PlayerAvatar:SetVisible(false)
        self.BotAvatar:SetVisible(true)
		-- [修改] 使用传递进来的 botAvatarMaterial 参数来设置图片
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

-- [核心修改] 在显示和更新时，同时获取玩家和机器人头像材质
function PANEL:ShowAndUpdate(sourcePanel)
    if not IsValid(sourcePanel) or not IsValid(sourcePanel:GetPlayer()) then 
        self:HideAndStopThinking()
        return
    end

    self.SourcePanel = sourcePanel
    
    -- [修改] 从 sourcePanel 获取玩家实体 和 机器人头像材质
    local player = sourcePanel:GetPlayer()
    local botAvatar = sourcePanel:GetBotAvatarMaterial() -- 调用我们新增的函数

    -- [修改] 将两个信息都传递给 UpdateWithPlayer
    self:UpdateWithPlayer(player, botAvatar)
    
    local x, y = sourcePanel:LocalToScreen(sourcePanel:GetWide() + 5, 0)
    self:SetPos(x, y)
    self:SetVisible(true)
    self.bIsThinking = true
end

function PANEL:Think()
    -- ... (Think, HideAndStopThinking, OnCursorExited 等函数保持不变) ...
    if not self.bIsThinking then return end
    if not IsValid(self.SourcePanel) or (not self.SourcePanel:IsHovered() and not self:IsHovered()) then
        self:HideAndStopThinking()
    end
end

function PANEL:HideAndStopThinking()
    self:SetVisible(false)
    self.SourcePanel = nil
    self.bIsThinking = false
end

function PANEL:OnCursorExited()
end

vgui.Register("ZSPlayerHoverCard", PANEL, "DPanel")
