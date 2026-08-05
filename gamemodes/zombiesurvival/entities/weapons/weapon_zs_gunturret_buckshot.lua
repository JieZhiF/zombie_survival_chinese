-- ============================================================================
-- weapon_zs_gunturret_buckshot.lua - 霰弹炮台遥控器（霰弹型）
-- 负责：定义霰弹自动炮台的属性（伤害、弹药、散布）
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 继承炮台遥控器基础
SWEP.Base = "weapon_zs_gunturret"

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_buckshot")
SWEP.Description = ""..translate.Get("weapon_zs_gunturret_buckshot_description")

-- 炮台单发伤害
SWEP.Primary.Damage = 6.75

-- 放置预览幽灵状态 / 部署出的炮台实体
SWEP.GhostStatus = "ghost_gunturret_buckshot"
SWEP.DeployClass = "prop_gunturret_buckshot"
-- 炮台弹药类型 / 初始装填量 / 射击散布
SWEP.TurretAmmoType = "buckshot"
SWEP.TurretAmmoStartAmount = 25
SWEP.TurretSpread = 5

-- 遥控器消耗的弹药类型
SWEP.Primary.Ammo = "turret_buckshot"

-- 强化词条：炮台散布 -0.9
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.9)
