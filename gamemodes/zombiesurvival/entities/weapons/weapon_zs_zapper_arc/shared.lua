-- ============================================================================
-- weapon_zs_zapper_arc/shared.lua - 电击器「弧形电链」（Zapper Arc）共享端
-- 负责：定义弧形电链的电击伤害、幽灵预览与部署实体
-- ============================================================================

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_zapper_arc")
SWEP.Description = ""..translate.Get("weapon_zs_zapper_arc_description")

-- 继承电击器基础模板（weapon_zs_zapper）
SWEP.Base = "weapon_zs_zapper"

-- 使用专属弹药类型（弧形电链）
SWEP.Primary.Ammo = "zapper_arc"

-- 部署前的幽灵预览状态与部署生成的实体
SWEP.GhostStatus = "ghost_zapper_arc"
SWEP.DeployClass = "prop_zapper_arc"

-- 电击伤害 45
SWEP.Primary.Damage = 45

-- 武器等级 4
SWEP.Tier = 4
