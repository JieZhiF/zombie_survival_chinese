-- ============================================================================
-- status_ghost_messagebeacon - 讯息信标放置幽灵预览状态实体（客户端）
-- 负责：每帧刷新放置合法性，并以绿色/红色半透明线框模型绘制放置预览
-- ============================================================================
INC_CLIENT()

-- 渲染组：透明实体
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Think - 每帧刷新放置合法性（NextThink 设为本帧保证逐帧执行） ====
function ENT:Think()
	self:RecalculateValidity()

	self:NextThink(CurTime())
	return true
end

-- ==== DrawTranslucent - 以 1/3 缩放的线框模型绘制预览：可放置为绿色高亮，不可放置为红色半透明 ====
function ENT:DrawTranslucent()
	self:SetModelScale(0.333, 0)

	cam.Start3D(EyePos(), EyeAngles())
		render.SuppressEngineLighting(true)
		-- 可放置：绿色高亮；不可放置：红色半透明
		if self:GetValidPlacement() then
			render.SetBlend(0.75)
			render.SetColorModulation(0, 1, 0)
		else
			render.SetBlend(0.5)
			render.SetColorModulation(1, 0, 0)
		end

		self:DrawModel()

		-- 还原透明度与颜色调制
		render.SetBlend(1)
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	cam.End3D()
end
