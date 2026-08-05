-- ============================================================================
-- projectile_shadeice/init.lua - 寒冰投射物（服务器）
-- 负责：管理冰弹的飞行物理；命中后播放冰碎特效并结算伤害，
--       对爆炸范围内的存活玩家按距离施加冰冻状态与腿部减速
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：设置冰弹模型、材质、颜色与物理属性 ====
function ENT:Initialize()
	self:SetModel("models/props_wasteland/rockcliff01g.mdl")
	self:SetModelScale(0.3, 0)
	self:SetMaterial("models/shadertest/shader2")
	self:SetColor(Color(0, 150, 255, 255))
	self:PhysicsInitSphere(10)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:SetCustomCollisionCheck(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(20)
		phys:EnableMotion(true)
		phys:Wake()
	end
end

-- ==== Think - 处理物理碰撞结果，爆炸后移除自身 ====
function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.Exploded then
		self:Remove()
	end
end

-- ==== Hit - 命中结算：直击伤害 + 范围冰冻与腿部减速 ====
function ENT:Hit(vHitPos, vHitNormal, hitent)
	-- 每颗冰弹只结算一次命中
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	-- 施放者失效时以冰弹自身作为伤害来源
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中点播放冰碎特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_ice", effectdata)

	-- 直击目标（非亡灵单位）受到 44 点通用伤害，倍率受目标物理伤害修正影响
	if hitent:IsValid() and not hitent:IsPlayer() or (hitent:IsPlayer() and hitent:Team() ~= TEAM_UNDEAD) then
		hitent:TakeSpecialDamage(44 * (hitent.PhysicsDamageTakenMul or 1), DMG_GENERIC, owner, self)

		-- 目标自身拥有冰霜 AOE 免疫时不扩散冰冻效果
		if hitent.FizzleStatusAOE then return end
	end

	-- 爆炸范围 110：按距离衰减为范围内存活玩家施加冰冻状态与腿部减速
	for _, ent in pairs(util.BlastAlloc(self, owner, vHitPos, 110)) do
		if ent:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", ent, owner) and ent ~= owner then
			local nearest = ent:NearestPoint(vHitPos)
			local scalar = ((110 - nearest:Distance(vHitPos)) / 110)

			-- 距离越近冻结越久，同时按同比例叠加腿部减速
			ent:GiveStatus("frost", scalar * 6)
			ent:AddLegDamageExt(18 * scalar, owner, self, SLOWTYPE_COLD)
		end
	end
end

-- ==== PhysicsCollide - 物理碰撞：记录碰撞数据待下帧结算 ====
function ENT:PhysicsCollide(data, phys)
	-- 投射物处于遥控控制状态时不结算碰撞
	if self.Control:IsValid() then return end

	self.PhysicsData = data
	self:NextThink(CurTime())
end
