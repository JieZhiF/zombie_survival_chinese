-- ============================================================================
-- init.lua - 冰封亡魂（僵尸近战武器）服务端逻辑
-- 负责：近战命中附加霜冻/夜视削弱状态与腿部伤害，然后走基类伤害结算
-- ============================================================================

-- 服务端 realm 守卫：仅服务端加载本文件（替代 if SERVER then 写法）
INC_SERVER()

-- ==== ApplyMeleeDamage - 近战命中附加冰冻效果后交由基类结算 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 命中人类玩家时附加状态：夜视削弱 6 秒 + 霜冻 8 秒
	if ent:IsPlayer() then
		ent:GiveStatus("dimvision", 6)
		local gt = ent:GiveStatus("frost", 8)
		local owner = self:GetOwner()

		-- 记录霜冻状态的施加者（用于击杀归属）
		if gt and gt:IsValid() then
			gt.Applier = owner
		end
		-- 追加 12 点腿部伤害（寒冷减速类型），来源为本武器与持有者
		ent:AddLegDamageExt(12, owner, self, SLOWTYPE_COLD)
	end

	-- 其余伤害结算交给基类（僵尸武器基类）
	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end
