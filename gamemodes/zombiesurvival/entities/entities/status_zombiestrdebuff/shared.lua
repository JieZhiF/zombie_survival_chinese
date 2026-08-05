-- ============================================================================
-- status_zombiestrdebuff/shared.lua - 僵尸力量削弱状态（共享）
-- 负责：声明状态实体类型并注册钩子——服务器端注册伤害放大与伤害归属
--       钩子（僵尸受人类伤害提升，加成部分记入施放者名下），客户端
--       注册绘制钩子用于红色粒子特效
-- ============================================================================

-- 动画实体类型（可附着在拥有者身上跟随移动）
ENT.Type = "anim"
-- 继承通用状态实体基类，复用生命周期管理
ENT.Base = "status__base"

-- ==== Initialize - 初始化：调用基类并按运行端注册钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 服务器端：注册伤害放大与伤害归属钩子（以自身为标识，移除时自动清理）
	if SERVER then
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
		hook.Add("PlayerHurt", self, self.PlayerHurt)

		-- 清零伤害计数器（DT Int 槽 1）
		self:SetDTInt(1, 0)
	end

	-- 客户端：注册绘制钩子（红色削弱粒子特效）
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end
