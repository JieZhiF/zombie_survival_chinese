-- ============================================================================
-- init.lua - 投掷物武器基类服务端逻辑
-- 负责：实现投掷物生成（ShootBullets）——创建投射物实体、设置伤害/队伍、
--       按视线方向施加初速度与随机翻滚角速度
-- ============================================================================
INC_SERVER()

-- 投掷生成的投射物实体（碎片手雷）
SWEP.ThrownProjectile = "projectile_zsgrenade"
-- 投射物随机翻滚角速度大小
SWEP.ThrowAngVel = 5
-- 投射物初速度
SWEP.ThrowVel = 800

-- ==== ShootBullets - 生成并抛掷投射物 ====
-- damage 参数实际作为"副模式投掷"标记：副投时出生点降低且初速度仅为主投的 40%
function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()
	-- 播放投掷动画与攻击事件
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()

	-- 在射击位置生成投射物（副投时向下偏移 16 单位）
	local ent = ents.Create(self.ThrownProjectile)
	if ent:IsValid() then
		local pos = owner:GetShootPos()
		pos.z = pos.z - (damage and 16 or 0)
		ent:SetPos(pos)
		ent:SetOwner(owner)
		ent:Spawn()

		-- 传递爆炸伤害/半径与阵营信息
		ent.GrenadeDamage = self.GrenadeDamage
		ent.GrenadeRadius = self.GrenadeRadius
		ent.Team = owner:Team()

		-- 唤醒物理并施加随机翻滚角速度与视线方向初速度
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:AddAngleVelocity(VectorRand() * self.ThrowAngVel)
			phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * self.ThrowVel * (damage and 0.4 or 1) * (owner.ObjectThrowStrengthMul or 1))
		end

		-- 记录物理攻击者为玩家（用于击杀归属）
		ent:SetPhysicsAttacker(owner)
	end
end
