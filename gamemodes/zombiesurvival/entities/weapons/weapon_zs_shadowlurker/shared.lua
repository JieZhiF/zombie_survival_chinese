-- ============================================================================
-- weapon_zs_shadowlurker/shared.lua - 暗影潜行者（僵尸近战爪击，共享端定义）
-- 负责：近战攻击属性与攻击/待机/警戒等状态音效
-- ============================================================================
-- 继承僵尸躯干基础武器（僵尸持有时为爪击攻击）
SWEP.Base = "weapon_zs_zombietorso"

-- 武器名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_shadowlurker")

-- 近战攻击间隔 / 近战伤害
SWEP.MeleeDelay = 0.25
SWEP.MeleeDamage = 20

-- ==== PlayHitSound - 播放命中音效（快速僵尸攻击命中声） ====
function SWEP:PlayHitSound()
	self:EmitSound("NPC_FastZombie.AttackHit", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 播放挥空音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("NPC_FastZombie.AttackMiss", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 播放攻击前警告音效（随机音调） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie_poison/pz_warn"..math.random(2)..".wav", 70, math.random(200, 210), nil, CHAN_AUTO)
end

-- ==== PlayIdleSound - 播放待机音效（低频虫鸣声，由主人播放） ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/antlion/idle"..math.random(5)..".wav", 70, math.random(60, 66))
end

-- ==== PlayAlertSound - 播放警戒音效（呼吸声，由主人播放） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/stalker/breathing3.wav", 70, math.random(80, 90))
end
