--[[
==================================================================
血块小子 (Gore Child) — 僵尸职业
特点：娃娃模型、极小体型、极低血量、速度慢、可装死、
      可嘲讽、死亡时播放假死动画、自定义手部模型
==================================================================
]]

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/gigagorechild"
-- 职业显示名称
CLASS.Name = "Gore Child"
-- 翻译键名
CLASS.TranslationName = "class_gore_child"
-- 描述文本键名
CLASS.Description = "description_gore_child"
-- 控制帮助文本键名
CLASS.Help = "controls_gore_child"

-- 初始可用/隐藏
CLASS.Wave = 0
CLASS.Unlocked = true
CLASS.Hidden = true

-- 生命值
CLASS.Health = 20
-- 移动速度
CLASS.Speed = 150

-- 击杀得分
CLASS.Points = 0.5

-- 可嘲讽
CLASS.CanTaunt = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_gorechild"

-- 娃娃模型
CLASS.Model = Model("models/vinrax/player/doll_player.mdl")

-- 语音音调（高音）
CLASS.VoicePitch = 1.5

-- 模型缩放（极小）
CLASS.ModelScale = 0.4

-- 物理/碰撞属性
CLASS.Mass = 30
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
CLASS.StepSize = 8
CLASS.Hull = {Vector(-16, -16, 0) * CLASS.ModelScale, Vector(16, 16, 100) * CLASS.ModelScale}
CLASS.HullDuck = {Vector(-16, -16, 0) * CLASS.ModelScale, Vector(16, 16, 60) * CLASS.ModelScale}

-- 可装死
CLASS.CanFeignDeath = true

-- 缓存函数
local CurTime = CurTime
local math_random = math.random
local math_max = math.max
local math_min = math.min
local math_ceil = math.ceil

-- 缓存动画常量
local DIR_BACK = DIR_BACK
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE

-- 脚步声
local StepLeftSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[math_random(#StepLeftSounds)], 55, 150)
	else
		pl:EmitSound(StepRightSounds[math_random(#StepRightSounds)], 55, 150)
	end
	return true
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
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetSwinging then return end

	if wep:GetSwinging() then
		if not pl.PlayingFZSwing then
			pl.PlayingFZSwing = true
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_FRENZY)
		end
	elseif pl.PlayingFZSwing then
		pl.PlayingFZSwing = false
		pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
	end

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

	if len2d >= 16 then
		pl:SetPlaybackRate(pl:GetPlaybackRate() * 2)
	end
	return true
end

-- 脚步时间间隔（缩短）
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE.BaseClass, pl, iType, bWalking) * 0.4
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
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

-- 自定义受伤音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("ambient/creatures/teddy.wav", 65, math_random(140, 150))
	pl.NextPainSound = CurTime() + 0.5
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("ambient/voices/citizen_beaten"..math_random(5)..".wav", 70, math_random(140, 150))
	return true
end

-- 服务端逻辑
if SERVER then
	-- 死亡时假死
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:FakeDeath(pl:LookupSequence("death_0"..math_random(4)), self.ModelScale)
		return true
	end

	-- 死亡后切回默认职业
	function CLASS:PostOnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:SetZombieClass(GAMEMODE.DefaultZombieClass)
	end

	-- 备用使用键装死
	function CLASS:AltUse(pl)
		pl:StartFeignDeath()
	end

	-- 生成时创建自定义手部
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
CLASS.Icon = "zombiesurvival/killicons/gorechild"

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
