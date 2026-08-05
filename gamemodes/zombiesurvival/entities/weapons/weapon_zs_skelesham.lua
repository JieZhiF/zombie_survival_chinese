-- ============================================================================
-- weapon_zs_skelesham.lua - 骷髅架僵尸近战武器（僵尸专用）
-- 负责：骷髅架僵尸的近战数值与全套叫声/攻击音效，以及客户端材质渲染替换
-- ============================================================================
AddCSLuaFile()

-- 基于僵尸通用近战武器
SWEP.Base = "weapon_zs_zombie"

-- 显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_skelesham")

-- 近战伤害
SWEP.MeleeDamage = 28

-- ==== Reload - 换弹键触发近战 ====
-- 骷髅架没有换弹概念，按 R 直接执行右键（近战攻击）
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 开始呻吟（空实现） ====
-- 骷髅架不会呻吟，覆盖基础行为
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 停止呻吟（空实现） ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 是否在呻吟 ====
-- 骷髅架永远不呻吟
function SWEP:IsMoaning()
	return false
end

-- ==== PlayIdleSound - 待机音效 ====
-- 随机播放金属摩擦声（随机音高）
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound(string.format("npc/strider/creak%d.wav", math.random(4)), 70, math.random(95, 105))
end

-- ==== PlayAlertSound - 警觉音效 ====
-- 播放高音呼吸声
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/stalker/breathing3.wav", 70, math.random(110, 120))
end

-- ==== PlayAttackSound - 攻击音效 ====
-- 快速僵尸苏醒声 + 随机金属疼痛声
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/wake1.wav", 70, math.random(95, 105))
	self:EmitSound("npc/metropolice/pain"..math.random(4)..".wav", 74, math.Rand(105, 115), 0.65, CHAN_WEAPON + 20)
end

if not CLIENT then return end

-- 布娃娃材质：渲染时整体替换成玩偶材质
local matSheet = Material("models/props_c17/doll01")

-- ==== PreDrawViewModel - 视图模型绘制前 ====
-- 覆盖为玩偶材质，营造骷髅质感
function SWEP:PreDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(matSheet)
end

-- ==== PostDrawViewModel - 视图模型绘制后 ====
-- 恢复默认材质
function SWEP:PostDrawViewModel(vm, wep, pl)
	render.ModelMaterialOverride(nil)
end
