-- ============================================================================
-- zombie_battlecry.lua - 僵尸战吼特效（客户端）
-- 负责：僵尸发出战吼时以自身为圆心生成两圈扩散的红色光环粒子，
--       并朝四周喷出 100 条红色光线，宣告群体冲锋的开始
-- ============================================================================

-- ==== Init - 特效初始化：生成扩散光环与放射状光线 ====
function EFFECT:Init(effectdata)
	-- 战吼中心位置与地面法线（决定光环的朝向）
	local pos = effectdata:GetOrigin()
	local normal = effectdata:GetNormal()

	-- 两个发射器：一个用于光环，一个用于光线
	local emitter = ParticleEmitter(pos, true)
	emitter:SetNearClip(24, 32)
	local emitter2 = ParticleEmitter(pos)
	emitter2:SetNearClip(24, 32)


	-- 3 组共 6 个红色光环粒子：交错延迟、从零膨胀到 220/290 大小，模拟冲击波扩散
	for i=1,3 do
		local particle = emitter:Add("effects/select_ring", pos)
		particle:SetDieTime(0.1 + i * 0.1)
		particle:SetColor(255,35,0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(220)
		particle:SetAngles(normal:Angle())
		particle = emitter:Add("effects/select_ring", pos)
		particle:SetDieTime(0.2 + i * 0.1)
		particle:SetColor(255,35,0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(290)
		particle:SetAngles(normal:Angle())
	end
	-- 100 条红色光线朝随机方向高速射出，形成战吼时的放射状爆发
	for i=1,100 do
		local particle = emitter2:Add("effects/splash2", pos)
		particle:SetDieTime(0.4)
		particle:SetColor(255,35,0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(4)
		particle:SetStartLength(30)
		particle:SetEndLength(30)
		particle:SetVelocity(VectorRand():GetNormal() * math.random(450,600))
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
	emitter2:Finish() emitter2 = nil collectgarbage("step", 64)

end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end

