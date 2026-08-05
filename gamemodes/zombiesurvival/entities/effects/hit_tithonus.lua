-- ============================================================================
-- hit_tithonus.lua - 提托努斯（Tithonus）命中特效（客户端）
-- 负责：提托努斯攻击命中时沿表面法线喷射绿色生命火花粒子，
--       随后在命中点短暂显示一颗衰减的绿色光晕
-- ============================================================================

-- ==== Init - 特效初始化：喷射绿色火花并记录位置 ====
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()
	self.Pos = pos
	local normal = effectdata:GetNormal()

	-- 光晕透明度与寿命计数器初始值
	self.Alpha = 255
	self.Life = 0

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 沿法线方向并带随机偏移，喷射 15 颗绿色生命火花
	for i=1, 15 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(0.2)
		particle:SetColor(40,255,70)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(2)
		particle:SetVelocity((normal + VectorRand()):GetNormal() * 150)
		particle:SetCollide(true)
		particle:SetBounce(0.75)
		particle:SetAirResistance(12)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 每帧推进寿命，驱动光晕透明度衰减 ====
function EFFECT:Think()
	self.Life = self.Life + FrameTime() * 3
	self.Alpha = 255 * (1 - self.Life)
	return (self.Life < 1)
end

-- 光晕绘制材质
local glowmat = Material("sprites/glow04_noz")
-- ==== Render - 在命中点绘制随寿命衰减的绿色光晕 ====
function EFFECT:Render()
	local pos = self.Pos

	render.SetMaterial(glowmat)
	render.DrawSprite(pos, 25, 25, Color(40, 255, 70, self.Alpha))
end
