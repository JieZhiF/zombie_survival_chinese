-- ============================================================================
-- weapon_zs_grenade/shared.lua - 手雷（投掷爆炸物，共享端定义）
-- 负责：手雷的基础属性与携带上限
-- ============================================================================
-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_grenade")
SWEP.Description = ""..translate.Get("weapon_zs_grenade_description")

-- 继承投掷武器基础（提供投掷与引信逻辑）
SWEP.Base = "weapon_zs_basethrown"

-- 携带上限（背包可存数量）
SWEP.MaxStock = 8
