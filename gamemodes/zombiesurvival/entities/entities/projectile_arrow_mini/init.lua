-- ============================================================================
-- projectile_arrow_mini/init.lua - 迷你箭矢投射物（服务器）
-- 负责：发射后飞行的箭矢：命中时对小范围造成爆炸伤害，并对僵尸
--       造成额外直接伤害；15 秒后自动消失
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 生成箭矢：模型/物理/音效与自毁计时 ====
function ENT:Initialize()
	-- 弩箭模型并缩小 55%
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:SetModelScale(0.55, 0)
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 标准投射物初始化（不因碰撞掉落等）
	self:SetupGenericProjectile(true)

	-- 飞行音效
	self:EmitSound("weapons/crossbow/bolt_fly4.wav", 75, 125)

	-- 15 秒后自动销毁
	self:Fire("kill", "", 15)
end

-- ==== PhysicsCollide - 记录首次碰撞并进入 Think 结算 ====
function ENT:PhysicsCollide(data, phys)
	-- 只结算第一次碰撞
	if self.HitData then return end
	self.HitData = data

	self:NextThink(CurTime())
end

-- ==== Explode - 命中爆炸结算：范围伤害 + 僵尸直接伤害 + 特效 ====
function ENT:Explode(hitpos, hitnormal)
	-- 防止重复爆炸
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or self:GetForward()

	local owner = self:GetOwner()
	-- 仅当发射者为人类时造成伤害
	if owner:IsValidHuman() then
		local source = self:ProjectileDamageSource()

		-- 56 半径范围爆炸：投射物伤害的 40%
		util.BlastDamagePlayer(source, owner, hitpos, 56, self.ProjDamage * 0.4, DMG_ALWAYSGIB, 0.95)
		-- 直接命中的僵尸/僵尸建造物：额外 65% 直接伤害
		local ent = self.HitData.HitEntity
		if (ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive) or ent.ZombieConstruction then
			ent:TakeSpecialDamage(self.ProjDamage * 0.65, DMG_GENERIC, owner, source, hitpos)
		end
	end

	-- 爆炸特效与音效
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("HelicopterMegaBomb", effectdata)
	self:EmitSound(")weapons/explode3.wav", 80, 180)
end

-- ==== Think - 碰撞后立刻爆炸并销毁自身 ====
function ENT:Think()
	if self.HitData then
		self:Explode(self.HitData.HitPos, self.HitData.HitNormal)
		self:EmitSound("physics/metal/sawblade_stick"..math.random(3)..".wav", 100, 240, 0.7, CHAN_AUTO)
		self:Remove()
	end
end
