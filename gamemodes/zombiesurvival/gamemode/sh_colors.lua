-- ============================================================================
-- 颜色定义表 (sh_colors.lua)
-- 本文件定义了游戏中使用的所有颜色常量，包括基础颜色、暗色系、带透明度的颜色，
-- 以及颜色ID到Color对象的映射工具函数。
-- ============================================================================

-- ============================================================================
-- 基本颜色
-- ============================================================================

COLOR_GRAY = Color(190, 190, 190)       -- 灰色
COLOR_RED = Color(255, 0, 0)             -- 红色
COLOR_BLUE = Color(0, 0, 255)            -- 蓝色
COLOR_GREEN = Color(0, 255, 0)           -- 绿色
COLOR_LIMEGREEN = Color(50, 255, 50)     -- 酸橙色
COLOR_YELLOW = Color(255, 255, 0)        -- 黄色
COLOR_CYAN = Color(0, 255, 255)          -- 青色
COLOR_WHITE = Color(255, 255, 255)       -- 白色
COLOR_PURPLE = Color(255, 0, 255)        -- 紫色
COLOR_PINK = Color(255, 20, 100)         -- 粉色
COLOR_ORANGE = Color(255, 200, 0)        -- 橙色
COLOR_BROWN = Color(168, 94, 0)          -- 棕色
COLOR_TAN = Color(210, 180, 140)         -- 棕褐色
COLOR_LBLUE = Color(25, 50, 255)         -- 浅蓝色
COLOR_SOFTRED = Color(255, 40, 40)       -- 柔和红色

-- ============================================================================
-- 加亮颜色
-- ============================================================================

COLOR_RPURPLE = Color(200, 0, 200)       -- 亮紫色
COLOR_RPINK = Color(255, 100, 255)       -- 亮粉色
COLOR_RORANGE = Color(255, 128, 0)       -- 亮橙色

-- ============================================================================
-- 暗色系
-- ============================================================================

COLOR_DARKGRAY = Color(40, 40, 40)       -- 深灰色
COLOR_DARKRED = Color(185, 35, 35)       -- 深红色
COLOR_DARKGREEN = Color(0, 150, 0)       -- 深绿色
COLOR_DARKBLUE = Color(5, 75, 150)       -- 深蓝色

-- ============================================================================
-- 中间色
-- ============================================================================

COLOR_MIDGRAY = Color(140, 140, 140)     -- 中灰色

-- ============================================================================
-- 状态颜色
-- 用于表示玩家/物体的不同状态（友好、健康、受伤、濒死等）
-- ============================================================================

COLOR_FRIENDLY = COLOR_DARKGREEN         -- 友好（绿色）
COLOR_HEALTHY = COLOR_DARKGREEN          -- 健康（绿色）
COLOR_SCRATCHED = Color(80, 210, 0)      -- 轻伤（黄绿色）
COLOR_HURT = Color(150, 50, 0)           -- 受伤（橙色）
COLOR_CRITICAL = COLOR_DARKRED           -- 濒死（深红色）

-- ============================================================================
-- 半透明黑色
-- ============================================================================

color_black_alpha220 = Color(0, 0, 0, 220)  -- 黑色，透明度220
color_black_alpha200 = Color(0, 0, 0, 200)  -- 黑色，透明度200
color_black_alpha180 = Color(0, 0, 0, 180)  -- 黑色，透明度180
color_black_alpha120 = Color(0, 0, 0, 120)  -- 黑色，透明度120
color_black_alpha90 = Color(0, 0, 0, 90)    -- 黑色，透明度90

-- ============================================================================
-- 半透明白色
-- ============================================================================

color_white_alpha230 = Color(255, 255, 255, 230)  -- 白色，透明度230
color_white_alpha200 = Color(255, 255, 255, 200)  -- 白色，透明度200
color_white_alpha180 = Color(255, 255, 255, 180)  -- 白色，透明度180
color_white_alpha120 = Color(255, 255, 255, 120)  -- 白色，透明度120
color_white_alpha90 = Color(255, 255, 255, 90)    -- 白色，透明度90

-- ============================================================================
-- 颜色ID枚举
-- 用于网络传输等场景中的颜色标识
-- ============================================================================

COLORID_WHITE = 0    -- 白色ID
COLORID_BLACK = 1    -- 黑色ID
COLORID_RED = 2      -- 红色ID
COLORID_GREEN = 3    -- 绿色ID
COLORID_BLUE = 4     -- 蓝色ID
COLORID_YELLOW = 5   -- 黄色ID
COLORID_PURPLE = 6   -- 紫色ID
COLORID_CYAN = 7     -- 青色ID
COLORID_GRAY = 8     -- 灰色ID

-- ============================================================================
-- 颜色ID转Color对象映射表
-- ============================================================================

local colidtocolor = {
	[COLORID_WHITE] = COLOR_WHITE,
	[COLORID_BLACK] = color_black,
	[COLORID_RED] = COLOR_RED,
	[COLORID_GREEN] = COLOR_GREEN,
	[COLORID_BLUE] = COLOR_BLUE,
	[COLORID_YELLOW] = COLOR_YELLOW,
	[COLORID_PURPLE] = COLOR_PURPLE,
	[COLORID_CYAN] = COLOR_CYAN,
	[COLORID_GRAY] = COLOR_GRAY
}

-- ============================================================================
-- util.ColorIDToColor
-- 根据颜色ID获取对应的Color对象
-- @param id number - 颜色ID（COLORID_* 常量）
-- @param default Color|nil - 默认颜色，未找到时返回
-- @return Color - 对应的颜色对象，未找到时返回default或白色
-- ============================================================================

function util.ColorIDToColor(id, default)
	return colidtocolor[id] or default or COLOR_WHITE
end

-- ============================================================================
-- util.ColorCopy
-- 复制源颜色到目标颜色对象
-- @param source Color - 源颜色
-- @param dest Color - 目标颜色
-- @param copyalpha boolean - 是否同时复制透明度
-- ============================================================================

function util.ColorCopy(source, dest, copyalpha)
	dest.r = source.r
	dest.g = source.g
	dest.b = source.b
	if copyalpha then
		dest.a = source.a
	end
end
