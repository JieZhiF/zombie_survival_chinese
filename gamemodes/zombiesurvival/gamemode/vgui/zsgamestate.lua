-- ============================================================================
-- ZSGameState - 游戏状态 HUD 组件
-- 显示波次信息、倒计时、队伍人数、分数/大脑数量
-- 位于屏幕顶部，带渐变背景
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 队伍计数器
-- [位置] Init() / PerformLayout()
-- [作用] 左上角人类/僵尸人数图标计数
-- [常改] 计数尺寸、图标材质
--
-- [区域] 状态文本
-- [位置] Text1Paint() / Text2Paint() / Text3Paint()
-- [作用] 三行文本：波次信息/倒计时/积分与大脑数
-- [常改] 字体、文本格式、颜色闪烁逻辑
--
-- [区域] 渐变背景
-- [位置] Paint()
-- [作用] 顶部左侧实底 + 右侧渐变背景
-- [常改] 透明度、渐变材质、高度
-- ============================================================================

local PANEL = {}

-- ============================================================================
-- Init - 初始化游戏状态面板
-- ============================================================================
function PANEL:Init()
	-- 人类计数器
	self.m_HumanCount = vgui.Create("DTeamCounter", self)
	self.m_HumanCount:SetTeam(TEAM_HUMAN)
	self.m_HumanCount:SetImage("zombiesurvival/humanhead")

	-- 僵尸计数器
	self.m_ZombieCount = vgui.Create("DTeamCounter", self)
	self.m_ZombieCount:SetTeam(TEAM_UNDEAD)
	self.m_ZombieCount:SetImage("zombiesurvival/zombiehead")

	-- 三行文本显示
	self.m_Text1 = vgui.Create("DLabel", self)
	self.m_Text2 = vgui.Create("DLabel", self)
	self.m_Text3 = vgui.Create("DLabel", self)
	self:SetTextFont("ZSHUDFontTiny")

	-- 使用自定义 Paint 函数
	self.m_Text1.Paint = self.Text1Paint
	self.m_Text2.Paint = self.Text2Paint
	self.m_Text3.Paint = self.Text3Paint

	self:InvalidateLayout()
end

-- ============================================================================
-- SetTextFont - 设置所有文本标签的字体
-- ============================================================================
function PANEL:SetTextFont(font)
	self.m_Text1.Font = font
	self.m_Text1:SetFont(font)
	self.m_Text2.Font = font
	self.m_Text2:SetFont(font)
	self.m_Text3.Font = font
	self.m_Text3:SetFont(font)

	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局队伍计数器和文本标签
-- ============================================================================
function PANEL:PerformLayout()
	local hs = self:GetTall() * 0.5
	self.m_HumanCount:SetSize(hs, hs)
	self.m_ZombieCount:SetSize(hs, hs)
	self.m_ZombieCount:AlignTop(hs)

	self.m_Text1:SetWide(self:GetWide())
	self.m_Text1:SizeToContentsY()
	self.m_Text1:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text1:AlignTop(4)
	self.m_Text2:SetWide(self:GetWide())
	self.m_Text2:SizeToContentsY()
	self.m_Text2:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text2:CenterVertical()
	self.m_Text3:SetWide(self:GetWide())
	self.m_Text3:SizeToContentsY()
	self.m_Text3:MoveRightOf(self.m_HumanCount, 12)
	self.m_Text3:AlignBottom(4)
end

-- ============================================================================
-- Text1Paint - 绘制第一行文本（波次信息或任务目标）
-- ============================================================================
function PANEL:Text1Paint()
	local text
	local override = MySelf:IsValid() and GetGlobalString("hudoverride"..MySelf:Team(), "")

	if override and #override > 0 then
		text = override
	else
		local wave = GAMEMODE:GetWave()
		if GAMEMODE:IsEscapeSequence() then
			text = translate.Get(MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD and "prop_obj_exit_z" or "prop_obj_exit_h")
		elseif wave <= 0 then
			text = translate.Get("prepare_yourself")
		elseif GAMEMODE.ZombieEscape then
			text = translate.Get("zombie_escape")
			round = GAMEMODE.CurrentRound
			text = text .. " - " .. translate.Format("round_x_of_y", round, 2)
		else
			local maxwaves = GAMEMODE:GetNumberOfWaves()
			if maxwaves ~= -1 then
				text = translate.Format("wave_x_of_y", wave, maxwaves)
				if not GAMEMODE:GetWaveActive() then
					text = translate.Get("intermission").." - "..text
				end
			elseif not GAMEMODE:GetWaveActive() then
				text = translate.Get("intermission")
			end
		end
	end

	if text then
		draw.SimpleText(text, self.Font, 0, 0, COLOR_GRAY)
	end

	return true
end

-- ============================================================================
-- Text2Paint - 绘制第二行文本（倒计时）
-- ============================================================================
function PANEL:Text2Paint()
	if GAMEMODE:GetWave() <= 0 then
		local col
		local timeleft = math.max(0, GAMEMODE:GetWaveStart() - CurTime())
		if timeleft < 10 then
			local glow = math.sin(RealTime() * 8) * 200 + 255
			col = Color(255, glow, glow)
		else
			col = COLOR_GRAY
		end

		draw.SimpleText(translate.Format("zombie_invasion_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, col)
	elseif GAMEMODE:GetWaveActive() then
		local waveend = GAMEMODE:GetWaveEnd()
		if waveend ~= -1 then
			local timeleft = math.max(0, waveend - CurTime())
			draw.SimpleText(translate.Format("wave_ends_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, 10 < timeleft and COLOR_GRAY or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
		end
	else
		local wavestart = GAMEMODE:GetWaveStart()
		if wavestart ~= -1 then
			local timeleft = math.max(0, wavestart - CurTime())
			draw.SimpleText(translate.Format("next_wave_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, 10 < timeleft and COLOR_GRAY or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
		end
	end

	return true
end

-- ============================================================================
-- Text3Paint - 绘制第三行文本（分数/大脑数量）
-- ============================================================================
function PANEL:Text3Paint()
	if MySelf:IsValid() then
		if MySelf:Team() == TEAM_UNDEAD then
			-- 僵尸：显示已食用的大脑数量
			local toredeem = GAMEMODE:GetRedeemBrains()
			if toredeem > 0 then
				draw.SimpleText(translate.Format("brains_eaten_x", MySelf:Frags().." / "..toredeem), self.Font, 0, 0, COLOR_SOFTRED)
			else
				draw.SimpleText(translate.Format("brains_eaten_x", MySelf:Frags()), self.Font, 0, 0, COLOR_SOFTRED)
			end
		else
			-- 人类：显示积分和得分
			draw.SimpleText(""..translate.Format("gameui_points")..MySelf:GetPoints()..""..translate.Format("gameui_score")..MySelf:Frags(), self.Font, 0, 0, COLOR_SOFTRED)
		end
	end

	return true
end

-- 渐变材质
local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})

-- ============================================================================
-- Paint - 绘制渐变背景
-- ============================================================================
function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, 0, w * 0.4, h)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(w * 0.4, 0, w * 0.6, h)
	surface.SetDrawColor(0, 0, 0, 250)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(0, h - 1, w, 1)

	return true
end

vgui.Register("ZSGameState", PANEL, "DPanel")
