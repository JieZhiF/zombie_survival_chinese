-- ============================================================================
-- status_spawnslow/shared.lua - 出生减速状态实体（共享端）
-- 负责：持续时间内限制玩家移动速度，并注册移动/屏幕效果钩子
-- ============================================================================

ENT.Type = "anim"
ENT.Base = "status__base"

-- 网络变量：状态持续时间 / 状态开始时间
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化 ====
-- 调用基类初始化，生成随机种子并注册移动与屏幕特效钩子
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 随机种子（用于特效随机变化）
	self.Seed = math.Rand(0, 10)

	-- 客户端注册屏幕空间特效钩子（绿色视觉滤镜）
	if CLIENT then
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)
	end

	-- 注册移动钩子（限制速度）
	hook.Add("Move", self, self.Move)
end

-- ==== Move - 移动限制 ====
-- 将持有者的移动速度限制为 40%（减速效果）
function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	-- 速度保留比例
	local sloweffect = 0.4

	move:SetMaxSpeed(move:GetMaxSpeed() * sloweffect)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * sloweffect)
end

-- ==== PlayerSet - 玩家绑定回调 ====
-- 状态附加到玩家时记录开始时间（用于计算剩余效果强度）
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
