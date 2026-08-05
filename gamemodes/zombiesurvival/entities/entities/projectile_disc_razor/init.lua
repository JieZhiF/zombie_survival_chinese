-- ============================================================================
-- projectile_disc_razor/init.lua - 飞盘锯刃投射物（服务器）
-- 负责：锯刃飞行与物理碰撞；左键射击命中目标直接结算伤害，
--       右键（Secondary）射击可在世界表面反弹最多 4 次后命中结算，
--       3 秒后无论状态如何都会自毁
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：按射击模式设定弹跳次数并装配物理弹体 ====
function ENT:Initialize()
	-- 右键蓄力（Secondary）可反弹 4 次，普通射击 0 次
	self.Bounces = self.Secondary and 4 or 0

	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.25, 0)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	-- 使用通用投射物参数（初速、重力等）
	self:SetupGenericProjectile(false)

	-- 3 秒后强制销毁，防止无限滞留
	self:Fire("kill", "", 3)
end

-- ==== PhysicsUpdate - 物理更新：每帧向前扫描前方碰撞 ====
function ENT:PhysicsUpdate(phys)
	self:ProjectileTraceAhead(phys)
end

-- ==== PhysicsCollide - 物理碰撞：未结算时决定反弹或记录命中数据 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end

	-- 仍有反弹次数且撞上世界表面：沿法线反射并继续飞行
	if self.Bounces <= 3 and data.HitEntity and data.HitEntity:IsWorld() then
		-- 计算镜面反射方向并保持高速
		local normal = data.OurOldVelocity:GetNormalized()
		phys:SetVelocityInstantaneous((2 * data.HitNormal * data.HitNormal:Dot(normal * -1) + normal) * 1500)

		self:EmitSound("physics/metal/sawblade_stick3.wav", 70, 250)

		self.Bounces = self.Bounces + 1
	else
		-- 弹跳次数耗尽或撞上实体：记录本次碰撞数据，等待 Think 结算
		self.HitData = data
	end

	self:NextThink(CurTime())
end

-- ==== Think - 命中结算：触碰目标时造成伤害并移除，否则按碰撞数据移除 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 拥有者失效时以自身为伤害来源
	if not owner:IsValid() then owner = self end

	-- 之前已触碰目标且尚未造成伤害：结算伤害
	if self.Touched and not self.Damaged then
		local tr = self.Touched

		self.Damaged = true
		-- 造成投射物伤害（默认 77 点）
		self:DealProjectileTraceDamage(self.ProjDamage or 77, tr, owner)

		-- 溅射血迹效果
		util.Blood(tr.Entity:WorldSpaceCenter(), math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		self:Remove()
	elseif self.HitData then
		-- 弹跳次数耗尽后撞上物体：直接移除
		self:Remove()
	end
end
