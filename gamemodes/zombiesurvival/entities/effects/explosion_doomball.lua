-- ============================================================================
-- explosion_doomball.lua - 末日之球爆炸特效（客户端）
-- 负责：爆炸瞬间播放燃气罐点燃音效，喷出黑色浓烟团与扩散烟尘，
--       并额外触发 8 次 doomball_skull 骷髅头特效叠加视觉冲击
-- ============================================================================

-- ==== Init - 特效初始化：喷射浓烟并触发骷髅头附加特效 ====
function EFFECT:Init(data)
	-- 爆炸位置与主方向（法线取反作为喷发方向）
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	-- 出生点沿法线微抬，避免粒子嵌在表面内部
	pos = pos + normal

	-- 播放燃气罐点燃音效（低音调模拟爆炸轰鸣）
	sound.Play("ambient/fire/gascan_ignite1.wav", pos, 75, math.Rand(50, 55))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 6 个巨型黑色浓烟团原地膨胀消散，形成爆炸初期的烟柱
	for i=1, 6 do
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetDieTime(math.Rand(2, 4.5))
		particle:SetStartAlpha(30)
		particle:SetEndAlpha(0)
		particle:SetStartSize(200)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-5.5, 5.5))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(0, 0, 0)
	end

	-- 80 个烟尘粒子向四周随机高速扩散，模拟爆炸冲击波掀起的尘雾
	for i=1, 80 do
		local heading = VectorRand()
		heading:Normalize()

		local size = math.Rand(15, 25)

		local particle = emitter:Add("particles/smokey", pos + heading * math.Rand(2, 64))
		particle:SetVelocity(heading * math.Rand(-128, 256))
		particle:SetDieTime(math.Rand(3, 5.5))
		particle:SetStartAlpha(60)
		particle:SetEndAlpha(0)
		particle:SetStartSize(size)
		particle:SetEndSize(size)
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(0, 0, 0)
		particle:SetAirResistance(math.Rand(50, 200))
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 在爆炸位置重复触发 8 次骷髅头光效，叠加成炫目的爆炸核心
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	for i=1, 8 do
		util.Effect("doomball_skull", effectdata)
	end
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
