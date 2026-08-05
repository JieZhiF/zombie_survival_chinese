-- ============================================================================
-- weapon_zs_zombietorso.lua - 僵尸躯干（近战攻击）
-- 负责：无口部动画的僵尸近战武器，R 键触发重击，无呻吟声
-- ============================================================================
AddCSLuaFile()

SWEP.Base = "weapon_zs_zombie" -- 继承僵尸近战武器基类

SWEP.PrintName = ""..translate.Get("weapon_zs_zombietorso") -- 武器显示名称

SWEP.MeleeDelay = 0.25 -- 攻击间隔（秒）
SWEP.MeleeReach = 40 -- 攻击距离
SWEP.MeleeDamage = 25 -- 攻击伤害
SWEP.SwingAnimSpeed = 2.96 -- 挥击动画播放速度

SWEP.DelayWhenDeployed = true -- 部署后需等待攻击延迟

-- ==== Reload - 按 R 键触发右键重击 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 空实现（躯干没有嘴，无法呻吟） ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 空实现（躯干没有嘴，无法呻吟） ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 躯干永远不会处于呻吟状态 ====
function SWEP:IsMoaning()
	return false
end
