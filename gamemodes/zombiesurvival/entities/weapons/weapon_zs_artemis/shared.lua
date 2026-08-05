-- ============================================================================
-- shared.lua - 阿尔忒弥斯（共享端）
-- 负责：手弩类武器属性、音效注册、改装分支与开火/换弹动画逻辑
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_zs_artemis") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_artemis_description") -- 武器描述

SWEP.SlotPos = 0 -- 武器栏中的槽位

SWEP.Base = "weapon_zs_baseproj" -- 继承投射物武器基类

-- 注册换弹音效（弩上弦）
sound.Add({
	name = "Weapon_Artemis_Reload.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitch = {80, 85},
	sound = "weapons/crossbow/reload1.wav"
})

-- 注册开火音效（弩发射，音调偏高）
sound.Add({
	name = "Weapon_Artemis_Fire.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitch = {150, 160},
	sound = "weapons/crossbow/fire1.wav"
})

-- 注册空枪音效
sound.Add({
	name = "Weapon_Artemis_Empty.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitch = {80, 85},
	sound = "weapons/ar2/ar2_empty.wav"
})

SWEP.HoldType = "duel" -- 持枪姿势（双持手枪）

SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl" -- 第一人称模型
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl" -- 第三人称模型
SWEP.UseHands = true -- 使用玩家手部模型

SWEP.CSMuzzleFlashes = false -- 不使用 CS 风格枪口闪光

SWEP.Primary.Delay = 0.5 -- 射击间隔（秒）
SWEP.Primary.Damage = 85 -- 单发伤害

SWEP.Primary.ClipSize = 4 -- 弹匣容量
SWEP.Primary.Automatic = false -- 单发（非全自动）
SWEP.Primary.Ammo = "XBowBolt" -- 消耗的弹药类型（弩箭）
SWEP.Primary.DefaultClip = 15 -- 默认赠送的弹匣倍数

SWEP.ReloadDelay = 3.5 -- 换弹耗时（秒）

SWEP.Tier = 4 -- 武器等级（4 级）
SWEP.MaxStock = 3 -- 商店最大库存

SWEP.ConeMax = 0 -- 最大扩散（固定精确）
SWEP.ConeMin = 0 -- 最小扩散

SWEP.WalkSpeed = SPEED_SLOW -- 持枪移动速度（慢速）

SWEP.Primary.Sound = Sound("Weapon_Artemis_Fire.Single") -- 开火音效
SWEP.ReloadSound = Sound("Weapon_Artemis_Reload.Single") -- 换弹音效
SWEP.DryFireSound = Sound("Weapon_Artemis_Empty.Single") -- 空枪音效

SWEP.DontScaleReloadSpeed = true -- 换弹速度不受属性加成缩放

-- 附加武器修饰符：换弹速度 +10%、弹匣容量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
-- 添加改装分支：伤害降至 75%，改为发射灼烧弩箭（对目标附加灼烧状态）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_artemis_r1"), ""..translate.Get("weapon_zs_artemis_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.75
	wept.Primary.Projectile = "projectile_arrow_inq"
	wept.EntModify = function(self, ent)
		ent:SetDTBool(0, true)
	end
end)

-- ==== SecondaryAttack - 禁用右键（无副武器功能） ====
function SWEP:SecondaryAttack()
end

-- ==== SendWeaponAnimation - 按弹匣奇偶交替播放左右手攻击动画 ====
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(self:Clip1() % 2 == 0 and ACT_VM_PRIMARYATTACK or ACT_VM_SECONDARYATTACK)
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== ProcessReloadEndTime - 根据换弹速度加成计算换弹完成时间 ====
function SWEP:ProcessReloadEndTime()
	local reloadspeed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()
	self:SetReloadFinish(CurTime() + self.ReloadDelay / reloadspeed)
end
