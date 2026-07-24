--[[
==================================================================
快速僵尸腿 (Fast Zombie Legs) — 特殊僵尸职业
特点：快速僵尸死亡后分裂出的下半身、仅腿部受伤判定、
      高跳跃力、可装死、踢腿攻击骨骼动画、无头部/上半身渲染
==================================================================
]]

-- 职业显示名称
CLASS.Name = "Fast Zombie Legs"
-- 翻译键名
CLASS.TranslationName = "class_fast_zombie_legs"
-- 描述文本键名
CLASS.Description = "description_fast_zombie_legs"

-- 主模型（快速僵尸）
CLASS.Model = Model("models/player/zombie_fast.mdl")
-- 覆盖模型（快速僵尸腿部模型）
CLASS.OverrideModel = Model("models/Gibs/Fast_Zombie_Legs.mdl")
-- 无头部
CLASS.NoHead = true

-- 初始可用/隐藏
CLASS.Wave = 0
CLASS.Threshold = 0
CLASS.Unlocked = true
CLASS.Hidden = true

-- 生命值
CLASS.Health = 75
-- 移动速度
CLASS.Speed = 200
-- 跳跃力
CLASS.JumpPower = 250

-- 可嘲讽
CLASS.CanTaunt = true

-- 击杀得分
CLASS.Points = CLASS.Health/GM.LegsZombiePointRatio

-- 小型碰撞体积（无上半身）
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 32)
CLASS.ViewOffsetDucked = Vector(0, 0, 32)
CLASS.Mass = DEFAULT_MASS * 0.5
CLASS.CrouchedWalkSpeed = 1

-- 不能蹲下/不能装死
CLASS.CantDuck = true
CLASS.CanFeignDeath = false

-- 语音音调
CLASS.VoicePitch = 0.65

-- 无血液
CLASS.BloodColor = -1

-- 绑定的武器
CLASS.SWEP = "weapon_zs_fastzombielegs"

-- 服务端逻辑
if SERVER then
	-- 备用使用键：触发装死
	function CLASS:AltUse(pl)
		local feigndeath = pl.FeignDeath
		if feigndeath and feigndeath:IsValid() then
			if CurTime() >= feigndeath:GetStateEndTime() then
				feigndeath:SetState(1)
				feigndeath:SetStateEndTime(CurTime() + 1.5)
			end
		elseif pl:IsOnGround() and not pl:KeyDown(IN_FORWARD) and not pl:KeyDown(IN_MOVERIGHT) and not pl:KeyDown(IN_MOVELEFT) and not pl:KeyDown(IN_BACK) then
			local wep = pl:GetActiveWeapon()
			if wep:IsValid() and not wep:IsSwinging() and CurTime() > wep:GetNextPrimaryFire() then
				local status = pl:GiveStatus("feigndeath")
				if status and status:IsValid() then
					status:SetStateEndTime(CurTime() + 1.5)
				end
			end
		end
	end

	-- 忽略腿部伤害
	function CLASS:IgnoreLegDamage(pl, dmginfo)
		return true
	end
end

-- 缩放伤害：仅下半身可被攻击
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	if not dmginfo:IsBulletDamage() then return true end

	if hitgroup ~= HITGROUP_LEFTLEG and hitgroup ~= HITGROUP_RIGHTLEG and hitgroup ~= HITGROUP_GEAR and hitgroup ~= HITGROUP_GENERIC and dmginfo:GetDamagePosition().z > pl:LocalToWorld(Vector(0, 0, self.Hull[2].z * 1.33)).z then
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
	end
	return true
end

-- 强制绘制本地玩家
function CLASS:ShouldDrawLocalPlayer(pl)
	return true
end

-- 缓存的随机函数
local mathrandom = math.random

-- 脚步声列表
local StepLeftSounds = {
	"npc/fast_zombie/foot1.wav",
	"npc/fast_zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/fast_zombie/foot3.wav",
	"npc/fast_zombie/foot4.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[mathrandom(#StepLeftSounds)], 70)
	else
		pl:EmitSound(StepRightSounds[mathrandom(#StepRightSounds)], 70)
	end
	return true
end

-- 脚步音效间隔时间
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 625 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 600
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 750
	end
	return 450
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		return 1, pl:LookupSequence("zombie_slump_rise_02_fast")
	end

	if velocity:Length2DSqr() <= 1 then
		return ACT_HL2MP_IDLE_ZOMBIE, -1
	end
	return ACT_HL2MP_RUN_ZOMBIE, -1
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local feign = pl.FeignDeath
	if feign and feign:IsValid() then
		if feign:GetState() == 1 then
			pl:SetCycle(1 - math.max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		else
			pl:SetCycle(math.max(feign:GetStateEndTime() - CurTime(), 0) * 0.666)
		end
		pl:SetPlaybackRate(0)
		return true
	end

	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math.min(len2d / maxseqgroundspeed * 0.75, 3))
	else
		pl:SetPlaybackRate(1)
	end
	return true
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fast_legs"

-- 裁剪上半身的贴花
local undo = false
function CLASS:PrePlayerDraw(pl)
	local boneid = pl:LookupBone("ValveBiped.Bip01_Spine")
	if boneid and boneid > 0 then
		local pos, ang = pl:GetBonePosition(boneid)
		if pos then
			local normal = ang:Forward() * -1
			render.EnableClipping(true)
			render.PushCustomClipPlane(normal, normal:Dot(pos))
			undo = true
		end
	end
end

function CLASS:PostPlayerDraw(pl)
	if undo then
		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end
end

-- 构建骨骼：踢腿动画时操控大腿骨骼角度
function CLASS:BuildBonePositions(pl)
	local desired
	local bone = "ValveBiped.Bip01_L_Thigh"

	local wep = pl:GetActiveWeapon()
	if wep:IsValid() then
		if wep.GetSwingEndTime and wep:GetSwingEndTime() > 0 then
			desired = 1 - math.Clamp((wep:GetSwingEndTime() - CurTime()) / wep.MeleeDelay, 0, 1)
		end

		if wep:GetDTBool(3) then
			bone = "ValveBiped.Bip01_R_Thigh"
		end
	end

	desired = desired or 0

	if desired > 0 then
		pl.m_KickDelta = CosineInterpolation(0, 1, desired)
	else
		pl.m_KickDelta = math.Approach(pl.m_KickDelta or 0, desired, FrameTime() * 4)
	end

	local boneid = pl:LookupBone(bone)
	if boneid and boneid > 0 then
		pl:ManipulateBoneAngles(boneid, pl.m_KickDelta * Angle(bone == "ValveBiped.Bip01_L_Thigh" and 0 or 20, -110, 30))
	end
end
