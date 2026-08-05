-- ============================================================================
-- projectile_asmd/init.lua - ASMD 能量弹投射物（服务器）
-- 负责：能量弹的飞行与两种引爆方式：撞击目标小范围伤害 +
--       直击僵尸高额伤害；被主枪命中时触发大范围替代爆炸
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：设置模型与通用投射物物理，10 秒后自动移除 ====
function ENT:Initialize()
	self.Bounces = 0

	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(2, 0)
	self:SetupGenericProjectile(false)

	self:Fire("kill", "", 10)
end

-- ==== Explode - 撞击爆炸：小范围溅射 + 直击僵尸额外伤害 ====
function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or self:GetForward()

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local source = self:ProjectileDamageSource()
		local ent = self.HitData.HitEntity
		-- 50 半径溅射：20% 投射物伤害，无视伤害衰减
		util.BlastDamagePlayer(source, owner, self:GetPos(), 50, (self.ProjDamage or 52) * 0.2, DMG_ALWAYSGIB, 0.96)
		-- 直击普通僵尸：90% 投射物伤害的集中打击
		if ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
			ent:TakeSpecialDamage((self.ProjDamage or 49) * 0.9, DMG_GENERIC, owner, source, hitpos)
		end
	end
end

-- ==== ExplodeAlt - 替代爆炸：被主枪能量束引爆，大范围高额伤害 ====
function ENT:ExplodeAlt()
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local source = self:ProjectileDamageSource()
		-- 124 半径，225% 投射物伤害
		util.BlastDamagePlayer(source, owner, self:GetPos(), 124, (self.ProjDamage or 52) * 2.25, DMG_ALWAYSGIB, 0.96)
	end

	-- 播放震波核心特效
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetNormal(self:GetForward())
	util.Effect("explosion_shockcore", effectdata)

	self:Remove()
end

-- ==== OnTakeDamage - 受伤响应：被拥有者 ASMD 主弹命中时替代引爆 ====
function ENT:OnTakeDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValidLivingHuman() then
		local inflictor = dmginfo:GetInflictor()

		-- 判定：施害物为 ASMD 武器且攻击者为拥有者本人
		if inflictor:IsValid() and dmginfo:GetDamageType() == DMG_GENERIC and inflictor.ASMD and attacker == self:GetOwner() then
			self:ExplodeAlt()
		end
	end
end

-- ==== PhysicsCollide - 物理碰撞：记录首次碰撞数据 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== Think - 结算碰撞：爆炸后移除 ====
function ENT:Think()
	if self.HitData then
		self:Explode(self.HitData.HitPos, self.HitData.HitNormal)
		self:Remove()
	end
end
