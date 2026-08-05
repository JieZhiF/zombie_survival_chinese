-- ============================================================================
-- weapon_zs_zeknife.lua - 僵尸逃生模式专用匕首
-- 负责：高伤害近战武器（500伤害），用于僵尸逃生模式中人类近身作战
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_zeknife")

if CLIENT then
	-- 第一人称视角设置
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 持握姿势：匕首
SWEP.HoldType = "knife"

-- 第一人称/世界模型（CS 匕首）
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
-- 使用 C 模型手部
SWEP.UseHands = true

-- 近战伤害、攻击范围、攻击判定大小
SWEP.MeleeDamage = 500
SWEP.MeleeRange = 62
SWEP.MeleeSize = 0.875

-- 持有时的移动速度（僵尸逃生模式标准速度）
SWEP.WalkSpeed = SPEED_ZOMBIEESCAPE_NORMAL

-- 攻击延迟
SWEP.Primary.Delay = 0.45

-- 命中贴花类型（砍痕）
SWEP.HitDecal = "Manhackcut"

-- 命中与挥空手势动画
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.MissGesture = SWEP.HitGesture

-- 命中与挥空武器动画
SWEP.HitAnim = ACT_VM_MISSCENTER
SWEP.MissAnim = ACT_VM_PRIMARYATTACK

-- 不播放命中肉体音效（使用自定义音效）
SWEP.NoHitSoundFlesh = true

-- 不允许强化（逃生模式专用武器）
SWEP.AllowQualityWeapons = false

-- ==== PlaySwingSound - 播放挥砍音效 ====
function SWEP:PlaySwingSound()
	-- 随机播放匕首挥砍音效
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

-- ==== PlayHitSound - 播放命中墙壁音效 ====
function SWEP:PlayHitSound()
	-- 播放匕首击墙音效
	self:EmitSound("weapons/knife/knife_hitwall1.wav")
end

-- ==== PlayHitFleshSound - 播放命中肉体音效 ====
function SWEP:PlayHitFleshSound()
	-- 随机播放匕首击中肉体音效
	self:EmitSound("weapons/knife/knife_hit"..math.random(4)..".wav")
end

if SERVER then
	-- ==== InitializeHoldType - 初始化活动动画映射（匕首姿势） ====
	function SWEP:InitializeHoldType()
		self.ActivityTranslate = {}
		-- 将标准 HL2MP 活动映射为匕首专用活动
		self.ActivityTranslate[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslate[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslate[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslate[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_PHYSGUN
		self.ActivityTranslate[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_KNIFE
		self.ActivityTranslate[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslate[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_KNIFE
		self.ActivityTranslate[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_KNIFE
		self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_KNIFE
	end
end
