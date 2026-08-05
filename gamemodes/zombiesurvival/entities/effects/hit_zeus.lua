-- ============================================================================
-- hit_zeus.lua - 宙斯之怒命中特效（客户端）
-- 负责：电击命中瞬间播放高压电弧音效，喷出蓝色电火花粒子，并逐帧
--       绘制中心光晕与放射状电弧光束，整体随生命周期快速衰减
-- ============================================================================

-- ==== Init - 特效初始化：记录位置并喷射电火花粒子 ====
function EFFECT:Init(effectdata)
	-- 命中位置（Render 中用于绘制光晕与电弧）
	local pos = effectdata:GetOrigin()
	self.Pos = pos
	-- 主喷射方向（命中法线）
	local normal = effectdata:GetNormal()

	-- 生命周期状态：Alpha 从 255 线性衰减，Life 0 → 1 控制整体进度
	self.Alpha = 255
	self.Life = 0

	-- 播放高压放电音效（高频刺耳，模拟电击）
	sound.Play("ambient/office/zap1.wav", pos, 80, math.random(165, 180))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 15 个蓝色电火花沿法线方向高速飞出并弹跳，模拟电弧溅射
	for i=1, 15 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(0.5)
		particle:SetColor(50,125,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(4)
		particle:SetVelocity((normal + VectorRand()):GetNormal() * 700)
		particle:SetGravity(VectorRand() * 20 + Vector(0, 0, -100))
		particle:SetCollide(true)
		particle:SetBounce(0.75)
		particle:SetAirResistance(12)
	end
	-- 6 个大型蓝色光斑原地快速膨胀消失，形成电击中心的闪光
	for i=0,5 do
		particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(47, 49))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(55, 136, 245)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 推进生命周期：Alpha 衰减，Life 达到 1 时特效消亡 ====
function EFFECT:Think()
	-- 生命周期进度以每秒 4 倍速推进，透明度同步线性下降
	self.Life = self.Life + FrameTime() * 4
	self.Alpha = 255 * (1 - self.Life)
	return self.Life < 1
end

-- 辉光材质（中心光晕）与激光材质（放射状电弧光束）
local glowmat = Material("sprites/glow04_noz")
local matTrail = Material("trails/laser")
-- ==== Render - 逐帧渲染：中心光晕 + 8 条随机电弧光束 ====
function EFFECT:Render()
	local pos = self.Pos

	-- 绘制命中点的蓝色中心光晕，透明度随生命周期衰减
	render.SetMaterial(glowmat)
	render.DrawSprite(pos, 60, 60, Color(70, 140, 255, self.Alpha))

	-- 沿 8 个随机方向绘制激光光束，长度与透明度同步衰减
	render.SetMaterial(matTrail)
	for i=1, 8 do
		local dir = VectorRand():GetNormal()
		render.DrawBeam(pos, pos + dir * 30 * self.Alpha/255, 15, i, 3 + i, Color(70, 140, 250))
	end
end
