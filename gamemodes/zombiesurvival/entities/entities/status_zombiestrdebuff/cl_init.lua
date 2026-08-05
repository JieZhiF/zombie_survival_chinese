-- ============================================================================
-- status_zombiestrdebuff/cl_init.lua - 僵尸力量削弱状态（客户端）
-- 负责：削弱视觉特效——每 0.25 秒从拥有者头顶冒出一缕红色光粒，
--       直观标示被削弱的僵尸
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流时间戳（限频控制）
ENT.NextEmit = 0

-- ==== Draw - 削弱粒子特效：定期从拥有者头顶冒出红色光粒 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者无效，或是本地玩家第一人称看不到自己模型时跳过
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	-- 声明了 IgnoreTargetAssist 的僵尸职业不显示特效
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	-- 出生保护期间不显示特效
	if owner.SpawnProtection then return end

	-- 按 0.25 秒间隔限频生成粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.25

	-- 粒子出生点：拥有者包围盒中心上方
	local pos = owner:WorldSpaceCenter()
	pos.z = pos.z + 24

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 每次生成 6 缕红色光粒，缓慢上升拉长后消散
	for i = 1, 6 do
		particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 12)
		particle:SetDieTime(math.Rand(1.1, 1.2))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(0)
		particle:SetGravity(Vector(0, 0, -155))
		particle:SetAirResistance(300)
		particle:SetStartLength(1)
		particle:SetEndLength(35)
		particle:SetColor(255, 30, 30)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
