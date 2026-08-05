-- ============================================================================
-- projectile_zsmolotov/cl_init.lua - 燃烧瓶投射物（客户端）
-- 负责：飞行途中每 0.02 秒在弹体位置生成火焰与黑烟粒子，模拟燃烧瓶燃烧外观
-- ============================================================================
INC_CLIENT()

-- 下次烟雾生成时间（节流用）
ENT.SmokeTimer = 0

-- ==== Think - 火焰特效：按节流间隔生成火焰与黑烟粒子 ====
function ENT:Think()
	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(24, 32)

	-- 每 0.02 秒生成一组粒子
	if self.SmokeTimer < CurTime() then
		self.SmokeTimer = CurTime() + 0.02

		local vOffset = self:GetPos()

		-- 火焰粒子：随机选一种火焰材质，短暂燃烧后缩小
		local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset)
		particle:SetDieTime(0.5)
		particle:SetStartSize(math.Rand(4, 7))
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5,5))

		-- 黑烟粒子：缓慢膨胀扩散并渐隐
		particle = emitter:Add("particle/smokestack", vOffset)
		particle:SetDieTime(0.7)
		particle:SetStartAlpha(225)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(16,18))
		particle:SetColor(30, 30, 30)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
