-- ============================================================================
-- weapon_zs_special_wow/init.lua - WOW 特殊武器（服务端）
-- 负责：拔出武器时为持有者创建 WOW 主题环境音效
-- ============================================================================
INC_SERVER()

-- ==== Deploy - 拔出武器时 ====
-- 为持有者创建 WOW 风格环境音效
function SWEP:Deploy()
	self:GetOwner():CreateAmbience("ambience_wow")

	return true
end
