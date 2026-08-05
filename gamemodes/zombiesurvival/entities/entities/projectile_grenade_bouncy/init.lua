-- ============================================================================
-- init.lua - 弹跳手雷投射物（服务器）：抛物线弹跳、计时与撞击爆炸
-- 负责：手雷沿抛物线飞行并最多弹跳 2 次，命中玩家/建造物或到时即爆炸
-- ============================================================================
INC_SERVER()

-- 手雷从生成到自动爆炸的寿命（秒）
ENT.LifeTime = 3

-- ==== Initialize - 初始化：按受重力投射物生成并设定弹跳/爆炸参数 ====
function ENT:Initialize()
	self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self:SetColor(Color(255, 255, 0))
	self:PhysicsInitSphere(3)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.2, 0)
	self:DrawShadow(false)
	self:SetupGenericProjectile(true)

	-- 剩余弹跳次数 2 次；爆炸时间与免弹跳缓冲期
	self.Bounces = 2
	self.ExplodeTime = CurTime() + self.LifeTime
	self.Grace = CurTime() + 0.1
end

-- ==== Think - 每帧处理：到时/撞击爆炸，否则按法线反射反弹 ====
function ENT:Think()
	if self.ExplodeTime <= CurTime() then
		self:Explode(self:GetPos())
	end
	if self.PhysicsData then
		-- 弹跳次数耗尽、命中玩家或僵尸建造物时立即爆炸
		if self.Bounces <= 0 or self.PhysicsData.HitEntity:IsPlayer() or self.PhysicsData.HitEntity.ZombieConstruction then
			self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
		end
		-- 沿命中法线反射速度（保留 80%），实现弹性反弹
		local phys = self.PhysicsData.PhysObject
		if phys:IsValid() then
			local hitnormal = self.PhysicsData.HitNormal
			local vel = self.PhysicsData.OurOldVelocity
			local normal = vel:GetNormalized()
			phys:SetVelocityInstantaneous((2 * hitnormal * hitnormal:Dot(normal * -1) + normal) * vel:Length() * 0.8)
		end
		-- 缓冲期结束后每次碰撞消耗一次弹跳次数
		if CurTime() >= self.Grace then
			self.Bounces = self.Bounces -1
		end
		self.PhysicsData = nil
	end

	self:NextThink(CurTime())
	return true
end

-- ==== Explode - 爆炸：对人类造成范围伤害并播放音效后移除 ====
function ENT:Explode(hitpos, hitnormal, hitent)
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()

	if owner:IsValidLivingHuman() then
		-- 以发射者为伤害来源，造成范围爆破伤害（默认 29 点）
		local source = self:ProjectileDamageSource()
		util.BlastDamagePlayer(source, owner, hitpos, 81, self.ProjDamage or 29, DMG_ALWAYSGIB, 0.95)
	end

	self:EmitSound(")weapons/explode5.wav", 80, 130)
	self:Remove()
end

-- ==== PhysicsCollide - 物理碰撞：记录碰撞数据并调度反弹/爆炸处理 ====
function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
