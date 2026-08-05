-- ============================================================================
-- weapon_zs_crygasgrenade/shared.lua - 冷冻气体手雷（共享端）
-- 负责：定义投掷物的弹药类型、模型隐藏与商店库存
-- ============================================================================

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_crygasgrenade")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_crygasgrenade_description")

-- 母本：投掷武器基础
SWEP.Base = "weapon_zs_basethrown"

-- 隐藏第一人称模型（外观由附加模型拼装）
SWEP.ShowViewModel = false
-- 隐藏世界模型
SWEP.ShowWorldModel = false

-- 消耗的投掷弹药类型：冷冻气体手雷
SWEP.Primary.Ammo = "crygasgrenade"

-- 商店最大库存 6 个
SWEP.MaxStock = 6
