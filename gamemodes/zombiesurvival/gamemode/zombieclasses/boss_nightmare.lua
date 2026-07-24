--[[
==================================================================
梦魇 (Nightmare) — BOSS僵尸职业
特点：高速移动、免疫击退、可嘲讽、随机骨骼扭曲效果、 
      死亡掉落武器箱、深色渲染
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Nightmare"
-- 翻译键名
CLASS.TranslationName = "class_nightmare"
-- 描述文本键名
CLASS.Description = "description_nightmare"
-- 控制帮助文本键名
CLASS.Help = "controls_nightmare"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 2600
-- 移动速度
CLASS.Speed = 280

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_nightmare"

-- 主模型（经典僵尸修复版）
CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")
-- 覆盖模型（烧焦尸体）
CLASS.OverrideModel = Model("models/player/charple.mdl")

-- 语音音调
CLASS.VoicePitch = 0.65

-- 受伤/死亡音效列表
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 缓存函数
local math_random = math.random
local math_Rand = math.Rand
local math_min = math.min
local math_ceil = math.ceil
local CurTime = CurTime

-- 缓存动画常量
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

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 70)
	return true
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
		pl:DoZombieAttackAnim(data)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 服务端逻辑
if SERVER then
	-- 生成时播放环境音效
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("nightmareambience")
	end

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
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/nightmare2"

-- 创建随机骨骼偏移数据
local function CreateBoneOffsets(pl)
	pl.m_NightmareBoneOffsetsNext = CurTime() + math_Rand(0.02, 0.1)

	local offsets = {}
	local angs = {}
	for i=1, pl:GetBoneCount() - 1 do
		if math_random(3) == 3 then
			offsets[i] = VectorRand():GetNormalized() * math.Rand(0.5, 3)
		end
		if math_random(5) == 5 then
			angs[i] = Angle(math_Rand(-5, 5), math_Rand(-15, 15), math_Rand(-5, 5))
		end
	end
	pl.m_NightmareBoneOffsets = offsets
	pl.m_NightmareBoneAngles = angs
end

-- 构建骨骼位置：随机扭曲骨骼制造恐怖效果
function CLASS:BuildBonePositions(pl)
	if not pl.m_NightmareBoneOffsets or CurTime() >= pl.m_NightmareBoneOffsetsNext then
		CreateBoneOffsets(pl)
	end

	local offsets = pl.m_NightmareBoneOffsets
	local angs = pl.m_NightmareBoneAngles
	for i=1, pl:GetBoneCount() - 1 do
		if offsets[i] then
			pl:ManipulateBonePosition(i, offsets[i])
		end
		if angs[i] then
			pl:ManipulateBoneAngles(i, angs[i])
		end
	end
end

-- 绘制前深色渲染
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0.1, 0.1, 0.1)
end

-- 绘制后恢复
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
end
