-- ============================================================================
-- weapon_zs_gunturret_assault.lua - 突击炮塔（放置型武器）
-- 负责：定义可部署的突击炮塔属性：伤害、弹药、扩散及部署实体
-- ============================================================================
AddCSLuaFile()

-- 基于炮塔放置武器母本
SWEP.Base = "weapon_zs_gunturret"

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret_assault")
SWEP.Description = ""..translate.Get("weapon_zs_gunturret_assault_description")

-- 炮塔单发伤害
SWEP.Primary.Damage = 22.5

-- 放置时的预览（虚影）实体与部署后生成的炮塔实体
SWEP.GhostStatus = "ghost_gunturret_assault"
SWEP.DeployClass = "prop_gunturret_assault"

-- 炮塔使用 AR2 弹药，初始携弹 100 发，射击扩散 2
SWEP.TurretAmmoType = "ar2"
SWEP.TurretAmmoStartAmount = 100
SWEP.TurretSpread = 2

-- 武器等级
SWEP.Tier = 4

-- 部署消耗的弹药类型
SWEP.Primary.Ammo = "turret_assault"

-- 附加炮塔扩散强化模组（每级 -0.5 扩散）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)
