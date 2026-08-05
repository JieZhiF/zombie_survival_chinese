-- ============================================================================
-- status_strengthdartboost/cl_init.lua - 力量针剂强化状态（客户端）
-- 负责：在拥有者周围每 0.5 秒发射一组红色发光粒子，标示力量强化生效中
-- ============================================================================
INC_CLIENT()

-- 下一次粒子发射的时间戳（限制特效频率）
ENT.NextEmit = 0

-- ==== Draw - 渲染强化光环：按间隔在拥有者周围生成红色粒子 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者无效、自己是拥有者且不绘制本地玩家时跳过
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	-- 拥有者僵尸类配置为忽略目标辅助时跳过（避免暴露目标位置）
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	-- 拥有者处于出生保护时跳过
	if owner.SpawnProtection then return end

	-- 按 0.5 秒间隔发射粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.5

	local pos = owner:WorldSpaceCenter()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 生成 2 颗红色发光粒子，在拥有者周围随机偏移并缓慢上飘
	for i = 1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 12)
		particle:SetDieTime(math.Rand(1.1, 1.2))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(0)
		particle:SetGravity(Vector(0, 0, 75))
		particle:SetAirResistance(300)
		particle:SetStartLength(1)
		particle:SetEndLength(35)
		particle:SetColor(255, 30, 30)
	end

	-- 结束粒子发射并立即触发一次垃圾回收以降低粒子开销
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
