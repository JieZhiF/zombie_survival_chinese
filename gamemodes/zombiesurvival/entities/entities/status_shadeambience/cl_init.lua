-- ============================================================================
-- status_shadeambience/cl_init.lua - 幽影环境状态（客户端）
-- 负责：为幽影状态拥有者持续播放尖叫环境音效；拥有者最近受到
--       高额伤害时，从身体内喷出亮黄色能量粒子
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流时间戳
ENT.NextEmit = 0

-- ==== Initialize - 初始化：播放尖叫音并在拥有者身上登记本状态 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "ambient/levels/citadel/citadel_ambient_scream_loop1.wav")
	self.AmbientSound:PlayEx(1, 88)

	-- 在拥有者身上登记引用，供其他系统查询幽影状态
	self:GetOwner().status_shadeambience = self
end

-- ==== OnRemove - 移除时停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Draw - 受击后 1 秒内按伤害强度发射黄色能量粒子 ====
function ENT:Draw()
	if CurTime() < self.NextEmit then return end

	-- 距上次受击不足 1 秒时，按伤害量决定粒子强度与发射频率
	local delta = CurTime() - self:GetLastDamaged()
	if delta < 1 then
		local power = (1 - delta) * math.min(1, self:GetLastDamage() / 12)
		self.NextEmit = CurTime() + 0.02 + (1 - power) * 0.3

		local owner = self:GetOwner()
		if owner:IsValid() then
			-- 发射点：拥有者身体中心附近随机偏移
			local radius = owner:BoundingRadius() / 2

			local pos = owner:LocalToWorld(owner:OBBCenter()) + VectorRand():GetNormalized() * math.Rand(-radius, radius)

			local emitter = ParticleEmitter(pos)
			emitter:SetNearClip(24, 32)

			-- 配置粒子：短寿命光点，尺寸随伤害强度放大，亮黄色渐隐
			local particle = emitter:Add("sprites/glow04_noz", pos)
			particle:SetDieTime(math.Rand(0.2, 0.4))
			particle:SetStartSize(1)
			particle:SetEndSize(power * 16)
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetColor(255, 255, 190)

			-- 释放发射器并主动触发一步 GC
			emitter:Finish() emitter = nil collectgarbage("step", 64)
		end
	end
end
