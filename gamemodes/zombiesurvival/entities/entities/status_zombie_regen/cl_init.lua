-- ============================================================================
-- status_zombie_regen - 僵尸再生状态实体（客户端）
-- 负责：在再生中的僵尸身上周期喷发红色反弹粒子，直观标示治疗效果
-- ============================================================================
INC_CLIENT()

-- 粒子发射限频时间戳
ENT.NextEmit = 0

-- ==== Draw - 每 0.25 秒在僵尸中心向上喷发 6 个红色反弹粒子；自身/免疫目标/出生保护期间不绘制 ====
function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	if owner.SpawnProtection then return end
	local pos = owner:WorldSpaceCenter()

	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.25

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 生成向上偏移的随机发射方向（回血粒子整体向上飘散）
	local dir = (VectorRand() * 20 + Vector(0, 0, 40)):GetNormal()

	for i = 1, 6 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity(dir * 120)
		particle:SetDieTime(math.Rand(1.1, 1.4))
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(6, 7))
		particle:SetEndSize(12)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetGravity(Vector(0, 0, 25))
		particle:SetCollide(true)
		particle:SetBounce(0.45)
		particle:SetAirResistance(300)
		particle:SetColor(60, 20, 20)
	end

	-- 释放粒子发射器并主动回收一次垃圾内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Initialize - 空实现（状态初始化与绘制钩子注册在共享端完成） ====
function ENT:Initialize()
end
