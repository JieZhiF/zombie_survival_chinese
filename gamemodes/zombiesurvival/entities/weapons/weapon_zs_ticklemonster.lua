-- ============================================================================
-- weapon_zs_ticklemonster.lua - 挠痒怪（僵尸远程触手攻击）
-- 负责：超长距离触手近战，对道具造成额外伤害，带触手音效与材质覆盖
-- ============================================================================
AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_ticklemonster") -- 武器显示名称

SWEP.Base = "weapon_zs_zombie" -- 继承僵尸近战武器基类

SWEP.MeleeDamage = 24 -- 对人攻击伤害
SWEP.MeleeDamageVsProps = 28 -- 对道具/实体攻击伤害
SWEP.MeleeReach = 150 -- 攻击距离（超长触手）
SWEP.MeleeSize = 5 -- 攻击判定体积

-- ==== Reload - 按 R 键触发右键重击 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== MeleeHit - 命中非玩家实体时使用对道具伤害倍率 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== PlayAlertSound - 播放触手伸长警报音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound -- 闲置时复用警报音效

-- ==== PlayAttackSound - 播放触手攻击音效 ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav")
end

if not CLIENT then return end

-- ==== ViewModelDrawn - 绘制后清除材质覆盖，避免影响其他物体 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/Charple/Charple1_sheet") -- 触手皮肤材质
-- ==== PreDrawViewModel - 绘制前覆盖为触手皮肤材质 ====
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
