-- ============================================================================
-- weapon_zs_bloatedzombie.lua - 肿胀僵尸爪武器
-- 负责：肿胀僵尸的近战攻击属性（高伤害重击）、特殊音效，以及
--       客户端用"食尸鬼皮肤"材质覆盖僵尸手臂的渲染
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_bloatedzombie")

-- 继承僵尸爪武器母本
SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 31 -- 近战伤害
SWEP.MeleeForceScale = 1.25 -- 命中时施加的击退力度倍率

SWEP.Primary.Delay = 1.4 -- 两次攻击之间的间隔

-- ==== Reload - 换弹：触发副攻击 ====
-- 肿胀僵尸的"换弹键"被复用为右键副攻击（特殊技能）
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== PlayAlertSound - 播放警戒音效 ====
-- 警戒时直接使用攻击音效（低沉吼声）
function SWEP:PlayAlertSound()
	self:PlayAttackSound()
end

-- ==== PlayIdleSound - 播放待机音效 ====
-- 随机播放藤壶舌头伸缩声（模拟鼓胀的身体声）
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end

-- ==== PlayAttackSound - 播放攻击音效 ====
-- 随机播放鱼龙攻击吼声，带随机音调
function SWEP:PlayAttackSound()
	self:EmitSound("npc/ichthyosaur/attack_growl"..math.random(3)..".wav", 70, math.Rand(145, 155))
end

if not CLIENT then return end -- 以下仅客户端执行

-- ==== ViewModelDrawn - 第一人称模型绘制后 ====
-- 清除材质覆盖，恢复正常材质
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet") -- 食尸鬼皮肤材质
-- ==== PreDrawViewModel - 第一人称模型绘制前 ====
-- 用食尸鬼皮肤材质覆盖僵尸手臂，表现肿胀僵尸的皮肤
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
