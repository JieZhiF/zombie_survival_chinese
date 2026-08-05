-- ============================================================================
-- cl_init.lua - 动能冲击地雷投射物（客户端）：感应激光束绘制
-- 负责：激活后沿地雷朝上方向绘制光束与发光点，标识感应扫描范围
-- ============================================================================
INC_CLIENT()

-- 光束材质（线状激光）
local matBeam = Material("effects/laser1")
-- 发光点精灵材质
local matGlow = Material("sprites/glow04_noz")
-- 光束主色（橙黄色）
local colBeam = Color(255, 168, 40, 255)
local COLOR_WHITE = color_white
-- 复用的扫描射线参数（使用子弹掩码）
local trace = {mask = MASK_SHOT}
-- ==== DrawTranslucent - 绘制感应光束：每 0.15 秒重新扫描一次落点 ====
function ENT:DrawTranslucent()
	-- 未激活（尚未命中）时不绘制
	if not self:IsActive() then return end

	local pos = self:GetStartPos()
	-- 限制扫描频率，避免每帧执行射线检测
	if CurTime() >= self.NextTrace then
		self.NextTrace = CurTime() + 0.15

		local forward = self:GetUp()
		trace.start = pos
		trace.endpos = pos + forward * self.Range
		trace.filter = self:GetCachedScanFilter()

		self.LastPos = util.TraceLine(trace).HitPos
	end

	local hitpos = self.LastPos
	-- 内层细白光与外层粗橙光的双层光束，突出视觉层次
	render.SetMaterial(matBeam)
	render.DrawBeam(pos, hitpos, 0.33, 0, 1, COLOR_WHITE)
	render.DrawBeam(pos, hitpos, 1.3, 0, 1, colBeam)
	-- 在起点（地雷）与终点（扫描落点）绘制两层发光精灵
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 2, 2, COLOR_WHITE)
	render.DrawSprite(pos, 8, 8, colBeam)
	render.DrawSprite(hitpos, 1, 1, COLOR_WHITE)
	render.DrawSprite(hitpos, 4, 4, colBeam)
end
