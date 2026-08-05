-- ============================================================================
-- status_fastreload/shared.lua - 快速装填状态（共享）
-- 负责：提供状态时长/开始时间的网络同步字段；客户端在初始化时
--       注册绘制特效（Draw）以展示增益光效
-- ============================================================================
AddCSLuaFile()

-- 实体类型为动画实体，继承 status__base 状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

 
-- 状态持续时间（秒）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 状态开始时间（CurTime 时间戳）
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：客户端注册绘制监听 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if CLIENT then
		-- 客户端：绘制增益光效
		hook.Add("Draw", self, self.Draw)
	end
end

-- ==== PlayerSet - 附加到玩家：记录状态开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
