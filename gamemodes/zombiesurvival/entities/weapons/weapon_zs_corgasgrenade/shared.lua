-- ============================================================================
-- shared.lua - 腐蚀气体手雷（共享端）
-- 负责：投掷武器属性，爆炸后释放腐蚀性毒气
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_zs_corgasgrenade") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_corgasgrenade_description") -- 武器描述

SWEP.Base = "weapon_zs_basethrown" -- 继承投掷武器基类

SWEP.ShowViewModel = false -- 不显示默认第一人称模型（使用自定义部件拼装）
SWEP.ShowWorldModel = false -- 不显示默认第三人称模型

SWEP.Primary.Ammo = "corgasgrenade" -- 消耗的弹药类型（腐蚀气体手雷）

SWEP.MaxStock = 6 -- 商店最大库存
