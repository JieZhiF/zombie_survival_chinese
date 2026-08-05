-- ============================================================================
-- weapon_zs_chemzombie/cl_init.lua - 化学僵尸喷吐武器（客户端）
-- 负责：声明显示名称与不绘制默认准星；仅在启用准星 ConVar 时绘制圆点准星
-- ============================================================================
INC_CLIENT()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_chemzombie")
-- 不绘制游戏默认准星
SWEP.DrawCrosshair = false

-- ==== Think - 每帧逻辑（客户端无需额外处理） ====
function SWEP:Think()
end

-- ==== DrawHUD - 绘制 HUD：按准星设置决定是否绘制圆点准星 ====
function SWEP:DrawHUD()
	-- 玩家关闭准星时跳过
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end
