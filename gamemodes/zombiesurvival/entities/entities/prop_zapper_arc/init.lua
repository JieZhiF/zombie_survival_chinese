-- ============================================================================
-- prop_zapper_arc/init.lua - 电弧电击器（服务器）
-- 负责：电击陷阱的进阶版：命中主目标后电弧在 105 单位内至多再跳跃
--       3 次，伤害逐跳衰减；每次射击消耗 3 发弹药
-- ============================================================================
INC_SERVER()

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
	-- 弹药 ≥ 3 且有有效拥有者才开火
	if curammo >= 3 and owner:IsValid() then
		self.NextZapCheck = CurTime() + 0.4

		local pos = self:LocalToWorld(Vector(0, 0, 29))
		local target = self:FindZapperTarget(pos, owner)

		-- 记录已被电击过的目标，防止重复命中
		local shocked = {}
		if target then
			-- 每次射击消耗 3 发弹药
			self:SetAmmo(curammo - 3)

			-- 弹药耗尽时提醒拥有者
			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			-- 射击冷却 4.5 秒（可被拥有者延迟加成调整）
			self:SetNextZap(CurTime() + 4.5 * (owner.FieldDelayMul or 1))
			-- 主目标受到全额伤害
			self:HitTarget(target, self.Damage, owner)

			-- 主目标的电弧特效
			local effectdata = EffectData()
				effectdata:SetOrigin(target:WorldSpaceCenter())
				effectdata:SetStart(pos)
				effectdata:SetEntity(self)
			util.Effect("tracer_zapper", effectdata)

			shocked[target] = true
			-- 电弧跳跃：从当前目标周围 105 单位内找下一个未电击、视线可达的僵尸
			for i = 1, 3 do
				local tpos = target:WorldSpaceCenter()

				for k, ent in pairs(ents.FindInSphere(tpos, 105)) do
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
