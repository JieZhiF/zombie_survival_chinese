-- ============================================================================
-- weapon_zs_baseproj/init.lua - 投射物武器基础模板（服务器端）
-- 负责：生成投射物、施加后坐力与随机扩散方向的核心开火逻辑
-- ============================================================================

INC_SERVER()

-- 默认投射物实体（箭矢）
SWEP.Primary.Projectile = "projectile_arrow"

-- ==== EntModify - 生成投射物前的实体修改钩子（默认不修改） ====
function SWEP:EntModify(ent)
end

-- ==== PhysModify - 生成投射物后的物理修改钩子（默认不修改） ====
function SWEP:PhysModify(physobj)
end

-- ==== ShootBullets - 发射投射物：后坐力、随机散布与多发射击 ====
function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	-- 后坐力视角震动（轻微随机晃动）
	if self.Recoil > 0 then
		local r = math.Rand(0.8, 1)
		owner:ViewPunch(Angle(r * -self.Recoil, 0, (1 - r) * (math.random(2) == 1 and -1 or 1) * self.Recoil))
	end

	-- SameSpread 模式下所有投射物共用同一随机散布方向（霰弹式齐射）
	local ssfw, ssup
	if self.SameSpread then
		ssfw, ssup = math.Rand(0, 360), math.Rand(-cone, cone)
	end

	-- 逐发创建投射物：伤害受玩家投射物伤害倍率影响
	for i = 0,numshots-1 do
		local ent = ents.Create(self.Primary.Projectile)
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:SetAngles(owner:EyeAngles())
			ent:SetOwner(owner)
			ent.ProjDamage = self.Primary.Damage * (owner.ProjectileDamageMul or 1)
			ent.ProjSource = self
			ent.ShotMarker = i
			ent.Team = owner:Team()

			-- 允许武器自定义实体并生成
			self:EntModify(ent)
			ent:Spawn()

			-- 设置初速度：绕前轴随机旋转 + 绕上轴随机散布（受玩家速度倍率影响）
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()

				local angle = owner:GetAimVector():Angle()
				angle:RotateAroundAxis(angle:Forward(), ssfw or math.Rand(0, 360))
				angle:RotateAroundAxis(angle:Up(), ssup or math.Rand(-cone, cone))

				ent.PreVel = angle:Forward() * self.Primary.ProjVelocity * (owner.ProjectileSpeedMul or 1)
				phys:SetVelocityInstantaneous(ent.PreVel)

				self:PhysModify(phys)
			end
		end
	end
end
