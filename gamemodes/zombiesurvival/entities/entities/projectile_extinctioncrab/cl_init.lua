-- ============================================================================
-- projectile_extinctioncrab/cl_init.lua - 灭绝蟹投射物（客户端）
-- 负责：黄色血肉材质外观、蒸汽环境音；飞行时喷出橙色烟雾粒子尾迹
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流时间戳（每 0.1 秒一批）
ENT.NextEmit = 0

-- ==== Initialize - 客户端初始化：设定材质颜色与循环环境音 ====
function ENT:Initialize()
	-- 整体染成亮黄色，使用血肉材质
	self:SetColor(Color(255, 255, 0, 255))
	self:SetMaterial("models/flesh")

	-- 创建蒸汽循环环境音，并记录生成时刻（用于音调渐降）
	self.AmbientSound = CreateSound(self, "ambient/gas/steam_loop1.wav")
	self.Created = CurTime()
end

-- ==== Think - 每帧维持环境音，音调随存在时间从 90 渐降至 70 ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.75, 90 - math.min(2, CurTime() - self.Created) * 20)

	self:NextThink(CurTime())
	return true
end

-- ==== OnRemove - 移除时停止循环环境音 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Draw - 绘制本体并每 0.1 秒喷出一颗橙色烟雾粒子 ====
function ENT:Draw()
	self:DrawModel()

	-- 粒子发射节流：0.1 秒内只生成一颗
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.1

	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 烟雾粒子：1 秒内渐隐消失，沿速度反方向（尾迹）加随机偏移喷出
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
	particle:SetColor(255, 105, 0)

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
