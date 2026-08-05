-- ============================================================================
-- weapon_zs_drone_hauler.lua - 搬运无人机（放置型武器）
-- 负责：定义可部署的搬运无人机：部署实体与弹药消耗规则
-- ============================================================================
AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_drone")

-- 基于无人机放置武器母本
SWEP.Base = "weapon_zs_drone"

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_drone_hauler")
SWEP.Description = ""..translate.Get("weapon_zs_drone_hauler_description")

-- 部署消耗的弹药类型
SWEP.Primary.Ammo = "drone_hauler"

-- 部署后生成的无人机实体
SWEP.DeployClass = "prop_drone_hauler"
-- 部署不额外消耗弹药类型（无弹药限制）
SWEP.DeployAmmoType = false
-- 无补给弹药类型
SWEP.ResupplyAmmoType = nil
