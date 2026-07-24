--[[
==================================================================
快速僵尸 (Fast Zombie) — 僵尸职业
特点：高速移动、可爬墙、可扑击、无腿部受伤判定、可嘲讽、
      死亡时概率分裂为腿部或躯干僵尸、无摔落伤害
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Fast Zombie"
-- 翻译键名
CLASS.TranslationName = "class_fast_zombie"
-- 描述文本键名
CLASS.Description = "description_fast_zombie"
-- 控制帮助文本键名
CLASS.Help = "controls_fast_zombie"

-- 进阶版本
CLASS.BetterVersion = "Lacerator"

-- 使用快速僵尸模型
CLASS.Model = Model("models/player/zombie_fast.mdl")

-- 出现波次
CLASS.Wave = 2 / 6
-- 若50%人类死亡则自动解锁此职业
CLASS.Infliction = 0.5
-- 可复活分裂
CLASS.Revives = true

-- 生命值
CLASS.Health = 150
-- 移动速度
CLASS.Speed = 255
-- 绑定的武器
CLASS.SWEP = "weapon_zs_fastzombie"

-- 击杀得分
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio

-- 可嘲讽
CLASS.CanTaunt = true

-- 碰撞体积和视角偏移
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

-- 受伤/死亡音效
CLASS.PainSounds = {"NPC_FastZombie.Pain"}
CLASS.DeathSounds = {"npc/fast_zombie/leap1.wav"}

-- 语音音调
CLASS.VoicePitch = 0.75

-- 无摔落伤害/减速
CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

-- 缓存函数和变量
local math_random = math.random
local math_min = math.min
local math_Clamp = math.Clamp
local CurTime = CurTime
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE
local ACT_ZOMBIE_CLIMB_UP = ACT_ZOMBIE_CLIMB_UP
local ACT_ZOMBIE_LEAP_START = ACT_ZOMBIE_LEAP_START
local ACT_ZOMBIE_LEAPING = ACT_ZOMBIE_LEAPING
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_HL2MP_RUN_ZOMBIE_FAST = ACT_HL2MP_RUN_ZOMBIE_FAST
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01

-- 移动逻辑
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end

	if mv:GetForwardSpeed() <= 0 then
		mv:SetMaxSpeed(math_min(mv:GetMaxSpeed(), 90))
		mv:SetMaxClientSpeed(math_min(mv:GetMaxClientSpeed(), 90))
	end
end

-- 脚步声列表
local StepLeftSounds = {
	"npc/fast_zombie/foot1.wav",
	"npc/fast_zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/fast_zombie/foot3.wav",
	"npc/fast_zombie/foot4.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[math_random(#StepLeftSounds)], 70)
	else
		pl:EmitSound(StepRightSounds[math_random(#StepRightSounds)], 70)
	end
	return true
end

-- 脚步音效间隔时间
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 450 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 400
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 550
	end
	return 250
end

-- 缩放伤害
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

-- 忽略腿部伤害
function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetClimbing or not wep.GetPounceTime then return end

	if wep:GetClimbing() then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end

	if wep:GetPounceTime() > 0 then
		return ACT_ZOMBIE_LEAP_START, -1
	end

	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		return ACT_ZOMBIE_LEAPING, -1
	end

	local speed = velocity:Length2DSqr()

	if speed <= 1 and wep:IsRoaring() then
		return 1, pl:LookupSequence("menu_zombie_01")
	end

	if speed > 256 and wep:GetSwinging() then
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

	if pl:Crouching() then
		return speed <= 1 and ACT_HL2MP_IDLE_CROUCH_ZOMBIE or ACT_HL2MP_WALK_CROUCH_ZOMBIE_01, -1
	end

	return ACT_HL2MP_RUN_ZOMBIE_FAST, -1
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetClimbing or not wep.GetPounceTime then return end

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
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		return ACT_INVALID
	end
end

-- 服务端逻辑：死亡分裂
if SERVER then
	function CLASS:ReviveCallback(pl, attacker, dmginfo)
		if math.random(2) == 2 or not pl:ShouldReviveFrom(dmginfo, self.Hull[2].z * 0.4) then return false end

		local classtable = math_random(3) == 3 and GAMEMODE.ZombieClasses["Fast Zombie Legs"] or GAMEMODE.ZombieClasses["Fast Zombie Torso"]
		if classtable then
			pl:RemoveStatus("overridemodel", false, true)
			local deathclass = pl.DeathClass or pl:GetZombieClass()
			pl:SetZombieClass(classtable.Index)
			pl:DoHulls(classtable.Index, TEAM_UNDEAD)
			pl.DeathClass = deathclass

			pl:EmitSound("physics/flesh/flesh_bloody_break.wav", 100, 75)
			pl:Gib()
			pl.Gibbed = nil

			timer.Simple(0, function()
				if IsValid(pl) then
					pl:SecondWind()
				end
			end)
			return true
		end
		return false
	end
end

-- 服务端在此处返回
if SERVER then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fastzombie"

-- 客户端移动指令：扑击时视角锁定
function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsPouncing then
		if wep.m_ViewAngles and wep:IsPouncing() then
			local maxdiff = FrameTime() * 20
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
end
