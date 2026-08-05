-- ============================================================================
-- headcrab_dust.lua - 头蟹扬尘特效（客户端）
-- 负责：在头蟹尸体位置扬起少量土黄色尘埃粒子——粒子随机偏移出生、
--       缓慢漂移、逐渐缩小消失并接受光照，表现落地扬起的尘土细节
-- ============================================================================

-- ==== Init - 特效初始化：喷射少量尘土粒子 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 24)

	-- 2 颗尘埃粒子：出生位置与速度均带随机偏移，缓慢扩散
	for i=1, 2 do
		local particle = emitter:Add("particles/smokey", pos + VectorRand():GetNormalized() * math.Rand(0.1, 6))
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(1, 16))
		particle:SetDieTime(math.Rand(1, 2.5))
		particle:SetStartAlpha(math.random(100, 140))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(4, 12))
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-2.5, 2.5))
		particle:SetRoll(math.random(0, 360))
		-- 土黄色尘土色泽，并受场景光照影响
		particle:SetColor(255, 220, 50)
		particle:SetLighting(true)
	end

	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 特效思考：一次性爆发特效，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由粒子系统自动绘制 ====
function EFFECT:Render()
end
