-- ============================================================================
-- weapon_zs_devourer/cl_init.lua - 吞噬者僵尸（客户端）
-- 负责：声明显示名称、第一人称镜头 FOV，不绘制默认准星
-- ============================================================================
INC_CLIENT()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_devourer")

-- 第一人称镜头 FOV
SWEP.ViewModelFOV = 47
-- 不绘制游戏默认准星
SWEP.DrawCrosshair = false
