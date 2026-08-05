-- ============================================================================
-- init.lua - 电光飞盘投射物（服务器）：飞行、碰撞爆炸与弹雨
-- 负责：飞盘沿直线飞行，碰撞时爆炸，并沿来袭反方向分 8 次倾泻弹雨
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：按物理投射物生成并设定生命周期 ====
function ENT:Initialize()
	self:SetModelScale(0.3, 0)
	self:DrawShadow(false)
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInitSphere(3)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	-- 按投射物通用参数发射（无重力直线飞行）
	self:SetupGenericProjectile(false)

	-- 若 0.3 秒内未碰撞则自动销毁
	self:Fire("kill", "", 0.3)

	self.NextShoot = 0
	-- 记录发射者，供爆炸后的伤害归属使用
	self.PostOwner = self:GetOwner()
end

-- ==== Think - 有碰撞数据时立即触发爆炸 ====
function ENT:Think()
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end
end

-- ==== PhysicsCollide - 物理碰撞：记录碰撞数据并调度爆炸 ====
function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

-- ==== OnRemove - 移除时：播放爆炸特效并沿反方向分次倾泻弹雨 ====
function ENT:OnRemove()
	local hitpos = self.PhysicsData and self.PhysicsData.HitPos or self:GetPos()
	local normal = self.PhysicsData and self.PhysicsData.HitNormal or Vector(0, 0, 1)

	-- 播放飞盘爆炸特效
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(normal)
	util.Effect("explosion_fusordisc", effectdata)

	-- 伤害归属：发射者仍存活则算作发射者的伤害
	local owner = self.PostOwner
	if not owner:IsValidLivingHuman() then owner = self end

	local oldvel = self.PhysicsData and self.PhysicsData.OurOldVelocity or self:GetVelocity()

	-- 沿来袭方向的反方向，分 8 波倾泻弹雨（每波造成一半伤害）
	local backvel = oldvel:GetNormalized()
	local pos = self:GetPos() - backvel * 10
	local dmg = self.ProjDamage
	local me = self:ProjectileDamageSource()

	for i = 1, 8 do
		timer.Simple(i * 0.05, function()
			-- 每波略微抬高弹道仰角，形成扇形扩散
			backvel.z = backvel.z + 0.001 * i
			backvel = backvel:GetNormalized()

			self:FireBulletsLua(pos, -backvel, 1, 1, dmg/2, owner, 0.01, "tracer_fusor", BulletCallback, nil, nil, nil, nil, me)
		end)
	end
end

-- ==== Explode - 爆炸：标记已爆炸并移除自身（爆炸表现由 OnRemove 完成） ====
function ENT:Explode(hitpos, normal, hitent)
	if self.Exploded then return end
	self.Exploded = true

	self:Remove()
end
