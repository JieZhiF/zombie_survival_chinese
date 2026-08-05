-- ============================================================================
-- weapon_zs_extinctioncrab/cl_init.lua - 灭绝螃蟹（客户端逻辑）
-- 负责：客户端显示名称、准星绘制与武器选择界面
-- ============================================================================
INC_CLIENT()

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_extinctioncrab")
-- 不绘制默认准星
SWEP.DrawCrosshair = false

-- ==== DrawHUD - 绘制 HUD 准星：开启准星 ConVar 时绘制点状准星 ====
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== DrawWeaponSelection - 武器选择菜单绘制（沿用母本实现） ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
