-- ============================================================================
-- weapon_zs_nightmare.lua - 梦魇（Nightmare）僵尸利爪
-- 负责：低直接伤害但命中玩家叠加虚弱、暗影视觉与流血三重负面状态；
--       对道具伤害较高；客户端视模型覆盖为梦魇皮肤
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_nightmare")

-- 继承通用僵尸近战武器基底
SWEP.Base = "weapon_zs_zombie"

-- 近战单次伤害（较低）
SWEP.MeleeDamage = 15
-- 命中的流血总伤害
SWEP.BleedDamage = 15
-- 攻击时对持枪者的减速倍率（大幅减速，出手代价高）
SWEP.SlowDownScale = 5.4
-- 近战对道具的伤害（拆墙效率高）
SWEP.MeleeDamageVsProps = 40
-- 虚弱状态时长换算：每点伤害对应 10/15 秒（约 0.667 秒）
SWEP.EnfeebleDurationMul = 10 / SWEP.MeleeDamage

-- ==== Reload - 换弹键触发：直接使用右键（扑击）技能 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== PlayAlertSound - 警戒音效（藤壶舌拉伸声） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end
-- 闲置吼叫复用警戒音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound

-- ==== PlayAttackSound - 攻击音效（藤壶叫声） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav")
end

-- ==== MeleeHit - 近战命中：命中非玩家实体时改用对道具伤害 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== ApplyMeleeDamage - 伤害结算：命中玩家附加虚弱 + 暗影视觉 + 流血 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	if SERVER and ent:IsPlayer() then
		-- 附加虚弱状态（时长随伤害缩放），记录来源
		local gt = ent:GiveStatus("enfeeble", damage * self.EnfeebleDurationMul)
		if gt and gt:IsValid() then
			gt.Applier = self:GetOwner()
		end

		-- 附加 10 秒暗影视觉（视野受限）
		ent:GiveStatus("dimvision", 10)

		-- 附加流血状态并累加流血伤害
		local bleed = ent:GiveStatus("bleed")
		if bleed and bleed:IsValid() then
			bleed:AddDamage(self.BleedDamage)
			bleed.Damager = self:GetOwner()
		end
	end

	-- 继续执行基底（weapon_zs_zombie）的常规近战伤害结算
	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end

-- 以下仅为客户端内容，服务器端到此结束
if not CLIENT then return end

-- ==== ViewModelDrawn - 视模型绘制后清除材质覆盖 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

-- 梦魇皮肤材质
local matSheet = Material("Models/Charple/Charple1_sheet")
-- ==== PreDrawViewModel - 绘制视模型前覆盖为梦魇皮肤 ====
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
