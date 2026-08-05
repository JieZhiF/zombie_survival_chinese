-- ============================================================================
-- init.lua - 脉冲炮塔（服务器）：开火逻辑，发射脉冲无人机炮弹
-- 负责：脉冲炮弹的生成与散射、弹药消耗、双发齐射（TWINVOLLEY 天赋）与空仓处理
-- ============================================================================
INC_SERVER()

-- 记录伤害事件的间隔周期（供基类跟踪最近一次受伤时间，单位：秒）
ENT.LastHitPeriod = 4

-- ==== FireTurret - 炮塔开火：消耗弹药并按散射角生成脉冲炮弹 ====
function ENT:FireTurret(src, dir)
	-- 冷却结束才允许开火
	if self:GetNextFire() <= CurTime() then
		local curammo = self:GetAmmo()
		local owner = self:GetObjectOwner()
		-- 手动操控且激活"双发齐射"天赋时，每次开火发射两发、消耗双倍弹药
		local twinvolley = self:GetManualControl() and owner:IsSkillActive(SKILL_TWINVOLLEY)
		-- 弹药足够（双发模式需要至少 2 发）才进入开火流程
		if curammo > (twinvolley and 1 or 0) then
			-- 双发时射速略微降低（冷却延长 1.5 倍）
			self:SetNextFire(CurTime() + self.FireDelay * (twinvolley and 1.5 or 1))
			self:SetAmmo(curammo - (twinvolley and 2 or 1))

			-- 弹药耗尽时向部署者发送弹药不足提示
			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			self:PlayShootSound()

			local angle = dir:Angle()
			-- 按 NumShots 生成炮弹，双发模式下数量翻倍
			for i = 1, self.NumShots * (twinvolley and 2 or 1) do
				local ent = ents.Create("projectile_drone_pulse")
				if ent:IsValid() then
					ent:SetPos(src)
					ent:SetAngles(angle)
					ent:SetOwner(owner)
					-- 伤害继承主人的投射物伤害倍率
					ent.ProjDamage = self.Damage * (owner.ProjectileDamageMul or 1)
					ent.ProjSource = self

					ent.Team = owner:Team()
					ent:Spawn()

					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:Wake()

						-- 每发炮弹在弹道前方随机旋转一周并上下偏摆，产生散射
						angle:RotateAroundAxis(angle:Forward(), math.Rand(0, 360))
						angle:RotateAroundAxis(angle:Up(), math.Rand(-self.Spread, self.Spread))
						phys:SetVelocityInstantaneous(angle:Forward() * 1200 * (owner.ProjectileSpeedMul or 1))
					end
				end
			end
		else
			-- 弹药不足：短暂冷却后播放空仓音效
			self:SetNextFire(CurTime() + 0.20)
			self:EmitSound("npc/turret_floor/die.wav")
		end
	end
end

