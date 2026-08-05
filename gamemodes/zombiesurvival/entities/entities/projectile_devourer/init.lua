-- ============================================================================
-- init.lua - 吞噬者投射物（服务器）：减速飞行、命中拖拽与击倒
-- 负责：骨刺命中人类后附加"吞噬者"状态（持续拖拽吸血），命中载具则弹飞
-- ============================================================================
INC_SERVER()

local vector_origin = vector_origin

-- ==== Initialize - 初始化：按无重力投射物生成并设定 1.1 秒生命周期 ====
function ENT:Initialize()
	self:SetModel("models/gibs/HGIBS_rib.mdl")
	self:PhysicsInitSphere(13)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(2.2, 0)
	self:SetupGenericProjectile(false)

	self.DieTime = CurTime() + 1.1
	self.LastPhysicsUpdate = UnPredictedCurTime()
end

-- ==== PhysicsUpdate - 物理更新：对初速度施加反向加速度使骨刺逐渐减速 ====
function ENT:PhysicsUpdate(phys)
	if not self.InitVelocity then self.InitVelocity = self:GetVelocity() end

	-- 按帧间隔累加反向速度，实现飞行中的减速
	local dt = (UnPredictedCurTime() - self.LastPhysicsUpdate)
	self.LastPhysicsUpdate = UnPredictedCurTime()

	phys:AddVelocity(self.InitVelocity * dt * -1.8)
end

-- ==== Think - 每帧检测：处理碰撞结果并检查过期销毁 ====
function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.Exploded then
		-- 已命中目标后转为世界碰撞组，避免后续干扰
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	elseif self.DieTime < CurTime() then
		-- 超时未命中则自动销毁
		self:Remove()
	end
end

-- ==== OnRemove - 移除时：播放骨刺爆炸特效 ====
function ENT:OnRemove()
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("explosion_bonemesh", effectdata)
end

-- ==== Hit - 命中处理：人类被附加吞噬状态拖拽，载具被弹飞 ====
function ENT:Hit(vHitPos, vHitNormal, ent)
	if self.Exploded then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	if ent:IsValid() then
		if (ent.BeingControlled or ent:IsValidLivingHuman()) and owner:IsPlayer() then
			if ent:IsValidLivingHuman() then
				-- 命中人类：造成伤害并击倒，附加吞噬状态持续拖拽（有镇痛挂件则伤害减为 5）
				self.Exploded = true

				ent:TakeSpecialDamage(8, DMG_GENERIC, owner, self)
				ent:KnockDown()

				local status = ent:GiveStatus("devourer")
				if status and status:IsValid() then
					status:SetDamage(ent:HasTrinket("analgestic") and 5 or 15)
					status:SetPuller(owner)
					-- 骨刺挂到状态实体上，跟随被拖拽者移动
					self:SetParent(status)
				end

				-- 命中后停止骨刺自身运动
				self:GetPhysicsObject():SetVelocityInstantaneous(vector_origin)
			else
				-- 命中被控制的载具：沿射击者视线反向弹飞
				local vel = owner:GetAimVector() * -2000
				ent:GetPhysicsObject():SetVelocity(vel)
			end
		end
	end
end

-- ==== PhysicsCollide - 物理碰撞：记录碰撞数据并调度 Hit 处理 ====
function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
