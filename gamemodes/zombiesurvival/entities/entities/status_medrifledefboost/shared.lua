-- ============================================================================
-- status_medrifledefboost/shared.lua - 医疗步枪防御增益状态（共享）
-- 负责：为拥有者挂载减伤增益；服务器端注册伤害监听（EntityTakeDamage），
--       客户端注册绘制特效（Draw），两端的挂载时机集中在初始化中完成
-- ============================================================================
-- 实体类型为动画实体，继承 status__base 状态基类
ENT.Type = "anim"
ENT.Base = "status__base"


-- 状态持续时间（秒）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 状态开始时间（CurTime 时间戳）
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 附加到玩家：记录状态开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

-- ==== Initialize - 初始化：服务器挂伤害监听，客户端挂绘制监听 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		-- 服务器：监听伤害事件，实现减伤与积分结算
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)

		-- 重置客户端展示用的 DT 数据位
		self:SetDTInt(1, 0)
	end

	if CLIENT then
		-- 客户端：绘制增益光效
		hook.Add("Draw", self, self.Draw)
	end
end
