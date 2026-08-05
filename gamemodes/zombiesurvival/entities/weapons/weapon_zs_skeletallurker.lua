-- ============================================================================
-- weapon_zs_skeletallurker.lua - 白骨潜行者（僵尸近战武器）
-- 负责：定义潜行者的静默爪击（不发出呻吟声）与特殊音效
-- ============================================================================
AddCSLuaFile()

-- 基于僵尸躯体武器母本
SWEP.Base = "weapon_zs_zombietorso"

-- 武器名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_skeletallurker")

-- 近战攻击间隔与伤害
SWEP.MeleeDelay = 0.25
SWEP.MeleeDamage = 14

-- ==== Reload - 换弹键：复用副攻击 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 开始呻吟：潜行者保持静默（空实现） ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 停止呻吟：空实现 ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 是否在呻吟：始终返回否（静默特性） ====
function SWEP:IsMoaning()
	return false
end

-- ==== PlayIdleSound - 空闲音效：木质吱嘎声 ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound(string.format("npc/strider/creak%d.wav", math.random(4)), 70, math.random(125, 135))
end

-- ==== PlayAlertSound - 警戒音效：呼吸声 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/stalker/breathing3.wav", 70, math.random(120, 130))
end

-- ==== PlayAttackSound - 攻击音效：苏醒叫声 ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/wake1.wav", 70, math.random(125, 150))
end

-- 以下为客户端专属内容
if not CLIENT then return end

-- 骨白色皮肤材质覆盖
local matSheet = Material("models/props_c17/doll01")

-- ==== PreDrawViewModel - 视图模型绘制前：覆盖为娃娃材质 ====
function SWEP:PreDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(matSheet)
end

-- ==== PostDrawViewModel - 视图模型绘制后：恢复默认材质 ====
function SWEP:PostDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(nil)
end
