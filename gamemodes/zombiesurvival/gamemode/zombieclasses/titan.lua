--[[
==================================================================
泰坦 (Titan) — 僵尸职业
特点：高血量、大型模型、高跳跃力、可嘲讽、不可装死、
      缓慢笨重动画（速度减半）、重型脚步声、自定义手部模型
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Titan"
-- 翻译键名（语言系统中的名字）
CLASS.TranslationName = "class_titan"
-- 描述文本键名（语言系统中的角色设定和描述）
CLASS.Description = "description_titan"
-- 控制帮助文本键名（语言系统中的角色教程）
CLASS.Help = "controls_titan"

-- 生命值/速度
CLASS.Health = 600
CLASS.Speed = 120
-- 击杀得分
CLASS.Points = 25

-- 绑定的武器
CLASS.SWEP = "weapon_zs_titan"

-- 经典僵尸模型
CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")

-- 出现波次
CLASS.Wave = 5 / 6

-- 无摔落伤害
CLASS.NoFallDamage = true
-- 未解锁
CLASS.Unlocked = false
-- 不可装死
CLASS.CanFeignDeath = false
-- 可嘲讽
CLASS.CanTaunt = true
CLASS.Hidden = true
-- 语音音调
CLASS.VoicePitch = 1.0

-- 大型模型
CLASS.ModelScale = 1.45

-- 物理/碰撞属性
CLASS.Mass = 500
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
CLASS.StepSize = 25
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}

-- 缓存函数
local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local CurTime = CurTime

local DIR_BACK = DIR_BACK
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE

-- 脚步声
local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 77, 50)
	if iFoot == 0 then
		pl:EmitSound("^npc/strider/strider_step4.wav", 90, math_random(90, 110))
	else
		pl:EmitSound("^npc/strider/strider_step5.wav", 90, math_random(90, 110))
	end
	return true
end

-- 死亡/受伤音效
function CLASS:PlayDeathSound(pl)
	local pitch = math_random(60, 70)
	for i=1, 2 do
		pl:EmitSound("ambient/creatures/town_child_scream1.wav", 75, pitch)
	end
	return true
end

function CLASS:PlayPainSound(pl)
	pl:EmitSound("ambient/voices/citizen_beaten"..math_random(5)..".wav", 70, math_random(50, 60))
	pl.NextPainSound = CurTime() + 1.25
	return true
end

-- 活动动画
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

-- 脚步间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE.BaseClass, pl, iType, bWalking) * 1.8
end

-- 更新动画（整体速度减半）
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
    -- 死亡时假死并掉落武器箱
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
        pl:FakeDeath(pl:LookupSequence("death_0"..math.random(4)), self.ModelScale)
        local pos = pl:LocalToWorld(pl:OBBCenter())
        local ent = ents.Create("prop_weapon")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:SetAngles(AngleRand())
            ent:SetWeaponType("weapon_zs_box")
            ent:Spawn()
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
                phys:AddAngleVelocity(VectorRand() * 200)
            end
        end
        return true
    end

    -- 死后切回默认僵尸职业
    function CLASS:PostOnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
        pl:SetZombieClass(GAMEMODE.DefaultZombieClass)
    end

    -- 备用使用键（当前为空）
    function CLASS:AltUse(pl)
    end

    -- 生成时创建自定义手部
    function CLASS:OnSpawned(pl)
        local oldhands = pl:GetHands()
        if IsValid(oldhands) then
            oldhands:Remove()
        end
        local hands = ents.Create("zs_hands")
        if IsValid(hands) then
            hands:DoSetup(pl)
            hands:Spawn()
        end
    end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/zombie"

local render_ModelMaterialOverride = render.ModelMaterialOverride
local matSheet = Material("models/props_c17/doll01")
function CLASS:DrawHands(pl, hands)
	render_ModelMaterialOverride(matSheet)
	hands:DrawModel()
	render_ModelMaterialOverride(nil)
	return true
end
