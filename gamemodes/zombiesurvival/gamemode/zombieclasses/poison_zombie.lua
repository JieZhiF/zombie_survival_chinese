-- ============================================================================
-- 毒僵尸 (Poison Zombie) — 僵尸职业
-- 特点：毒僵尸模型、高血量、较高质量（不易被击退）、
--       缓慢行走动画、绿色血液
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Poison Zombie"
-- 翻译键名
CLASS.TranslationName = "class_poison_zombie"
-- 描述文本键名
CLASS.Description = "description_poison_zombie"
-- 控制帮助文本键名
CLASS.Help = "controls_poison_zombie"

-- 进阶版本
CLASS.BetterVersion = "Wild Poison Zombie"

-- 毒僵尸模型
CLASS.Model = Model("models/Zombie/Poison.mdl")

-- 出现波次
CLASS.Wave = 4 / 6

-- 生命值
CLASS.Health = 440
-- 移动速度
CLASS.Speed = 150
-- 跳跃力
CLASS.JumpPower = DEFAULT_JUMP_POWER * 1.081
-- 绑定的武器
CLASS.SWEP = "weapon_zs_poisonzombie"

-- 质量（不易被击退）
CLASS.Mass = DEFAULT_MASS * 1.5

-- 击杀得分
CLASS.Points = CLASS.Health/GM.PoisonZombiePointRatio

-- 受伤/死亡音效
-- 受伤音效
CLASS.PainSounds = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav", "npc/zombie_poison/pz_pain3.wav"}
-- 死亡音效
CLASS.DeathSounds = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
-- 语音音调
CLASS.VoicePitch = 0.6

-- 视角偏移和碰撞体积
-- 视角偏移
CLASS.ViewOffset = Vector(0, 0, 50)
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

-- 黄色血液
CLASS.BloodColor = BLOOD_COLOR_YELLOW

-- 缓存函数
local math_random = math.random

-- 缓存动画和脚步常量
local ACT_IDLE = ACT_IDLE
local ACT_WALK = ACT_WALK
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return ACT_WALK, -1
end

-- 自定义脚步声
-- 自定义脚步声（左右脚交替音效）
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math_random(3) < 3 then
		pl:EmitSound("npc/zombie_poison/pz_right_foot1.wav")
	else
		pl:EmitSound("npc/zombie_poison/pz_left_foot1.wav")
	end
	return true
end

-- 脚步音效间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 365 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 300
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 450
	end
	return 150
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/poisonzombie"
