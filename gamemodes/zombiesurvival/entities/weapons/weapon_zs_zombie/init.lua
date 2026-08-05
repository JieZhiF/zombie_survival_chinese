-- ============================================================================
-- weapon_zs_zombie/init.lua - 僵尸利爪（僵尸专用近战武器，服务器端）
-- 负责：定义嚎叫技能（按 R 键切换开启/关闭嚎叫）
-- ============================================================================

INC_SERVER()

-- 嚎叫技能的施放间隔
SWEP.MoanDelay = 1

-- ==== Reload - 切换嚎叫状态（R 键触发） ====
function SWEP:Reload()
	-- 嚎叫冷却未结束则跳过
	if CurTime() < self:GetNextSecondaryFire() then return end
	self:SetNextSecondaryFire(CurTime() + self.MoanDelay)

	-- 正在嚎叫则停止，否则开始嚎叫
	if self:IsMoaning() then
		self:StopMoaning()
	else
		self:StartMoaning()
	end
end
