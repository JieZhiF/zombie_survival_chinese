-- ============================================================================
-- weapon_zs_zeus/shared.lua - 宙斯：发射强力电弧弩箭的电能十字弓
-- 负责：定义武器的基本属性、开火/装填音效及开镜判定
-- ============================================================================
-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_zeus")
SWEP.Description = ""..translate.Get("weapon_zs_zeus_description")

-- 基于投射物武器母本
SWEP.Base = "weapon_zs_baseproj"

-- 持握姿势：十字弓
SWEP.HoldType = "crossbow"

-- 第一人称与第三人称模型，启用玩家手部模型
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光（自带能量特效）
SWEP.CSMuzzleFlashes = false

-- 开火音效（电流爆炸声）与装填完成音效
SWEP.Primary.Sound = Sound("ambient/levels/labs/electric_explosion5.wav")
SWEP.ReloadFinishSound = Sound("npc/vort/attack_shoot.wav")
-- 射击间隔（秒），全自动
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true
-- 伤害值
SWEP.Primary.Damage = 123

-- 单发弹匣，使用十字弓螺栓弹药，默认携带 15 发
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.DefaultClip = 15
SWEP.RequiredClip = 1

-- 副攻击（装填）的触发延迟（秒）
SWEP.SecondaryDelay = 0.25

-- 持枪移动速度：慢速
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级与商店最大库存
SWEP.Tier = 4
SWEP.MaxStock = 3

-- 零扩散：射击完全精准
SWEP.ConeMax = 0
SWEP.ConeMin = 0

-- 开镜冷却计时器（用于防止快速连续开镜）
SWEP.NextZoom = 0

-- 装填速度倍率
SWEP.ReloadSpeed = 0.8

-- 附加装填速度强化模组（每级 +6.5%）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.065)

-- ==== EmitFireSound - 播放开火音效：电流爆炸 + 弩箭射出 ====
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 75, math.random(215, 225), 0.75)
	self:EmitSound("weapons/crossbow/bolt_skewer1.wav", 75, math.random(112, 128), 0.6, CHAN_WEAPON + 20)
end

-- ==== EmitReloadSound - 播放装填（上弦）音效，仅首次预测时播放避免重复 ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/crossbow/bolt_load"..math.random(2)..".wav", 50, 85, 1, CHAN_WEAPON + 21)
	end
end

-- ==== EmitReloadFinishSound - 播放装填完成音效，仅首次预测时播放 ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound(self.ReloadFinishSound, 75, 235, 0.5, CHAN_WEAPON + 22)
	end
end

-- ==== IsScoped - 开镜判定：机瞄状态且开镜超过 0.25 秒后才算开镜 ====
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- 预缓存装填音效，避免首次播放卡顿
util.PrecacheSound("weapons/crossbow/bolt_load1.wav")
util.PrecacheSound("weapons/crossbow/bolt_load2.wav")
