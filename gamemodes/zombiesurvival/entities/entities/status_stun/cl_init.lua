-- ============================================================================
-- status_stun/cl_init.lua - 眩晕状态实体（客户端）
-- 负责：在玩家头顶渲染快速旋转的红色警示标记（眩晕视觉提示）
-- ============================================================================

INC_CLIENT()

-- 归入半透明渲染组（使用 DrawTranslucent 绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== DrawTranslucent - 半透明绘制 ====
-- 在持有者头顶绘制旋转的红色模型标记，提示其处于眩晕状态
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	-- 强制红色染色并关闭引擎光照（保证标记纯色可见）
	render.SetColorModulation(1, 0, 0)
	render.SuppressEngineLighting(true)

	-- 将标记定位到玩家头顶，并以每秒 500 度的速度旋转
	self:SetRenderOrigin(owner:GetPos() + Vector(0, 0, owner:OBBMaxs().z))
	self:SetRenderAngles(Angle(0, CurTime() * 500, 0))
	self:DrawModel()

	-- 恢复光照与颜色调制
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
end
