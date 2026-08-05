-- ============================================================================
-- weapon_zs_fastheadcrab.lua - 快速猎头蟹（僵尸近战武器）
-- 负责：定义快速猎头蟹的扑击伤害与专属音效
-- ============================================================================
AddCSLuaFile()

-- 基于猎头蟹武器母本
SWEP.Base = "weapon_zs_headcrab"

-- 武器名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_fastheadcrab")

-- 扑击伤害
SWEP.PounceDamage = 6

-- 无命中/命中后的攻击恢复时间
SWEP.NoHitRecovery = 0.6
SWEP.HitRecovery = 0.75

-- ==== EmitBiteSound - 播放撕咬音效 ====
function SWEP:EmitBiteSound()
	self:GetOwner():EmitSound("NPC_FastHeadcrab.Bite")
end

-- ==== EmitIdleSound - 播放空闲音效 ====
function SWEP:EmitIdleSound()
	self:GetOwner():EmitSound("NPC_FastHeadcrab.Idle")
end

-- ==== EmitAttackSound - 播放攻击音效 ====
function SWEP:EmitAttackSound()
	self:GetOwner():EmitSound("NPC_FastHeadcrab.Attack")
end

-- ==== Reload - 换弹键：无操作（猎头蟹不需要换弹） ====
function SWEP:Reload()
end
