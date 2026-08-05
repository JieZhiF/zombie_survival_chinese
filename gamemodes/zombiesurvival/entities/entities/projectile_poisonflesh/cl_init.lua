-- ============================================================================
-- projectile_poisonflesh - 毒肉投射物实体（客户端）
-- 负责：以血肉贴图精灵绘制投射物，并持续发射飘散的血液粒子
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（用于限制发射频率）
ENT.NextEmit = 0

-- ==== Initialize - 初始化并随机生成投射物的显示大小 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.Size = math.Rand(10, 14)
end

-- 血肉精灵的绘制颜色（白色即原样显示贴图）
local colFlesh = Color(255, 255, 255, 255)
-- 血肉溅射贴图材质
local matFlesh = Material("decals/Yblood1")
-- ==== Draw - 绘制血肉精灵，并每隔 0.05 秒发射一次血液粒子 ====
function ENT:Draw()
	local size = self.Size

	render.SetMaterial(matFlesh)
	local pos = self:GetPos()
	render.DrawSprite(pos, size, size, colFlesh)

	-- 粒子发射限频：不足 0.05 秒则跳过
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.05

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(36, 44)

	-- 生成血液粒子：随机偏移位置、缓慢飘散、保持不透明、尺寸渐小
	local particle = emitter:Add("decals/Yblood"..math.random(6), pos + VectorRand():GetNormalized() * math.Rand(1, 4))
	particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(1, 4))
	particle:SetDieTime(math.Rand(0.6, 0.9))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(size * math.Rand(0.1, 0.22))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-4, 4))
	particle:SetLighting(true)

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
