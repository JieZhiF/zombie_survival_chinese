-- ============================================================================
-- weapon_zs_bonemesh/cl_init.lua - 骨甲僵尸爪武器（客户端部分）
-- 负责：客户端显示名称、视野与准星设置；禁用右键攻击和换弹
-- ============================================================================
INC_CLIENT() -- 客户端专用文件标记

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_bonemesh")
SWEP.ViewModelFOV = 47 -- 第一人称视野大小
SWEP.DrawCrosshair = false -- 不绘制准星

-- ==== SecondaryAttack - 右键（空实现，禁用） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（空实现，禁用） ====
function SWEP:Reload()
end
