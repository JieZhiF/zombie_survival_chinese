-- ============================================================================
-- status_poison/shared.lua - 中毒状态实体（共享端）
-- 负责：定义中毒状态的属性（伤害存储）与伤害叠加/读取接口
-- ============================================================================

-- 实体类型与基础类（继承 status__base 状态基类）
ENT.Type = "anim"
ENT.Base = "status__base"

-- 每个伤害 tick 造成的伤害量（实际伤害在 init.lua 中按此计算）
ENT.DamagePerTick = 3

-- 短暂存在型状态（玩家死亡/移除时自动清理）
ENT.Ephemeral = true

-- ==== Initialize - 初始化 ====
function ENT:Initialize()
	-- 状态实体不可见，关闭阴影绘制
	self:DrawShadow(false)
	-- 记录初始时间戳（用于计算毒伤持续时间）
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end
end

-- ==== AddDamage - 叠加毒伤 ====
-- 将新伤害累加到已存储的总毒伤中，并记录各攻击者的伤害贡献
function ENT:AddDamage(damage, attacker)
	self:SetDamage(self:GetDamage() + damage)

	-- 服务器端记录攻击者伤害明细（用于击杀归属判定）
	if SERVER and attacker then
		self.Attackers[attacker] = (self.Attackers[attacker] or 0) + damage
	end
end

-- ==== SetDamage - 设置总毒伤 ====
-- 写入网络变量并限制最大毒伤（防止无限叠加）
function ENT:SetDamage(damage)
	self:SetDTFloat(0, math.min(GAMEMODE.MaxPoisonDamage or 1000, damage))
end

-- ==== GetDamage - 读取总毒伤 ====
function ENT:GetDamage()
	return self:GetDTFloat(0)
end
