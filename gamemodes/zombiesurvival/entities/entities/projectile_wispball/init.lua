-- ============================================================================
-- init.lua - 幽光球投射物（服务端）：飞行、碰撞与能量爆炸
-- 负责：生成漂浮球体投射物，命中时造成溶解伤害爆炸，1.75 秒后自动消失
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化投射物：模型、物理与自毁计时 ====
function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	-- 使用通用的投射物初始化（设置飞行速度、重力与碰撞）
	self:SetupGenericProjectile(false)

	-- 播放能量飞行音效，音高随机（125~135）
	self:EmitSound("weapons/physcannon/energy_sing_flyby2.wav", 70, math.random(125, 135))

	-- 1.75 秒后自动销毁（防止无限飞行）
	self:Fire("kill", "", 1.75)
end

-- ==== Think - 每帧处理：处理物理碰撞结果并清理已爆炸的球体 ====
function ENT:Think()
	-- 物理碰撞后执行命中逻辑（延迟到 Think 以避免在碰撞回调中改动实体）
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.Exploded then
		self:Remove()
	end
end

-- ==== OnRemove - 移除时兜底触发命中（防止未命中即消失） ====
function ENT:OnRemove()
	self:Hit(self:GetPos(), Vector(0, 0, 1), NULL)
end

-- ==== Hit - 命中处理：造成爆炸伤害并播放特效（仅执行一次） ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	if self.Exploded then return end
	self.Exploded = true

	-- 投射物失去所有者时以自身作为伤害来源
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 在命中点施加 32 半径、4 点伤害的溶解类爆炸（对僵尸使用）
	util.BlastDamagePlayer(self, owner, vHitPos + vHitNormal, 32, 4, DMG_DISSOLVE)

	-- 播放幽光球爆炸特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("explosion_wispball", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞回调：穿过围栏则忽略，否则记录为命中 ====
function ENT:PhysicsCollide(data, phys)
	-- 围栏类薄物体不触发命中（HitFence 返回真），其余碰撞记录待 Think 处理
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end
