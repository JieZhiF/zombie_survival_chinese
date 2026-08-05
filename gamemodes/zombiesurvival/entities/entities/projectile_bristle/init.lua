-- ============================================================================
-- projectile_bristle/init.lua - 荆棘投射物（服务器端）
-- 负责：荆棘刺的飞行物理（持续下坠）、碰撞判定与命中效果：
--       命中人类造成流血（可致盲）、命中其他实体造成伤害，
--       0.45 秒后自动销毁，移除时播放命中特效
-- ============================================================================

-- 服务器端加载入口（INC_SERVER 系列约定写法）
INC_SERVER()

-- ==== Initialize - 投射物初始化 ====
function ENT:Initialize()
	-- 设置荆棘刺模型并缩小
	self:SetModel("models/props_wasteland/dockplank_chunk01d.mdl")
	self:SetModelScale(0.3)
	-- 球形物理碰撞体
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	-- 绿色着色（客户端会覆盖为橙色）
	self:SetColor(Color(0, 255, 0, 255))
	-- 按通用投射物规范初始化（重力、速度、碰撞）
	self:SetupGenericProjectile(false)

	-- 0.45 秒后自动销毁（飞行寿命上限）
	self:Fire("kill", "", 0.45)
	self.LastPhysicsUpdate = UnPredictedCurTime()
end

-- 复用的下坠速度向量（避免每帧分配）
local vecDown = Vector()
-- ==== PhysicsUpdate - 物理帧更新 ====
-- 对投射物持续施加向下速度，模拟荆棘刺的抛物线下坠
function ENT:PhysicsUpdate(phys)
	local dt = (UnPredictedCurTime() - self.LastPhysicsUpdate)
	self.LastPhysicsUpdate = UnPredictedCurTime()

	vecDown.z = dt * -75
	phys:AddVelocity(vecDown)
end

-- ==== Think - 每帧处理延迟碰撞 ====
function ENT:Think()
	-- 物理碰撞数据在下一帧处理（由 PhysicsCollide 写入）
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	-- 命中结算完成后移除实体
	if self.Exploded then
		self:Remove()
	end
end

-- ==== Hit - 命中结算 ====
-- 人类：3 点伤害 + 流血状态（8 点总伤害，归属射手）；
--       命中眼睛附近额外致盲（暗视 5 秒）；其他实体：11 点伤害
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 只结算一次
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	if eHitEntity:IsValid() then
		if eHitEntity:IsPlayer() then
			-- 命中玩家：基础伤害
			eHitEntity:TakeDamage(3, owner, self)

			-- 施加流血状态，叠加 8 点流血伤害，伤害归属射手
			local bleed = eHitEntity:GiveStatus("bleed")
			if bleed and bleed:IsValid() then
				bleed:AddDamage(8)
				bleed.Damager = self:GetOwner()
			end
			-- 命中人类且击中眼部附近（距第一个附着点 18 单位内）时致盲
			if eHitEntity:Team() == TEAM_HUMAN then
				local attach = eHitEntity:GetAttachment(1)
				if attach and vHitPos:DistToSqr(attach.Pos) <= 324 then
					eHitEntity:PlayEyePainSound()
					local status = eHitEntity:GiveStatus("dimvision", 5)
					if status then
						status.EyeEffect = true
					end
				end
			end
		else
			-- 命中非玩家实体：更高伤害
			eHitEntity:TakeDamage(11, owner, self)
		end
	end
end

-- ==== OnRemove - 移除时播放命中特效 ====
function ENT:OnRemove()
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetNormal(self:GetVelocity():GetNormalized())
	util.Effect("hit_barb", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞回调 ====
-- 若未命中栅栏类物体（穿透），则记录碰撞数据交给下一帧的 Think 结算
function ENT:PhysicsCollide(data, phys)
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end
