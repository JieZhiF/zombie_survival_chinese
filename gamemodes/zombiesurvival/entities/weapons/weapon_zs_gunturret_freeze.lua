-- ============================================================================
-- weapon_zs_gunturret_freeze.lua - 冰冻炮台（Gunturret Freeze）
-- 负责：定义可部署冰冻炮台的冷冻控制、弹药与部署实体
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()

-- 继承的基础炮台武器
SWEP.Base = "weapon_zs_gunturret"

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_freeze")
-- 武器商店描述（部署与操作说明）
SWEP.Description = "An icy turret that locks onto zombies with a cryo beam, building up frost until they are frozen solid.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

-- 放置预览（幽灵）状态实体
SWEP.GhostStatus = "ghost_gunturret_pulse"
-- 实际部署的炮台实体
SWEP.DeployClass = "prop_gunturret_pulse"

-- 炮台使用的弹药类型（脉冲弹药）
SWEP.TurretAmmoType = "pulse"
-- 炮台部署时的初始弹药量
SWEP.TurretAmmoStartAmount = 30

-- 武器等级（Tier 3）
SWEP.Tier = 3
-- 限购数量（商店库存上限）
SWEP.MaxStock = 5

-- 部署时消耗的弹药类型
SWEP.Primary.Ammo = "turret_pulse"
