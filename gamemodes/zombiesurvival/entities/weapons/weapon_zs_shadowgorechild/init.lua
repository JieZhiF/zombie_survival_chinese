-- ============================================================================
-- weapon_zs_shadowgorechild/init.lua - 暗影血童（服务器端逻辑）
-- 负责：近战命中时为玩家目标附加暗视状态
-- ============================================================================
INC_SERVER()

-- ==== ApplyMeleeDamage - 近战命中：对玩家附加 2.5 秒暗视效果 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	if ent:IsPlayer() then
		ent:GiveStatus("dimvision", 2.5)
	end

	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end
