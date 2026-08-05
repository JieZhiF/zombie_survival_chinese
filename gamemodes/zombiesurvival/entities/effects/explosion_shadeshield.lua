-- ============================================================================
-- explosion_shadeshield.lua - 暗影护盾爆炸特效（客户端）
-- 负责：护盾被击破瞬间在爆炸点喷射 50 个蓝色能量火花粒子，
--       沿法线方向飘散并受重力下落、弹跳，表现护盾碎裂的能量迸发
-- ============================================================================

-- ==== Init - 特效初始化：在爆炸点喷射蓝色能量火花 ====
function EFFECT:Init(effectdata)
	-- 爆炸位置与主喷射方向（命中法线）
	local pos = effectdata:GetOrigin()
	local normal = effectdata:GetNormal()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 50 个蓝色火花：沿法线方向扩散，尺寸渐大、随重力下落并弹跳
	for i=1, 50 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(1)
		particle:SetColor(50,90,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(11)
		particle:SetVelocity((normal + VectorRand()):GetNormal() * 150)
		particle:SetGravity(VectorRand() * 20 + Vector(0, 0, -400))
		particle:SetCollide(true)
		particle:SetBounce(0.75)
		particle:SetAirResistance(12)
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
