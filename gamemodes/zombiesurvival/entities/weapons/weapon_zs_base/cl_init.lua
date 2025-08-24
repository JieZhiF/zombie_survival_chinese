-- =============================================================================
-- GMod SWEP 动画与视图模型基础脚本
--
-- 描述:
-- 这是一个功能丰富的 SWEP 基础脚本，用于处理高级视图模型动画，
-- 包括平滑的机械瞄准（铁瞄）、自定义武器检视序列、呼吸效果、
-- 动态 3D/2D HUD 以及与游戏模式的集成。
--
-- 主要功能:
-- - 动态机械瞄准系统，支持平滑过渡。
-- - 可配置的多阶段武器检视动画。
-- - 模拟持枪时的“呼吸”和摇摆效果。
-- - 附着在武器模型上的 3D 弹药 HUD。
-- - 现代化的 2D 弹药和武器信息 HUD。
-- - 从外部文件加载自定义瞄准位置。
-- =============================================================================

-- 确保此脚本在客户端运行，因为所有视图模型和 HUD 操作都在客户端执行。
INC_CLIENT()

-- 引入外部的动画库，可能包含一些预设的动画处理函数。
include("animations.lua")

-- =============================================================================
-- SECTION: SWEP 基础配置
-- =============================================================================

SWEP.DrawAmmo = true                      -- 是否绘制游戏默认的弹药 HUD。
SWEP.DrawCrosshair = false                -- 是否绘制准星。
SWEP.Slot = 0                             -- 武器在武器选择栏中的位置（0 通常是主武器）。

-- =============================================================================
-- SECTION: 视图模型 (ViewModel) 设置
-- =============================================================================

SWEP.ViewModelFOV = 60                    -- 视图模型的视野（FOV），调整武器在屏幕上的大小和远近。
SWEP.ViewModelFlip = true                 -- 是否水平翻转视图模型。对于从 CS:GO 等游戏移植的模型很有用。
SWEP.BobScale = 1                         -- 移动时视图模型的上下晃动幅度。
SWEP.SwayScale = 1                        -- 移动视角时视图模型的左右摇摆幅度。
SWEP.VMPos = Vector(0, 0, 0)              -- 对视图模型的全局位置偏移。用于修正模型位置。
SWEP.VMAng = Angle(0, 0, 0)               -- 对视图模型的全局角度偏移。用于修正模型角度。
SWEP.deploytime = 0
-- =============================================================================
-- SECTION: 机械瞄准 (Iron Sights) 设置
-- =============================================================================

SWEP.IronEnable = true                    -- 是否启用机械瞄准功能。
SWEP.IronSightsPos = Vector(0, 0, 0)       -- 机械瞄准时的位置偏移。
SWEP.IronSightsAng = Angle(0, 0, 0)        -- 机械瞄准时的角度偏移。
SWEP.IronSpeed = 8.5                        -- 进入和退出机械瞄准状态的过渡速度。
SWEP.IronsightsMultiplier = 0.6           -- 瞄准时鼠标灵敏度的缩放系数。

-- [内部变量] - 请勿在子脚本中修改
SWEP.IronPos = Vector(0, 0, 0)            -- (内部使用) 当前的瞄准位置，用于平滑过渡。
SWEP.IronAng = Angle(0, 0, 0)             -- (内部使用) 当前的瞄准角度，用于平滑过渡。

-- =============================================================================
-- SECTION: 武器检视 (Inspect) 设置
-- =============================================================================

SWEP.InspectOnDeploy = false              -- 是否在切换到此武器时自动播放检视动画。
SWEP.DeployInspectTime = 5                -- 如果上面为 true，自动检视的持续时间。
SWEP.InspectSpeed = 1                     -- 检视动画的播放速度倍率。

-- 检视动画序列定义
-- 这是一个表格数组，每个子表格定义一个检视动画的关键帧。
-- pos: 视图模型位置偏移, ang: 视图模型角度偏移, time: 该关键帧的持续时间 (秒)。
SWEP.Inspect = {
	{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0), time = -1}, -- 默认检视位置，time = -1 表示无限时长，直到按键松开。
}

-- 骨骼检视定义 (更高级的检视，可以控制模型骨骼)
-- 允许你在检视动画期间独立地移动或旋转视图模型的特定骨骼。
SWEP.BoneInspect = {
	{
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0), bone = "default"}, -- bone: 要操作的骨骼名称。
	}
}

-- =============================================================================
-- SECTION: 呼吸与摇摆 (Breathing & Sway) 设置
-- =============================================================================

SWEP.Breath = 0                           -- (内部使用) 当前的呼吸偏移量。
SWEP.Breathmult = 10                      -- 呼吸效果的强度乘数，数值越大，效果越微弱。
SWEP.offset = 0                           -- (用途不明确，可能是旧的或特定的偏移变量)。

-- =============================================================================
-- SECTION: 3D HUD 设置
-- =============================================================================

SWEP.HUD3DBone = "base"                   -- 3D HUD 附着的视图模型骨骼名称。
SWEP.HUD3DScale = 0.01                    -- 3D HUD 的整体缩放大小。
SWEP.HUD3DAng = Angle(180, 0, 0)          -- 3D HUD 的角度偏移。

-- =============================================================================
-- SECTION: 内部初始化
-- =============================================================================

-- [内部状态变量]
local key = 1      -- 当前检视动画的关键帧索引。
local keytime = 0  -- 当前检视关键帧的结束时间。

-- 遍历所有骨骼检视定义，为每个骨骼添加一个用于实时修改的向量和角度变量。
-- 这样做是为了在不修改原始配置的情况下，动态地应用动画效果。
for k, v in pairs(SWEP.BoneInspect) do
	for f, b in pairs(v) do
		b.modv = Vector(0, 0, 0)
		b.moda = Angle(0, 0, 0)
	end
end


-- =============================================================================
-- SECTION: 核心函数 (Core Functions)
-- =============================================================================

---
-- @function SWEP:Deploy
-- @description 武器部署（切换到该武器）时调用。
--
function SWEP:Deploy()
	-- 如果设置了部署时检视，则设定一个计时器。
	-- 否则，将 deploytime 初始化为 0，以防止与 nil 比较的错误。
	if self.InspectOnDeploy == true then
		self.deploytime = CurTime() + self.DeployInspectTime
	else
		self.deploytime = 0 -- <<<<<< 新增的行
	end

	-- 创建视图模型元素（如果使用了自定义模型元素）。
	self:CreateModels(self.VElements)
	return true
end

---
-- @function SWEP:DoAnims
-- @description 动画处理核心函数，应在子武器的 Think hook 中调用。
--              负责处理机械瞄准、武器检视和呼吸效果。
--

function SWEP:DoAnims()
	-- 检查并确保视图模型 (VElements) 和世界模型 (WElements) 的实体有效。
	-- 如果无效（例如，玩家重生后），则重新创建它们。
	-- 注意：这部分逻辑通常更适合放在 SWEP:Think() 或 SWEP:Deploy() 中，
	-- 而不是 CalcViewModelView 每次调用时都执行。
	-- 但为了保持原样，我们暂时保留它。
	local check = true
	if self.VElements ~= nil then
		for k, v in pairs(self.VElements) do
			if check == true then
				if v.modelEnt == nil then
					self:CreateModels(self.VElements)
					check = false
				end
			end
		end
	end
	check = true
	if self.WElements ~= nil then
		for k, v in pairs(self.WElements) do
			if check == true then
				if v.modelEnt == nil then
					self:CreateModels(self.WElements)
					check = false
				end
			end
		end
	end

	-- 状态判断与动画应用
	if self.Owner:KeyDown(IN_ATTACK2) and self.IronEnable then
		-- 状态一: 玩家按下右键进行机械瞄准
		-- 使用 Lerp 和 LerpAngle 平滑地将视图模型移动到瞄准位置。
		self.IronPos = LerpVector(RealFrameTime() * self.IronSpeed, self.IronPos, self.IronSightPos)
		self.IronAng = LerpAngle(RealFrameTime() * self.IronSpeed, self.IronAng, self.IronSightAng)
		-- 应用更细微的呼吸效果。
		self.Breath = math.sin(CurTime()) / (self.Breathmult * 80)
		-- 瞄准时减小模型的晃动和摇摆，以提高稳定性。
		self.SwayScale = 0.1
		self.BobScale = 0.1
	elseif (input.IsKeyDown(KEY_G) or self.deploytime > CurTime()) and not input.IsMouseDown(MOUSE_LEFT) then
		-- 状态二: 玩家按下 'G' 键或处于部署检视时间内，且未开火
		-- 应用标准的呼吸效果。
		self.Breath = math.sin(CurTime()) / (self.Breathmult * 4)
		-- 调用检视动画处理函数。
		self:DoInspect()
	else
		-- 状态三: 默认持枪状态
		-- 平滑地将视图模型恢复到默认位置。
		self.IronPos = LerpVector(RealFrameTime() * self.IronSpeed, self.IronPos, Vector(0, 0, 0))
		self.IronAng = LerpAngle(RealFrameTime() * self.IronSpeed, self.IronAng, Angle(0, 0, 0))
		-- 应用标准的呼吸效果。
		self.Breath = math.sin(CurTime()) / (self.Breathmult * 4)
		-- 恢复默认的晃动和摇摆幅度。
		self.SwayScale = 1
		self.BobScale = 1
		-- 重置检视动画的状态。
		keytime = 0
		key = 1
	end

	-- !!! 移除此处对 GetViewModelPosition 的调用 !!!
	-- local pos = self.Owner:GetViewModel(0):GetPos()
	-- local ang = self.Owner:GetViewModel(0):GetAngles()
	-- self:GetViewModelPosition(pos, ang)
end

---
-- @function SWEP:GetViewModelPosition
-- @description 计算并返回最终的视图模型位置和角度。
--              此函数将所有偏移（瞄准、呼吸等）应用到模型上。
-- @param Pos Vector 当前视图模型位置。
-- @param Ang table or Angle 当前视图模型角度。
-- @return Vector, Angle 计算后的新位置和新角度。
--
function SWEP:GetViewModelPosition(Pos, Ang)
	-- 创建一个角度的副本进行操作，以避免修改原始传入的 Ang table/object。
	-- 这样写可以同时兼容 Ang 是一个 Angle 对象或一个包含 p,y,r 的 table 的情况。
	local ang_copy = Angle(Ang.p, Ang.y, Ang.r)

	-- 围绕玩家的视觉轴线旋转视图模型，以应用瞄准角度偏移。
	ang_copy:RotateAroundAxis(EyeAngles():Forward(), self.IronAng.p)
	ang_copy:RotateAroundAxis(EyeAngles():Up(), self.IronAng.y)
	ang_copy:RotateAroundAxis(EyeAngles():Right(), self.IronAng.r)

    -- 计算最终的位置，应用瞄准位置偏移、呼吸效果等。
    local finalPos = Pos +
                     (ang_copy:Forward() * (self.offset + self.IronPos.x)) +
                     (ang_copy:Right() * self.IronPos.y) +
                     (ang_copy:Up() * (self.IronPos.z + self.Breath))

    -- 计算最终的角度，应用一些额外的微调。
    local finalAng = ang_copy + Angle((self.offset + 10) / 3, 0, 0)

	return finalPos, finalAng
end

-- =============================================================================
-- SECTION: 检视动画处理 (Inspect Logic)
-- =============================================================================

---
-- @function SWEP:DoInspect
-- @description 处理武器检视动画序列。
--
function SWEP:DoInspect()
	-- 获取当前关键帧的动画信息。
	local info = self.Inspect[key]
	local Bones = self.BoneInspect[key] -- (骨骼部分在此函数中未实际使用，但已获取)

	-- 如果当前关键帧的计时器未启动，则设置其结束时间。
	if keytime == 0 then
		keytime = CurTime() + self.Inspect[key].time
	end

	-- 如果当前时间超过了关键帧的结束时间，并且该关键帧不是无限时长的，则前进到下一帧。
	if CurTime() > keytime and info.time > 0 then
		key = key + 1
		-- 如果序列播放完毕，可以根据需要循环或停止 (当前代码会因索引越界而出错，需要子脚本处理)
		if not self.Inspect[key] then key = #self.Inspect end -- 简单的循环处理
		keytime = CurTime() + self.Inspect[key].time
	end
	
	self.keyframe = key -- 记录当前关键帧，可能用于其他地方。
	
	-- 使用自定义的曲线插值函数，平滑地将视图模型过渡到当前关键帧的目标位置和角度。
	self.IronPos = self:LerpCurveVec(1, self.IronPos, info.pos)
	self.IronAng = self:LerpCurveAng(1, self.IronAng, info.ang)
end

---
-- @function SWEP:LerpCurveVec
-- @description 使用余弦曲线对 Vector 进行平滑插值，实现 "ease-in/ease-out" 效果。
-- @param a number (未使用)
-- @param b Vector 起始向量。
-- @param c Vector 目标向量。
-- @return Vector 插值结果。
--
function SWEP:LerpCurveVec(a, b, c)
	-- 计算当前时间在关键帧内的进度，并用 cos 函数将其映射到平滑曲线上。
	local progress = self:inv_lerp(1, -1, math.cos(((CurTime() - (keytime - self.Inspect[key].time)) / (self.Inspect[key].time)) / self.InspectSpeed))
	return LerpVector(progress, b, c)
end

---
-- @function SWEP:LerpCurveAng
-- @description 使用余弦曲线对 Angle 进行平滑插值。
--
function SWEP:LerpCurveAng(a, b, c)
	local progress = self:inv_lerp(1, -1, math.cos(((CurTime() - (keytime - self.Inspect[key].time)) / (self.Inspect[key].time)) / self.InspectSpeed))
	return LerpAngle(progress, b, c)
end

---
-- @function SWEP:inv_lerp
-- @description 反向线性插值。计算值 c 在 a 和 b 之间的比例位置。
--
function SWEP:inv_lerp(a, b, c)
	return (c - a) / (b - a)
end


-- =============================================================================
-- SECTION: 游戏模式集成 (Gamemode Integration)
-- =============================================================================

---
-- @function SWEP:TranslateFOV
-- @description 根据游戏模式的设置调整视野（FOV）。
--
function SWEP:TranslateFOV(fov)
	-- 此处逻辑与特定游戏模式（如 ZS）紧密相关，用于在瞄准时缩放FOV。
	return (GAMEMODE.FOVLerp + (self.IsScoped and not GAMEMODE.DisableScopes and 0 or (1 - GAMEMODE.FOVLerp) * (1 - GAMEMODE.IronsightZoomScale))) * fov
end

---
-- @function SWEP:AdjustMouseSensitivity
-- @description 根据游戏模式的设置调整鼠标灵敏度。
--
function SWEP:AdjustMouseSensitivity()
	-- 当进入机械瞄准状态时，返回一个灵敏度乘数。
	if self:GetIronsights() then
		return GAMEMODE.FOVLerp + (self.IsScoped and not GAMEMODE.DisableScopes and 0 or (1 - GAMEMODE.FOVLerp) * (1 - GAMEMODE.IronsightZoomScale))
	end
end


-- =============================================================================
-- SECTION: 绘图函数 (Drawing Functions)
-- =============================================================================

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

---
-- @function SWEP:DrawHUD
-- @description 主 HUD 绘制函数，决定绘制哪些 HUD 元素。
--
function SWEP:DrawHUD()
	self:DrawWeaponCrosshair() -- 绘制准星（如果启用）

	-- 根据游戏模式设置决定是否绘制 2D HUD
	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:Draw2DHUD()
	end
end

-- =============================================================================
-- SECTION: SBASE 覆盖与其他函数 (SBase Overrides & Misc)
-- =============================================================================
-- 以下函数很可能覆盖了某个基础武器框架（如 SBase）的默认行为。

---
-- @function SWEP:Think
-- @description 每帧调用，用于处理持续性逻辑。
--
function SWEP:Think()
	-- 如果当前在瞄准状态，但玩家已松开右键，则退出瞄准。
	if self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	-- 处理换弹结束逻辑。
	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end
		return
	-- 处理闲置动画逻辑。
	elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(self.IdleActivity)
	end
	self.offset = Lerp(RealFrameTime() * 10, self.offset, 0)
end

---
-- @function SWEP:GetIronsightsDeltaMultiplier
-- @description 计算一个从 0 到 1 的值，表示进入或退出瞄准状态的进度。
-- @return number 瞄准进度乘数 (0=完全不瞄准, 1=完全瞄准)。
--
function SWEP:GetIronsightsDeltaMultiplier()
	local bIron = self:GetIronsights()
	local fIronTime = self.fIronTime or 0

	if not bIron and fIronTime < CurTime() - 0.25 then
		return 0 -- 如果不在瞄准且过渡期已过，则为 0
	end

	local Mul = 1

	-- 根据进入/退出瞄准的时间计算过渡进度
	if fIronTime > CurTime() - 0.25 then
		Mul = math.Clamp((CurTime() - fIronTime) * 4, 0, 1)
		if not bIron then Mul = 1 - Mul end -- 退出瞄准时反转进度
	end

	return Mul
end
-- [[ 新增的动态运动效果参数 ]] --
SWEP.SwayAmount = 0.02  -- 左右移动时，武器倾斜的幅度
SWEP.BobAmount  = 0.006 -- 前后移动时，武器前后晃动的幅度
SWEP.MovementLerpSpeed = 6 -- 动态效果的平滑过渡速度
local ghostlerp = 0
---
-- @function SWEP:CalcViewModelView
-- @description (最终修正版) 增加了对 self.fIronTime 的支持，以修复原生瞄准镜HUD。
--
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	local owner = self:GetOwner()
	if not IsValid(owner) then return pos, ang end

	-- =========================================================================
	-- 1. 初始化和变量准备
	-- =========================================================================
	self.CurrentIronPos = self.CurrentIronPos or Vector(0, 0, 0)
	self.CurrentIronAng = self.CurrentIronAng or Angle(0, 0, 0)
	self.CurrentSwayAngle = self.CurrentSwayAngle or Angle(0, 0, 0)
	self.CurrentBobVector = self.CurrentBobVector or Vector(0, 0, 0)
	
	local wep_offset = self.offset or 0

	-- =========================================================================
	-- 2. 状态判断与计算“目标”和“动态效果”
	-- =========================================================================
	local bIron = self:GetIronsights() and not GAMEMODE.NoIronsights
	local target_pos
	local target_ang

	-- !! CRITICAL FIX: 重新加入 fIronTime 的逻辑 !!
	-- 追踪瞄准状态的变化，以便在正确的时间设置 fIronTime。
	if bIron ~= self.bLastIron then
		self.bLastIron = bIron
		if bIron then
			-- 如果刚刚开始瞄准，就记录下当前时间。
			self.fIronTime = CurTime()
		else
			-- 如果刚刚退出瞄准，就清空时间。
			self.fIronTime = nil
		end
	end
	
	if bIron then
		-- 状态一: 瞄准
		target_pos = self.IronSightsPos
		target_ang = self.IronSightsAng
		self.SwayScale = 0.75
		self.BobScale = 0.1
		self.Breath = math.sin(CurTime()) / (self.Breathmult * 80)
	else
		-- 状态二/三: 默认或检视
		target_pos = Vector(0, 0, 0)
		target_ang = Angle(0, 0, 0)
		self.SwayScale = 1
		self.BobScale = 1
		self.Breath = math.sin(CurTime()) / (self.Breathmult * 4)

		if (input.IsKeyDown(KEY_G) or (self.deploytime and self.deploytime > CurTime())) and not input.IsMouseDown(MOUSE_LEFT) then
			if self.DoInspect then self:DoInspect() end
		else
			if _G.keytime then keytime = 0 end
			if _G.key then key = 1 end
		end
	end
	
	-- =========================================================================
	-- 3. 平滑更新“瞄准”的过渡
	-- =========================================================================
	self.CurrentIronPos = LerpVector(RealFrameTime() * self.IronSpeed, self.CurrentIronPos, target_pos)
	if isvector(target_ang) then target_ang = Angle(target_ang.x, target_ang.y, target_ang.z) end
	self.CurrentIronAng = LerpAngle(RealFrameTime() * self.IronSpeed, self.CurrentIronAng, target_ang)
	
	-- =========================================================================
	-- 4. 计算并平滑更新“动态运动效果”
	-- =========================================================================
	local velocity = owner:GetVelocity()
	local eye_ang = owner:EyeAngles()
	
	local vel_forward = velocity:Dot(eye_ang:Forward())
	local vel_right = velocity:Dot(eye_ang:Right())
	
	vel_forward = math.Clamp(vel_forward, -350, 350)
	vel_right = math.Clamp(vel_right, -350, 350)

	local target_sway_roll = -vel_right * (self.SwayAmount or 0.03) * self.SwayScale
	local target_bob_forward = -vel_forward * (self.BobAmount or 0.003) * self.BobScale
	
	local target_sway = Angle(0, 0, target_sway_roll)
	local target_bob = Vector(0, target_bob_forward, 0)

	local lerp_speed = self.MovementLerpSpeed or 6
	self.CurrentSwayAngle = LerpAngle(RealFrameTime() * lerp_speed, self.CurrentSwayAngle, target_sway)
	self.CurrentBobVector = LerpVector(RealFrameTime() * lerp_speed, self.CurrentBobVector, target_bob)

	-- =========================================================================
	-- 5. 应用所有变换
	-- =========================================================================
	ang = Angle(ang.p, ang.y, ang.r)
	
	ang:RotateAroundAxis(ang:Right(), self.CurrentIronAng.x)
	ang:RotateAroundAxis(ang:Up(), self.CurrentIronAng.y)
	ang:RotateAroundAxis(ang:Forward(), self.CurrentIronAng.z)
	
	ang:RotateAroundAxis(ang:Forward(), self.CurrentSwayAngle.r)
	
	pos = pos + (self.CurrentIronPos.x * ang:Right())
	pos = pos + (self.CurrentIronPos.y * ang:Forward())
	pos = pos + (self.CurrentIronPos.z * ang:Up())

	pos = pos + (ang:Forward() * self.CurrentBobVector.y)

	pos = pos + ang:Up() * self.Breath
	pos = pos + ang:Forward() * wep_offset

	-- =========================================================================
	-- 6. 保留原有的其他视觉效果
	-- =========================================================================
	if owner:GetBarricadeGhosting() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 5)
	end
	if ghostlerp > 0 then
		pos = pos + 3.5 * ghostlerp * ang:Up()
		ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
	end
	
	if self.VMAng and self.VMPos then
		ang:RotateAroundAxis(ang:Right(), self.VMAng.x)
		ang:RotateAroundAxis(ang:Up(), self.VMAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.VMAng.z)
		
		pos = pos + (ang:Right() * self.VMPos.x)
		pos = pos + (ang:Forward() * self.VMPos.y)
		pos = pos + (ang:Up() * self.VMPos.z)
	end
	
	return pos, ang
end
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- 用于缓存从文件读取的瞄准设置，避免重复IO操作
local OverrideIronSights = {}

---
-- @function SWEP:CheckCustomIronSights
-- @description 检查并从 "garrysmod/data/ironsights/" 目录加载自定义的瞄准位置文件。
--              文件名为 "武器类名.txt"，内容为6个数字，分别代表 Pos 的 x,y,z 和 Ang 的 x,y,z。
--
function SWEP:CheckCustomIronSights()
	local class = self:GetClass()
	if OverrideIronSights[class] then
		-- 如果已缓存，直接使用缓存数据
		if type(OverrideIronSights[class]) == "table" then
			self.IronSightsPos = OverrideIronSights[class].Pos
			self.IronSightsAng = OverrideIronSights[class].Ang
		end
		return
	end

	local filename = "ironsights/" .. class .. ".txt"
	if file.Exists(filename, "MOD") then
		local content = file.Read(filename, "MOD")
		local tab = string.Explode(" ", content)
		
		local pos = Vector(tonumber(tab[1]) or 0, tonumber(tab[2]) or 0, tonumber(tab[3]) or 0)
		local ang = Angle(tonumber(tab[4]) or 0, tonumber(tab[5]) or 0, tonumber(tab[6]) or 0)

		-- 缓存读取到的数据
		OverrideIronSights[class] = {Pos = pos, Ang = ang}
		self.IronSightsPos = pos
		self.IronSightsAng = ang
	else
		-- 如果文件不存在，缓存一个标记，避免再次尝试读取
		OverrideIronSights[class] = true
	end
end

-- =============================================================================
-- SECTION: 动画库钩子 (Animation Library Hooks)
-- =============================================================================
-- 以下函数调用了 "animations.lua" 文件中定义的对应函数。

function SWEP:OnRemove()
	self:Anim_OnRemove()
end

function SWEP:ViewModelDrawn()
	self:Anim_ViewModelDrawn()
end

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	-- 在特定情况下（如玩家为隐形人或处于出生保护）不绘制世界模型。
	if owner:IsValid() and (owner.ShadowMan or owner.SpawnProtection) then return end

	self:Anim_DrawWorldModel()
end