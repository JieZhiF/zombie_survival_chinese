--[[
==================================================================
暗影 (Shade) — BOSS僵尸职业
特点：半透明幽灵效果、无摔伤、无阴影、无脚步声、
      腿部/躯干子弹免疫、暗影护盾技能、隐藏腿部骨骼、
      折射特效、死亡时触发暗影死亡特效
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Shade"
-- 翻译键名
CLASS.TranslationName = "class_shade"
-- 描述文本键名
CLASS.Description = "description_shade"
-- 控制帮助文本键名
CLASS.Help = "controls_shade"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 无尸体碎裂
CLASS.NoGibs = true
-- 无摔落伤害
CLASS.NoFallDamage = true
-- 无摔落减速
CLASS.NoFallSlowdown = true

-- 无阴影
CLASS.NoShadow = true
-- 不调整物理伤害
CLASS.NoAdjustPhysDamage = true

-- 可嘲讽
CLASS.CanTaunt = true

-- 生命值
CLASS.Health = 2400
-- 移动速度
CLASS.Speed = 175

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_shade"

-- 使用快速僵尸模型
CLASS.Model = Model("models/player/zombie_fast.mdl")

-- 语音音调
CLASS.VoicePitch = 0.8

-- 机械血液颜色
CLASS.BloodColor = BLOOD_COLOR_MECH

-- 受伤/死亡音效（藤壶拉拽音效）
CLASS.PainSounds = {Sound("npc/barnacle/barnacle_pull1.wav"), Sound("npc/barnacle/barnacle_pull2.wav"), Sound("npc/barnacle/barnacle_pull3.wav"), Sound("npc/barnacle/barnacle_pull4.wav")}
CLASS.DeathSounds = {Sound("zombiesurvival/wraithdeath1.ogg"), Sound("zombiesurvival/wraithdeath2.ogg"), Sound("zombiesurvival/wraithdeath3.ogg"), Sound("zombiesurvival/wraithdeath4.ogg")}

-- 缓存数学函数
local math_sin = math.sin
local math_cos = math.cos
local math_abs = math.abs
local math_Clamp = math.Clamp
local CurTime = CurTime

-- 缓存动画常量
local ACT_HL2MP_IDLE_MAGIC = ACT_HL2MP_IDLE_MAGIC
local ACT_HL2MP_RUN_MAGIC = ACT_HL2MP_RUN_MAGIC
local ACT_HL2MP_RUN_ZOMBIE = ACT_HL2MP_RUN_ZOMBIE

-- 缩放伤害：仅子弹伤害生效，腿部和躯干部位免疫
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	if not dmginfo:IsBulletDamage() then return true end

	if hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR or hitgroup == HITGROUP_GENERIC then
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
	end
	return true
end

-- 忽略腿部伤害
function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

-- 移动逻辑：暗影护盾状态下极大减速
function CLASS:Move(pl, move)
	if pl.ShadeShield and pl.ShadeShield:IsValid() then
		move:SetMaxSpeed(35)
		move:SetMaxClientSpeed(35)
	end
end

-- 无脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

-- 脚步声时间固定为1秒
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return 1000
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if (pl.ShadeControl and pl.ShadeControl:IsValid()) or (pl.ShadeShield and pl.ShadeShield:IsValid()) then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_MAGIC, -1
		end
		return ACT_HL2MP_RUN_MAGIC, -1
	end
	return ACT_HL2MP_RUN_ZOMBIE, -1
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2, true)
		return ACT_INVALID
	end
end

-- 更新动画：脉动循环效果
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetPlaybackRate(1)
	pl:SetCycle(0.35 + math_abs(math_sin(CurTime() * 1.5)) * 0.3)
	return true
end

-- 死亡时触发暗影死亡特效
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	if SERVER then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:WorldSpaceCenter())
			effectdata:SetNormal(pl:GetUp())
			effectdata:SetEntity(pl)
		util.Effect("death_shade", effectdata, nil, true)
	end
	return true
end

-- 服务端逻辑
if SERVER then
	-- 生成时创建环境音效并设置半透明渲染
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("shadeambience")
		pl:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	-- 切换职业时恢复渲染模式
	function CLASS:SwitchedAway(pl)
		pl:SetRenderMode(RENDERMODE_NORMAL)
	end

	-- 伤害处理
	function CLASS:ProcessDamage(pl, dmginfo)
		if SERVER then
			local inflictor = dmginfo:GetInflictor()
			if inflictor:IsValid() and (inflictor:IsPhysicsModel() or inflictor.IsPhysbox) then
				return
			end
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

		if shadeshield and shadeshield:IsValid() then
			if curtime >= shadeshield:GetStateEndTime() then
				shadeshield:SetState(1)
				shadeshield:SetStateEndTime(curtime + 0.5)
			end
		elseif pl:IsOnGround() and not pl:IsPlayingTaunt() then
			local wep = pl:GetActiveWeapon()
			if wep:IsValid() and curtime > wep:GetNextPrimaryFire() and curtime > wep:GetNextSecondaryFire() then
				local status = pl:GiveStatus("shadeshield")
				if status and status:IsValid() then
					status:SetStateEndTime(curtime + 0.5)
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
CLASS.Icon = "zombiesurvival/killicons/shadev2"
CLASS.IconColor = Color(0, 50, 255)

-- 需要缩到最小的腿部骨骼
local ToZero = {"ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_R_Foot"}

-- 构建骨骼位置：隐藏腿部（幽灵般漂浮）
function CLASS:BuildBonePositions(pl)
	for _, bonename in pairs(ToZero) do
		local boneid = pl:LookupBone(bonename)
		if boneid and boneid > 0 then
			pl:ManipulateBoneScale(boneid, vector_tiny)
		end
	end
end

local nodraw = false
local matWhite = Material("models/debug/debugwhite")
local matRefract = Material("models/spawn_effect")

-- 渲染前特效
function CLASS:PreRenderEffects(pl)
	if render.SupportsVertexShaders_2_0() then
		local normal = pl:GetUp()
		render.EnableClipping(true)
		render.PushCustomClipPlane(normal, normal:Dot(pl:GetPos() + normal * 16))
	end

	if nodraw then return end

	local red = 0
	local status = pl.status_shadeambience
	if status and status:IsValid() then
		red = 1 - math_Clamp((CurTime() - status:GetLastDamaged()) * 3, 0, 1) ^ 3
	end

	render.SetColorModulation(red, 0.1, 1 - red)
	render.SetBlend(0.5 + math_abs(math_cos(CurTime())) ^ 2 * 0.1)
	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(matWhite)
end

-- 渲染后特效
function CLASS:PostRenderEffects(pl)
	if render.SupportsVertexShaders_2_0() then
		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end

	if nodraw then return end

	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride()

	if render.SupportsPixelShaders_2_0() then
		render.UpdateRefractTexture()
		matRefract:SetFloat("$refractamount", 0.01)
		render.ModelMaterialOverride(matRefract)
		nodraw = true
		pl:DrawModel()
		nodraw = false
		render.ModelMaterialOverride(0)
	end
end

-- 绘制前
function CLASS:PrePlayerDraw(pl)
	pl:RemoveAllDecals()
	self:PreRenderEffects(pl)
end

-- 绘制后
function CLASS:PostPlayerDraw(pl)
	self:PostRenderEffects(pl)
end
