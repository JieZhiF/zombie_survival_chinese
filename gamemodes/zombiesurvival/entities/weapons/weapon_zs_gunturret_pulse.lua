-- ============================================================================
-- weapon_zs_gunturret_pulse.lua - 脉冲减速炮台（Gunturret Pulse）
-- 负责：定义可部署脉冲炮台的伤害、弹药与部署实体
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()

-- 继承的基础炮台武器
SWEP.Base = "weapon_zs_gunturret"

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_pulse")
-- 武器商店描述（部署与操作说明）
SWEP.Description = "A high powered turret that can fire pulse slowing shots.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

-- 炮台单发伤害
SWEP.Primary.Damage = 30

-- 放置预览（幽灵）状态实体
SWEP.GhostStatus = "ghost_gunturret_pulse"
-- 实际部署的炮台实体
SWEP.DeployClass = "prop_gunturret_pulse"

-- 炮台使用的弹药类型（脉冲弹药）
SWEP.TurretAmmoType = "pulse"
-- 炮台部署时的初始弹药量
SWEP.TurretAmmoStartAmount = 30
-- 炮台射击时的弹道扩散
SWEP.TurretSpread = 2

-- 武器等级（Tier 5）
SWEP.Tier = 5

-- 部署时消耗的弹药类型
SWEP.Primary.Ammo = "turret_pulse"

-- 强化修饰器：降低炮台弹道扩散
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)