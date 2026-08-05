-- ============================================================================
-- init.lua - 提托努斯毒针投射物（服务端）：飞行、命中伤害与腿部减速
-- 负责：小体积快速毒针，飞行中持续下压，命中僵尸造成伤害与腿部脉冲减速
-- ============================================================================
INC_SERVER()

-- 命中僵尸时的得分倍率（结算期间临时生效）
ENT.PointsMultiplier = 1.25

-- ==== Initialize - 初始化毒针：模型、物理与 2 秒自毁 ====
function ENT:Initialize()
	-- 2 秒后自动销毁（未命中也不遗留）
	self:Fire("kill", "", 2)

	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(2)
	self:SetSolid(SOLID_VPHYSICS)
	-- 缩小到 20% 呈现针状小体积
	self:SetModelScale(0.2, 0)
	self:SetupGenericProjectile(false)
	-- 记录未预测时间戳，供 PhysicsUpdate 计算帧间隔
	self.LastPhysicsUpdate = UnPredictedCurTime()
end

-- 复用的下压速度向量（避免每帧新建）
local vecDown = Vector()
-- ==== PhysicsUpdate - 物理更新：向前探测命中并施加持续下坠力 ====
function ENT:PhysicsUpdate(phys)
	-- 在飞行方向前方做射线检测，命中僵尸时记录 Touched
	self:ProjectileTraceAhead(phys)

	-- 按实际帧间隔施加 -200 单位/秒的下压速度，使毒针呈抛物线坠射
	local dt = UnPredictedCurTime() - self.LastPhysicsUpdate
	self.LastPhysicsUpdate = UnPredictedCurTime()

	vecDown.z = dt * -200
	phys:AddVelocity(vecDown)
end

-- ==== PhysicsCollide - 物理碰撞回调：记录碰撞数据待 Think 处理 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end
	self.HitData = data

	self:NextThink(CurTime())
end

-- ==== OnRemove - 移除时在命中点播放毒针命中特效 ====
function ENT:OnRemove()
	local effectdata = EffectData()
		effectdata:SetOrigin(self.HitData and self.HitData.HitPos or self:GetPos())
		effectdata:SetNormal(self.HitData and self.HitData.HitNormal or Vector(0, 0, 0))
	util.Effect("hit_tithonus", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞回调：记录碰撞数据待 Think 处理 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== Think - 每帧结算：射线命中僵尸则造成伤害，物理碰撞则直接移除 ====
function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 射线检测命中（Touched 由 ProjectileTraceAhead 写入）且尚未结算伤害
	if self.Touched and not self.Damaged then
		self.Damaged = true

		local tr = self.Touched

		-- 结算期间启用 1.25 倍得分倍率
		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end
		-- 对命中目标造成 77 点投射物伤害
		self:DealProjectileTraceDamage(self.ProjDamage or 77, tr, owner)
		-- 命中玩家时额外施加 5.5 点腿部伤害与脉冲减速
		if tr.Entity:IsPlayer() then
			tr.Entity:AddLegDamageExt(5.5, owner, source, SLOWTYPE_PULSE)
		end
		-- 结算结束，清除得分倍率
		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		-- 在命中点喷射绿色血液
		util.Blood(tr.Entity:WorldSpaceCenter(), math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		self:Remove()
	elseif self.HitData then
		-- 撞上障碍物（世界碰撞）时直接移除
		self:Remove()
	end
end
