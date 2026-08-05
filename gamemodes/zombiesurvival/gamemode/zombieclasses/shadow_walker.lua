-- ============================================================================
-- 暗影行者 (Shadow Walker) — 僵尸职业
-- 特点：骷髅覆盖模型、可装死、半透明黑色渲染、
--       近战伤害减半、红色发光眼睛、骨骼属性
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Shadow Walker"
-- 翻译键名
CLASS.TranslationName = "class_shadow_walker"
-- 描述文本键名
CLASS.Description = "description_shadow_walker"
-- 控制帮助文本键名
CLASS.Help = "controls_shadow_lurker"

-- 进阶版本
CLASS.BetterVersion = "Frigid Revenant"

-- 主模型（尸体）+ 覆盖模型（骷髅）
-- 主模型（尸体）
CLASS.Model = Model("models/player/corpse1.mdl")
-- 覆盖模型（骷髅）
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 可嘲讽
CLASS.CanTaunt = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_shadowwalker"

-- 出现波次
CLASS.Wave = 2 / 6

-- 生命值/速度
-- 生命值
CLASS.Health = 220
-- 移动速度
CLASS.Speed = 180

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 语音音调
CLASS.VoicePitch = 0.55

-- 可装死
CLASS.CanFeignDeath = true

-- 不隐藏主模型
CLASS.NoHideMainModel = true

-- 骨骼标记
CLASS.Skeletal = true

-- 缓存变量
local math_random = math.random
local math_min = math.min
local math_max = math.max
local DMG_BULLET = DMG_BULLET
local ACT_HL2MP_ZOMBIE_SLUMP_RISE = ACT_HL2MP_ZOMBIE_SLUMP_RISE
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_FIST = ACT_HL2MP_IDLE_CROUCH_FIST
local ACT_HL2MP_IDLE_KNIFE = ACT_HL2MP_IDLE_KNIFE
local ACT_HL2MP_WALK_CROUCH_KNIFE = ACT_HL2MP_WALK_CROUCH_KNIFE
local ACT_HL2MP_RUN_KNIFE = ACT_HL2MP_RUN_KNIFE

-- 被击倒时重置
function CLASS:KnockedDown(pl, status, exists)
	pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
end

-- 脚步声
-- 自定义脚步声（藤壶折颈音效）
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random(2) == 1 then
		pl:EmitSound("npc/barnacle/neck_snap1.wav", 65, math_random(135, 150), 0.27)
	else
		pl:EmitSound("npc/barnacle/neck_snap2.wav", 65, math_random(135, 150), 0.27)
	end
	return true
end

-- 计算活动动画（有重复定义，第二个覆盖）
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return ACT_WALK, -1
end

-- 受伤/死亡音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/antlion/pain2.wav", 70, math_random(190, 200))
	pl.NextPainSound = CurTime() + 0.5
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/antlion/pain"..math_random(2)..".wav", 70, math_random(190, 200))
	return true
end

-- 计算主要活动动画（覆盖版本）
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
	if velocity:Length2DSqr() <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_FIST, -1
		end
		return ACT_HL2MP_IDLE_KNIFE, -1
	end
	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_KNIFE, -1
	end
	return ACT_HL2MP_RUN_KNIFE, -1
end

-- 更新动画
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
	local len = velocity:Length()
	if len > 1 then
		pl:SetPlaybackRate(math_min(len / maxseqgroundspeed, 3))
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

-- 装死时不产生恐惧
function CLASS:DoesntGiveFear(pl)
	return pl.FeignDeath and pl.FeignDeath:IsValid()
end

-- 服务端逻辑
if SERVER then
	-- 备用使用键触发装死
	function CLASS:AltUse(pl)
		pl:StartFeignDeath()
	end
	-- 近战伤害减半
	function CLASS:ProcessDamage(pl, dmginfo)
		if dmginfo:GetInflictor().IsMelee then
			dmginfo:SetDamage(dmginfo:GetDamage() / 2)
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/skeletal_walker"
-- 图标颜色（深灰色）
CLASS.IconColor = Color(50, 50, 50)

-- 渲染变量
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_ModelMaterialOverride = render.ModelMaterialOverride
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

local colGlow = Color(255, 0, 0)
local matGlow = Material("sprites/glow04_noz")
local matBlack = CreateMaterial("shadowlurkersheet", "UnlitGeneric", {["$basetexture"] = "Tools/toolsblack", ["$model"] = 1})
local vecEyeLeft = Vector(5, -3.5, -1)
local vecEyeRight = Vector(5, -3.5, 1)

-- 主模型绘制前：半透明深灰
function CLASS:PrePlayerDraw(pl)
	render_SetBlend(0.45)
	render_SetColorModulation(0.2, 0.2, 0.2)
end

-- 主模型绘制后：恢复颜色与透明度
function CLASS:PostPlayerDraw(pl)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end

-- 覆盖模型绘制前：黑色材质
function CLASS:PrePlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(matBlack)
end

-- 覆盖模型绘制后：恢复材质并绘制红色发光眼睛
function CLASS:PostPlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(nil)
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end
	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
