-- ============================================================================
-- hit_flesh.lua - 血肉命中特效（客户端）
-- 负责：命中血肉目标时沿法线方向喷出黄色血滴粒子，血滴落地播放血肉
--       撞击音效并随机留下印记，同时在命中面投射黄色血迹贴图
-- ============================================================================

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end

-- ==== CollideCallback - 血滴碰撞回调：终止粒子、播放音效并随机留印记 ====
local function CollideCallback(particle, hitpos, hitnormal)
	-- 已终止的粒子直接忽略，避免重复处理
	if particle:GetDieTime() == 0 then return end
	particle:SetDieTime(0)

	-- 1/3 概率播放血肉撞击音效
	if math.random(3) == 3 then
		sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.Rand(95, 105))
	end

	-- 1/3 概率在碰撞面留下虫族血肉印记
	if math.random(3) == 3 then
		util.Decal("Impact.Antlion", hitpos + hitnormal, hitpos - hitnormal)
	end
end

-- ==== Init - 特效初始化：喷射黄色血滴并留血迹贴图 ====
function EFFECT:Init(data)
	-- 命中位置与命中面法线（取反作为主喷射方向）
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(28, 32)
	-- 4~7 个黄色血滴：低速向随机方向散开，受重力下落并触发碰撞回调
	local grav = Vector(0, 0, -500)
	for i=1, math.random(4, 7) do
		local particle = emitter:Add("decals/Yblood"..math.random(6), pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(16, 64))
		particle:SetDieTime(math.Rand(2.5, 4.0))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(2, 4))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetCollide(true)
		particle:SetGravity(grav)
		particle:SetCollideCallback(CollideCallback)
		particle:SetLighting(true)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 在命中面直接投射一块黄色血迹贴图
	util.Decal("YellowBlood", pos + normal, pos - normal)

	-- 播放血肉撞击音效（随机 4 种之一）
	sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", pos, 80, math.Rand(95, 110))
end
