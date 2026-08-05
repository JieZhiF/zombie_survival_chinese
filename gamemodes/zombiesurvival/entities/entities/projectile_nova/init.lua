-- ============================================================================
-- projectile_nova/init.lua - 新星投射物（服务器端）
-- 负责：能量球的飞行物理（分支弹左右摆动、撞墙可弹跳一次）、
--       命中结算（77 点伤害 + 腿部减速，击杀得分 1.25 倍），
--       3 秒飞行寿命后自动销毁
-- ============================================================================

-- 服务器端加载入口（INC_SERVER 系列约定写法）
INC_SERVER()

-- 击杀得分倍率（使用本投射物击杀时得分 ×1.25）
ENT.PointsMultiplier = 1.25

-- ==== Initialize - 投射物初始化 ====
function ENT:Initialize()
	-- 已弹跳次数（初始为 0）
	self.Bounces = 0

	-- 悬浮球模型作为能量球外观
	self:SetModel("models/dav0r/hoverball.mdl")
	self:PhysicsInitSphere(2)
	self:SetSolid(SOLID_VPHYSICS)
	-- 分支弹更小（0.15），主弹 0.25
	self:SetModelScale(self.Branch and 0.15 or 0.25, 0)
	-- 按通用投射物规范初始化（重力、速度、碰撞）
	self:SetupGenericProjectile(false)

	-- 3 秒后自动销毁（飞行寿命上限）
	self:Fire("kill", "", 3)
	self.Creation = UnPredictedCurTime()
end

-- ==== PhysicsUpdate - 物理帧更新 ====
-- 主弹仅做提前碰撞检测；分支弹额外叠加左右摆动的正弦偏移，
-- 偏移幅度随时间增长，方向由射击标记（ShotMarker）决定
function ENT:PhysicsUpdate(phys)
	self:ProjectileTraceAhead(phys)

	if not self.Branch then return end

	local livetime = UnPredictedCurTime() - self.Creation
	local vel = phys:GetVelocity()
	local physang = vel:Angle()
	local vr = physang:Right() * math.cos(CurTime() * 5) * (1 + livetime) * 3 * (self.ShotMarker == 0 and 1 or -1)

	local newvel = vel + vr

	phys:SetVelocityInstantaneous(newvel)
end

-- ==== PhysicsCollide - 物理碰撞回调 ====
-- 撞到世界表面时最多反弹一次（以 700 速度反向弹回并播放音效），
-- 其余碰撞记录为命中数据，交给下一帧的 Think 结算
function ENT:PhysicsCollide(data, phys)
	-- 已有命中数据则不再处理
	if self.HitData then return end

	if self.Bounces <= 1 and data.HitEntity and data.HitEntity:IsWorld() then
		-- 沿表面法线反射速度
		local normal = data.OurOldVelocity:GetNormalized()
		phys:SetVelocityInstantaneous((2 * data.HitNormal * data.HitNormal:Dot(normal * -1) + normal) * 700)

		self:EmitSound("ambient/levels/citadel/weapon_disintegrate3.wav", 70, 210)

		self.Bounces = self.Bounces + 1
	else
		self.HitData = data
	end

	self:NextThink(CurTime())
end

-- ==== Think - 命中结算 ====
function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	-- 已触发命中且未造成伤害时执行伤害结算
	if self.Touched and not self.Damaged then
		self.Damaged = true

		local tr = self.Touched

		-- 命中期间启用 1.25 倍击杀得分
		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end
		-- 对命中目标造成 77 点伤害（可被 ProjDamage 覆盖）
		self:DealProjectileTraceDamage(self.ProjDamage or 77, tr, owner)
		-- 命中玩家时额外附加腿部减速（脉冲型减速）
		if tr.Entity:IsPlayer() then
			tr.Entity:AddLegDamageExt(5.5, owner, source, SLOWTYPE_PULSE)
		end
		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		-- 播放命中喷血特效
		util.Blood(tr.Entity:WorldSpaceCenter(), math.max(0, 15), -self:GetForward(), math.Rand(100, 300), true)

		self:Remove()
	-- 撞墙（非命中目标）后直接移除
	elseif self.HitData then
		self:Remove()
	end
end
