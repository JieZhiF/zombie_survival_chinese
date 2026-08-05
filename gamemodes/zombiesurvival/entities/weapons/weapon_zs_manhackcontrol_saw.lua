-- ============================================================================
-- weapon_zs_manhackcontrol_saw.lua - 锯片猎头蟹控制装置
-- 负责：定义召唤锯片型猎头蟹的控制武器
-- ============================================================================
AddCSLuaFile()

-- 基于猎头蟹控制武器母本
SWEP.Base = "weapon_zs_manhackcontrol"

-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_manhackcontrol_saw")
SWEP.Description = ""..translate.Get("weapon_zs_manhackcontrol_saw_description")

-- 召唤的猎头蟹实体类型（锯片型）
SWEP.EntityClass = "prop_manhack_saw"
