-- ============================================================================
-- cl_init.lua - 弹跳手雷投射物（客户端）：外观参数与爆炸粒子特效
-- 负责：以缩小黄色模型显示手雷，移除时喷发火花/余烬/闪光/飞溅粒子
-- ============================================================================
INC_CLIENT()

-- 发光点材质（爆炸闪光用）
local matGlow = Material("sprites/light_glow02_add")

-- ==== Initialize - 初始化：应用缩小尺寸与淡黄配色 ====
function ENT:Initialize()
	self:SetModelScale(0.2, 0)
	self:SetColor(Color(255, 255, 100))
	self:DrawShadow(false)
end

-- ==== OnRemove - 移除时：在爆炸点喷发四层粒子特效 ====
function ENT:OnRemove()
	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 25 个向外飞散的橙色发光火花
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
	-- 16 个带碰撞弹跳的火星余烬
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
	-- 6 个大号橙色闪光（爆炸中心光晕）
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
	-- 75 个向外拉长的橙色飞溅条（爆炸冲击）
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
