AddCSLuaFile()

SWEP.Base = "weapon_zs_swissarmyknife"
SWEP.PrintName = ""..translate.Get("weapon_zs_pomendao")

SWEP.MeleeDamage = 3
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.Primary.Delay = 0.15
SWEP.AllowQualityWeapons = false
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    if hitent:IsPlayer() then
        self.MeleeDamage = 3  -- 对玩家造成30伤害
    else
        self.MeleeDamage = 65  -- 对其他目标造成65伤害
    end
end
