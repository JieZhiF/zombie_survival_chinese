-- ============================================================================
-- projectile_strengthdart/init.lua - 力量/防御强化飞镖（服务器）
-- 负责：命中时对非僵尸玩家附加力量或防御强化状态（右键蓄力发射为
--       防御强化弹）并附带半程治疗；命中无效目标时退回弹药
-- ============================================================================
INC_SERVER()

-- ==== Hit - 命中处理：附着目标、施加增益状态或退回弹药 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity, vOldVelocity)
	-- 已命中过则忽略
	if self:GetHitTime() ~= 0 then return end
	self:SetHitTime(CurTime())

	-- 10 秒后自动清除实体（清理附着在玩家身上的飞镖）
	self:Fire("kill", "", 10)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 命中点与表面法线（法线取反以贴合表面）
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = (vHitNormal or Vector(0, 0, -1)) * -1

	-- 停止碰撞与运动，吸附到命中点表面
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	self:SetPos(vHitPos + vHitNormal)

	-- 右键发射（DT 布尔 0 号位为真）时为防御强化弹
	local alt = self:GetDTBool(0)
	if eHitEntity:IsValid() then
		self:AttachToPlayer(vHitPos, eHitEntity)

		-- 命中非僵尸玩家：施加增益状态
		if eHitEntity:IsPlayer() and eHitEntity:Team() ~= TEAM_UNDEAD then
			-- 防御强化 2 倍时长 / 力量强化 1 倍时长（以 BuffDuration 为基础）
			local strstatus = eHitEntity:GiveStatus(alt and "medrifledefboost" or "strengthdartboost", (alt and 2 or 1) * (self.BuffDuration or 10))
			strstatus.Applier = owner

			local txt = alt and "Defence Shot Gun" or "Strength Shot Gun"

			-- 双方互相显示增益来源提示
			net.Start(NET_MSG.BUFFBY)
				net.WriteEntity(owner)
				net.WriteString(txt)
			net.Send(eHitEntity)

			net.Start(NET_MSG.BUFFWITH)
				net.WriteEntity(eHitEntity)
				net.WriteString(txt)
			net.Send(owner)

			-- 附带半程治疗状态
			eHitEntity:GiveStatus("healdartboost", (self.BuffDuration or 10)/2)
		else
			-- 命中僵尸：退回弹药
			self:DoRefund(owner)
		end
	else
		-- 未命中任何实体：退回弹药
		self:DoRefund(owner)
	end

	self:SetAngles(vOldVelocity:Angle())

	-- 命中特效（普通/防御两种弹型）
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
		if eHitEntity:IsValid() then
			effectdata:SetEntity(eHitEntity)
		else
			effectdata:SetEntity(NULL)
		end
	util.Effect(alt and "hit_healdart2" or "hit_strengthdart", effectdata)
end
