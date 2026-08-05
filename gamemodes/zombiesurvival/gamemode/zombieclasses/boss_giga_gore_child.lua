--[[
==================================================================
巨型血块小子 (Giga Gore Child) — BOSS僵尸职业
特点：高血量、可装死、可嘲讽、恐惧免疫（装死时）、
      娃娃模型、哭声减速、自定义死亡动画、踢腿攻击
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Giga Gore Child"
-- 翻译键名
CLASS.TranslationName = "class_giga_gore_child"
-- 描述文本键名
CLASS.Description = "description_giga_gore_child"
-- 控制帮助文本键名
CLASS.Help = "controls_giga_gore_child"

-- 非正式BOSS（隐藏）
CLASS.Boss = false
-- 迷你BOSS（通过僵尸商店购买获得）
CLASS.MiniBoss = true
-- 隐藏职业
CLASS.Hidden = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 2500
-- 移动速度
CLASS.Speed = 230

-- 击杀得分
CLASS.Points = 40

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 绑定的武器
CLASS.SWEP = "weapon_zs_gigagorechild"

-- 使用娃娃模型
CLASS.Model = Model("models/vinrax/player/doll_player.mdl")

-- 语音音调
CLASS.VoicePitch = 1

-- 模型缩放
CLASS.ModelScale = 1.3

-- 可装死
CLASS.CanFeignDeath = true

-- 质量
CLASS.Mass = 500
-- 视角偏移
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
-- 步高
CLASS.StepSize = 25
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}

-- 缓存函数和变量
local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local CurTime = CurTime

-- 缓存常量和动画
local DIR_BACK = DIR_BACK
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE

-- 脚步声列表
local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

-- 自定义脚步声（普通脚步+重型地面震动声）
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 77, 50)

	if iFoot == 0 then
		pl:EmitSound("^npc/strider/strider_step4.wav", 90, math_random(90, 110))
	else
		pl:EmitSound("^npc/strider/strider_step5.wav", 90, math_random(90, 110))
	end
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	local pitch = math_random(60, 70)
	for i=1, 2 do
		pl:EmitSound("ambient/creatures/town_child_scream1.wav", 75, pitch)
	end
	return true
end

-- 自定义受伤音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("ambient/voices/citizen_beaten"..math_random(5)..".wav", 70, math_random(50, 60))
	pl.NextPainSound = CurTime() + 1.25
	return true
end

-- 计算主要活动动画（处理装死/游泳/蹲下）
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

	if pl:Crouching() and pl:OnGround() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end

	return ACT_HL2MP_RUN_ZOMBIE, -1
end

-- 移动逻辑：哭泣时减速
function CLASS:Move(pl, move)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsCrying and wep:IsCrying() then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.5)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.5)
		return true
	end
end

-- 脚步音效间隔时间（延长1.8倍）
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE.BaseClass, pl, iType, bWalking) * 1.8
end

-- 更新动画播放速率
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
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end

	-- 整体动画速度减半（笨重感）
	pl:SetPlaybackRate(pl:GetPlaybackRate() * 0.5)
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:DoZombieAttackAnim(data)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_THROW, true)
		return ACT_INVALID
	end
end

-- 装死时不产生恐惧
function CLASS:DoesntGiveFear(pl)
	return pl.FeignDeath and pl.FeignDeath:IsValid()
end

-- 服务端逻辑
if SERVER then
	-- 死亡时播放假死动画
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:FakeDeath(pl:LookupSequence("death_0"..math.random(4)), self.ModelScale)
		return true
	end

	-- 死亡后切换为默认僵尸职业
	function CLASS:PostOnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:SetZombieClass(GAMEMODE.DefaultZombieClass)
	end

	-- 备用使用键触发装死
	function CLASS:AltUse(pl)
		pl:StartFeignDeath()
	end

	-- 生成时：移除默认手部模型并创建自定义手部
	function CLASS:OnSpawned(pl)
		local oldhands = pl:GetHands()
		if IsValid(oldhands) then
			oldhands:Remove()
		end

		local hands = ents.Create("zs_hands")
		if hands:IsValid() then
			hands:DoSetup(pl)
			hands:Spawn()
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/gigagorechild"

local render_ModelMaterialOverride = render.ModelMaterialOverride

-- 手部材质（娃娃材质）
local matSheet = Material("models/props_c17/doll01")

-- 自定义手部绘制
function CLASS:DrawHands(pl, hands)
	render_ModelMaterialOverride(matSheet)
	hands:DrawModel()
	render_ModelMaterialOverride(nil)
	return true
end
