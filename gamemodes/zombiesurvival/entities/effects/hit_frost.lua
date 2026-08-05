-- ============================================================================
-- hit_frost.lua - 冰冻命中特效（客户端）
-- 负责：冰冻攻击命中时播放玻璃碎裂音效并喷射蓝白色冰晶闪光粒子，
--       粒子落地时附带冰面碎裂声与碎冰贴图，表现冻结破碎效果
-- ============================================================================

-- 纯粒子特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

-- 粒子碰撞回调：冰晶碰到表面时立即消失并随机播放碎裂音/贴图
local function CollideCallback(particle, hitpos, hitnormal)
	if particle:GetDieTime() == 0 then return end
	particle:SetDieTime(0)

	-- 三分之一概率播放玻璃碎裂撞击声
	if math.random(3) == 3 then
		sound.Play("physics/glass/glass_impact_bullet"..math.random(4)..".wav", hitpos, 50, math.Rand(135, 155))
	end

	-- 三分之一概率在碰撞面留下碎玻璃贴图
	if math.random(3) == 3 then
		util.Decal("Impact.Glass", hitpos + hitnormal, hitpos - hitnormal)
	end
end

-- ==== Init - 特效初始化：喷射冰晶闪光粒子并播放碎裂音效 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(28, 32)
	local grav = Vector(0, 0, -200)
	-- 随机 4~7 个蓝白色闪光粒子，受重力下落并可与表面碰撞
	for i=1, math.random(4, 7) do
		local particle = emitter:Add("particle/sparkles", pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(16, 64))
		particle:SetDieTime(math.Rand(1.1, 1.5))
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 3))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetCollide(true)
		particle:SetGravity(grav)
		particle:SetCollideCallback(CollideCallback)
		particle:SetColor(140, 175, 205)
		particle:SetLighting(false)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 命中瞬间播放高音调玻璃碎裂声
	sound.Play("physics/glass/glass_impact_bullet"..math.random(4)..".wav", pos, 80, math.Rand(165, 170))
end
