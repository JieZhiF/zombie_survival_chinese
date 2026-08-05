-- ============================================================================
-- projectile_poisonflesh - 毒肉投射物实体（服务端）
-- 负责：控制毒肉飞行与命中引爆：命中目标造成中毒伤害并播放血肉特效，30 秒后自动移除
-- ============================================================================
INC_SERVER()

-- 命中目标时造成的毒素伤害值
ENT.Damage = 4

-- ==== Initialize - 初始化飞行参数：球形物理体、30 秒寿命、通用投射物设置 ====
function ENT:Initialize()
	self.DeathTime = CurTime() + 30

	self:DrawShadow(false)
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetupGenericProjectile(true)
end

-- ==== Think - 处理物理碰撞结果并在寿命到期时自动移除 ====
function ENT:Think()
	-- 已记录碰撞数据时在命中位置引爆
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	-- 超过 30 秒寿命后自动消失
	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

-- ==== Explode - 命中引爆：对目标施加中毒伤害并播放血肉飞溅特效 ====
function ENT:Explode(vHitPos, vHitNormal, eHitEntity)
	-- 防止重复引爆
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	-- 拥有者无效时以自身作为伤害来源
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中有效实体时对其施加中毒伤害
	if eHitEntity:IsValid() then
		eHitEntity:PoisonDamage(self.Damage, owner, self)
	end

	-- 在命中位置播放血肉特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_flesh", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞回调：非栅栏命中时记录碰撞数据供 Think 引爆 ====
function ENT:PhysicsCollide(data, phys)
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end
