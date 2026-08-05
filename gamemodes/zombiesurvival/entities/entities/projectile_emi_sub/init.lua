-- ============================================================================
-- projectile_emi_sub - 电磁脉冲子投射物实体（服务端）
-- 负责：初始化模型与物理、自定义螺旋坠落飞行轨迹、命中时造成溶解伤害与范围溅射
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化模型、球形物理碰撞体与通用投射物属性，播放飞行音效并在 5.75 秒后自动移除 ====
function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(4)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.55, 0)
	self:SetupGenericProjectile(false)

	self:EmitSound("weapons/physcannon/energy_sing_flyby2.wav", 70, math.random(245, 255))
	self:Fire("kill", "", 5.75)
	self.Creation = UnPredictedCurTime()
end

-- 复用的零向量局部变量（PhysicsUpdate 每物理帧调用，避免反复分配新表）
local vecDown = Vector()
-- ==== PhysicsUpdate - 自定义飞行轨迹：水平速度逐步衰减，垂直方向先上升后下降并叠加正弦浮动 ====
function ENT:PhysicsUpdate(phys)
	local livetime = UnPredictedCurTime() - self.Creation
	local vel = phys:GetVelocity()

	vecDown.x = vel.x * 0.95
	vecDown.y = vel.y * 0.95
	vecDown.z = (200 + livetime * -300) + math.sin(self.Rot + livetime * 10) * 250

	phys:SetVelocityInstantaneous(vecDown)
end

-- ==== Hit - 命中处理：对直接命中的目标造成溶解伤害，并在命中点产生范围溅射伤害 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 同一投射物只处理一次命中
	if self.Exploded then return end
	self.Exploded = true

	-- 拥有者无效时以自身作为伤害来源兜底
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 仅当拥有者为存活人类玩家时才造成伤害
	if owner:IsValidLivingHuman() then
		-- 获取实际伤害来源（投射物本体或拥有者）
		local source = self:ProjectileDamageSource()
		if eHitEntity and eHitEntity:IsValid() then
			-- 对命中实体直接造成溶解伤害（含投射物伤害倍率加成）
			eHitEntity:TakeSpecialDamage((self.ProjDamage or 25) * (owner.ProjectileDamageMul or 1), DMG_DISSOLVE, owner, source, hitpos)

			-- 命中点附带范围溶解溅射伤害（一半投射物伤害，半径 67）
			util.BlastDamagePlayer(source, owner, vHitPos + vHitNormal, 67, self.ProjDamage/2, DMG_DISSOLVE)
		end
	end
end
