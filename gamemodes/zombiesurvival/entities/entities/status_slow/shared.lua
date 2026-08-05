-- ============================================================================
-- status_slow/shared.lua - 减速状态（共享）
-- 负责：减速负面状态的实体定义——通过 Move 钩子按比例削减拥有者的
--       移动速度（受 SlowEffTakenMul 抗性系数影响），并注册客户端
--       绘制钩子用于减速视觉特效
-- ============================================================================

-- 动画实体类型（可附着在拥有者身上跟随移动）
ENT.Type = "anim"
-- 继承通用状态实体基类，复用生命周期管理
ENT.Base = "status__base"

-- 瞬时状态标记：玩家死亡/状态重置时一并清除
ENT.Ephemeral = true

-- 数据表同步：持续时间（DT Float 槽 0）与起始时间（DT Float 槽 4）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：调用基类、生成随机种子并注册钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 随机种子，供客户端粒子/视觉扰动使用
	self.Seed = math.Rand(0, 10)

	-- 注册移动钩子以施加减速（以自身为标识，移除时自动清理）
	hook.Add("Move", self, self.Move)

	-- 客户端注册绘制钩子（减速视觉特效）
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end

-- ==== Move - 移动减速：按比例削减拥有者的最大移动速度 ====
function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	-- 基础减速 40%（速度乘 0.6），SlowEffTakenMul 为受减速倍率：
	-- 0 则完全免疫，数值越大减速越强
	local sloweffect = 1 - 0.4 * (pl.SlowEffTakenMul or 1)

	move:SetMaxSpeed(move:GetMaxSpeed() * sloweffect)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * sloweffect)
end

-- ==== PlayerSet - 状态附加到玩家身上时记录起始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
