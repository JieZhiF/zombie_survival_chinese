-- ============================================================================
-- weapon_zs_anightmare.lua - 进阶梦魇（A Nightmare）僵尸利爪
-- 负责：高伤害（55）的梦魇精英僵尸近战武器；换弹键复用右键扑击技能；
--       客户端视模型覆盖为梦魇皮肤
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_anightmare")

-- 继承通用僵尸近战武器基底
SWEP.Base = "weapon_zs_zombie"

-- 近战单次伤害（高）
SWEP.MeleeDamage = 55
-- 攻击时对持枪者的减速倍率
SWEP.SlowDownScale = 1

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
	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav", 75, 85)
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
