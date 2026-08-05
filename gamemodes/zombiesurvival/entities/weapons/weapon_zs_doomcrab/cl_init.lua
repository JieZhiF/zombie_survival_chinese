-- ============================================================================
-- weapon_zs_doomcrab/cl_init.lua - 僵尸近战武器「末日蟹钳」（Doomcrab）客户端
-- 负责：武器名称、准星隐藏与 HUD 准星圆点绘制
-- ============================================================================

INC_CLIENT()

-- 武器显示名称（由语言文件提供）；隐藏游戏默认准星
SWEP.PrintName = ""..translate.Get("weapon_zs_doomcrab")
SWEP.DrawCrosshair = false

-- ==== DrawHUD - 绘制 HUD：按玩家准星设置绘制准星圆点 ====
function SWEP:DrawHUD()
	-- 玩家准星开关（crosshair 指令）关闭时不做绘制
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== DrawWeaponSelection - 武器选择界面绘制（调用基础实现） ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
