--[[
==================================================================
噩梦屠夫 (Night Butcher) — BOSS僵尸职业
特点：高血量、极快速度、免疫击退、可嘲讽、半透明渲染、
      拥有暗影护盾技能、死亡掉落武器箱、红色发光眼睛、蓝色发光特效
==================================================================
]]

-- 职业显示名称
CLASS.Name = "噩梦屠夫"
-- 翻译键名（直接使用中文）
CLASS.TranslationName = "噩梦屠夫"
-- 描述文本
CLASS.Description = "暂定"
-- 控制帮助文本
CLASS.Help = ""

-- 非正式BOSS（隐藏）
CLASS.Boss = false
-- 隐藏职业
CLASS.Hidden = true
-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 3400
-- 移动速度
CLASS.Speed = 265

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_butt_a"

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

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_MELEE, -1
	end
	if pl:Crouching() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_MELEE, -1
		end
		return ACT_HL2MP_WALK_CROUCH_MELEE, -1
	end

	local swinging = false
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and CurTime() < wep:GetNextPrimaryFire() then
		swinging = true
	end

	if velocity:Length2DSqr() <= 1 then
		if swinging then
			return ACT_HL2MP_IDLE_MELEE, -1
		end
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

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

-- 单独的攻击动画函数
function CLASS:PlayAttackAnimation(pl)
    -- 根据玩家事件触发主攻击，播放僵尸攻击动画
    pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true)
    return ACT_INVALID
end

-- 攻击事件处理
function CLASS:DoAnimationEvent(pl, event, data)
    if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
        -- 调用单独的攻击动画函数
        return self:PlayAttackAnimation(pl)
    elseif event == PLAYERANIMEVENT_RELOAD then
        -- 播放僵尸的挑衅动画
        pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
        return ACT_INVALID
    end
end

-- 移动逻辑：暗影护盾状态下减速
function CLASS:Move(pl, move)
	if pl.ShadeShield and pl.ShadeShield:IsValid() then
		move:SetMaxSpeed(175)
		move:SetMaxClientSpeed(175)
	end
end

-- 服务端逻辑
if SERVER then
	-- 生成时：创建环境音效并设置半透明渲染
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("shadeambience")
		pl:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	-- 切换职业时恢复渲染模式
	function CLASS:SwitchedAway(pl)
		pl:SetRenderMode(RENDERMODE_NORMAL)
	end

	-- 处理伤害：物理碰撞伤害免疫
	function CLASS:ProcessDamage(pl, dmginfo)
		if SERVER then
			local inflictor = dmginfo:GetInflictor()
			if inflictor:IsValid() and (inflictor:IsPhysicsModel() or inflictor.IsPhysbox) then
				return
			end
			-- 更新环境音效的最后受伤时间
			local status = pl.status_shadeambience
			if status and status:IsValid() then
				status:SetLastDamaged(CurTime())
			end
		end
	end

	-- 暗影护盾技能
	function CLASS:ShadeShield(pl)
		local shadeshield = pl.ShadeShield
		local curtime = CurTime()
		if pl.NextShield and curtime <= pl.NextShield then return end

		-- 如果已有护盾则更新状态
		if shadeshield and shadeshield:IsValid() then
			if curtime >= shadeshield:GetStateEndTime() then
				shadeshield:SetState(1)
				shadeshield:SetStateEndTime(curtime + 0.5)
			end
		-- 否则创建新护盾
		elseif pl:IsOnGround() and not pl:IsPlayingTaunt() then
			local wep = pl:GetActiveWeapon()
			if wep:IsValid() and curtime > wep:GetNextPrimaryFire() and curtime > wep:GetNextSecondaryFire() then
				local status = pl:GiveStatus("shadeshield")
				if status and status:IsValid() then
					status:SetStateEndTime(curtime + 0.5)
					-- 移除旧的暗影控制实体
					for _, ent in pairs(ents.FindByClass("env_shadecontrol")) do
						if ent:IsValid() and ent:GetOwner() == pl then
							ent:Remove()
							return
						end
					end
				end
			end
		end
	end

	-- 备用使用键触发暗影护盾
	function CLASS:AltUse(pl)
		self:ShadeShield(pl)
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

-- 眼睛发光颜色（蓝色）
local colGlow = Color(0, 51, 235)
-- 发光材质
local matGlow = Material("sprites/glow04_noz")
-- 双眼偏移位置
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前颜色调制（偏粉红）
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(1, 0.5, 0.5)
end

-- 绘制后恢复颜色并绘制发光眼睛
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
