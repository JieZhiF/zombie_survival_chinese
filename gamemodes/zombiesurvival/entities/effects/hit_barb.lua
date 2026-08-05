-- ============================================================================
-- hit_barb.lua - 倒刺命中特效（客户端）
-- 负责：倒刺飞镖命中目标时沿命中方向锥形喷发大量深色烟尘粒子，
--       并播放金属锯齿嵌入音效，表现钉入瞬间的冲击感
-- ============================================================================

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end

-- ==== Init - 特效初始化：喷发烟尘粒子并播放嵌入音效 ====
function EFFECT:Init(data)
	-- 命中位置与命中面法线（取反后作为主喷射方向）
	local pos = data:GetOrigin()
	local hitnormal = data:GetNormal() * -1

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 48)

	-- 60~85 个深色烟尘粒子：沿法线方向锥形喷出，受重力下落并与地面碰撞
	local grav = Vector(0, 0, -200)
	for i = 1, math.random(60, 85) do
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(90, 130) + hitnormal * math.Rand(48, 198))
		particle:SetDieTime(math.Rand(1.2, 2))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(1, 2))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-15, 15))
		particle:SetColor(25, 25, 25)
		particle:SetLighting(true)
		particle:SetGravity(grav)
		particle:SetCollide(true)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 播放金属锯齿嵌入音效（随机 3 种之一，高音调模拟刺入）
	sound.Play("physics/metal/sawblade_stick"..math.random(3)..".wav", pos, 74, math.random(199, 210))
end
