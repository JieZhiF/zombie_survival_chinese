-- ============================================================================
-- 乌鸦 (Crow) — 特殊僵尸职业
-- 特点：使用乌鸦模型、可飞行、极低血量、隐藏职业、不计入击杀统计、
--       不产生恐惧、击杀后统计乌鸦击杀数、可啄击攻击
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Crow"
-- 翻译键名
CLASS.TranslationName = "class_crow"
-- 描述文本键名
CLASS.Description = "description_crow"

-- 极低生命值
CLASS.Health = 5
-- 波次/阈值（初始可用）
CLASS.Wave = 0
-- 阈值（0 表示无需任何条件）
CLASS.Threshold = 0
-- 绑定的武器
CLASS.SWEP = "weapon_zs_crow"
-- 使用乌鸦模型
CLASS.Model = Model("models/crow.mdl")
-- 移动速度
CLASS.Speed = 90
-- 跳跃力
CLASS.JumpPower = 230

-- 受伤/死亡音效
CLASS.PainSounds = {"NPC_Crow.Pain"}
-- 死亡音效
CLASS.DeathSounds = {"NPC_Crow.Die"}

-- 初始解锁/隐藏
CLASS.Unlocked = true
-- 隐藏（不在职业列表中显示）
CLASS.Hidden = true

-- 小型碰撞体积
CLASS.Hull = {Vector(-4, -4, 0), Vector(4, 4, 9)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-4, -4, 0), Vector(4, 4, 9)}
-- 视角偏移
CLASS.ViewOffset = Vector(0,0,8)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0,0,8)
-- 蹲伏行走速度倍率
CLASS.CrouchedWalkSpeed = 1
-- 台阶高度
CLASS.StepSize = 8
-- 质量（极轻）
CLASS.Mass = 2

-- 各种特殊属性
CLASS.NoUse = true          -- 不可使用
CLASS.NoGibs = true         -- 无尸体碎裂
CLASS.NoCollideAll = true   -- 不与其他实体碰撞
CLASS.NoFallDamage = true   -- 无摔落伤害
CLASS.NoFallSlowdown = true -- 无摔落减速
CLASS.NeverAlive = true     -- 从不被视为活着
CLASS.AllowTeamDamage = true-- 允许队友伤害
CLASS.NoDeaths = true       -- 不计入死亡
CLASS.Points = 0            -- 无得分

-- 缓存常量和键位
local ACT_RUN = ACT_RUN
local ACT_IDLE = ACT_IDLE
local ACT_FLY = ACT_FLY
local IN_JUMP = IN_JUMP
local IN_MOVELEFT = IN_MOVELEFT
local IN_MOVERIGHT = IN_MOVERIGHT
local IN_FORWARD = IN_FORWARD

-- 无死亡消息
function CLASS:NoDeathMessage(pl, attacker, dmginfo)
	return true
end

-- 不产生恐惧
function CLASS:DoesntGiveFear()
	return true
end

-- 伤害缩放（不做调整）
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

-- 无脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	-- 地面状态
	if pl:OnGround() then
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.IsPecking and wep:IsPecking() then
			return 1, 5  -- 啄击动画
		end

		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1  -- 奔跑
		end
		return ACT_IDLE, -1  -- 闲置
	end

	-- 高速飞行
	if velocity:LengthSqr() > 122500 then
		return ACT_FLY, -1  -- 快速飞行
	end
	return 1, 7  -- 普通滑翔
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)
	pl:SetPlaybackRate(1)
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end

-- 移动逻辑：空中飞行控制
function CLASS:Move(pl, mv)
	if not pl:GetActiveWeapon().IsCrow then return end

	-- 空中按住跳跃键飞行
	if not pl:IsOnGround() and pl:KeyDown(IN_JUMP) then
		local dir = mv:GetAngles()
		if pl:KeyDown(IN_MOVELEFT) then
			dir:RotateAroundAxis(dir:Up(), 20)
		elseif pl:KeyDown(IN_MOVERIGHT) then
			dir:RotateAroundAxis(dir:Up(), -20)
		end

		if pl:KeyDown(IN_FORWARD) then
			mv:SetVelocity(dir:Forward() * 450)
		else
			mv:SetVelocity(dir:Forward() * 300)
		end
		return true
	end
end

-- 服务端逻辑
if SERVER then
	-- 切换职业时恢复正常旋转
	function CLASS:SwitchedAway(pl)
		pl:SetAllowFullRotation(false)
	end

	-- 死亡处理
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		pl:SetAllowFullRotation(false)

		-- 统计乌鸦击杀数
		if attacker:IsPlayer() and attacker ~= pl and attacker:Team() == TEAM_HUMAN then
			attacker.CrowKills = attacker.CrowKills + 1
		end

		-- 低血量时触发血腥效果
		if pl:Health() < -45 then
			local amount = pl:OBBMaxs():Length()
			local vel = pl:GetVelocity()
			util.Blood(pl:LocalToWorld(pl:OBBCenter()), math.Rand(amount * 0.25, amount * 0.5), vel:GetNormalized(), vel:Length() * 0.75)
			return true
		elseif not pl.KnockedDown then
			pl:CreateRagdoll()
		end

		pl:SetHealth(pl:GetMaxHealth())
		pl:StripWeapons()
		pl:Spectate(OBS_MODE_ROAMING)
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 强制绘制本地玩家
function CLASS:ShouldDrawLocalPlayer(pl)
	return true
end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/crow"
