-- ============================================================================
-- weapon_zs_coolwisp/cl_init.lua - 寒冰幽灵武器（客户端）
-- 负责：隐藏十字准星，并沿用基础武器的武器选择界面绘制
-- ============================================================================
INC_CLIENT()

-- 隐藏十字准星（使用自定义瞄准界面）
SWEP.DrawCrosshair = false

-- ==== DrawWeaponSelection - 绘制武器选择界面 ====
-- 沿用基础武器（weapon_zs_base）的选择界面绘制逻辑
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
