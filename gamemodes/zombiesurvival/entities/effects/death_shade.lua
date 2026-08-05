-- ============================================================================
-- death_shade.lua - 暗影死亡特效（客户端）
-- 负责：暗影单位死亡瞬间喷射蓝色能量光点粒子并播放分解音效，
--       随后逐帧绘制一个快速衰减的大型蓝色光晕，表现能量消散
-- ============================================================================

-- ==== Init - 特效初始化：记录位置并喷射蓝色能量粒子 ====
function EFFECT:Init(effectdata)
	-- 死亡位置（Render 中用于绘制大光晕）
	local pos = effectdata:GetOrigin()
	self.Pos = pos
	-- 主喷射方向（命中法线）
	local normal = effectdata:GetNormal()

	-- 生命周期状态：Alpha 从 255 衰减，Life 0 → 1 控制光晕收缩
	self.Alpha = 255
	self.Life = 0

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 30 个蓝色能量粒子沿法线方向高速飞出并弹跳，模拟能量四散
	for i=1, 30 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(1)
		particle:SetColor(50,80,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(7)
		particle:SetVelocity((normal + VectorRand()):GetNormal() * 300)
		particle:SetGravity(VectorRand() * 20 + Vector(0, 0, -300))
		particle:SetCollide(true)
		particle:SetBounce(0.75)
		particle:SetAirResistance(12)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 播放能量分解音效（低音调模拟物质消散）
	sound.Play("weapons/physcannon/energy_disintegrate4.wav", pos, 80, math.Rand(50, 65))
end

-- ==== Think - 推进生命周期：透明度衰减，Life 达到 1 时特效消亡 ====
function EFFECT:Think()
	-- 生命周期以每秒 2 倍速推进，透明度同步线性下降
	self.Life = self.Life + FrameTime() * 2
	self.Alpha = 255 * (1 - self.Life)
	return (self.Life < 1)
end

-- 蓝色辉光材质（中心大光晕）
local glowmat = Material("sprites/glow04_noz")

-- ==== Render - 逐帧渲染：在死亡位置绘制衰减的蓝色大光晕 ====
function EFFECT:Render()
	render.SetMaterial(glowmat)
	render.DrawSprite(self.Pos, 300, 300, Color(110, 150, 255, self.Alpha))
end
