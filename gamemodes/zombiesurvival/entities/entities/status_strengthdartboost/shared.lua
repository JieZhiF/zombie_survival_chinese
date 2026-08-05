-- ============================================================================
-- status_strengthdartboost/shared.lua - 力量针剂强化状态（共享）
-- 负责：记录强化持续时间与开始时间；服务器端注册实体伤害钩子以
--       施加/叠加力量强化效果，客户端注册绘制钩子显示红色强化粒子
-- ============================================================================
ENT.Type = "anim"
ENT.Base = "status__base"

-- DT 访问器：状态持续时间与开始时间（同步至客户端）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 状态附加到玩家时记录开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

-- ==== Initialize - 初始化基础状态并注册各端钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 服务器端：监听实体伤害事件用于力量强化加成
	if SERVER then
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)

		-- 清空强化计数槽位
		self:SetDTInt(1, 0)
	end

	-- 客户端：监听绘制事件用于红色强化特效
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end
