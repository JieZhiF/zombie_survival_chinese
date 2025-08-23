INC_CLIENT()

include("animations.lua")

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = true
SWEP.BobScale = 1
SWEP.SwayScale = 1
SWEP.Slot = 0

SWEP.offset = 0
SWEP.IronSightAng = Angle(0,0,0)
SWEP.IronSightPos = Vector(0,0,0)
SWEP.IronPos = Vector(0,0,0) -- dont edit this
SWEP.IronAng = Angle(0,0,0) -- dont edit this
SWEP.VMPos = Vector(0,0, 0)
SWEP.VMAng = Angle(0, 0, 0)
SWEP.InspectSpeed = 1
SWEP.IronSpeed = 3
SWEP.InspectOnDeploy = false
SWEP.DeployInspectTime = 5
SWEP.Inspect = {
	{pos = Vector(0,0,0), ang = Angle(0,0,0), time = -1}, //default inspect position is the default position
}
SWEP.BoneInspect = {
	{
		{pos = Vector(0,0,0), ang = Angle(0,0,0),bone = "default"}, //allows you to manipulate the C model bones
	}
}
SWEP.Breath = 0
SWEP.Breathmult = 10
SWEP.IronEnable = true 
SWEP.deploytime = 0


SWEP.IronsightsMultiplier = 0.6

SWEP.HUD3DScale = 0.01
SWEP.HUD3DBone = "base"
SWEP.HUD3DAng = Angle(180, 0, 0)

local key = 1
local keytime = 0
for k ,v in pairs(SWEP.BoneInspect) do //add extra variables to all bones so that we dont have to modify the original bone positions
	for f, b in pairs(v) do
		b.modv = Vector(0,0,0)
		b.moda = Angle(0,0,0)
	end
end

function SWEP:Deploy()
	if self.InspectOnDeploy == true then
		self.deploytime = CurTime()+self.DeployInspectTime
	end
	self:CreateModels(self.VElements)
	return true
end

function SWEP:DoAnims() //call this function from the child sweps think hook to enable iron sights, inspecting, and 'breathing' viewmodel shifting
	
	//check to see if the models are valid or nil
	local check = true
	if self.VElements~=nil then
		for k, v in pairs(self.VElements) do
			if check == true then
				if v.modelEnt==nil then
					self:CreateModels(self.VElements)
					check = false
				end
			end
		end
	end
	check = true
	if self.WElements~=nil then
		for k, v in pairs(self.WElements) do
			if check == true then
				if v.modelEnt==nil then
					self:CreateModels(self.WElements)
					check = false
				end
			end
		end
	end
	
	if self.Owner:KeyDown(IN_ATTACK2) and self.IronEnable then //do ironsighting first to allow it to override inspecting
		self.IronPos.x = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.x,self.IronSightPos.x)
		self.IronPos.y = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.y,self.IronSightPos.y)
		self.IronPos.z = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.z,self.IronSightPos.z)
		self.IronAng = LerpAngle(RealFrameTime()*self.IronSpeed,self.IronAng,self.IronSightAng)
		self.Breath = math.sin(CurTime())/(self.Breathmult*80)
		self.SwayScale = 0.0 //decreases swep viewmodel sway while scoping
     	self.BobScale = 0.0 //decreases swep viewemodel bob while scoping
	elseif (input.IsKeyDown(KEY_G) or self.deploytime > CurTime()) and not input.IsMouseDown(MOUSE_LEFT) then //does inspecting while the G key is pressed down. this key is used because by default garrysmod does not bind G to any function.
		self.Breath = math.sin(CurTime())/(self.Breathmult*4) //simple sine function
		self:DoInspect() //calls inspecting
	else //reset to default position when doing nothing
		self.IronPos.x = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.x,0)
		self.IronPos.y = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.y,0)
		self.IronPos.z = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.z,0)
		self.IronAng = LerpAngle(RealFrameTime()*self.IronSpeed,self.IronAng,Angle(0,0,0))
		self.Breath = math.sin(CurTime())/(self.Breathmult*4)
		self.SwayScale = 1
     	self.BobScale = 1
		keytime = 0
		key = 1
	end
	local pos = self.Owner:GetViewModel(0):GetPos()
	local ang = self.Owner:GetViewModel(0):GetAngles()
	self:GetViewModelPosition(pos,ang)
end
--[[
function SWEP:GetViewModelPosition(Pos,Ang)
	local tmp = Ang
	Ang:RotateAroundAxis(EyeAngles():Forward(),self.IronAng.p) //rotate the shit
	Ang:RotateAroundAxis(EyeAngles():Up(),self.IronAng.y)
	Ang:RotateAroundAxis(EyeAngles():Right(),self.IronAng.r)
	return Pos+(tmp:Forward()*(self.offset+self.IronPos.x))+(tmp:Right()*self.IronPos.y)+(tmp:Up()*(self.IronPos.z+self.Breath)),Ang+Angle((self.offset+10)/3,0,0)
end
]]
function SWEP:DoInspect()
	local info = self.Inspect[key]
	local Bones = self.BoneInspect[key]
	if keytime == 0 then
		keytime = CurTime()+self.Inspect[key].time
	end
	if CurTime() > keytime and info.time > 0 then
		key = key + 1
		keytime = CurTime()+self.Inspect[key].time
	end
	self.keyframe=key
	self.IronPos = self:LerpCurveVec(1,self.IronPos,info.pos)
	self.IronAng = self:LerpCurveAng(1,self.IronAng,info.ang)
end

function SWEP:LerpCurveVec(a,b,c)
	return LerpVector( self:inv_lerp( 1, -1, math.cos( ((CurTime()-(keytime-self.Inspect[key].time))/(self.Inspect[key].time)) / self.InspectSpeed)), b, c)
end
function SWEP:LerpCurveAng(a,b,c)
	return LerpAngle( self:inv_lerp( 1, -1, math.cos( ((CurTime()-(keytime-self.Inspect[key].time))/(self.Inspect[key].time)) / self.InspectSpeed)), b, c)
end
function SWEP:inv_lerp(a,b,c)
	return (c-a)/(b-a)
end
function SWEP:TranslateFOV(fov)//调节FOV
	return (GAMEMODE.FOVLerp + (self.IsScoped and not GAMEMODE.DisableScopes and 0 or (1 - GAMEMODE.FOVLerp) * (1 - GAMEMODE.IronsightZoomScale))) * fov
end

function SWEP:AdjustMouseSensitivity()//调节鼠标灵敏度
	if self:GetIronsights() then return GAMEMODE.FOVLerp + (self.IsScoped and not GAMEMODE.DisableScopes and 0 or (1 - GAMEMODE.FOVLerp) * (1 - GAMEMODE.IronsightZoomScale)) end
end

function SWEP:PreDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(0)
	end
end

function SWEP:PostDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(1)
	end

	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end
end

function SWEP:GetHUD3DPos(vm)
	local bone = vm:LookupBone(self.HUD3DBone)
	if not bone then return end

	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	if self.ViewModelFlip then
		ang.r = -ang.r
	end

	local offset = self.HUD3DPos
	local aoffset = self.HUD3DAng

	pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z

	if aoffset.yaw ~= 0 then ang:RotateAroundAxis(ang:Up(), aoffset.yaw) end
	if aoffset.pitch ~= 0 then ang:RotateAroundAxis(ang:Right(), aoffset.pitch) end
	if aoffset.roll ~= 0 then ang:RotateAroundAxis(ang:Forward(), aoffset.roll) end

	return pos, ang
end

local colBG = Color(16, 16, 16, 90)
local colRed = Color(220, 0, 0, 230)
local colYellow = Color(220, 220, 0, 230)
local colWhite = Color(220, 220, 220, 230)
local colAmmo = Color(255, 255, 255, 230)
local function GetAmmoColor(clip, maxclip)
	if clip == 0 then
		colAmmo.r = 255 colAmmo.g = 0 colAmmo.b = 0
	else
		local sat = clip / maxclip
		colAmmo.r = 255
		colAmmo.g = sat ^ 0.3 * 255
		colAmmo.b = sat * 255
	end
end

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


function SWEP:Draw3DHUD(vm, pos, ang)
	local wid, hei = 180, 200
	local x, y = wid * -0.6, hei * -0.5
	local clip = self:Clip1()
    local owner = self:GetOwner()
    local ammocount = owner:GetAmmoCount(self:GetPrimaryAmmoType())
	local maxclip = self.Primary.ClipSize

	local dclip, dbackammo, dmaxclip = self:GetDisplayAmmo(clip, ammocount, maxclip)

	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		draw.RoundedBoxEx(32, x, y, wid, hei, colBG, true, false, true, false)

		local displayspare = dmaxclip > 0 and self.Primary.DefaultClip ~= 99999
		if displayspare then
			draw.SimpleTextBlurry(dbackammo, dbackammo >= 1000 and "ZS3D2DFontSmall" or "ZS3D2DFont", x + wid * 0.5, y + hei * 0.75, dbackammo == 0 and colRed or dbackammo <= dmaxclip and colYellow or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		GetAmmoColor(dclip, dmaxclip)
		draw.SimpleTextBlurry(dclip, dclip >= 100 and "ZS3D2DFont" or "ZS3D2DFontBig", x + wid * 0.5, y + hei * (displayspare and 0.3 or 0.5), colAmmo, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end


function SWEP:Draw2DHUD()
    local screenscale = BetterScreenScale()
    local padding = 8 * screenscale
    local elementHeight = 64 * screenscale
    local sw,sh = ScrW() , ScrH()
    -- 基础位置计算
	local panelx = 300 * screenscale
    local x = sw - panelx
    local y = sh - elementHeight - padding * 4
    
    -- 弹药显示参数
    local clip = self:Clip1()
    local owner = self:GetOwner()
    local ammocount = owner:GetAmmoCount(self:GetPrimaryAmmoType())
    local maxclip = self:GetPrimaryClipSize()
	local dclip, dbackammo, dmaxclip = self:GetDisplayAmmo(clip, ammocount, maxclip)

    
    -- 武器名称
    surface.SetFont("ZSA_HUD_Name")
    local wname = self:GetPrintName()
    local nameW, nameH = surface.GetTextSize(wname)
    
    -- 主弹药显示
    surface.SetFont("ZSA_HUD_Clip")
    local clipText = tostring(dclip)
    local clipW = surface.GetTextSize(clipText)
    
    -- 备用弹药显示
    surface.SetFont("ZSA_HUD_Ammo")
    local ammoText = " / " .. tostring(dbackammo)
    local ammoW = surface.GetTextSize(ammoText)
    
    -- 整体宽度计算
    local totalWidth = math.max(nameW, clipW + ammoW) + 96 * screenscale
    
    -- 背景面板
    surface.SetDrawColor(30, 30, 30, 220)
    surface.DrawRect(x, y, totalWidth, elementHeight)
    
    -- 绘制武器名称
    surface.SetTextColor(255, 255, 255)
    surface.SetFont("ZSA_HUD_Name")
    surface.SetTextPos(x + padding, y + padding)
    surface.DrawText(wname)
    
    -- 弹药数字组合
    local numbersY = y + elementHeight - 32 * screenscale - padding
    surface.SetFont("ZSA_HUD_Clip")
    surface.SetTextPos(x + padding, numbersY)
    surface.DrawText(clipText)
    
    surface.SetFont("ZSA_HUD_Ammo")
    surface.SetTextPos(x + padding + clipW, numbersY + (32 - 20) * screenscale / 2)
    surface.DrawText(ammoText)
    
    -- 进度条参数
    local barHeight = 4 * screenscale
    local barY = y + elementHeight - barHeight - padding
    local progress = math.Clamp(dclip / dmaxclip,0,1)
    
    -- 进度条背景
    surface.SetDrawColor(50, 50, 50, 220)
    surface.DrawRect(x + padding, barY, totalWidth - padding * 2, barHeight)
    
    -- 进度条前景
    surface.SetDrawColor(204, 204, 204)
    surface.DrawRect(x + padding, barY, (totalWidth - padding * 2) * progress, barHeight)
    
    -- Killicon绘制（右侧对齐）
    local iconSize = 48 * screenscale
    local iconX = x + totalWidth - iconSize - padding
    local iconY = y + (elementHeight - iconSize) / 2
    
    local killiconData = killicon.Get(self:GetClass())
    if killiconData then
        if killicon.GetFont(self:GetClass()) then
            surface.SetFont(killiconData[1])
            surface.SetTextColor(killiconData[3] or color_white)
            local tw, th = surface.GetTextSize(killiconData[2])
            surface.SetTextPos(iconX + (iconSize - tw)/2, iconY + (iconSize - th)/2)
            surface.DrawText(killiconData[2])
        else
            surface.SetMaterial(Material(killiconData[1]))
            surface.SetDrawColor(killiconData[2] or color_white)
            surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
        end
    end
end


function SWEP:Think()
	if self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end

		return
	elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(self.IdleActivity)
	end
end

function SWEP:GetIronsightsDeltaMultiplier()
	local bIron = self:GetIronsights()
	local fIronTime = self.fIronTime or 0

	if not bIron and fIronTime < CurTime() - 0.25 then
		return 0
	end

	local Mul = 1

	if fIronTime > CurTime() - 0.25 then
		Mul = math.Clamp((CurTime() - fIronTime) * 4, 0, 1)
		if not bIron then Mul = 1 - Mul end
	end

	return Mul
end

local ghostlerp = 0
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang) //这个覆盖了sbase的机瞄
	local bIron = self:GetIronsights() and not GAMEMODE.NoIronsights

	if bIron ~= self.bLastIron then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if bIron then
			self.SwayScale = 0.3
			self.BobScale = 0.1
		else
			self.SwayScale = 2.0
			self.BobScale = 1.5
		end
	end

	local Mul = math.Clamp((CurTime() - (self.fIronTime or 0)) * 4, 0, 1)
	if not bIron then Mul = 1 - Mul end

	if Mul > 0 then
		local Offset = self.IronSightsPos
		if self.IronSightsAng then
			ang = Angle(ang.p, ang.y, ang.r)
			ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
			ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * Mul)
			ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
		end

		pos = pos + Offset.x * Mul * ang:Right() + Offset.y * Mul * ang:Forward() + Offset.z * Mul * ang:Up()
	end

	if self:GetOwner():GetBarricadeGhosting() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 5)
	end

	if ghostlerp > 0 then
		pos = pos + 3.5 * ghostlerp * ang:Up()
		ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
	end

	return pos, ang
end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

function SWEP:DrawHUD()
	self:DrawWeaponCrosshair()

	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:Draw2DHUD()
	end
end

local OverrideIronSights = {}
function SWEP:CheckCustomIronSights()
	local class = self:GetClass()
	if OverrideIronSights[class] then
		if type(OverrideIronSights[class]) == "table" then
			self.IronSightsPos = OverrideIronSights[class].Pos
			self.IronSightsAng = OverrideIronSights[class].Ang
		end

		return
	end

	local filename = "ironsights/"..class..".txt"
	if file.Exists(filename, "MOD") then
		local pos = Vector(0, 0, 0)
		local ang = Vector(0, 0, 0)

		local tab = string.Explode(" ", file.Read(filename, "MOD"))
		pos.x = tonumber(tab[1]) or 0
		pos.y = tonumber(tab[2]) or 0
		pos.z = tonumber(tab[3]) or 0
		ang.x = tonumber(tab[4]) or 0
		ang.y = tonumber(tab[5]) or 0
		ang.z = tonumber(tab[6]) or 0

		OverrideIronSights[class] = {Pos = pos, Ang = ang}

		self.IronSightsPos = pos
		self.IronSightsAng = ang
	else
		OverrideIronSights[class] = true
	end
end

function SWEP:OnRemove()
	self:Anim_OnRemove()
end

function SWEP:ViewModelDrawn()
	self:Anim_ViewModelDrawn()
end

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if owner:IsValid() and (owner.ShadowMan or owner.SpawnProtection) then return end

	self:Anim_DrawWorldModel()
end
