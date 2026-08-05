-- ============================================================================
-- shared.lua - 屎拍子（僵尸近战武器）共享逻辑
-- 负责：近战属性定义、换弹键触发特殊攻击、各战斗音效（取代基类嚎叫/挥击音）
-- ============================================================================

-- 继承僵尸武器基类
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_shitslapper")

-- 两次近战攻击之间的延迟（秒）
SWEP.MeleeDelay = 0.25
-- 近战攻击距离
SWEP.MeleeReach = 74
-- 近战伤害
SWEP.MeleeDamage = 38
-- 近战判定尺寸（伤害半径）
SWEP.MeleeSize = 16
-- 挥击动画播放速度倍率
SWEP.SwingAnimSpeed = 2.82

-- 部署完成后需要等待才能攻击（防止切出立即挥击）
SWEP.DelayWhenDeployed = true

-- ==== Reload - 换弹键改为触发右键特殊攻击 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 覆盖基类：此武器不使用嚎叫 ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 覆盖基类：此武器不使用嚎叫 ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 此武器永远不处于嚎叫状态 ====
function SWEP:IsMoaning()
	return false
end

-- ==== PlayHitSound - 近战命中音效（僵尸爪击） ====
function SWEP:PlayHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(3)..".wav", 75, math.random(80, 90), nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 近战挥空音效（僵尸爪挥空） ====
function SWEP:PlayMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", 75, math.random(80, 90), nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 攻击音效（僵尸攻击吼） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav", 75, math.random(80, 90))
end

-- ==== PlayAlertSound - 警戒音效（僵尸警觉嚎叫） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/zombie/zombie_alert"..math.random(3)..".wav", 75, math.random(80, 90))
end

-- ==== PlayIdleSound - 待机音效（僵尸低语） ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/zombie/zombie_voice_idle"..math.random(14)..".wav", 75, math.random(80, 90))
end
