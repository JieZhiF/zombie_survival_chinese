-- ============================================================================
-- projectile_flashbomb/init.lua - 闪光弹投射物（服务器）
-- 负责：投掷后飞行，移除时爆炸：对视野内的僵尸与投掷者本人造成
--       致盲（屏幕闪烁/DSP 失真/迷向状态）与腿部伤害；对僵尸附带 1 点伤害
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化：闪光弹模型与物理 ====
function ENT:Initialize()
	self:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	-- 投射物碰撞组：忽略投掷者碰撞
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(1)
		phys:SetMaterial("metal")
	end

	-- 记录寿命结束时间并安排到期 Think
	self.DieTime = CurTime() + self.LifeTime
	self:NextThink(self.DieTime)
end

-- ==== PhysicsCollide - 高速撞击时播放碰撞音效 ====
function ENT:PhysicsCollide(data, phys)
	-- 撞击速度足够大且非连续接触时才播放
	if 20 < data.Speed and 0.25 < data.DeltaTime then
		self:EmitSound("weapons/flashbang/grenade_hit1.wav")
	end
end

-- ==== Think - 寿命结束自动移除（触发爆炸）====
function ENT:Think()
	if CurTime() >= self.DieTime then
		self:Remove()
	end
end

-- ==== OnRemove - 移除瞬间引爆 ====
function ENT:OnRemove()
	self:Explode()
end

-- ==== Explode - 引爆：对视线内的僵尸与投掷者造成致盲与伤害 ====
function ENT:Explode()
	-- 只爆炸一次
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	local pos = self:GetPos()

	-- 遍历爆炸半径内的玩家（僵尸或投掷者本人）
	for _, ent in pairs(ents.FindInSphere(pos, self.Radius)) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() and (ent:Team() == TEAM_UNDEAD or ent == owner) then
			local eyepos = ent:EyePos()
			-- 需视线直达才受影响
			if TrueVisibleFiltered(pos, eyepos, self, ent) then
				-- 致盲强度：距离越近、越正对闪光越强
				local eyevec = ent:GetAimVector()
				local strength = (1 - eyepos:Distance(pos) / self.Radius) ^ 0.5 * (0.3 + math.Clamp((pos - eyepos):GetNormalized():Dot(eyevec), 0, 1) * 0.7)

				-- 施加腿部伤害、屏幕白闪与 DSP 失真
				ent:AddLegDamage(strength)
				local time = (0.5 + strength * 1.5) * (ent.VisionAlterDurationMul or 1)
				ent:ScreenFade(SCREENFADE.IN, nil, time, time)
				ent:SetDSP(36)
				-- 强致盲时附加迷向状态
				if strength > 0.4 then ent:GiveStatus("disorientation", time * 2) end

				-- 僵尸额外受到 1 点伤害
				if ent:Team() == TEAM_UNDEAD then
					ent:TakeDamage(1, owner, self)
				end
			end
		end
	end

	-- 爆炸音效与特效
	self:EmitSound("weapons/flashbang/flashbang_explode2.wav")

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("HelicopterMegaBomb", effectdata)
end
