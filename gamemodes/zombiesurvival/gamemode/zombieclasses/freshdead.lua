-- ============================================================================
-- 新鲜死者 (Fresh Dead) — 僵尸职业
-- 特点：基础僵尸、使用玩家阵亡前的模型、可装死（假死）、
--       可嘲讽、隐藏职业（作为其他职业的基类）
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Fresh Dead"
-- 翻译键名
CLASS.TranslationName = "class_fresh_dead"
-- 描述文本键名
CLASS.Description = "description_fresh_dead"
-- 控制帮助文本键名
CLASS.Help = "controls_fresh_dead"

-- 初始可用/隐藏
CLASS.Wave = 0
-- 初始解锁
CLASS.Unlocked = true
-- 隐藏（作为基类不直接可选）
CLASS.Hidden = true

-- 生命值
CLASS.Health = 100
-- 移动速度
CLASS.Speed = 195

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 可嘲讽
CLASS.CanTaunt = true

-- 使用玩家之前的模型（保留阵亡时的外观）
CLASS.UsePreviousModel = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_freshdead"

-- 受伤/死亡音效
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 语音音调
CLASS.VoicePitch = 0.65

-- 可装死
CLASS.CanFeignDeath = true

-- 缓存函数和变量
local CurTime = CurTime
local math_random = math.random
local math_max = math.max
local math_min = math.min
local math_ceil = math.ceil
local math_Clamp = math.Clamp

-- 缓存动画常量
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_GMOD_GESTURE_RANGE_ZOMBIE = ACT_GMOD_GESTURE_RANGE_ZOMBIE
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01

-- 脚步声列表
local StepLeftSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
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

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	-- 复活动画
	local revive = pl.Revive
	if revive and revive:IsValid() then
		return ACT_HL2MP_ZOMBIE_SLUMP_RISE, -1
	end

	-- 装死动画
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

	if pl:Crouching() and pl:OnGround() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end

	return ACT_HL2MP_RUN_ZOMBIE, -1
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	-- 复活动画进度
	local revive = pl.Revive
	if revive and revive:IsValid() then
		pl:SetCycle(0.4 + (1 - math_Clamp((revive:GetReviveTime() - CurTime()) / revive.AnimTime, 0, 1)) * 0.6)
		pl:SetPlaybackRate(0)
		return true
	end

	-- 装死动画进度
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
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed, 3))
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

-- 服务端逻辑
if SERVER then
	-- 死亡后切换为默认僵尸职业
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:SetZombieClass(GAMEMODE.DefaultZombieClass)
	end

	-- 备用使用键触发装死
	function CLASS:AltUse(pl)
		pl:StartFeignDeath()
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fresh_dead"

-- 绘制前颜色调制（绿色调）
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0.5, 0.9, 0.5)
end

-- 绘制后恢复颜色调制
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
end
