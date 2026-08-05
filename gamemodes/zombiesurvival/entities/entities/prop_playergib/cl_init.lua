-- ============================================================================
-- prop_playergib - 玩家肢体碎块道具（客户端）
-- 负责：绘制碎块模型，并在其快速移动时持续喷射血液粒子
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（限频用）
ENT.NextEmit = 0

-- ==== Draw - 绘制模型，移动速度足够快时每隔 0.05 秒喷出红色血液粒子 ====
function ENT:Draw()
	self:DrawModel()

	-- 限频且速度平方 ≥ 256（约 16 单位/秒）时才发射血液
	if CurTime() >= self.NextEmit and self:GetVelocity():LengthSqr() >= 256 then
		self.NextEmit = CurTime() + 0.05

		local pos = self:WorldSpaceCenter()

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(16, 24)

		-- 生成血液飞溅粒子：随机方向飘散、保持不透明、尺寸渐小、红色
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(8, 16))
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(230)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetColor(255, 0, 0)
		particle:SetLighting(true)

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end
