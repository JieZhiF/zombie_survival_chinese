INC_CLIENT()

include("animations.lua")

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 60
 
SWEP.Slot = 0
SWEP.SlotPos = 0
local lerp = 0
local blocklerp = 0
local attacklerp = 0
local swinglerp = 0

function SWEP:TranslateFOV(fov)
	return GAMEMODE.FOVLerp * fov
end


function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

function SWEP:OnRemove()
	self:Anim_OnRemove()
end

function SWEP:ViewModelDrawn()
	self:Anim_ViewModelDrawn()
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
end

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if owner:IsValid() and (owner.ShadowMan or owner.SpawnProtection) then return end

	self:Anim_DrawWorldModel()
end

local ghostlerp = 0
function SWEP:GetViewModelPosition(pos, ang)
	local owner = self:GetOwner()
	if self:IsSwinging() then
		local rot = self.SwingRotation
		local offset = self.SwingOffset
		local armdelay = owner:GetMeleeSpeedMul()
		local swingtime = self.SwingTime * (owner.MeleeSwingDelayMul or 1) * armdelay

		ang = Angle(ang.pitch, ang.yaw, ang.roll) -- Copy

		local swingend = self:GetSwingEnd()
		local delta = swingtime - math.Clamp(swingend - CurTime(), 0, swingtime)
		local power = CosineInterpolation(0, 1, delta / swingtime)

		if power >= 0.9 then
			power = (1 - power) ^ 0.4 * 2
		end

		pos = pos + offset.x * power * ang:Right() + offset.y * power * ang:Forward() + offset.z * power * ang:Up()

		ang:RotateAroundAxis(ang:Right(), rot.pitch * power)
		ang:RotateAroundAxis(ang:Up(), rot.yaw * power)
		ang:RotateAroundAxis(ang:Forward(), rot.roll * power)
	end

	if owner:GetBarricadeGhosting() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 5)
	end

	if ghostlerp > 0 then
		pos = pos + 3.5 * ghostlerp * ang:Up()
		ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
	end
	
	if self:IsBlocking() or self.BlockAnim and self.BlockAnim > CurTime() and self.BlockPos and self.BlockAng then
		--if IsFirstTimePredicted() then
			lerp = math.Approach(lerp, (self:IsBlocking() and 1) or 0, RealFrameTime()*1*((lerp + 1) ^ 3))
		--end
		local rot = self.BlockAng
		local offset = self.BlockPos
		
		ang = Angle(ang.pitch, ang.yaw, ang.roll)
		
		local power = lerp
		
		ang:RotateAroundAxis(ang:Right(), rot.pitch * power)
		ang:RotateAroundAxis(ang:Up(), rot.yaw * power)
		ang:RotateAroundAxis(ang:Forward(), rot.roll * power)
		
		pos = pos + offset.x * power * ang:Right() + offset.y * power * ang:Forward() + offset.z * power * ang:Up()
	end


	-- i mostly use this to give the GMOD cs weapons (which are ported like ass), a cs:source feeling.
	if self.VMAng and self.VMPos then

			ang:RotateAroundAxis(ang:Right(), self.VMAng.x)

			ang:RotateAroundAxis(ang:Up(), self.VMAng.y)

			ang:RotateAroundAxis(ang:Forward(), self.VMAng.z)



			pos:Add(ang:Right() * self.VMPos.x)

			pos:Add(ang:Forward() * self.VMPos.y)

			pos:Add(ang:Up() * self.VMPos.z)

	end
	return pos, ang
end

// -- COOLDOWWNWNNN
function SWEP:CooldownRingBinding()
	return self:GetNextPrimaryFire()-CurTime() 
end

function SWEP:CooldownRingMaximumBinding()
	return self.Primary.Delay
end

-- Block percent
function SWEP:CooldownRingBinding2()
	return self.NextBlock - CurTime()
end

function SWEP:CooldownRingMaximumBinding2()
	return self.Primary.Delay + self.MeleeDelay + self.SwingTime
end
	

function SWEP:DrawCooldowns()
	local V=math.max(ScrH() / 1080, 0.851) * 1
	--Primary Attack
	local ab=self:CooldownRingBinding()
	local ac=self:CooldownRingMaximumBinding()
	--Block Cooldown
	local ab2=self:CooldownRingBinding2()
	local ac2=self:CooldownRingMaximumBinding2()

	local CooldownRingSize=math.Clamp(tonumber(f) or 1,0.5,1.5)
	local CooldownRingSpacing=math.Clamp(tonumber(f)or 1,0,1)
	local a6=Color(220,0,0,100)
	local a4=Color(0,220,0,100)
	local H=ScrW()*0.5
	local I=ScrH()*0.5
	if ab>0 and ac>0 and ab~=math.huge and ac~=math.huge then
	-- Primary Attack
	draw.SimpleText(math.Round(ab,1), font ,H-(2)*30*V,I+(5),a6,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText(math.Round(ab,1), fontblur ,H-(2)*30*V,I+(5),a6,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	if not self:IsBlocking() then
		draw.HollowCircle(H,I,(1+CooldownRingSpacing)*9*V,3*CooldownRingSize,270,270+360*ab/ac,a6)
		draw.HollowCircle(H,I,(1+CooldownRingSpacing)*9*V,3*CooldownRingSize,270,270+360,Color(12,12,12,30)) 
	end
	end
	if ab2>0 and ac2>0 and ab2~=math.huge and ac2~=math.huge then
		-- Block Cooldown
		draw.SimpleText(math.Round(ab2,1),font,H+(55)*V,I+(5),a4,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText(math.Round(ab2,1),fontblur,H+(55)*V,I+(5),a4,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		if not self:IsBlocking() then
			draw.HollowCircle(H,I,(1+CooldownRingSpacing)*2*V,3*CooldownRingSize,270,270+360*ab2/ac2,a4)
			draw.HollowCircle(H,I,(1+CooldownRingSpacing)*2*V,3*CooldownRingSize,270,270+360,Color(12,12,12,30))
		end

	end

end

-- 添加辅助方法检查冷却时间有效性
function SWEP:IsValidCooldown(current, max)
    return current > 0 and max > 0 and current ~= math.huge and max ~= math.huge
end
-- weapon_zs_basemelee/cl_init.lua (最终修复版)
function SWEP:DrawMeleeHud()
	local scrW = ScrW()
	local scrH = ScrH()
	local width = 50
	local height = 50
	local owner = self:GetOwner()

	-- 根据技能数量动态计算UI起始位置，以保证整体居中
	local icon_count = 2
	if self.HasThirdAbility then icon_count = icon_count + 1 end
	if self.HasFourthAbility then icon_count = icon_count + 1 end
	local total_width = (icon_count * width) + ((icon_count - 1) * 10) -- 图标间距为10
	local x_start = scrW - total_width - 200 -- 整体右边距为32

	local y = scrH - height - 72
	local glowAlpha = 50 + math.sin(CurTime() * 5) * 50

	local current_x = x_start

	-- =======================================================
	-- 1. 绘制主要攻击 (通用)
	-- =======================================================
	local ratiopri = math.max(self:GetNextPrimaryFire() - CurTime(), 0) / (self.Primary.Delay + (self.MeleeDelay or 0)) * 1.6
	local cooldownHeightPri = height * ratiopri
	local iconAttack = self.PrimaryIcon or Material("materials/stab.png")

	surface.SetDrawColor(90, 0, 0, 150)
	surface.DrawRect(current_x, y, width, height)
	surface.SetDrawColor(255, 255, 255, 90)
	surface.DrawRect(current_x, y + (height - cooldownHeightPri), width, cooldownHeightPri)
	if ratiopri == 0 then
		DrawThickOutline(current_x, y, width, height, 3, Color(255, 100, 100, glowAlpha))
	end
	surface.SetMaterial(iconAttack)
	surface.SetDrawColor(255, 100, 100, 255)
	surface.DrawTexturedRect(current_x + (width - 50) / 2, y + (height - 50) / 2, 50, 50)
	local lmb_text = self.PrimaryTextKey or "meleehud_lmb"
	draw.SimpleText(translate.Get(lmb_text), font, current_x + width / 2, y + height + 10, Color(255, 170, 170), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	current_x = current_x + width + 50

	-- =======================================================
	-- 2. 绘制格挡 (通用)
	-- =======================================================
	local ratioblock = math.max(self.NextBlock - CurTime(), 0) / (self.Primary.Delay + (self.MeleeDelay or 0) + (self.SwingTime or 0))
	local cooldownHeightBlock = height * ratioblock
	local iconBlock = self.BlockIcon or Material("materials/zombiesurvival/defense.png")

	surface.SetDrawColor(0, 90, 0, 150)
	surface.DrawRect(current_x, y, width, height)
	surface.SetDrawColor(255, 255, 255, 90)
	surface.DrawRect(current_x, y + (height - cooldownHeightBlock), width, cooldownHeightBlock)
	if ratioblock == 0 then
		DrawThickOutline(current_x, y, width, height, 3, Color(100, 255, 100, glowAlpha))
	end
	surface.SetMaterial(iconBlock)
	surface.SetDrawColor(100, 255, 100, 255)
	surface.DrawTexturedRect(current_x + (width - 50) / 2, y + (height - 50) / 2, 50, 50)
	local reload_text = self.BlockTextKey or "meleehud_Reload"
	draw.SimpleText(translate.Get(reload_text), font, current_x + width / 2, y + height + 10, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	current_x = current_x + width + 50

	-- =======================================================
	-- 3. 绘制第三个技能 (如果武器定义了)
	-- =======================================================
	if self.HasThirdAbility and self.ThirdAbilityConfig then
		local config = self.ThirdAbilityConfig
		local ratio, cooldownHeight = config.GetRatio(self, owner, width, height)
		
		surface.SetDrawColor(config.BGColor.r, config.BGColor.g, config.BGColor.b, config.BGColor.a or 150)
		surface.DrawRect(current_x, y, width, height)
		
		local cdColor = config.CooldownColor or Color(255, 255, 255, 90)
		surface.SetDrawColor(cdColor.r, cdColor.g, cdColor.b, cdColor.a or 90)
		surface.DrawRect(current_x, y + (height - cooldownHeight), width, cooldownHeight)
		
		if ratio == 0 then
			-- !! 核心修复：从配置中读取基础颜色，然后应用动态的 glowAlpha
			local baseGlowColor = config.GlowColor
			DrawThickOutline(current_x, y, width, height, 3, Color(baseGlowColor.r, baseGlowColor.g, baseGlowColor.b, glowAlpha))
		end
		
		surface.SetMaterial(config.Icon)
		surface.SetDrawColor(config.IconColor.r, config.IconColor.g, config.IconColor.b, config.IconColor.a or 255)
		local iconSize = config.IconSize or 50
		surface.DrawTexturedRect(current_x + (width - iconSize) / 2, y + (height - iconSize) / 2, iconSize, iconSize)
		
		if config.TextLines then
			for _, line in ipairs(config.TextLines) do
				draw.SimpleText(line.text, font, current_x + width/2, y + height + line.y_off, line.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end
		current_x = current_x + width + 50
	end

	-- (此处可以为 self.HasFourthAbility 添加类似逻辑)
	
	-- =======================================================
	-- 5. 绘制自定义HUD元素 (例如Combo, Charge)
	-- =======================================================
	if self.DrawCustomHUD then
		self:DrawCustomHUD(owner, scrW, scrH)
	end
end
function SWEP:DrawCrosshairDot()
	if GetConVar("crosshair"):GetInt() == 0 then return end
	if not self:IsBlocking() or GetConVar("zsw_enable_rts_hud"):GetInt() == 0 then
		local x = ScrW() * 0.5
		local y = ScrH() * 0.5
		surface.SetDrawColor(Color(255, 110, 0))
		surface.DrawRect(x - 2, y - 2, 4, 4)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawOutlinedRect(x - 2, y - 2, 4, 4)
	end
end

function SWEP:DrawCrosshairClassic()
	if GetConVar("crosshair"):GetInt() == 0 then return end

	if not self:IsBlocking() or GetConVar("zsw_enable_rts_hud"):GetInt() == 0 then

		local SCREEN_W = 1920; --For the screen resolution scale. This means that it can be fit exactly on the screen without any issues.
		local SCREEN_H = 1080;
		local X_MULTIPLIER = ScrW( )  / 60 ;
		local Y_MULTIPLIER = ScrH( ) / 80 ;



		local cW, cH = ScrW() * 0.5, ScrH() * 0.5
		
		surface.SetDrawColor( Color ( 188,183,153,30 ) )
		surface.DrawLine(cW - X_MULTIPLIER, cH - 2, cW + X_MULTIPLIER, cH - 2)
		
		surface.SetDrawColor( Color ( 188,183,153,160 ) )
		surface.DrawLine(cW - X_MULTIPLIER, cH - 1, cW + X_MULTIPLIER, cH - 1)
		
		surface.SetDrawColor( Color ( 188,183,153,160 ) )
		surface.DrawLine(cW - X_MULTIPLIER, cH - 0, cW + X_MULTIPLIER, cH - 0)
		
		surface.SetDrawColor( Color ( 188,183,153,30 ) )
		surface.DrawLine(cW - X_MULTIPLIER, cH + 1, cW + X_MULTIPLIER, cH + 1)

		
		surface.SetDrawColor( Color ( 188,183,153,50 ) )
		surface.DrawLine(cW - 1, cH - Y_MULTIPLIER, cW - 1, cH + Y_MULTIPLIER)
		
		surface.SetDrawColor( Color ( 188,183,153,130 ) )
		surface.DrawLine(cW - 0, cH - Y_MULTIPLIER, cW - 0, cH + Y_MULTIPLIER)
		
		surface.SetDrawColor( Color ( 188,183,153,50 ) )
		surface.DrawLine(cW + 1, cH - Y_MULTIPLIER, cW + 1, cH + Y_MULTIPLIER)
		
	end
end

function SWEP:DrawBlockHUD()
    local x = ScrW() * 0.5
	local y = ScrH() * 0.5
	local size = 50
	local hsize = size/2
	local matGlow = Material("sprites/glow04_noz")
    local texDownEdge = surface.GetTextureID("vgui/gradient-r") --vgui/hud/healthbar_ticks_withglow_white
    local colHealth = Color(0, 0, 0, defalpha)
    local defalpha = 230

	local shieldMat = Material( "icon16/shield.png", "smooth" )

	if self:IsBlocking() and GetConVar("zsw_enable_rts_hud"):GetInt() == 1 then

		draw.SimpleText("p","csfont",x+10,y+15,Color(0,255,0,defalpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	end

	if self.Owner:KeyDown(IN_RELOAD) then
		-- When blocking, set defalpha to max visibility
		defalpha = 255
	else
		-- Gradually reduce defalpha based on current block defense
		if defalpha > 0 then
			-- Reduce defalpha by a factor depending on block defense
			defalpha = defalpha - math.max(50, self.DefendingDamageBlocked * 50)
		end
	end

	if GetBlockDefense() < GetBlockDefenseDefault() then
		draw.SimpleText(math.Round(GetBlockDefense()*30,0),font,x,y+150,Color(0,255,0,defalpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText(math.Round(GetBlockDefense()*30,0),fontblur,x,y+150,Color(0,255,0,defalpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("DEF",font,x-90,y+182,Color(0,255,0,defalpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("DEF",fontblur,x-90,y+182,Color(0,255,0,defalpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)


		local blockdef = math.Clamp(GetBlockDefense()*30,0,GetBlockDefenseDefault()*30)
		local blockdefdefault = GetBlockDefenseDefault()*30
		surface.SetDrawColor(0, 0, 0, defalpha)
		surface.DrawRect(x - 60, y + 170, blockdefdefault, hsize-6)

		surface.SetDrawColor(255 * 0.6, colHealth.g * 0.6, colHealth.b, defalpha)
		surface.SetTexture(texDownEdge)
		surface.DrawTexturedRect(x - 60, y + 170, blockdefdefault, hsize-6)
		surface.SetDrawColor(colHealth.r * 0.5, colHealth.g * 0.5, colHealth.b, defalpha)
		surface.DrawRect(x - 60, y + 170, blockdefdefault, hsize-6)

		surface.SetTexture(texDownEdge)
		surface.SetDrawColor(0, 255, 0, defalpha)
		surface.DrawTexturedRect(x - 60, y + 170, blockdef, hsize-6)

		surface.SetMaterial(matGlow)
		surface.SetDrawColor(255, 255, 255, defalpha)
		surface.DrawTexturedRect(x - 64 + blockdef , y + 160, 6, 40)

		surface.SetTexture(texDownEdge)
		surface.SetDrawColor(255, 255, 255, defalpha)
		surface.DrawTexturedRect(x - 18.1 , y + 167, 5, hsize)

	end

end

function SWEP:DrawFonts()
	local fontchoice = GetConVar("zsw_font_choice"):GetInt()
	-- Define the fonts based on the CVAR choice
	if fontchoice == 1 then                 -- gmod default
			font = "ZSM_Coolvetica"            
			fontblur = "ZSM_CoolveticaBlur"
	elseif fontchoice == 2 then             -- ZS
			font = "RemingtonNoiseless"
			fontblur = "RemingtonNoiselessBlur"
	elseif fontchoice == 3 then             -- ZS
			font = "Typenoksidi"
			fontblur = "TypenoksidiBlur"
	elseif fontchoice == 4 then             -- ZS
			font = "GhoulishFrightAOE"          
			fontblur = "GhoulishFrightAOEBlur"
	else                                    -- If none of these exist, use a gmod default
			font = "ZSM_Coolvetica"
			fontblur = "ZSM_CoolveticaBlur"
	end

end

function SWEP:DrawHUD()

    local crosshairMode = GetConVar("zsw_crosshair_mode"):GetInt()
    local enableCooldown = GetConVar("zsw_enable_cooldown"):GetInt() == 1
    local enableHUD = GetConVar("zsw_enable_hud"):GetInt() == 1
    local enableRTSHud = GetConVar("zsw_enable_rts_hud"):GetInt() == 1

    self:DrawFonts()

	-- Only draw the HUD if it's enabled
    if enableHUD then
        if enableCooldown then
            self:DrawCooldowns()
        end
        
        --if self:IsBlocking() then
            self:DrawBlockHUD()
        --end
        
        if enableRTSHud then -- Check for the RTS HUD CVAR
            self:DrawMeleeHud()
        end

        if crosshairMode == 1 then
            self:DrawCrosshairDot()
        elseif crosshairMode == 0 then
            self:DrawCrosshairClassic()
        end
    end
end

