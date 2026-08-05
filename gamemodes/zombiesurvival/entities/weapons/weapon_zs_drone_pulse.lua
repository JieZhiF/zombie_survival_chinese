-- ============================================================================
-- weapon_zs_drone_pulse.lua - 脉冲切割无人机部署器
-- 负责：定义脉冲无人机的弹药类型与部署实体（基于无人机母本 weapon_zs_drone）
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()
-- 定义母本类引用（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_drone")

-- 母本：无人机母本
SWEP.Base = "weapon_zs_drone"

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_drone_pulse")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_drone_pulse_description")

-- 玩家持有该部署器时消耗的弹药类型（脉冲切割器）
SWEP.Primary.Ammo = "pulse_cutter"

-- 部署后生成的实体类（脉冲无人机）
SWEP.DeployClass = "prop_drone_pulse"
-- 部署无人机的弹药类型
SWEP.DeployAmmoType = "pulse"
-- 弹药补给类型（补给箱可补充脉冲弹药）
SWEP.ResupplyAmmoType = "pulse"
