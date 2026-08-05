-- ============================================================================
-- weapon_zs_gunturret_rocket.lua - 火箭炮塔建造武器
-- 负责：定义可建造火箭炮塔的各项参数（伤害、弹药、散布等）
-- ============================================================================
AddCSLuaFile()

-- 基于通用炮塔武器母本
SWEP.Base = "weapon_zs_gunturret"

-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_rocket")
SWEP.Description = ""..translate.Get("weapon_zs_gunturret_rocket_description")

-- 火箭炮塔单发伤害
SWEP.Primary.Damage = 104

-- 建造时显示的幽灵模型
SWEP.GhostStatus = "ghost_gunturret_rocket"
-- 部署后生成的炮塔实体
SWEP.DeployClass = "prop_gunturret_rocket"
-- 炮塔弹药类型与初始弹药量
SWEP.TurretAmmoType = "impactmine"
SWEP.TurretAmmoStartAmount = 12
-- 炮塔射击散布
SWEP.TurretSpread = 1

-- 武器自身使用的弹药类型
SWEP.Primary.Ammo = "turret_rocket"

-- 武器等级
SWEP.Tier = 4

-- 附加武器修正：降低炮塔散布
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.45)
