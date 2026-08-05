-- ============================================================================
-- prop_gunturret_rocket/init.lua - 火箭炮塔（服务器）
-- 负责：开火冷却与弹药消耗，生成带散布的火箭投射物；无弹药时提示并延迟重试
-- ============================================================================
INC_SERVER()

-- 无弹药时的重试间隔（秒）
ENT.LastHitPeriod = 4

-- ==== FireTurret - 炮塔开火：消耗弹药生成 rocket 投射物（支持双联齐射技能） ====
function ENT:FireTurret(src, dir)
	-- 仅在冷却结束时开火
	if self:GetNextFire() <= CurTime() then
		local curammo = self:GetAmmo()
		local owner = self:GetObjectOwner()
		-- 手动控制且拥有双联齐射技能时一次发射两发（消耗翻倍）
		local twinvolley = self:GetManualControl() and owner:IsSkillActive(SKILL_TWINVOLLEY)
		if curammo > (twinvolley and 1 or 0) then
			-- 设定下次开火时间；双联时冷却延长 1.5 倍作为平衡
			self:SetNextFire(CurTime() + self.FireDelay * (twinvolley and 1.5 or 1))
			self:SetAmmo(curammo - (twinvolley and 2 or 1))

			-- 弹药耗尽时通知拥有者
			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			self:PlayShootSound()

			-- 按齐射数量生成火箭（双联翻倍）
			local angle = dir:Angle()
			for i = 1, self.NumShots * (twinvolley and 2 or 1) do
				local ent = ents.Create("projectile_rocket")
				if ent:IsValid() then
					-- 设定发射位置、朝向与施放者
					ent:SetPos(src)
					ent:SetAngles(angle)
					ent:SetOwner(owner)
					-- 伤害受拥有者投射物伤害倍率加成
					ent.ProjDamage = self.Damage * (owner.ProjectileDamageMul or 1)
					ent.ProjSource = self
					ent.ProjTaper = 0.95

					-- 继承拥有者阵营（供友军伤害判定使用）
					ent.Team = owner:Team()
					ent:Spawn()

					-- 唤醒物理体并施加随机散布：绕前进轴随机旋转 + 上下散布
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:Wake()

						angle:RotateAroundAxis(angle:Forward(), math.Rand(0, 360))
						angle:RotateAroundAxis(angle:Up(), math.Rand(-self.Spread, self.Spread))
						-- 以 900 单位/秒初速射出，受拥有者投射物速度倍率加成
						phys:SetVelocityInstantaneous(angle:Forward() * 900 * (owner.ProjectileSpeedMul or 1))
					end
				end
			end
		else
			-- 弹药不足：播放失电音效，2 秒后重试
			self:SetNextFire(CurTime() + 2)
			self:EmitSound("npc/turret_floor/die.wav")
		end
	end
end
