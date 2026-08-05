-- ============================================================================
-- 猎头蟹 (Headcrab) — 僵尸职业
-- 特点：经典猎头蟹模型、挖地潜行（钻地）、可扑击、
--       跳跃时扑击视角锁定、不产生恐惧（钻地时）、小型碰撞体积
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Headcrab"
-- 翻译键名
CLASS.TranslationName = "class_headcrab"
-- 描述文本键名
CLASS.Description = "description_headcrab"
-- 控制帮助文本键名
CLASS.Help = "controls_headcrab"

-- 经典猎头蟹模型
CLASS.Model = Model("models/headcrabclassic.mdl")

-- 初始可用
CLASS.Wave = 0
-- 初始解锁
CLASS.Unlocked = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_headcrab"

-- 生命值
CLASS.Health = 70
-- 移动速度
CLASS.Speed = 175
-- 跳跃力
CLASS.JumpPower = 100

-- 无摔落伤害
CLASS.NoFallDamage = true
-- 无摔落减速
CLASS.NoFallSlowdown = true

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HeadcrabZombiePointRatio

-- 小型碰撞体积
CLASS.Hull = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
-- 视角偏移
CLASS.ViewOffset = Vector(0, 0, 10)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 10)
-- 台阶高度
CLASS.StepSize = 8
-- 蹲伏行走速度倍率
CLASS.CrouchedWalkSpeed = 1
-- 质量（轻）
CLASS.Mass = 25

-- 不能蹲下
CLASS.CantDuck = true

-- 标记为猎头蟹
CLASS.IsHeadcrab = true

-- 受伤/死亡音效
CLASS.PainSounds = {"NPC_HeadCrab.Pain"}
-- 死亡音效
CLASS.DeathSounds = {"NPC_HeadCrab.Die"}

-- 黄色血液
CLASS.BloodColor = BLOOD_COLOR_YELLOW

-- 缓存函数
local CurTime = CurTime
local math_min = math.min
local math_Clamp = math.Clamp
local math_abs = math.abs

-- 移动逻辑
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end
end

-- 无脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

-- 缩放伤害
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetBurrowTime then
		local time = wep:GetBurrowTime()
		if time > 0 then
			return 1, 11  -- 钻入地下
		end
		if time < 0 then
			return 1, 10  -- 钻出地面
		end
	end

	if pl:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end
		return 1, 1
	end

	if pl:WaterLevel() >= 3 then
		return 1, 6
	end
	return 1, 5  -- 跳跃
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetBurrowTime then
		local time = wep:GetBurrowTime()
		if time ~= 0 then
			pl:SetCycle(math_Clamp((math_abs(time) - CurTime()) / wep.BurrowTime, 0, 1))
			pl:SetPlaybackRate(0)
			return true
		end
	end

	local seq = pl:GetSequence()
	if seq == 5 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
		pl:SetPlaybackRate(1)
		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end

	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5, 2))
	else
		pl:SetPlaybackRate(1)
	end
	return true
end

-- 钻地时不产生恐惧且不可见
function CLASS:DoesntGiveFear(pl)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetBurrowTime then
		return wep:GetBurrowTime() > 0 and CurTime() > math_abs(wep:GetBurrowTime())
	end
end
CLASS.NoDraw = CLASS.DoesntGiveFear

-- 钻地时强制绘制本地玩家
function CLASS:ShouldDrawLocalPlayer(pl)
	local wep = pl:GetActiveWeapon()
	return wep:IsValid() and wep.GetBurrowTime and wep:GetBurrowTime() ~= 0
end

-- 服务端：备用使用键重新装弹（触发钻地）
if SERVER then
	function CLASS:AltUse(pl)
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() then wep:Reload() end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/headcrab"

-- 钻地时不绘制
function CLASS:PrePlayerDraw(pl)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetBurrowTime and wep:GetBurrowTime() ~= 0 and CurTime() >= math_abs(wep:GetBurrowTime()) then
		return true
	end
end

-- 客户端移动指令：扑击时视角锁定
function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.m_ViewAngles and wep.IsPouncing and wep:IsPouncing() then
		local maxdiff = FrameTime() * 15
		local mindiff = -maxdiff
		local originalangles = wep.m_ViewAngles
		local viewangles = cmd:GetViewAngles()

		local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
		if diff > maxdiff or diff < mindiff then
			viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
		end

		wep.m_ViewAngles = viewangles
		cmd:SetViewAngles(viewangles)
	end
end
