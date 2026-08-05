-- ============================================================================
-- weapon_zs_poisonheadcrab/cl_init.lua - 毒头蟹僵尸武器（客户端）
-- 负责：客户端显示逻辑，隐藏默认准星改为自绘准星点、武器选择图标绘制
-- ============================================================================
INC_CLIENT()

-- 第一人称视野大小
SWEP.ViewModelFOV = 70
-- 不绘制默认十字准星（改为自绘准星点）
SWEP.DrawCrosshair = false

-- ==== DrawHUD - 绘制 HUD ====
function SWEP:DrawHUD()
	-- 玩家关闭准星时跳过绘制
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	-- 绘制屏幕中央的准星点
	self:DrawCrosshairDot()
end

-- ==== DrawWeaponSelection - 绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	-- 使用基础类的标准绘制方式
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
