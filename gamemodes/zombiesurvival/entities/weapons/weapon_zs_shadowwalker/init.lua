-- ============================================================================
-- weapon_zs_shadowwalker/init.lua - 暗影行者僵尸利爪（服务器端）
-- 负责：近战命中人类时附加"暗影视觉"（dimvision）负面状态，使其视野受限
-- ============================================================================
INC_SERVER()

-- ==== ApplyMeleeDamage - 近战命中结算：命中人类先附加暗影视觉状态，再走基底伤害 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 目标是人类：附加 6 秒暗影视觉（视野受限/变暗）
	if ent:IsPlayer() then
		ent:GiveStatus("dimvision", 6)
	end

	-- 继续执行基底（weapon_zs_zombie）的常规近战伤害结算
	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end
