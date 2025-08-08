AddCSLuaFile()

SWEP.PrintName = "'恶魔剑客' 斩剑式"
SWEP.Description = "手持时，15%闪避。你攻击的僵尸血量小于等于20%时，立即斩杀"

if CLIENT then
    SWEP.ViewModelFOV = 70
    SWEP.ViewModelFlip = false

    net.Receive("DemonBlade_Slay", function()
        chat.AddText(Color(255, 100, 100), "你成功斩杀了目标！")
    end)

    net.Receive("DemonBlade_Evade", function()
        chat.AddText(Color(100, 255, 100), "你闪避了一次攻击！")
    end)
end

if SERVER then
    util.AddNetworkString("DemonBlade_Slay")
    util.AddNetworkString("DemonBlade_Evade")
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/v_katana.mdl"
SWEP.WorldModel = "models/weapons/w_katana.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 135
SWEP.MeleeRange = 85
SWEP.MeleeSize = 2.75
SWEP.MeleeKnockBack = 20

SWEP.Primary.Delay = 0.8

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.SwingTime = 0.7
SWEP.SwingRotation = Angle(0, -20, -40)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.SwingHoldType = "melee"

SWEP.Tier = 4
SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.13)

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
    if hitent:IsValid()
        and hitent:IsPlayer()
        and hitent:Alive()
        and hitent:Team() == TEAM_UNDEAD
        and hitent:Health() <= hitent:GetMaxHealthEx() * 0.2
        and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then

        if SERVER then
            hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, self:GetOwner(), self, tr.HitPos)
            hitent:EmitSound("npc/roller/blade_out.wav", 80, 75)

            local attacker = self:GetOwner()
            if attacker:IsPlayer() then
                net.Start("DemonBlade_Slay")
                net.Send(attacker)
            end
        end
    end
end

if SERVER then
    hook.Remove("EntityTakeDamage", "DemonBlade_Evasion") -- 清理旧 hook，防止重复执行

    hook.Add("EntityTakeDamage", "DemonBlade_Evasion", function(target, dmginfo)
        if not target:IsPlayer() or not target:Alive() then return end

        local wep = target:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_zs_demon" then 
            return 
        end

        if math.random(0,1) < 0.15 then
            dmginfo:SetDamage(0)
            target:EmitSound("npc/roller/mine/rmine_blip3.wav", 70, 120)

            net.Start("DemonBlade_Evade")
            net.Send(target)
        end
    end)
end