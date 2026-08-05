-- ============================================================================
-- status_frostshadeshield/shared.lua - 冰霜护盾状态（共享）
-- 负责：僵尸的冰霜护盾：继承阴影护盾基类；护盾血量归零时触发冰爆——
--       对周围玩家施加冰冻状态与腿部伤害并造成爆炸伤害
-- ============================================================================
-- 继承阴影护盾基类，复用其状态/血量存取与碰撞过滤逻辑
ENT.Base = "status_shadeshield"

-- ==== SetObjectHealth - 设置护盾血量；归零时触发冰霜爆炸 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(1, health)
	-- 血量首次降到 0 及以下且尚未销毁时，触发冰爆表现（只触发一次）
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		if SERVER then
			-- 播放破冰特效
			local effectdata = EffectData()
				effectdata:SetOrigin(self:WorldSpaceCenter())
				effectdata:SetNormal(self:GetUp())
			util.Effect("hit_ice", effectdata)

			-- 对护盾周围 128 单位内的玩家：施加 7 秒冰冻并造成腿部伤害（不伤及护盾主人）
			local owner = self:GetOwner()
			local pos = self:LocalToWorld(self:OBBCenter())
			for _, ent in pairs(util.BlastAlloc(self, owner, pos, 128)) do
				if ent:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", ent, owner) and ent ~= owner then
					ent:GiveStatus("frost", 7)
					ent:AddLegDamageExt(18, owner, self, SLOWTYPE_COLD)
				end
			end

			-- 以拥有者无敌状态施放 30 点爆炸伤害，避免炸伤自己
			owner:GodEnable()
			util.BlastDamageEx(self, owner, pos, 128, 30, DMG_GENERIC)
			owner:GodDisable()
			-- 屏幕震动与玻璃破碎音效
			util.ScreenShake(self:GetPos(), 15, 5, 1.5, 800)
			self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 85)
		end
	end
end
