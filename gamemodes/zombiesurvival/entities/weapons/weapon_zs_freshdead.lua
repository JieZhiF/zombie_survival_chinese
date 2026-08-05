-- ============================================================================
-- weapon_zs_freshdead.lua - 新鲜僵尸爪武器
-- 负责：普通僵尸的基础近战爪击；"换弹键"触发副攻击（特殊技能），
--       且该僵尸不会发出呻吟声
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 继承僵尸爪武器母本
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_freshdead")

SWEP.MeleeDamage = 20 -- 近战伤害

-- ==== Reload - 换弹：触发副攻击 ====
-- 新鲜僵尸的"换弹键"被复用为右键副攻击（特殊技能）
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 开始呻吟（空实现） ====
-- 新鲜僵尸不会呻吟
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 停止呻吟（空实现） ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 是否正在呻吟 ====
-- 永远返回 false（新鲜僵尸没有呻吟机制）
function SWEP:IsMoaning()
	return false
end
