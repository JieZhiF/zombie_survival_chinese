-- ============================================================================
-- status_magnet - 磁铁状态
-- 负责：人类玩家持有磁铁武器时，周期性吸引周围地面上的弹药/物品/武器
--       道具到自己身边；距离足够近时直接给予玩家；
--       僵尸阵营持有则立即移除该状态
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 实体类型：动画实体，继承状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- 吸引半径（单位）
ENT.Radius = 400

-- 服务器端专属逻辑
if CLIENT then return end

-- 可被吸引的道具类别表（弹药盒/库存物品/掉落武器）
ENT.Classes = table.ToAssoc(
	{"prop_ammo", "prop_invitem", "prop_weapon"}
)
-- 施加在道具上的力大小
ENT.Force = 50
-- 两次吸引施加之间的间隔
ENT.ForceDelay = 0.25

-- ==== Think - 周期性吸引逻辑 ====
function ENT:Think()
	local owner = self:GetOwner()

	-- 僵尸持有磁铁则移除（磁铁仅限人类使用）
	if owner:Team() == TEAM_UNDEAD then
		self:Remove()
		return
	end

	-- 需要玩家手持磁铁武器才生效
	local activeweapon = owner:GetActiveWeapon()
	if not activeweapon:IsValid() or not activeweapon.IsMagnet then return end

	local pos = self:GetPos()
	-- 遍历半径内的所有实体
	for _, ent in pairs(ents.FindInSphere(pos, self.Radius)) do
		local class = ent:GetClass()
		-- 道具无归属限制，或归属为本玩家
		local ownsitem = not ent.NoPickupsOwner or ent.NoPickupsOwner == owner
		-- 道具不是刚刚掉落的（4 秒内不吸引，防止拾取回流）
		local droppedrecent = not ent.DroppedTime or ent.DroppedTime + 4 < CurTime()

		-- 满足类别、归属、掉落时间且玩家与道具之间无遮挡时施加吸引力
		if ent and ent:IsValid() and self.Classes[class] and WorldVisible(pos, ent:NearestPoint(pos)) and droppedrecent and ownsitem then
			local phys = ent:GetPhysicsObject()
			local dir = (pos - ent:NearestPoint(pos)):GetNormalized()
			-- 按质量成比例的力将道具拉向玩家
			phys:ApplyForceCenter(phys:GetMass() * self.Force * dir)
			-- 记录物理攻击者为玩家，避免道具被判定为无主掉落
			ent:SetPhysicsAttacker(owner, 4)

			-- 道具已非常接近玩家（约 75 单位内）且支持直接给予时，立即拾取
			if (ent:GetPos() - pos):LengthSqr() <= 5600 and ent.GiveToActivator then
				ent:GiveToActivator(owner)
			end
		end
	end

	-- 按固定间隔循环执行
	self:NextThink(CurTime() + self.ForceDelay)
	return true
end
