-- ============================================================================
-- weapon_zs_asmd/init.lua - ASMD（服务端入口）
-- 负责：指定投射物并实现副射击（蓄力弹）的生成与发射
-- ============================================================================
INC_SERVER()

-- 主射击发射的投射物实体及其初速度
SWEP.Primary.Projectile = "projectile_asmd"
SWEP.Primary.ProjVelocity = 400

-- ==== ShootSecondary - 副射击：从枪口按散射锥生成多个投射物并赋予速度 ====
function SWEP:ShootSecondary(damage, numshots, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	for i = 0,numshots-1 do
		-- 创建投射物并设置位置、角度、伤害与归属信息
		local ent = ents.Create(self.Primary.Projectile)
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:SetAngles(owner:EyeAngles())
			ent:SetOwner(owner)
			ent.ProjDamage = damage * (owner.ProjectileDamageMul or 1)
			ent.ProjSource = self
			ent.Team = owner:Team()

			ent:Spawn()

			-- 在锥形范围内随机偏移发射方向（绕前进轴随机旋转 + 上下随机偏转）
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()

				local angle = owner:GetAimVector():Angle()
				angle:RotateAroundAxis(angle:Forward(), math.Rand(0, 360))
				angle:RotateAroundAxis(angle:Up(), math.Rand(-cone, cone))
				phys:SetVelocityInstantaneous(angle:Forward() * self.Primary.ProjVelocity * (owner.ProjectileSpeedMul or 1))
			end
		end
	end
end
