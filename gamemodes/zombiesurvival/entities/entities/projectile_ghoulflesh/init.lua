-- ============================================================================
-- projectile_ghoulflesh/init.lua - 食尸鬼腐肉投射物（服务器）
-- 负责：管理腐肉球飞行与命中结算：命中玩家施加 5 秒减速与腿部损伤；
--       未命中时 30 秒后自动消失
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：设置模型与物理，30 秒后自动移除 ====
function ENT:Initialize()
	self.DeathTime = CurTime() + 30

	self:SetModel("models/props/cs_italy/orange.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(255, 255, 0, 255))
	self:SetupGenericProjectile(true)
end

-- ==== Think - 结算碰撞并检查超时移除 ====
function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	-- 超时（或已命中触发）后移除
	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

-- ==== Hit - 命中结算：施加减速状态与腿部损伤，播放血肉命中特效 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 只结算一次命中
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	-- 施放者失效时以腐肉球自身为伤害来源
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中可受伤的存活玩家：减速 5 秒 + 腿部损伤 2 点
	if eHitEntity:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", eHitEntity, owner) then
		eHitEntity:GiveStatus("slow", 5)
		eHitEntity:AddLegDamage(2)
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_flesh", effectdata)
end

-- ==== PhysicsCollide - 碰撞处理：栅栏命中时弹开，否则记录碰撞待结算 ====
function ENT:PhysicsCollide(data, phys)
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end
