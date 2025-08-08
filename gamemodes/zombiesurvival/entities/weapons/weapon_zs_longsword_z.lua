AddCSLuaFile()

SWEP.Base = "weapon_zs_longsword"

SWEP.ZombieOnly = true
SWEP.MeleeDamage = 32
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.Primary.Delay = 1.2
SWEP.MeleeRange = 85

SWEP.RecruitCD = 30  -- "募兵" CD
SWEP.SacrificeCD = 20 -- "献祭" CD
SWEP.SacrificeBuffDuration = 15 -- "献祭" 增益持续时间
SWEP.SacrificeRange = 600 -- "献祭" 影响范围
SWEP.RecruitLastUse = 0
SWEP.SacrificeLastUse = 0

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    if not hitent:IsPlayer() then
        self.MeleeDamage = 20
    end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
    self.MeleeDamage = self.OriginalMeleeDamage
end

function SWEP:CanUseRecruit()
    return CurTime() >= (self.RecruitLastUse + self.RecruitCD)
end

function SWEP:CanUseSacrifice()
    return CurTime() >= (self.SacrificeLastUse + self.SacrificeCD)
end

function SWEP:SecondaryAttack()
    if not self:CanUseRecruit() then return end
    self.RecruitLastUse = CurTime()
    
    local owner = self:GetOwner()
    local candidates = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= owner and not ply:IsBoss() and (ply:GetClass() == "crow" or (ply:Team() == TEAM_SURVIVOR and not ply:Alive()) or ply:Team() == TEAM_SURVIVOR) and ply:GetClass() ~= "boss_evilknight" then
            table.insert(candidates, ply)
        end
    end
    
    if #candidates > 0 then
        local target = candidates[math.random(#candidates)]
        local classes = {"butcherex", "painfulskeletons", "plagueroshan"}
        target:SetPlayerClass(classes[math.random(#classes)])
    end
end

function SWEP:Reload()
    if not self:CanUseSacrifice() then return end
    
    local owner = self:GetOwner()
    if owner:Health() <= 200 then return end
    
    self.SacrificeLastUse = CurTime()
    owner:SetHealth(owner:Health() - 200)
    self.RecruitLastUse = math.max(0, self.RecruitLastUse - 10) -- 加快募兵CD
    
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_SURVIVOR and ply:GetPos():DistToSqr(owner:GetPos()) <= (self.SacrificeRange ^ 2) then
            ply:SetNWFloat("BuffEndTime", CurTime() + self.SacrificeBuffDuration)
        end
    end
end

hook.Add("EntityTakeDamage", "SacrificeBuffDamage", function(target, dmginfo)
    if target:IsPlayer() and target:Team() == TEAM_SURVIVOR then
        if target:GetNWFloat("BuffEndTime", 0) > CurTime() then
            dmginfo:ScaleDamage(1.1) -- 10%额外伤害
        end
    end
end)

hook.Add("Move", "SacrificeBuffSpeed", function(ply, mv)
    if ply:IsPlayer() and ply:Team() == TEAM_SURVIVOR then
        if ply:GetNWFloat("BuffEndTime", 0) > CurTime() then
            mv:SetMaxSpeed(mv:GetMaxSpeed() * 1.1) -- 10%移速加成
        end
    end
end)