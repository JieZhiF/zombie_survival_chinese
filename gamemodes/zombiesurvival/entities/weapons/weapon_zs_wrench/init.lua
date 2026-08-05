-- ============================================================================
-- weapon_zs_wrench/init.lua - 近战维修工具「扳手」（Wrench）服务器端
-- 负责：命中建筑时的维修逻辑（回复生命、播放维修音效与特效）
-- ============================================================================

INC_SERVER()

-- ==== PlayRepairSound - 播放维修（伺服电机）音效 ====
function SWEP:PlayRepairSound(hitent)
	hitent:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
end

-- ==== OnMeleeHit - 命中处理：对可维修物件执行修理并结算事件 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if CLIENT or not hitent:IsValid() then return end

	local owner = self:GetOwner()

	-- 若被击实体自带扳手命中处理（如特殊物件），交给它处理并终止
	if hitent.HitByWrench and hitent:HitByWrench(self, owner, tr) then
		return
	end

	-- 可维修物件：满血/已损坏或被击后 4 秒内不可重复维修
	if hitent.GetObjectHealth then
		local oldhealth = hitent:GetObjectHealth()
		if oldhealth <= 0 or oldhealth >= hitent:GetMaxObjectHealth() or hitent.m_LastDamaged and CurTime() < hitent.m_LastDamaged + 4 then return end

		-- 维修量 = 扳手强度 × 玩家维修倍率 × 物件修理倍率，不超过最大生命
		local healstrength = self.HealStrength * (owner.RepairRateMul or 1) * (hitent.WrenchRepairMultiplier or 1)

		hitent:SetObjectHealth(math.min(hitent:GetMaxObjectHealth(), hitent:GetObjectHealth() + healstrength))
		local healed = hitent:GetObjectHealth() - oldhealth
		-- 播放维修音效并通知游戏模式（维修量按一半计入统计数据）
		self:PlayRepairSound(hitent)
		gamemode.Call("PlayerRepairedObject", owner, hitent, healed / 2, self)

		-- 生成钉子修复特效（对所有人可见、强制创建）
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(1)
		util.Effect("nailrepaired", effectdata, true, true)

		return true
	end
end
