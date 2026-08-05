-- ============================================================================
-- cl_init.lua - 猎头蟹武器客户端脚本
-- 负责：设置武器显示名称与准星显示，绘制 HUD 准星点与武器选择界面
-- ============================================================================
INC_CLIENT()

-- 武器显示名称（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_headcrab")
-- 不使用游戏默认准星，由 DrawHUD 自行绘制中心点
SWEP.DrawCrosshair = false

-- ==== DrawHUD - 绘制猎头蟹的 HUD 准星点 ====
-- 仅当控制台准星 ConVar 开启时绘制瞄准中心点
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== DrawWeaponSelection - 绘制武器选择界面 ====
-- 直接复用父类的基础绘制逻辑
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
