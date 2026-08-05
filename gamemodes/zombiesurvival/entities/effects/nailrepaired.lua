-- ============================================================================
-- nailrepaired.lua - 修钉/修复反馈特效（客户端）
-- 负责：在修复位置沿表面法线喷射光点——修复成功时显示绿色光点且大小
--       随修复量缩放，修复失败时显示红色光点，直观反馈修复结果
-- ============================================================================

-- ==== Init - 特效初始化：根据修复状态喷射绿/红反馈光点 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local magnitude = data:GetMagnitude()

	-- 修复量为 0 表示本次修复失败
	local norepair = data:GetMagnitude() == 0

	local emitter = ParticleEmitter(pos)

	-- 随机喷发 16~24 颗光点：沿法线方向（叠加随机偏移）低速飘散
	for i=1, math.random(16, 24) do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetVelocity((norm + VectorRand()):GetNormalized() * math.Rand(8, 24))
		particle:SetAirResistance(8)
		-- 修复失败：红色小光点；修复成功：绿色光点，尺寸随修复量增大
		if norepair then
			particle:SetColor(255, 0, 0)
			particle:SetEndSize(2)
		else
			particle:SetColor(0, 255, 0)
			particle:SetEndSize(math.Rand(2, 3) * math.max(magnitude, 0.1))
		end
		particle:SetDieTime(math.Rand(0.2, 0.5))
		particle:SetStartSize(0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
	end

	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 特效思考：一次性爆发特效，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由粒子系统自动绘制 ====
function EFFECT:Render()
end
