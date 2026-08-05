-- ============================================================================
-- projectile_doomcrab - 末日螃蟹（DoomCrab）投掷的投射物实体（客户端）
-- 负责：以绿色血肉材质绘制模型、循环播放蒸汽环境音效，并持续发射飘散的绿色烟雾粒子
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（用于限制发射频率）
ENT.NextEmit = 0

-- ==== Initialize - 设置模型颜色与材质，创建环境音效并记录生成时间 ====
function ENT:Initialize()
	self:SetColor(Color(0, 230, 0, 255))
	self:SetMaterial("models/flesh")

	self.AmbientSound = CreateSound(self, "ambient/gas/steam_loop1.wav")
	self.Created = CurTime()
end

-- ==== Think - 每帧循环播放蒸汽音效，音高随存活时间从 90 逐渐下降 ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.75, 90 - math.min(2, CurTime() - self.Created) * 20)

	self:NextThink(CurTime())
	return true
end

-- ==== OnRemove - 实体移除时停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Draw - 绘制模型，并每隔 0.1 秒发射一次绿色烟雾粒子 ====
function ENT:Draw()
	self:DrawModel()

	-- 粒子发射限频：不足 0.1 秒则跳过
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.1

	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 生成烟雾粒子：沿速度反方向飘散、尺寸渐小、透明度渐隐、随机旋转
	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(math.Rand(0.8, 1))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(15, 20))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetVelocity((self:GetVelocity():GetNormalized() * -1 + VectorRand():GetNormalized()):GetNormalized() * math.Rand(16, 48))
	particle:SetLighting(true)
	particle:SetColor(30, 255, 30)

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
