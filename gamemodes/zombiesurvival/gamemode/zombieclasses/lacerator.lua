-- ============================================================================
-- 撕裂者 (Lacerator) — 僵尸职业
-- 继承自：fast_zombie
-- 特点：快速僵尸的进阶版、更高血量速度、使用撕裂者模型、
--       自定义脚步（金属+重型）、自定义死亡/受伤音效
-- ============================================================================

-- 基础职业为"快速僵尸"
CLASS.Base = "fast_zombie"
-- 不可复活分裂
CLASS.Revives = false

-- 职业显示名称
CLASS.Name = "Lacerator"
-- 翻译键名
CLASS.TranslationName = "class_lacerator"
-- 描述文本键名
CLASS.Description = "description_lacerator"
-- 控制帮助文本键名
CLASS.Help = "controls_lacerator"

-- 使用撕裂者模型
CLASS.Model = Model("models/player/zombie_lacerator2.mdl")

-- 出现波次
CLASS.Wave = 4 / 6

-- 生命值
CLASS.Health = 225
-- 移动速度
CLASS.Speed = 270
-- 绑定的武器
CLASS.SWEP = "weapon_zs_lacerator"

-- 碰撞体积和视角
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
-- 视角偏移
CLASS.ViewOffset = Vector(0, 0, 50)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

-- 击杀得分
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio

-- 可嘲讽
CLASS.CanTaunt = true

-- 语音音调
CLASS.VoicePitch = 0.75

-- 无摔落伤害/减速
CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

-- 缓存函数和常量
local math_random = math.random
local math_min = math.min
local math_Clamp = math.Clamp
local math_ceil = math.ceil
local CurTime = CurTime
-- 骨骼放大倍数（2倍）
local BoneScale = Vector(2,2,2)
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE
local ACT_ZOMBIE_LEAP_START = ACT_ZOMBIE_LEAP_START
local ACT_ZOMBIE_LEAPING = ACT_ZOMBIE_LEAPING
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE_FAST = ACT_HL2MP_RUN_ZOMBIE_FAST
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
local ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL = ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL
local ACT_INVALID = ACT_INVALID

-- 金属装备碰撞声
local GearFoley = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav"
}

-- 自定义脚步声（重型+金属碰撞）
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound("npc/antlion_guard/foot_heavy1.wav", 70, math_random(120,133), 0.4)
	else
		pl:EmitSound("npc/antlion_guard/foot_heavy2.wav", 70, math_random(120,133), 0.4)
	end
	pl:EmitSound(GearFoley[math_random(#GearFoley)], 70, 100, 0.6)
	return true
end

-- 脚步音效间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 580 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 400
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 550
	end
	return 250
end

-- 自定义受伤音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/fast_zombie/leap1.wav", 75, math_random(70, 80))
	pl.NextPainSound = CurTime() + .5
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/zombie/zombie_die"..math_random(3)..".wav",70, math_random(80,85))
	return true
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetClimbing or not wep.GetPounceTime then return end

	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.666, 3))
	else
		pl:SetPlaybackRate(1)
	end

	if wep.GetSwinging and wep:GetSwinging() then
		if not pl.PlayingFZSwing then
			pl.PlayingFZSwing = true
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_FRENZY)
		end
	elseif pl.PlayingFZSwing then
		pl.PlayingFZSwing = false
		pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
	end

	if wep:GetClimbing() then
		local vel = pl:GetVelocity()
		local speed = vel:LengthSqr()
		if speed > 64 then
			pl:SetPlaybackRate(math_Clamp(speed / 25600, 0, 1) * (vel.z < 0 and -1 or 1))
		else
			pl:SetPlaybackRate(0)
		end
		return true
	end

	if wep.GetPounceTime and wep:GetPounceTime() > 0 then
		pl:SetPlaybackRate(0.25)
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end

	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl:SetPlaybackRate(1)
		if pl:GetCycle() >= 1 then
			pl:SetCycle(pl:GetCycle() - 1)
		end
		return true
	end

	if wep:IsRoaring() and velocity:Length2DSqr() <= 1 then
		pl:SetPlaybackRate(0)
		pl:SetCycle(math_Clamp(1 - (wep:GetRoarEndTime() - CurTime()) / wep.RoarTime, 0, 1) * 0.9)
		return true
	end
	return true
end

-- 服务端在此处返回
if SERVER then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/lacerator"
