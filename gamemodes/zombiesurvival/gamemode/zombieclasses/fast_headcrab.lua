-- ============================================================================
-- 快速猎头蟹 (Fast Headcrab) — 僵尸职业
-- 特点：快速移动、高跳跃力、无摔伤、小型碰撞体积、
--       可扑击、扑击时视角锁定、黄色血液
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Fast Headcrab"
-- 翻译键名
CLASS.TranslationName = "class_fast_headcrab"
-- 描述文本键名
CLASS.Description = "description_fast_headcrab"
-- 控制帮助文本键名
CLASS.Help = "controls_fast_headcrab"

-- 进阶版本
CLASS.BetterVersion = "Bloodsucker Headcrab"

-- 使用猎头蟹模型
CLASS.Model = Model("models/headcrab.mdl")

-- 出现波次
CLASS.Wave = 2 / 6

-- 绑定的武器
CLASS.SWEP = "weapon_zs_fastheadcrab"

-- 生命值
CLASS.Health = 40
-- 移动速度
CLASS.Speed = 230
-- 跳跃力
CLASS.JumpPower = 100

-- 无摔落伤害/减速
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
CLASS.Mass = 16

-- 不能蹲下
CLASS.CantDuck = true

-- 标记为猎头蟹
CLASS.IsHeadcrab = true

-- 受伤/死亡音效
CLASS.PainSounds = {"NPC_FastHeadcrab.Pain"}
-- 死亡音效
CLASS.DeathSounds = {"NPC_FastHeadcrab.Die"}

-- 黄色血液
CLASS.BloodColor = BLOOD_COLOR_YELLOW

local ACT_RUN = ACT_RUN

-- 移动逻辑：调用武器移动函数
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
	if pl:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end
		return 1, 1
	end

	if pl:WaterLevel() >= 3 then
		return 1, 6
	end
	return 1, 3
end

-- 更新动画：跳跃动画循环
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local seq = pl:GetSequence()
	if seq == 3 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
		pl:SetPlaybackRate(1)
		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fastheadcrab"

-- 客户端移动指令：扑击时锁定视角
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
