-- ============================================================================
-- boss_coolwisp/client.lua - 寒冰鬼火 (Cool Wisp) BOSS 客户端逻辑
-- 负责：击杀图标（发光精灵材质，蓝色）与绘制前拦截
-- ============================================================================

include("shared.lua")

-- 击杀图标（使用发光精灵材质）
CLASS.Icon = "sprites/glow04_noz"
-- 图标颜色（冰蓝色）
CLASS.IconColor = Color(0, 180, 255)

-- ==== PrePlayerDraw - 拦截默认绘制（模型由特效呈现） ====
function CLASS:PrePlayerDraw(pl)
	return true
end
