-- ============================================================================
-- init.lua - 符印碎片武器服务端逻辑
-- 负责：实现传送执行（DoTeleport），在起点与目标点播放特效并把玩家移动到目标符印
-- ============================================================================
INC_SERVER()

-- ==== DoTeleport - 执行传送到目标位置 ====
-- 由传送状态（sigilteleport）在蓄能完成后调用；播放双向特效、移动玩家并进入建造幽灵态
function SWEP:DoTeleport(target)
	local owner = self:GetOwner()

	-- 在起点（玩家）与终点（目标符印）各播放一次传送特效
	local effectdata = EffectData()
	effectdata:SetOrigin(owner:WorldSpaceCenter())
	effectdata:SetEntity(owner)
	util.Effect(self.TeleportEffect, effectdata, true, true)
	effectdata:SetOrigin(target:WorldSpaceCenter())
	util.Effect(self.TeleportEffect, effectdata, true, true)

	-- 移动玩家到目标位置，并开启建造幽灵态（传送期间免疫碰撞）
	owner:SetPos(target:GetPos())
	owner:SetBarricadeGhosting(true, true)

	-- 碎片弹药耗尽：传送完成后移除武器
	if self:GetPrimaryAmmoCount() <= 0 then
		owner:StripWeapon(self:GetClass())
	end
end
