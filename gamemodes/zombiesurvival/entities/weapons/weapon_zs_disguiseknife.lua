-- ============================================================================
-- weapon_zs_disguiseknife.lua - 伪装小刀（僵尸专属武器）
-- 负责：定义基于瑞士军刀基础的小刀属性，实现"背刺"机制——从目标背后攻击时
--       近战伤害翻倍，本次攻击结束后自动恢复
-- ============================================================================
-- 全端加载（服务端 + 客户端）
AddCSLuaFile()

-- 继承自瑞士军刀近战武器基类
SWEP.Base = "weapon_zs_swissarmyknife"

-- 仅僵尸可用
SWEP.ZombieOnly = true
-- 基础近战伤害
SWEP.MeleeDamage = 25
-- 记录原始伤害（用于背刺翻倍后恢复）
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
-- 攻击间隔（秒）
SWEP.Primary.Delay = 0.45

-- ==== OnMeleeHit - 近战命中回调：判定背刺 ====
-- 命中玩家且攻击方向与目标朝向夹角不超过 90 度时，标记本次为背刺并使伤害翻倍
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and not self.m_BackStabbing and math.abs(hitent:GetForward():Angle().yaw - self:GetOwner():GetForward():Angle().yaw) <= 90 then
		self.m_BackStabbing = true
		self.MeleeDamage = self.MeleeDamage * 2
	end
end

-- ==== PostOnMeleeHit - 近战命中后回调：恢复伤害 ====
-- 本次攻击若为背刺，结束前将伤害恢复为原始值并清除标记
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if self.m_BackStabbing then
		self.m_BackStabbing = false

		self.MeleeDamage = self.MeleeDamage / 2
	end
end
