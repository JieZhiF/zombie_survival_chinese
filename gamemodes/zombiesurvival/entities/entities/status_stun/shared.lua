-- ============================================================================
-- status_stun/shared.lua - 眩晕状态实体（共享端）
-- 负责：定义眩晕状态使用的模型与短暂存在属性
-- ============================================================================

ENT.Type = "anim"
ENT.Base = "status__base"

-- 眩晕提示用的玻璃碎片模型（缩放至极小，仅作为渲染锚点）
ENT.Model = Model("models/effects/splodeglass.mdl")

-- 短暂存在型状态（玩家死亡/移除时自动清理）
ENT.Ephemeral = true

-- ==== Initialize - 初始化 ====
-- 调用基类初始化，设置不可见的微型模型作为眩晕标记
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 设置微小模型并关闭阴影（本体不可见）
	self:SetModel(self.Model)
	self:SetModelScale(0.05, 0)
	self:DrawShadow(false)

end
