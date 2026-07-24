--[[
==================================================================
嚎叫者 (Howler) — BOSS僵尸职业
特点：高血量、大型模型、无腿部/头部受伤判定、可嘲讽、
      战吼减伤50%、死亡掉落武器箱、自定义死亡/受伤音效
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Howler"
-- 翻译键名
CLASS.TranslationName = "class_howler"
-- 描述文本键名
CLASS.Description = "description_howler"
-- 控制帮助文本键名
CLASS.Help = "controls_howler"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 可嘲讽
CLASS.CanTaunt = true

-- 击杀得分
CLASS.Points = 40

-- 绑定的武器
CLASS.SWEP = "weapon_zs_howler"

-- 主模型（经典僵尸修复版）
CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")
-- 覆盖模型（撕裂者2）
CLASS.OverrideModel = Model("models/player/zombie_lacerator2.mdl")

-- 生命值
CLASS.Health = 3300
-- 移动速度
CLASS.Speed = 180

-- 语音音调
CLASS.VoicePitch = 0.65

-- 模型缩放
CLASS.ModelScale = 1.2
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}
-- 视角偏移
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
-- 步高
CLASS.StepSize = 25
-- 质量
CLASS.Mass = DEFAULT_MASS * CLASS.ModelScale

-- 缓存函数和变量
local math_random = math.random
local math_min = math.min
local math_ceil = math.ceil
local CurTime = CurTime

-- 缓存常量和动画
local DIR_BACK = DIR_BACK
local ACT_INVALID = ACT_INVALID
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_ZOMBIE = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
local ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE

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
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE.BaseClass, pl, iType, bWalking) * 1.8
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/antlion_guard/antlion_guard_die"..math_random(2)..".wav", 100, math_random(80, 90))
	return true
end

-- 自定义受伤音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/combine_gunship/gunship_pain.wav", 75, math_random(85, 95))
	pl.NextPainSound = CurTime() + 1.5
	return true
end

-- 脚步声列表
local StepSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 77, 50)

	if iFoot == 0 then
		pl:EmitSound("^npc/strider/strider_step4.wav", 90, math_random(95, 115))
	else
		pl:EmitSound("^npc/strider/strider_step5.wav", 90, math_random(95, 115))
	end
	return true
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	elseif pl:Crouching() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		else
			return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math_ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
		end
	else
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end
	return true
end

-- 更新动画播放速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5 , 3))
	else
		pl:SetPlaybackRate(1 / self.ModelScale)
	end
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 服务端逻辑
if SERVER then
	-- 伤害处理：战吼期间减伤50%
	function CLASS:ProcessDamage(pl, dmginfo)
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.GetBattlecry and wep:GetBattlecry() > CurTime() then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)
		end
	end

	-- 死亡时播放假死动画并掉落武器箱
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		local fakedeath = pl:FakeDeath(234, self.ModelScale)
		if fakedeath and fakedeath:IsValid() then
			fakedeath:SetModel(self.OverrideModel)
		end
		
        -- 掉落武器
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
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/howler"
