-- ============================================================================
-- projectile_flak/init.lua - 防空炮弹（高射炮）投射物（服务器）
-- 负责：炮弹飞行与物理碰撞；可在世界表面反弹 1 次，命中目标时按
--       反弹次数折算伤害（反弹越多单次伤害越低），2 秒后自毁
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：装配微型弹体并启用重力弹道 ====
function ENT:Initialize()
	-- 反弹次数计数，从 0 开始
	self.Bounces = 0

	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.05, 0)
	-- 使用带重力的通用投射物参数（炮弹抛物线弹道）
	self:SetupGenericProjectile(true)

	-- 2 秒后强制销毁，防止无限滞留
	self:Fire("kill", "", 2)
end

-- ==== PhysicsUpdate - 物理更新：每帧向前扫描前方碰撞 ====
function ENT:PhysicsUpdate(phys)
	self:ProjectileTraceAhead(phys)
end

-- ==== Explode - 爆炸入口：标记已爆炸（默认无额外爆炸行为，预留钩子） ====
function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or self:GetForward()
end

-- ==== PhysicsCollide - 物理碰撞：未结算时决定反弹或记录命中数据 ====
function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end

	-- 仍有反弹次数且撞上世界表面：反射并继续飞行
	if self.Bounces <= 1 and data.HitEntity and data.HitEntity:IsWorld() then
		-- 沿表面法线镜面反射
		local normal = data.OurOldVelocity:GetNormalized()
		phys:SetVelocityInstantaneous((2 * data.HitNormal * data.HitNormal:Dot(normal * -1) + normal) * 500)

		self:EmitSound("physics/metal/metal_box_impact_bullet3.wav", 65, 250)

		self.Bounces = self.Bounces + 1
	else
		-- 弹跳次数耗尽或撞上实体：记录碰撞数据，等待 Think 结算
		self.HitData = data
	end

	self:NextThink(CurTime())
end

-- ==== Think - 命中结算：触碰目标时造成按反弹次数折算的伤害并移除 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 拥有者失效时以自身为伤害来源
	if not owner:IsValid() then owner = self end

	-- 之前已触碰目标且尚未造成伤害：结算伤害
	if self.Touched and not self.Damaged then
		self.Damaged = true

		local tr = self.Touched

		-- 基础伤害（默认 22）除以反弹次数 +1，反弹越多次衰减越明显
		self:DealProjectileTraceDamage((self.ProjDamage or 22)/(self.Bounces + 1), tr, owner)
		-- 命中位置溅射血迹
		util.Blood(tr.HitPos, math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		self:Remove()
	elseif self.HitData then
		-- 反弹次数耗尽后撞上物体：直接移除
		self:Remove()
	end
end
