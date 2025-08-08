
SWEP.PrintName = ""..translate.Get("weapon_zs_graveshovel_a")


SWEP.Base = "weapon_zs_graveshovel"
SWEP.ZombieOnly = true

SWEP.MeleeDamage = 40
SWEP.MeleeKnockBack = 0

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
    draw.SimpleText("Bonus Damage: +" .. bonus, "DermaDefault", x, y + 20, Color(20, 170, 20), TEXT_ALIGN_CENTER)

    if timeLeft > 0 then
        draw.SimpleText("Burning: " .. string.format("%.1f", timeLeft) .. "s", "DermaDefault", x, y + 40, Color(170, 20, 20), TEXT_ALIGN_CENTER)
    end
end