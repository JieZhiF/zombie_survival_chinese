-- ============================================================================
-- tracer_rico.lua - 跳弹曳光特效（客户端）
-- 负责：记录弹道起点与终点并播放跳弹音效，随后沿弹道绘制一条随剩余
--       时间向终点回缩、宽度脉动的火花光束，表现子弹跳弹瞬间的轨迹
-- ============================================================================

-- 消亡时间（秒），由 Init 初始化为当前时间 + 0.1，即特效总寿命 0.1 秒
EFFECT.DieTime = 0

-- ==== Init - 特效初始化：记录弹道两端并播放跳弹音效 ====
function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Dir = self.EndPos - self.StartPos
	-- 扩大渲染包围盒以覆盖整条弹道，防止光束被视锥裁剪
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

	self.DieTime = CurTime() + 0.1

	-- 播放随机跳弹音效
	sound.Play("weapons/fx/rics/ric"..math.random(5)..".wav", self.StartPos, 73, math.random(100, 110))
end

-- ==== Think - 特效思考：在寿命结束前持续返回 true 保持渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 渲染用的火花光束材质
local matBeam = Material("effects/spark")
-- ==== Render - 特效渲染：绘制回缩且脉动的火花光束 ====
function EFFECT:Render()
	-- fDelta 为剩余寿命占比（1 → 0），光束沿弹道从起点缩回终点
	local fDelta = (self.DieTime - CurTime()) / 0.1
	fDelta = math.Clamp(fDelta, 0, 1)
	-- 正弦波动：让光束位置与宽度跳动，模拟火花飞溅
	local sinWave = math.sin(fDelta * math.pi)

	render.SetMaterial(matBeam)
	-- 光束两端在 fDelta ± 波动范围内收拢，宽度随正弦脉动（2 ~ 10）
	render.DrawBeam(self.EndPos - self.Dir * (fDelta - sinWave * 0.3), self.EndPos - self.Dir * (fDelta + sinWave * 0.3), 2 + sinWave * 8, 1, 0, color_white)
end
