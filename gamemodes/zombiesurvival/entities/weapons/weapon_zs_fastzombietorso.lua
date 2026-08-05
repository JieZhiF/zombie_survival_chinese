-- ============================================================================
-- weapon_zs_fastzombietorso.lua - 快速僵尸躯干武器
-- 负责：快速僵尸（猎头蟹僵尸躯干）近战数值与全套攻击/待机音效
-- ============================================================================
AddCSLuaFile()

-- 基于僵尸躯干通用武器
SWEP.Base = "weapon_zs_zombietorso"

-- 显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_fastzombietorso")

-- 第一人称模型
SWEP.ViewModel = Model("models/weapons/v_fza.mdl")

-- 近战出手延迟
SWEP.MeleeDelay = 0.25
-- 近战伤害
SWEP.MeleeDamage = 18
-- 挥击动画速度倍率
SWEP.SwingAnimSpeed = 2.4

-- ==== PlayHitSound - 命中音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("NPC_FastZombie.AttackHit", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 挥空音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("NPC_FastZombie.AttackMiss", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 攻击音效 ====
-- 播放快速僵尸扑击声
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/leap1.wav", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayIdleSound - 待机音效 ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("NPC_FastZombie.AlertFar")
end

-- ==== PlayAlertSound - 警觉音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("NPC_FastZombie.Frenzy")
end