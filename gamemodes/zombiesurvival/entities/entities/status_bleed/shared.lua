-- ============================================================================
-- status_bleed/shared.lua - 流血状态（共享）
-- 负责：累计流血伤害值（受技能倍率影响并钳制上限），记录状态生效起始时间
-- ============================================================================
ENT.Type = "anim"
ENT.Base = "status__base"

-- 短暂状态：显示计时结束后自动消失（由基类处理）
ENT.Ephemeral = true

-- ==== Initialize - 初始化：记录流血起始时间（供客户端显示剩余时长） ====
function ENT:Initialize()
	self:DrawShadow(false)
	-- 起始时间未设置时记录为当前时间
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end
end

-- ==== AddDamage - 叠加流血伤害：先应用技能倍率再累加，并记录伤害来源 ====
function ENT:AddDamage(damage, attacker)
	local owner = self:GetOwner()
	-- 拥有者具有流血受击倍率（技能树加成）时放大伤害
	if damage > 0 and owner:IsValid() and owner.BleedDamageTakenMul then
		damage = damage * owner.BleedDamageTakenMul
	end

	self:SetDamage(self:GetDamage() + damage)
	-- 记录最后一次造成流血的伤害来源
	if attacker then
		self.Damager = attacker
	end
end

-- ==== SetDamage - 设置累计流血伤害：钳制在全局上限（默认 1000）内 ====
function ENT:SetDamage(damage)
	self:SetDTFloat(0, math.min(GAMEMODE.MaxBleedDamage or 1000, damage))
end

-- ==== GetDamage - 读取累计流血伤害 ====
function ENT:GetDamage()
	return self:GetDTFloat(0)
end
