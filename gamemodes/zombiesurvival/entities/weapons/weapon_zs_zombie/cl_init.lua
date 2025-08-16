INC_CLIENT()

SWEP.ViewModelFOV = 70
SWEP.DrawCrosshair = false

function SWEP:Reload()
end

function SWEP:DrawWorldModel()
end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:DrawHUD()
    if GetConVar("crosshair"):GetInt() ~= 1 then return end
    self:DrawCrosshairDot()
    
    -- 绘制僵尸专用HUD
    --self:DrawZombieHud()
    self:DrawZombieCooldowns()
end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
    self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- =============================================
-- 僵尸专用冷却显示系统
-- =============================================

-- 主攻击冷却
function SWEP:CooldownRingBinding()
    return self:GetNextPrimaryFire() - CurTime() 
end

function SWEP:CooldownRingMaximumBinding()
    return self.Primary.Delay or 1.2
end

-- 警报技能冷却 (右键)
function SWEP:CooldownRingBinding2()
    return self:GetNextSecondaryFire() - CurTime()
end

function SWEP:CooldownRingMaximumBinding2()
    return self.AlertDelay or 2.5
end

-- 检查冷却时间有效性
function SWEP:IsValidCooldown(current, max)
    return current > 0 and max > 0 and current ~= math.huge and max ~= math.huge
end

-- 绘制冷却圆环
function SWEP:DrawZombieCooldowns()
    local V = math.max(ScrH() / 1080, 0.851)
    
    -- 主攻击冷却
    local attackCd = self:CooldownRingBinding()
    local attackMax = self:CooldownRingMaximumBinding()
    
    -- 警报技能冷却
    local alertCd = self:CooldownRingBinding2()
    local alertMax = self:CooldownRingMaximumBinding2()
    
    local CooldownRingSize = 1 -- 可以通过ConVar控制
    local CooldownRingSpacing = 1
    
    -- 颜色定义
    local attackColor = Color(255, 80, 80, 180)  -- 红色 - 攻击
    local alertColor = Color(255, 200, 0, 180)   -- 黄色 - 警报
    local bgColor = Color(12, 12, 12, 50)
    
    local H = ScrW() * 0.5
    local I = ScrH() * 0.5
    
    -- 字体 (如果没定义则使用默认)
    local font = "ZSM_Coolvetica" or "DefaultFont"
    local fontblur = "ZSM_CoolveticaBlur" or font
    
    -- 绘制攻击冷却
    if self:IsValidCooldown(attackCd, attackMax) then
        -- 冷却时间文字
        draw.SimpleText(math.Round(attackCd, 1), fontblur, H +30 * V, I + 20, attackColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(math.Round(attackCd, 1), font, H + 30 * V, I + 20, attackColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- 冷却圆环
        local progress = attackCd / attackMax
        draw.HollowCircle(H, I, 12 * V, 4 * CooldownRingSize, 270, 270 + 360 * progress, attackColor)
        draw.HollowCircle(H, I, 12 * V, 4 * CooldownRingSize, 270, 270 + 360, bgColor)
    end
    --[[
    -- 绘制警报技能冷却
    if self:IsValidCooldown(alertCd, alertMax) then
        -- 冷却时间文字
        draw.SimpleText(math.Round(alertCd, 1), fontblur, H + 60 * V, I + 5, alertColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(math.Round(alertCd, 1), font, H + 60 * V, I + 5, alertColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- 冷却圆环
        local progress = alertCd / alertMax
        draw.HollowCircle(H, I, 25 * V, 3 * CooldownRingSize, 270, 270 + 360 * progress, alertColor)
        draw.HollowCircle(H, I, 25 * V, 3 * CooldownRingSize, 270, 270 + 360, bgColor)
    end
    ]]
end

-- =============================================
-- 僵尸专用技能HUD显示
-- =============================================
--[[
function SWEP:DrawZombieHud()
    local scrW = ScrW()
    local scrH = ScrH()
    local width = 60
    local height = 60
    local owner = self:GetOwner()
    
    -- 僵尸有2个技能：攻击和警报
    local icon_count = 2
    local total_width = (icon_count * width) + ((icon_count - 1) * 15) -- 图标间距15
    local x_start = scrW - total_width - 50 -- 右边距50
    
    local y = scrH - height - 80
    local glowAlpha = 50 + math.sin(CurTime() * 4) * 40
    
    local current_x = x_start
    
    -- ==========================================
    -- 1. 绘制主攻击 (爪击)
    -- ==========================================
    local attackCd = math.max(self:GetNextPrimaryFire() - CurTime(), 0)
    local attackMax = self.Primary.Delay or 1.2
    local attackRatio = attackCd / attackMax
    local attackCooldownHeight = height * attackRatio
    
    -- 背景
    surface.SetDrawColor(120, 20, 20, 180)
    surface.DrawRect(current_x, y, width, height)
    
    -- 冷却遮罩
    surface.SetDrawColor(60, 60, 60, 120)
    surface.DrawRect(current_x, y, width, attackCooldownHeight)
    
    -- 可用时的发光效果
    if attackRatio <= 0.1 then
        self:DrawThickOutline(current_x, y, width, height, 3, Color(255, 100, 100, glowAlpha))
    end
    
    -- 爪击图标 (可以替换为更合适的材质)
    local clawIcon = Material("icon16/error.png") -- 临时图标，建议替换
    surface.SetMaterial(clawIcon)
    surface.SetDrawColor(255, 120, 120, 255)
    surface.DrawTexturedRect(current_x + 5, y + 5, 50, 50)
    
    -- 按键提示
    draw.SimpleText("攻击", "Default", current_x + width/2, y + height + 8, Color(255, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.SimpleText("鼠标左键", "DefaultSmall", current_x + width/2, y + height + 22, Color(200, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    current_x = current_x + width + 15
    
    -- ==========================================
    -- 2. 绘制警报技能
    -- ==========================================
    local alertCd = math.max(self:GetNextSecondaryFire() - CurTime(), 0)
    local alertMax = self.AlertDelay or 2.5
    local alertRatio = alertCd / alertMax
    local alertCooldownHeight = height * alertRatio
    
    -- 背景
    surface.SetDrawColor(120, 100, 20, 180)
    surface.DrawRect(current_x, y, width, height)
    
    -- 冷却遮罩
    surface.SetDrawColor(60, 60, 60, 120)
    surface.DrawRect(current_x, y, width, alertCooldownHeight)
    
    -- 可用时的发光效果
    if alertRatio <= 0.1 then
        self:DrawThickOutline(current_x, y, width, height, 3, Color(255, 200, 100, glowAlpha))
    end
    
    -- 警报图标
    local alertIcon = Material("icon16/sound.png") -- 临时图标，建议替换
    surface.SetMaterial(alertIcon)
    surface.SetDrawColor(255, 220, 120, 255)
    surface.DrawTexturedRect(current_x + 5, y + 5, 50, 50)
    
    -- 按键提示
    draw.SimpleText("警报", "Default", current_x + width/2, y + height + 8, Color(255, 200, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.SimpleText("鼠标右键", "DefaultSmall", current_x + width/2, y + height + 22, Color(200, 160, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    -- ==========================================
    -- 3. 绘制僵尸状态信息
    -- ==========================================
    --self:DrawZombieStatus(scrW, scrH, owner)
end

-- 绘制僵尸状态信息
function SWEP:DrawZombieStatus(scrW, scrH, owner)
    local statusY = scrH - 180
    local statusX = scrW - 200
    --[[
    -- 呻吟状态指示
    if self:IsMoaning() then
        draw.SimpleText("呻吟中...", "DefaultBold", statusX, statusY, Color(255, 100, 100, 200 + math.sin(CurTime() * 8) * 55), TEXT_ALIGN_LEFT)
        statusY = statusY + 20
    end
    ]]
	--[[
    -- 攻击状态指示
    if self:IsSwinging() then
        local swingTime = self:GetSwingEndTime() - CurTime()
        draw.SimpleText("攻击中 " .. math.Round(swingTime, 1) .. "s", "Default", statusX, statusY, Color(255, 150, 150), TEXT_ALIGN_LEFT)
        statusY = statusY + 18
    end
	]]
    --[[
    -- 移动速度加成（如果有呻吟技能）
    if owner.m_Zombie_Moan and self:IsMoaning() then
        draw.SimpleText("速度加成: +60%", "Default", statusX, statusY, Color(100, 255, 100), TEXT_ALIGN_LEFT)
    end
	
end

-- 辅助函数：绘制厚边框
function SWEP:DrawThickOutline(x, y, w, h, thickness, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    -- 上
    surface.DrawRect(x - thickness, y - thickness, w + thickness * 2, thickness)
    -- 下
    surface.DrawRect(x - thickness, y + h, w + thickness * 2, thickness)
    -- 左
    surface.DrawRect(x - thickness, y, thickness, h)
    -- 右
    surface.DrawRect(x + w, y, thickness, h)
end
]]