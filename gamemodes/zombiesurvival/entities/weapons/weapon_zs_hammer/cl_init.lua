-- ============================================================================
-- weapon_zs_hammer/cl_init.lua - 锤子（客户端入口）
-- 负责：客户端栏位设置，以及 HUD 上钉子数量显示与准星绘制
-- ============================================================================

INC_CLIENT()
-- 武器栏位：维修工具栏
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRepairTools")
SWEP.SlotGroup = WEPSELECT_REPAIR_TOOL
-- 第一人称镜头视野大小
SWEP.ViewModelFOV = 75

-- ==== DrawHUD - 绘制钉子数量 HUD 与准星 ====
function SWEP:DrawHUD()
	-- 经典模式下不绘制
	if GetGlobalBool("classicmode") then return end

	local screenscale = BetterScreenScale()

	-- 在屏幕右下角显示剩余钉子数量，颜色随数量变化（有钉子为亮绿，无钉子为红色）
	surface.SetFont("ZSHUDFont")
	local nails = self:GetPrimaryAmmoCount()
	local text = translate.Format("nails_x", nails)
	local nTEXW, nTEXH = surface.GetTextSize(text)

	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - nTEXW * 0.75 - 32 * screenscale, ScrH() - nTEXH * 1.5, nails > 0 and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)

	-- 游戏默认准星开启时才绘制自己的准星点
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end
