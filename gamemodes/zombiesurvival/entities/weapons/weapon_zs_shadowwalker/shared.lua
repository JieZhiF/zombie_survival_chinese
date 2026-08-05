-- ============================================================================
-- weapon_zs_shadowwalker/shared.lua - 暗影行者僵尸利爪（共享）
-- 负责：定义近战伤害与整套音效回调；该僵尸保持静默（不呻吟），
--       换弹键复用右键扑击技能
-- ============================================================================
-- 继承通用僵尸近战武器基底
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_shadowwalker")

-- 近战单次伤害
SWEP.MeleeDamage = 30

-- ==== Reload - 换弹键触发：直接使用右键（扑击）技能 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 开始呻吟（空实现：暗影行者保持静默潜行） ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 停止呻吟（空实现） ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 是否正在呻吟（恒为否：永远不会被听声辨位） ====
function SWEP:IsMoaning()
	return false
end

-- ==== PlayHitSound - 命中音效（快僵尸爪击命中） ====
function SWEP:PlayHitSound()
	self:EmitSound("NPC_FastZombie.AttackHit", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 挥空音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("NPC_FastZombie.AttackMiss", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 攻击音效（毒僵尸警示声，高音调变奏） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie_poison/pz_warn"..math.random(2)..".wav", 70, math.random(180, 190), nil, CHAN_AUTO)
end

-- ==== PlayIdleSound - 闲置音效（蚂蚁狮低鸣） ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/antlion/idle"..math.random(5)..".wav", 70, math.random(60, 66))
end

-- ==== PlayAlertSound - 警戒音效（猎人呼吸声） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/stalker/breathing3.wav", 70, math.random(80, 90))
end
