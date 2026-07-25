
---
-- @function SWEP:PreDrawViewModel
-- @description 在绘制视图模型之前调用。
--
function SWEP:PreDrawViewModel(vm)
	-- 如果设置了不显示视图模型，则将其完全透明化。
	if self.ShowViewModel == false then
		render.SetBlend(0)
	end
end

---
-- @function SWEP:PostDrawViewModel
-- @description 在绘制视图模型之后调用。
--
function SWEP:PostDrawViewModel(vm)
	-- 恢复渲染混合模式。
	if self.ShowViewModel == false then
		render.SetBlend(1)
	end

	-- 如果定义了 3D HUD 并且游戏模式允许绘制，则进行绘制。
	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end
end

---
-- @function SWEP:GetHUD3DPos
-- @description 获取 3D HUD 在世界中的位置和角度。
--
function SWEP:GetHUD3DPos(vm)
	-- 查找指定的骨骼。
	local bone = vm:LookupBone(self.HUD3DBone)
	if not bone then return end

	-- 获取骨骼的矩阵信息（包含位置和角度）。
	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	-- 如果视图模型是翻转的，需要修正角度。
	if self.ViewModelFlip then
		ang.r = -ang.r
	end

	-- 应用位置和角度偏移。
	local offset = self.HUD3DPos
	local aoffset = self.HUD3DAng
	pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z
	if aoffset.yaw ~= 0 then ang:RotateAroundAxis(ang:Up(), aoffset.yaw) end
	if aoffset.pitch ~= 0 then ang:RotateAroundAxis(ang:Right(), aoffset.pitch) end
	if aoffset.roll ~= 0 then ang:RotateAroundAxis(ang:Forward(), aoffset.roll) end

	return pos, ang
end

-- 定义 3D HUD 使用的颜色
local colBG = Color(16, 16, 16, 90)
local colRed = Color(220, 0, 0, 230)
local colYellow = Color(220, 220, 0, 230)
local colWhite = Color(220, 220, 220, 230)
local colAmmo = Color(255, 255, 255, 230)

---
-- @function GetAmmoColor
-- @description 根据当前弹药量返回一个动态颜色。
--
local function GetAmmoColor(clip, maxclip)
	if clip == 0 then
		colAmmo.r, colAmmo.g, colAmmo.b = 255, 0, 0
	else
		-- 弹药越少，颜色越偏向红色。
		local sat = clip / maxclip
		colAmmo.r = 255
		colAmmo.g = sat ^ 0.3 * 255
		colAmmo.b = sat * 255
	end
end

---
-- @function SWEP:GetDisplayAmmo
-- @description 计算用于显示的弹药数量，处理某些武器一次消耗多发子弹的情况。
--
function SWEP:GetDisplayAmmo(clip, backammo, maxclip)
	if self.RequiredClip ~= 1 then
		clip = math.floor(clip / self.RequiredClip)
		backammo = math.floor(backammo / self.RequiredClip)
		maxclip = math.ceil(maxclip / self.RequiredClip)
	end

	if self.AmmoUse then
		clip = math.floor(clip / self.AmmoUse)
		backammo = math.floor(backammo / self.AmmoUse)
		maxclip = math.ceil(maxclip / self.AmmoUse)
	end

	return clip, backammo, maxclip
end

---
-- @function SWEP:Draw3DHUD
-- @description 绘制附着在武器模型上的 3D HUD。
--
function SWEP:Draw3DHUD(vm, pos, ang)
	local wid, hei = 200, 240
	local x, y = wid * -0.6, hei * -0.5

	-- 获取弹药信息
	local clip = self:Clip1()
	local owner = self:GetOwner()
	local ammocount = owner:GetAmmoCount(self:GetPrimaryAmmoType())
	local maxclip = self.Primary.ClipSize
	local dclip, dbackammo, dmaxclip = self:GetDisplayAmmo(clip, ammocount, maxclip)
	--local auto = self.Primart.Automatic
	-- 开始 3D 空间中的 2D 绘制
	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		-- 绘制背景
		draw.RoundedBoxEx(32, x, y, wid, hei, colBG, true, false, true, false)

		-- 绘制备弹量
		local displayspare = dmaxclip > 0 and self.Primary.DefaultClip ~= 99999
		if displayspare then
			-- 根据备弹量多少选择不同颜色
			local ammoColor = dbackammo == 0 and colRed or dbackammo <= dmaxclip and colYellow or colWhite
			draw.SimpleTextBlurry(dbackammo, dbackammo >= 1000 and "ZS3D2DFontSmall" or "ZS3D2DFont", x + wid * 0.5, y + hei * 0.65, ammoColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- 绘制当前弹匣弹量
		GetAmmoColor(dclip, dmaxclip) -- 获取动态颜色
		draw.SimpleTextBlurry(dclip, dclip >= 100 and "ZS3D2DFont" or "ZS3D2DFontBig", x + wid * 0.5, y + hei * (displayspare and 0.3 or 0.5), colAmmo, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self.Primary.Automatic then
			draw.SimpleText("Auto","ZS3D2DFontSmall",x + wid * 0.5, y + hei * 0.88,color_white_alpha230,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end


---
-- @function SWEP:Draw2DHUD
-- @description 绘制屏幕右下角的 2D 武器信息 HUD。
--
function SWEP:Draw2DHUD()
	-- 尺寸和位置计算，适配不同屏幕分辨率
    local screenscale = BetterScreenScale()
    local padding = 8 * screenscale
    local elementHeight = 64 * screenscale
    local sw, sh = ScrW(), ScrH()
	local panelx = 300 * screenscale
    local x = sw - panelx
    local y = sh - elementHeight - padding * 4

    -- 获取弹药信息
    local clip = self:Clip1()
    local owner = self:GetOwner()
    local ammocount = owner:GetAmmoCount(self:GetPrimaryAmmoType())
    local maxclip = self:GetPrimaryClipSize()
	local dclip, dbackammo, dmaxclip = self:GetDisplayAmmo(clip, ammocount, maxclip)

    -- 计算文本尺寸以实现动态布局
    surface.SetFont("ZSA_HUD_Name")
    local wname = self:GetPrintName()
    local nameW, nameH = surface.GetTextSize(wname)
    
    surface.SetFont("ZSA_HUD_Clip")
    local clipText = tostring(dclip)
    local clipW = surface.GetTextSize(clipText)
    
    surface.SetFont("ZSA_HUD_Ammo")
    local ammoText = " / " .. tostring(dbackammo)
    local ammoW = surface.GetTextSize(ammoText)
    
    -- 计算面板总宽度
    local totalWidth = math.max(nameW, clipW + ammoW) + 96 * screenscale
    
    -- 绘制背景面板
    surface.SetDrawColor(30, 30, 30, 220)
    surface.DrawRect(x, y, totalWidth, elementHeight)
    
    -- 绘制武器名称
    surface.SetTextColor(255, 255, 255)
    surface.SetFont("ZSA_HUD_Name")
    surface.SetTextPos(x + padding, y + padding)
    surface.DrawText(wname)
    
    -- 绘制弹药数量
    local numbersY = y + elementHeight - 32 * screenscale - padding
    surface.SetFont("ZSA_HUD_Clip")
    surface.SetTextPos(x + padding, numbersY)
    surface.DrawText(clipText)
    
    surface.SetFont("ZSA_HUD_Ammo")
    surface.SetTextPos(x + padding + clipW, numbersY + (32 - 20) * screenscale / 2)
    surface.DrawText(ammoText)
    
    -- 绘制弹药进度条
    local barHeight = 4 * screenscale
    local barY = y + elementHeight - barHeight - padding
    local progress = (dmaxclip > 0) and math.Clamp(dclip / dmaxclip, 0, 1) or 0
    
    surface.SetDrawColor(50, 50, 50, 220) -- 进度条背景
    surface.DrawRect(x + padding, barY, totalWidth - padding * 2, barHeight)
    
    surface.SetDrawColor(204, 204, 204) -- 进度条前景
    surface.DrawRect(x + padding, barY, (totalWidth - padding * 2) * progress, barHeight)
    
    -- 绘制武器的击杀图标 (Killicon)
    local iconSize = 48 * screenscale
    local iconX = x + totalWidth - iconSize - padding
    local iconY = y + (elementHeight - iconSize) / 2
    
    local killiconData = killicon.Get(self:GetClass())
    if killiconData then
        if killicon.GetFont(self:GetClass()) then
            -- 如果是字体图标
            surface.SetFont(killiconData[1])
            surface.SetTextColor(killiconData[3] or color_white)
            local tw, th = surface.GetTextSize(killiconData[2])
            surface.SetTextPos(iconX + (iconSize - tw) / 2, iconY + (iconSize - th) / 2)
            surface.DrawText(killiconData[2])
        else
            -- 如果是材质图标
            surface.SetMaterial(Material(killiconData[1]))
            surface.SetDrawColor(killiconData[2] or color_white)
            surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
        end
    end
end

function SWEP:CooldownRingBinding()
    local finish = self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADEND)
    local now = CurTime()
    return math.max(0, finish - now)
end

function SWEP:CooldownRingMaximumBinding()
    local startTime = self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADSTART)
    local finishTime = self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADEND)
    return math.max(0, finishTime - startTime)
end

function SWEP:DrawCooldowns()
	if self:GetPrimaryAmmoCount() <= 0 then return end
	local cooldownIcon = self:GetCooldownIcon()
    local coneGap = self:GetCone() / 2
    local betterscale = BetterScreenScale()
    local remaining = self:CooldownRingBinding()
    local maximum = self:CooldownRingMaximumBinding()
    local ringSize = math.Clamp(CrosshairCoolPrimaryCircleSize, 0.5, 16) + coneGap
    local ringSpacing = math.Clamp(CrosshairCoolPrimaryCircleSize, 0, 16) + coneGap + self.CooldownExtraSize
    local ringColor = Color(255, 40, 40)
    local backgroundColor = Color(12, 12, 12, 30)

    if remaining > 0 and maximum > 0 and remaining ~= math.huge and maximum ~= math.huge then
        local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5

        if CurTime() >= self:GetReloadStart() and CurTime() <= self:GetReloadFinish() then
            local innerRadius = (ringSpacing) * 10 * betterscale
            draw.HollowCircle(centerX, centerY, innerRadius, 2 * ringSize, 270, 270 + 360 * remaining / maximum, ringColor)
            draw.HollowCircle(centerX, centerY, innerRadius, 2 * ringSize, 270, 270 + 360, backgroundColor)
            draw.SimpleTextBlurry(math.Round(remaining, 1), "RemingtonNoiseless", centerX - innerRadius * 2, centerY,ringColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local iw, ih = cooldownIcon:Width(), cooldownIcon:Height()
            if iw == 0 or ih == 0 then iw, ih = 64, 64 end
            local pad = math.max(2, ringSize * 0.8)
            local iconMax = (innerRadius - pad) * 2
            local s = math.min(iconMax / iw, iconMax / ih)
            local w, h = math.floor(iw * s), math.floor(ih * s)
            local rotation = CurTime() * 90

            surface.SetMaterial(cooldownIcon)
            surface.SetDrawColor(ringColor)
            surface.DrawTexturedRectRotated(centerX, centerY, w, h, rotation)
        end
    end
end

---
-- @function SWEP:DrawHUD
-- @description 主 HUD 绘制函数，决定绘制哪些 HUD 元素。
--

function SWEP:DrawHUD()
	-- 根据游戏模式设置决定是否绘制 2D HUD
	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:DrawCooldowns()
		self:Draw2DHUD()
	end
	if self:GetReloadFinish() > 0 then return end
	self:DrawWeaponCrosshair() -- 绘制准星（如果启用）


end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end