-- ============================================================================
-- PClassSelect - 僵尸职业选择界面（按 F3 打开）
-- 布局：标题 + 7 个分类标签页（普通僵尸/其他/变异/迷你BOSS/BOSS/超级BOSS/巨型BOSS）
--       + 左侧 3D 模型卡片网格 + 右侧详情面板
-- 详情面板包含属性条（波次/生命/速度/点数/近战伤害/攻击距离/攻击判定）与职业描述
-- 注册面板：
--   ClassSelect        主窗口
--   ClassSelectTab     顶部分类标签页按钮（选中=白底，未选中=半透明黑底）
--   ClassButton        职业卡片（半透明黑圆角背景 + 名称 + 3D 模型 + 状态行）
--   ClassDetailPanel   右侧职业详情（属性条 + 描述）
--   ZombieClassPreview 3D 模型预览（套用职业客户端特效回调，支持整体染色与面板裁剪）
--                      默认关闭（zs_pclass_3d 0），显示 2D 击杀图标（原版形式）
-- ConVar：zs_bossclass（BOSS 选择）、zs_pclassdebug（诊断输出）、zs_pclass_3d（3D 预览开关）
-- 全局函数：GM:OpenClassSelect（服务器经 SendLua 调用）
-- 分类字段：CLASS.Boss / CLASS.MiniBoss / CLASS.SuperBoss / CLASS.MegaBoss / CLASS.Hidden
-- 视觉优化（v1.0，纯 UI 无逻辑改动）：
--   1) 全屏黑色遮罩 + 主窗口深色背景，降低游戏画面干扰
--   2) 当前职业卡片高亮边框 + 轻微发光 + 名称增强
--   3) 属性条按类型分色（生命绿/速度蓝/攻击红/点数金/距离橙/判定紫）
--   4) 详情文字层级：名称最大（ZSHUDFont）> 属性（Smallest）> 描述（BodyText）
--   5) 顶部分类标签选中态增加底部高亮线
--   6) 锁定卡片：模型灰化 + 降透明度 + 挂锁图标 + 锁定文字突出
--   7) 滚动条统一为窄半透明样式（隐藏默认按钮与背景）
--   8) 模型预览：悬停平滑放大（FOV 插值）+ 面板内暗色底
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 主窗口
-- [位置] ClassSelect / GM:OpenClassSelect() / Init() / PerformLayout() / Paint()
-- [作用] 全屏遮罩 + 标题 + 关闭按钮 + 代币余额，布局标签/网格/详情
-- [常改] 窗口尺寸、背景、标题样式
--
-- [区域] 分类标签页
-- [位置] ClassSelectTab / SetCategory()
-- [作用] 7 个职业分类标签，选中白底+绿线
-- [常改] 标签字体、选中态样式
--
-- [区域] 职业卡片网格
-- [位置] ClassButton / BuildClassGrid() / SetClassTable() / Think()
-- [作用] 职业卡片：名称/3D 预览/状态行，当前=绿框/锁定=灰化+挂锁
-- [常改] 卡片尺寸、状态颜色、状态文字
--
-- [区域] 3D 模型预览
-- [位置] ZombieClassPreview / SetClassTable() / Paint() / FitCameraToBounds()
-- [作用] 职业特效回调渲染 + 面板裁剪 + 悬停放大，缺失回退 2D 图标
-- [常改] 相机、染色、回调容错
--
-- [区域] 右侧详情面板
-- [位置] ClassDetailPanel / SetClassTable() / Paint() / RebuildDescLabels()
-- [作用] 职业名称/属性条(分色)/描述滚动区
-- [常改] 属性行定义、颜色、字体层级
-- ============================================================================

-- 创建客户端变量保存选择的 BOSS 职业
CreateClientConVar("zs_bossclass", "", true, true)

-- 调试开关：zs_pclassdebug 1 开启诊断输出（控制台输入）
CreateClientConVar("zs_pclassdebug", "0", true, true)

-- 3D 模型预览开关：zs_pclass_3d 1 启用 3D 模型预览，默认 0 显示 2D 击杀图标（原版形式）
CreateClientConVar("zs_pclass_3d", "0", true, true)

-- ============================================================================
-- IsDebugEnabled - 是否开启诊断输出
-- ============================================================================
local function IsDebugEnabled()
	local cvar = GetConVar("zs_pclassdebug")
	return cvar and cvar:GetBool() or false
end

-- ============================================================================
-- Is3DPreviewEnabled - 是否启用 3D 模型预览（默认关闭 = 2D 击杀图标）
-- ============================================================================
local function Is3DPreviewEnabled()
	local cvar = GetConVar("zs_pclass_3d")
	return cvar and cvar:GetBool() or false
end

-- ============================================================================
-- GetMiniBossShopData - 迷你BOSS购买数据查询（代币价格/商店签名）
-- 惰性构建自僵尸商店注册（sh_zombieshop.lua 的 AddMiniBossPurchase，客户端共享可见）
-- 返回表：职业 Name -> {Price = 代币价格, Signature = 商店购买签名}
-- ============================================================================
local MiniBossShopData
local function GetMiniBossShopData()
	if MiniBossShopData then return MiniBossShopData end

	MiniBossShopData = {}
	for _, mut in ipairs(GAMEMODE.Mutations) do
		if mut.MiniBossClass then
			MiniBossShopData[mut.MiniBossClass] = {Price = mut.Price, Signature = mut.Signature}
		end
	end
	return MiniBossShopData
end

-- 主窗口
local Window

-- 热路径缓存
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local math_Clamp = math.Clamp
local string_format = string.format
local string_gmatch = string.gmatch
local string_sub = string.sub
local table_sort = table.sort
local table_insert = table.insert
local ipairs = ipairs
local draw_SimpleText = draw.SimpleText
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_SetTexture = surface.SetTexture
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_GetScissorRect = surface.GetScissorRect
local render_SuppressEngineLighting = render.SuppressEngineLighting
local render_SetLightingOrigin = render.SetLightingOrigin
local render_ResetModelLighting = render.ResetModelLighting
local render_SetModelLighting = render.SetModelLighting
local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend
local render_SetScissorRect = render.SetScissorRect
local render_ClearDepth = render.ClearDepth
local render_ModelMaterialOverride = render.ModelMaterialOverride
local pcall = pcall
local math_cos = math.cos
local math_sin = math.sin
local math_pi = math.pi
local draw_GetFontHeight = draw.GetFontHeight

-- 渐变纹理
local texUpEdge = surface.GetTextureID("gui/gradient_up")
local texDownEdge = surface.GetTextureID("gui/gradient_down")

-- 调试用：记录已打印过诊断的卡片数（避免刷屏）
local CardDebugCount = 0
-- 调试用：记录已打印过模型诊断的职业名（避免重复刷屏）
local DebuggedModelFails = {}

-- ============================================================================
-- OpenClassSelect - 打开职业选择界面
-- ============================================================================
function GM:OpenClassSelect()
	if Window and Window:IsValid() then Window:Remove() end

	Window = vgui.Create("ClassSelect")
	Window:SetAlpha(0)
	Window:AlphaTo(255, 0.1)

	Window:MakePopup()

	Window:InvalidateLayout()

	PlayMenuOpenSound()
end

-- ============================================================================
-- ComputeClassStatMaxes - 统计所有职业的属性最大值（用于详情属性条比例）
-- ============================================================================
local function ComputeClassStatMaxes()
	local maxes = {Health = 1, Speed = 1, Points = 1, MeleeDamage = 1, MeleeRange = 1, MeleeSize = 1}

	for i = 1, #GAMEMODE.ZombieClasses do
		local classtab = GAMEMODE.ZombieClasses[i]
		if classtab and not classtab.Disabled then
			maxes.Health = math_max(maxes.Health, classtab.Health or 0)
			maxes.Speed = math_max(maxes.Speed, classtab.Speed or 0)
			maxes.Points = math_max(maxes.Points, classtab.Points or 0)

			local weptab = classtab.SWEP and weapons.Get(classtab.SWEP)
			if weptab then
				maxes.MeleeDamage = math_max(maxes.MeleeDamage, weptab.MeleeDamage or 0)
				maxes.MeleeRange = math_max(maxes.MeleeRange, weptab.MeleeRange or 0)
				maxes.MeleeSize = math_max(maxes.MeleeSize, weptab.MeleeSize or 0)
			end
		end
	end

	return maxes
end

-- ============================================================================
-- WrapTextToWidth - 按像素宽度手动换行（UTF-8 安全，兼容无空格的中文文本）
-- 优先在空格处断行；无空格时按字符断行；尊重文本中已有的 \n
-- ============================================================================
local utf8pattern = "[%z\1-\127\194-\244][\128-\191]*"

local function WrapTextToWidth(text, font, maxw)
	local lines = {}

	surface_SetFont(font)

	for paragraph in string_gmatch(text .. "\n", "(.-)\n") do
		local current = ""
		local lastspace

		for char in string_gmatch(paragraph, utf8pattern) do
			if char == " " then lastspace = #current + 1 end

			local trial = current .. char
			if surface_GetTextSize(trial) > maxw and current ~= "" then
				if lastspace and lastspace > 1 then
					-- 在上一个空格处断行，空格后的内容移到下一行
					table_insert(lines, string_sub(current, 1, lastspace - 1))
					current = string_sub(current, lastspace + 1) .. char
				else
					table_insert(lines, current)
					current = char
				end

				lastspace = nil
				for i = 1, #current do
					if string_sub(current, i, i) == " " then lastspace = i end
				end
			else
				current = trial
			end
		end

		table_insert(lines, current)
	end

	return lines
end

-- ============================================================================
-- DrawPadlock - 用 surface 图元绘制简单挂锁图标（不依赖系统字体表情符号）
-- x/y 为左上角，size 为图标边长；用于锁定职业卡片的状态行左侧
-- ============================================================================
local function DrawPadlock(x, y, size, col)
	local bodyw = size * 0.6
	local bodyh = size * 0.5
	local bodyx = x + (size - bodyw) / 2
	local bodyy = y + size - bodyh

	draw.RoundedBox(2, bodyx, bodyy, bodyw, bodyh, col)

	-- 锁梁：双层半圆弧 + 横向连接线，模拟圆弧厚度
	local cx = x + size / 2
	local cy = bodyy - size * 0.02
	local ro = size * 0.28
	local ri = ro - size * 0.14
	local steps = 10
	surface_SetDrawColor(col.r, col.g, col.b, col.a)
	local pxo, pyo, pxi, pyi
	for i = 0, steps do
		local ang = math_pi * (1 - i / steps)
		local nxo = cx + math_cos(ang) * ro
		local nyo = cy - math_sin(ang) * ro
		local nxi = cx + math_cos(ang) * ri
		local nyi = cy - math_sin(ang) * ri
		if i > 0 then
			surface.DrawLine(pxo, pyo, nxo, nyo)
			surface.DrawLine(pxi, pyi, nxi, nyi)
			surface.DrawLine(pxo, pyo, pxi, pyi)
		end
		pxo, pyo, pxi, pyi = nxo, nyo, nxi, nyi
	end
end

-- ============================================================================
-- StyleScrollBar - 统一滚动条样式：窄、低透明、隐藏默认按钮与背景
-- 仅保留辅助功能可见度（轨道近乎隐藏，滑块悬停时略微提亮）
-- 需在面板 PerformLayout 中再次 SetWide 以适配当前屏幕缩放
-- ============================================================================
local function StyleScrollBar(vbar, scale)
	if not vbar or not vbar:IsValid() then return end

	vbar:SetWide(math_floor(4 * scale))
	if vbar.btnUp then vbar.btnUp:SetVisible(false) end
	if vbar.btnDown then vbar.btnDown:SetVisible(false) end

	vbar.Paint = function(self, w, h)
		surface_SetDrawColor(0, 0, 0, 35)
		surface_DrawRect(0, 0, w, h)

		-- 画布高度：优先 VBar 自带接口，缺失时回退到父级 DScrollPanel 画布
		local canvas
		if self.GetCanvasSize then
			canvas = self:GetCanvasSize()
		else
			local parent = self:GetParent()
			if parent and parent.GetCanvas then
				local c = parent:GetCanvas()
				if c and c:IsValid() then canvas = c:GetTall() end
			end
		end

		local view = self:GetTall()
		if canvas and canvas > view then
			local th = math_max(28, view * view / canvas)
			local ty = (self:GetScroll() or 0) * (view - th)
			local alpha = self:IsHovered() and 85 or 55
			surface_SetDrawColor(255, 255, 255, alpha)
			draw.RoundedBox(w * 0.5, 1, math_floor(ty + 1), math_max(1, w - 2), math_max(4, math_floor(th - 2)), Color(255, 255, 255, alpha))
		end

		return true
	end
end

-- 详情面板属性行定义（顺序即显示顺序）
-- Get(classtable, weapontable) 取值；Max(maxes) 取比例上限；Decimals 表示保留一位小数
-- Color 为该属性条与标签的强调色（低饱和版本：保持分类区分，避免视觉刺眼）
local STAT_ROW_DEFS = {
	{Label = "zsclassstat_wave", Get = function(ct) return ct.Wave or 0 end, Max = function() return GAMEMODE.NumberOfWaves or 6 end, Color = Color(175, 175, 175)},
	{Label = "zsclassstat_health", Get = function(ct) return ct.Health or 0 end, Max = function(m) return m.Health end, Color = Color(120, 180, 120)},
	{Label = "zsclassstat_speed", Get = function(ct) return ct.Speed or 0 end, Max = function(m) return m.Speed end, Color = Color(120, 150, 195)},
	{Label = "zsclassstat_points", Get = function(ct) return ct.Points or 0 end, Max = function(m) return m.Points end, Color = Color(200, 175, 105)},
	{Label = "zsclassstat_meleedamage", Get = function(ct, wep) return wep and wep.MeleeDamage end, Max = function(m) return m.MeleeDamage end, Color = Color(195, 115, 115)},
	{Label = "zsclassstat_reach", Get = function(ct, wep) return wep and wep.MeleeRange end, Max = function(m) return m.MeleeRange end, Color = Color(200, 150, 95)},
	{Label = "zsclassstat_meleesize", Get = function(ct, wep) return wep and wep.MeleeSize end, Max = function(m) return m.MeleeSize end, Decimals = true, Color = Color(165, 140, 200)},
}

-- ============================================================================
-- ZombieClassPreview - 3D 模型预览（继承 DModelPanelEx，支持整体染色）
-- 预览会套用职业的客户端渲染回调（PrePlayerDraw / PostPlayerDraw /
-- BuildBonePositions），半透明、材质覆盖、发光眼睛、隐藏腿部等特殊效果
-- 与游戏中一致；回调出错时退化为普通绘制。
-- 模型绘制前重新套用面板裁剪矩形（同官方 DModelPanel:DrawModel），
-- 防止模型渲染到卡片/滚动区域之外
-- ============================================================================
local PANEL = {}

function PANEL:Init()
	-- 与 DModelPanelEx:Init 保持一致（不调用 BaseClass，避免连锁初始化问题）
	self.Entity = nil
	self.WElements = nil
	self.wRenderOrder = nil

	self.Angles = Angle(0, 0, 0)          -- 面板当前角度（用于自动旋转）
	self.AutoRotate = true                -- 自动旋转开关
	self.RotateSpeed = 30                 -- 角速度 (degrees / second)
	self.ShowBaseModel = true

	self.TintColor = nil                  -- 整体染色（nil = 不染色）
	self.ClassTable = nil                 -- 当前预览的职业

	-- 复制 DModelPanel:Init 的默认字段（vgui.Create 不会链式调用基类 Init，
	-- 必须自己初始化，否则模型光照/相机为空导致模型不可见）
	self.FarZ = 4096
	self:SetCamPos(Vector(50, 50, 50))
	self:SetLookAt(Vector(0, 0, 40))
	self:SetFOV(70)
	self:SetColor(color_white)
	self:SetAmbientLight(Color(90, 90, 90))
	self.DirectionalLight = {}
	self:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
	self:SetDirectionalLight(BOX_FRONT, Color(255, 255, 255))

	-- 悬停轻微放大：BaseFOV 为基准，HoverTarget 平滑插值到 HoverZoom
	self.BaseFOV = 70
	self.HoverZoom = 0
	self.HoverTarget = 0
end

-- ============================================================================
-- SetTintColor - 设置整体染色（未解锁职业传红色，解锁后传 nil 清除）
-- ============================================================================
function PANEL:SetTintColor(col)
	self.TintColor = col
end

-- ============================================================================
-- SetHovered - 设置悬停目标（由 ClassButton:Think 每帧同步），Paint 中平滑缩放
-- ============================================================================
function PANEL:SetHovered(hovered)
	self.HoverTarget = hovered and 1 or 0
end

-- ============================================================================
-- ResetBoneScales - 还原所有被 ManipulateBoneScale 缩放的骨骼
-- 注意：SetManipulateBoneScale 是 Player 专属方法，ClientsideModel 上没有，
-- 必须用 Entity 级方法 ManipulateBoneScale 还原
-- ============================================================================
function PANEL:ResetBoneScales()
	if not IsValid(self.Entity) then return end

	for bone = 0, self.Entity:GetBoneCount() - 1 do
		local s = self.Entity:GetManipulateBoneScale(bone)
		if s and (s.x ~= 1 or s.y ~= 1 or s.z ~= 1) then
			self.Entity:ManipulateBoneScale(bone, Vector(1, 1, 1))
		end
	end
end

-- ============================================================================
-- SetClassTable - 设置职业数据（模型创建 + 体型缩放 + 相机取景）
-- 模型创建带多级兜底：
--   1) 客户端缺少职业模型文件时回退到基础游戏模型 zombie_classic
--   2) RENDER_GROUP_OPAQUE_ENTITY 不可用/创建失败时依次尝试不带渲染组、
--      RENDERGROUP_OPAQUE
-- 创建仍失败时打印一次诊断（含 file.Exists / ClientsideModel 状态）
-- ============================================================================
function PANEL:SetClassTable(classtable)
	self.ClassTable = classtable

	-- 3D 模型预览开关：默认关闭（显示 2D 击杀图标，即原版形式）。
	-- 关闭时不创建 3D 实体，Paint 走 2D 图标绘制分支
	if not Is3DPreviewEnabled() then
		return
	end

	self:ResetBoneScales()

	local classtab = classtable
	if not classtab then return end

	-- 覆盖模型：部分职业在游戏里实际显示的是 OverrideModel（如暗影系显示骷髅、
	-- Eradicator 显示毒僵尸），预览应优先使用覆盖模型
	local model = classtab.Model
	self.UsingOverrideModel = false
	if classtab.OverrideModel and classtab.OverrideModel ~= false then
		model = classtab.OverrideModel
		self.UsingOverrideModel = true
	end

	if not model or model == "" then
		if IsDebugEnabled() then
			print("[PClassSelect] 职业无模型: " .. tostring(classtab.Name))
		end
		return
	end

	-- 模型文件在客户端不存在时回退到基础游戏模型
	if not file.Exists(model, "GAME") then
		if IsDebugEnabled() and not DebuggedModelFails[classtab.Name] then
			DebuggedModelFails[classtab.Name] = true
			print("[PClassSelect] 模型缺失回退: " .. classtab.Name .. " -> " .. tostring(model))
		end
		model = "models/player/zombie_classic.mdl"
	end

	-- 移除旧实体
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end

	-- 多级创建兜底（pcall 捕获任何创建异常）
	local ent
	local lasterr
	local ok, res = pcall(ClientsideModel, model, RENDER_GROUP_OPAQUE_ENTITY)
	if ok and IsValid(res) then
		ent = res
	else
		lasterr = ok and "返回无效实体" or tostring(res)
	end
	if not IsValid(ent) then
		ok, res = pcall(ClientsideModel, model)
		if ok and IsValid(res) then
			ent = res
		else
			lasterr = ok and "返回无效实体" or tostring(res)
		end
	end
	if not IsValid(ent) then
		ok, res = pcall(ClientsideModel, model, RENDERGROUP_OPAQUE)
		if ok and IsValid(res) then
			ent = res
		else
			lasterr = ok and "返回无效实体" or tostring(res)
		end
	end

	if not IsValid(ent) then
		if IsDebugEnabled() and not DebuggedModelFails[classtab.Name] then
			DebuggedModelFails[classtab.Name] = true
			print("[PClassSelect] 模型创建失败: " .. classtab.Name ..
				" 模型=" .. tostring(model) ..
				" file=" .. tostring(file.Exists(model, "GAME")) ..
				" CM=" .. tostring(ClientsideModel) ..
				" RG=" .. tostring(RENDER_GROUP_OPAQUE_ENTITY) ..
				" 错误=" .. tostring(lasterr))
		end
		return
	end

	self.Entity = ent
	ent:SetNoDraw(true)
	ent:SetIK(false)

	-- 选择一个合理的默认序列
	local iSeq = ent:LookupSequence("walk")
	if iSeq <= 0 then iSeq = ent:LookupSequence("Run1") end
	if iSeq <= 0 then iSeq = ent:LookupSequence("walk_all") end
	if iSeq > 0 then ent:ResetSequence(iSeq) end

	-- 体型缩放
	local scale = classtab.ModelScale or 1
	if scale ~= 1 then
		ent:SetModelScale(scale, 0)
	end

	-- 先设一个保守默认相机；模型异步加载，前 30 帧持续重新取景，
	-- 确保取景最终覆盖加载完成的真实模型（创建瞬间包围盒可能退化）
	self.FitFramesLeft = 30
	local defaultoffset = Vector(1, -0.6, 0.4):GetNormalized() * 110
	self:SetCamPos(defaultoffset)
	self:SetLookAt(Vector(0, 0, 30))
end

-- ============================================================================
-- FitCameraToBounds - 按模型当前包围盒精确取景（模型加载期间每帧调用）
-- 用最大半外延反推距离（余量 1.4），比包围球更贴合模型实际尺寸；
-- 自动旋转时模型绕 Y 轴转，水平方向取 X/Z 较大者。
-- 加载窗口内相机距离单调递增（只推远不拉近），防止早期小包围盒定太近；
-- 窗口结束时解除限制做最终定距，避免瞬时大包围盒把相机定太远
-- ============================================================================
function PANEL:FitCameraToBounds()
	if not IsValid(self.Entity) then return end

	local mins, maxs = self.Entity:GetRenderBounds()
	local center = (mins + maxs) / 2

	local hx = (maxs.x - mins.x) / 2
	local hy = (maxs.y - mins.y) / 2
	local hz = (maxs.z - mins.z) / 2
	local half = math_max(hx, hz)
	half = math_max(half, hy)
	if half < 5 then half = 40 end

	local scale = (self.ClassTable and self.ClassTable.ModelScale) or 1
	half = half * scale

	local fov = self.fFOV or 70
	local dist = half / math.tan(math.rad(fov) / 2) * 1.4
	dist = math.max(dist, 20)

	if self.LastFitDist and dist < self.LastFitDist then
		dist = self.LastFitDist
	end
	self.LastFitDist = dist

	local offset = Vector(1, -0.6, 0.4):GetNormalized() * dist
	self:SetCamPos(center + offset)
	self:SetLookAt(center)
end

-- ============================================================================
-- Paint - 3D 渲染：职业特效回调 + 面板裁剪 + 可选染色
-- ============================================================================
function PANEL:Paint(w, h)
	-- 面板内暗灰色底（提升模型/图标与卡片的层次感与可见度）
	draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 180))

	-- 悬停轻微放大：FOV 基准值向目标值平滑插值（数值不变，仅视角变化）
	self.HoverZoom = Lerp(FrameTime() * 10, self.HoverZoom or 0, self.HoverTarget or 0)
	self.fFOV = (self.BaseFOV or 70) * (1 - self.HoverZoom * 0.08)

	if not IsValid(self.Entity) then
		-- 模型未创建成功时打印一次诊断，并回退绘制 2D 击杀图标
		if IsDebugEnabled() and not self.DebuggedInvalid then
			self.DebuggedInvalid = true
			print("[PClassSelect] 预览实体无效: " .. tostring(self.ClassTable and self.ClassTable.Name or "?"))
		end

		local icon = self.ClassTable and self.ClassTable.Icon
		if icon then
			if not self.IconMaterial then
				self.IconMaterial = Material(icon)
			end

			local col = self.TintColor or color_white
			-- 锁定态（有染色）降低图标透明度
			surface_SetDrawColor(col.r, col.g, col.b, self.TintColor and 110 or 220)
			surface_SetMaterial(self.IconMaterial)

			local isize = math_min(w, h) * 0.6
			surface_DrawTexturedRect((w - isize) / 2, (h - isize) / 2, isize, isize)
		end
		return
	end

	local ent = self.Entity
	local classtab = self.ClassTable

	self:LayoutEntity(ent)

	-- 模型异步加载期间持续重新取景（前 30 帧）
	if self.FitFramesLeft then
		self.FitFramesLeft = self.FitFramesLeft - 1
		if self.FitFramesLeft <= 0 then
			self.FitFramesLeft = nil
			-- 窗口结束：解除单调限制，按真实包围盒最终定距（避免定太远）
			self.LastFitDist = nil
		end
		self:FitCameraToBounds()
	end

	local x, y = self:LocalToScreen(0, 0)

	local camPos = self.vCamPos or Vector(0, 0, 0)
	local lookPos = self.vLookatPos or Vector(0, 0, 0)
	local fov = self.fFOV or 50

	-- 首帧打印一次诊断，确认预览渲染路径与相机状态（DEBUG 开关开启时）
	if IsDebugEnabled() and not self.DebugPrinted and CardDebugCount < 5 then
		CardDebugCount = CardDebugCount + 1
		self.DebugPrinted = true
		print("[PClassSelect] 预览 " .. tostring(classtab and classtab.Name or "?") ..
			" ent=" .. tostring(IsValid(ent)) ..
			" cam=" .. tostring(camPos) ..
			" look=" .. tostring(lookPos) ..
			" fov=" .. string_format("%.0f", fov) ..
			" size=" .. w .. "x" .. h)
	end

	cam.Start3D(camPos, (lookPos - camPos):Angle(), fov, x, y, w, h, 5, self.FarZ or 4096)
		render_SuppressEngineLighting(true)
		render_SetLightingOrigin(ent:GetPos())

		-- 抑制引擎光照后必须手动打光，否则模型渲染为黑色不可见
		local ambient = self.colAmbientLight
		render_ResetModelLighting(ambient and ambient.r / 255 or 0.35, ambient and ambient.g / 255 or 0.35, ambient and ambient.b / 255 or 0.35)
		if self.DirectionalLight then
			for i = 0, 6 do
				local lightcol = self.DirectionalLight[i]
				if lightcol then
					render_SetModelLighting(i, lightcol.r / 255, lightcol.g / 255, lightcol.b / 255)
				end
			end
		end

		-- 套用职业骨骼效果（如隐藏腿部/手臂）
		if classtab and classtab.BuildBonePositions then
			pcall(classtab.BuildBonePositions, classtab, ent)
		end

		-- 模型绘制前设置 scissor 裁剪：优先与 VGUI 当前裁剪矩形取交集，
		-- 无效时退回面板自身屏幕矩形。防止模型渲染到卡片边界之外
		render_ClearDepth(false)
		local scisen, scl, sct, scr, scb = surface_GetScissorRect()
		if scisen then
			scl = math_max(scl, x)
			sct = math_max(sct, y)
			scr = math_min(scr, x + w)
			scb = math_min(scb, y + h)
		end
		if scisen and scr > scl and scb > sct then
			render_SetScissorRect(scl, sct, scr, scb, true)
		else
			render_SetScissorRect(x, y, x + w, y + h, true)
		end

		local tint = self.TintColor
		if tint then
			-- 未解锁：灰化渲染 + 降低透明度（锁定视觉），不套用职业特效
			render_SetColorModulation(tint.r / 255, tint.g / 255, tint.b / 255)
			render_SetBlend(0.6)
			if self.ShowBaseModel then
				ent:DrawModel()
			end
		elseif classtab then
			-- 已解锁：套用职业客户端渲染回调
			-- 使用覆盖模型时调用对应的 OverrideModel 绘制回调（如暗影系发光眼睛）
			local prefn = self.UsingOverrideModel and classtab.PrePlayerDrawOverrideModel or classtab.PrePlayerDraw
			local postfn = self.UsingOverrideModel and classtab.PostPlayerDrawOverrideModel or classtab.PostPlayerDraw

			local okpre = true
			local skipdraw = false
			if prefn then
				okpre, skipdraw = pcall(prefn, classtab, ent)
			end

			if skipdraw == true then
				-- 回调要求不绘制（如钻地隐身）
			elseif okpre then
				if self.ShowBaseModel then
					ent:DrawModel()
				end

				if postfn then
					pcall(postfn, classtab, ent)
				end
			else
				-- 回调出错（可能使用了玩家专属接口），退化为普通绘制
				if self.ShowBaseModel then
					ent:DrawModel()
				end
			end
		elseif self.ShowBaseModel then
			ent:DrawModel()
		end

		render_SetScissorRect(0, 0, 0, 0, false)

		-- 防御性还原渲染状态
		render_SetColorModulation(1, 1, 1)
		render_SetBlend(1)
		render_ModelMaterialOverride()

		-- 还原职业骨骼缩放，避免影响下一个职业
		-- pcall 保护：此调用位于 cam.Start3D/End3D 之间，任何错误都会造成相机泄漏
		if classtab and classtab.BuildBonePositions then
			pcall(self.ResetBoneScales, self)
		end

		render_SuppressEngineLighting(false)
	cam.End3D()
end

vgui.Register("ZombieClassPreview", PANEL, "DModelPanelEx")

-- ============================================================================
-- ClassSelectTab - 顶部分类标签页按钮（选中=白底，未选中=半透明黑底）
-- ============================================================================
PANEL = {}

PANEL.Font = "ZSHUDFontSmaller"

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetText("")

	self.TabText = ""
	self.Active = false
end

-- ============================================================================
-- SetTabText - 设置标签文字
-- ============================================================================
function PANEL:SetTabText(text)
	self.TabText = text
	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 根据文字宽度自适应尺寸（含左右内边距）
-- ============================================================================
function PANEL:PerformLayout()
	local scale = BetterScreenScale()

	surface_SetFont(self.Font)
	local tw = surface_GetTextSize(self.TabText)

	self:SetSize(tw + math_floor(30 * scale), math_floor(30 * scale))
end

-- ============================================================================
-- Paint - 绘制标签：选中白底 / 未选中半透明黑底，文字随底色反色
-- ============================================================================
function PANEL:Paint(w, h)
	local scale = BetterScreenScale()

	if self.Active then
		-- 选中：白色背景 + 深色文字 + 底部高亮线
		surface_SetDrawColor(255, 255, 255, 235)
		draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 235))
		draw_SimpleText(self.TabText, self.Font, w / 2, h / 2, Color(20, 20, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface_SetDrawColor(90, 255, 120, 230)
		surface_DrawRect(2, h - 3, w - 4, 3)
	else
		-- 未选中：半透明黑底 + 白色文字
		local bgalpha = 80
		if self.Hovered then bgalpha = 110 end
		surface_SetDrawColor(0, 0, 0, bgalpha)
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, bgalpha))

		local col = self.Hovered and Color(255, 255, 255) or Color(210, 210, 210)
		draw_SimpleText(self.TabText, self.Font, w / 2, h / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	return true
end

vgui.Register("ClassSelectTab", PANEL, "Button")

-- ============================================================================
-- ClassButton - 职业卡片（半透明黑圆角背景 + 名称 + 3D 模型预览 + 底部状态行）
-- ============================================================================
PANEL = {}

-- ============================================================================
-- Init - 初始化卡片
-- ============================================================================
function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetText("")

	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("ZSHUDFontSmaller")
	self.NameLabel:SetAlpha(170)
	self.NameLabel:SetMouseInputEnabled(false)

	self.Preview = vgui.Create("ZombieClassPreview", self)
	self.Preview:SetMouseInputEnabled(false)

	self.StatusLabel = vgui.Create("DLabel", self)
	self.StatusLabel:SetFont("ZSHUDFontTiny")
	self.StatusLabel:SetMouseInputEnabled(false)

	-- 当前背景颜色（用于悬停动画）
	self.CurrentBG = Color(0, 0, 0, 100)

	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局名称、模型预览与状态行
-- ============================================================================
function PANEL:PerformLayout()
	local w = self:GetWide()
	local h = self:GetTall()
	local scale = BetterScreenScale()

	self.NameLabel:SizeToContents()
	local nw, nh = self.NameLabel:GetSize()
	self.NameLabel:SetPos(math_floor((w - nw) / 2), math_floor(6 * scale))

	self.StatusLabel:SizeToContents()
	local sw, sh = self.StatusLabel:GetSize()
	self.StatusLabel:SetPos(math_floor((w - sw) / 2), math_floor(h - sh - 6 * scale))

	local _, namey = self.NameLabel:GetPos()
	local _, statusy = self.StatusLabel:GetPos()
	local top = namey + math_floor(nh) + 2

	self.Preview:SetPos(math_floor(5 * scale), top)
	self.Preview:SetSize(w - math_floor(10 * scale), math_max(10, statusy - top - 2))
end

-- ============================================================================
-- SetClassTable - 设置职业数据
-- ============================================================================
function PANEL:SetClassTable(classtable)
	self.ClassTable = classtable

	local name = translate.Get(classtable.TranslationName)
	local len = #name

	self.NameLabel:SetText(name)
	self.NameLabel:SetFont(len > 15 and "ZSHUDFontTiny" or len > 11 and "ZSHUDFontSmallest" or "ZSHUDFontSmaller")

	self.Preview:SetClassTable(classtable)

	self:InvalidateLayout()
end

-- ============================================================================
-- DoClick - 点击选择职业（保持原有行为：BOSS 走 convar，普通走 net 消息）
-- ============================================================================
function PANEL:DoClick()
	if self.ClassTable then
		if self.ClassTable.Boss then
			RunConsoleCommand("zs_bossclass", self.ClassTable.Name)
			GAMEMODE:CenterNotify(translate.Format("boss_class_select", self.ClassTable.Name))
		elseif self.ClassTable.MiniBoss then
			-- 迷你BOSS：代币足够时直接购买变身（复用僵尸商店购买指令），不足则提示
			local shopdata = GetMiniBossShopData()[self.ClassTable.Name]
			if shopdata and MySelf:GetTokens() >= shopdata.Price then
				RunConsoleCommand("zs_mutationshop_click", shopdata.Signature)
			else
				GAMEMODE:CenterNotify(COLOR_RED, translate.Get("you_dont_have_enough_btokens"))
				surface.PlaySound("buttons/button10.wav")
				return
			end
		else
			net.Start(NET_MSG.CHANGECLASS)
				net.WriteString(self.ClassTable.Name)
				net.WriteBool(GAMEMODE.SuicideOnChangeClass)
			net.SendToServer()
		end
	end

	surface.PlaySound("buttons/button15.wav")

	if Window and Window:IsValid() then Window:Remove() end
end

-- ============================================================================
-- Paint - 绘制半透明黑圆角背景，悬停时高亮
-- ============================================================================
function PANEL:Paint(w, h)
	local selected = self.LastEnabledState == 2
	local target = self.Hovered and Color(255, 255, 255, 28) or Color(0, 0, 0, 100)
	local alpha = Lerp(FrameTime() * 10, self.CurrentBG.a, target.a)
	self.CurrentBG = Color(target.r, target.g, target.b, alpha)

	if selected then
		-- 当前职业：绿色细边框 + 内侧轻微发光，中心不透明暗色（不覆盖模型区域，保证文字清晰）
		draw.RoundedBox(6, 0, 0, w, h, Color(90, 255, 120, 235))
		draw.RoundedBox(6, 3, 3, w - 6, h - 6, Color(90, 255, 120, 30))
		draw.RoundedBox(6, 2, 2, w - 4, h - 4, Color(10, 10, 10, 255))
	else
		draw.RoundedBox(6, 0, 0, w, h, self.CurrentBG)
	end

	-- 悬停时白色细边框（选中态已被绿色边框取代，不再叠加）
	if self.Hovered and not selected then
		surface_SetDrawColor(255, 255, 255, 40)
		surface_DrawOutlinedRect(0, 0, w, h)
	end

	-- 锁定状态：状态行文字左侧绘制挂锁图标
	if self.LastEnabledState == 0 and self.StatusLabel and self.StatusLabel:IsValid() then
		local slx, sly = self.StatusLabel:GetPos()
		local slw, slh = self.StatusLabel:GetSize()
		local iconsize = math_floor(slh * 0.72)
		local iconx = self:GetWide() / 2 - slw / 2 - iconsize - math_floor(4 * BetterScreenScale())
		local icony = sly + (slh - iconsize) / 2
		DrawPadlock(iconx, icony, iconsize, Color(255, 85, 85, 230))
	end

	return true
end

-- ============================================================================
-- OnCursorEntered - 悬停时高亮名称并在右侧显示该职业详情
-- ============================================================================
function PANEL:OnCursorEntered()
	self.NameLabel:SetAlpha(self.LastEnabledState == 2 and 255 or 230)

	if Window and Window:IsValid() and self.ClassTable then
		Window:SetDetailClass(self.ClassTable)
	end
end

-- ============================================================================
-- OnCursorExited - 恢复名称透明度（选中态保持全亮；详情面板保留最后悬停的职业）
-- ============================================================================
function PANEL:OnCursorExited()
	self.NameLabel:SetAlpha(self.LastEnabledState == 2 and 255 or 170)
end

-- ============================================================================
-- Think - 更新卡片状态（当前职业=绿 / 已解锁=白 / 未解锁=红+模型染色）
-- 迷你BOSS：特殊状态 3（白名 + "商店购买"提示，不染色）
-- ============================================================================
function PANEL:Think()
	if not self.ClassTable then return end

	local enabled
	if self.ClassTable.MiniBoss then
		-- 迷你BOSS始终显示为可购买状态（不检查波次解锁）
		if MySelf:GetZombieClass() == self.ClassTable.Index then
			enabled = 2
		else
			enabled = 3
		end
	elseif MySelf:GetZombieClass() == self.ClassTable.Index then
		enabled = 2
	elseif self.ClassTable.Boss or gamemode.Call("IsClassUnlocked", self.ClassTable.Index) then
		enabled = 1
	else
		enabled = 0
	end

	if enabled ~= self.LastEnabledState then
		self.LastEnabledState = enabled

		if enabled == 2 then
			self.NameLabel:SetTextColor(COLOR_GREEN)
			self.NameLabel:SetAlpha(255)
			self.Preview:SetTintColor(nil)
			self.StatusLabel:SetFont("ZSHUDFontTiny")
			self.StatusLabel:SetText("")
		elseif enabled == 3 then
			-- 迷你BOSS：白色名称 + 代币价格（足够=绿色，不足=红色）
			self.NameLabel:SetTextColor(COLOR_WHITE)
			self.NameLabel:SetAlpha(self.Hovered and 230 or 170)
			self.Preview:SetTintColor(nil)
			self.StatusLabel:SetFont("ZSHUDFontTiny")
			local shopdata = GetMiniBossShopData()[self.ClassTable.Name]
			if shopdata then
				self.StatusLabel:SetText(translate.Format("miniboss_price_label", math_floor(shopdata.Price)))
				self.StatusLabel:SetTextColor(MySelf:GetTokens() >= shopdata.Price and COLOR_GREEN or COLOR_RED)
			else
				self.StatusLabel:SetText(translate.Get("miniboss_shop_label"))
				self.StatusLabel:SetTextColor(COLOR_RORANGE)
			end
		elseif enabled == 1 then
			self.NameLabel:SetTextColor(COLOR_WHITE)
			self.NameLabel:SetAlpha(self.Hovered and 230 or 170)
			self.Preview:SetTintColor(nil)
			self.StatusLabel:SetFont("ZSHUDFontTiny")

			if self.ClassTable.Wave and self.ClassTable.Wave > 0 then
				self.StatusLabel:SetText(translate.Format("unlocked_on_wave_x", self.ClassTable.Wave))
				self.StatusLabel:SetTextColor(COLOR_GRAY)
			else
				self.StatusLabel:SetText("")
			end
		else
			self.NameLabel:SetTextColor(COLOR_DARKRED)
			self.NameLabel:SetAlpha(200)
			-- 锁定：模型灰化 + 锁定文字加大加亮（配合卡片挂锁图标）
			self.Preview:SetTintColor(Color(165, 165, 165))
			self.StatusLabel:SetFont("ZSHUDFontSmallest")
			self.StatusLabel:SetText(translate.Get("zombieselect_Locked"))
			self.StatusLabel:SetTextColor(Color(255, 85, 85))
		end

		self:InvalidateLayout(true)
	end

	-- 同步悬停状态到模型预览（Paint 中平滑缩放）
	if self.Preview and self.Preview:IsValid() then
		self.Preview:SetHovered(self.Hovered)
	end

	-- 代币数量变化时刷新迷你BOSS卡片的价格颜色（足够=绿，不足=红）
	if enabled == 3 then
		local tokens = MySelf:GetTokens()
		if tokens ~= self.LastTokens then
			self.LastTokens = tokens
			local shopdata = GetMiniBossShopData()[self.ClassTable.Name]
			if shopdata then
				self.StatusLabel:SetText(translate.Format("miniboss_price_label", math_floor(shopdata.Price)))
				self.StatusLabel:SetTextColor(tokens >= shopdata.Price and COLOR_GREEN or COLOR_RED)
			end
		end
	end
end

vgui.Register("ClassButton", PANEL, "Button")

-- ============================================================================
-- ClassDetailPanel - 右侧职业详情面板（属性条 + 描述）
-- ============================================================================
PANEL = {}

-- ============================================================================
-- Init - 初始化详情面板
-- ============================================================================
function PANEL:Init()
	self.ClassName = ""
	self.StatRows = {}
	self.DescSections = {}
	self.DescLabels = {}
	self.DescDirty = false

	self.DescScroll = vgui.Create("DScrollPanel", self)
	StyleScrollBar(self.DescScroll:GetVBar(), BetterScreenScale())
end

-- ============================================================================
-- SetClassTable - 设置职业数据并刷新属性条与描述
-- ============================================================================
function PANEL:SetClassTable(classtable, maxes)
	self.ClassTable = classtable
	self.ClassName = translate.Get(classtable.TranslationName)

	local weptab = classtable.SWEP and weapons.Get(classtable.SWEP)

	self.StatRows = {}
	for _, rowdef in ipairs(STAT_ROW_DEFS) do
		local value = rowdef.Get(classtable, weptab)
		local maxv = rowdef.Max(maxes)
		local frac = 0
		local text = "-"

		if value then
			frac = maxv and maxv > 0 and math_Clamp(value / maxv, 0, 1) or 0
			text = rowdef.Decimals and string_format("%.1f", value) or string_format("%d", math_floor(value + 0.5))
		end

		table_insert(self.StatRows, {Label = translate.Get(rowdef.Label), Frac = frac, Text = text, Color = rowdef.Color or COLOR_GRAY})
	end

	-- 描述分段（实际换行与标签创建在 PerformLayout 中进行，那时才有宽度）
	local scale = BetterScreenScale()
	local gapsmall = math_floor(6 * scale)
	local gapbig = math_floor(12 * scale)

	self.DescSections = {}

	if classtable.Wave and classtable.Wave > 0 then
		table_insert(self.DescSections, {Text = translate.Format("unlocked_on_wave_x", classtable.Wave), Font = "ZSBodyTextFont", Color = COLOR_GRAY, Gap = gapsmall})
	end

	if classtable.BetterVersion then
		local betterclasstable = GAMEMODE.ZombieClasses[classtable.BetterVersion]
		if betterclasstable then
			table_insert(self.DescSections, {Text = translate.Format("evolves_in_to_x_on_wave_y", betterclasstable.Wave, betterclasstable.Name), Font = "ZSBodyTextFont", Color = COLOR_RORANGE, Gap = gapbig})
		end
	end

	if classtable.Description then
		table_insert(self.DescSections, {Text = translate.Get(classtable.Description), Font = "ZSBodyTextFont", Color = COLOR_WHITE, Gap = gapsmall})
	end

	if classtable.Help then
		table_insert(self.DescSections, {Text = translate.Get(classtable.Help), Font = "ZSBodyTextFontSmall", Color = COLOR_GRAY, Gap = 0})
	end

	self.DescDirty = true
	self:InvalidateLayout(true)
end

-- ============================================================================
-- RebuildDescLabels - 按给定宽度换行并重建描述标签
-- ============================================================================
function PANEL:RebuildDescLabels(innerw)
	for _, label in ipairs(self.DescLabels) do
		label:Remove()
	end
	self.DescLabels = {}

	local y = 0
	for _, section in ipairs(self.DescSections) do
		local lines = WrapTextToWidth(section.Text, section.Font, innerw)

		for i, line in ipairs(lines) do
			local label = vgui.Create("DLabel", self.DescScroll)
			label:SetFont(section.Font)
			-- 空行用一个空格占位，保留行高作为段间距
			label:SetText(line == "" and " " or line)
			label:SetTextColor(section.Color)
			label:SizeToContents()
			label:SetPos(0, y)
			label:SetWide(innerw)

			y = y + label:GetTall() + (i == #lines and section.Gap or 2)

			table_insert(self.DescLabels, label)
		end
	end
end

-- ============================================================================
-- PerformLayout - 计算属性条几何并布局描述滚动区
-- ============================================================================
function PANEL:PerformLayout()
	local w, h = self:GetSize()
	local scale = BetterScreenScale()
	self.Scale = scale

	self.Padding = math_floor(12 * scale)
	self.RowH = math_floor(22 * scale)
	self.BarH = math_max(4, math_floor(7 * scale))

	-- 名称字号自适应：短名用最大号（ZSHUDFont），长名逐级缩小，保证层级最大
	local namelen = #self.ClassName
	self.ClassNameFont = namelen <= 8 and "ZSHUDFont" or (namelen <= 14 and "ZSHUDFontSmall" or "ZSHUDFontSmaller")
	self.ClassNameHeight = draw_GetFontHeight(self.ClassNameFont)
	self.StatsY = self.Padding + self.ClassNameHeight + math_floor(12 * scale)

	local labelw = math_floor(100 * scale)
	local valuew = math_floor(48 * scale)
	self.BarX = self.Padding + labelw
	self.BarW = math_max(20, w - self.Padding * 2 - labelw - valuew - math_floor(8 * scale))

	local descY = self.StatsY + self.RowH * #STAT_ROW_DEFS + math_floor(14 * scale)
	self.DescY = descY
	self.DescScroll:SetPos(self.Padding, descY)
	self.DescScroll:SetSize(w - self.Padding * 2, math_max(20, h - descY - self.Padding))

	-- 宽度确定后重建描述标签（换行依赖宽度；仅在内容或宽度变化时重建）
	local innerw = self.DescScroll:GetWide() - math_floor(10 * scale)
	if self.DescDirty or self.LastDescInnerW ~= innerw then
		self.DescDirty = false
		self.LastDescInnerW = innerw
		self:RebuildDescLabels(innerw)
	end
end

-- ============================================================================
-- Paint - 绘制职业名称与属性条
-- ============================================================================
function PANEL:Paint(w, h)
	local pad = self.Padding or 12
	local scale = self.Scale or 1

	-- 职业名称：最大字号（层级第一）
	local namefont = self.ClassNameFont or "ZSHUDFontSmall"
	draw_SimpleText(self.ClassName, namefont, pad, pad, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	-- 名称下短强调线，强化与下方属性的层级分隔（整数坐标防模糊）
	local nameh = self.ClassNameHeight or draw_GetFontHeight(namefont)
	surface_SetDrawColor(90, 255, 120, 150)
	surface_DrawRect(pad, math_floor(pad + nameh + 6 * scale), math_floor(44 * scale), 2)

	local y = self.StatsY or (pad + 40)
	local rowh = self.RowH or 22
	local barx = self.BarX or (pad + 100)
	local barw = self.BarW or 100
	local barh = self.BarH or 7
	local valuex = w - pad

	for _, row in ipairs(self.StatRows) do
		local cy = math_floor(y + rowh / 2)
		local rowcol = row.Color or COLOR_GRAY

		draw_SimpleText(row.Label, "ZSHUDFontSmallest", pad, cy, rowcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local bary = math_floor(cy - barh / 2)
		surface_SetDrawColor(30, 30, 30, 220)
		surface_DrawRect(barx, bary, barw, barh)
		if row.Frac > 0 then
			surface_SetDrawColor(rowcol.r, rowcol.g, rowcol.b, 255)
			surface_DrawRect(barx, bary, barw * row.Frac, barh)
		end

		draw_SimpleText(row.Text, "ZSHUDFontSmallest", valuex, cy, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		y = y + rowh
	end

	-- 属性区与描述区之间的水平分割线（弱化显示，仅作分区）
	if self.DescY then
		surface_SetDrawColor(255, 255, 255, 22)
		surface_DrawRect(pad, math_floor(self.DescY - 7 * scale), w - pad * 2, 2)
	end

	return true
end

vgui.Register("ClassDetailPanel", PANEL, "Panel")

-- ============================================================================
-- ClassSelect 主面板
-- ============================================================================
PANEL = {}

-- ============================================================================
-- 分类标签定义（顺序即显示顺序，与截图样式一致）
-- Key 为翻译键，Filter 为职业过滤函数
-- ApplyClassicFilter = true 时应用原版"普通职业"过滤（隐藏/目标图/CanUse 检查）
-- ============================================================================
local CLASS_TABS = {
	{Key = "zombieselect_Classes", ApplyClassicFilter = true, Filter = function(ct) return not ct.Boss and not ct.MiniBoss and not ct.SuperBoss and not ct.MegaBoss and not ct.Hidden end},
	-- 隐藏职业沿用原版规则：仅在 CanUse(MySelf) 通过时显示（如 flesh creeper），其余不显示
	{Key = "zombieselect_Other", Filter = function(ct) return ct.Hidden and ct.CanUse and ct:CanUse(MySelf) and not ct.MiniBoss and not ct.SuperBoss and not ct.MegaBoss and not ct.Boss end},
	{Key = "zombieselect_Mutations", Filter = function(ct) return ct.Mutation == true end},
	{Key = "zombieselect_MiniBosses", Filter = function(ct) return ct.MiniBoss == true end},
	{Key = "zombieselect_Bosses", Filter = function(ct) return ct.Boss == true and not ct.SuperBoss and not ct.MegaBoss end},
	{Key = "zombieselect_SuperBosses", Filter = function(ct) return ct.SuperBoss == true end},
	{Key = "zombieselect_MegaBosses", Filter = function(ct) return ct.MegaBoss == true end},
}

-- ============================================================================
-- Init - 初始化主窗口（标题 / 关闭按钮 / 分类标签页 / 网格 / 详情）
-- ============================================================================
function PANEL:Init()
	self.NeedsRebuild = true
	self.ClassButtons = {}
	self.StatMaxes = ComputeClassStatMaxes()
	self.CategoryTabs = {}
	self.ActiveCategory = CLASS_TABS[1].Key

	-- 每次打开都重置诊断去重，保证输出完整可读
	CardDebugCount = 0
	DebuggedModelFails = {}

	if IsDebugEnabled() then
		print("[PClassSelect] 僵尸选择界面已加载 (当前为修复版)")
	end

	-- 分类标签页（7 个）
	-- 容器最先创建：Derma 按创建顺序排 z 序，后创建的兄弟面板（关闭按钮等）在其上层，
	-- 全窗口容器才不会拦截它们的鼠标事件；容器自身保持鼠标输入启用，标签子面板才能点击
	self.TabsContainer = vgui.Create("DPanel", self)
	self.TabsContainer:SetPaintBackground(false)

	for i, tabdef in ipairs(CLASS_TABS) do
		local tab = vgui.Create("ClassSelectTab", self.TabsContainer)
		tab:SetTabText(translate.Get(tabdef.Key))
		tab.Active = (i == 1)
		tab.CategoryKey = tabdef.Key
		tab.DoClick = function(btn) self:SetCategory(btn.CategoryKey) end
		self.CategoryTabs[tabdef.Key] = tab
	end

	-- 标题文本（Paint 中自绘：阴影 + 正文 + 底部装饰线）
	self.TitleText = translate.Get("zombieselect_title")

	-- 关闭按钮（自定义绘制：默认灰白，悬停淡红）
	self.CloseButton = EasyButton(self, translate.Get("zombieselect_Close"), 8, 4)
	self.CloseButton:SetFont("ZSHUDFontSmaller")
	self.CloseButton:SizeToContents()
	self.CloseButton.Paint = function(btn, bw, bh)
		local hovered = btn:IsHovered()
		local bg = hovered and Color(255, 90, 90, 46) or Color(255, 255, 255, 10)
		local col = hovered and Color(255, 110, 110) or Color(210, 210, 210)
		draw.RoundedBox(4, 0, 0, bw, bh, bg)
		draw_SimpleText(btn:GetText(), "ZSHUDFontSmaller", math_floor(bw / 2), math_floor(bh / 2), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return true
	end
	self.CloseButton.DoClick = function()
		if Window and Window:IsValid() then Window:Remove() end
	end

	-- 代币余额显示（仅迷你BOSS标签页可见）
	self.TokenLabel = vgui.Create("DLabel", self)
	self.TokenLabel:SetFont("ZSHUDFontSmaller")
	self.TokenLabel:SetTextColor(COLOR_WHITE)
	self.TokenLabel:SetVisible(false)

	-- 左侧职业卡片网格
	self.Scroll = vgui.Create("DScrollPanel", self)
	StyleScrollBar(self.Scroll:GetVBar(), BetterScreenScale())
	self.IconLayout = vgui.Create("DIconLayout", self.Scroll)

	-- 右侧详情面板
	self.Detail = vgui.Create("ClassDetailPanel", self)
end

-- ============================================================================
-- SetCategory - 切换分类标签页并重建网格
-- ============================================================================
function PANEL:SetCategory(key)
	if self.ActiveCategory == key then return end

	self.ActiveCategory = key
	for tabkey, tab in pairs(self.CategoryTabs) do
		tab.Active = (tabkey == key)
	end

	-- 代币余额仅迷你BOSS标签页显示
	self.TokenLabel:SetVisible(key == "zombieselect_MiniBosses")

	self.NeedsRebuild = true
	self:InvalidateLayout(true)
end

-- ============================================================================
-- SetDetailClass - 在右侧详情面板显示指定职业
-- ============================================================================
function PANEL:SetDetailClass(classtable)
	if self.DetailClass == classtable then return end

	self.DetailClass = classtable
	self.Detail:SetClassTable(classtable, self.StatMaxes)
end

-- ============================================================================
-- BuildClassGrid - 按当前分类标签重建职业卡片网格
-- 分类过滤规则见 CLASS_TABS 定义
-- ============================================================================
function PANEL:BuildClassGrid()
	self.IconLayout:Clear()
	self.ClassButtons = {}

	local scale = BetterScreenScale()
	local spacing = math_floor(8 * scale)
	local border = math_floor(10 * scale)

	self.IconLayout:SetSpaceX(spacing)
	self.IconLayout:SetSpaceY(spacing)
	self.IconLayout:SetBorder(border)

	-- 每行 5 张卡片（宽度适中，3 行完整显示无需滚动）
	local innerw = self.IconLayout:GetWide() - border * 2
	local cardw = math_floor((innerw - spacing * 4) / 5)
	local cardh = math_floor(cardw * 1.2)

	-- 获取当前分类的过滤函数
	local filterfn
	local applyclassic = false
	for _, tabdef in ipairs(CLASS_TABS) do
		if tabdef.Key == self.ActiveCategory then
			filterfn = tabdef.Filter
			applyclassic = tabdef.ApplyClassicFilter or false
			break
		end
	end
	if not filterfn then
		filterfn = CLASS_TABS[1].Filter
		applyclassic = true
	end

	-- 收集职业（沿用原有过滤逻辑 + 分类过滤）
	local classes = {}
	local already_added = {}
	local use_better_versions = GAMEMODE:ShouldUseBetterVersionSystem()

	for i = 1, #GAMEMODE.ZombieClasses do
		local classtab = GAMEMODE.ZombieClasses[GAMEMODE:GetBestAvailableZombieClass(i)]

		if classtab and not classtab.Disabled and not already_added[classtab.Index] then
			already_added[classtab.Index] = true

			local ok = filterfn(classtab)
			if ok then
				-- 仅"普通职业"分类保留原版隐藏/目标图过滤；
				-- 其他分类（迷你BOSS/其他等）完全由分类过滤函数决定
				if applyclassic then
					ok = (not classtab.Hidden or classtab.CanUse and classtab:CanUse(MySelf)) and
						(not GAMEMODE.ObjectiveMap or classtab.Unlocked)
				end
			end

			if ok and (not use_better_versions or not classtab.BetterVersionOf or GAMEMODE:IsClassUnlocked(classtab.Index)) then
				table.insert(classes, classtab)
			end
		end
	end

	if IsDebugEnabled() then
		print(string_format("[PClassSelect] 分类[%s] 职业数=%d (经典过滤=%s)", tostring(self.ActiveCategory), #classes, tostring(applyclassic)))
	end

	-- 按解锁波次排序（与原 SortByMember("Wave") 一致，缺省按 1 处理）
	table_sort(classes, function(a, b)
		local wa, wb = a.Wave or 1, b.Wave or 1
		if wa == wb then return (a.Name or "") < (b.Name or "") end
		return wa < wb
	end)

	local currentindex = MySelf:GetZombieClass()
	local defaultdetail

	for _, classtab in ipairs(classes) do
		local button = vgui.Create("ClassButton")
		button:SetClassTable(classtab)
		button:SetSize(cardw, cardh)

		self.IconLayout:Add(button)
		table.insert(self.ClassButtons, button)

		if not defaultdetail and classtab.Index == currentindex then
			defaultdetail = classtab
		end
	end

	-- 默认详情：当前职业，否则列表第一个
	if not defaultdetail then
		defaultdetail = classes[1]
	end
	if defaultdetail then
		self.DetailClass = nil
		self:SetDetailClass(defaultdetail)
	end

	self.IconLayout:InvalidateLayout(true)
end

-- ============================================================================
-- PerformLayout - 布局标题 / 标签页 / 网格 / 分隔线 / 详情面板
-- ============================================================================
function PANEL:PerformLayout()
	local scale = BetterScreenScale()

	local w = math_min(math_floor(1280 * scale), ScrW() - 40)
	local h = math_min(math_floor(860 * scale), ScrH() - 60)
	self:SetSize(w, h)
	self:Center()

	-- 标签容器铺满窗口：消除 0x0 容器的隐性依赖
	-- （GMod 默认不裁剪子面板，标签才能显示；但不应依赖此行为）
	self.TabsContainer:SetPos(0, 0)
	self.TabsContainer:SetSize(w, h)

	self.Scale = scale
	self.TitleY = math_floor(10 * scale)

	self.CloseButton:SizeToContents()
	local cbw = self.CloseButton:GetWide()
	self.CloseButton:SetPos(w - cbw - math_floor(10 * scale), math_floor(10 * scale))

	-- 代币余额标签：关闭按钮左侧
	self.TokenLabel:SizeToContents()
	self.TokenLabel:SetPos(self.CloseButton:GetX() - self.TokenLabel:GetWide() - math_floor(12 * scale), math_floor(12 * scale))

	-- 分类标签页居中排成一行（动态数量）
	local tabs = {}
	for key, tab in pairs(self.CategoryTabs) do
		table_insert(tabs, tab)
	end
	table_sort(tabs, function(a, b)
		local ai, bi
		for i, tabdef in ipairs(CLASS_TABS) do
			if tabdef.Key == a.CategoryKey then ai = i end
			if tabdef.Key == b.CategoryKey then bi = i end
		end
		return (ai or 99) < (bi or 99)
	end)

	local totalw = 0
	for _, tab in ipairs(tabs) do
		tab:InvalidateLayout(true)
		totalw = totalw + tab:GetWide()
	end
	local tabgap = math_floor(8 * scale)
	totalw = totalw + tabgap * (#tabs - 1)

	local tabtotal = math_max(totalw, w * 0.55)
	local taby = math_floor(58 * scale)
	local x = (w - tabtotal) / 2
	-- 若标签总宽超窗口则从左侧开始
	if totalw > w - math_floor(20 * scale) then
		x = math_floor(10 * scale)
	end
	for _, tab in ipairs(tabs) do
		tab:SetPos(x, taby)
		x = x + tab:GetWide() + tabgap
	end

	-- 内容区：左网格 + 分隔线 + 右详情
	local margin = math_floor(10 * scale)
	local contentY = math_floor(100 * scale)
	local contentH = h - contentY - margin

	local scrollW = math_floor((w - margin * 2) * 0.70)
	self.Scroll:SetPos(margin, contentY)
	self.Scroll:SetSize(scrollW, contentH)

	-- 预留滚动条宽度，避免第 4 列卡片被遮住（宽度随缩放实时应用）
	local vbarw = 16
	local vbar = self.Scroll.GetVBar and self.Scroll:GetVBar()
	if vbar and vbar:IsValid() then
		vbar:SetWide(math_floor(4 * scale))
		vbarw = vbar:GetWide()
	end
	self.IconLayout:SetWide(scrollW - vbarw)

	self.DividerX = margin + scrollW + math_floor(4 * scale)
	self.DividerY = contentY
	self.DividerH = contentH

	local detailX = self.DividerX + 2 + math_floor(4 * scale)
	self.Detail:SetPos(detailX, contentY)
	self.Detail:SetSize(w - detailX - margin, contentH)

	if self.NeedsRebuild then
		self.NeedsRebuild = false
		self:BuildClassGrid()
	end
end

-- ============================================================================
-- Think - 迷你BOSS标签页的代币余额变化时刷新显示
-- ============================================================================
function PANEL:Think()
	if self.TokenLabel and self.TokenLabel:IsVisible() then
		local tokens = math_floor(MySelf:GetTokens() or 0)
		if tokens ~= self.LastTokenDisplay then
			self.LastTokenDisplay = tokens
			self.TokenLabel:SetText(translate.Format("miniboss_tokens_label", tokens))
			self.TokenLabel:SizeToContents()
		end
	end
end

-- ============================================================================
-- Paint - 绘制背景半透明层、边缘渐变与左右分隔线
-- ============================================================================
function PANEL:Paint(w, h)
	local edgesize = 16

	DisableClipping(true)
	-- 全屏黑色遮罩：压暗游戏画面，避免背景干扰 UI 阅读
	local sx, sy = self:LocalToScreen(0, 0)
	surface_SetDrawColor(0, 0, 0, 150)
	surface_DrawRect(-sx, -sy, ScrW(), ScrH())
	-- 主窗口背景（深色高不透明，与遮罩形成层级）
	surface_SetDrawColor(20, 20, 20, 235)
	surface_DrawRect(0, 0, w, h)
	surface_SetTexture(texUpEdge)
	surface_DrawTexturedRect(0, -edgesize, w, edgesize)
	surface_SetTexture(texDownEdge)
	surface_DrawTexturedRect(0, h, w, edgesize)
	DisableClipping(false)

	-- 面板细边框（截图样式）
	surface_SetDrawColor(Color(255, 255, 255, 35))
	surface_DrawOutlinedRect(0, 0, w, h)

	-- 标题：轻微阴影 + 正文 + 底部装饰线（简洁，无动画；全部整数坐标防模糊）
	local scale = self.Scale or 1
	local titley = self.TitleY or math_floor(10 * scale)
	local titlex = math_floor(w / 2)
	draw_SimpleText(self.TitleText, "ZSHUDFont", titlex + 1, titley + 1, Color(0, 0, 0, 140), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw_SimpleText(self.TitleText, "ZSHUDFont", titlex, titley, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	local titleliney = titley + math_floor(draw_GetFontHeight("ZSHUDFont") + 4 * scale)
	surface_SetDrawColor(90, 255, 120, 130)
	surface_DrawRect(titlex - math_floor(30 * scale), titleliney, math_floor(60 * scale), 2)

	if self.DividerX then
		surface_SetDrawColor(Color(255, 255, 255, 25))
		surface_DrawRect(self.DividerX, self.DividerY, 2, self.DividerH)
	end

	return true
end

vgui.Register("ClassSelect", PANEL, "Panel")
