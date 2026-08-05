-- ============================================================================
-- projectile_zsgrenade/init.lua - 手雷投射物实体（服务器端）
-- 负责：手雷的物理初始化、落地碰撞音效、定时爆炸与范围伤害结算
-- ============================================================================

INC_SERVER()

-- ==== Initialize - 初始化 ====
-- 设定爆炸时间，启用物理碰撞并配置金属材质的刚体
function ENT:Initialize()
	-- 记录爆炸倒计时（寿命结束后自动引爆）
	self.DieTime = CurTime() + self.LifeTime

	-- 使用手雷模型并启用 VPHYSICS 物理模拟
	self:SetModel("models/weapons/w_grenade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	-- 开启自定义碰撞检测（配合 ShouldNotCollide 过滤）
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	-- 唤醒刚体，设定质量与材质
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(4)
		phys:SetMaterial("metal")
	end
end

-- ==== PhysicsCollide - 物理碰撞回调 ====
-- 高速落地时播放金属撞击音效（随机三种之一）
function ENT:PhysicsCollide(data, phys)
	if 20 < data.Speed and 0.25 < data.DeltaTime then
		self:EmitSound("physics/metal/metal_grenade_impact_hard"..math.random(3)..".wav")
	end
end

-- ==== Think - 每帧逻辑 ====
-- 已爆炸则移除自身；否则到达寿命时引爆
function ENT:Think()
	if self.Exploded then
		self:Remove()
	elseif self.DieTime <= CurTime() then
		self:Explode()
	end
end

-- ==== Explode - 引爆 ====
-- 爆炸时对范围内玩家造成爆炸伤害，并播放特效与音效（仅人类投掷者生效）
function ENT:Explode()
	-- 防止重复引爆
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	-- 只有投掷者仍为有效人类时结算伤害（避免已变僵尸的手雷失效）
	if owner:IsValidHuman() then
		local pos = self:GetPos()

		-- 范围爆炸伤害（半径与伤害默认 256，可由投掷武器覆盖）
		util.BlastDamagePlayer(self, owner, pos, self.GrenadeRadius or 256, self.GrenadeDamage or 256, DMG_ALWAYSGIB)

		-- 生成地面烧焦痕迹
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + Vector(0, 0, -1))
			effectdata:SetNormal(Vector(0, 0, -1))
		util.Effect("decal_scorch", effectdata)

		-- 爆炸音效与爆炸粒子效果
		self:EmitSound("npc/env_headcrabcanister/explosion.wav", 85, 100)
		ParticleEffect("dusty_explosion_rockets", pos, angle_zero)
	end
end
