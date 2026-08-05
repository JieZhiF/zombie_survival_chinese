-- ============================================================================
-- projectile_flakbomb/cl_init.lua - 高射炮弹（母弹）投射物（客户端）
-- 负责：同步母弹模型缩放与配色；移除（爆炸）时生成橙红色爆炸粒子特效
-- ============================================================================
INC_CLIENT()

-- 爆炸粒子发光材质
local matGlow = Material("sprites/light_glow02_add")

-- ==== Initialize - 客户端初始化：同步模型缩放、颜色并关闭阴影 ====
function ENT:Initialize()
	self:SetModelScale(0.33, 0)
	self:SetColor(Color(205, 135, 110))
	self:DrawShadow(false)
end

-- ==== OnRemove - 移除（爆炸）时喷发三层橙红色爆炸粒子 ====
function ENT:OnRemove()
	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 第一层：26 颗高速四散的小火花（随机方向 275 速度，0.5 秒消失）
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
	-- 第二层：6 颗原地膨胀的亮橙色大光球（闪光核心）
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
	-- 第三层：75 条沿随机方向飞射的线状火花（拉长呈尾迹状）
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
