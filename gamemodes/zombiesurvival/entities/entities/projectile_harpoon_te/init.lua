-- ============================================================================
-- projectile_harpoon_te/init.lua - 鱼叉枪投射物实体（服务器端）
-- 负责：鱼叉飞行减速、命中僵尸后钉入持续流血、拉拽者回收武器
-- ============================================================================

INC_SERVER()

-- 缓存零向量（性能优化：避免每帧创建新表）
local vector_origin = vector_origin

-- 下一次流血伤害的冷却时间戳
ENT.NextDamage = 0
-- 剩余流血次数（钉入后共 50 次，每次约 0.35 秒）
ENT.TicksLeft = 50

-- ==== Initialize - 初始化 ====
-- 设置鱼叉模型与通用投射物属性，播放投掷音效并安排自毁
function ENT:Initialize()
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetupGenericProjectile(false)

	-- 低音调挥击音效（模拟鱼叉投出）
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(35, 45))

	-- 30 秒后强制销毁（保险）；3 秒后进入钉入判定阶段
	self:Fire("kill", "", 30)
	self.DieTime = CurTime() + 3
	self.LastPhysicsUpdate = UnPredictedCurTime()
end

-- ==== PhysicsUpdate - 物理更新 ====
-- 对鱼叉施加持续反向速度，使其飞行中逐渐减速停止
function ENT:PhysicsUpdate(phys)
	-- 记录初始飞行速度
	if not self.InitVelocity then self.InitVelocity = self:GetVelocity() end

	-- 每帧按经过时间施加与初始速度相反的加速度
	local dt = (UnPredictedCurTime() - self.LastPhysicsUpdate)
	self.LastPhysicsUpdate = UnPredictedCurTime()

	phys:AddVelocity(self.InitVelocity * dt * -0.6)
end

-- ==== OnRemove - 移除时 ====
-- 移除时给拉拽者补发鱼叉枪，并在命中处播放骨片破碎特效
function ENT:OnRemove()
	local owner = self:GetOwner()
	-- 拉拽者仍为存活人类时归还鱼叉枪（允许再次拉拽）
	if owner:IsValidLivingHuman() then
		owner:Give(self.BaseWeapon)
	end

	-- 播放骨片破碎粒子效果
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("explosion_bonemesh", effectdata)
end

-- ==== Think - 每帧逻辑 ====
-- 处理延迟碰撞命中、钉入僵尸后的持续流血、碰撞组切换与超时移除
function ENT:Think()
	-- 有缓存的物理碰撞数据时补发命中事件
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.OurOldVelocity, self.PhysicsData.HitEntity)
	end

	-- 已钉入玩家时每 0.35 秒造成一次流血伤害
	local parent = self:GetParent()
	if parent:IsValid() and parent:IsPlayer() then
		if parent:IsValidLivingZombie() and not parent.SpawnProtection then
			if CurTime() >= self.NextDamage then
				self.NextDamage = CurTime() + 0.35

				-- 生成血迹并造成初始伤害 22.2% 的持续流血
				util.Blood((parent:NearestPoint(self:GetPos()) + parent:WorldSpaceCenter()) / 2, math.random(4, 9), Vector(0, 0, 1), 100)
				parent:TakeSpecialDamage((self.ProjDamage or 35) * 0.222, DMG_SLASH, self:GetOwner(), self)
			end
		else
			-- 目标不再是可流血的僵尸：移除鱼叉
			self:Remove()
		end
	end

	-- 爆炸/命中后将碰撞组切为世界（防止残留碰撞影响）
	if self.Exploded and not self.ColChange then
		self.ColChange = true
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end

	-- 超时后移除
	if self.DieTime < CurTime() then
		self:Remove()
	end

	-- 每帧持续触发 Think
	self:NextThink(CurTime())
	return true
end

-- ==== Hit - 命中处理 ====
-- 命中玩家时造成腿部伤害并钉入目标；命中场景仅记录碰撞
function ENT:Hit(vHitPos, vHitNormal, vel, hitent)
	if self.Exploded then return end

	local owner = self:GetOwner()
	-- 所有者失效时把伤害归属设为自身
	if not owner:IsValid() then owner = self end

	if hitent and hitent:IsValid() and hitent:IsPlayer() then
		-- 增加腿部伤害（打断僵尸腿部，减速）
		hitent:AddLegDamage(30)

		self.Exploded = true

		-- 造成初始穿透伤害并播放刺入音效
		hitent:TakeSpecialDamage(self.ProjDamage or 35, DMG_GENERIC, owner, self, self:GetPos())
		hitent:EmitSound("npc/strider/strider_skewer1.wav", 70, 112)

		-- 延长存活时间，钉入目标并停止自身运动
		self.DieTime = CurTime() + 7

		self:GetPhysicsObject():SetVelocityInstantaneous(vector_origin)
		self:SetParent(hitent)
	end
end

-- ==== PhysicsCollide - 物理碰撞回调 ====
-- 缓存碰撞数据并在下一帧统一处理（避免碰撞回调中直接修改物理）
function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
