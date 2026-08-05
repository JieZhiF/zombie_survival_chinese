-- ============================================================================
-- PEndBoard - 回合结束面板
-- 显示回合结果（胜利/失败）、荣誉提名列表
-- 包含 DEndBoardPlayerPanel 用于显示每个玩家的头像和相关信息
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 回合结果面板
-- [位置] MakepEndBoard() / GM:AddHonorableMention()
-- [作用] 显示胜利/失败标题、副标题与荣誉提名玩家列表
-- [常改] 标题文字、音效、窗口宽度、列表尺寸
--
-- [区域] 玩家条目
-- [位置] DEndBoardPlayerPanel / Init() / SetPlayer() / OnMousePressed()
-- [作用] 单个玩家条目：头像、名字、附加信息，点击查看资料
-- [常改] 头像大小、文字位置、点击回调
-- ============================================================================

-- ============================================================================
-- AddHonorableMention - 添加荣誉提名到结束面板
-- ============================================================================
function GM:AddHonorableMention(pl, mentionid, ...)
	if not (pEndBoard and pEndBoard:IsValid()) then
		MakepEndBoard(ROUNDWINNER)
	end

	local mentiontab = self.HonorableMentions[mentionid]
	if not mentiontab then return end

	local pan = vgui.Create("DEndBoardPlayerPanel", pEndBoard.List)
	pan:SetPlayer(pl, mentiontab.Color, string.format(mentiontab.String, mentiontab.Callback(pl, ...)), nil, mentiontab.Name)
	pEndBoard.List:AddItem(pan)
end

-- ============================================================================
-- MakepEndBoard - 创建回合结束面板
-- ============================================================================
function MakepEndBoard(winner)
	if pEndBoard and pEndBoard:IsValid() then
		pEndBoard:Remove()
		pEndBoard = nil
	end

	local localwin = winner == TEAM_HUMAN and MySelf:IsValid() and MySelf:Team() == winner

	local screenscale = BetterScreenScale()
	local wid = math.min(ScrW(), 650) * screenscale

	-- 创建主框架
	local frame = vgui.Create("DFrame")
	frame:SetWide(wid)
	frame:SetKeyboardInputEnabled(false)
	frame:SetDeleteOnClose(false)
	frame:SetCursor("pointer")
	frame:SetTitle(" ")
	pEndBoard = frame

	local y = 8

	-- 标题：胜利或失败
	local heading
	if localwin then
		surface.PlaySound("beams/beamstart5.wav")
		heading = EasyLabel(frame, translate.Get("endboard_YouHaveWon"), "ZSHUDFontBig", COLOR_CYAN)
	else
		surface.PlaySound("ambient/levels/citadel/strange_talk"..math.random(3, 11)..".wav")
		heading = EasyLabel(frame, translate.Get("endboard_YouHaveLost"), "ZSHUDFontBig", COLOR_RED)
	end
	heading:SetPos(wid * 0.5 - heading:GetWide() * 0.5, y)
	y = y + heading:GetTall() + 16
	
	-- 副标题：描述结果
	local subheading
	if localwin then
		subheading = EasyLabel(frame, translate.Get("endboard_TheHumansHaveSurvivedForNow"), "ZSHUDFontSmaller", COLOR_WHITE)
	else
		subheading = EasyLabel(frame, translate.Get("endboard_TheUndeadArmyGrowsStronger"), "ZSHUDFontSmaller", COLOR_LIMEGREEN)
	end
	subheading:SetPos(wid * 0.5 - subheading:GetWide() * 0.5, y)
	y = y + subheading:GetTall() + 2
	
	-- 荣誉提名标题
	local svpan = EasyLabel(frame, translate.Get("endboard_HonorableMentions"), "ZSHUDFontSmall", COLOR_WHITE)
	
	svpan:SetPos(wid * 0.5 - svpan:GetWide() * 0.5, y)
	y = y + svpan:GetTall() + 2

	-- 荣誉提名玩家列表
	local list = vgui.Create("DPanelList", frame)
	list:SetSize(wid - 16, 600 * screenscale)
	list:SetPos(8, y)
	list:SetPadding(2)
	list:SetSpacing(2)
	list:EnableVerticalScrollbar()
	y = y + list:GetTall() + 8

	frame.List = list

	frame:SetTall(y)
	frame:Center()

	frame:MakePopup()

	return frame
end

-- ============================================================================
-- DEndBoardPlayerPanel - 结束面板中的单个玩家条目
-- ============================================================================
local PANEL = {}

-- ============================================================================
-- OnMousePressed - 点击玩家条目时触发回调查看资料
-- ============================================================================
function PANEL:OnMousePressed(mc)
	if mc == MOUSE_LEFT then
		local pl = self:GetPlayer()
		if pl:IsValid() then
			gamemode.Call("ClickedEndBoardPlayerButton", pl, self)
		end
	end
end

-- ============================================================================
-- Init - 初始化玩家条目面板
-- ============================================================================
function PANEL:Init()
	local screenscale = math.max(1, BetterScreenScale())
	self:SetSize(200 * screenscale, 38 * screenscale)
end

-- ============================================================================
-- GetPlayer - 获取关联的玩家
-- ============================================================================
function PANEL:GetPlayer()
	return self.m_Player or NULL
end

-- ============================================================================
-- SetPlayer - 设置玩家显示信息
-- @pl: 玩家对象
-- @col: 名字颜色
-- @misc: 附加信息文本
-- @misccol: 附加信息颜色
-- @overridename: 覆盖显示的名字
-- ============================================================================
function PANEL:SetPlayer(pl, col, misc, misccol, overridename)
	if self.m_pAvatar then
		self.m_pAvatar:Remove()
		self.m_pAvatar = nil
	end
	if self.m_pName then
		self.m_pName:Remove()
		self.m_pName = nil
	end
	if self.m_pMisc then
		self.m_pMisc:Remove()
		self.m_pMisc = nil
	end

	if pl:IsValidPlayer() then
		local name = overridename or pl:Name()

		-- 玩家头像
		local avatar = vgui.Create("AvatarImage", self)
		avatar:SetPos(2, 2)
		avatar:SetSize(32, 32)
		avatar:SetPlayer(pl)
		avatar:SetTooltip(translate.Get("endboard_ClickHereToViewProfile"))

		self.m_pAvatar = avatar

		-- 玩家名字
		local namelab = EasyLabel(self, name, "ZSHUDFontTiny", col)
		namelab:SetPos(40, -2)
		self.m_pName = namelab

		-- 附加信息（如有）
		if misc then
			local misclab = EasyLabel(self, misc, nil, misccol)
			misclab:SetPos(58, self:GetTall() - 1 - misclab:GetTall())
		end
	end
end
vgui.Register("DEndBoardPlayerPanel", PANEL, "DPanel")
