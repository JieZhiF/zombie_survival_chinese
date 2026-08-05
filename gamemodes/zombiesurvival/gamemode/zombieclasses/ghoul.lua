-- ============================================================================
-- 食尸鬼 (Ghoul) — 僵尸职业
-- 特点：使用尸体模型、可装死、可嘲讽、黄色血液、
--       自定义受伤/死亡音效、使用毒僵尸音效
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Ghoul"
-- 翻译键名
CLASS.TranslationName = "class_ghoul"
-- 描述文本键名
CLASS.Description = "description_ghoul"
-- 控制帮助文本键名
CLASS.Help = "controls_ghoul"

-- 初始可用
CLASS.Wave = 0
-- 初始解锁
CLASS.Unlocked = true

-- 进阶版本
CLASS.BetterVersion = "Noxious Ghoul"

-- 生命值
CLASS.Health = 200
-- 移动速度
CLASS.Speed = 175

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 可嘲讽
CLASS.CanTaunt = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_ghoul"

-- 使用尸体模型
CLASS.Model = Model("models/player/corpse1.mdl")

-- 语音音调
CLASS.VoicePitch = 0.7

-- 可装死
CLASS.CanFeignDeath = true

-- 黄色血液
CLASS.BloodColor = BLOOD_COLOR_YELLOW

-- 缓存函数
local CurTime = CurTime
local math_random = math.random
local math_max = math.max
local math_min = math.min
local math_ceil = math.ceil

-- 缓存常量和动画
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE
local DIR_BACK = DIR_BACK
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_IDLE_ZOMBIE = ACT_HL2MP_IDLE_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_WALK_ZOMBIE_01 = ACT_HL2MP_WALK_ZOMBIE_01

-- 脚步声和摩擦声
local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}
local ScuffSounds = {
	"npc/zombie/foot_slide1.wav",
	"npc/zombie/foot_slide2.wav",
	"npc/zombie/foot_slide3.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random() < 0.15 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 70)
	else
		pl:EmitSound(StepSounds[math_random(#StepSounds)], 70)
	end
	return true
end

-- 自定义受伤音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_warn"..math_random(2)..".wav", 75, math.Rand(137, 143))
	pl.NextPainSound = CurTime() + 0.5
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_die2.wav", 75, math.Rand(122, 128))
	return true
end

-- 脚步音效间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 625 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 600
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 750
	end
	return 450
end

-- 被击倒时重置手势
function CLASS:KnockedDown(pl, status, exists)
	pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetDirection() == DIR_BACK then
			return 1, pl:LookupSequence("zombie_slump_rise_02_fast")
		end
		return ACT_HL2MP_ZOMBIE_SLUMP_RISE, -1
	end

	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end

	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end
		return ACT_HL2MP_IDLE_ZOMBIE, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
	end

	return ACT_HL2MP_WALK_ZOMBIE_01 - 1 + math_ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetState() == 1 then
			pl:SetCycle(1 - math_max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		else
			pl:SetCycle(math_max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		end
		pl:SetPlaybackRate(0)
		return true
	end

	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5, 3))
	else
		pl:SetPlaybackRate(1)
	end
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:DoZombieAttackAnim(data)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 装死时不产生恐惧
function CLASS:DoesntGiveFear(pl)
	return pl.FeignDeath and pl.FeignDeath:IsValid()
end

-- 服务端：备用使用键触发装死
if SERVER then
	function CLASS:AltUse(pl)
		pl:StartFeignDeath()
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/ghoul"
