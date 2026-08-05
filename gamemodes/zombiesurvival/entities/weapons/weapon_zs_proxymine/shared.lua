-- ============================================================================
-- weapon_zs_proxymine/shared.lua - 感应地雷（投掷型陷阱武器）
-- 负责：定义感应地雷的基础属性，投掷后落地成为触发式爆炸地雷
-- ============================================================================

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_proxymine")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_proxymine_description")

-- 继承投掷类武器基类
SWEP.Base = "weapon_zs_basethrown"

-- 隐藏第一人称与第三人称模型（本体只是出手动作，地雷实体在投掷后生成）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 主攻击使用的弹药类型：betty（阔剑地雷弹药，限制携带量）
SWEP.Primary.Ammo = "betty"

-- 可同时持有的最大库存数量
SWEP.MaxStock = 8
