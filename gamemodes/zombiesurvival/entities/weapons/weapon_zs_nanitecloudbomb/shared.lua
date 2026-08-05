-- ============================================================================
-- weapon_zs_nanitecloudbomb/shared.lua - 纳米虫云炸弹（人类投掷武器）
-- 负责：定义纳米虫云炸弹的名称、模型与弹药设置
-- ============================================================================
-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_nanitecloudbomb")
SWEP.Description = ""..translate.Get("weapon_zs_nanitecloudbomb_description")

-- 基于投掷武器母本
SWEP.Base = "weapon_zs_basethrown"

-- 视图模型与第三人称模型（借用手雷与药瓶模型）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/healthvial.mdl"

-- 显示视图模型，隐藏第三人称模型
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

-- 消耗的弹药类型
SWEP.Primary.Ammo = "nanitecloudbomb"

-- 最大携带量
SWEP.MaxStock = 12
