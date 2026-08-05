-- ============================================================================
-- weapon_zs_skeleton.lua - 骷髅僵尸的近战武器
-- 负责：骷髅僵尸近战属性、特殊攻击（换弹触发）、骨骼音效及客户端玩偶材质渲染
-- ============================================================================
AddCSLuaFile()

-- 基于僵尸通用武器母本
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_skeleton")

-- 近战伤害值
SWEP.MeleeDamage = 22

-- ==== Reload - 换弹键触发副攻击（特殊技能） ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 占位：骷髅不发出持续呻吟声 ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 占位：骷髅不发出持续呻吟声 ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 骷髅永远不处于呻吟状态 ====
function SWEP:IsMoaning()
	return false
end

-- ==== PlayIdleSound - 播放随机骨骼吱嘎作响的待机音效 ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound(string.format("npc/strider/creak%d.wav", math.random(4)), 70, math.random(115, 125))
end

-- ==== PlayAlertSound - 播放警报（发现敌人）时的呼吸音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/stalker/breathing3.wav", 70, math.random(110, 120))
end

-- ==== PlayAttackSound - 播放攻击起始音效 ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/wake1.wav", 70, math.random(115, 140))
end

if not CLIENT then return end

-- 玩偶材质：覆盖渲染让骷髅呈现玩具/玩偶质感
local matSheet = Material("models/props_c17/doll01")

-- ==== PreDrawViewModel - 渲染前把武器材质覆盖为玩偶材质 ====
function SWEP:PreDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(matSheet)
end

-- ==== PostDrawViewModel - 渲染后清除材质覆盖 ====
function SWEP:PostDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(nil)
end
