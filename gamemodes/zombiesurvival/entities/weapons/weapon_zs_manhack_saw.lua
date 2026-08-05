-- ============================================================================
-- weapon_zs_manhack_saw.lua - 电锯机器人遥控器（电锯型）
-- 负责：召唤电锯版猎头机器人的遥控武器属性
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 继承猎头机器人遥控器基础
SWEP.Base = "weapon_zs_manhack"

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_manhack_saw")
SWEP.Description = ""..translate.Get("weapon_zs_manhack_saw_description")

-- 召唤出的机器人实体 / 对应的操控武器
SWEP.DeployClass = "prop_manhack_saw"
SWEP.ControlWeapon = "weapon_zs_manhackcontrol_saw"

-- 消耗的弹药类型（电锯机器人弹药）
SWEP.Primary.Ammo = "manhack_saw"
