-- ============================================================================
-- hit_spit.lua - 酸液吐痰命中特效（客户端）
-- 负责：酸液命中时沿表面法线反向喷射大量绿色粘液粒子并播放挤压音效，
--       粒子受重力下落，落地时随机留下异形血肉贴图与湿滑音效
-- ============================================================================

-- 纯粒子特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

-- 粒子碰撞回调：粘液碰到表面时立即消失并随机播放湿润音效/贴图
local function CollideCallback(particle, hitpos, hitnormal)
	if particle:GetDieTime() == 0 then return end
	particle:SetDieTime(0)

	-- 三分之一概率播放血肉挤压声
	if math.random(3) == 3 then
		sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", hitpos, 50, math.Rand(95, 105))
	end

	-- 三分之一概率在碰撞面留下异形血肉贴图
	if math.random(3) == 3 then
		util.Decal("Impact.AlienFlesh", hitpos + hitnormal, hitpos - hitnormal)
	end
end

-- ==== Init - 特效初始化：喷射绿色粘液粒子并留下初始贴图 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local hitnormal = data:GetNormal() * -1

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 48)

	local grav = Vector(0, 0, -500)
	-- 随机 60~85 个绿色粘液粒子，沿法线方向溅射并受重力下落
	for i = 1, math.random(60, 85) do
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(32, 72) + hitnormal * math.Rand(48, 198))
		particle:SetDieTime(math.Rand(0.9, 2))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(1, 5))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-15, 15))
		particle:SetColor(math.Rand(25, 30), math.Rand(200, 240), math.Rand(25, 30))
		particle:SetLighting(true)
		particle:SetGravity(grav)
		particle:SetCollide(true)
		particle:SetCollideCallback(CollideCallback)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 命中点直接留下一块异形血肉贴图
	util.Decal("Impact.AlienFlesh", pos + hitnormal, pos - hitnormal)

	-- 播放蚂蚁幼虫被压扁的挤压音效
	sound.Play("npc/antlion_grub/squashed.wav", pos, 74, math.random(95, 110))
end
