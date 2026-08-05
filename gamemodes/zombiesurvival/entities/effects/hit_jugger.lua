-- ============================================================================
-- hit_jugger.lua - 重击命中特效（客户端）
-- 负责：重击命中时沿表面法线喷射红色火化粒子并播放金属撞击音效，
--       随后在命中点短暂显示一颗衰减的橙色光晕，强化打击感
-- ============================================================================

-- ==== Init - 特效初始化：喷射红色火花并记录位置 ====
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()
	self.Pos = pos
	local normal = effectdata:GetNormal()

	-- 光晕透明度与寿命计数器初始值
	self.Alpha = 255
	self.Life = 0

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 沿法线方向并带随机偏移，喷射 15 颗红色火花粒子
	for i=1, 15 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(0.4)
		particle:SetColor(255,70,40)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(2)
		particle:SetVelocity((normal + VectorRand()):GetNormal() * 70)
		particle:SetCollide(true)
		particle:SetBounce(0.75)
		particle:SetAirResistance(12)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 播放金属片被子弹击中的撞击声
	sound.Play("physics/metal/metal_sheet_impact_bullet"..math.random(2)..".wav", pos, 80, math.Rand(135, 155))
end

-- ==== Think - 每帧推进寿命，驱动光晕透明度衰减 ====
function EFFECT:Think()
	self.Life = self.Life + FrameTime() * 3
	self.Alpha = 255 * (1 - self.Life)
	return self.Life < 1
end

-- 光晕绘制材质
local glowmat = Material("sprites/glow04_noz")
-- ==== Render - 在命中点绘制随寿命衰减的橙色光晕 ====
function EFFECT:Render()
	local pos = self.Pos

	render.SetMaterial(glowmat)
	render.DrawSprite(pos, 20, 20, Color(255, 75, 40, self.Alpha))
end
