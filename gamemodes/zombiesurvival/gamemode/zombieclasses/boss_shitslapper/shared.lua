-- ============================================================================
-- boss_shitslapper/shared.lua - 屎掌拍 (Shit Slapper) 小BOSS 共享定义
-- 负责：职业属性、巨型躯干模型、免疫击退、巨型脚步声与动画速率
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Shit Slapper"
-- 翻译键名
CLASS.TranslationName = "class_shitslapper"
-- 描述文本键名
CLASS.Description = "description_shitslapper"
-- 控制帮助文本键名
CLASS.Help = "controls_shitslapper"

-- 躯干模型（放大显示）
CLASS.Model = Model("models/Zombie/Classic_torso.mdl")

-- 非普通BOSS
CLASS.Boss = false
-- 小BOSS标记（可在僵尸商店购买）
CLASS.MiniBoss = true
-- 隐藏职业（不在常规职业列表中显示）
CLASS.Hidden = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 40

-- 绑定的武器
CLASS.SWEP = "weapon_zs_shitslapper"

-- 生命值
CLASS.Health = 4000
-- 移动速度
CLASS.Speed = 225
-- 跳跃力
CLASS.JumpPower = 200

-- 模型缩放（1.75 倍巨型躯干）
CLASS.ModelScale = 1.75
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}
-- 视角偏移（随模型缩放）
CLASS.ViewOffset = Vector(0, 0, 14 * CLASS.ModelScale)
CLASS.ViewOffsetDucked = Vector(0, 0, 14 * CLASS.ModelScale)
-- 台阶跨越高度
CLASS.StepSize = 25
-- 蹲伏行走速度倍率
CLASS.CrouchedWalkSpeed = 1
-- 质量（随体型增大）
CLASS.Mass = DEFAULT_MASS * CLASS.ModelScale * 0.5

-- 无法主动蹲伏
CLASS.CantDuck = true

-- 缓存随机数与时间函数
local math_random = math.random
local CurTime = CurTime

-- 缓存行走动画常量
local ACT_WALK = ACT_WALK

-- ==== PlayPainSound - 播放受伤音效（带 0.5 秒冷却） ====
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 75, math_random(70, 80))

	pl.NextPainSound = CurTime() + .5

	return true
end

-- ==== PlayDeathSound - 播放死亡音效 ====
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/zombie/zombie_die"..math_random(3)..".wav", 70, math_random(70, 80))

	return true
end

-- ==== PlayerStepSoundTime - 脚步音效间隔按模型缩放倍数放大 ====
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE.BaseClass, pl, iType, bWalking) * self.ModelScale
end

-- 脚步音效列表
local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

-- ==== PlayerFootstep - 播放沉重脚步音效并叠加巨型机械脚步低音 ====
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)

	-- 普通脚步音效（低音调）
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 77, 50)

	-- 左右脚交替播放巨型脚步轰鸣
	if iFoot == 0 then
		pl:EmitSound("^npc/strider/strider_step4.wav", 90, math_random(95, 115))
	else
		pl:EmitSound("^npc/strider/strider_step5.wav", 90, math_random(95, 115))
	end

	return true
end

-- ==== UpdateAnimation - 巨型体型下按移动速度缩放动画播放速率 ====
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 1 then
		-- 移动时按速度与体型调整播放速率（上限 3 倍）
		pl:SetPlaybackRate(math.min(len2d / maxseqgroundspeed * 0.25 / self.ModelScale, 3))
	else
		-- 静止时按体型放慢
		pl:SetPlaybackRate(1 / self.ModelScale)
	end

	return true
end

-- ==== CalcMainActivity - 计算主要活动动画（静止时用自定义帧，移动时用行走动画） ====
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return 1, 1
	end

	return ACT_WALK, -1
end

-- ==== DoAnimationEvent - 处理主攻击动画事件（播放近战攻击手势） ====
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end
