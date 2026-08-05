-- ============================================================================
-- projectile_emi/init.lua - 电磁脉冲投射物（服务器）
-- 负责：EMP 弹的飞行与命中——无重力球形弹体，飞行中持续朝前方发射
--       子弹（等离子拖尾）；命中/爆炸时触发 EMP 爆炸特效并移除
-- ============================================================================
INC_SERVER()

-- 分裂出的子投射物类名（爆炸时生成/供继承使用）
ENT.SubProjectile = "projectile_emi_sub"

-- ==== Initialize - 初始化：模型、无重力物理与自毁计时 ====
function ENT:Initialize()
	-- 悬浮球模型，半径 1 的物理球碰撞体，整体缩小 40%
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(1)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.4)
	-- 按通用投射物规则初始化（false 表示无重力）
	self:SetupGenericProjectile(false)

	-- 飞行音效（随机音调）与 1.3 秒后自动销毁
	self:EmitSound("weapons/physcannon/energy_sing_flyby2.wav", 70, math.random(125, 135))
	self:Fire("kill", "", 1.3)

	-- 下一次拖尾子弹发射时间戳（节流）
	self.NextShoot = 0
end

-- ==== Think - 飞行逻辑：处理碰撞结果并按节流发射拖尾子弹 ====
function ENT:Think()
	-- 物理碰撞后延迟到下一帧处理命中
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	-- 已爆炸则移除自身
	if self.Exploded then
		self:Remove()
	end

	-- 每 0.1 秒向前方发射一发子弹（等离子拖尾），伤害来自 ProjDamage
	if CurTime() > self.NextShoot then
		self.NextShoot = CurTime() + 0.1

		local owner = self:GetOwner()
		-- 拥有者不是有效存活人类时以自身为伤害来源
		if not owner:IsValidLivingHuman() then owner = self end

		self:FireBulletsLua(self:GetPos() + self:GetForward() * 10, self:GetForward(), 5, 1, self.ProjDamage, owner, 0.01, "tracer_pcutter", BulletCallback, nil, nil, nil, nil, self)
	end
end

-- ==== OnRemove - 移除时在当前位置触发一次命中效果 ====
function ENT:OnRemove()
	self:Hit(self:GetPos(), Vector(0, 0, 1), NULL)
end

-- ==== Hit - 命中结算：触发一次 EMP 爆炸特效（只触发一次） ====
function ENT:Hit(vHitPos, vHitNormal, eHitEntity)
	-- 已爆炸则不再重复触发
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 命中位置/法线缺失时以自身位置兜底
	vHitPos = vHitPos or self:GetPos()
	vHitNormal = vHitNormal or Vector(0, 0, 1)

	-- 在命中点生成 EMP 爆炸特效
	local effectdata = EffectData()
		effectdata:SetOrigin(vHitPos)
		effectdata:SetNormal(vHitNormal)
	util.Effect("explosion_emi", effectdata)
end

-- ==== PhysicsCollide - 物理碰撞：栅栏直接穿过，其余记录命中数据 ====
function ENT:PhysicsCollide(data, phys)
	-- 命中栅栏时穿过（HitFence 返回 true），否则记录碰撞数据待 Think 处理
	if not self:HitFence(data, phys) then
		self.PhysicsData = data
	end

	self:NextThink(CurTime())
end
