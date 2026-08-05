-- ============================================================================
-- 骨网 (Bonemesh) — BOSS僵尸职业
-- 特点：高血量、免疫击退、脚步声厚重（蚁狮守卫音效）、可嘲讽、
--       无头部判定、无视腿部伤害、死亡掉落武器箱、生成时播放环境音效
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Bonemesh"
-- 翻译键名
CLASS.TranslationName = "class_bonemesh"
-- 描述文本键名
CLASS.Description = "description_bonemesh"
-- 控制帮助文本键名
CLASS.Help = "controls_bonemesh"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 可嘲讽
CLASS.CanTaunt = true

-- 生命值
CLASS.Health = 2400
-- 移动速度
CLASS.Speed = 195

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 35

-- 绑定的武器
CLASS.SWEP = "weapon_zs_bonemesh"

-- 主模型（快速僵尸）
CLASS.Model = Model("models/player/zombie_fast.mdl")
-- 覆盖模型（毒僵尸）
CLASS.OverrideModel = Model("models/Zombie/Poison.mdl")

-- 语音音调
CLASS.VoicePitch = 0.8

-- 碰撞体积（站立）
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
-- 视角偏移（站立）
CLASS.ViewOffset = Vector(0, 0, 50)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 24)

-- 受伤音效列表
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效列表
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 缓存随机函数
local math_random = math.random

-- 缓存脚步时间常量
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE
-- 缓存动作常量
local ACT_ZOMBIE_LEAPING = ACT_ZOMBIE_LEAPING
local ACT_HL2MP_RUN_ZOMBIE_FAST = ACT_HL2MP_RUN_ZOMBIE_FAST

-- 自定义脚步声：蚁狮守卫的重踏音效
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound("npc/antlion_guard/foot_light1.wav", 70, math_random(115, 120))
	else
		pl:EmitSound("npc/antlion_guard/foot_light2.wav", 70, math_random(115, 120))
	end
	return true
end

-- 自定义脚步音效间隔时间
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

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	-- 空中或深水时播放跳跃动画
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		return ACT_ZOMBIE_LEAPING, -1
	end
	return ACT_HL2MP_RUN_ZOMBIE_FAST, -1
end

-- 更新动画播放速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	-- 空中动画循环
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl:SetPlaybackRate(1)
		if pl:GetCycle() >= 1 then
			pl:SetCycle(pl:GetCycle() - 1)
		end
		return true
	end
end

-- 缩放伤害（不做调整）
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

-- 忽略腿部伤害
function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
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

-- 服务端逻辑
if SERVER then
    -- 当僵尸被杀死时
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
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
    
    -- 生成时播放环境音效
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("bonemeshambience")
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/bonemesh"
