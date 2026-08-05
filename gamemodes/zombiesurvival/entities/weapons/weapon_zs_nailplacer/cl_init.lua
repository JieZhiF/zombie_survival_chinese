-- ============================================================================
-- weapon_zs_nailplacer - 客户端
-- 功能：
--   OpenNailPlacerMenu(presetModel) - 模型选择界面
--     * 我的最爱：保存在玩家本地 data/zs_nailplacer/config.json（含自定义名字）
--     * 预设模型：常用路障道具
--     * 模型浏览：仿原版 spawnmenu 的图形化模型浏览器
--       （左侧 DTree 文件夹树懒加载、默认展开起始目录，右侧 SpawnIcon 图标网格）
--     * 自定义名字：显示在预览下方与最爱列表里，方便快速识别
--     * 服务器校验：浏览器只显示服务器上有的模型，预览/生成缺失模型时警告并拦截
--     * 单击选中并预览，点“生成”在准星处生成模型
--     * 模型缩放（0.1-4 均匀）与颜色（RGBA）调整，实时预览并随生成发送
--     * 关闭菜单仅隐藏，重新打开保留上次状态
--     * “保存钉子 / 加载钉子”按钮调用 sv_nailsave.lua 的 zs_savenails / zs_loadnails
-- （左键开菜单在 shared.lua 的 SWEP:PrimaryAttack 中；拆钉逻辑在 shared.lua 的 SWEP:Think 中）
--   SWEP:DrawHUD() - 显示按键提示与准星
-- 全局定义：
--   OpenNailPlacerMenu([presetModel]) - 打开模型选择界面，可传入预选模型
-- ============================================================================
INC_CLIENT()

SWEP.Slot = 5
SWEP.ViewModelFOV = 75

-- 幽灵预显模式：0 = 仅显示当前等级（默认），1 = 全部显示（超出等级的为红色）
-- 加存在性检查：CreateClientConVar 每次脚本重跑会重置默认值，导致重开地图归零
if not GetConVar("zs_nailplacer_ghostmode") then
	CreateClientConVar("zs_nailplacer_ghostmode", "1", true, false)
end

-- ============================================================================
-- 本地配置读写（最爱列表 + 当前生成等级，共存于同一个 config.json）
-- ============================================================================
local CONFIG_DIR = "zs_nailplacer"
local CONFIG_PATH = CONFIG_DIR.."/config.json"

local function LoadConfig()
	if file.Exists(CONFIG_PATH, "DATA") then
		local data = util.JSONToTable(file.Read(CONFIG_PATH, "DATA") or "")
		if type(data) == "table" then return data end
	end
	return {}
end

local configData = LoadConfig()

-- 当前生成等级（生成道具时随包发送并写入道具，1-5）
local currentSpawnLevel = math.Clamp(math.floor(tonumber(configData.spawnlevel) or 1), 1, 5)

local function SaveConfig()
	configData.spawnlevel = currentSpawnLevel
	file.CreateDir(CONFIG_DIR)
	file.Write(CONFIG_PATH, util.TableToJSON(configData, true))
end

-- 从本地配置读取最爱列表
-- 兼容两种格式：旧版纯字符串（无名字）与新版 {model=..., name=...} 表
local function LoadFavorites()
	local favorites = {}
	if type(configData.favorites) == "table" then
		for _, fav in ipairs(configData.favorites) do
			if type(fav) == "string" then
				table.insert(favorites, {model = fav, name = ""})
			elseif type(fav) == "table" and type(fav.model) == "string" then
				table.insert(favorites, {model = fav.model, name = fav.name or ""})
			end
		end
	end
	return favorites
end

-- 保存最爱列表到本地配置（保留生成等级等其他字段）
local function SaveFavorites(favorites)
	configData.favorites = favorites
	SaveConfig()
end

-- 完整模型路径转短显示名：去掉 models/ 前缀和 .mdl 后缀
local function ShortModelName(model)
	return string.StripExtension(string.gsub(model, "^models/", ""))
end

-- 模型存在性检查：用 file.Exists 而非 util.IsValidModel，
-- 后者在客户端对未加载的模型经常误报 false，导致预览加载不出来
local function ModelExists(model)
	return type(model) == "string" and model ~= "" and file.Exists(model, "GAME")
end

-- ============================================================================
-- 预设模型列表（常用路障道具）
-- ============================================================================
local presetModels = {
	"models/props_c17/furnituredresser001a.mdl",
	"models/props_c17/furnituretable001a.mdl",
	"models/props_c17/furnituretable002a.mdl",
	"models/props_c17/furniturecouch001a.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_c17/furnituredrawer001a.mdl",
	"models/props_interiors/furniture_shelf01a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_borealis/bluebarrel001.mdl",
	"models/props_junk/trashbin01a.mdl",
	"models/props_c17/concrete_barrier001a.mdl",
	"models/props_debris/wood_board04a.mdl",
	"models/props_wasteland/medbridge_post01.mdl",
	"models/props_c17/canister_propane01a.mdl"
}

-- ============================================================================
-- 生成选中的模型：客户端做准星追踪，把位置/缩放/颜色发给服务器
-- ============================================================================
local function SpawnModel(model, scale, col)
	if not model or model == "" then return end

	local tr = MySelf:TraceLine(2000, MASK_SOLID)
	local pos = tr.HitPos + tr.HitNormal * 2
	local ang = Angle(0, MySelf:EyeAngles().y, 0)

	net.Start("zs_nailplacer_spawn")
		net.WriteString(model)
		net.WriteVector(pos)
		net.WriteAngle(ang)
		net.WriteFloat(scale or 1)
		net.WriteColor(col or color_white)
		net.WriteUInt(currentSpawnLevel, 8) -- 防线等级
	net.SendToServer()
end

-- ============================================================================
-- 服务器模型存在性查询
-- 管理员的本地通常有大量服务器没有的模型：浏览器目录与预览都做服务器校验，
-- 只展示、只生成服务器上真实存在的模型
-- ============================================================================
local function RequestFolderModels(folder)
	net.Start("zs_nailplacer_modelcheck")
		net.WriteUInt(0, 8)
		net.WriteString(folder)
	net.SendToServer()
end

local function RequestModelCheck(model)
	net.Start("zs_nailplacer_modelcheck")
		net.WriteUInt(1, 8)
		net.WriteString(model)
	net.SendToServer()
end

-- ============================================================================
-- 图形化模型浏览器（仿原版 spawnmenu：左文件夹树 + 右 SpawnIcon 网格）
-- ============================================================================
local BROWSER_START_PATH = "models/props" -- 默认展示的目录
local MAX_BROWSE_ICONS = 400              -- 单目录图标上限，防止巨型目录卡死

local function BuildModelBrowser(frame, sheet, screenscale)
	local browser = vgui.Create("DPanel")
	browser.Paint = function() end
	local browsersheet = sheet:AddSheet(translate.Get("nailplacer_browser"), browser, nil, false, false)
	browser.SheetTab = browsersheet.Tab

	-- 左侧：文件夹树（DTree_Node:MakeFolder 懒加载子目录，与原版 spawnmenu 相同）
	local tree = vgui.Create("DTree", browser)
	tree:Dock(LEFT)
	tree:DockMargin(2, 2, 2, 2)
	tree:SetWide(200 * screenscale)
	tree:SetIndentSize(10)

	-- 右侧：模型图标网格（DIconLayout 自动换行、自动撑高）
	local scroll = vgui.Create("DScrollPanel", browser)
	scroll:Dock(FILL)

	local iconLayout = vgui.Create("DIconLayout", scroll)
	iconLayout:Dock(TOP)
	iconLayout:SetSpaceX(4)
	iconLayout:SetSpaceY(4)
	iconLayout:SetBorder(4)

	-- 模型过多提示
	local noteLabel = vgui.Create("DLabel", scroll)
	noteLabel:Dock(TOP)
	noteLabel:SetVisible(false)

	-- 渲染指定目录的图标网格（files 为文件名列表；serverFiltered 表示已按服务器内容过滤）
	function browser:RenderIcons(folder, files, serverFiltered)
		iconLayout:Clear()
		noteLabel:SetVisible(false)

		local capped = false
		local count = 0
		for _, f in ipairs(files) do
			count = count + 1
			if count > MAX_BROWSE_ICONS then
				capped = true
				break
			end

			local fullpath = folder.."/"..f
			local icon = vgui.Create("SpawnIcon", iconLayout)
			icon:SetModel(fullpath)
			icon:SetSize(80, 80)
			icon:SetTooltip(fullpath)
			icon.DoClick = function() frame:PreviewModel(fullpath, true) end
		end

		-- 提示行：过滤说明 + 数量上限说明
		local notes = {}
		if serverFiltered then
			table.insert(notes, translate.Format("nailplacer_server_filter", #files))
		end
		if capped then
			table.insert(notes, translate.Format("nailplacer_too_many_models", MAX_BROWSE_ICONS))
		end
		if #notes > 0 then
			noteLabel:SetText(table.concat(notes, " | "))
			noteLabel:SetVisible(true)
			noteLabel:SizeToContents()
		end
	end

	-- 用指定目录填充图标网格：优先服务器真实列表（缓存），
	-- 否则先用本地列表顶着，同时向服务器发起查询（应答到达后按服务器列表重建）
	function browser:PopulateIcons(folder)
		browser.CurrentFolder = folder

		local cached = frame.ServerFolderCache[folder]
		if cached then
			browser:RenderIcons(folder, cached, true)
			return
		end

		local files = file.Find(folder.."/*.mdl", "GAME")
		table.sort(files)
		browser:RenderIcons(folder, files, false)
		RequestFolderModels(folder)
	end

	-- 选中文件夹节点时刷新图标网格
	function tree:OnNodeSelected(node)
		local folder = node:GetFolder()
		if folder then browser:PopulateIcons(folder) end
	end

	-- 懒加载 models/ 整棵目录树（只显示文件夹）
	local modelsNode = tree:Root():AddFolder("models", "models", "GAME", false, "*")

	-- 默认展开并选中起始目录（FilePopulate 是同步的，展开后子节点立即可用；
	-- 选中会触发上面的 OnNodeSelected，同步填充右侧图标网格）
	local startNode
	modelsNode:SetExpanded(true, true)
	for _, child in ipairs(modelsNode:GetChildNodes()) do
		if child:GetFolder() == BROWSER_START_PATH then
			startNode = child
			break
		end
	end

	if startNode then
		startNode:SetExpanded(true, true)
		tree:SetSelectedItem(startNode)
	else
		-- 起始目录不存在时退回手动填充
		browser:PopulateIcons(BROWSER_START_PATH)
	end

	return browser
end

-- ============================================================================
-- 等级配置分页：人数区间 → 防线等级规则编辑（保存在服务器 data/zs/nail_levels.json）
-- 高等级会自动加载所有更低等级的防线
-- ============================================================================
local function BuildLevelPanel(frame, sheet, screenscale)
	local panel = vgui.Create("DPanel")
	panel.Paint = function() end
	sheet:AddSheet(translate.Get("nailplacer_levels"), panel, nil, false, false)

	-- 顶部提醒：高等级自动包含低等级
	local note = vgui.Create("DLabel", panel)
	note:Dock(TOP)
	note:DockMargin(6, 6, 6, 2)
	note:SetText(translate.Get("nailplacer_level_note"))
	note:SetTextColor(Color(255, 200, 80))
	note:SizeToContents()

	-- 复制模式开关：关闭 = 地图原素材被移走组成防线；开启 = 原素材不动，额外生成副本
	-- 用 DCheckBoxLabel（文本+复选框一体），说明文字放悬浮提示，避免说明盖住开关点不到
	local copyCheck = vgui.Create("DCheckBoxLabel", panel)
	copyCheck:Dock(TOP)
	copyCheck:DockMargin(6, 6, 6, 2)
	copyCheck:SetText(translate.Get("nailplacer_copymode"))
	copyCheck:SetTooltip(translate.Get("nailplacer_copymode_desc"))
	copyCheck:SetValue(false)

	panel.CopyCheck = copyCheck

	-- 当前生成等级（本地保存，生成道具时随包发送）
	local spawnSlider = vgui.Create("DNumSlider", panel)
	spawnSlider:Dock(TOP)
	spawnSlider:DockMargin(6, 4, 6, 2)
	spawnSlider:SetText(translate.Get("nailplacer_spawn_level"))
	spawnSlider:SetMin(1)
	spawnSlider:SetMax(5)
	spawnSlider:SetDecimals(0)
	spawnSlider:SetValue(currentSpawnLevel)
	function spawnSlider:OnValueChanged(val)
		currentSpawnLevel = math.Clamp(math.floor(val), 1, 5)
		SaveConfig()
	end

	-- 将准星道具设为当前等级
	local setEntBtn = vgui.Create("DButton", panel)
	setEntBtn:Dock(TOP)
	setEntBtn:DockMargin(6, 2, 6, 4)
	setEntBtn:SetText(translate.Get("nailplacer_level_setent"))
	setEntBtn.DoClick = function()
		net.Start("zs_nailplacer_setlevel")
			net.WriteUInt(currentSpawnLevel, 8)
		net.SendToServer()
	end

	-- 规则表头
	local header = vgui.Create("DLabel", panel)
	header:Dock(TOP)
	header:DockMargin(6, 2, 6, 2)
	header:SetText(translate.Get("nailplacer_level_rules").."（"..translate.Get("nailplacer_level_min").." / "..translate.Get("nailplacer_level_max").." / "..translate.Get("nailplacer_level_level").."）")
	header:SizeToContents()

	-- 规则行容器
	local rulesScroll = vgui.Create("DScrollPanel", panel)
	rulesScroll:Dock(FILL)
	rulesScroll:DockMargin(6, 2, 6, 2)

	panel.RuleRows = {}

	local function AddRuleRow(mn, mx, lv)
		local row = vgui.Create("DPanel", rulesScroll)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, 2)
		row:SetTall(24)
		row.Paint = function() end

		local minWang = vgui.Create("DNumberWang", row)
		minWang:Dock(LEFT)
		minWang:SetWide(70)
		minWang:SetMin(1)
		minWang:SetMax(64)
		minWang:SetValue(mn)

		local maxWang = vgui.Create("DNumberWang", row)
		maxWang:Dock(LEFT)
		maxWang:DockMargin(4, 0, 0, 0)
		maxWang:SetWide(70)
		maxWang:SetMin(1)
		maxWang:SetMax(64)
		maxWang:SetValue(mx)

		local lvWang = vgui.Create("DNumberWang", row)
		lvWang:Dock(LEFT)
		lvWang:DockMargin(4, 0, 0, 0)
		lvWang:SetWide(50)
		lvWang:SetMin(1)
		lvWang:SetMax(5)
		lvWang:SetValue(lv)

		local del = vgui.Create("DButton", row)
		del:Dock(RIGHT)
		del:SetWide(24)
		del:SetText("X")
		del.DoClick = function() row:Remove() end

		row.GetRule = function()
			return math.floor(minWang:GetValue()), math.floor(maxWang:GetValue()), math.floor(lvWang:GetValue())
		end

		table.insert(panel.RuleRows, row)
	end

	function panel:CollectRules()
		local rules = {}
		for _, row in ipairs(panel.RuleRows) do
			if IsValid(row) then
				local mn, mx, lv = row.GetRule()
				table.insert(rules, {min = mn, max = mx, level = lv})
			end
		end
		return rules
	end

	function panel:FillRules(rules)
		for _, row in ipairs(panel.RuleRows) do
			if IsValid(row) then row:Remove() end
		end
		panel.RuleRows = {}
		for _, r in ipairs(rules) do
			AddRuleRow(r.min or 1, r.max or 64, r.level or 1)
		end
	end

	-- 底部：状态 / 保存 / 添加（BOTTOM 停靠，先创建的在最下面）
	local statusLabel = vgui.Create("DLabel", panel)
	statusLabel:Dock(BOTTOM)
	statusLabel:DockMargin(6, 2, 6, 4)
	statusLabel:SetText("")
	frame.LevelStatusLabel = statusLabel

	local saveBtn = vgui.Create("DButton", panel)
	saveBtn:Dock(BOTTOM)
	saveBtn:DockMargin(6, 2, 6, 2)
	saveBtn:SetText(translate.Get("nailplacer_level_save"))
	saveBtn.DoClick = function()
		net.Start(NET_MSG.NAILPLACER_LEVELCFG)
			net.WriteUInt(1, 8)
			net.WriteString(util.TableToJSON({rules = panel:CollectRules(), copymode = copyCheck:GetChecked()}))
		net.SendToServer()
	end

	local addBtn = vgui.Create("DButton", panel)
	addBtn:Dock(BOTTOM)
	addBtn:DockMargin(6, 2, 6, 2)
	addBtn:SetText(translate.Get("nailplacer_level_add"))
	addBtn.DoClick = function() AddRuleRow(1, 64, 1) end

	return panel
end

-- ============================================================================
-- 模型选择界面
-- ============================================================================
local pNailPlacer

function OpenNailPlacerMenu(presetModel, copyColor)
	-- 菜单已存在：直接重新显示，保留上次的状态（选中的模型、浏览目录、最爱列表）
	if pNailPlacer and pNailPlacer:IsValid() then
		pNailPlacer:SetVisible(true)
		pNailPlacer:MakePopup()

		if presetModel then
			pNailPlacer:SelectModel(presetModel)
		end

		if copyColor then
			pNailPlacer.PreviewColor = copyColor

			if IsValid(pNailPlacer.ColorMixer) then
				pNailPlacer.ColorMixer:SetColor(copyColor)
			end

			pNailPlacer:ApplyPreviewMods()
		end

		return
	end

	local screenscale = BetterScreenScale()
	local wid, hei = 1066 * screenscale, 800 * screenscale

	local frame = vgui.Create("DFrame")
	frame:SetSize(wid, hei)
	frame:Center()
	frame:SetTitle(translate.Get("nailplacer_menu_title"))
	frame:SetDeleteOnClose(false) -- 关闭时仅隐藏不销毁，下次打开保留状态
	frame:MakePopup()
	pNailPlacer = frame

	frame.SelectedModel = nil
	frame.Favorites = LoadFavorites()
	-- 服务器模型内容缓存：目录列表与单模型存在性，菜单存活期间有效
	frame.ServerFolderCache = {}
	frame.ServerModelCache = {}

	-- 查找最爱中保存的名字
	function frame:FindFavoriteName(model)
		for _, fav in ipairs(frame.Favorites) do
			if fav.model == model then return fav.name end
		end
	end

	-- 刷新预览下方的名字显示：有自定义名字显示名字，否则显示模型短名
	-- 服务器确认没有该模型时，红色警告优先于一切显示
	function frame:UpdatePreviewName()
		if not IsValid(frame.PreviewName) then return end

		if frame.SelectedModel
		and frame.ServerModelCache
		and frame.ServerModelCache[frame.SelectedModel] == false then
			frame.PreviewName:SetText(translate.Get("nailplacer_server_missing"))
			frame.PreviewName:SetTextColor(Color(255, 80, 80))
			return
		end

		frame.PreviewName:SetTextColor(color_white)

		local name = IsValid(frame.NameEntry) and string.Trim(frame.NameEntry:GetValue()) or ""
		if name ~= "" then
			frame.PreviewName:SetText(name)
		elseif frame.SelectedModel then
			frame.PreviewName:SetText(ShortModelName(frame.SelectedModel))
		else
			frame.PreviewName:SetText("")
		end
	end

	-- 更新右侧预览（file.Exists 校验，未加载的模型也能正常预览）
	-- syncName 为 true 时同步名字输入框（从列表/浏览器/中键载入模型时用），
	-- 手动输入模型路径时不同步，避免清掉用户正在输入的名字
	function frame:PreviewModel(model, syncName)
		if ModelExists(model) then
			frame.SelectedModel = model
			frame.Preview:SetModel(model)
			frame:ApplyPreviewMods() -- SetModel 重建了实体，需重新应用缩放/颜色

			-- 同步填充自定义模型输入框（抑制回填触发的 OnValueChange，防止循环）
			if IsValid(frame.CustomEntry) and frame.CustomEntry:GetValue() ~= model then
				frame.m_SuppressEntry = true
				frame.CustomEntry:SetValue(model)
				frame.m_SuppressEntry = nil
			end

			if syncName then
				local favName = frame:FindFavoriteName(model) or ""
				if IsValid(frame.NameEntry) and frame.NameEntry:GetValue() ~= favName then
					frame.m_SuppressName = true
					frame.NameEntry:SetValue(favName)
					frame.m_SuppressName = nil
				end
			end

			-- 服务器存在性查询：未缓存过结果才请求，应答到达后刷新警告显示
			if frame.ServerModelCache and frame.ServerModelCache[model] == nil then
				RequestModelCheck(model)
			end

			frame:UpdatePreviewName()
		end
	end

	-- ===== 左侧：最爱 / 预设 / 模型浏览 分页 =====
	local sheet = vgui.Create("DPropertySheet", frame)
	sheet:Dock(LEFT)
	sheet:DockMargin(4, 4, 4, 4)
	sheet:SetWide(wid * 0.55)

	-- DPropertySheet 会自行管理分页面板尺寸，列表不做 Dock
	local function MakeModelList()
		local list = vgui.Create("DListView")
		list:SetMultiSelect(false)
		list:AddColumn(translate.Get("nailplacer_model")):SetFixedWidth(300 * screenscale)

		function list:OnRowSelected(rowIndex, row)
			-- 选中其中一页时清空另一页的选择
			local other = (self == frame.FavList) and frame.PresetList or frame.FavList
			if other then other:ClearSelection() end

			frame:PreviewModel(row.ModelPath, true)
		end

		-- 有自定义名字时显示名字，否则显示模型短名（完整路径在悬浮提示里）
		function list:AddModel(model, name)
			local display = (name and name ~= "") and name or ShortModelName(model)
			local line = self:AddLine(display)
			line.ModelPath = model
			line.ModelName = name
			line:SetTooltip(model)
			return line
		end

		return list
	end

	local favList = MakeModelList()
	frame.FavList = favList
	sheet:AddSheet(translate.Get("nailplacer_favorites"), favList, nil, false, false)

	local presetList = MakeModelList()
	frame.PresetList = presetList
	sheet:AddSheet(translate.Get("nailplacer_presets"), presetList, nil, false, false)

	-- 模型浏览分页（图形化浏览器）
	local browser = BuildModelBrowser(frame, sheet, screenscale)
	frame.Browser = browser

	-- 等级配置分页（人数区间 → 防线等级）
	frame.LevelPanel = BuildLevelPanel(frame, sheet, screenscale)

	-- 刷新最爱列表显示
	function frame:RefreshFavorites()
		favList:Clear()
		for _, fav in ipairs(frame.Favorites) do
			favList:AddModel(fav.model, fav.name)
		end
	end

	for _, model in ipairs(presetModels) do
		presetList:AddModel(model)
	end
	frame:RefreshFavorites()

	-- 默认激活模型浏览分页
	sheet:SetActiveTab(browser.SheetTab)

	-- ===== 右侧：预览 + 自定义 + 按钮 =====
	local right = vgui.Create("DPanel", frame)
	right:Dock(FILL)
	right:DockMargin(0, 4, 4, 4)
	right.Paint = function() end

	-- 模型预览（DModelPanelEx 自动调整摄像机）
	local preview = vgui.Create("DModelPanelEx", right)
	preview:Dock(TOP)
	preview:DockMargin(0, 0, 0, 4)
	preview:SetTall(hei * 0.32)
	frame.Preview = preview

	-- 预览名字显示（自定义名字或模型短名）
	local previewName = vgui.Create("DLabel", right)
	previewName:Dock(TOP)
	previewName:DockMargin(0, 0, 0, 4)
	previewName:SetTall(18)
	previewName:SetContentAlignment(5) -- 水平居中
	frame.PreviewName = previewName

	-- 自定义模型输入
	local customLabel = vgui.Create("DLabel", right)
	customLabel:Dock(TOP)
	customLabel:SetText(translate.Get("nailplacer_custom_model"))
	customLabel:SizeToContents()

	local customEntry = vgui.Create("DTextEntry", right)
	customEntry:Dock(TOP)
	customEntry:DockMargin(0, 2, 0, 4)
	customEntry:SetUpdateOnType(true)
	frame.CustomEntry = customEntry
	function customEntry:OnValueChange(value)
		if frame.m_SuppressEntry then return end -- 程序回填不触发预览，防止循环
		frame:PreviewModel(string.Trim(value))
	end

	-- 自定义名字输入（显示在预览下方与最爱列表里，方便快速识别）
	local nameLabel = vgui.Create("DLabel", right)
	nameLabel:Dock(TOP)
	nameLabel:SetText(translate.Get("nailplacer_custom_name"))
	nameLabel:SizeToContents()

	local nameEntry = vgui.Create("DTextEntry", right)
	nameEntry:Dock(TOP)
	nameEntry:DockMargin(0, 2, 0, 4)
	nameEntry:SetUpdateOnType(true)
	frame.NameEntry = nameEntry
	function nameEntry:OnValueChange(value)
		if frame.m_SuppressName then return end -- 程序回填不触发，防止循环
		frame:UpdatePreviewName()
	end

	-- 模型缩放（均匀缩放，与 sv_nailsave 的 scale 字段一致；参考 SCK 的 x/y/z，
	-- 但物理道具非均匀缩放只有渲染矩阵、碰撞不同步，故只提供均匀缩放）
	local scaleSlider = vgui.Create("DNumSlider", right)
	scaleSlider:Dock(TOP)
	scaleSlider:DockMargin(0, 2, 0, 2)
	scaleSlider:SetText(translate.Get("nailplacer_scale"))
	scaleSlider:SetMin(0.1)
	scaleSlider:SetMax(4)
	scaleSlider:SetDecimals(2)
	scaleSlider:SetValue(1)

	-- 颜色调整（参考 SCK 的 DColorMixer）
	local colorLabel = vgui.Create("DLabel", right)
	colorLabel:Dock(TOP)
	colorLabel:SetText(translate.Get("nailplacer_color"))
	colorLabel:SizeToContents()

	local colorMixer = vgui.Create("DColorMixer", right)
	colorMixer:Dock(TOP)
	colorMixer:DockMargin(0, 2, 0, 4)
	colorMixer:SetTall(90 * screenscale)
	colorMixer:SetPalette(true)
	colorMixer:SetAlphaBar(true)
	colorMixer:SetWangs(true)
	local startColor = copyColor or Color(255,255,255)
	colorMixer:SetColor(startColor)

	frame.PreviewColor = startColor
	frame.ColorMixer = colorMixer
	frame.PreviewScale = 1

	function frame:ApplyPreviewMods()
		local ent = frame.Preview.Entity
		if not IsValid(ent) then return end

		local scale = scaleSlider:GetValue()
		ent:SetModelScale(scale, 0)
		-- 不调 AutoCam——缩放后重新取景会抵消视觉变化

		local col = colorMixer:GetColor()
		frame.PreviewColor = col
		frame.Preview:SetColor(col)
	end

	function colorMixer:ValueChanged(col)
		frame:ApplyPreviewMods()
	end

	local lastColor
	colorMixer.Think = function(self)
	local col = self:GetColor()
		if not lastColor
		or col.r ~= lastColor.r
		or col.g ~= lastColor.g
		or col.b ~= lastColor.b
		or col.a ~= lastColor.a then

			lastColor = Color(col.r,col.g,col.b,col.a)
			frame:ApplyPreviewMods()
		end
	end
	
	local previewBasePaint = preview.Paint
	function preview:Paint(w, h)
		local col = frame.PreviewColor or color_white
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
		render.SetBlend(col.a / 255)
		previewBasePaint(self, w, h)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
	end


	
	function scaleSlider:OnValueChanged(value) frame:ApplyPreviewMods() end
	function colorMixer:ValueChanged(col) frame:ApplyPreviewMods() end

	-- 校验当前选中或输入的模型，返回模型路径或 nil
	local function GetChosenModel()
		local model = frame.SelectedModel or string.Trim(customEntry:GetValue())
		if not ModelExists(model) then
			MySelf:PrintMessage(HUD_PRINTCENTER, translate.Get("nailplacer_invalid_model"))
			return nil
		end

		return model
	end

	-- 按钮构造器（BOTTOM 停靠，后创建的在上面）
	local function MakeButton(text, onclick)
		local btn = vgui.Create("DButton", right)
		btn:Dock(BOTTOM)
		btn:DockMargin(0, 2, 0, 2)
		btn:SetText(text)
		btn.DoClick = onclick
		return btn
	end

	-- 生成按钮（最底部），携带当前缩放/颜色
	MakeButton(translate.Get("nailplacer_spawn"), function()
		local model = GetChosenModel()
		if not model then return end

		-- 已确认服务器没有该模型：本地直接拦截（服务器仍会权威复查）
		if frame.ServerModelCache and frame.ServerModelCache[model] == false then
			surface.PlaySound("buttons/button10.wav")
			MySelf:PrintMessage(HUD_PRINTCENTER, translate.Format("nailplacer_spawn_blocked", model))
			return
		end

		SpawnModel(model, scaleSlider:GetValue(), colorMixer:GetColor())
	end)

	-- 加载钉子按钮（sv_nailsave 的 concommand）
	MakeButton(translate.Get("nailplacer_load_nails"), function()
		RunConsoleCommand("zs_loadnails")
	end)

	-- 保存钉子按钮（sv_nailsave 的 concommand）
	MakeButton(translate.Get("nailplacer_save_nails"), function()
		RunConsoleCommand("zs_savenails")
	end)

	-- 移除最爱按钮
	MakeButton(translate.Get("nailplacer_remove_favorite"), function()
		local lineID = favList:GetSelectedLine()
		if not lineID then return end
		local model = favList:GetLine(lineID).ModelPath

		for i, fav in ipairs(frame.Favorites) do
			if fav.model == model then
				table.remove(frame.Favorites, i)
				break
			end
		end

		SaveFavorites(frame.Favorites)
		frame:RefreshFavorites()
	end)

	-- 添加最爱按钮（加入当前选中或输入框中的模型；已存在则更新名字）
	MakeButton(translate.Get("nailplacer_add_favorite"), function()
		local model = GetChosenModel()
		if not model then return end

		local name = string.Trim(nameEntry:GetValue())

		for _, fav in ipairs(frame.Favorites) do
			if fav.model == model then
				fav.name = name -- 已在最爱中：更新自定义名字
				SaveFavorites(frame.Favorites)
				frame:RefreshFavorites()
				return
			end
		end

		table.insert(frame.Favorites, {model = model, name = name})
		SaveFavorites(frame.Favorites)
		frame:RefreshFavorites()
	end)

	-- 中键复制模型等情况下的预选（重开已存在的菜单时也会调用）
	function frame:SelectModel(model)
		frame:PreviewModel(model, true) -- PreviewModel 会同步填充自定义输入框与名字
	end

	-- 打开菜单时向服务器请求一次等级规则（"等级配置"分页用）
	net.Start(NET_MSG.NAILPLACER_LEVELCFG)
		net.WriteUInt(0, 8)
	net.SendToServer()

	if presetModel then frame:SelectModel(presetModel) end
end

-- ============================================================================
-- 鼠标中键（MOUSE_MIDDLE）：复制准星实体的模型路径并打开模型选择界面
-- ============================================================================
function SWEP:Think()
	local owner = self:GetOwner()
	if owner ~= MySelf then return end
	if not self.CanUseNailPlacer(owner) then return end

	local middledown = not vgui.CursorVisible() and input.IsMouseDown(MOUSE_MIDDLE) or nil
	if middledown == self.m_MiddleDown then return end
	self.m_MiddleDown = middledown
	if not middledown then return end

	local tr = owner:TraceLine(self.NailDistance, MASK_SOLID)
	local ent = tr.Entity
	if not IsValid(ent) then return end

	local model = ent:GetModel()
	if not model or model == "" or string.sub(model, 1, 1) == "*" then return end

	local col = ent:GetColor()
	if not col then
		col = color_white
	end

	if col.a <= 0 then
		col.a = 255
	end

	SetClipboardText(model)

	owner:PrintMessage(
		HUD_PRINTCENTER,
		translate.Format("nailplacer_copied", model)
	)

	OpenNailPlacerMenu(model, col)
end

-- ============================================================================
-- HUD：按键提示与准星
-- ============================================================================
function SWEP:DrawHUD()
	local screenscale = BetterScreenScale()

	local text = translate.Get("nailplacer_help")
	local texh = draw.GetFontHeight("ZSHUDFontSmall")
	draw.SimpleTextBlurry(text, "ZSHUDFontSmall", ScrW() * 0.5, ScrH() - texh - 8 * screenscale, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)

	if GetConVar("crosshair"):GetInt() ~= 1 then return end

	-- 简单的准星点
	local x, y = ScrW() * 0.5, ScrH() * 0.5
	local size = math.max(1, math.floor(2 * screenscale))
	surface.SetDrawColor(0, 255, 0, 220)
	surface.DrawRect(x - size * 0.5, y - size * 0.5, size, size)
end

-- 左键开菜单：shared.lua 的服务端 SWEP:PrimaryAttack 发 net 消息到这里。
-- 不能走客户端 PrimaryAttack（单人模式预测关闭不会触发），
-- 也不能用全局 Think 轮询鼠标（切枪确认点击/按住左键切枪会误触发）。
net.Receive("zs_nailplacer_menu", function()
	OpenNailPlacerMenu()
end)

-- 服务器应答：模型存在性查询
net.Receive("zs_nailplacer_modelcheck", function()
	local mode = net.ReadUInt(8)

	if mode == 0 then
		-- 目录列表：写入缓存；仍在浏览同一目录才重建网格，避免覆盖用户后续操作
		local folder = net.ReadString()
		local count = net.ReadUInt(16)
		local files = {}
		for i = 1, count do files[i] = net.ReadString() end

		if not (pNailPlacer and pNailPlacer:IsValid()) then return end
		if not pNailPlacer.ServerFolderCache then pNailPlacer.ServerFolderCache = {} end
		pNailPlacer.ServerFolderCache[folder] = files

		local browser = pNailPlacer.Browser
		if browser and browser.CurrentFolder == folder then
			browser:RenderIcons(folder, files, true)
		end
	else
		-- 单模型：写入缓存；仍是当前预览模型才刷新警告显示
		local model = net.ReadString()
		local exists = net.ReadBool()

		if not (pNailPlacer and pNailPlacer:IsValid()) then return end
		if not pNailPlacer.ServerModelCache then pNailPlacer.ServerModelCache = {} end
		pNailPlacer.ServerModelCache[model] = exists

		if pNailPlacer.SelectedModel == model then
			pNailPlacer:UpdatePreviewName()
		end
	end
end)

-- 服务器拦截：生成的模型在服务器上不存在
net.Receive("zs_nailplacer_badmodel", function()
	local model = net.ReadString()

	surface.PlaySound("buttons/button10.wav")
	local msg = translate.Format("nailplacer_spawn_blocked", model)
	MySelf:PrintMessage(HUD_PRINTCENTER, msg)
	MySelf:PrintMessage(HUD_PRINTTALK, msg) -- 聊天栏留档，方便回看完整路径
end)

-- 服务器应答：等级规则（mode 0 = 请求回复，mode 1 = 保存回复）
net.Receive(NET_MSG.NAILPLACER_LEVELCFG, function()
	local mode = net.ReadUInt(8)
	local data = util.JSONToTable(net.ReadString())

	if not (pNailPlacer and pNailPlacer:IsValid()) then return end
	if not (data and type(data.rules) == "table") then return end

	if pNailPlacer.LevelPanel and pNailPlacer.LevelPanel.FillRules then
		pNailPlacer.LevelPanel:FillRules(data.rules)
	end

	if pNailPlacer.LevelPanel and IsValid(pNailPlacer.LevelPanel.CopyCheck) and data.copymode ~= nil then
		pNailPlacer.LevelPanel.CopyCheck:SetValue(not not data.copymode)
	end

	if mode == 1 and IsValid(pNailPlacer.LevelStatusLabel) then
		pNailPlacer.LevelStatusLabel:SetText(translate.Get("nailplacer_level_saved"))
		pNailPlacer.LevelStatusLabel:SizeToContents()
	end
end)

-- ============================================================================
-- 等待阶段 HUD：本局将加载的防线等级（所有玩家可见）
-- ============================================================================
local nailLevelRules
local nailLevelHasSave = false

net.Receive(NET_MSG.NAILPLACER_LEVELRULES, function()
	local data = util.JSONToTable(net.ReadString())
	if data and type(data.rules) == "table" then
		nailLevelRules = data.rules
		nailLevelHasSave = not not data.has
	end
end)

-- 只统计人类玩家（排除机器人），与服务器等级判定保持一致
local function GetHumanPlayerCount()
	local count = 0
	for _, ply in ipairs(player.GetAll()) do
		if ply:IsValid() and not ply:IsBot() then
			count = count + 1
		end
	end
	return count
end

local function GetNailLevelForCount(count)
	if not nailLevelRules then return 1 end
	local maxlv = 1
	for _, r in ipairs(nailLevelRules) do
		if count >= r.min and count <= r.max then return r.level end
		maxlv = math.max(maxlv, r.level)
	end
	return maxlv
end

hook.Add("HUDPaint", "ZS_NailPlacer_LevelInfo", function()
	if not nailLevelHasSave then return end
	if not nailLevelRules then return end
	if not GAMEMODE then return end
	if GAMEMODE:GetWave() ~= 0 or GAMEMODE:GetWaveActive() then return end

	local count = GetHumanPlayerCount()
	if count == 0 then return end
	local level = GetNailLevelForCount(count)
	local text = translate.Format("nailplacer_hud_info", count, level, level)

	draw.SimpleTextBlurry(text, "ZSHUDFontSmall", ScrW() * 0.5, ScrH() * 0.4, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
end)

-- ============================================================================
-- 幽灵预显：服务器下发防线数据，客户端本地渲染（白色/红色线框）
-- 每个玩家按自己的 ghostmode convar 独立决定显示/隐藏/颜色，无需依赖 DrawEntity
-- ============================================================================
local nailGhosts = {} -- {model = ClientsideModel, pos, level}

net.Receive(NET_MSG.NAILPLACER_GHOSTS, function()
	local count = net.ReadUInt(16)

	for _, g in ipairs(nailGhosts) do
		if IsValid(g.model) then g.model:Remove() end
	end
	nailGhosts = {}

	for i = 1, count do
		local model = net.ReadString()
		local pos = net.ReadVector()
		local ang = net.ReadAngle()
		local scale = net.ReadFloat()
		local bodygroups = net.ReadString()
		local skin = net.ReadUInt(8)
		local level = net.ReadUInt(8)

		local m = ClientsideModel(model, RENDER_GROUP_OPAQUE_ENTITY)
		if IsValid(m) then
			m:SetPos(pos)
			m:SetAngles(ang)
			m:SetSkin(skin)
			if bodygroups ~= "" then m:SetBodyGroups(bodygroups) end
			if scale ~= 1 then m:SetModelScale(scale, 0) end
			m:SetMaterial("models/wireframe")
			m:SetColor(Color(255, 255, 255))
			m:SetNoDraw(true) -- 手动绘制

			table.insert(nailGhosts, {model = m, pos = pos, level = level})
		end
	end
end)

-- 幽灵可见性条件：等待阶段且规则已同步
local function NailGhostsVisible()
	if #nailGhosts == 0 then return false end
	if not nailLevelRules then return false end
	if not GAMEMODE then return false end
	if GAMEMODE:GetWave() ~= 0 or GAMEMODE:GetWaveActive() then return false end
	return true
end

-- 3D 渲染：白色（本局会加载）或红色（ghostmode 1 下的超等级防线）
hook.Add("PostDrawOpaqueRenderables", "ZS_NailPlacer_Ghosts", function()
	if not NailGhostsVisible() then return end

	local currentLevel = GetNailLevelForCount(GetHumanPlayerCount())
	local mode = (GetConVar("zs_nailplacer_ghostmode") and GetConVar("zs_nailplacer_ghostmode"):GetInt()) or 0

	cam.Start3D()
		for _, g in ipairs(nailGhosts) do
			if mode == 1 or g.level <= currentLevel then
				if mode == 1 and g.level > currentLevel then
					render.SetColorModulation(1, 0.25, 0.25) -- 红色线框
				else
					render.SetColorModulation(1, 1, 1)
				end
				g.model:DrawModel()
				render.SetColorModulation(1, 1, 1)
			end
		end
	cam.End3D()
end)

-- 2D：在幽灵上方显示防线自身的等级
-- 不穿墙（眼睛到标签的射线仅世界几何体阻挡）、距离缩放但有上限
hook.Add("HUDPaint", "ZS_NailPlacer_GhostLevels", function()
	if not NailGhostsVisible() then return end

	local currentLevel = GetNailLevelForCount(GetHumanPlayerCount())
	local mode = (GetConVar("zs_nailplacer_ghostmode") and GetConVar("zs_nailplacer_ghostmode"):GetInt()) or 0

	local lp = LocalPlayer()
	if not IsValid(lp) then return end
	local eye = lp:EyePos()
	local labelOffset = Vector(0, 0, 18)

	for _, g in ipairs(nailGhosts) do
		if mode == 1 or g.level <= currentLevel then
			local labelPos = g.pos + labelOffset
			local dist = eye:Distance(labelPos)
			if dist > 2500 or dist < 16 then goto ghostlevelskip end

			-- 遮挡检测：仅世界几何体算阻挡（幽灵为客户端模型不参与），避免穿墙
			local tr = util.TraceLine({
				start = eye,
				endpos = labelPos,
				mask = MASK_OPAQUE,
				filter = function(ent) return not ent:IsWorld() end,
			})
			if tr.Hit then goto ghostlevelskip end

			local scr = labelPos:ToScreen()
			if not scr.visible then goto ghostlevelskip end

			-- 距离缩放：远小近大，但增长幅度有上限，近距离不会撑满屏幕
			local scale = math.Clamp(1000 / dist, 0.5, 1.25)

			local col = (mode == 1 and g.level > currentLevel) and Color(255, 80, 80) or Color(255, 255, 255)
			draw.SimpleText(translate.Format("nailplacer_ghost_level", g.level), "ZSHUDFontSmall", scr.x, scr.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, scale)
		end
		::ghostlevelskip::
	end
end)
