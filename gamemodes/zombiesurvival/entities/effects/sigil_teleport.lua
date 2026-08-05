-- ============================================================================
-- sigil_teleport.lua - 法阵传送特效（客户端）
-- 负责：传送触发瞬间在起点爆开蓝色光点粒子，并逐帧绘制六面收缩的
--       光晕立方体；若传送者是自己则额外播放传送音效并触发白屏过渡
-- ============================================================================

-- 特效总时长（秒）：决定光晕收缩速度与粒子消散节奏
EFFECT.LifeTime = 0.25

-- ==== Init - 特效初始化：记录消亡时刻并喷射蓝色光点 ====
function EFFECT:Init(data)
	-- 传送发生的位置与相关实体（通常为使用法阵的玩家）
	local pos = data:GetOrigin()
	local ent = data:GetEntity()

	-- 用引擎实时时钟记录消亡时刻，Think 据此判断特效存活
	self.DieTime = RealTime() + self.LifeTime

	-- 16 个蓝色光点沿随机方向高速飞出并缓慢消散，形成传送光爆
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)
	for i=1, 16 do
		local heading = VectorRand()
		heading:Normalize()

		particle = emitter:Add("sprites/light_glow02_add", pos + heading * 8)
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
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 若传送者是自己：播放传送音效并触发 1 秒白屏遮罩过渡
	if ent == MySelf then
		MySelf:EmitSound("ambient/machines/teleport1.wav", 75, 110, 0.8)
		util.WhiteOut(1)
	end
end

-- ==== Think - 特效存活判定：未到消亡时刻则继续渲染 ====
function EFFECT:Think()
	return RealTime() < self.DieTime
end

-- 蓝色辉光材质与复用颜色对象（Render 中逐帧修改透明度通道）
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(0, 120, 255)
-- ==== Render - 逐帧渲染：六面收缩光立方 + 中心光晕 ====
function EFFECT:Render()
	-- 特效实体位置即传送点位置
	local pos = self.Entity:GetPos()
	-- 剩余时间比例（1 → 0），随特效推进逐渐减小
	local delta = math.Clamp((self.DieTime - RealTime()) / self.LifeTime, 0, 1)

	-- 光晕透明度随时间渐隐
	colGlow.a = delta * 255

	-- 光晕边长从 128 收缩到 36，形成向中心收拢的视觉
	local size = 128 - delta * 92

	-- 在六个轴向上各绘制一张光晕平面，叠加成发光立方体
	render.SetMaterial(matGlow)
	render.DrawQuadEasy(pos, Vector(0, 0, -1), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(0, 0, 1), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(0, -1, 0), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(0, 1, 0), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(-1, 0, 0), size, size, colGlow)
	render.DrawQuadEasy(pos, Vector(1, 0, 0), size, size, colGlow)
	-- 中心再绘制一个光晕精灵，强化传送点的高亮
	render.DrawSprite(pos, size, size, colGlow)
end
