-- ============================================================================
-- explosion_bonemesh_sb.lua - 骨网爆炸特效变体（SB，客户端）
-- 负责：骨网爆裂的次级变体特效，播放躯干断裂音效，先膨胀一团旋转
--       的红色血雾，再向四周高速喷射 100~130 个红色血肉碎粒
-- ============================================================================

-- 纯粒子特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

-- ==== Init - 特效初始化：膨胀血雾并喷射血肉碎粒 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()

	-- 播放躯干断裂音效
	sound.Play("physics/body/body_medium_break"..math.random(2, 4)..".wav", pos, 77, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 48)

	local particle = emitter:Add("particles/smokey", pos)
	-- 第一颗粒子：快速膨胀的旋转红色血雾团
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(32)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(40, 60) * (math.random(2) == 1 and -1 or 1))
	particle:SetColor(255, 30, 30)
	particle:SetLighting(true)

	-- 其余 100~130 颗血肉碎粒沿随机方向高速喷射并受空气阻力减速
	for i = 1, math.random(100, 130) do
		particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(128, 350))
		particle:SetAirResistance(100)
		particle:SetDieTime(math.Rand(0.9, 2))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(1, 3))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetColor(255, 30, 30)
		particle:SetLighting(true)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
