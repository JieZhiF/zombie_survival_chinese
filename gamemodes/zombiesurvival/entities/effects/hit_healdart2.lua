-- ============================================================================
-- hit_healdart2.lua - 治疗飞镖命中特效（客户端）
-- 负责：治疗飞镖命中目标时播放蒸汽释放音效（命中玩家额外播放弩箭
--       命中音效），并沿命中法线锥形喷射蓝色治疗烟雾粒子
-- ============================================================================

-- ==== Init - 特效初始化：播放命中音效并喷射治疗烟雾 ====
function EFFECT:Init(data)
	-- 命中位置、法线与目标实体
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local ent = data:GetEntity()

	-- 目标有效时音效挂在目标上，命中玩家再补一个弩箭命中音效
	if ent and ent:IsValid() then
		ent:EmitSound("ambient/machines/steam_release_2.wav", 70, 255)

		if ent:IsPlayer() then
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav", 70, 140)
		end
	else
		sound.Play("ambient/machines/steam_release_2.wav", pos, 70, 255)
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 32 个蓝色烟雾粒子：以法线为轴在 80 度范围内随机旋转射出，模拟治疗雾团
	for i=1, 32 do
		local ang = norm:Angle()
		ang:RotateAroundAxis(ang:Up(), math.Rand(0, 360))
		ang:RotateAroundAxis(ang:Right(), math.Rand(-80, 80))

		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(ang:Forward() * math.Rand(4, 32))
		particle:SetDieTime(math.Rand(0.75, 1.25))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(6)
		particle:SetColor(71, 127, 255)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetGravity(Vector(0, 0, -10))
		particle:SetAirResistance(100)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
