-- ============================================================================
-- status_patientzero - 患者零号状态实体（客户端）
-- 负责：在持有者身上持续向上飘散暗绿色光点粒子，标识其特殊状态
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（限频用）
ENT.NextEmit = 0

-- ==== Draw - 每隔 0.25 秒在持有者身上发射一簇暗绿色上升光点 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 持有者无效，或为本地玩家且不绘制自身模型时跳过
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	-- 该僵尸类设置忽略目标辅助标记时跳过
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	-- 持有者处于出生保护期时不绘制
	if owner.SpawnProtection then return end
	local pos = owner:WorldSpaceCenter()

	-- 粒子发射限频：0.25 秒一次
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.25

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 粒子主方向：随机水平偏移并向上倾斜
	local dir = (VectorRand() * 20 + Vector(0, 0, 40)):GetNormal()

	-- 生成 10 颗暗绿色光点：向上飘散、尺寸渐大、透明度渐隐、可碰撞弹跳
	for i = 1, 10 do
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
		particle:SetColor(30, 60, 30)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
