-- ============================================================================
-- tracer_heph_alt.lua - 赫菲斯托斯替换曳光特效（客户端）
-- 负责：记录弹道起点与终点并播放高音调跳弹音效，随后绘制多层绿色
--       激光束——5 条细束叠加 1 条粗束辉光，透明度随剩余寿命衰减，
--       表现能量弹道留下的残影
-- ============================================================================

-- 消亡时间（秒），由 Init 初始化为当前时间 + 0.5，即特效总寿命 0.5 秒
EFFECT.DieTime = 0

-- ==== Init - 特效初始化：记录弹道两端并播放高音调跳弹音效 ====
function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Dir = self.EndPos - self.StartPos
	-- 扩大渲染包围盒以覆盖整条弹道，防止光束被视锥裁剪
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

	self.DieTime = CurTime() + 0.5

	-- 播放随机跳弹音效，音调偏高表现能量武器的尖锐感
	sound.Play("weapons/fx/rics/ric"..math.random(5)..".wav", self.StartPos, 73, math.random(140, 150))
end

-- ==== Think - 特效思考：在寿命结束前持续返回 true 保持渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 渲染用的绿色激光材质
local beammat = Material("trails/laser")
-- ==== Render - 特效渲染：绘制多层绿色光束并随时间淡出 ====
function EFFECT:Render()
	-- 随机纹理坐标起点，让每次光束纹理相位不同
	local texcoord = math.Rand(0, 1)
	-- alpha 即剩余寿命（秒，0.5 → 0），同时充当透明度系数
	local alpha = self.DieTime - CurTime()
	-- 光束两端距离 × 剩余寿命，决定纹理滚动区间（随光束缩短而收窄）
	local norm = (self.StartPos - self.EndPos) * alpha
	local nlen = norm:Length()

	render.SetMaterial(beammat)

	-- 5 条宽度 4 的细光束叠加成主光束，增强激光强度感
	for i = 1, 5 do
		render.DrawBeam(self.StartPos, self.EndPos, 4, texcoord, texcoord + nlen / 128, Color(115, 210, 50, 255 * alpha))
	end
	-- 最后绘制一条宽度 14 的半透明粗光束作为外层辉光
	render.DrawBeam(self.StartPos, self.EndPos, 14, texcoord, texcoord + nlen / 128, Color(115, 210, 50, 170 * alpha))
end
