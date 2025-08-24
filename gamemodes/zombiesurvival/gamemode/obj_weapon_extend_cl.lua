-- 本文件主要负责扩展Garry's Mod中"Weapon"（武器）对象在客户端的绘制功能，包括自定义准星、瞄准镜样式、武器选择界面的显示以及隐藏武器模型等。

-- DrawWeaponCrosshair 一个主函数，用于根据设置调用绘制十字准星和中心点。
-- DrawAnimatedRingCrosshair 绘制一个动态的、可以根据武器精准度（cone）变化大小和间距的环形准星。
-- DrawCrosshairCross 绘制十字形的准星线条，其大小和间距会根据武器的精准度动态变化。
-- DrawCrosshairDot 在屏幕中心绘制准星的点，并处理特殊情况下的UI提示（如越肩视角被阻挡）。
-- DrawRegularScope 绘制一个传统的、带有黑色边框的圆形瞄准镜遮罩。
-- DrawFuturisticScope 绘制一个具有科幻风格的、带有蓝色线条和光晕效果的瞄准镜遮罩。
-- BaseDrawWeaponSelection 在武器选择菜单中绘制武器的图标、名称和弹药信息。
-- HideWorldModel 通过重写绘制函数来隐藏武器的世界模型（即其他玩家看到的模型）。
-- HideViewModel 通过修改视图模型的位置函数来隐藏武器的视图模型（即玩家自己看到的模型）。
local meta = FindMetaTable("Weapon")

function meta:DrawWeaponCrosshair()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairCross()
	self:DrawCrosshairDot()
end

local ironsightscrosshair = CreateClientConVar("zs_ironsightscrosshair", "0", true, false):GetBool()
cvars.AddChangeCallback("zs_ironsightscrosshair", function(cvar, oldvalue, newvalue)
	ironsightscrosshair = tonumber(newvalue) == 1
end)

--local CrossHairScale = 1
local matGrad = Material("vgui/white")
local function DrawLine(x, y, rot)
	local thickness = GAMEMODE.CrosshairThickness

	rot = 270 - rot
	surface.SetMaterial(matGrad)
	surface.SetDrawColor(0, 0, 0, GAMEMODE.CrosshairColor.a)
	surface.DrawTexturedRectRotated(x, y, 14, math.max(4 * thickness, 2 + 2 * thickness), rot)
	surface.SetDrawColor(GAMEMODE.CrosshairColor)
	surface.DrawTexturedRectRotated(x, y, 12, 2 * thickness, rot)
end

function meta:DrawAnimatedRingCrosshair()
    -- 前置检查
    if not self.Crosshair_MaterialPath then error("Crosshair_MaterialPath 未设置!") return end
    if not self:GetCone() then error("SWEP:GetCone() 函数未定义!") return end
    if not self.ConeMin or not self.ConeMax then error("SWEP.ConeMin 或 SWEP.ConeMax 未在武器中定义!") return end
	if not GetConVar("zs_crosshair_cicrle"):GetBool() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:Alive() then return end

    if (self.GetIronsights and self:GetIronsights()) or
       (self.GetSprinting and self:GetSprinting()) or
       (self.GetReloading and self:GetReloading()) then
        return
    end

    local x, y = ScrW() / 2, ScrH() / 2

    -- === 动态计算 ===
    local cone = self:GetCone()
    local fov = owner:GetFOV()

    -- 1. 计算目标间距 (与上一版相同)
    local cone_mult  = self.Crosshair_ConeMultiplier or 0.0003125
    local size_mult  = self.Crosshair_ConeSizeMultiplier or 40
    local base_gap = (ScrH() * cone_mult * cone) * (90 / fov)
    local targetGap = base_gap * size_mult

    -- 2. 【核心改动】计算动态尺寸缩放
    local min_scale = self.Crosshair_MinScale or 0.5
    local max_scale = self.Crosshair_MaxScale or 1.0
    -- 使用 Remap 函数，将当前 cone 值从 [ConeMin, ConeMax] 的范围映射到 [min_scale, max_scale] 的范围
    local dynamicScale = math.Remap(cone, self.ConeMin, self.ConeMax, min_scale, max_scale)
    -- 使用 Clamp 确保缩放值不会超出设定的范围，防止意外情况
    dynamicScale = math.Clamp(dynamicScale, min_scale, max_scale)

    -- === 动画与缩放 ===
    if not self.SmoothedCrosshairGap then self.SmoothedCrosshairGap = targetGap end
    self.SmoothedCrosshairGap = Lerp(FrameTime() * self.Crosshair_Smoothing, self.SmoothedCrosshairGap, targetGap)

    local overall_scale = self.Crosshair_OverallScale or 1.0
    -- 将动态尺寸缩放应用到最终大小的计算中
    local final_size = math.Clamp(self.Crosshair_Size * overall_scale * dynamicScale,32,64)
    local final_gap = self.SmoothedCrosshairGap * overall_scale * 0.8

    -- === 绘制 ===
    local col = self.Crosshair_Color
    if not self.CrosshairMaterial then
        self.CrosshairMaterial = Material(self.Crosshair_MaterialPath, "mips smooth")
    end

    local draw_offset = final_gap + (final_size / 2)

    surface.SetMaterial(self.CrosshairMaterial)
    surface.SetDrawColor(col)

    surface.DrawTexturedRectRotated(x - draw_offset, y, final_size, final_size, 0)
    surface.DrawTexturedRectRotated(x + draw_offset, y, final_size, final_size, 180)

    if self.Crosshair_ShowVertical then
        surface.DrawTexturedRectRotated(x, y - draw_offset, final_size, final_size, -90)
        surface.DrawTexturedRectRotated(x, y + draw_offset, final_size, final_size, 90)
    end
end

local baserot = 0
function meta:DrawCrosshairCross()
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5

	local ironsights = self.GetIronsights and self:GetIronsights()

	local cone = self:GetCone()

	if cone <= 0 or ironsights and not ironsightscrosshair then return end

	--cone = ScrH() / 76.8 * cone
	cone = ScrH() * 0.0003125 * cone
	cone = cone * 90 / MySelf:GetFOV()

	CrossHairScale = cone --math.Approach(CrossHairScale, cone, FrameTime() * math.max(5, math.abs(CrossHairScale - cone) * 0.02))

	local midarea = 40 * cone --CrossHairScale

	local vel = MySelf:GetVelocity()
	local len = vel:LengthSqr()
	vel:Normalize()
	if GAMEMODE.NoCrosshairRotate then
		baserot = GAMEMODE.CrosshairOffset
	else
		baserot = math.NormalizeAngle(baserot + vel:Dot(EyeAngles():Right()) * math.min(10, len / 40000))
	end

	local ang = Angle(0, 0, baserot)
	for i=0, 359, 360 / GAMEMODE.CrosshairLines do
		ang.roll = baserot + i
		local p = ang:Up() * midarea
		DrawLine(math.Round(x + p.y), math.Round(y + p.z), ang.roll)
	end
end

function meta:DrawCrosshairDot()
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5
	local thickness = GAMEMODE.CrosshairThickness
	local size = 5 * thickness
	local hsize = size/2

	surface.SetDrawColor(GAMEMODE.CrosshairColor2)
	surface.DrawRect(x - hsize, y - hsize, size, size)
	surface.SetDrawColor(0, 0, 0, GAMEMODE.CrosshairColor2.a)
	surface.DrawOutlinedRect(x - hsize, y - hsize, size, size)

	if GAMEMODE.LastOTSBlocked and MySelf:Team() == TEAM_HUMAN and GAMEMODE:UseOverTheShoulder() then
		GAMEMODE:DrawCircle(x, y, 8, COLOR_RED)
	end
end

local matScope = Material("zombiesurvival/scope")
function meta:DrawRegularScope()
	local scrw, scrh = ScrW(), ScrH()
	local size = math.min(scrw, scrh)
	surface.SetMaterial(matScope)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, size)
	surface.SetDrawColor(0, 0, 0, 255)
	if scrw > size then
		local extra = (scrw - size) * 0.5
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end
	if scrh > size then
		local extra = (scrh - size) * 0.5
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end
	local scope_size = 1          -- 瞄准镜的尺寸，1 代表占满屏幕的垂直高度
	local scope_radius = (scrh * scope_size) / 2

	local crosshair_color = Color(0, 0, 0, 220) -- 十字准星的颜色 (RGBA)
	local line_thickness = 3          -- 十字准星线条的粗细 (像素)
	local gap_size = 6              -- 中心点的大小/间隙 (像素)
	local x, y = scrw / 2, scrh / 2 -- 获取屏幕中心点
			-- 3. 绘制十字准星
	surface.SetDrawColor(crosshair_color)
	local gap = gap_size / 2
	local thickness_half = line_thickness / 2

	-- 绘制四条线，构成一个中间有间隙的十字
	-- 上方竖线
	surface.DrawRect(x - thickness_half, y - scope_radius, line_thickness, scope_radius - gap)
	-- 下方竖线
	surface.DrawRect(x - thickness_half, y + gap, line_thickness, scope_radius - gap)
	-- 左侧横线
	surface.DrawRect(x - scope_radius, y - thickness_half, scope_radius - gap, line_thickness)
	-- 右侧横线
	surface.DrawRect(x + gap, y - thickness_half, scope_radius - gap, line_thickness)
end

local texGradientU = Material("vgui/gradient-u")
local texGradientD = Material("vgui/gradient-d")
local texGradientR = Material("vgui/gradient-r")
function meta:DrawFuturisticScope()
	local scrw, scrh = ScrW(), ScrH()
	local size = math.min(scrw, scrh)
	local hw,hh = scrw * 0.5, scrh * 0.5
	local screenscale = BetterScreenScale()
	local gradsize = math.ceil(size * 0.14)
	local line = 38 * screenscale

	for i=0,6 do
		local rectsize = math.floor(screenscale * 44) + i * math.floor(130 * screenscale)
		local hrectsize = rectsize * 0.5
		surface.SetDrawColor(0,145,255,math.max(35,25 + i * 30)/2)
		surface.DrawOutlinedRect(hw-hrectsize,hh-hrectsize,rectsize,rectsize)
	end
	if scrw > size then
		local extra = (scrw - size) * 0.5
		for i=0,12 do
			surface.SetDrawColor(0,145,255, math.max(10,255 - i * 21.25)/2)
			surface.DrawLine(hw,i*line,hw,i*line+line)
			surface.DrawLine(hw,scrh-i*line,hw,scrh-i*line-line)
			surface.DrawLine(i*line+extra,hh,i*line+line+extra,hh)
			surface.DrawLine(scrw-i*line-extra,hh,scrw-i*line-line-extra,hh)
		end
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end
	if scrh > size then
		local extra = (scrh - size) * 0.5
		for i=0,12 do
			surface.SetDrawColor(0,145,255, math.max(10,255 - i * 21.25)/2)
			surface.DrawLine(hw,i*line+extra,hw,i*line+line+extra)
			surface.DrawLine(hw,scrh-i*line-extra,hw,scrh-i*line-line-extra)
			surface.DrawLine(i*line,hh,i*line+line,hh)
			surface.DrawLine(scrw-i*line,hh,scrw-i*line-line,hh)
		end
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end

	surface.SetMaterial(texGradientU)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, gradsize)
	surface.SetMaterial(texGradientD)
	surface.DrawTexturedRect((scrw - size) * 0.5, scrh - (scrh - size) * 0.5 - gradsize, size, gradsize)
	surface.SetMaterial(texGradientR)
	surface.DrawTexturedRect(scrw - (scrw - size) * 0.5 - gradsize, (scrh - size) * 0.5, gradsize, size)
	surface.DrawTexturedRectRotated((scrw - size) * 0.5 + gradsize / 2, (scrh - size) * 0.5 + size / 2, gradsize, size, 180)
end

function meta:BaseDrawWeaponSelection(x, y, wide, tall, alpha)
	local ammotype1 = self:ValidPrimaryAmmo()
	local ammotype2 = self:ValidSecondaryAmmo()

	--killicon.Draw(x + wide * 0.5, y + tall * 0.5, self:GetClass(), 255)
	-- Doesn't work with pngs...
	local ki = killicon.Get(self:GetClass())
	local cols = ki and ki[#ki] or ""

	if ki and #ki == 3 then
		draw.SimpleText(ki[2], ki[1] .. "ws", x + wide * 0.5, y + tall * 0.5 + 18 * BetterScreenScale(), Color(cols.r, cols.g, cols.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ki then
		local material = Material(ki[1])
		local wid, hei = material:Width(), material:Height()

		surface.SetMaterial(material)
		surface.SetDrawColor(cols.r, cols.g, cols.b, alpha )
		surface.DrawTexturedRect(x + wide * 0.5 - wid * 0.5, y + tall * 0.5 - hei * 0.5, wid, hei)
	end

	draw.SimpleTextBlur(self:GetPrintName(), "ZSHUDFontSmaller", x + wide * 0.5, y + tall * 0.15, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if ammotype1 then
		local total = self:GetPrimaryAmmoCount()
		local inclip = self:Clip1()
		if inclip >= 0 then
			if self.Primary and self.Primary.ClipSize and self.Primary.ClipSize == 1 then
				draw.SimpleTextBlur("["..total.."]", "ZSHUDFontSmaller", x + wide * 0.05, y + tall * 0.8, total == 0 and COLOR_RED or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM_REAL)
			else
				draw.SimpleTextBlur("["..inclip.." / ".. total - inclip .."]", "ZSHUDFontSmaller", x + wide * 0.05, y + tall * 0.8, total == 0 and COLOR_RED or inclip == 0 and COLOR_YELLOW or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM_REAL)
			end
		end
	end

	if ammotype2 then
		local total = self:GetSecondaryAmmoCount()
		local inclip = self:Clip2()
		if inclip >= 0 then
			if self.Secondary and self.Secondary.ClipSize and self.Secondary.ClipSize == 1 then
				draw.SimpleTextBlur("["..total.."]", "ZSHUDFontSmaller", x + wide * 0.95, y + tall * 0.8, total == 0 and COLOR_RED or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM_REAL)
			else
				draw.SimpleTextBlur("["..inclip.." / ".. total - inclip .."]", "ZSHUDFontSmaller", x + wide * 0.95, y + tall * 0.8, total == 0 and COLOR_RED or inclip == 0 and COLOR_YELLOW or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM_REAL)
			end
		end
	end

	return true
end

local function empty() end
function meta:HideWorldModel()
	self:DrawShadow(false)
	self.DrawWorldModel = empty
	self.DrawWorldModelTranslucent = empty
end

local function HiddenViewModel(self, pos, ang)
	return pos + ang:Forward() * -256, ang
end
function meta:HideViewModel()
	self.GetViewModelPosition = HiddenViewModel
end
