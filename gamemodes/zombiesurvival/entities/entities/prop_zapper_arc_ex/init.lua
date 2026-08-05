-- ============================================================================
-- prop_zapper_arc_ex/init.lua - 超级电塔（娱乐，服务器）
-- 负责：管理员刷取的娱乐版电击塔：索敌范围 500 单位、极短射击冷却
--       （0.1 秒）、每次仅耗 1 发弹药；电弧在 50 单位内至多跳跃 3 次
-- ============================================================================
INC_SERVER()

-- ==== FindZapperTarget - 索敌：在超大范围（500 单位）内找存活僵尸 ====
function ENT:FindZapperTarget(pos, owner)
	local target
	local targethealth = 99999
	local isheadcrab

	-- 遍历范围 500 单位（可被拥有者范围加成放大）内的实体
	for k, ent in pairs(ents.FindInSphere(pos, 500 * (owner.FieldRangeMul or 1))) do
		if ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
			isheadcrab = ent:IsHeadcrab()
			-- 头部蟹优先（直接锁定），否则选择血量最低且视线可达的目标
			if (isheadcrab or ent:Health() < targethealth) and TrueVisibleFiltered(pos, ent:NearestPoint(pos), self, ent) then
				targethealth = ent:Health()
				target = ent

				if isheadcrab then
					break
				end
			end
		end
	end

	return target
end

-- ==== HitTarget - 对目标造成腿部伤害与电击伤害并播放音效 ====
function ENT:HitTarget(ent, damage, owner)
	-- 附加腿部伤害与脉冲减速
	ent:AddLegDamageExt(self.LegDamage, owner, self, SLOWTYPE_PULSE)

	-- 伤害结算期间应用得分倍率
	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end
	ent:TakeSpecialDamage(damage, DMG_SHOCK, owner, self)
	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end

	self:EmitSound("ambient/office/zap1.wav", 70, 160, 0.6, CHAN_AUTO)
end

-- ==== Think - 主循环：索敌并发射电弧（主目标 + 至多 3 次跳跃）====
function ENT:Think()
	-- 已摧毁：移除自身
	if self.Destroyed then
		self:Remove()
		return
	end

	-- 冷却未结束：跳过本次
	if CurTime() < self:GetNextZap() or CurTime() < self.NextZapCheck then return end

	local curammo = self:GetAmmo()
	local owner = self:GetObjectOwner()
	-- 弹药 ≥ 1 且有有效拥有者才开火
	if curammo >= 1 and owner:IsValid() then
		self.NextZapCheck = CurTime() + 0.4

		local pos = self:LocalToWorld(Vector(0, 0, 29))
		local target = self:FindZapperTarget(pos, owner)

		-- 记录已被电击过的目标，防止重复命中
		local shocked = {}
		if target then
			-- 每次射击消耗 1 发弹药
			self:SetAmmo(curammo - 1)

			-- 弹药耗尽时提醒拥有者
			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			-- 射击冷却 0.1 秒（极速射击，可被拥有者延迟加成调整）
			self:SetNextZap(CurTime() + 0.1 * (owner.FieldDelayMul or 1))
			-- 主目标受到全额伤害
			self:HitTarget(target, self.Damage, owner)

			-- 主目标的电弧特效
			local effectdata = EffectData()
				effectdata:SetOrigin(target:WorldSpaceCenter())
				effectdata:SetStart(pos)
				effectdata:SetEntity(self)
			util.Effect("tracer_zapper", effectdata)

			shocked[target] = true
			-- 电弧跳跃：从当前目标周围 50 单位内找下一个未电击、视线可达的僵尸
			for i = 1, 3 do
				local tpos = target:WorldSpaceCenter()

				for k, ent in pairs(ents.FindInSphere(tpos, 50)) do
					if not shocked[ent] and ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
						if WorldVisible(tpos, ent:NearestPoint(tpos)) then
							shocked[ent] = true
							target = ent

							-- 跳跃目标延迟 i*0.15 秒后受击，伤害逐跳衰减
							timer.Simple(i * 0.15, function()
								-- 延迟期间目标可能已死亡或移出视线：失效则跳过
								if not ent:IsValid() or not ent:IsValidLivingZombie() or not WorldVisible(tpos, ent:NearestPoint(tpos)) then return end

								self:HitTarget(ent, self.Damage / (i + 0.5), owner)

								-- 本次跳跃的电弧特效
								local worldspace = ent:WorldSpaceCenter()
								effectdata = EffectData()
									effectdata:SetOrigin(worldspace)
									effectdata:SetStart(tpos)
									effectdata:SetEntity(target)
								util.Effect("tracer_zapper", effectdata)
							end)

							break
						end
					end
				end
			end
		end
	end

	-- 每帧续约 Think
	self:NextThink(CurTime())
	return true
end
