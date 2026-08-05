-- ============================================================================
-- weapon_zs_eradicator.lua - 根除者（Eradicator）僵尸利爪武器
-- 负责：定义僵尸近战利爪的伤害、警报/攻击音效，以及第一人称的僵尸皮肤外观；
--       换弹键复用右键的扑击技能
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_eradicator")

-- 继承通用僵尸近战武器基底
SWEP.Base = "weapon_zs_zombie"

-- 近战单次伤害
SWEP.MeleeDamage = 30
-- 攻击时对持枪者的减速倍率（0 = 不减速）
SWEP.SlowDownScale = 0

-- 发出警报嚎叫的间隔时间（秒）
SWEP.AlertDelay = 3.5

-- ==== Reload - 换弹键触发：直接使用右键（扑击）技能 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== PlayAlertSound - 播放警戒嚎叫（发现/被激怒时，通过所有者发声） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/combine_gunship/gunship_moan.wav", 75, math.random(70,75))
end
-- 闲置时的吼叫复用警戒音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound

-- ==== PlayAttackSound - 播放攻击音效（随机咆哮） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 75, math.random(75,80))
end

-- 以下仅为客户端内容，服务器端到此结束
if not CLIENT then return end

-- ==== ViewModelDrawn - 视模型绘制完成后清除材质覆盖 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

-- 僵尸皮肤材质（尸体模型贴图）
local matSheet = Material("Models/charple/charple4_sheet.vtf")
-- ==== PreDrawViewModel - 绘制视模型前覆盖为僵尸皮肤 ====
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
