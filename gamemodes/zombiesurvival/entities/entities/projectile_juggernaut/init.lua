-- ============================================================================
-- init.lua - 重装兵投射物（服务端）
-- 负责：发射飞行，碰撞后对命中的活僵尸造成伤害并播放命中特效
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化投射物 ====
-- 设置模型与物理，按通用投射物规则初始化，并播放高速发射音效
function ENT:Initialize()
	self:SetModel("models/props_c17/trappropeller_lever.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetupGenericProjectile(false)

	self:EmitSound("weapons/ar2/fire1.wav", 75, 210)
end

-- ==== PhysicsCollide - 物理碰撞回调 ====
-- 首次碰撞时记录碰撞数据，并安排下一帧处理爆炸（避免重复记录）
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== Explode - 命中爆炸处理 ====
-- 若主人为有效人类且命中目标是活僵尸，则对其造成子弹伤害；并播发命中特效
function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or self:GetForward()

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local source = self:ProjectileDamageSource()
		local target = self.HitData.HitEntity

		-- 只对「始终存活」以外的活僵尸造成伤害（守护类僵尸免疫）
		if target:IsValidLivingZombie() and not target:GetZombieClassTable().NeverAlive then
			target:TakeSpecialDamage(self.ProjDamage or 47, DMG_BULLET, owner, source, hitpos)
		end
	end

	-- 在命中点播发重装兵命中特效
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("hit_jugger", effectdata)
end

-- ==== Think - 命中后爆炸并移除 ====
function ENT:Think()
	if self.HitData then
		self:Explode(self.HitData.HitPos, self.HitData.HitNormal)
		self:Remove()
	end
end
