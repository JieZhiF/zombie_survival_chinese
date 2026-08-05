-- ============================================================================
-- 暗影腐化者 (Shadow Corruptor) — 僵尸职业（已禁用）
-- 特点：已禁用、娃娃模型+骷髅覆盖模型、可装死、半透明黑色渲染、
--       红色发光眼睛、自定义手部绘制
-- ============================================================================

-- 隐藏/禁用
-- 隐藏（不直接可选）
CLASS.Hidden = true
-- 禁用（不参与游戏）
CLASS.Disabled = true
-- 解锁（但被禁用）
CLASS.Unlocked = true

-- 职业显示名称
CLASS.Name = "Shadow Corruptor"
-- 翻译键名
CLASS.TranslationName = "class_shadow_corruptor"
-- 描述文本键名
CLASS.Description = "description_shadow_corruptor"
-- 控制帮助文本键名
CLASS.Help = "controls_shadow_corruptor"

-- 出现波次
CLASS.Wave = 6 / 6

-- 生命值
CLASS.Health = 100
-- 移动速度
CLASS.Speed = 150

-- 击杀得分
CLASS.Points = 5

-- 可嘲讽/可装死
-- 可嘲讽
CLASS.CanTaunt = true
-- 可装死
CLASS.CanFeignDeath = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_shadowcorruptor"

-- 主模型（娃娃）+ 覆盖模型（骷髅）
-- 主模型（娃娃）
CLASS.Model = Model("models/vinrax/player/doll_player.mdl")
-- 覆盖模型（骷髅）
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 语音音调
CLASS.VoicePitch = 0.75

-- 不隐藏主模型
CLASS.NoHideMainModel = true

-- 模型缩放
CLASS.ModelScale = 0.4

-- 物理/碰撞属性
CLASS.Mass = 30
-- 视角偏移
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
-- 台阶高度
CLASS.StepSize = 8
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0) * CLASS.ModelScale, Vector(16, 16, 100) * CLASS.ModelScale}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0) * CLASS.ModelScale, Vector(16, 16, 60) * CLASS.ModelScale}

-- 缓存函数
local CurTime = CurTime
local math_random = math.random
local math_max = math.max
local math_min = math.min
local math_ceil = math.ceil
local string_format = string.format

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

-- 自定义脚步声（高音调）
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[math_random(#StepLeftSounds)], 55, 150)
	else
		pl:EmitSound(StepRightSounds[math_random(#StepRightSounds)], 55, 150)
	end
	return true
end

-- 计算活动动画
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
		pl:SetPlaybackRate(pl:GetPlaybackRate() * 1.5)
	end
	return true
end

-- 受伤/死亡音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("npc/metropolice/pain%d.wav", math_random(4)), 65, math_random(70, 75))
	pl.NextPainSound = CurTime() + 0.5
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound(string_format("npc/zombie/zombie_die%d.wav", math_random(3)), 75, math_random(122, 128))
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
	-- 死亡时播放假死动画
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:FakeDeath(pl:LookupSequence("death_0"..math_random(4)), self.ModelScale)
		return true
	end
	-- 备用使用键触发装死
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
-- 图标颜色（黑色）
CLASS.IconColor = Color(20, 20, 20)

-- 渲染变量
local render_ModelMaterialOverride = render.ModelMaterialOverride
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

local colGlow = Color(255, 0, 0)
local matGlow = Material("sprites/glow04_noz")
local matBlack = CreateMaterial("shadowlurkersheet", "UnlitGeneric", {["$basetexture"] = "Tools/toolsblack", ["$model"] = 1})
local vecEyeLeft = Vector(5, -3.5, -1)
local vecEyeRight = Vector(5, -3.5, 1)
local matSheet = Material("models/props_c17/doll01")

-- 手部绘制
function CLASS:DrawHands(pl, hands)
	render_ModelMaterialOverride(matSheet)
	render_SetColorModulation(0.1, 0.1, 0.1)
	render_SetBlend(0.45)
	hands:DrawModel()
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
	render_ModelMaterialOverride(nil)
	return true
end

-- 绘制前：半透明黑色
function CLASS:PrePlayerDraw(pl)
	render_SetBlend(0.45)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

-- 绘制后：恢复颜色与透明度
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
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() then return end
	local pos, ang = pl:GetBonePositionMatrixed(5)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 3, 3, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 3, 3, colGlow)
	end
end
