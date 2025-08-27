SWEP.PrintName = ""..translate.Get("weapon_zs_graveshovel")
SWEP.Description = ""..translate.Get("weapon_zs_graveshovel_description")

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 130  * GAMEMODE.LabourTime
SWEP.MeleeRange = 78
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 220

SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)
SWEP.Primary.Delay = 1.2

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.65
SWEP.SwingHoldType = "melee"
--[[
-- 删除 DrawMeleeHud 函数，添加以下配置
SWEP.PrimaryIcon = Material("materials/horderally.png") -- 自定义主攻击图标

-- 获取当前的近战伤害
function SWEP:GetMeleeDamage()
    return self.MeleeDamage + (self.PermanentBonus or 0)
end

-- 击杀僵尸时调用，增加永久伤害
function SWEP:OnZombieKilled()
    self.PermanentBonus = (self.PermanentBonus or 0) + 3
end

-- 攻击命中后触发
function SWEP:OnMeleeHit(ent, hitpos, damage)
    if not IsValid(ent) then return end

    -- 判定击杀增加永久伤害
    if ent:IsPlayer() and ent:Team() == TEAM_UNDEAD and ent:Health() <= damage then
        self:OnZombieKilled()
    end

    -- 添加燃烧效果
    if ent:IsPlayer() or ent:IsNPC() then
        local bonus = self.PermanentBonus or 0
        local burnDuration = 5 + bonus

        ent:Ignite(burnDuration, 0)
        -- 记录最新燃烧时间（客户端 HUD 显示用）
        self.LastBurnTime = CurTime()
        self.LastBurnDuration = burnDuration
    end
end

-- HUD 显示
function SWEP:DrawCustomHUD(owner, scrW, scrH)
    local charge = self.GetShovelCharge and self:GetShovelCharge() or 0
    local bonus = self.PermanentBonus or 0
    local burnDuration = self.LastBurnDuration or 0
    local timeLeft = math.max(0, (self.LastBurnTime or 0) + burnDuration - CurTime())

    local screenscale = math.max(scrH / 1080, 0.851)
    local x = scrW - 215 * 0.75 - 32 * screenscale
    local y = scrH - 180

    draw.SimpleText("Charge: " .. charge, "DermaDefault", x, y, Color(255, 100, 0), TEXT_ALIGN_CENTER)
    draw.SimpleText("额外伤害 Bonus Damage: +" .. bonus, "DermaDefault", x, y + 20, Color(20, 170, 20), TEXT_ALIGN_CENTER)

    if timeLeft > 0 then
        draw.SimpleText("燃烧时间 Burning: " .. string.format("%.1f", timeLeft) .. "s", "DermaDefault", x, y + 40, Color(170, 20, 20), TEXT_ALIGN_CENTER)
    end
end
]]
SWEP.Tier = 3

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.12)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/shovel/shovel_hit-0"..math.random(4)..".ogg", 75, 80)
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

function SWEP:SetShovelCharge(charge)
	self:SetDTInt(9, charge)
end

function SWEP:GetShovelCharge()
	return self:GetDTInt(9)
end






---下面是用于备份，如果上面代码出了问题，则复制下面代码并替换上面的代码以用于临时的修复。By_良缘
--[[
SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 130  * GAMEMODE.LabourTime
SWEP.MeleeRange = 78
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 220

SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)
SWEP.Primary.Delay = 1.2

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.65
SWEP.SwingHoldType = "melee"
-- 删除 DrawMeleeHud 函数，添加以下配置
SWEP.PrimaryIcon = Material("materials/horderally.png") -- 自定义主攻击图标

-- 添加一个自定义绘制函数来显示充能
function SWEP:DrawCustomHUD(owner, scrW, scrH)
	local charge = self:GetShovelCharge()
	local screenscale = math.max(scrH / 1080, 0.851) * 1
	local x = scrW - 215 * 0.75 - 32 * screenscale
	local y = scrH - 180
	draw.SimpleText("Charge: ".. charge, font, x, y, Color(170,20,20), TEXT_ALIGN_CENTER)
end
SWEP.Tier = 4
SWEP.MaxStock = 3

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.12)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/shovel/shovel_hit-0"..math.random(4)..".ogg", 75, 80)
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

function SWEP:SetShovelCharge(charge)
	self:SetDTInt(9, charge)
end

function SWEP:GetShovelCharge()
	return self:GetDTInt(9)
end
--]]