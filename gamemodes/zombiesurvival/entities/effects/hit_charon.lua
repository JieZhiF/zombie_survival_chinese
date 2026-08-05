-- ============================================================================
-- hit_charon.lua - 卡戎（Charon）命中特效（客户端）
-- 负责：卡戎攻击命中时沿表面法线喷射蓝色能量火花并播放金属撞击音效，
--       随后在命中点短暂显示一颗衰减的蓝色光晕
-- ============================================================================

-- ==== Init - 特效初始化：喷射蓝色火花并记录位置 ====
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()
	self.Pos = pos
	local normal = effectdata:GetNormal()

	-- 光晕透明度与寿命计数器初始值
	self.Alpha = 255
	self.Life = 0

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 沿法线方向并带随机偏移，喷射 11 颗蓝色能量火花
	for i=1, 11 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(0.2)
		particle:SetColor(190,210,250)
		particle:SetStartAlpha(190)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(2)
		particle:SetVelocity((normal + VectorRand()):GetNormal() * 200)
		particle:SetCollide(true)
		particle:SetBounce(0.75)
		particle:SetAirResistance(24)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 播放高音调金属撞击声，突出能量武器手感
	sound.Play("physics/metal/metal_sheet_impact_bullet"..math.random(2)..".wav", pos, 75, math.Rand(195, 215))
end

-- ==== Think - 每帧推进寿命，驱动光晕透明度衰减 ====
function EFFECT:Think()
	self.Life = self.Life + FrameTime() * 5
	self.Alpha = 255 * (1 - self.Life)
	return (self.Life < 1)
end

-- 光晕绘制材质
local glowmat = Material("sprites/glow04_noz")
-- ==== Render - 在命中点绘制随寿命衰减的蓝色光晕 ====
function EFFECT:Render()
	local pos = self.Pos

	render.SetMaterial(glowmat)
	render.DrawSprite(pos, 20, 20, Color(180, 210, 255, self.Alpha))
end
