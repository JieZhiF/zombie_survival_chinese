-- ============================================================================
-- init.lua - 混沌之箭投射物（服务器）：直线飞行、命中伤害与爆炸
-- 负责：沿直线飞行并提前射线探测命中，命中实体结算伤害、命中物体触发爆炸
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：按受重力投射物生成并播放飞行音效 ====
function ENT:Initialize()
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 通用投射物参数（带重力，呈抛物线飞行）
	self:SetupGenericProjectile(true)

	self:EmitSound("weapons/crossbow/bolt_fly4.wav", 75, 130)
end

-- ==== PhysicsUpdate - 物理更新：沿飞行方向提前射线探测命中 ====
function ENT:PhysicsUpdate(phys)
	self:ProjectileTraceAhead(phys)
end

-- ==== Explode - 爆炸：在命中点播放混沌爆炸特效 ====
function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or self:GetForward()

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("hit_charon", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞：记录碰撞数据（栅栏除外）并调度处理 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end
	-- 撞到栅栏类物体不算最终命中，允许继续穿透
	if not self:HitFence(data, phys) then
		self.HitData = data
	end

	self:NextThink(CurTime())
end

-- ==== Think - 每帧处理：命中实体结算伤害与喷血，命中物体爆炸后移除 ====
function ENT:Think()
	self:NextThink(CurTime())

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if self.Touched and not self.Damaged then
		-- 首次命中实体：只结算一次伤害
		self.Damaged = true

		local tr = self.Touched

		-- 对命中的实体结算投射物伤害（默认 77 点）
		self:DealProjectileTraceDamage(self.ProjDamage or 77, tr, owner)

		-- 播放命中音效（人体中箭声或切割声随机）
		tr.Entity:EmitSound(math.random(2) == 1 and "weapons/crossbow/hitbod"..math.random(2)..".wav" or "ambient/machines/slicer"..math.random(4)..".wav", 75, 150)

		-- 按命中方向喷血
		util.Blood(tr.Entity:WorldSpaceCenter(), math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		self:Explode()
		self:EmitSound("physics/metal/sawblade_stick"..math.random(3)..".wav", 70, 250)
		self:Remove()
	elseif self.HitData then
		-- 撞到场景物体：在碰撞点爆炸并移除
		self:Explode(self.HitData.HitPos, self.HitData.HitNormal)
		self:EmitSound("physics/metal/sawblade_stick"..math.random(3)..".wav", 70, 250)
		self:Remove()
	end
	return true
end
