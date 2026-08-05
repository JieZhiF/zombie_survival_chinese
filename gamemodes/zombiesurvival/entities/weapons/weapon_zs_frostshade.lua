-- ============================================================================
-- weapon_zs_frostshade.lua - 冰霜暗影（僵尸远程技能）
-- 负责：暗影类技能变体，发射冰霜弹并附带冰冻控制实体
-- ============================================================================
AddCSLuaFile()

SWEP.Base = "weapon_zs_shade" -- 继承暗影技能武器基类

SWEP.PrintName = ""..translate.Get("weapon_zs_frostshade") -- 武器显示名称

SWEP.ShadeControl = "env_frostshadecontrol" -- 控制实体（冰冻效果控制器）
SWEP.ShadeProjectile = "projectile_shadeice" -- 发射的投射物（冰霜弹）
