-- ============================================================================
-- 屠夫 (The Butcher) — BOSS僵尸职业
-- 特点：高血量、超快速度、免疫击退、可嘲讽、自定义步行/攻击动画、
--       死亡掉落屠夫刀、生成时播放环境音效、红色发光眼睛
-- ============================================================================

-- 职业显示名称
CLASS.Name = "The Butcher"
-- 翻译键名
CLASS.TranslationName = "class_butcher"
-- 描述文本键名
CLASS.Description = "description_butcher"
-- 控制帮助文本键名
CLASS.Help = "controls_butcher"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 3000
-- 移动速度
CLASS.Speed = 270

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_butcherknifez"

-- 使用尸体模型
CLASS.Model = Model("models/player/corpse1.mdl")

-- 语音音调（低沉）
CLASS.VoicePitch = 0.65

-- 受伤音效列表
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效列表
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 缓存函数和变量
local math_random = math.random
local math_min = math.min
local CurTime = CurTime

-- 缓存动画常量
local ACT_HL2MP_SWIM_MELEE = ACT_HL2MP_SWIM_MELEE
local ACT_HL2MP_IDLE_CROUCH_MELEE = ACT_HL2MP_IDLE_CROUCH_MELEE
local ACT_HL2MP_WALK_CROUCH_MELEE = ACT_HL2MP_WALK_CROUCH_MELEE
local ACT_HL2MP_IDLE_MELEE = ACT_HL2MP_IDLE_MELEE
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE
local ACT_HL2MP_RUN_MELEE = ACT_HL2MP_RUN_MELEE

-- 左脚脚步声列表
local StepLeftSounds = {
	"npc/fast_zombie/foot1.wav",
	"npc/fast_zombie/foot2.wav"
}
-- 右脚脚步声列表
local StepRightSounds = {
	"npc/fast_zombie/foot3.wav",
	"npc/fast_zombie/foot4.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[math_random(#StepLeftSounds)], 70)
	else
		pl:EmitSound(StepRightSounds[math_random(#StepRightSounds)], 70)
	end
	return true
end

-- 计算主要活动动画（根据状态选择不同动作）
function CLASS:CalcMainActivity(pl, velocity)
	-- 游泳时使用近战游泳动画
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_MELEE, -1
	end

	-- 蹲下时根据速度选择闲置或行走动画
	if pl:Crouching() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_MELEE, -1
		end
		return ACT_HL2MP_WALK_CROUCH_MELEE, -1
	end

	-- 检测是否正在挥砍
	local swinging = false
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and CurTime() < wep:GetNextPrimaryFire() then
		swinging = true
	end

	-- 静止状态
	if velocity:Length2DSqr() <= 1 then
		if swinging then
			return ACT_HL2MP_IDLE_MELEE, -1
		end
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

	-- 移动时根据是否挥砍选择动画
	if swinging then
		return ACT_HL2MP_RUN_MELEE, -1
	end
	return ACT_HL2MP_RUN_ZOMBIE, -1
end

-- 更新动画播放速率
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
		pl:CreateAmbience("butcherambience")
	end

	-- 创建屠夫刀掉落物
	local function MakeButcherKnife(pos)
		local ent = ents.Create("prop_weapon")
		if ent:IsValid() then
			ent:SetPos(pos)
			ent:SetAngles(AngleRand())
			ent:SetWeaponType("weapon_zs_box")
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
				phys:AddAngleVelocity(VectorRand() * 200)
			end
		end
	end

	-- 死亡时延迟掉落屠夫刀
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local pos = pl:LocalToWorld(pl:OBBCenter())
		timer.Simple(0, function()
			MakeButcherKnife(pos)
		end)
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/butcher"

-- 客户端渲染相关变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 眼睛发光颜色（红色）
local colGlow = Color(235, 50, 0)
-- 发光材质
local matGlow = Material("sprites/glow04_noz")
-- 双眼偏移位置
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前颜色调制（偏红）
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(1, 0.5, 0.5)
end

-- 绘制后恢复颜色并绘制发光眼睛
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	-- 获取头部骨骼位置并绘制双眼发光
	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
