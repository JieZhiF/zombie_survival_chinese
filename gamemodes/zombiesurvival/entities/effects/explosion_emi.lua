-- ============================================================================
-- explosion_emi.lua - 电磁脉冲（EMI）爆炸特效（客户端）
-- 负责：电磁脉冲爆炸瞬间播放燃气罐点燃音效，喷射 70~80 颗灰色电火
--       花粒子并点亮白色动态光源，随后绘制快速扩张的折射环与
--       灰色光晕，表现电磁冲击波
-- ============================================================================

-- 特效基准寿命（秒）
EFFECT.LifeTime = 0.5

-- ==== Init - 特效初始化：喷射电火花并创建动态光源 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	-- 爆炸位置沿法线略作偏移，避免贴进表面
	pos = pos + normal

	self.Pos = pos
	self.Normal = normal
	self.DieTime = CurTime() + self.LifeTime

	-- 播放燃气罐点燃的高音爆鸣
	sound.Play("ambient/fire/gascan_ignite1.wav", pos, 75, math.Rand(250, 255))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 70~80 颗灰色电火花沿随机方向放射
	for i=1, math.random(70, 80) do
		local heading = VectorRand()
		heading:Normalize()

		local particle = emitter:Add("effects/spark", pos + heading * 8)
		particle:SetVelocity(120 * heading)
		particle:SetDieTime(math.Rand(0.5, 0.55))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(3, 4))
		particle:SetEndSize(0)
		particle:SetColor(110, 110, 110)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(250)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 创建持续 1 秒的白色动态光源
	local dlight = DynamicLight(0)
	if dlight then
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 8
		dlight.Size = 300
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 1
	end
end

-- ==== Think - 存活至死亡时间 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 折射环、光晕材质与光晕颜色
local matRefract = Material("refract_ring")
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(215, 215, 215)
-- ==== Render - 绘制快速扩张的折射环与灰色光晕 ====
function EFFECT:Render()
	-- 剩余寿命比例，控制尺寸与透明度
	local delta = (self.DieTime - CurTime()) / self.LifeTime
	-- 基准尺寸随寿命快速扩张
	local basesize = 20
	basesize = basesize + basesize ^ (1.5 - delta)

	local pos = self.Pos
	-- 折射量随寿命波动衰减，绘制双面折射环表现冲击扭曲
	matRefract:SetFloat("$refractamount", (0.75 + math.abs(math.sin(CurTime() * 5)) * math.pi * 0.25) * delta)
	render.SetMaterial(matRefract)
	render.UpdateRefractTexture()
	render.DrawSprite(pos, basesize, basesize)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, color_white, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, color_white, 0)

	-- 内层绘制更小的灰色光晕并随寿命渐隐
	basesize = basesize * 0.75

	colGlow.a = delta * 255
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, basesize, basesize, colGlow)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
end
