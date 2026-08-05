-- ============================================================================
-- cl_init.lua - 提托努斯毒针投射物（客户端）：绿色发光渲染与飞行粒子
-- 负责：以绿色自发光模型绘制毒针，飞行中生成短暂绿色光点粒子
-- ============================================================================
INC_CLIENT()

-- 拖尾光晕材质与纯白模型材质
local matGlow = Material("effects/splashwake1")
local matGlow2 = Material("sprites/light_glow02_add")
local matWhite = Material("models/debug/debugwhite")
local vector_origin = vector_origin

-- 粒子生成计时（保留字段，当前版本未使用）
ENT.SmokeTimer = 0

-- ==== Draw - 绘制绿色发光毒针与飞行光点 ====
function ENT:Draw()
	-- 纯白材质 + 绿色调色 + 关闭引擎光照，呈现自发光绿色外观
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(0.1, 0.9, 0.3)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	local pos = self:GetPos()

	-- 仅在毒针飞行（速度非零）时绘制发光与粒子
	if self:GetVelocity() ~= vector_origin then
		-- 绘制两层大小不一的绿色光晕精灵
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 7, 7, Color(30, 155, 70))

		render.SetMaterial(matGlow2)
		render.DrawSprite(pos, 29, 6, Color(90, 255, 130))
		render.DrawSprite(pos, 3, 23, Color(90, 255, 130))

		-- 生成两枚短暂存在的绿色闪光粒子
		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
		local particle
		for i=0, 1 do
			particle = emitter:Add(matGlow2, pos)
			particle:SetVelocity(VectorRand() * 5)
			particle:SetDieTime(0.05)
			particle:SetStartAlpha(175)
			particle:SetEndAlpha(0)
			particle:SetStartSize(5)
			particle:SetEndSize(0)
			particle:SetRollDelta(math.Rand(-10, 10))
			particle:SetColor(50, 255, 110)
		end
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end

-- ==== Initialize - 客户端初始化占位（外观由 Draw 处理） ====
function ENT:Initialize()
end

-- ==== Think - 客户端每帧占位（无额外客户端逻辑） ====
function ENT:Think()
end
