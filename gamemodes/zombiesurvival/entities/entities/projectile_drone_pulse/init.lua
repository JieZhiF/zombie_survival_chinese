-- ============================================================================
-- projectile_drone_pulse/init.lua - 无人机脉冲弹（服务器）
-- 负责：飞行穿透人类玩家，命中僵尸结算伤害与腿部减速，1 秒后自毁
-- ============================================================================
INC_SERVER()

-- 命中结算期间适用的击杀得分倍率
ENT.PointsMultiplier = 1.25

-- ==== Initialize - 初始化：创建小型悬浮球投射物，1 秒后自动销毁 ====
function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl")
	-- 球形物理碰撞体（半径 1）
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	-- 模型缩小至 25%
	self:SetModelScale(0.25, 0)
	self:SetupGenericProjectile(false)

	-- 1 秒内未命中则自动销毁
	self:Fire("kill", "", 1)
end

-- ==== PhysicsUpdate - 物理更新：每帧向前方射线检测，捕捉僵尸/僵尸建筑 ====
function ENT:PhysicsUpdate(phys)
	self:ProjectileTraceAhead(phys)
end

-- ==== PhysicsCollide - 物理碰撞：记录命中数据，下一帧结算 ====
function ENT:PhysicsCollide(data, phys)
	-- 只处理第一次碰撞
	if self.HitData then return end
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== Think - 结算命中：对僵尸造成伤害与腿部减速，随后移除 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 施放者失效时以自身为伤害来源
	if not owner:IsValid() then owner = self end

	-- 射线检测命中目标（僵尸/僵尸建筑）且尚未结算时处理伤害
	if self.Touched and not self.Damaged then
		self.Damaged = true

		local tr = self.Touched

		-- 结算期间临时启用 1.25 倍得分
		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end
		-- 造成投射物伤害（默认 19），含命中部位判定
		self:DealProjectileTraceDamage(self.ProjDamage or 19, tr, owner)
		-- 命中玩家时附加腿部伤害（脉冲型减速效果）
		if tr.Entity:IsPlayer() then
			tr.Entity:AddLegDamageExt(5.5, owner, source, SLOWTYPE_PULSE)
		end
		-- 恢复默认得分倍率
		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		-- 喷血表现并移除弹体
		util.Blood(tr.Entity:WorldSpaceCenter(), math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		self:Remove()
	elseif self.HitData then
		-- 撞上世界物体等非射线目标：直接销毁
		self:Remove()
	end
end
