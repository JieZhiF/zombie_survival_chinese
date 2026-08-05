-- ============================================================================
-- projectile_ghoulfleshchilled/init.lua - 冰冻食尸鬼血肉投射物（服务器）
-- 负责：投射物的飞行生命周期：初始化蓝色冰冻外观与球体物理，命中时对
--       玩家施加冰冻状态并播放特效，30 秒后自动销毁
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化投射物外观、物理与生命期 ====
function ENT:Initialize()
	-- 生命期：30 秒后自动销毁
	self.DeathTime = CurTime() + 30

	-- 蓝色冰冻外观（球体模型 + 材质 + 色调）
	self:SetModel("models/props/cs_italy/orange.mdl")
	self:SetMaterial("models/seagull/seagull")
	-- 半径为 1 的球体物理，作为飞行碰撞体
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(0, 125, 255, 255))
	-- 套用通用投射物设定（重力/初速等）
	self:SetupGenericProjectile(true)
end

-- ==== Think - 处理碰撞数据并检查生命期 ====
function ENT:Think()
	-- 物理碰撞数据已就绪时执行命中结算（延迟一帧，等待物理稳定）
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	-- 生命期耗尽时销毁
	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

-- ==== Hit - 命中结算：对玩家施加冰冻状态并播放命中特效 ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 防止重复结算（爆炸标记）
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	-- 命中归属：投射物无有效发射者时以自身为来源
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 兜底填充未传入的命中位置/法线
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 命中存活的玩家且允许造成伤害时：施加 5 秒冰冻状态
	if eHitEntity:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", eHitEntity, owner) then
		eHitEntity:GiveStatus("frost", 5)
	end

	-- 在命中点播放冰冻特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("hit_frost", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞：跳过围栏类碰撞，其余记录并立即结算 ====
function ENT:PhysicsCollide(data, phys)
	-- 命中围栏（可穿透障碍）时不触发命中，避免投射物卡在围栏上
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	-- 立即调度 Think 处理碰撞数据
	self:NextThink(CurTime())
end
