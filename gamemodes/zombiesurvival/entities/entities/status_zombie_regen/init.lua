-- ============================================================================
-- status_zombie_regen - 僵尸再生状态实体（服务端）
-- 负责：周期性恢复僵尸血量，受麻痹状态、剩余治疗量与 Boss 治疗配额的约束
-- ============================================================================
INC_SERVER()

-- ==== Think - 每 0.1 秒恢复一次血量：无剩余治疗量、中麻痹或 Boss 治疗耗尽时移除状态 ====
function ENT:Think()
	local owner = self:GetOwner()

	if owner:GetStatus("shockdebuff") or self:GetHealLeft() <= 0 or owner.BossHealRemaining and owner.BossHealRemaining <= 0 then
		self:Remove()
		return
	end

	local zombieclasstbl = owner:GetZombieClassTable()
	-- 每跳治疗量：剩余治疗量的 1~5 点；骷髅系职业（SkeletalRes）仅获 36% 效果
	local heal = math.Clamp(self:GetHealLeft(), 1, 5) * (zombieclasstbl.SkeletalRes and 0.36 or 1)

	-- 治疗上限：Boss 为最大血量的 40%，普通僵尸为最大血量的 125%
	local ehp = zombieclasstbl.Boss and owner:GetMaxHealth() * 0.4 or owner:GetMaxHealth() * 1.25

	-- 消耗 Boss 专属治疗配额（Boss 再生由配额驱动）
	if owner.BossHealRemaining and owner.BossHealRemaining > 0 then
		owner.BossHealRemaining = owner.BossHealRemaining - heal
	end

	-- 恢复血量并扣除剩余治疗量，实际血量不超过 ehp 上限
	owner:SetHealth(math.min(ehp, owner:Health() + heal))
	self:SetHealLeft(self:GetHealLeft() - heal)

	self:NextThink(CurTime() + 0.1)
	return true
end
