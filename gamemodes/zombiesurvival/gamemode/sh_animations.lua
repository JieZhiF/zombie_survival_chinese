-- ============================================================================
-- 动画系统 (sh_animations.lua)
-- 本文件负责处理和优化玩家的动画，根据玩家的移动状态（跑、跳、蹲、游泳）、
-- 所属团队（人类或僵尸）以及是否携带物品来计算和更新正确的动画序列。
-- 动画已进行大量优化以提高性能。
-- ============================================================================

-- GM:PlayerShouldTaunt 判断玩家是否应该执行嘲讽动作
-- GM:CalcMainActivity 根据玩家的速度和状态（如跳跃、蹲伏、游泳）计算其主要动画活动
-- GM:UpdateAnimation 根据玩家的移动速度更新动画的播放速率
-- GM:DoAnimationEvent 处理动画事件，如头部受创的退缩动画
-- GM:TranslateActivity 当玩家携带物体时，转换其动画活动到相应的持物动画

local TEAM_UNDEAD = TEAM_UNDEAD
local ACT_MP_STAND_IDLE = ACT_MP_STAND_IDLE
local ACT_MP_RUN = ACT_MP_RUN
local ACT_MP_WALK = ACT_MP_WALK
local ACT_MP_JUMP = ACT_MP_JUMP
local ACT_MP_CROUCHWALK = ACT_MP_CROUCHWALK
local ACT_MP_CROUCH_IDLE = ACT_MP_CROUCH_IDLE
local GESTURE_SLOT_JUMP = GESTURE_SLOT_JUMP
local ACT_LAND = ACT_LAND
local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
local math_min = math.min
local math_max = math.max
local CLIENT = CLIENT
local PLAYERANIMEVENT_FLINCH_HEAD = PLAYERANIMEVENT_FLINCH_HEAD
local CurTime = CurTime
local IsValid = IsValid

local M_Player = FindMetaTable("Player")
local M_Entity = FindMetaTable("Entity")
local P_Team = M_Player.Team
local P_GetZombieClassTable = M_Player.GetZombieClassTable
local P_AnimRestartGesture = M_Player.AnimRestartGesture
local P_AnimRestartMainSequence = M_Player.AnimRestartMainSequence
local P_Crouching = M_Player.Crouching
local P_DoFlinchAnim = M_Player.DoFlinchAnim
local P_IsCarrying = M_Player.IsCarrying
local P_CallZombieFunction = M_Player.CallZombieFunction
local P_Alive = M_Player.Alive
local E_OnGround = M_Entity.OnGround
local E_GetTable = M_Entity.GetTable
local E_WaterLevel = M_Entity.WaterLevel
local E_SetPlaybackRate = M_Entity.SetPlaybackRate
-- 这些变量通过__index不会被销毁，但放在这里也无妨
local M_Vector = FindMetaTable("Vector")
local V_Length2D = M_Vector.Length2D
local V_Length2DSqr = M_Vector.Length2DSqr
local V_LengthSqr = M_Vector.LengthSqr

local onground, tab, len2d, waterlevel, ideal, override, pt

-- ============================================================================
-- PlayerShouldTaunt
-- 判断玩家是否可以执行嘲讽动作
-- 要求：玩家存活且是人类，或者是允许嘲讽的僵尸
-- @param pl Player - 玩家对象
-- @param actid number - 动作ID
-- @return boolean - 是否可嘲讽
-- ============================================================================

function GM:PlayerShouldTaunt(pl, actid)
	pt = E_GetTable(pl)

	return P_Alive(pl) and (P_Team(pl) == TEAM_HUMAN or P_Team(pl) == TEAM_UNDEAD and P_GetZombieClassTable(pl).CanTaunt) and not IsValid(pt.Revive) and not IsValid(pt.FeignDeath)
end

-- ============================================================================
-- CalcMainActivity
-- 根据玩家移动速度和状态计算主要动画活动
-- 处理逻辑：僵尸类自定义动作 -> 落地 -> 跳跃 -> 蹲伏 -> 游泳 -> 跑步 -> 行走 -> 待机
-- @param pl Player - 玩家对象
-- @param velocity Vector - 当前速度向量
-- @return ideal number - 理想活动ID
-- @return override number - 覆盖参数（-1表示不覆盖）
-- ============================================================================

function GM:CalcMainActivity(pl, velocity)
	pt = E_GetTable(pl)

	-- 僵尸类：优先使用自定义动画计算
	if P_Team(pl) == TEAM_UNDEAD then
		tab = P_GetZombieClassTable(pl)
		if tab.CalcMainActivity then
			ideal, override = tab:CalcMainActivity(pl, velocity)
			if ideal then
				return ideal, override
			end
		end
	end

	-- 落地处理
	onground = E_OnGround(pl)
	if onground and not pt.m_bWasOnGround then
		P_AnimRestartGesture(pl, GESTURE_SLOT_JUMP, ACT_LAND, true)
		pt.m_bWasOnGround = true
	end

	-- 跳跃处理
	-- 空气行走类似HL2MP：在速度为零之前保持空气行走，之后切换到跳跃动画
	-- 水下则正常空气行走
	waterlevel = E_WaterLevel(pl)
	if pt.m_bJumping then
		if pt.m_bFirstJumpFrame then
			pt.m_bFirstJumpFrame = false
			P_AnimRestartMainSequence(pl)
		end

		if waterlevel >= 2 or CurTime() - pt.m_flJumpStartTime > 0.2 and onground then
			pt.m_bJumping = false
			pt.m_fGroundTime = nil
			P_AnimRestartMainSequence(pl)
		else
			return ACT_MP_JUMP, -1
		end
	elseif not onground and waterlevel <= 0 then
		if not pt.m_fGroundTime then
			pt.m_fGroundTime = CurTime()
		elseif CurTime() > pt.m_fGroundTime and V_Length2D(velocity) < 0.5 then
			pt.m_bJumping = true
			pt.m_bFirstJumpFrame = false
			pt.m_flJumpStartTime = 0
		end
	end

	-- 蹲伏处理
	if P_Crouching(pl) then
		if V_Length2DSqr(velocity) >= 1 then
			return ACT_MP_CROUCHWALK, -1
		end

		return ACT_MP_CROUCH_IDLE, -1
	end

	-- 游泳处理
	if not onground and waterlevel >= 2 then
		return ACT_MP_SWIM, -1
	end

	-- 根据速度选择跑步或行走
	len2d = V_Length2DSqr(velocity)
	if len2d >= 22500 then -- 150^2，跑步阈值
		return ACT_MP_RUN, -1
	end

	if len2d >= 1 then
		return ACT_MP_WALK, -1
	end

	return ACT_MP_STAND_IDLE, -1
end

--local wep
local len
local rate

-- ============================================================================
-- UpdateAnimation
-- 根据移动速度更新动画播放速率
-- 水下强制最低播放速率0.5
-- 客户端额外更新耳朵动画
-- @param pl Player - 玩家对象
-- @param velocity Vector - 当前速度向量
-- @param maxseqgroundspeed number - 序列最大地面速度
-- ============================================================================

function GM:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if P_CallZombieFunction(pl, "UpdateAnimation", velocity, maxseqgroundspeed) then return end

	len = V_LengthSqr(velocity)

	if len > 1 then
		rate = math_min(len / maxseqgroundspeed ^ 2, 2)
	else
		rate = 1
	end

	-- 水下保持持续游泳动画
	if E_WaterLevel(pl) >= 2 then
		rate = math_max(rate, 0.5)
	end

	E_SetPlaybackRate(pl, rate)

	if CLIENT then
		GAMEMODE:GrabEarAnimation(pl)
		--GAMEMODE:MouthMoveAnimation(pl) -- 已损坏?
	end
end

local eact

-- ============================================================================
-- DoAnimationEvent
-- 处理动画事件，如头部受创的后仰动画
-- @param pl Player - 玩家对象
-- @param event number - 动画事件类型
-- @param data number - 事件数据
-- @return mixed - 自定义动画事件结果，或调用基类方法
-- ============================================================================

function GM:DoAnimationEvent(pl, event, data)
	eact = P_CallZombieFunction(pl, "DoAnimationEvent", event, data)
	if eact then return eact end

	if event == PLAYERANIMEVENT_FLINCH_HEAD then
		return P_DoFlinchAnim(pl, data)
	end

	return self.BaseClass:DoAnimationEvent(pl, event, data)
end

-- ============================================================================
-- 持物动画转换表
-- 将普通动画映射到对应的持物动画（搬运物体时的动画覆盖）
-- ============================================================================

local CarryingActivityTranslate = {}
CarryingActivityTranslate[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_SLAM
CarryingActivityTranslate[ACT_MP_WALK] = ACT_HL2MP_IDLE_SLAM + 1
CarryingActivityTranslate[ACT_MP_RUN] = ACT_HL2MP_IDLE_SLAM + 2
CarryingActivityTranslate[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_SLAM + 3
CarryingActivityTranslate[ACT_MP_CROUCHWALK] = ACT_HL2MP_IDLE_SLAM + 4
CarryingActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_IDLE_SLAM + 5
CarryingActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_IDLE_SLAM + 5
CarryingActivityTranslate[ACT_MP_RELOAD_STAND] = ACT_HL2MP_IDLE_SLAM + 6
CarryingActivityTranslate[ACT_MP_RELOAD_CROUCH] = ACT_HL2MP_IDLE_SLAM + 6
CarryingActivityTranslate[ACT_MP_JUMP] = ACT_HL2MP_IDLE_SLAM + 7
CarryingActivityTranslate[ACT_RANGE_ATTACK1] = ACT_HL2MP_IDLE_SLAM + 8

-- ============================================================================
-- TranslateActivity
-- 当玩家携带物体时，将当前动画活动转换为对应的持物动画
-- @param pl Player - 玩家对象
-- @param act number - 当前活动ID
-- @return number - 转换后的活动ID
-- ============================================================================

function GM:TranslateActivity(pl, act)
	if P_IsCarrying(pl) then
		return CarryingActivityTranslate[act] or act
	end

	return self.BaseClass:TranslateActivity(pl, act)
end
