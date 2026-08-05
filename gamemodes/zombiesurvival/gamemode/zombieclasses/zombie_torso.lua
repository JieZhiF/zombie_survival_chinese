-- ============================================================================
-- zombie_torso.lua - 僵尸躯干 (Zombie Torso) 职业
-- 负责：快速僵尸死亡后分裂出的躯干形态，低血量、矮碰撞体积、
--       无蹲伏、滑动脚步音效、爬行动画
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Zombie Torso"
-- 翻译键名
CLASS.TranslationName = "class_zombie_torso"
-- 描述文本键名
CLASS.Description = "description_zombie_torso"

-- 躯干模型（经典僵尸躯干）
CLASS.Model = Model("models/Zombie/Classic_torso.mdl")

-- 绑定的武器
CLASS.SWEP = "weapon_zs_zombietorso"

-- 初始解锁波次（第 0 波即解锁）
CLASS.Wave = 0
-- 解锁阈值（无条件）
CLASS.Threshold = 0
-- 默认解锁
CLASS.Unlocked = true
-- 隐藏职业（不出现在常规选择列表，由分裂机制生成）
CLASS.Hidden = true

-- 生命值
CLASS.Health = 100
-- 移动速度
CLASS.Speed = 130
-- 跳跃力
CLASS.JumpPower = 120

-- 击杀得分（按躯干僵尸得分比例计算）
CLASS.Points = CLASS.Health/GM.TorsoZombiePointRatio

-- 矮小碰撞体积（贴地爬行）
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 20)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 20)}
-- 低视角偏移
CLASS.ViewOffset = Vector(0, 0, 14)
CLASS.ViewOffsetDucked = Vector(0, 0, 14)
-- 质量（较轻，易被击退）
CLASS.Mass = DEFAULT_MASS * 0.5
-- 蹲伏行走速度倍率
CLASS.CrouchedWalkSpeed = 1
-- 台阶跨越高度（较低，只能爬小台阶）
CLASS.StepSize = 12

-- 无法主动蹲伏
CLASS.CantDuck = true

-- 受伤音效
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 语音音调（低沉）
CLASS.VoicePitch = 0.65

-- 标记为躯干形态（分裂职业）
CLASS.IsTorso = true

-- 缓存随机数与动画常量
local math_random = math.random
local ACT_WALK = ACT_WALK

-- ==== CalcMainActivity - 计算主要活动动画（静止时用自定义爬行帧，移动时用行走动画） ====
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return 1, 1
	end

	return ACT_WALK, -1
end

-- 拖动滑行脚步音效列表
local ScuffSounds = {
	"npc/zombie/foot_slide1.wav",
	"npc/zombie/foot_slide2.wav",
	"npc/zombie/foot_slide3.wav"
}

-- ==== PlayerFootstep - 低概率播放躯干拖地滑行音效 ====
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random() < 0.07 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 70, 90)
	end

	return true
end

-- ==== DoAnimationEvent - 处理主攻击动画事件（播放近战攻击手势） ====
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end

-- 服务端逻辑
if SERVER then
	-- ==== OnSecondWind - 回光返照时播放僵尸叫声 ====
	function CLASS:OnSecondWind(pl)
		pl:EmitSound("npc/zombie/zombie_voice_idle"..math.random(14)..".wav", 100, 85)
	end
end

-- 客户端逻辑
if CLIENT then
	-- 击杀图标
	CLASS.Icon = "zombiesurvival/killicons/torso"
end
