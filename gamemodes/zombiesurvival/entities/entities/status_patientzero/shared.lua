-- ============================================================================
-- status_patientzero - 患者零号（Patient Zero）状态实体（共享端）
-- 负责：注册双端钩子：服务端监听伤害事件、客户端绘制标识粒子，双端加速持有者移动
-- ============================================================================

-- 实体类型：动画实体，继承状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- 瞬时状态：不长期存在，随持有者状态变化而移除
ENT.Ephemeral = true

-- ==== Initialize - 调用基类初始化并注册对应端的伤害/绘制钩子与双端移动钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 服务端：监听全局伤害事件（输出增强与受伤调整）
	if SERVER then
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)

		self:SetDTInt(1, 0)
	end

	-- 客户端：每帧绘制标识粒子
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end

	-- 双端：加速持有者的移动速度
	hook.Add("Move", self, self.Move)
end

-- ==== Move - 持有者移动时额外提升 20 单位/秒的最大速度 ====
function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(move:GetMaxSpeed() + 20)
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end
