-- ============================================================================
-- status_fastshoot/cl_init.lua - 急速射击状态（客户端）
-- 负责：在拥有者头顶周期性生成橙红色光带粒子，标记急速射击生效中
-- ============================================================================
INC_CLIENT()

-- 粒子生成的节流时间戳
ENT.NextEmit = 0

-- ==== Draw - 全局绘制钩子：在拥有者头顶喷出光带粒子 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者无效，或本地玩家（未开启第三人称）时不绘制
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	-- 僵尸职业标记为忽略辅助标记时不显示
	if owner:GetZombieClassTable().IgnoreTargetAssist then return end

	-- 重生保护期间不显示
	if owner.SpawnProtection then return end

	-- 限制粒子生成频率为每 0.5 秒一次
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.5

	-- 粒子起点：拥有者身体中心上方 24 单位
	local pos = owner:WorldSpaceCenter()
	pos.z = pos.z + 24

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 喷出 3 根橙红色拉长光带（尾部拉长呈彗尾状）
	for i = 1, 3 do
		particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 6)
		particle:SetDieTime(math.Rand(0.8,1))
		particle:SetStartAlpha(160)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(0)
		particle:SetGravity(Vector(0, 0, 10))
		particle:SetAirResistance(300)
		-- 粒子长度从 1 拉伸到 35，形成光带效果
		particle:SetStartLength(1)
		particle:SetEndLength(35)
		particle:SetColor(255, 60, 0)
	end

	-- 结束发射器并释放内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
