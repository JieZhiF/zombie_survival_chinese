-- ============================================================================
-- weapon_zs_zapper_arc_ex/shared.lua - 电弧扩展版电击陷阱（Zapper Arc EX）
-- 负责：定义扩展版电击陷阱的属性（伤害、弹药与部署实体）
-- ============================================================================
-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_zapper_arc_ex")
-- 武器商店描述（无获取渠道，仅作占位）
SWEP.Description = "没获取渠道要什么描述？"

-- 继承的基础电击陷阱武器
SWEP.Base = "weapon_zs_zapper"

-- 部署时消耗的弹药类型
SWEP.Primary.Ammo = "zapper_arc_ex"

-- 放置预览（幽灵）状态实体
SWEP.GhostStatus = "ghost_zapper_arc_ex"
-- 实际部署的陷阱实体
SWEP.DeployClass = "prop_zapper_arc_ex"

-- 陷阱对触碰僵尸造成的伤害
SWEP.Primary.Damage = 45

-- 武器等级（Tier 4）
SWEP.Tier = 4
