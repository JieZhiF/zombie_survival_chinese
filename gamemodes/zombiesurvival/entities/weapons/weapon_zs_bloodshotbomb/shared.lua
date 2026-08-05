-- ============================================================================
-- shared.lua - 血弹炸弹武器共享定义
-- 负责：定义可投掷血弹炸弹的基础属性——隐藏默认模型、消耗血弹弹药、
--       场上最大持有数量限制
-- ============================================================================
-- 武器显示名称与描述（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_bloodshotbomb")
SWEP.Description = ""..translate.Get("weapon_zs_bloodshotbomb_description")

-- 继承自投掷物武器基类
SWEP.Base = "weapon_zs_basethrown"

-- 隐藏默认模型（改用客户端 SCK 自定义部件拼装外观）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 消耗的弹药类型（血弹）
SWEP.Primary.Ammo = "bloodshot"

-- 场上最大持有数量
SWEP.MaxStock = 6
