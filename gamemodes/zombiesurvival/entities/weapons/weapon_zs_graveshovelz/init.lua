-- ============================================================================
-- weapon_zs_graveshovelz/init.lua - 墓园铁锹（服务器端）
-- 负责：拆道具专用铁锹——近战命中非玩家（道具/物件）时临时切换为高伤害，
--       命中结算后立即恢复原伤害
-- ============================================================================
INC_SERVER()

-- 记录武器的原始近战伤害，供临时切换后恢复
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage

-- ==== Deploy - 出枪：调用双重基底（weapon_zs_base → 更底层）的部署逻辑 ====
function SWEP:Deploy()
	self.BaseClass.BaseClass.Deploy(self)
end

-- ==== OnMeleeHit - 近战命中瞬间：命中非玩家实体时把伤害切换为 30（拆道具） ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitent:IsPlayer() then
		self.MeleeDamage = 30
	end
end

-- ==== PostOnMeleeHit - 命中结算后：恢复原始近战伤害 ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end
