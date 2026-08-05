-- ============================================================================
-- explosion_fat.lua - 胖子爆炸特效（客户端）：黄色血雾爆裂
-- 负责：爆炸瞬间播放躯干断裂与血肉撞击音效，喷射黄色血雾粒子并在
--       爆炸位置留下大片血迹，表现肥硕僵尸爆裂的场面
-- ============================================================================

-- ==== Init - 特效初始化：播放音效并喷射黄色血雾 ====
function EFFECT:Init(data)
	-- 爆炸位置与喷发主方向（命中法线）
	local pos = data:GetOrigin()
	local norm = data:GetNormal()

	-- 立即播放躯干断裂音效，并延迟随机播放数次血肉撞击音效
	sound.Play("physics/body/body_medium_break"..math.random(2, 4)..".wav", pos, 77, math.Rand(90, 110))
	for i=0, math.random(2, 3) do
		timer.Simple(i * math.Rand(0.1, 0.3), function() sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", pos, 77, math.Rand(90, 110)) end)
	end

	local emitter = ParticleEmitter(pos)

	-- 12 个黄色血雾粒子沿爆裂方向喷出并渐隐，模拟脂肪与血液飞溅
	for i=1, 12 do
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(norm * 32 + VectorRand() * 16)
		particle:SetDieTime(math.Rand(1.5, 2.5))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(13, 14))
		particle:SetEndSize(math.Rand(10, 12))
		particle:SetRoll(180)
		particle:SetDieTime(3)
		particle:SetColor(255, 255, 0)
		particle:SetLighting(true)
	end

	-- 单独喷出一个更大的黄色血雾团，作为爆裂中心的主体
	local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
	particle:SetVelocity(norm * 32)
	particle:SetDieTime(math.Rand(2.25, 3))
	particle:SetStartAlpha(200)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(28, 32))
	particle:SetEndSize(math.Rand(14, 28))
	particle:SetRoll(180)
	particle:SetColor(255, 255, 0)
	particle:SetLighting(true)

	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 在爆炸位置留下 16~22 处向上喷溅的血迹
	util.Blood(pos, math.random(16, 22), Vector(0,0,1), 300)
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
