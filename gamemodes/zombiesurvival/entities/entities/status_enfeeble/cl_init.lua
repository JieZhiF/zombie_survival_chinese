-- ============================================================================
-- status_enfeeble/cl_init.lua - 虚弱状态（客户端）
-- 负责：在拥有者头顶渲染旋转的红色内脏特效模型；把拥有者玩家模型
--       染成红色并施加运动模糊屏幕特效，余量随状态剩余时间衰减
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组（特效模型需要混合绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== DrawTranslucent - 绘制旋转的红色内脏特效模型 ====
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	-- 红色染色 + 按剩余强度控制透明度 + 禁用引擎光照（纯色渲染）
	render.SetColorModulation(1, 0, 0)
	render.SetBlend(self:GetPower() * 0.95)
	render.SuppressEngineLighting(true)

	-- 特效模型悬浮于拥有者头顶并上下浮动，随时间绕 Y 轴旋转
	self:SetRenderOrigin(owner:GetPos() + Vector(0, 0, owner:OBBMaxs().z + math.abs(math.sin(CurTime() * 2)) * 4))
	self:SetRenderAngles(Angle(0, CurTime() * 270, 0))
	self:DrawModel()

	-- 恢复渲染状态
	render.SuppressEngineLighting(false)
	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)
end

-- ==== PrePlayerDraw - 绘制拥有者前把玩家模型染成红色（带闪烁） ====
function ENT:PrePlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	-- 红色基调并随时间轻微闪烁（0.8~1.0）
	local r = 1 - math.abs(math.sin((CurTime() + self:EntIndex()) * 3)) * 0.2
	render.SetColorModulation(r, 0.1, 0.1)
end

-- ==== PostPlayerDraw - 绘制完成后还原玩家模型颜色 ====
function ENT:PostPlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	render.SetColorModulation(1, 1, 1)
end

-- ==== GetPower - 状态剩余强度（0~1，随时间线性衰减） ====
function ENT:GetPower()
	return math.Clamp(self:GetStartTime() + self:GetDuration() - CurTime(), 0, 1)
end

-- ==== RenderScreenspaceEffects - 状态拥有者视角施加运动模糊特效 ====
function ENT:RenderScreenspaceEffects()
	-- 只对状态拥有者自己生效
	if MySelf ~= self:GetOwner() then return end

	DrawMotionBlur(0.1, self:GetPower() * 0.3, 0.01)
end
