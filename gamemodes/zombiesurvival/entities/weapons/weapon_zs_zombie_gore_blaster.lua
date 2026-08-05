-- ============================================================================
-- weapon_zs_zombie_gore_blaster.lua - 僵尸近战武器「血腥爆发」（Gore Blaster）
-- 负责：定义僵尸近战伤害、流血状态施加与攻击/警戒/待机音效
-- ============================================================================

AddCSLuaFile()

-- 武器显示名称（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_zombie_gore_blaster")

-- 继承僵尸基础武器模板
SWEP.Base = "weapon_zs_zombie"

-- 近战伤害 18；流血伤害为 8 点（由伤害比例折算）；对场景物件的伤害 28
SWEP.MeleeDamage = 18
SWEP.BleedDamageMul = 8 / SWEP.MeleeDamage
SWEP.MeleeDamageVsProps = 28

-- 发出警戒音后再次攻击所需的冷却时间
SWEP.AlertDelay = 2.75

-- ==== Reload - 换弹键触发右键攻击（僵尸无换弹，按下即攻击） ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== PlayAttackSound - 播放僵尸攻击音效 ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie/zo_attack"..math.random(2)..".wav", 70, math.random(87, 92))
end

-- ==== PlayAlertSound - 播放警戒（发现敌人）音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/zombie/zombie_alert"..math.random(3)..".wav", 70, math.random(87, 92))
end

-- ==== PlayIdleSound - 播放待机低吼音效 ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/zombie/zombie_voice_idle"..math.random(14)..".wav", 70, math.random(87, 92))
end

-- ==== MeleeHit - 命中处理：非玩家目标改用场景物件伤害值 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	-- 命中非玩家（如路障、道具）时使用专门的对物件伤害
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== ApplyMeleeDamage - 造成伤害：命中玩家时附加流血状态 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 服务器端：对玩家命中附加流血状态，按比例叠加流血伤害并记录伤害来源
	if SERVER and ent:IsPlayer() then
		local bleed = ent:GiveStatus("bleed")
		if bleed and bleed:IsValid() then
			bleed:AddDamage(damage * self.BleedDamageMul)
			bleed.Damager = self:GetOwner()
		end
	end

	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end

-- 以下为客户端专属逻辑
if not CLIENT then return end

-- ==== ViewModelDrawn - 清除模型材质覆盖，恢复默认材质 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

-- ==== PreDrawViewModel - 绘制第一人称模型前施加红色染色（血腥外观） ====
function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(1, 0, 0)
end
