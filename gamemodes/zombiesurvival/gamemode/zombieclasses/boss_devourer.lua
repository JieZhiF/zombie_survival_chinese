--[[
==================================================================
吞噬者 (Devourer) — BOSS僵尸职业
特点：骷髅模型叠加肉尸模型、肌肉骨骼放大效果、免疫击退、
      自定义动画（小刀动作）、死亡掉落武器箱
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Devourer"
-- 翻译键名
CLASS.TranslationName = "class_devourer"
-- 描述文本键名
CLASS.Description = "description_devourer"
-- 控制帮助文本键名
CLASS.Help = "controls_devourer"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 2600
-- 移动速度
CLASS.Speed = 160

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_devourer"

-- 主模型（烧焦尸体）
CLASS.Model = Model("models/player/charple.mdl")
-- 覆盖模型（骷髅）
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 不隐藏主模型（两个模型同时显示）
CLASS.NoHideMainModel = true

-- 语音音调
CLASS.VoicePitch = 0.65

-- 受伤音效列表
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效列表
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 标记为骷髅类僵尸
CLASS.Skeletal = true

-- 缓存函数和变量
local math_random = math.random
local math_min = math.min
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

-- 计算主要活动动画（使用小刀动作集）
function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end

	local len = velocity:Length2DSqr()
	-- 静止状态
	if len <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_FIST, -1
		end
		return ACT_HL2MP_IDLE_KNIFE, -1
	end

	-- 蹲下行走
	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_KNIFE, -1
	end

	-- 根据速度选择步行或奔跑
	if len < 2800 then
		return ACT_HL2MP_WALK_KNIFE, -1
	end
	return ACT_HL2MP_RUN_KNIFE, -1
end

-- 更新动画播放速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length()
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
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)
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
		pl:CreateAmbience("devourerambience")
	end
end

-- 脊椎偏移量
local vecSpineOffset = Vector(1, 3, 0)
-- 需要放大肌肉的骨骼列表及缩放值
local MuscularBones = {
	["ValveBiped.Bip01_R_Upperarm"] = Vector(1, 2, 3.5),
	["ValveBiped.Bip01_R_Forearm"] = Vector(1, 2.5, 3),
	["ValveBiped.Bip01_L_Upperarm"] = Vector(1, 2, 3.5),
	["ValveBiped.Bip01_L_Forearm"] = Vector(1, 2.5, 3),
	["ValveBiped.Bip01_L_Hand"] = Vector(1, 2, 4),
	["ValveBiped.Bip01_R_Hand"] = Vector(1, 2, 4),
	["ValveBiped.Bip01_L_Thigh"] = Vector(1, 2, 3),
	["ValveBiped.Bip01_R_Thigh"] = Vector(1, 2, 3),
	["ValveBiped.Bip01_L_Calf"] = Vector(1, 2, 3),
	["ValveBiped.Bip01_R_Calf"] = Vector(1, 2, 3),
	["ValveBiped.Bip01_L_Foot"] = Vector(1, 2, 3),
	["ValveBiped.Bip01_R_Foot"] = Vector(1, 2, 3),
}
-- 需要位移的脊椎骨骼列表
local SpineBones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Neck1"}

-- 构建骨骼位置：拉伸脊椎并放大肌肉
function CLASS:BuildBonePositions(pl)
	-- 位移脊椎骨骼
	for _, bone in pairs(SpineBones) do
		local boneid = pl:LookupBone(bone)
		if boneid and boneid > 0 then
			pl:ManipulateBonePosition(boneid, vecSpineOffset)
		end
	end

	-- 放大肌肉骨骼
	for bonename, newscale in pairs(MuscularBones) do
		local boneid = pl:LookupBone(bonename)
		if boneid and boneid > 0 then
			pl:ManipulateBoneScale(boneid, newscale)
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/devourer"

-- 肉材质和黑色材质
local matFlesh = Material("models/flesh")
local matBlack = CreateMaterial("devourer", "UnlitGeneric", {["$basetexture"] = "Tools/toolsblack", ["$model"] = 1})

-- 主模型绘制前：覆盖为肉材质并调色
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matFlesh)
	render.SetColorModulation(0.45, 0.35, 0.05)
end

-- 主模型绘制后恢复
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end

-- 覆盖模型绘制前：使用黑色材质
function CLASS:PrePlayerDrawOverrideModel(pl)
	render.ModelMaterialOverride(matBlack)
end

-- 覆盖模型绘制后恢复
function CLASS:PostPlayerDrawOverrideModel(pl)
	render.ModelMaterialOverride(nil)
end

-- 服务端逻辑：死亡掉落武器箱
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
end
