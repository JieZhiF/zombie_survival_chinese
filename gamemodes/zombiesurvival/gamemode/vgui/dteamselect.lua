-- ============================================================================
-- DTeamSelect - 出生团队选择窗口（玩家加入游戏时弹出）
-- 居中窗口（约 70% × 77% 屏幕），无背景遮罩：
-- 窗口顶部左侧标题 + 玩家偏好勾选框，
-- 中间左右两个等宽阵营面板（Survivors 人类 / Zombie 僵尸），
-- 面板内含阵营标题与人数、玩家统计列表、3D 模型预览；
-- 窗口底部为旁观者面板与创意工坊标志。点击阵营面板即向服务器发送队伍选择。
-- 当服务器判定已超过 NoNewHumansWave 时会自动分配为僵尸，不再弹出本界面。
-- 回合重启（RestartRound）时不再弹出本界面：服务器按玩家上次的选择
-- （本机 cvar zs_lastspawnchoice，断线重连仍保留；并兼用会话缓存 LastSpawnChoice）
-- 直接自动分配，客户端在重启时兜底关闭残留窗口。
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 主窗口
-- [位置] OpenTeamSelect() / DTeamSelect:Init() / DTeamSelect:Paint()
-- [作用] 全屏输入拦截容器 + 居中承载窗口（DTeamSelectFrame），无背景绘制
-- [常改] 窗口尺寸比例
--
-- [区域] 窗口本体
-- [位置] DTeamSelectFrame:BuildLayout() / PerformLayout() / Paint()
-- [作用] 标题 + 勾选框 + 阵营面板 + 旁观者面板 + 底部标志
-- [常改] 背景、标题文字、面板间距
--
-- [区域] 阵营面板（人类/僵尸）
-- [位置] DTeamFactionButton
-- [作用] 阵营标题与人数、玩家统计列表、3D 模型预览；点击加入阵营
-- [常改] 列定义（FACTION_DEFS.Columns）、模型路径、行高、字号
--
-- [区域] 偏好勾选框
-- [位置] DTeamSelectCheck / DTeamSelectFrame:BuildLayout
-- [作用] 读写客户端偏好 zs_alwaysspawnmenu / zs_alwaysvolunteer
-- [常改] 选项文案、cvar 名
-- ============================================================================

local TeamSelect = nil

-- 本地队伍别名：避免与 GM 表冲突
local T_HUMAN = TEAM_HUMAN
local T_UNDEAD = TEAM_UNDEAD

-- 从zombieclasses文件夹中提取僵尸模型
local function GetZombieModelsFromClasses()
	local zombieModels = {}
	local zombieClassesPath = "gamemodes/zombiesurvival/gamemode/zombieclasses/"
	
	-- 获取所有zombieclasses文件
	local files = file.Find(zombieClassesPath .. "*.lua", "GAME")
	if not files then
		return zombieModels
	end
	
	-- 遍历每个文件，提取CLASS.Model
	for _, filename in ipairs(files) do
		local filePath = zombieClassesPath .. filename
		local fileContent = file.Read(filePath, "GAME")
		
		if fileContent then
			-- 查找CLASS.Model = Model("...")模式
			local modelPattern = 'Model%("([^"]+)"%)'
			for modelPath in string.gmatch(fileContent, modelPattern) do
				-- 确保是有效的模型路径
				if modelPath and string.match(modelPath, "^models/.*%.mdl$") then
					-- 避免重复添加相同的模型
					local duplicate = false
					for _, existingModel in ipairs(zombieModels) do
						if existingModel == modelPath then
							duplicate = true
							break
						end
					end
					if not duplicate then
						table.insert(zombieModels, modelPath)
					end
				end
			end
		end
	end
	
	return zombieModels
end

-- 获取人类模型表（从所有模型中剔除僵尸模型）
local function GetHumanModels()
	local allModels = GetAllPlayerModels()
	local humanModels = {}
	
	for modelName, modelPath in pairs(allModels) do
		if not IsZombieModel(modelPath) then
			table.insert(humanModels, modelPath)
		end
	end
	
	-- 如果没有找到人类模型，使用默认列表
	if #humanModels == 0 then
		humanModels = {
			"models/player/arctic.mdl",
			"models/player/police.mdl",
			"models/player/riot.mdl",
			"models/player/gasmask.mdl",
			"models/player/swat.mdl",
			"models/player/fbi.mdl",
			"models/player/leet.mdl",
			"models/player/phoenix.mdl",
			"models/player/guerilla.mdl",
			"models/player/homicidal.mdl"
		}
	end
	
	return humanModels
end

-- 获取所有有效的玩家模型
local function GetAllPlayerModels()
	-- 确保player_manager存在（客户端可能还未完全加载）
	if player_manager and player_manager.AllValidModels then
		return player_manager.AllValidModels() or {}
	end
	return {}
end

-- 获取人类模型表（从所有模型中剔除僵尸模型）
local function GetHumanModels()
	local allModels = GetAllPlayerModels()
	local humanModels = {}
	
	for modelName, modelPath in pairs(allModels) do
		-- 检查是否为僵尸模型（通过检查是否在僵尸模型列表中）
		local isZombie = false
		local zombieModels = GetZombieModelsFromClasses()
		for _, zombieModel in ipairs(zombieModels) do
			if modelPath == zombieModel then
				isZombie = true
				break
			end
		end
		
		if not isZombie then
			table.insert(humanModels, modelPath)
		end
	end
	
	-- 如果没有找到人类模型，使用默认列表
	if #humanModels == 0 then
		humanModels = {
			"models/player/arctic.mdl",
			"models/player/police.mdl",
			"models/player/riot.mdl",
			"models/player/gasmask.mdl",
			"models/player/swat.mdl",
			"models/player/fbi.mdl",
			"models/player/leet.mdl",
			"models/player/phoenix.mdl",
			"models/player/guerilla.mdl",
			"models/player/homicidal.mdl"
		}
	end
	
	return humanModels
end

-- 获取僵尸模型表
local function GetZombieModels()
	-- 首先尝试从zombieclasses文件夹中获取
	local zombieModels = GetZombieModelsFromClasses()
	
	-- 如果没有找到僵尸模型，使用默认列表
	if #zombieModels == 0 then
		zombieModels = {
			"models/player/zombie_classic_hbfix.mdl",
			"models/player/zombie_fast.mdl",
			"models/player/zombie_lacerator2.mdl",
			"models/player/fatty/fatty.mdl",
			"models/player/zelpa/stalker.mdl",
			"models/wraith_zsv1.mdl",
			"models/vinrax/player/doll_player.mdl"
		}
	end
	
	return zombieModels
end

-- 随机选择模型函数
local function GetRandomModel(modelTable)
	if #modelTable == 0 then
		return "models/player/error.mdl"  -- 如果模型表为空，返回错误模型
	end
	return modelTable[math.random(#modelTable)]
end

-- 缓存模型表，避免每次调用都重新计算
local HUMAN_MODELS = nil
local ZOMBIE_MODELS = nil

-- 获取缓存的模型表
local function GetCachedHumanModels()
	if not HUMAN_MODELS then
		HUMAN_MODELS = GetHumanModels()
	end
	return HUMAN_MODELS
end

local function GetCachedZombieModels()
	if not ZOMBIE_MODELS then
		ZOMBIE_MODELS = GetZombieModels()
	end
	return ZOMBIE_MODELS
end

-- 阵营主题：标题、颜色、3D 模型、玩家列表列定义
-- Align=0 左对齐（名称列），Align=1 右对齐（数值列）
local FACTION_DEFS = {
	{
		TeamID = T_HUMAN,
		Title = "Survivors",
		TitleCN = "人类",
		Color = Color(70, 130, 200),
		ColorDark = Color(30, 60, 100),
		Model = GetRandomModel(GetCachedHumanModels()),
		Sound = "buttons/button14.wav",
		Columns = {
			{ Key = "name", Label = "玩家", X = 0.06, Align = 0 },
			{ Key = "score", Label = "得分", X = 0.5, Align = 1 },
			{ Key = "points", Label = "积分", X = 0.68, Align = 1 },
			{ Key = "ping", Label = "延迟", X = 0.88, Align = 1 },
		},
	},
	{
		TeamID = T_UNDEAD,
		Title = "Zombie",
		TitleCN = "僵尸",
		Color = Color(90, 170, 90),
		ColorDark = Color(40, 90, 40),
		Model = GetRandomModel(GetCachedZombieModels()),
		Sound = "buttons/button3.wav",
		Columns = {
			{ Key = "name", Label = "玩家", X = 0.06, Align = 0 },
			--{ Key = "class", Label = "职业", X = 0.42, Align = 1 },
			{ Key = "brains", Label = "脑容量", X = 0.58, Align = 1 },
			{ Key = "tokens", Label = "代币", X = 0.74, Align = 1 },
			{ Key = "ping", Label = "延迟", X = 0.9, Align = 1 },
		},
	},
}

-- 偏好 cvar：持久化到 config.cfg（shouldsave=true→FCVAR_ARCHIVE），
-- 且必须带 userinfo 标志才能让服务器经 pl:GetInfo() 读到客户端设置，
-- 否则服务器只能用默认值 "1"，导致「默认人类」设置失效、出生菜单始终弹出。
CreateClientConVar("zs_alwaysspawnmenu", "1", true, true)
CreateClientConVar("zs_alwaysvolunteer", "0", true, true)

-- 获取阵营定义表
local function GetFactionDef(teamid)
	for i = 1, #FACTION_DEFS do
		if FACTION_DEFS[i].TeamID == teamid then
			return FACTION_DEFS[i]
		end
	end
end

-- 获取玩家某列统计值
local function GetColumnValue(pl, key)
	if key == "name" then
		return pl:Name()
	elseif key == "score" or key == "brains" then
		return tostring(pl:Frags())
	elseif key == "points" then
		return tostring(pl:GetPoints() or 0)
	elseif key == "class" then
		local class = pl:GetZombieClassTable()
		return class and class.Name or "?"
	elseif key == "tokens" then
		return tostring(pl:GetTokens() or 0)
	elseif key == "ping" then
		return tostring(pl:Ping())
	end
	return ""
end

-- 队伍成员按得分降序
local function FactionPlayers(teamid)
	local list = {}
	for _, pl in ipairs(player.GetAll()) do
		if pl:Team() == teamid then
			table.insert(list, pl)
		end
	end
	table.sort(list, function(a, b)
		return a:Frags() > b:Frags()
	end)
	return list
end

-- 按最大像素宽度截断文本（UTF-8 安全，超出补省略号）
local function TruncateText(text, maxw)
	if surface.GetTextSize(text) <= maxw then
		return text
	end
	local len = utf8.len(text)
	while len > 0 and surface.GetTextSize(text) > maxw do
		len = len - 1
		text = utf8.sub(text, 1, len)
	end
	return text .. "..."
end

-- 向服务器发送队伍选择
local function SendChoice(teamid)
	-- 同时写入本地 cvar（zs_lastspawnchoice），作为本机持久化的出生偏好记录
	local cvar = GetConVar("zs_lastspawnchoice")
	if cvar then
		cvar:SetString(teamid == T_UNDEAD and "zombie" or "human")
	end
	if teamid == T_HUMAN then
		RunConsoleCommand("zs_spawnmenu", "human")
	elseif teamid == T_UNDEAD then
		RunConsoleCommand("zs_spawnmenu", "zombie")
	end
end

-- ============================================================================
-- DTeamSelectCheck - 偏好勾选框（读写客户端 cvar）
-- ============================================================================
local CheckPANEL = {}

function CheckPANEL:Init()
	self.m_CvarName = ""
	self.m_LabelText = ""
	self.m_Checked = false
end

function CheckPANEL:SetCvarName(name)
	self.m_CvarName = name
	local cvar = GetConVar(name)
	self.m_Checked = cvar and cvar:GetBool() or false
end

function CheckPANEL:SetLabelText(text)
	self.m_LabelText = text
end

function CheckPANEL:DoClick()
	self.m_Checked = not self.m_Checked
	if self.m_CvarName ~= "" then
		RunConsoleCommand(self.m_CvarName, self.m_Checked and "1" or "0")
	end
	surface.PlaySound("ui/buttonclick.wav")
end

function CheckPANEL:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT then
		self:DoClick()
	end
end

function CheckPANEL:Paint(w, h)
	local scale = BetterScreenScale()
	local box = 18 * scale
	local by = (h - box) / 2

	if self.m_Checked then
		draw.RoundedBox(3, 2, by, box, box, Color(110, 200, 110))
		surface.SetDrawColor(255, 255, 255, 255)
		local ox, oy = 6 * scale, by + 5 * scale
		surface.DrawLine(ox, oy + 4 * scale, ox + 4 * scale, oy + 8 * scale)
		surface.DrawLine(ox + 4 * scale, oy + 8 * scale, ox + 11 * scale, oy)
	else
		draw.RoundedBox(3, 2, by, box, box, Color(30, 30, 35, 220))
		surface.SetDrawColor(180, 180, 180, 255)
		surface.DrawOutlinedRect(2, by, box, box)
	end

	surface.SetFont("ZS2DFontHarmonySmall")
	surface.SetTextColor(215, 215, 215, 255)
	surface.SetTextPos(box + 12 * scale, (h - 22 * scale) / 2)
	surface.DrawText(self.m_LabelText)
	return true
end

vgui.Register("DTeamSelectCheck", CheckPANEL, "DPanel")

-- ============================================================================
-- DTeamSelectFrame - 居中窗口本体（标题、勾选框、阵营面板、旁观者、标志）
-- ============================================================================
local FramePANEL = {}

function FramePANEL:Init()
	self.Spectators = {}
end

-- ============================================================================
-- BuildLayout - 创建标题、勾选框与两个阵营面板
-- ============================================================================
function FramePANEL:BuildLayout()
	if not IsValid(self.TitleLabel) then
		self.TitleLabel = EasyLabel(self, "阵营选择", "ZSHUDFont", color_white)
		self.TitleLabel:SetContentAlignment(4)
		self.TitleLabel:SizeToContents()
	end

	if not IsValid(self.SubTitle) then
		self.SubTitle = EasyLabel(self, "选择你的阵营，点击对应面板加入", "ZS2DFontHarmonySmall", Color(180, 180, 180))
		self.SubTitle:SizeToContents()
	end

	-- 移除了偏好设置复选框，已移至选项界面

	if not IsValid(self.HumanPanel) then
		self.HumanPanel = vgui.Create("DTeamFactionButton", self)
		self.HumanPanel:SetTeam(T_HUMAN)
	end
	if not IsValid(self.ZombiePanel) then
		self.ZombiePanel = vgui.Create("DTeamFactionButton", self)
		self.ZombiePanel:SetTeam(T_UNDEAD)
	end
end

-- ============================================================================
-- PerformLayout - 计算窗口内标题、勾选框、阵营面板的位置与尺寸
-- ============================================================================
function FramePANEL:PerformLayout()
	local scale = BetterScreenScale()
	local w, h = self:GetWide(), self:GetTall()

	if IsValid(self.TitleLabel) then
		self.TitleLabel:SetPos(w * 0.04, h * 0.03)
	end
	if IsValid(self.SubTitle) then
		self.SubTitle:SetPos(w * 0.04 + 6 * scale, h * 0.03 + 46 * scale)
	end
	-- 移除了偏好设置复选框的布局

	-- 左右阵营面板（各占约 46% 宽度）
	local margin = w * 0.04
	local gap = w * 0.02
	local panelW = (w - margin * 2 - gap) / 2
	local panelTop = h * 0.08  -- 减小顶部间距，因为移除了复选框
	local panelH = (h * 0.925) - panelTop - (h * 0.02)  -- 增加面板高度

	if IsValid(self.HumanPanel) then
		self.HumanPanel:SetPos(margin, panelTop)
		self.HumanPanel:SetSize(panelW, panelH)
	end
	if IsValid(self.ZombiePanel) then
		self.ZombiePanel:SetPos(margin + panelW + gap, panelTop)
		self.ZombiePanel:SetSize(panelW, panelH)
	end
end

-- ============================================================================
-- Think - 刷新旁观者列表（未选择阵营的玩家，按 Ping 升序）
-- ============================================================================
function FramePANEL:Think()
	self.Spectators = {}
	for _, pl in ipairs(player.GetAll()) do
		local t = pl:Team()
		if t ~= T_HUMAN and t ~= T_UNDEAD then
			table.insert(self.Spectators, pl)
		end
	end
	table.sort(self.Spectators, function(a, b)
		return a:Ping() < b:Ping()
	end)
end

-- ============================================================================
-- PaintSpectators - 窗口底部旁观者面板（名称 + Ping，超出两行省略）
-- ============================================================================
function FramePANEL:PaintSpectators(w, h)
	local scale = BetterScreenScale()
	local y0 = h * 0.925  -- 调整旁观者面板位置
	local barH = h * 0.075  -- 减小高度

	draw.RoundedBox(6, w * 0.04, y0, w * 0.92, barH, Color(20, 20, 25, 220))
	surface.SetDrawColor(255, 255, 255, 30)
	surface.DrawLine(w * 0.04, y0, w * 0.96, y0)

	surface.SetFont("ZSHUDFontSmaller")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(w * 0.06, y0 + 6 * scale)
	surface.DrawText("SPECTATORS (" .. #self.Spectators .. ")")

	surface.SetFont("ZS2DFontHarmonySmall")
	local x = w * 0.06
	local y = y0 + 38 * scale
	local line = 0
	for i = 1, #self.Spectators do
		local pl = self.Spectators[i]
		local txt = pl:Name() .. "  (" .. pl:Ping() .. ")"
		local tw = surface.GetTextSize(txt)
		if x + tw > w * 0.96 then
			line = line + 1
			if line >= 2 then
				surface.SetTextColor(150, 150, 150, 255)
				surface.SetTextPos(x, y)
				surface.DrawText("...")
				return
			end
			x = w * 0.06
			y = y + 22 * scale
		end
		surface.SetTextColor(205, 205, 205, 255)
		surface.SetTextPos(x, y)
		surface.DrawText(txt)
		x = x + tw + 24 * scale
	end
end
--[[
-- ============================================================================
-- PaintWorkshopLogo - 窗口底部中央创意工坊标志（线框圆 + 下载箭头 + 文字）
-- ============================================================================
function FramePANEL:PaintWorkshopLogo(w, h)
	local scale = BetterScreenScale()
	local cx = w / 2
	local cy = h * 0.965

	surface.SetFont("ZS2DFontHarmonySmall")
	local txt = "STEAM WORKSHOP"
	local tw = surface.GetTextSize(txt)

	-- 图标：圆环 + 向下箭头
	local r = 8 * scale
	local ax = cx - tw / 2 - r - 16 * scale
	local ay = cy - 8 * scale
	surface.SetDrawColor(150, 150, 150, 255)
	local lastx, lasty = ax + r, ay
	for i = 1, 24 do
		local a = math.rad(i / 24 * 360)
		local px = ax + math.cos(a) * r
		local py = ay + math.sin(a) * r
		surface.DrawLine(lastx, lasty, px, py)
		lastx, lasty = px, py
	end
	surface.DrawLine(ax, ay - 5 * scale, ax, ay + 3 * scale)
	surface.DrawLine(ax, ay + 3 * scale, ax - 4 * scale, ay - 1 * scale)
	surface.DrawLine(ax, ay + 3 * scale, ax + 4 * scale, ay - 1 * scale)

	surface.SetTextColor(140, 140, 145, 255)
	surface.SetTextPos(cx - tw / 2, cy - 8 * scale)
	surface.DrawText(txt)
end
]]
-- ============================================================================
-- Paint - 窗口背景（深色圆角框 + 主题色顶条 + 边框）+ 旁观者面板 + 底部标志
-- ============================================================================
function FramePANEL:Paint(w, h)
	-- 窗口背景
	draw.RoundedBox(8, 0, 0, w, h, Color(15, 15, 20, 245))
	draw.RoundedBox(2, 4, 4, w - 8, 4, Color(70, 130, 200))
	draw.RoundedBox(2, 4, 8, w - 8, 2, Color(90, 170, 90, 160))

	-- 标题分隔线
	surface.SetDrawColor(255, 255, 255, 40)
	surface.DrawLine(w * 0.04, h * 0.165, w * 0.96, h * 0.165)

	-- 边框
	surface.SetDrawColor(255, 255, 255, 60)
	surface.DrawOutlinedRect(0, 0, w, h)

	self:PaintSpectators(w, h)
	--self:PaintWorkshopLogo(w, h)
	return true
end

vgui.Register("DTeamSelectFrame", FramePANEL, "DPanel")

-- ============================================================================
-- DTeamSelect - 主窗口（全屏变暗遮罩 + 居中承载 DTeamSelectFrame）
-- ============================================================================
local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:MakePopup()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self.DontRemove = true

	self.Alive = true
end

function PANEL:BuildLayout()
	self:SetSize(ScrW(), ScrH())

	if not IsValid(self.Frame) then
		self.Frame = vgui.Create("DTeamSelectFrame", self)
		self.Frame:BuildLayout()
	end
end

function PANEL:PerformLayout()
	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	local w, h = self:GetWide(), self:GetTall()
	if IsValid(self.Frame) then
		local fw, fh = w * 0.7, h * 0.77
		self.Frame:SetPos((w - fw) / 2, (h - fh) / 2)
		self.Frame:SetSize(fw, fh)
	end
end

-- ============================================================================
-- Paint - 无背景绘制（纯窗口模式，不绘制遮罩）
-- ============================================================================
function PANEL:Paint(w, h)
	return true
end

function PANEL:Close()
	TeamSelect = nil
	self:Remove()
end

vgui.Register("DTeamSelect", PANEL, "DPanel")

-- ============================================================================
-- DTeamFactionButton - 单个阵营面板（标题 + 玩家列表 + 3D 模型预览，点击加入）
-- ============================================================================
local BtnPANEL = {}

function BtnPANEL:Init()
	self.TeamID = T_HUMAN
	self.Players = {}
	self.Count = 0
	self.m_IsHovered = false
	self.ModelFitFrames = 30

	self.ModelPanel = vgui.Create("DModelPanelEx", self)
	self.ModelPanel:SetMouseInputEnabled(false)
	self.ModelPanel:SetKeyboardInputEnabled(false)
	self.ModelPanel:SetFOV(42)
	self.ModelPanel.LayoutEntity = function(_, ent)
		if IsValid(ent) then
			ent:SetAngles(Angle(0, RealTime() * 35 % 360, 0))
		end
	end
end

function BtnPANEL:SetTeam(teamid)
	self.TeamID = teamid
	local def = GetFactionDef(teamid)
	if def and IsValid(self.ModelPanel) then
		self.ModelPanel:SetModel(def.Model)
	end
end

function BtnPANEL:Think()
	self.Players = FactionPlayers(self.TeamID)
	self.Count = #self.Players

	-- 模型异步加载期间持续重新取景（前 30 帧）
	if IsValid(self.ModelPanel) and self.ModelFitFrames > 0 then
		self.ModelFitFrames = self.ModelFitFrames - 1
		self.ModelPanel:AutoCam()
	end
end

function BtnPANEL:DoClick()
	local def = GetFactionDef(self.TeamID)
	if def then
		surface.PlaySound(def.Sound)
	end

	SendChoice(self.TeamID)
	TeamSelect:Close()
end

function BtnPANEL:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT then
		self:DoClick()
	end
end

function BtnPANEL:OnCursorEntered()
	self.m_IsHovered = true
	surface.PlaySound("ui/buttonrollover.wav")
end

function BtnPANEL:OnCursorExited()
	self.m_IsHovered = false
end

function BtnPANEL:Paint(w, h)
	local def = GetFactionDef(self.TeamID)
	if not def then return end
	local scale = BetterScreenScale()

	-- 背景与边框（悬停时提亮）
	local col = self.m_IsHovered and def.Color or def.ColorDark
	draw.RoundedBox(8, 0, 0, w, h, Color(col.r, col.g, col.b, 200))
	draw.RoundedBox(8, 4, 4, w - 8, h - 8, Color(12, 12, 16, 205))

	-- 顶部主题色条
	draw.RoundedBox(2, 4, 4, w - 8, 5, col)

	-- 阵营标题 + 人数（居中）
	surface.SetFont("ZSHUDFont")
	local title = def.Title
	local tw = surface.GetTextSize(title)
	local cnttxt = "(" .. tostring(self.Count) .. ")"
	surface.SetFont("ZSHUDFontSmaller")
	local cw = surface.GetTextSize(cnttxt)
	local titleY = 18 * scale

	surface.SetFont("ZSHUDFont")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(w / 2 - (tw + cw) / 2, titleY)
	surface.DrawText(title)

	surface.SetFont("ZSHUDFontSmaller")
	surface.SetTextColor(200, 200, 200, 255)
	surface.SetTextPos(w / 2 - (tw + cw) / 2 + tw + 10 * scale, titleY + 9 * scale)
	surface.DrawText(cnttxt)

	-- 中文名称
	surface.SetFont("ZS2DFontHarmonySmall")
	local cnw = surface.GetTextSize(def.TitleCN)
	surface.SetTextColor(180, 180, 180, 255)
	surface.SetTextPos(w / 2 - cnw / 2, titleY + 52 * scale)
	surface.DrawText(def.TitleCN)

	-- 列头（右对齐）
	local colY = titleY + 88 * scale
	surface.SetFont("ZSHUDFontSmaller")
	surface.SetTextColor(150, 150, 160, 255)
	for i = 1, #def.Columns do
		local c = def.Columns[i]
		local tx = c.X * w
		local tw2 = surface.GetTextSize(c.Label)
		surface.SetTextPos(c.Align == 0 and tx or tx - tw2, colY)
		surface.DrawText(c.Label)
	end

	-- 玩家行（最多 6 行，斑马纹）
	local rowY = colY + 30 * scale
	local rowH = 24 * scale
	local maxrows = math.min(#self.Players, 6)
	surface.SetFont("ZS2DFontHarmonySmall")
	local namemax = #def.Columns >= 2 and (def.Columns[2].X - def.Columns[1].X - 0.02) * w or w * 0.4
	for i = 1, maxrows do
		local pl = self.Players[i]
		local y = rowY + (i - 1) * rowH
		if i % 2 == 0 then
			draw.RoundedBox(2, 6, y - 2, w - 12, rowH - 4, Color(255, 255, 255, 8))
		end
		for j = 1, #def.Columns do
			local c = def.Columns[j]
			local val = GetColumnValue(pl, c.Key)
			if c.Key == "name" then
				val = TruncateText(val, namemax)
			end
			if c.Key == "ping" then
				local p = pl:Ping()
				if p > 150 then
					surface.SetTextColor(255, 90, 90, 255)
				elseif p > 80 then
					surface.SetTextColor(240, 200, 80, 255)
				else
					surface.SetTextColor(230, 230, 230, 255)
				end
			else
				surface.SetTextColor(230, 230, 230, 255)
			end
			local tx = c.X * w
			surface.SetTextPos(c.Align == 0 and tx or tx - surface.GetTextSize(val), y)
			surface.DrawText(val)
		end
	end
	if #self.Players > maxrows then
		surface.SetFont("ZS2DFontHarmonySmall")
		surface.SetTextColor(130, 130, 140, 255)
		surface.SetTextPos(w / 2 - surface.GetTextSize("...") / 2, rowY + maxrows * rowH - 4 * scale)
		surface.DrawText("...")
	end

	-- 3D 模型预览（列表下方居中，自动旋转）
	local modelTop = rowY + maxrows * rowH + 16 * scale
	local modelBottom = h - 14 * scale
	local mh = modelBottom - modelTop
	if mh > 40 * scale and IsValid(self.ModelPanel) then
		local msize = math.min(w - 24 * scale, mh)
		self.ModelPanel:SetPos((w - msize) / 2, modelTop + (mh - msize) / 2)
		self.ModelPanel:SetSize(msize, msize)
	end

	return true
end

vgui.Register("DTeamFactionButton", BtnPANEL, "DPanel")

-- ============================================================================
-- OpenTeamSelect - 弹出出生团队选择窗口（由客户端接收服务器消息调用）
-- ============================================================================
function OpenTeamSelect()
	if TeamSelect and TeamSelect:IsValid() then
		TeamSelect:Remove()
	end

	TeamSelect = vgui.Create("DTeamSelect")
	TeamSelect:BuildLayout()
	TeamSelect:MakePopup()
	TeamSelect:InvalidateLayout()
end

-- 关闭出生选择窗口（服务器强制处理时调用，玩家自行点击时内部已关闭）
function CloseTeamSelect()
	if TeamSelect and TeamSelect:IsValid() then
		TeamSelect:Close()
	end
end

-- 接收服务器消息：弹出（true + 波数）或关闭（false）出生选择界面
net.Receive(NET_MSG.SPAWNMENU, function(length)
	if net.ReadBool() then
		local wave = net.ReadUInt(16)
		OpenTeamSelect()
	else
		CloseTeamSelect()
	end
end)

-- 接收服务器消息：将服务器最终分配的阵营回写到本机 cvar（zs_lastspawnchoice），
-- 使其作为本地持久化记录；断线重连后服务器可用 pl:GetInfo 读回该偏好。
net.Receive(NET_MSG.LASTSPAWNCHOICE, function()
	local undead = net.ReadBool()
	local cvar = GetConVar("zs_lastspawnchoice")
	if cvar then
		cvar:SetString(undead and "zombie" or "human")
	end
end)