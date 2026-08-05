-- ============================================================================
-- weapon_zs_hammer_sp/cl_init.lua - 锤子 SP（客户端）：HUD 显示钉子数量与准星
-- 负责：客户端视野属性、DrawHUD 绘制剩余钉子数和准星圆点
-- ============================================================================
INC_CLIENT()

SWEP.ViewModelFOV = 75 -- 第一人称镜头视野

-- ==== DrawHUD - 绘制钉子剩余数量与准星圆点 ====
function SWEP:DrawHUD()
	-- 经典模式不绘制自定义 HUD
	if GetGlobalBool("classicmode") then return end

	local screenscale = BetterScreenScale() -- 屏幕缩放系数

	surface.SetFont("ZSHUDFont")
	local nails = self:GetPrimaryAmmoCount() -- 当前钉子数量
	local text = translate.Format("nails_x", nails) -- 本地化文本
	local nTEXW, nTEXH = surface.GetTextSize(text)

	-- 右下角显示钉子数量，没钉子时显示红色
	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - nTEXW * 0.75 - 32 * screenscale, ScrH() - nTEXH * 1.5, nails > 0 and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)

	-- 默认准星开启时才绘制自定义准星圆点
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end
