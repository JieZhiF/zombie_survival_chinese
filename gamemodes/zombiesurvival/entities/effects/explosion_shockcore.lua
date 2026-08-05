-- ============================================================================
-- explosion_shockcore.lua - 电击核心爆炸特效（客户端）
-- 负责：电击核心爆炸瞬间播放能量分解音效，喷射 100 条蓝色闪电条
--       粒子与多层扩散的蓝色光环，随后绘制脉动的折射环与蓝色
--       光晕，表现电能爆发冲击
-- ============================================================================

-- 特效基准寿命（秒）
EFFECT.LifeTime = 0.45

-- ==== Init - 特效初始化：喷射闪电粒子与扩散光环 ====
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()
	local normal = effectdata:GetNormal()

	-- 爆炸位置沿法线略作偏移，避免贴进表面
	pos = pos + normal

	self.Pos = pos
	self.Normal = normal
	self.DieTime = CurTime() + self.LifeTime

	local particle

	-- 播放能量分解与爆鸣两种音效
	sound.Play("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav", pos, 80, math.random(70, 90))
	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", pos, 80, math.random(105, 120))

	-- 普通发射器用于闪电条，第二个发射器（相对坐标）用于光环
	local emitter = ParticleEmitter(pos)
	local emitter2 = ParticleEmitter(pos, true)
	emitter:SetNearClip(24, 32)
	emitter2:SetNearClip(24, 32)

	-- 100 条蓝色闪电条沿随机方向放射，由短变长模拟电流
	for i=1, 100 do
		particle = emitter:Add("effects/splash2", pos)
		particle:SetDieTime(0.4)
		particle:SetColor(75, 110, 255)
		particle:SetStartAlpha(185)
		particle:SetEndAlpha(0)
		particle:SetStartSize(6)
		particle:SetEndSize(6)
		particle:SetStartLength(0)
		particle:SetEndLength(90)
		particle:SetVelocity(VectorRand():GetNormal() * 220)
	end
	-- 沿表面生成两组大小递增的扩散光环
	local ringstart = pos + normal * -3
	for i=1, 3 do
		particle = emitter2:Add("effects/select_ring", ringstart)
		particle:SetDieTime(0.1 + i * 0.1)
		particle:SetColor(75, 115, 255)
		particle:SetStartAlpha(185)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(110)
		particle:SetAngles(normal:Angle())
		particle = emitter2:Add("effects/select_ring", ringstart)
		particle:SetDieTime(0.2 + i * 0.1)
		particle:SetColor(75, 115, 255)
		particle:SetStartAlpha(185)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(120)
		particle:SetAngles(normal:Angle())
	end

	emitter:Finish()
	emitter2:Finish()
end

-- ==== Think - 存活至死亡时间 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 折射环、光晕材质与光晕颜色
local matRefract = Material("refract_ring")
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(75, 115, 255)
-- ==== Render - 绘制脉动的折射环与蓝色光晕 ====
function EFFECT:Render()
	-- 剩余寿命比例，控制尺寸与透明度
	local delta = (self.DieTime - CurTime()) / self.LifeTime
	-- 基准尺寸随寿命快速扩张
	local basesize = 48
	basesize = basesize + basesize ^ (1.5 - delta)

	local pos = self.Pos
	-- 折射量随寿命波动衰减，绘制双面折射环表现能量扭曲
	matRefract:SetFloat("$refractamount", (10.75 + math.abs(math.sin(CurTime() * 5)) * math.pi * 0.25) * delta)
	render.SetMaterial(matRefract)
	render.UpdateRefractTexture()
	render.DrawSprite(pos, basesize, basesize)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)

	-- 内层绘制更小的蓝色光晕并随寿命渐隐
	basesize = basesize * 0.75

	colGlow.a = delta * 255
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, basesize, basesize, colGlow)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
end
