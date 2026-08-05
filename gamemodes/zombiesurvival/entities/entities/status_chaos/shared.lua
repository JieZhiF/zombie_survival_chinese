-- ============================================================================
-- status_chaos/shared.lua - 混乱状态（共享）
-- 负责：混乱（混沌）负面状态的实体定义——记录持续时间与起始时间，
--       并在客户端注册绘制钩子以叠加混乱视觉特效
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型（可附着在拥有者身上跟随移动）
ENT.Type = "anim"
-- 继承通用状态实体基类，复用生命周期管理
ENT.Base = "status__base"

-- 数据表同步：持续时间（DT Float 槽 0）与起始时间（DT Float 槽 4）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：调用基类并在客户端注册绘制钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 客户端注册 Draw 钩子（混乱视觉特效的实现位于 cl_init.lua）
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end

-- ==== PlayerSet - 状态附加到玩家身上时记录起始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
