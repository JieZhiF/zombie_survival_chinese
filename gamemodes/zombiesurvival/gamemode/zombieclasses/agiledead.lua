--[[
==================================================================
敏捷僵尸 (Agile Dead) — 僵尸职业
继承自：freshdead
特点：速度快、可爬墙、无腿部受伤判定，使用玩家模型的敏捷型僵尸
==================================================================
]]

-- 基础职业为"freshdead"
CLASS.Base = "freshdead"

-- 职业显示名称
CLASS.Name = "Agile Dead"
-- 翻译键名（用于多语言系统）
CLASS.TranslationName = "class_agile_dead"
-- 描述文本键名
CLASS.Description = "description_agile_dead"
-- 控制帮助文本键名
CLASS.Help = "controls_agile_dead"

-- 该职业的进阶版本
CLASS.BetterVersion = "Fast Zombie"

-- 绑定的武器
CLASS.SWEP = "weapon_zs_agiledead"

-- 初始解锁
CLASS.Unlocked = true

-- 生命值
CLASS.Health = 125
-- 击杀得分 = 生命值 / 无头箱判定比率
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio
-- 移动速度
CLASS.Speed = 220

-- 碰撞体积（站立）
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
-- 视角偏移（站立）
CLASS.ViewOffset = Vector(0, 0, 50)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

-- 使用玩家模型
CLASS.UsePlayerModel = true
-- 不使用之前的模型
CLASS.UsePreviousModel = false

-- 服务端逻辑
if SERVER then
	-- 被击杀时不做特殊处理
	function CLASS:OnKilled() end
end

-- 缓存常用动作常量以提高性能
local ACT_ZOMBIE_LEAPING = ACT_ZOMBIE_LEAPING
local ACT_HL2MP_RUN_ZOMBIE_FAST = ACT_HL2MP_RUN_ZOMBIE_FAST
local ACT_ZOMBIE_CLIMB_UP = ACT_ZOMBIE_CLIMB_UP
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
local ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL = ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL
local ACT_INVALID = ACT_INVALID

-- 缓存数学函数
local math_Clamp = math.Clamp
local math_min = math.min

-- 服务端逻辑
if SERVER then
	-- 备用使用键（无特殊功能）
	function CLASS:AltUse(pl) end
	-- 被击杀时不做特殊处理
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end
end

-- 移动逻辑：处理武器移动和后退减速
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end

	-- 后退时限制速度
	if mv:GetForwardSpeed() <= 0 then
		mv:SetMaxSpeed(math_min(mv:GetMaxSpeed(), 120))
		mv:SetMaxClientSpeed(math_min(mv:GetMaxClientSpeed(), 120))
	end
end

-- 伤害缩放（不做调整）
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
	-- 爬墙动画
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end

	-- 空中或深水时播放跳跃动画
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		return ACT_ZOMBIE_LEAPING, -1
	end

	-- 地面奔跑动画
	return ACT_HL2MP_RUN_ZOMBIE_FAST, -1
end

-- 更新动画播放速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	-- 爬墙动画速率
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		local vel = pl:GetVelocity()
		local speed = vel:LengthSqr()
		if speed > 64 then
			pl:SetPlaybackRate(math_Clamp(speed / 3600, 0, 1) * (vel.z < 0 and -1 or 1) * 0.25)
		else
			pl:SetPlaybackRate(0)
		end
		return true
	end

	-- 空中动画循环
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl:SetPlaybackRate(1)
		if pl:GetCycle() >= 1 then
			pl:SetCycle(pl:GetCycle() - 1)
		end
		return true
	end
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	-- 主攻击动画
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
		return ACT_INVALID
	-- 装弹/嘲讽动画
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fresh_dead"
