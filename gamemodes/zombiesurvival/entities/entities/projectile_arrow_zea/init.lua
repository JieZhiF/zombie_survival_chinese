-- ============================================================================
-- projectile_arrow_zea - 宙斯（ZEA）电击箭投射物实体（服务端）
-- 负责：控制电击箭的飞行与命中：飞行中持续发射电弧子弹，命中造成电击伤害并概率附加麻痹状态
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化模型/物理与通用投射物设置，并记录首次射击时间 ====
function ENT:Initialize()
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetupGenericProjectile(false)
	self.LastPhysicsUpdate = UnPredictedCurTime()

	self.NextShoot = CurTime() + 0.05
end

-- 复用向量（避免每帧分配新表）
local vecDown = Vector()
-- ==== PhysicsUpdate - 每帧给投射物施加向下重力加速度（每秒 400 单位/秒） ====
function ENT:PhysicsUpdate(phys)
	local dt = UnPredictedCurTime() - self.LastPhysicsUpdate
	self.LastPhysicsUpdate = UnPredictedCurTime()

	vecDown.z = dt * -400
	phys:AddVelocity(vecDown)
end

-- ==== PhysicsCollide - 记录首次碰撞数据并安排下次 Think 处理 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end
	self.HitData = data

	self:NextThink(CurTime())
end

-- ==== Explode - 命中引爆：对僵尸造成电击伤害，并概率对周围玩家附加 7 秒麻痹状态 ====
function ENT:Explode(hitpos, hitnormal)
	-- 防止重复引爆
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or self:GetForward()

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local source = self:ProjectileDamageSource()

		-- 命中僵尸（或僵尸建造物）时造成电击伤害：基础伤害的 65%，目标处于麻痹状态时额外提升 25%
		local ent = self.HitData.HitEntity
		if ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive or ent.ZombieConstruction then
			ent:TakeSpecialDamage((ent:GetStatus("shockdebuff") and 1.25 or 1) * (self.ProjDamage or 125) * 0.65, DMG_SHOCK, owner, source, hitpos)
			ent:EmitSound("ambient/energy/zap1.wav", 70, 240, 0.7, CHAN_AUTO)
		end

		-- 33% 概率对命中点 60 半径内的存活玩家附加 7 秒麻痹状态
		if math.random(3) == 1 then
			for _, pl in pairs(util.BlastAlloc(source, owner, hitpos, 60)) do
				if pl:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", pl, owner) then
					local status = pl:GiveStatus("shockdebuff")
					status.DieTime = CurTime() + 7
				end
			end
		end
	end

	-- 在命中位置播放电击特效
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("hit_zeus", effectdata)
end

-- ==== Think - 飞行中每秒发射电弧子弹；命中后引爆并移除自身 ====
function ENT:Think()
	-- 每秒发射一发沿飞行方向飞行的电弧子弹（伤害为基础伤害的 45%）
	if CurTime() > self.NextShoot then
		self.NextShoot = CurTime() + 1

		local owner = self:GetOwner()
		if not owner:IsValidLivingHuman() then owner = self end

		local phys = self:GetPhysicsObject()
		local source = self:ProjectileDamageSource()

		self:FireBulletsLua(self:GetPos() + self:GetForward() * 1, phys:GetVelocity():GetNormalized(), 0, 1, self.ProjDamage * 0.45, owner, 0.01, "tracer_zapper", BulletCallback, nil, nil, nil, nil, source)
	end

	-- 已有碰撞数据时：引爆、播放音效并移除自身
	if self.HitData then
		self:Explode(self.HitData.HitPos, self.HitData.HitNormal)
		self:EmitSound("weapons/physcannon/superphys_small_zap1.wav", 85, 90, 1, CHAN_AUTO)
		self:Remove()
	end

	self:NextThink(CurTime())
end
