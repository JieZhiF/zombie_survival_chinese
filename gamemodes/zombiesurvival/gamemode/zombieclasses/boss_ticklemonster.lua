-- ============================================================================
-- 挠痒怪 (The Tickle Monster) — BOSS僵尸职业
-- 特点：高血量、大型碰撞体积、可嘲讽、无腿部/头部伤害判定、
--       手臂伸缩攻击效果（攻击时手臂变长）、死亡掉落武器箱
-- ============================================================================

-- 职业显示名称
CLASS.Name = "The Tickle Monster"
-- 翻译键名
CLASS.TranslationName = "class_the_tickle_monster"
-- 描述文本键名
CLASS.Description = "description_the_tickle_monster"
-- 控制帮助文本键名
CLASS.Help = "controls_the_tickle_monster"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 3000
-- 移动速度
CLASS.Speed = 155

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 可嘲讽
CLASS.CanTaunt = true

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_ticklemonster"

-- 主模型（经典僵尸修复版）
CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")
-- 覆盖模型（快速僵尸）
CLASS.OverrideModel = Model("models/player/zombie_fast.mdl")

-- 语音音调
CLASS.VoicePitch = 0.8

-- 受伤/死亡音效
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 视角偏移和碰撞体积（大型）
CLASS.ViewOffset = Vector(0, 0, 80)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 50)
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 86)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 48)}

-- 缓存函数
local math_random = math.random
local math_Approach = math.Approach
local math_min = math.min
local math_ceil = math.ceil
local math_Clamp = math.Clamp
local CurTime = CurTime

-- 缓存常量和动画
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE

-- 脚步声和摩擦声列表
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

-- 自定义脚步声（15%概率播放摩擦声）
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random() < 0.15 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 70)
	else
		pl:EmitSound(StepSounds[math_random(#StepSounds)], 70)
	end
	return true
end

-- 缩放伤害（不做调整）
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

-- 忽略腿部伤害
function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

-- 脚步音效间隔时间
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

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
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

-- 更新动画速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
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

-- 服务端逻辑：生成时播放环境音效
if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("ticklemonsterambience")
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/tickle"

-- 脊椎偏移量
local vecSpineOffset = Vector(8, 0, 0)
local SpineBones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine3"}

-- 构建骨骼位置：偏移脊椎并伸缩手臂
function CLASS:BuildBonePositions(pl)
	-- 偏移脊椎骨骼
	for _, bone in pairs(SpineBones) do
		local spineid = pl:LookupBone(bone)
		if spineid and spineid > 0 then
			pl:ManipulateBonePosition(spineid, vecSpineOffset)
		end
	end

	-- 根据攻击状态伸缩前臂骨骼
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetSwingEndTime then
		local desiredscale
		if wep:GetSwingEndTime() > 0 then
			desiredscale = 2 + (1 - math_Clamp((wep:GetSwingEndTime() - CurTime()) / wep.MeleeDelay, 0, 1)) * 10
		else
			desiredscale = 2
		end
		pl.m_TMArmLength = math_Approach(pl.m_TMArmLength or 2, desiredscale, FrameTime() * 10)

		local larmid = pl:LookupBone("ValveBiped.Bip01_L_Forearm")
		if larmid and larmid > 0 then
			pl:ManipulateBoneScale(larmid, Vector(pl.m_TMArmLength, 2, 2))
		end
		local rarmid = pl:LookupBone("ValveBiped.Bip01_R_Forearm")
		if rarmid and rarmid > 0 then
			pl:ManipulateBoneScale(rarmid, Vector(pl.m_TMArmLength, 2, 2))
		end
	end
end
