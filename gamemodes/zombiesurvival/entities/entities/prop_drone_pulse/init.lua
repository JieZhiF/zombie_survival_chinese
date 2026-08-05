-- ============================================================================
-- prop_drone_pulse/init.lua - 脉冲无人机炮塔（服务器）
-- 负责：开火发射脉冲弹投射物，消耗弹药并受冷却限制；弹药耗尽时停机
-- ============================================================================
INC_SERVER()

-- 发射的投射物类型：无人机脉冲弹
ENT.Projectile = "projectile_drone_pulse"

-- ==== FireTurret - 炮塔开火：消耗弹药发射脉冲弹 ====
function ENT:FireTurret(src, dir)
	-- 冷却结束且持有弹药时才可开火
	if self:GetNextFire() <= CurTime() then
		local curammo = self:GetAmmo()
		if curammo > 0 then
			-- 冷却 0.36 秒，每次射击消耗 2 发弹药
			self:SetNextFire(CurTime() + 0.36)
			self:SetAmmo(curammo - 2)

			self:PlayShootSound()

			local owner = self:GetObjectOwner()
			local angle = dir:Angle()

			-- 在炮口前方生成脉冲弹
			local ent = ents.Create(self.Projectile)
			if ent:IsValid() then
				ent:SetAngles(angle)
				ent:SetOwner(owner)
				ent:SetPos(src + angle:Forward() * 5)
				-- 基础伤害 22，受拥有者投射物伤害倍率影响
				ent.ProjDamage = 22 * (owner.ProjectileDamageMul or 1)
				-- 记录炮塔本体作为投射物来源
				ent.ProjSource = self

				ent.Team = owner:Team()
				ent:Spawn()

				-- 以 470 单位/秒的初速发射（受拥有者投射物速度倍率影响）
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()

					phys:SetVelocityInstantaneous(angle:Forward() * 470 * (owner.ProjectileSpeedMul or 1))
				end
			end
		else
			-- 弹药耗尽：2 秒后重试并播放炮塔损毁音效
			self:SetNextFire(CurTime() + 2)
			self:EmitSound("npc/turret_floor/die.wav")
		end
	end
end

-- ==== PlayShootSound - 播放开火音效（音调随机微调） ====
function ENT:PlayShootSound()
	self:EmitSound("weapons/zs_rail/rail.wav", 70, math.random(238, 243), 0.86, CHAN_AUTO)
end
