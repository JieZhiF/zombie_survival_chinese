-- ============================================================================
-- ZSHealthArea - 生命值 HUD 区域组件
-- 显示玩家生命值条（实血+虚血）和人类血甲值
-- 位于屏幕左下角，带渐变背景
-- 特性：
--   1. 血量数字与实血条实时变化（不做平滑处理）
--   2. 虚血条表示玩家刚掉的血：掉血时缓慢回落，回血时立刻跟上
--   3. 超出上限时数字与提示文字变为循环彩色
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 生命值条
-- [位置] ContentsPaint() 前半段
-- [作用] 实血条 + 虚血痕迹 + 血量数字，超出上限循环彩色
-- [常改] 条体尺寸、颜色、虚血衰减速度、发光效果
--
-- [区域] 血甲条
-- [位置] ContentsPaint() 后半段 (TEAM_HUMAN)
-- [作用] 人类血甲条与数值，带平滑过渡动画
-- [常改] 条体尺寸、颜色、动画速度
--
-- [区域] 面板背景
-- [位置] Init() / PerformLayout() / Paint()
-- [作用] 左下角定位与渐变背景
-- [常改] 面板尺寸、背景渐变
-- ============================================================================

local PANEL = {}

-- 发光材质和渐变纹理
local matGlow = Material("sprites/glow04_noz")
local texDownEdge = surface.GetTextureID("gui/gradient_down")
local colHealth = Color(0, 0, 0, 240)

-- 数值平滑过渡的速度，数值越大过渡越快
local ANIM_SPEED = 4

-- 虚血（掉血痕迹）衰减速度：数值越小，掉血后残留的虚血条消退越慢
local TRAIL_SPEED = 3

-- 彩虹色循环速度（每秒色相变化的角度）
local RAINBOW_SPEED = 30

-- ============================================================================
-- RainbowColor - 根据时间生成循环变化的彩色（可加角度偏移错开节奏）
-- ============================================================================
local function RainbowColor(offset)
	local hue = (CurTime() * RAINBOW_SPEED + (offset or 0)) % 360
	return HSVToColor(hue, 1, 1)
end

-- ============================================================================
-- Approach - 让 current 平滑趋近 target（帧率无关的指数平滑）
-- ============================================================================
local function Approach(current, target, speed)
	if current == nil then return target end
	local dt = math.Clamp(FrameTime() * speed, 0, 1)
	local result = Lerp(dt, current, target)
	-- 差值很小时直接对齐，避免长时间无限趋近产生的小数误差
	if math.abs(result - target) < 0.05 then
		result = target
	end
	return result
end

-- ============================================================================
-- ContentsPaint - 绘制生命值/虚血/血甲内容
-- ============================================================================
local function ContentsPaint(self, w, h)
	local lp = MySelf
	if lp:IsValid() then
		local screenscale = BetterScreenScale()
		local maxhealth = math.max(lp:GetMaxHealthEx(), 1)
		local health = math.max(lp:Health(), 0)

		-- 生命值超出上限时的判断
		local isOverheal = health > maxhealth

		-- 实血：直接使用真实生命值，数字与条体都实时变化，不做平滑过渡
		local healthperc = math.Clamp(health / maxhealth, 0, 1)
		local wid, hei = 300 * screenscale, 18 * screenscale

		-- 根据生命值比例计算颜色（低血红色，满血绿色）
		colHealth.r = (1 - healthperc) * 180
		colHealth.g = healthperc * 180
		colHealth.b = 0

		local x = 18 * screenscale
		local y = 115 * screenscale

		local subwidth = healthperc * wid

		-- 生命值数字：实时显示真实血量（超出上限时变为循环彩色）
		local numColor = isOverheal and RainbowColor(0) or colHealth
		draw.SimpleTextBlurry(health, "ZSHUDFont", x + wid + 12 * screenscale, y + 8 * screenscale, numColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		-- 绘制生命值条背景
		surface.SetDrawColor(0, 0, 0, 230)
		surface.DrawRect(x, y, wid, hei)

		-- 虚血：记录玩家刚掉的血，只在掉血时缓慢回落，回血时立刻跟上，不产生虚血
		self.lostHealthTrail = self.lostHealthTrail or health
		if health < self.lostHealthTrail then
			self.lostHealthTrail = Approach(self.lostHealthTrail, health, TRAIL_SPEED)
		else
			self.lostHealthTrail = health
		end
		local trailperc = math.Clamp(self.lostHealthTrail / maxhealth, 0, 1)
		local trailwidth = trailperc * wid

		-- 先画虚血痕迹（掉的血），再画实血盖在上面，这样实血边缘始终清晰
		if trailwidth > subwidth then
			surface.SetDrawColor(220, 50, 50, 150)
			surface.SetTexture(texDownEdge)
			surface.DrawTexturedRect(x + 2, y + 1, trailwidth - 4, hei - 2)
			surface.SetDrawColor(220, 50, 50, 40)
			surface.DrawRect(x + 2, y + 1, trailwidth - 4, hei - 2)
		end

		-- 绘制生命值条填充（渐变纹理）
		surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 160)
		surface.SetTexture(texDownEdge)
		surface.DrawTexturedRect(x + 2, y + 1, subwidth - 4, hei - 2)
		surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 30)
		surface.DrawRect(x + 2, y + 1, subwidth - 4, hei - 2)

		-- 生命值末端发光效果
		surface.SetMaterial(matGlow)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(x + 2 + subwidth - 6, y + 1 - hei/2, 4, hei * 2)

		-- 超出生命值上限提醒："+溢出值" 彩色文字（与偏移色相错开，视觉更活跃）
		if isOverheal then
			local overflow = math.Round(health - maxhealth)
			local overflowColor = RainbowColor(0)
			draw.SimpleTextBlurry("+" .. overflow, "ZSHUDFontSmall", x, y - 4 * screenscale, overflowColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end

		-- 人类血甲条
		if lp:Team() == TEAM_HUMAN then
			local bloodarmor = math.max(lp:GetBloodArmor(), 0)
			local maxarmor = math.max(lp.MaxBloodArmor or 10, 1)
			local isArmorOverheal = bloodarmor > maxarmor

			self.dispBloodArmor = Approach(self.dispBloodArmor, bloodarmor, ANIM_SPEED)

			if bloodarmor > 0 or self.dispBloodArmor > 0.05 then
				x = 78 * screenscale
				y = 142 * screenscale
				wid, hei = 240 * screenscale, 14 * screenscale

				healthperc = math.Clamp(self.dispBloodArmor / maxarmor, 0, 1)
				colHealth.r = 50 + healthperc * 205
				colHealth.g = 0
				colHealth.b = (1 - healthperc) * 50

				subwidth = healthperc * wid

				-- 血甲值数字（超出上限时变为循环彩色）
				local armorNumColor = isArmorOverheal and RainbowColor(240) or colHealth
				draw.SimpleTextBlurry(math.Round(self.dispBloodArmor), "ZSHUDFontSmall", x + wid + 12 * screenscale, y + 8 * screenscale, armorNumColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				-- 血甲条背景
				surface.SetDrawColor(0, 0, 0, 230)
				surface.DrawRect(x, y, wid, hei)

				-- 血甲条填充
				surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 160)
				surface.SetTexture(texDownEdge)
				surface.DrawTexturedRect(x + 2, y + 1, subwidth - 4, hei - 2)
				surface.SetDrawColor(colHealth.r * 0.5, colHealth.g * 0.5, colHealth.b, 30)
				surface.DrawRect(x + 2, y + 1, subwidth - 4, hei - 2)

				-- 血甲末端发光
				surface.SetMaterial(matGlow)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(x + 2 + subwidth - 6, y + 1 - hei/2, 4, hei * 2)

				-- 血甲超出上限提醒："+溢出值" 彩色文字
				if isArmorOverheal then
					local overflow = math.Round(bloodarmor - maxarmor)
					local overflowColor = RainbowColor(240)
					draw.SimpleTextBlurry("+" .. overflow, "ZSHUDFontSmall", x, y - 4 * screenscale, overflowColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				end
			end
		end
	end
end

-- ============================================================================
-- Init - 初始化生命值区域
-- ============================================================================
function PANEL:Init()
	self:DockMargin(0, 0, 0, 0)
	self:DockPadding(0, 0, 0, 0)

	-- 内容面板（负责绘制生命值条）
	local contents = vgui.Create("Panel", self)
	contents:Dock(FILL)
	contents.Paint = ContentsPaint

	self:ParentToHUD()
	self:InvalidateLayout()
end

-- ============================================================================
-- PerformLayout - 布局面板大小和位置
-- ============================================================================
function PANEL:PerformLayout()
	local screenscale = BetterScreenScale()

	self:SetSize(screenscale * 500, screenscale * 168)

	self:AlignLeft()
	self:AlignBottom()
end

-- 左侧渐变材质
local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})

-- ============================================================================
-- Paint - 绘制背景渐变
-- ============================================================================
function PANEL:Paint(w, h)
	local y = h * 0.6
	h = h - y

	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, y, w * 0.4, h + 1)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(w * 0.4, y, w * 0.6, h + 1)

	surface.SetDrawColor(0, 0, 0, 250)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(0, y, w, 1)

	return true
end

vgui.Register("ZSHealthArea", PANEL, "Panel")