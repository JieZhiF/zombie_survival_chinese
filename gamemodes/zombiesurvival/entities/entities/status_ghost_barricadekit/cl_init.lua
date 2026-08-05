-- ============================================================================
-- cl_init.lua - 路障工具放置虚影（客户端）：半透明有效性着色
-- 负责：每帧刷新放置有效性，按合法/非法分别以绿色/红色半透明渲染
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组（在普通模型之后绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Think - 每帧刷新放置有效性 ====
function ENT:Think()
	self:RecalculateValidity()

	self:NextThink(CurTime())
	return true
end

-- ==== DrawTranslucent - 半透明绘制：合法绿/非法红 ====
function ENT:DrawTranslucent()
	cam.Start3D(EyePos(), EyeAngles())
		render.SuppressEngineLighting(true)
		-- 合法放置：75% 透明度绿色；非法放置：50% 透明度红色
		if self:GetValidPlacement() then
			render.SetBlend(0.75)
			render.SetColorModulation(0, 1, 0)
		else
			render.SetBlend(0.5)
			render.SetColorModulation(1, 0, 0)
		end

		self:DrawModel()

		-- 恢复默认渲染状态
		render.SetBlend(1)
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	cam.End3D()
end
