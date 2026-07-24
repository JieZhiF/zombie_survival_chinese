--[[
==================================================================
怨灵 (Wraith) — 僵尸职业
特点：透明隐形效果、根据视角和距离动态调节透明度、
      无阴影、无脚步声、机械血液、使用小刀动作集、
      按住速度键减速、死亡时触发暗影特效
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Wraith"
-- 翻译键名
CLASS.TranslationName = "class_wraith"
-- 描述文本键名
CLASS.Description = "description_wraith"
-- 控制帮助文本键名
CLASS.Help = "controls_wraith"

-- 进阶版本
CLASS.BetterVersion = "Tormented Wraith"

-- 初始可用
CLASS.Wave = 0
CLASS.Unlocked = true

-- 生命值
CLASS.Health = 135

-- 绑定的武器
CLASS.SWEP = "weapon_zs_wraith"
-- 追踪者模型
CLASS.Model = Model("models/player/zelpa/stalker.mdl")
-- 速度
CLASS.Speed = 150

-- 可嘲讽
CLASS.CanTaunt = true

-- 击杀得分
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio

-- 语音音调
CLASS.VoicePitch = 0.65

-- 受伤/死亡音效
CLASS.PainSounds = {Sound("npc/barnacle/barnacle_pull1.wav"), Sound("npc/barnacle/barnacle_pull2.wav"), Sound("npc/barnacle/barnacle_pull3.wav"), Sound("npc/barnacle/barnacle_pull4.wav")}
CLASS.DeathSounds = {Sound("zombiesurvival/wraithdeath1.ogg"), Sound("zombiesurvival/wraithdeath2.ogg"), Sound("zombiesurvival/wraithdeath3.ogg"), Sound("zombiesurvival/wraithdeath4.ogg")}

-- 无阴影/无视目标辅助/半透明渲染
CLASS.NoShadow = true
CLASS.IgnoreTargetAssist = true
CLASS.RenderMode = RENDERMODE_TRANSALPHA

-- 机械血液
CLASS.BloodColor = BLOOD_COLOR_MECH

-- 缓存函数和变量
local math_min = math.min
local math_Clamp = math.Clamp
local IN_SPEED = IN_SPEED
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_FIST = ACT_HL2MP_IDLE_CROUCH_FIST
local ACT_HL2MP_IDLE_KNIFE = ACT_HL2MP_IDLE_KNIFE
local ACT_HL2MP_WALK_CROUCH_KNIFE = ACT_HL2MP_WALK_CROUCH_KNIFE
local ACT_HL2MP_WALK_KNIFE = ACT_HL2MP_WALK_KNIFE
local ACT_HL2MP_RUN_KNIFE = ACT_HL2MP_RUN_KNIFE
local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY
local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD
local ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL = ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
local ACT_INVALID = ACT_INVALID

-- 移动逻辑：按住速度键减速
function CLASS:Move(pl, move)
	if pl:KeyDown(IN_SPEED) then
		move:SetMaxSpeed(40)
		move:SetMaxClientSpeed(40)
	end
end

-- 活动动画（小刀动作集）
function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end
	local len = velocity:Length2DSqr()
	if len <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_FIST, -1
		end
		return ACT_HL2MP_IDLE_KNIFE, -1
	end
	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_KNIFE, -1
	end
	if len < 2800 then
		return ACT_HL2MP_WALK_KNIFE, -1
	end
	return ACT_HL2MP_RUN_KNIFE, -1
end

-- 更新动画
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
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 无脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

-- 动态透明度计算（基于视角和距离）
function CLASS:GetAlpha(pl)
	local wep = pl:GetActiveWeapon()
	if not wep.IsAttacking then wep = NULL end

	if wep:IsValid() and wep:IsAttacking() then
		return 0.7
	end

	local eyepos = EyePos()
	local nearest = pl:WorldSpaceCenter()
	local norm = nearest - eyepos
	norm:Normalize()
	local dot = EyeVector():Dot(norm)

	local vis = (dot * 0.4 + pl:GetVelocity():Length() / self.Speed / 2 - eyepos:Distance(nearest) / 400) * dot

	return math_Clamp(vis, MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD and 0.137 or 0, 0.7)
end

-- 服务端逻辑：死亡时触发暗影特效
if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(pl:GetForward())
			effectdata:SetEntity(pl)
		util.Effect("death_wraith", effectdata, nil, true)
		return true
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/wraithv2"

-- 绘制前
function CLASS:PrePlayerDraw(pl)
	local alpha = self:GetAlpha(pl)
	if alpha == 0 then return true end
	render.SetBlend(alpha)
	render.SetColorModulation(0.025, 0.025, 0.1)
	render.SuppressEngineLighting(true)
end

-- 绘制后
function CLASS:PostPlayerDraw(pl)
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
end
