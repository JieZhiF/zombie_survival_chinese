-- ============================================================
-- 文件: obj_weapon_extend_cl.lua
-- 作用: 客户端脚本
-- 功能: 扩展武器(Weapon)对象的客户端绘制功能
--       包括自定义准星、瞄准镜样式、武器选择界面、模型隐藏等
-- ============================================================

-- 以下是本文件中所有扩展函数的简要说明：
-- DrawWeaponCrosshair —— 主绘制函数，调用十字准星和中心点绘制
-- DrawAnimatedRingCrosshair —— 绘制动态环形准星，大小/间距随武器精准度变化
-- DrawCrosshairCross —— 绘制十字形准星线条，大小/间距动态变化
-- DrawCrosshairDot —— 绘制屏幕中心准星点，处理越肩视角被阻挡时的提示
-- DrawRegularScope —— 绘制传统圆形瞄准镜遮罩（黑色边框）
-- DrawFuturisticScope —— 绘制科幻风格瞄准镜（蓝色线条+光晕效果）
-- BaseDrawWeaponSelection —— 武器选择菜单中绘制图标、名称和弹药信息
-- HideWorldModel —— 隐藏武器世界模型（其他玩家可见）
-- HideViewModel —— 隐藏武器视图模型（第一人称可见）
-- GetCooldownIcon —— 根据武器类型返回对应的冷却图标材质

-- 获取武器对象的 Lua 元表，用于扩展客户端方法
local meta = FindMetaTable("Weapon")

-- ============================================================
-- 主准星绘制函数
-- 根据控制台变量 crosshair 的设置决定是否绘制准星
-- 依次调用十字准星和中心点的绘制
-- ============================================================
function meta:DrawWeaponCrosshair()
	-- 检查控制台变量 crosshair 是否启用（值为 1）
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	-- 绘制十字准星线条
	self:DrawCrosshairCross()
	-- 绘制准星中心点
	self:DrawCrosshairDot()
end

-- ============================================================
-- 控制台变量: zs_ironsightscrosshair
-- 控制开镜时是否显示准星（默认关闭）
-- ============================================================
local ironsightscrosshair = CreateClientConVar("zs_ironsightscrosshair", "0", true, false):GetBool()
-- 注册变量变更回调，实时更新本地缓存
cvars.AddChangeCallback("zs_ironsightscrosshair", function(cvar, oldvalue, newvalue)
	ironsightscrosshair = tonumber(newvalue) == 1
end)

-- [机瞄淡出] 开镜过渡期间准星透明度乘数；无机瞄系统的武器（近战/僵尸爪）恒为 1
local function GetCrosshairAlphaMul(wep)
	if not IsValid(wep) or not wep.GetIronsightDelta then return 1 end
	-- 玩家主动要求开镜显示准星时不淡出
	if wep.GetIronsights and wep:GetIronsights() and ironsightscrosshair then return 1 end
	return 1 - wep:GetIronsightDelta()
end

-- ============================================================
-- 材质与局部辅助函数
-- matGrad: 白色渐变材质，用于绘制准星线条
-- DrawLine: 绘制单条准星线条（带黑色描边效果）
-- ============================================================
local matGrad = Material("vgui/white")
-- 绘制一条带有内外两层颜色的准星线条
-- x, y: 线条中心坐标
-- rot: 旋转角度（度）
local function DrawLine(x, y, rot, alphamul)
	alphamul = alphamul or 1
	-- 获取准星线条粗细配置
	local thickness = GAMEMODE.CrosshairThickness

	-- 计算实际旋转角度（从默认朝上方向旋转）
	rot = 270 - rot
	-- 设置渐变材质
	surface.SetMaterial(matGrad)
	-- 先绘制黑色描边层（外圈）
	surface.SetDrawColor(0, 0, 0, GAMEMODE.CrosshairColor.a * alphamul)
	surface.DrawTexturedRectRotated(x, y, 14, math.max(4 * thickness, 2 + 2 * thickness), rot)
	-- 再绘制主要颜色层（内圈）
	surface.SetDrawColor(ColorAlpha(GAMEMODE.CrosshairColor, GAMEMODE.CrosshairColor.a * alphamul))
	surface.DrawTexturedRectRotated(x, y, 12, 2 * thickness, rot)
end

-- ============================================================
-- 动态环形准星绘制
-- 根据武器精准度(Cone)动态计算准星的大小和间距，并平滑过渡
-- 需要武器定义 Crosshair_MaterialPath、ConeMin、ConeMax 等属性
-- ============================================================
function meta:DrawAnimatedRingCrosshair()
	-- 前置检查：验证必要的武器属性是否已定义
	if not self.Crosshair_MaterialPath then error("Crosshair_MaterialPath 未设置!") return end
	if not self:GetCone() then error("SWEP:GetCone() 函数未定义!") return end
	if not self.ConeMin or not self.ConeMax then error("SWEP.ConeMin 或 SWEP.ConeMax 未在武器中定义!") return end
	-- 检查控制台变量是否启用了圆形准星
	if not GetConVar("zs_crosshair_cicrle"):GetBool() then return end
	-- 获取武器持有者并验证
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:Alive() then return end

	-- 检查玩家当前状态，以下状态不绘制准星
	if (self.GetIronsights and self:GetIronsights()) or
	   (self.GetSprinting and self:GetSprinting()) or
	   (self.GetReloading and self:GetReloading()) then
		return
	end

	-- 获取屏幕中心坐标
	local x, y = ScrW() / 2, ScrH() / 2

	-- === 动态计算准星间距与尺寸 ===
	local cone = self:GetCone()
	local fov = owner:GetFOV()

	-- 1. 计算目标间距（基于精准度和视野调整）
	local cone_mult  = self.Crosshair_ConeMultiplier or 0.0003125
	local size_mult  = self.Crosshair_ConeSizeMultiplier or 40
	local base_gap = (ScrH() * cone_mult * cone) * (90 / fov)
	local targetGap = base_gap * size_mult

	-- 2. 计算动态尺寸缩放（根据当前精准度在最小/最大缩放范围内映射）
	local min_scale = self.Crosshair_MinScale or 0.5
	local max_scale = self.Crosshair_MaxScale or 1.0
	-- 使用 Remap 函数将当前 cone 从 [ConeMin, ConeMax] 映射到 [min_scale, max_scale]
	local dynamicScale = math.Remap(cone, self.ConeMin, self.ConeMax, min_scale, max_scale)
	-- 限制缩放值在指定范围内
	dynamicScale = math.Clamp(dynamicScale, min_scale, max_scale)

	-- === 平滑动画过渡 ===
	if not self.SmoothedCrosshairGap then self.SmoothedCrosshairGap = targetGap end
	self.SmoothedCrosshairGap = Lerp(FrameTime() * self.Crosshair_Smoothing, self.SmoothedCrosshairGap, targetGap)

	-- 应用整体缩放比例
	local overall_scale = self.Crosshair_OverallScale or 1.0
	-- 最终尺寸 = 基础尺寸 * 整体缩放 * 动态缩放（限制在 32~64 像素）
	local final_size = math.Clamp(self.Crosshair_Size * overall_scale * dynamicScale, 32, 64)
	local final_gap = self.SmoothedCrosshairGap * overall_scale * 0.8

	-- === 绘制环形准星 ===
	local col = self.Crosshair_Color
	-- 延迟加载准星材质
	if not self.CrosshairMaterial then
		self.CrosshairMaterial = Material(self.Crosshair_MaterialPath, "mips smooth")
	end

	-- 计算绘制偏移量（间距 + 一半尺寸）
	local draw_offset = final_gap + (final_size / 2)

	-- 设置材质和颜色
	surface.SetMaterial(self.CrosshairMaterial)
	surface.SetDrawColor(col)

	-- 绘制左右两个准星标记
	surface.DrawTexturedRectRotated(x - draw_offset, y, final_size, final_size, 0)
	surface.DrawTexturedRectRotated(x + draw_offset, y, final_size, final_size, 180)

	-- 如果启用了上下标记，额外绘制上下两个
	if self.Crosshair_ShowVertical then
		surface.DrawTexturedRectRotated(x, y - draw_offset, final_size, final_size, -90)
		surface.DrawTexturedRectRotated(x, y + draw_offset, final_size, final_size, 90)
	end
end

-- ============================================================
-- 十字形准星绘制
-- 根据武器精准度(Cone)动态调整线条长度和间距
-- 支持准星旋转效果（受玩家移动速度影响）
-- ============================================================
local baserot = 0
function meta:DrawCrosshairCross()
	-- 获取屏幕中心坐标
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5

	-- 获取武器精准度
	local cone = self:GetCone()

	-- 机瞄过渡期间按进度平滑淡出，完全收起后不再绘制
	local alphamul = GetCrosshairAlphaMul(self)
	if cone <= 0 or alphamul <= 0.01 then return end

	-- 将精准度转换为屏幕像素偏移量
	cone = ScrH() * 0.0003125 * cone
	-- 根据视野角度调整准星缩放
	cone = cone * 90 / MySelf:GetFOV()

	-- 缓存当前缩放值（此处直接赋值而非平滑过渡，原注释掉的代码为平滑版本）
	CrossHairScale = cone

	-- 计算准星中心空白区域的大小
	local midarea = 40 * cone

	-- 获取玩家速度向量用于准星旋转
	local vel = MySelf:GetVelocity()
	local len = vel:LengthSqr()
	vel:Normalize()
	-- 根据游戏模式决定是否禁用准星旋转
	if GAMEMODE.NoCrosshairRotate then
		baserot = GAMEMODE.CrosshairOffset
	else
		-- 根据玩家侧向移动速度动态旋转准星
		baserot = math.NormalizeAngle(baserot + vel:Dot(EyeAngles():Right()) * math.min(10, len / 40000))
	end

	-- 根据配置的线条数循环绘制多条准星线
	local ang = Angle(0, 0, baserot)
	for i = 0, 359, 360 / GAMEMODE.CrosshairLines do
		ang.roll = baserot + i
		local p = ang:Up() * midarea
		DrawLine(math.Round(x + p.y), math.Round(y + p.z), ang.roll, alphamul)
	end
end

-- ============================================================
-- 准星中心点绘制
-- 在屏幕中心绘制一个点（带黑色描边）
-- 当越肩视角被阻挡时，额外显示红色圆圈提示
-- ============================================================
function meta:DrawCrosshairDot()
	-- 获取屏幕中心坐标
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5
	-- 获取准星线条粗细
	local thickness = GAMEMODE.CrosshairThickness
	-- 计算中心点尺寸
	local size = 5 * thickness
	local hsize = size / 2
	-- 机瞄过渡期间同步淡出
	local ply = MySelf and MySelf:IsValid() and MySelf or LocalPlayer()
	local alphamul = GetCrosshairAlphaMul(IsValid(ply) and ply:GetActiveWeapon() or NULL)
	if alphamul <= 0.01 then return end

	-- 绘制中心点（主要颜色）
	surface.SetDrawColor(ColorAlpha(GAMEMODE.CrosshairColor2, GAMEMODE.CrosshairColor2.a * alphamul))
	surface.DrawRect(x - hsize, y - hsize, size, size)
	-- 绘制中心点黑色描边
	surface.SetDrawColor(0, 0, 0, GAMEMODE.CrosshairColor2.a * alphamul)
	surface.DrawOutlinedRect(x - hsize, y - hsize, size, size)

	-- 处理越肩视角被阻挡的情况，显示红色提示圆圈
	if GAMEMODE.LastOTSBlocked and MySelf:Team() == TEAM_HUMAN and GAMEMODE:UseOverTheShoulder() then
		GAMEMODE:DrawCircle(x, y, 8, ColorAlpha(COLOR_RED, 255 * alphamul))
	end
end

-- ============================================================
-- 传统圆形瞄准镜绘制
-- 绘制黑色遮罩+圆形透明区域的瞄准镜效果
-- 附带十字准星线条（中心带间隙）
-- ============================================================
local matScope = Material("zombiesurvival/scope")
function meta:DrawRegularScope()
	-- 获取屏幕宽高
	local scrw, scrh = ScrW(), ScrH()
	-- 瞄准镜区域取宽高中较小的值，确保圆形完整显示
	local size = math.min(scrw, scrh)
	-- 绘制瞄准镜圆形纹理
	surface.SetMaterial(matScope)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, size)
	-- 绘制黑色遮罩覆盖屏幕多余部分
	surface.SetDrawColor(0, 0, 0, 255)
	-- 如果屏幕比瞄准镜宽，则左右两侧用黑色填充
	if scrw > size then
		local extra = (scrw - size) * 0.5
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end
	-- 如果屏幕比瞄准镜高，则上下两侧用黑色填充
	if scrh > size then
		local extra = (scrh - size) * 0.5
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end
	-- 配置十字准星参数
	local scope_size = 1                     -- 瞄准镜尺寸，1 表示占满屏幕高度
	local scope_radius = (scrh * scope_size) / 2
	local crosshair_color = Color(0, 0, 0, 220) -- 十字准星颜色（半透明黑色）
	local line_thickness = 3                     -- 线条粗细
	local gap_size = 6                           -- 中心间隙大小
	local x, y = scrw / 2, scrh / 2              -- 屏幕中心

	-- 绘制十字准星（四条线，中心有间隙）
	surface.SetDrawColor(crosshair_color)
	local gap = gap_size / 2
	local thickness_half = line_thickness / 2

	-- 上方竖线
	surface.DrawRect(x - thickness_half, y - scope_radius, line_thickness, scope_radius - gap)
	-- 下方竖线
	surface.DrawRect(x - thickness_half, y + gap, line_thickness, scope_radius - gap)
	-- 左侧横线
	surface.DrawRect(x - scope_radius, y - thickness_half, scope_radius - gap, line_thickness)
	-- 右侧横线
	surface.DrawRect(x + gap, y - thickness_half, scope_radius - gap, line_thickness)
end

-- ============================================================
-- 科幻风格瞄准镜绘制
-- 绘制带有蓝色光晕、多层边框和动态线条的瞄准镜效果
-- ============================================================
local texGradientU = Material("vgui/gradient-u")  -- 向上渐变材质
local texGradientD = Material("vgui/gradient-d")  -- 向下渐变材质
local texGradientR = Material("vgui/gradient-r")  -- 向右渐变材质
function meta:DrawFuturisticScope()
	-- 获取屏幕宽高
	local scrw, scrh = ScrW(), ScrH()
	-- 瞄准镜区域取最小值
	local size = math.min(scrw, scrh)
	-- 屏幕中心坐标
	local hw, hh = scrw * 0.5, scrh * 0.5
	-- 计算屏幕缩放比例
	local screenscale = BetterScreenScale()
	-- 渐变区域高度
	local gradsize = math.ceil(size * 0.14)
	-- 线条间距
	local line = 38 * screenscale

	-- 绘制多层同心矩形边框（蓝色光晕效果）
	for i = 0, 6 do
		local rectsize = math.floor(screenscale * 44) + i * math.floor(130 * screenscale)
		local hrectsize = rectsize * 0.5
		surface.SetDrawColor(0, 145, 255, math.max(35, 25 + i * 30) / 2)
		surface.DrawOutlinedRect(hw - hrectsize, hh - hrectsize, rectsize, rectsize)
	end

	-- 处理屏幕宽度超出瞄准镜的情况
	if scrw > size then
		local extra = (scrw - size) * 0.5
		-- 绘制水平方向的动态线条
		for i = 0, 12 do
			surface.SetDrawColor(0, 145, 255, math.max(10, 255 - i * 21.25) / 2)
			surface.DrawLine(hw, i * line, hw, i * line + line)
			surface.DrawLine(hw, scrh - i * line, hw, scrh - i * line - line)
			surface.DrawLine(i * line + extra, hh, i * line + line + extra, hh)
			surface.DrawLine(scrw - i * line - extra, hh, scrw - i * line - line - extra, hh)
		end
		-- 左右黑色遮罩
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end

	-- 处理屏幕高度超出瞄准镜的情况
	if scrh > size then
		local extra = (scrh - size) * 0.5
		-- 绘制垂直方向的动态线条
		for i = 0, 12 do
			surface.SetDrawColor(0, 145, 255, math.max(10, 255 - i * 21.25) / 2)
			surface.DrawLine(hw, i * line + extra, hw, i * line + line + extra)
			surface.DrawLine(hw, scrh - i * line - extra, hw, scrh - i * line - line - extra)
			surface.DrawLine(i * line, hh, i * line + line, hh)
			surface.DrawLine(scrw - i * line, hh, scrw - i * line - line, hh)
		end
		-- 上下黑色遮罩
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end

	-- 绘制四边的渐变光晕效果
	surface.SetMaterial(texGradientU)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, gradsize)
	surface.SetMaterial(texGradientD)
	surface.DrawTexturedRect((scrw - size) * 0.5, scrh - (scrh - size) * 0.5 - gradsize, size, gradsize)
	surface.SetMaterial(texGradientR)
	surface.DrawTexturedRect(scrw - (scrw - size) * 0.5 - gradsize, (scrh - size) * 0.5, gradsize, size)
	surface.DrawTexturedRectRotated((scrw - size) * 0.5 + gradsize / 2, (scrh - size) * 0.5 + size / 2, gradsize, size, 180)
end

-- ============================================================
-- 武器选择菜单绘制
-- 在武器选择界面中显示武器的击杀图标、名称和弹药信息
-- 返回值: true（表示绘制完成）
-- ============================================================
function meta:BaseDrawWeaponSelection(x, y, wide, tall, alpha)
	-- 获取有效的主副弹药类型
	local ammotype1 = self:ValidPrimaryAmmo()
	local ammotype2 = self:ValidSecondaryAmmo()

	-- 获取武器的击杀图标信息
	local ki = killicon.Get(self:GetClass())
	local cols = ki and ki[#ki] or ""

	-- 判断击杀图标格式并绘制
	if ki and #ki == 3 then
		-- 文本格式的图标（使用字体+字符）
		draw.SimpleText(ki[2], ki[1] .. "ws", x + wide * 0.5, y + tall * 0.5 + 13 * BetterScreenScale(), Color(cols.r, cols.g, cols.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ki then
		-- 材质格式的图标（使用图片）
		local material = Material(ki[1])
		local wid, hei = material:Width(), material:Height()
		surface.SetMaterial(material)
		surface.SetDrawColor(cols.r, cols.g, cols.b, alpha)
		surface.DrawTexturedRect(x + wide * 0.5 - wid * 0.5, y + tall * 0.5 - hei * 0.5, wid, hei)
	end

	-- 绘制武器名称（红色，模糊阴影效果）
	draw.SimpleTextBlur(self:GetPrintName(), "ZSHUDFontSmaller", x + wide * 0.5, y + tall * 0.15, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	-- 如果有有效的主弹药，绘制主弹药数量信息
	if ammotype1 then
		local total = self:GetPrimaryAmmoCount()
		local inclip = self:Clip1()
		-- 判断弹夹容量是否大于 0
		if inclip >= 0 then
			-- 单发装填武器（如霰弹枪）仅显示总数量
			if self.Primary and self.Primary.ClipSize and self.Primary.ClipSize == 1 then
				draw.SimpleTextBlur("[" .. total .. "]", "ZSHUDFontSmaller", x + wide * 0.05, y + tall * 0.8, total == 0 and COLOR_RED or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM_REAL)
			else
				-- 常规武器显示 "弹夹内 / 备用" 格式
				draw.SimpleTextBlur("[" .. inclip .. " / " .. total - inclip .. "]", "ZSHUDFontSmaller", x + wide * 0.05, y + tall * 0.8, total == 0 and COLOR_RED or inclip == 0 and COLOR_YELLOW or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM_REAL)
			end
		end
	end

	-- 如果有有效的副弹药，绘制副弹药数量信息（显示在右侧）
	if ammotype2 then
		local total = self:GetSecondaryAmmoCount()
		local inclip = self:Clip2()
		-- 判断弹夹容量是否大于 0
		if inclip >= 0 then
			-- 单发装填武器仅显示总数量
			if self.Secondary and self.Secondary.ClipSize and self.Secondary.ClipSize == 1 then
				draw.SimpleTextBlur("[" .. total .. "]", "ZSHUDFontSmaller", x + wide * 0.95, y + tall * 0.8, total == 0 and COLOR_RED or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM_REAL)
			else
				-- 常规武器显示 "弹夹内 / 备用" 格式
				draw.SimpleTextBlur("[" .. inclip .. " / " .. total - inclip .. "]", "ZSHUDFontSmaller", x + wide * 0.95, y + tall * 0.8, total == 0 and COLOR_RED or inclip == 0 and COLOR_YELLOW or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM_REAL)
			end
		end
	end

	return true
end

-- ============================================================
-- 隐藏武器世界模型（服务端/客户端通用）
-- 通过覆盖绘制函数和禁用阴影来实现
-- ============================================================
-- 空函数，用于替换绘制函数以取消渲染
local function empty() end
function meta:HideWorldModel()
	-- 禁用武器阴影
	self:DrawShadow(false)
	-- 将世界模型绘制函数替换为空函数
	self.DrawWorldModel = empty
	self.DrawWorldModelTranslucent = empty
end

-- ============================================================
-- 隐藏武器视图模型（仅客户端）
-- 通过修改视图模型位置函数，将其移到视野之外
-- ============================================================
-- 将视图模型位置移到玩家背后很远的位置（不可见）
local function HiddenViewModel(self, pos, ang)
	return pos + ang:Forward() * -256, ang
end
function meta:HideViewModel()
	-- 替换视图模型位置计算函数
	self.GetViewModelPosition = HiddenViewModel
end

-- ============================================================
-- 获取冷却图标材质
-- 根据武器的 WeaponType 属性返回对应的材质路径
-- 默认使用手枪类型材质
-- ============================================================
function meta:GetCooldownIcon()
	-- 获取武器类型，默认为手枪
	local wType = self.WeaponType or "pistol"
	-- 从 WeaponMaterials 表中查询对应的材质，找不到则使用手枪
	return WeaponMaterials[wType] or WeaponMaterials["pistol"]
end
