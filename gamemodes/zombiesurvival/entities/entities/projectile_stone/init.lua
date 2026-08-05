-- ============================================================================
-- init.lua - 投掷石块投射物（服务端）：飞行、命中伤害与碎裂
-- 负责：物理模拟石块飞行，命中玩家造成钝击伤害，撞击或玩家接触后碎裂消失
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化石块：物理属性与 30 秒生存时限 ====
function ENT:Initialize()
	-- 生存截止时间（30 秒后自动移除，防止遗留）
	self.DieTime = CurTime() + 30

	self:SetModel("models/props_junk/rock001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 启用触发器以接收 StartTouch 触碰回调
	self:SetTrigger(true)
	-- 使用通用投射物初始化（true 表示无重力平抛）
	self:SetupGenericProjectile(true)
end

-- ==== Think - 每帧处理：执行延迟的物理碰撞爆炸并清理过期石块 ====
function ENT:Think()
	-- 物理碰撞后执行碎裂逻辑（延迟到 Think 处理，避免碰撞回调中改动实体）
	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	-- 超过生存时限后移除
	if self.DieTime <= CurTime() then
		self:Remove()
	end
end

-- ==== PhysicsCollide - 物理碰撞回调：碰撞速度足够快时才碎裂 ====
function ENT:PhysicsCollide(data, phys)
	-- 仅当碰撞速度 >= 50 时才判定为硬撞击（轻触不碎裂）
	if data.Speed >= 50 then
		self.PhysicsData = data
		self:NextThink(CurTime())
	end
end

-- ==== StartTouch - 触碰玩家：对非友方存活玩家造成伤害 ====
function ENT:StartTouch(ent)
	-- DieTime == 0 表示已碎裂，不再造成伤害
	if self.DieTime ~= 0 and ent:IsValidLivingPlayer() then
		local owner = self:GetOwner()
		if not owner:IsValid() then owner = self end

		-- 目标非投掷者本人且阵营不同（人类玩家，因石块穿过人类）时结算伤害
		if ent ~= owner and ent:Team() ~= self.Team then
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav")
			ent:TakeSpecialDamage(self.Damage, DMG_CLUB, owner, self, nil)
			self:Explode()
		end
	end
end

-- ==== Explode - 碎裂：播放击碎特效并结束实体生命周期（仅一次） ====
function ENT:Explode(hitpos, hitnormal)
	if self.DieTime == 0 then return end
	-- 标记为已碎裂（0 表示失效）
	self.DieTime = 0

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or (self:GetVelocity():GetNormalized() * -1)

	-- 在碎裂点播放石块击碎特效
	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("hit_stone", effectdata)

	self:NextThink(CurTime())
end
