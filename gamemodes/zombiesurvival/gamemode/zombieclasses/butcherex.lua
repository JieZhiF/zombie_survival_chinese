--[[
==================================================================
屠夫EX (The Butcher ex) — 进阶僵尸职业
特点：较低的波次出现、免疫击退、可嘲讽、
      自定义步行/攻击动画、红色发光眼睛
==================================================================
]]

-- 职业显示名称
CLASS.Name = "The Butcher ex"
-- 翻译键名
CLASS.TranslationName = "class_butcherex"
-- 描述文本键名
CLASS.Description = "description_butcherex"
-- 控制帮助文本键名
CLASS.Help = "controls_butcherex"

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 730
-- 移动速度
CLASS.Speed = 220

-- 出现波次
CLASS.Wave = 3 / 6
-- 隐藏职业
CLASS.Hidden = true
-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 绑定的武器（屠夫刀EX版）
CLASS.SWEP = "weapon_zs_butcherknifz_ex"

-- 使用尸体模型
CLASS.Model = Model("models/player/corpse1.mdl")

-- 语音音调
CLASS.VoicePitch = 0.65

-- 受伤/死亡音效
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 缓存函数
local math_random = math.random
local math_min = math.min
local CurTime = CurTime

-- 缓存动画常量
local ACT_HL2MP_SWIM_MELEE = ACT_HL2MP_SWIM_MELEE
local ACT_HL2MP_IDLE_CROUCH_MELEE = ACT_HL2MP_IDLE_CROUCH_MELEE
local ACT_HL2MP_WALK_CROUCH_MELEE = ACT_HL2MP_WALK_CROUCH_MELEE
local ACT_HL2MP_IDLE_MELEE = ACT_HL2MP_IDLE_MELEE
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_HL2MP_RUN_MELEE = ACT_HL2MP_RUN_MELEE

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

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_MELEE, -1
	end

	if pl:Crouching() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_MELEE, -1
		end
		return ACT_HL2MP_WALK_CROUCH_MELEE, -1
	end

	local swinging = false
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and CurTime() < wep:GetNextPrimaryFire() then
		swinging = true
	end

	if velocity:Length2DSqr() <= 1 then
		if swinging then
			return ACT_HL2MP_IDLE_MELEE, -1
		end
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

	if swinging then
		return ACT_HL2MP_RUN_MELEE, -1
	end
	return ACT_HL2MP_RUN_ZOMBIE, -1
end

-- 更新动画速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 0.5 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 服务端逻辑：生成时播放环境音效
if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("butcherambience")
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/butcher"

-- 渲染变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

local colGlow = Color(235, 50, 0)
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前颜色调制
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(1, 0.5, 0.5)
end

-- 绘制后恢复并绘制发光眼睛
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
