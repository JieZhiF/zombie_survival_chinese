-- ============================================================================
-- explosion_cold.lua - 寒冰爆炸特效（客户端）
-- 负责：寒冰爆炸瞬间播放霜冻音效与寒风呼啸声，高速喷射白色冰晶
--       闪光粒子，并伴随快速膨胀的白色霜雾团，表现冰霜迸发
-- ============================================================================

-- ==== Init - 特效初始化：喷射冰晶与霜雾粒子 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()

	local particle

	-- 播放霜冻破碎与寒风两种音效
	sound.Play("nox/scatterfrost.ogg", pos, 75, math.Rand(95, 115))
	sound.Play("ambient/wind/wind_hit"..math.random(3)..".wav", pos, 75, math.Rand(160, 180))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 30~50 颗白色冰晶闪光，高速四散后受重力和空气阻力缓慢沉降
	for i=1, math.random(30, 50) do
		particle = emitter:Add("particle/sparkles", pos)
		particle:SetVelocity(VectorRand():GetNormal() * math.random(400,520))
		particle:SetAirResistance(math.random(400,600))
		particle:SetGravity(Vector(0,0,-45))
		particle:SetDieTime(math.Rand(3, 5))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(100)
		particle:SetStartSize(1)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetColor(255,255,255)
	end
	-- 16 团白色霜雾从中心快速膨胀消散
	for i=1, 16 do
		particle = emitter:Add("particle/smokesprites_000"..math.random(9), pos)
		particle:SetVelocity(VectorRand():GetNormal() * 140)
		particle:SetDieTime(math.Rand(0.3, 0.6))
		particle:SetStartAlpha(math.Rand(90, 110))
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(90, 120))
		particle:SetRoll(math.Rand(-360, 360))
		particle:SetRollDelta(math.Rand(-4.5, 4.5))
		particle:SetColor(255, 255, 255)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

end

-- 纯粒子特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
