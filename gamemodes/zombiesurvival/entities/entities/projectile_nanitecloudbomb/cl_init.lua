-- ============================================================================
-- projectile_nanitecloudbomb/cl_init.lua - 纳米云炸弹投射物实体（客户端）
-- 负责：渲染炸弹模型的紫色调色、青色光晕与向外扩散的纳米粒子云
-- ============================================================================

INC_CLIENT()

-- 归入半透明渲染组（使用 DrawTranslucent 绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-- 粒子发射节流时间戳
ENT.NextEmit = 0

-- 光晕用材质
local matGlow = Material("sprites/light_glow02_add")

-- ==== DrawTranslucent - 半透明绘制 ====
-- 以紫红色调绘制模型，叠加青色光晕，并周期性喷出纳米粒子
function ENT:DrawTranslucent()
	-- 给炸弹模型施加紫红色调染色
	render.SetColorModulation(0.7, 0.2, 0.4)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)

	-- 炸弹中心绘制青色光晕
	render.SetMaterial(matGlow)
	render.DrawSprite(self:GetPos(), 64, 64, COLOR_CYAN)

	-- 每 0.09 秒生成 10 个向外扩散的蓝白色纳米粒子
	if CurTime() >= self.NextEmit then
		local pos = self:GetPos()
		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)

		for i=1, 10 do
			local dir = VectorRand():GetNormalized()
			local particle = emitter:Add("sprites/glow04_noz", pos)
			particle:SetDieTime(math.Rand(1.3, 2.1))
			particle:SetColor(145,155,255)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(15)
			particle:SetEndSize(0)
			particle:SetGravity(dir * -6)
			particle:SetVelocity(dir * 5)
		end

		-- 结束发射器并手动触发垃圾回收释放资源
		emitter:Finish() emitter = nil collectgarbage("step", 64)

		self.NextEmit = CurTime() + 0.09
	end
end
