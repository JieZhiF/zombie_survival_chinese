-- ============================================================================
-- cl_init.lua - 损坏道具特效实体（客户端）
-- 负责：以受损外观半透明绘制道具，并持续喷出绿色烟雾模拟腐败/酸蚀效果
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流计时
ENT.NextEmit = 0

-- ==== Initialize - 初始化客户端表现 ====
-- 关闭阴影、放大模型，并随机生成 5 个粒子发射点
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(1.03, 0)

	-- 粒子发射点表（相对自身坐标）
	self.ParticlePositions = {}

	self:RandomizePositions()
end

-- ==== RandomizePositions - 随机化粒子发射点 ====
-- 在模型包围盒（收缩 75%）内随机取 5 个局部坐标作为烟雾发射点
function ENT:RandomizePositions()
	for i=1, 5 do
		local mins, maxs = self:OBBMins(), self:OBBMaxs()
		mins = mins * 0.75
		maxs = maxs * 0.75
		self.ParticlePositions[i] = Vector(math.Rand(-mins.x, maxs.x), math.Rand(-mins.y, maxs.y), math.Rand(-mins.z, maxs.z))
	end
end

-- 受损材质覆盖（混凝土碎块贴图）
local matDamage = Material("Models/props_debris/concretefloor013a")
-- ==== Draw - 绘制受损模型与烟雾粒子 ====
-- 以受损材质半透明绘制并让颜色随正弦波动（模拟腐烂闪动）；同时持续喷出绿色烟雾
function ENT:Draw()
	-- 饱和度随时间正弦波动，造成腐烂闪烁的视觉效果
	local sat = 1 - math.abs(math.sin(CurTime() * 3)) * 0.6

	-- 覆盖受损材质、半透明绘制模型后恢复原状
	render.ModelMaterialOverride(matDamage)
	render.SetBlend(0.35)
	render.SetColorModulation(1, sat, sat)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
	render.ModelMaterialOverride(0)

	-- 粒子节流：每 0.02 秒发射一轮
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.02

	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(16, 24)
	-- 从每个随机点发射向上飘的绿色烟雾粒子
	for _, pos in pairs(self.ParticlePositions) do
		local particle = emitter:Add("effects/fire_cloud"..math.random(2), self:LocalToWorld(pos))
		particle:SetDieTime(math.Rand(0.3, 0.4))
		particle:SetGravity(Vector(math.random(-1, 1), math.random(-1, 1), math.random(3, 8)):GetNormal() * 300)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(1)
		particle:SetStartLength(10)
		particle:SetEndLength(18)
		particle:SetColor(0, 255, 0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
