-- ============================================================================
-- weapon_zs_longsword_z.lua - 长剑 Z（僵尸）：募兵与献祭技能武器
-- 负责：右键募兵转化幸存者、重载献祭消耗生命为队友加增益
-- ============================================================================
AddCSLuaFile()

SWEP.Base = "weapon_zs_longsword" -- 基于长剑武器

SWEP.ZombieOnly = true -- 仅僵尸可用
SWEP.MeleeDamage = 32 -- 近战伤害
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage -- 记录原始伤害用于恢复
SWEP.Primary.Delay = 1.2 -- 攻击间隔
SWEP.MeleeRange = 85 -- 近战范围

SWEP.RecruitCD = 30  -- "募兵" CD
SWEP.SacrificeCD = 20 -- "献祭" CD
SWEP.SacrificeBuffDuration = 15 -- "献祭" 增益持续时间
SWEP.SacrificeRange = 600 -- "献祭" 影响范围
SWEP.RecruitLastUse = 0 -- 上次募兵时间
SWEP.SacrificeLastUse = 0 -- 上次献祭时间

-- ==== OnMeleeHit - 命中非玩家时降低伤害 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    -- 未命中玩家（打建筑等）时伤害降低
    if not hitent:IsPlayer() then
        self.MeleeDamage = 20
    end
end

-- ==== PostOnMeleeHit - 攻击结算后恢复原始伤害 ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
    self.MeleeDamage = self.OriginalMeleeDamage
end

-- ==== CanUseRecruit - 检查募兵技能是否冷却完毕 ====
function SWEP:CanUseRecruit()
    return CurTime() >= (self.RecruitLastUse + self.RecruitCD)
end

-- ==== CanUseSacrifice - 检查献祭技能是否冷却完毕 ====
function SWEP:CanUseSacrifice()
    return CurTime() >= (self.SacrificeLastUse + self.SacrificeCD)
end

-- ==== SecondaryAttack - 右键募兵：随机转化一名符合条件的玩家 ====
function SWEP:SecondaryAttack()
    if not self:CanUseRecruit() then return end
    self.RecruitLastUse = CurTime() -- 记录使用时间
    
    local owner = self:GetOwner()
    local candidates = {} -- 符合条件的玩家列表
    
    -- 收集可募兵目标：乌鸦、倒地的幸存者或存活的幸存者（排除邪恶骑士 Boss）
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= owner and not ply:IsBoss() and (ply:GetClass() == "crow" or (ply:Team() == TEAM_SURVIVOR and not ply:Alive()) or ply:Team() == TEAM_SURVIVOR) and ply:GetClass() ~= "boss_evilknight" then
            table.insert(candidates, ply)
        end
    end
    
    -- 随机选一名目标并随机转换为一种僵尸职业
    if #candidates > 0 then
        local target = candidates[math.random(#candidates)]
        local classes = {"butcherex", "painfulskeletons", "plagueroshan"}
        target:SetPlayerClass(classes[math.random(#classes)])
    end
end

-- ==== Reload - 重载献祭：消耗生命为范围内幸存者提供增益 ====
function SWEP:Reload()
    if not self:CanUseSacrifice() then return end
    
    local owner = self:GetOwner()
    -- 生命值不足 200 时不可献祭
    if owner:Health() <= 200 then return end
    
    self.SacrificeLastUse = CurTime() -- 记录使用时间
    owner:SetHealth(owner:Health() - 200) -- 消耗 200 生命
    self.RecruitLastUse = math.max(0, self.RecruitLastUse - 10) -- 加快募兵CD
    
    -- 给范围内所有幸存者设置增益结束时间
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_SURVIVOR and ply:GetPos():DistToSqr(owner:GetPos()) <= (self.SacrificeRange ^ 2) then
            ply:SetNWFloat("BuffEndTime", CurTime() + self.SacrificeBuffDuration)
        end
    end
end

-- 献祭增益：伤害加成 10%
hook.Add("EntityTakeDamage", "SacrificeBuffDamage", function(target, dmginfo)
    if target:IsPlayer() and target:Team() == TEAM_SURVIVOR then
        if target:GetNWFloat("BuffEndTime", 0) > CurTime() then
            dmginfo:ScaleDamage(1.1) -- 10%额外伤害
        end
    end
end)

-- 献祭增益：移速加成 10%
hook.Add("Move", "SacrificeBuffSpeed", function(ply, mv)
    if ply:IsPlayer() and ply:Team() == TEAM_SURVIVOR then
        if ply:GetNWFloat("BuffEndTime", 0) > CurTime() then
            mv:SetMaxSpeed(mv:GetMaxSpeed() * 1.1) -- 10%移速加成
        end
    end
end)