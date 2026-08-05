-- ============================================================================
-- cl_init.lua - 火箭投射物（客户端）
-- 负责：绘制火箭尾焰发光点、飞行烟迹、动态灯光，以及副武器爆炸时的焰火特效
-- ============================================================================
INC_CLIENT()

-- 尾焰发光材质
local matGlow = Material("sprites/light_glow02_add")

-- 烟迹发射节流计时
ENT.SmokeTimer = 0

-- ==== Draw - 绘制模型与尾焰 ====
-- 主武器为大型橙色光晕，副武器为小型光晕
function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos()
	local alt = self:GetDTBool(0)

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, alt and 30 or 100, alt and 30 or 100, Color(255,210,170))
end

-- ==== Initialize - 初始化尾焰音效 ====
-- 主武器为低沉轰鸣，副武器为小声高频点火声
function ENT:Initialize()
	local alt = self:GetDTBool(0)

	self.AmbientSound = CreateSound(self, "Missile.Ignite")
	self.AmbientSound:PlayEx(alt and 0.3 or 1, alt and 245 or 65)
end

-- ==== Think - 每帧发射烟迹粒子与动态灯光 ====
-- 主武器高频喷出火焰烟雾，副武器低频；同时照亮周围环境
function ENT:Think()
	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	local alt = self:GetDTBool(0)
	emitter:SetNearClip(24, 32)

	-- 按节流间隔发射火云与烟迹粒子（副武器间隔更长）
	if self.SmokeTimer < CurTime() then
		self.SmokeTimer = CurTime() + (alt and 0.3 or 0.05)

		-- 向后喷射的火焰粒子（相对速度反向）
		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetVelocity(self:GetVelocity() * -0.4 + VectorRand() * 60)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(100)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(12, 19))
		particle:SetEndSize(5)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(240, 180, 120)

		-- 扩散烟团粒子（随机偏移起点）
		particle = emitter:Add("particles/smokey", pos + VectorRand() * 10)
		particle:SetDieTime(math.Rand(0.4, 0.6))
		particle:SetStartAlpha(math.Rand(110, 130))
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(math.Rand(20, 34))
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(240, 190, 120)
	end

	-- 结束发射器并触发一次增量 GC（本模式性能惯例）
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 为火箭挂一盏橙色动态灯光，照亮飞行路径
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 190
		dlight.b = 130
		dlight.Brightness = 2
		dlight.Size = 150
		dlight.Decay = 300
		dlight.DieTime = CurTime() + 2
	end
end

-- ==== OnRemove - 移除时停止音效并播放副武器爆炸焰火 ====
-- 副武器（alt）爆炸时喷出火花、余烬、大光晕与放射状碎片粒子
function ENT:OnRemove()
	self.AmbientSound:Stop()

	local pos = self:GetPos()
	local alt = self:GetDTBool(0)

	-- 只有副武器爆炸才播焰火粒子
	if not alt then return end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 高速四散的小光点
	for i=0, 25 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 275)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(7, 9))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(245, 155, 30)
	end
	-- 带重力的火星余烬（落地反弹）
	for i=1, 16 do
		particle = emitter:Add("effects/fire_embers"..math.random(1, 3), pos)
		particle:SetVelocity(VectorRand():GetNormal() * 250)
		particle:SetDieTime(math.Rand(1.25, 1.5))
		particle:SetStartAlpha(130)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(15, 19))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetAirResistance(50)
		particle:SetCollide(true)
		particle:SetBounce(0.3)
		particle:SetGravity(Vector(0,0,-400))
	end
	-- 缓慢膨胀的大号闪光（模拟爆炸火球）
	for i=0,5 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(127, 129))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(245, 175, 60)
	end
	-- 放射状四散的橙色碎片（拉长粒子）
	for i=1, 75 do
		particle = emitter:Add("effects/splash2", pos)
		particle:SetDieTime(0.6)
		particle:SetColor(255, 130, 0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(0)
		particle:SetStartLength(1)
		particle:SetEndLength(15)
		particle:SetVelocity(VectorRand():GetNormal() * 200)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
