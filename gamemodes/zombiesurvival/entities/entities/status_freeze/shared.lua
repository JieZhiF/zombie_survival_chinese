-- ============================================================================
-- shared.lua - 冰冻 buff 状态（共享）：时长同步与阶段计算
-- 负责：定义冰冻累积时长的网络同步，以及按剩余时长划分的阶段计算：
--       阶段1 轻微减速 / 阶段2 重度减速 / 阶段3 完全冻结（定身+禁攻+尖刺）
--       阶段阈值见 sh_globals.lua 的 FREEZE_SLOW_DURATION / FREEZE_FULL_DURATION
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 继承通用状态基类（提供状态叠加/计时框架）
ENT.Base = "status__base"

-- 瞬时状态：死亡/换队等重置时不保留
ENT.Ephemeral = true

-- 冰冻累积总时长（秒），经 DT 同步到客户端
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 冰冻开始时间（服务器时间戳），用于计算剩余时长
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：播放冻结音效并注册客户端视觉钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		-- 服务端播放玻璃碎裂音效（冻结生效音）
		self:EmitSound("physics/glass/glass_impact_bullet"..math.random(4)..".wav", 70, 85)
	end

	if CLIENT then
		-- 客户端注册屏幕全屏特效钩子（模型染色由 GM:_PrePlayerDraw 统一处理）
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)
	end
end

-- ==== PlayerSet - 状态附加到玩家：记录开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

-- ==== GetRemaining - 剩余累积时长（秒） ====
function ENT:GetRemaining()
	return math.max(0, self:GetStartTime() + self:GetDuration() - CurTime())
end

-- ==== GetStage - 按剩余时长计算冰冻阶段 ====
-- 0 无效果 / 1 轻微减速 / 2 重度减速 / 3 完全冻结
function ENT:GetStage()
	local remain = self:GetRemaining()
	if remain >= FREEZE_FULL_DURATION then return 3 end
	if remain >= FREEZE_SLOW_DURATION then return 2 end
	if remain > 0 then return 1 end
	return 0
end

-- ==== IsFullyFrozen - 是否处于完全冻结（阶段3） ====
function ENT:IsFullyFrozen()
	return self:GetStage() == 3
end

-- ==== GetSlowFactor - 当前阶段的速度倍率 ====
function ENT:GetSlowFactor()
	local stage = self:GetStage()
	if stage == 1 then return 0.6 end
	if stage == 2 then return 0.25 end
	return 1
end