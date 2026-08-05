-- ============================================================================
-- shared.lua - 电击减益状态（共享）
-- 负责：定义状态基类并挂接客户端绘制钩子（电击粒子特效在 cl_init 中实现）
-- ============================================================================
-- 基于 anim 实体类型，继承状态类基座 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- 瞬时状态（不常驻在玩家状态栏，随效果结束立即移除）
ENT.Ephemeral = true

-- ==== Initialize - 初始化并挂接绘制钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 客户端每帧调用本实体的 Draw 绘制电击特效
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end
