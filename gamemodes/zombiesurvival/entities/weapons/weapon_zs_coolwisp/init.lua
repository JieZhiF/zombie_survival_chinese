-- ============================================================================
-- weapon_zs_coolwisp/init.lua - 寒冰幽灵武器（服务端）
-- 负责：拔出武器时为持有者创建寒冰幽灵环境音效
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 拔出武器时 ====
-- 为持有者创建寒冰幽灵风格环境音效
function SWEP:Deploy()
	self:GetOwner():CreateAmbience("ambience_coolwisp")

	return true
end
