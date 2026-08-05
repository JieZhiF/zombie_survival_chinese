-- ============================================================================
-- 毒猎头蟹 (Poison Headcrab) — 僵尸职业
-- 特点：黑色猎头蟹模型、可喷吐毒液、可扑击、远程攻击、
--       绿色血液、跳跃/喷吐时视角锁定
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Poison Headcrab"
-- 翻译键名
CLASS.TranslationName = "class_poison_headcrab"
-- 描述文本键名
CLASS.Description = "description_poison_headcrab"
-- 控制帮助文本键名
CLASS.Help = "controls_poison_headcrab"

-- 进阶版本
CLASS.BetterVersion = "Barbed Headcrab"

-- 黑色猎头蟹模型
CLASS.Model = Model("models/headcrabblack.mdl")

-- 出现波次
CLASS.Wave = 3 / 6
-- 出现阈值
CLASS.Threshold = 0.6

-- 绑定的武器
CLASS.SWEP = "weapon_zs_poisonheadcrab"

-- 生命值
CLASS.Health = 85
-- 移动/跳跃
CLASS.Speed = 145
CLASS.JumpPower = 100

-- 无摔落伤害/减速
CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

-- 标记为猎头蟹
CLASS.IsHeadcrab = true

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HeadcrabZombiePointRatio

-- 小型碰撞体积
CLASS.Hull = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
-- 视角偏移
CLASS.ViewOffset = Vector(0, 0, 10)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 10)
-- 台阶高度
CLASS.StepSize = 8
-- 蹲伏行走速度倍率
CLASS.CrouchedWalkSpeed = 1
-- 质量
CLASS.Mass = 40

-- 不能蹲下
CLASS.CantDuck = true

-- 受伤/死亡音效
-- 受伤音效
CLASS.PainSounds = {"NPC_BlackHeadcrab.Pain"}
-- 死亡音效
CLASS.DeathSounds = {"NPC_BlackHeadcrab.Die"}

-- 绿色血液
CLASS.BloodColor = BLOOD_COLOR_GREEN

-- 缓存函数和变量
local math_random = math.random
local CurTime = CurTime
local math_max = math.max
local math_sin = math.sin
local math_pi = math.pi

local ACT_RUN = ACT_RUN
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE

-- 移动逻辑
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end
end

-- 缩放伤害
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

-- 脚步声
local StepSounds = {
	"npc/headcrab_poison/ph_step1.wav",
	"npc/headcrab_poison/ph_step2.wav",
	"npc/headcrab_poison/ph_step3.wav",
	"npc/headcrab_poison/ph_step4.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 60)
	return true
end

-- 脚步音效间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 285 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 200
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 280
	end
	return 175
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.ShouldPlayLeapAnimation and wep:ShouldPlayLeapAnimation() then
			return 1, 7  -- 跳跃预备
		end
		if wep.IsGoingToSpit and wep:IsGoingToSpit() then
			return 1, 2  -- 喷吐预备
		end
	end

	if pl:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end
		return 1, 4
	end
	return 1, 6
end

-- 更新动画（喷吐/跳跃蓄力动画）
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local seq = pl:GetSequence()

	if seq == 2 then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.SpitWindUp then
			local spitend = wep:GetNextSpit()
			local lerp = 1 - math_max(0, spitend - CurTime()) / wep.SpitWindUp

			if lerp == 1 then
				pl:SetCycle(0.6 + math_sin(CurTime() * math_pi) * 0.1)
			else
				pl:SetCycle(lerp * 0.6)
			end
			pl:SetPlaybackRate(0)
			return true
		end
	elseif seq == 7 then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.PounceWindUp then
			local spitend = wep:GetNextLeap()
			local lerp = 1 - math_max(0, spitend - CurTime()) / wep.PounceWindUp

			if lerp == 1 then
				pl:SetCycle(0.7 + math_sin(CurTime() * math_pi) * 0.1)
			else
				pl:SetCycle(lerp * 0.7)
			end
			pl:SetPlaybackRate(0)
			return true
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/poisonheadcrab"

-- 客户端移动指令：跳跃/喷吐时视角锁定
function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.m_ViewAngles and (wep.IsLeaping and wep:IsLeaping() or wep.IsGoingToLeap and wep:IsGoingToLeap()) then
		local maxdiff = FrameTime() * 15
		local mindiff = -maxdiff
		local originalangles = wep.m_ViewAngles
		local viewangles = cmd:GetViewAngles()

		local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
		if diff > maxdiff or diff < mindiff then
			viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
		end

		wep.m_ViewAngles = viewangles
		cmd:SetViewAngles(viewangles)
	end
end
