-- ============================================================================
-- projectile_corgasgrenade/init.lua - 腐蚀毒气手雷（服务器）
-- 负责：手雷碰撞后持续排放毒气云（每 0.6 秒一跳，共 19 跳），
--       对范围内的僵尸与投掷者造成腐蚀伤害；手雷物理轻盈、易滚动
-- ============================================================================
INC_SERVER()

-- 毒气伤害间隔（秒）
ENT.TickTime = 0.6
-- 毒气总跳数
ENT.Ticks = 19
-- 每跳伤害
ENT.Damage = 13

-- ==== Initialize - 生成手雷：轻质物理与投射物碰撞组 ====
function ENT:Initialize()
	self:SetModel("models/props_lab/labpart.mdl")
	self:PhysicsInitSphere(2)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.42, 0)
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		-- 极轻、低浮力、高阻尼（落地后基本不弹跳）、关闭空气阻力
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0.01)
		phys:SetDamping(1.5, 4)
		phys:EnableDrag(false)
		phys:Wake()
	end

	-- 初始未排放毒气
	self:SetGasEmit(false)
end

-- ==== Think - 首次碰撞后启动毒气排放与自毁计时 ====
function ENT:Think()
	if not self.Collided and self.PhysicsData then
		-- 延迟 TickTime 后开始腐蚀，并在全部跳数结束后销毁
		self:Fire("corrode", "", self.TickTime)
		self:Fire("kill", "", self.TickTime * self.Ticks + 0.01)
		-- 通知客户端开始排放毒气特效
		self:SetGasEmit(true)

		self.Collided = true
	end
end

-- ==== PhysicsCollide - 记录碰撞数据并进入 Think 结算 ====
function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

-- ==== AcceptInput - 腐蚀一跳结算：对范围内僵尸/投掷者造成伤害 ====
function ENT:AcceptInput(name, activator, caller, arg)
	-- 只处理 corrode 输入
	if name ~= "corrode" then return end

	self.Ticks = self.Ticks - 1

	local owner = self:GetOwner()
	-- 投掷者失效时以手雷自身为伤害来源
	if not owner:IsValidLivingHuman() then owner = self end

	local vPos = self:GetPos()
	-- 遍历半径内实体：活着的僵尸或投掷者自己，且视线可见时受伤害
	for _, ent in pairs(ents.FindInSphere(vPos, self.Radius)) do
		if ent and (ent:IsValidLivingPlayer() and (ent:Team() == TEAM_UNDEAD or ent == owner)) and WorldVisible(vPos, ent:NearestPoint(vPos)) then
			if owner:IsValidLivingHuman() then
				-- 记录腐蚀时间（供客户端显示）并播放灼烧痛呼
				ent.Corrosion = CurTime()
				ent:EmitSound("player/pl_burnpain" .. math.random(1,3) .. ".wav", 65, math.random(60, 70))
				ent:TakeSpecialDamage(self.Damage, DMG_GENERIC, owner, self)
			end
		end
	end

	-- 还有剩余跳数则继续安排下一次腐蚀
	if self.Ticks > 0 then
		self:Fire("corrode", "", self.TickTime)
	end

	return true
end
