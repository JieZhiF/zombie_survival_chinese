-- ============================================================================
-- corrupted_teleport.lua - 腐化传送特效（客户端）
-- 负责：喷射蓝色烟雾粒子营造传送漩涡；若传送目标是本地玩家，额外播放
--       传送音效并触发短暂白屏遮罩；随后在传送点绘制一个随时间扩张、
--       淡出的绿色十字光柱，表现腐化能量撕开空间的传送过程
-- ============================================================================

-- 特效总寿命（秒），使用 RealTime 计时，暂停或卡顿时不会延长效果
EFFECT.LifeTime = 0.25

-- ==== Init - 特效初始化：喷射蓝色烟雾并处理本地玩家传送反馈 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()

	self.DieTime = RealTime() + self.LifeTime

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)
	-- 16 个蓝色烟雾粒子沿随机方向高速飞出，受空气阻力减速，形成漩涡撕扯感
	for i=1, 16 do
		local heading = VectorRand()
		heading:Normalize()

		particle = emitter:Add("particle/smokesprites_0001", pos + heading * 8)
		particle:SetDieTime(math.Rand(0.75, 1.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(8)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-14, 14))
		particle:SetColor(0, 120, 255)
		particle:SetVelocity(heading * math.Rand(128, 256))
		particle:SetAirResistance(256)
	end
	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 传送目标是本地玩家时：播放传送音效并触发 1 秒白屏，掩盖视角跳变
	if ent == MySelf then
		MySelf:EmitSound("ambient/machines/teleport1.wav", 75, 110, 0.8)
		util.WhiteOut(1)
	end
end

-- ==== Think - 特效思考：按 RealTime 在寿命结束前持续渲染 ====
function EFFECT:Think()
	return RealTime() < self.DieTime
end

-- 渲染用的烟雾材质与十字光柱颜色（绿色）
local matGlow = Material("particle/smokesprites_0001")
local colGlow = Color(0, 255, 120)
-- ==== Render - 特效渲染：绘制随时间扩张并淡出的绿色十字光柱 ====
function EFFECT:Render()
	local pos = self.Entity:GetPos()
	-- delta 为剩余寿命占比（1 → 0），驱动光柱大小与透明度
	local delta = math.Clamp((self.DieTime - RealTime()) / self.LifeTime, 0, 1)

	-- 透明度随剩余寿命线性衰减
	colGlow.a = delta * 255

	-- 光柱边长从 36 逐渐扩张到 128，营造传送门撑开感
	local size = 128 - delta * 92

	render.SetMaterial(matGlow)
	-- 六个朝向的四边形构成十字骨架（上下、前后、左右）
	render.DrawQuadEasy(pos, Vector(0, 0, -1), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(0, 0, 1), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(0, -1, 0), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(0, 1, 0), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(-1, 0, 0), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(1, 0, 0), size, size, colGlow)
	-- 中央光点补强核心亮度
	render.DrawSprite(pos, size, size, colGlow)
end
