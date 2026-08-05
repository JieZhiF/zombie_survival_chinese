-- ============================================================================
-- projectile_shaderock/init.lua - 暗影石块投射物（服务器）
-- 负责：石块飞行的物理初始化与命中结算——重物理碰撞体，命中非僵尸玩家
--       时造成 66 点物理伤害（受目标物理伤害倍率影响），并触发碎石特效
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：石块模型与重物理碰撞体 ====
function ENT:Initialize()
	-- 花岗岩碎石模型，物理体碰撞并归类为投射物碰撞组
	self:SetModel("models/props_wasteland/rockgranite03b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:SetCustomCollisionCheck(true)

	-- 设置 20 单位质量并启用运动，石块以纯物理方式飞行
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(20)
		phys:EnableMotion(true)
		phys:Wake()
	end
end

-- ==== Think - 飞行逻辑：处理碰撞结果，命中结算后移除自身 ====
function ENT:Think()
	-- 物理碰撞后延迟到下一帧处理命中
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	-- 已结算命中则移除自身
	if self.Exploded then
		self:Remove()
	end
end

-- ==== Hit - 命中结算：对非僵尸目标造成伤害并触发碎石特效 ====
function ENT:Hit(vHitPos, vHitNormal, ent)
	-- 命中只结算一次
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	-- 拥有者无效时以自身为伤害来源
	if not owner:IsValid() then owner = self end

	-- 命中位置/法线缺失时以自身位置兜底
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中有效目标且不是僵尸（含非玩家实体）时造成 66 点物理伤害，
	-- 伤害受目标物理伤害倍率（PhysicsDamageTakenMul）影响
	if ent:IsValid() then
		if not ent:IsPlayer() or (ent:IsPlayer() and ent:Team() ~= TEAM_UNDEAD) then
			ent:TakeSpecialDamage(66 * (ent.PhysicsDamageTakenMul or 1), DMG_GENERIC, owner, self)
		end
	end

	-- 同时触发暗影石与普通碎石两个命中特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_shadestone", effectdata)
	util.Effect("hit_stone", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞：受控期间无视碰撞，其余记录命中数据 ====
function ENT:PhysicsCollide(data, phys)
	-- 石块处于被控制状态（Control 控制实体有效）时忽略碰撞，继续飞行
	if self.Control:IsValid() then return end

	self.PhysicsData = data
	self:NextThink(CurTime())
end
