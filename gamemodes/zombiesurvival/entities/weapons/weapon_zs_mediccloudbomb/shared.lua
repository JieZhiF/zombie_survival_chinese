-- ============================================================================
-- weapon_zs_mediccloudbomb/shared.lua - 医疗烟雾弹（投掷型治疗辅助武器）
-- 负责：定义医疗烟雾弹的基础属性，投掷后落地生成治疗烟雾
-- ============================================================================

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_mediccloudbomb")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_mediccloudbomb_description")

-- 继承投掷类武器基类
SWEP.Base = "weapon_zs_basethrown"

-- 第一人称视角模型（手雷模型）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
-- 第三人称世界模型（医疗瓶）
SWEP.WorldModel = "models/healthvial.mdl"

-- 显示第一人称模型、隐藏世界模型（实际外观由附加模型拼装）
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

-- 主攻击使用的弹药类型：医疗烟雾弹
SWEP.Primary.Ammo = "mediccloudbomb"

-- 可同时持有的最大库存数量
SWEP.MaxStock = 12
