-- ============================================================================
-- status_fastreload/cl_init.lua - 快速装填状态（客户端）
-- 负责：每 0.5 秒在拥有者头顶上方生成上飘的橙色光点粒子，标识增益生效中
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（节流用）
ENT.NextEmit = 0

-- ==== Draw - 增益特效：按节流间隔在头顶生成橙色光点 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者失效或本地玩家视角下不显示自己时跳过
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	-- 僵尸类禁用目标辅助提示时跳过
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	-- 出生保护期间不显示
	if owner.SpawnProtection then return end

	-- 每 0.5 秒发射一次，避免每帧生成粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.5

	-- 以头顶上方为发射原点
	local pos = owner:WorldSpaceCenter()
	pos.z = pos.z + 24

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 三粒向上飘散并拉长的橙色光点
	for i = 1, 3 do
		particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 6)
		particle:SetDieTime(math.Rand(0.8,1))
		particle:SetStartAlpha(160)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(0)
		particle:SetGravity(Vector(0, 0, 10))
		particle:SetAirResistance(300)
		particle:SetStartLength(1)
		particle:SetEndLength(35)
		particle:SetColor(220, 100, 30)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
