-- ============================================================================
-- death_extinctioncrab.lua - 灭绝蟹死亡爆体特效（客户端）
-- 负责：角色死亡瞬间播放躯干断裂与血肉撞击音效，依次喷射红色烟雾、
--       灰色血雾与向外迸射的橙色雨点粒子，最后留下大片血迹
-- ============================================================================

-- ==== Init - 特效初始化：播放死亡音效并分三阶段喷射粒子 ====
function EFFECT:Init(data)
	-- 爆体位置与主朝向（法线取反作为爆体喷发方向）
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	-- 出生点沿法线微抬，避免粒子嵌在表面内部
	pos = pos + normal

	-- 立即播放躯干断裂音效，并延迟随机播放数次血肉撞击音效
	sound.Play("physics/body/body_medium_break"..math.random(2, 4)..".wav", pos, 77, math.Rand(90, 110))
	for i=0, math.random(2, 3) do
		timer.Simple(i * math.Rand(0.1, 0.3), function() sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", pos, 77, math.Rand(90, 110)) end)
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle, size, heading

	-- 第一阶段：12 个暗红色浓烟团沿爆体方向上升，缓慢旋转并渐隐消散
	for i=1, 12 do
		particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(normal * 48 + VectorRand() * 32)
		particle:SetDieTime(math.Rand(3.5, 4.5))
		particle:SetStartAlpha(60)
		particle:SetEndAlpha(0)
		particle:SetStartSize(200)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-2.5, 2.5))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(160, 5, 0)
	end

	-- 第二阶段：24 个灰色血雾粒子逆着重力向上飘起，模拟爆体升腾的血雾
	local grav = Vector(0, 0, 170)
	for i=1, 24 do
		particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(normal * -48 + VectorRand() * 64)
		particle:SetGravity(-grav)
		particle:SetDieTime(math.Rand(2, 2.5))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(13, 14))
		particle:SetEndSize(math.Rand(10, 12))
		particle:SetRoll(180)
		particle:SetDieTime(3)
		particle:SetColor(50, 50, 50)
		particle:SetLighting(true)
	end

	-- 第三阶段：80 个橙色长条雨点粒子向四周高速迸射并拉长，模拟爆体喷溅的体液
	for i=1, 80 do
		heading = VectorRand()
		heading:Normalize()

		size = math.Rand(10, 15)

		particle = emitter:Add("particle/rain", pos + heading * math.Rand(2, 64))
		particle:SetVelocity(heading * math.Rand(200, 550))
		particle:SetGravity(Vector(0, 0, -250))
		particle:SetDieTime(math.Rand(1, 1.5))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(size)
		particle:SetEndSize(size)
		particle:SetStartLength(size * 2)
		particle:SetEndLength(size * 4.5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, 120, 0)
		particle:SetAirResistance(math.Rand(20, 30))
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 在爆体位置留下 22~26 处向上喷溅的血迹
	util.Blood(pos, math.random(22, 26), Vector(0,0,1), 300)
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
