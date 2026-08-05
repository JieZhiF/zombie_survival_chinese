-- ============================================================================
-- cl_init.lua - 感应地雷投射物（客户端）：感应激光与发光绘制
-- 负责：激活后沿扫描方向绘制激光束与两端发光点，指示感应范围
-- ============================================================================
INC_CLIENT()

-- 与普通实体同组渲染（需要同时参与普通与半透明绘制）
ENT.RenderGroup = RENDERGROUP_BOTH
-- 缓存最近一次激光命中点
ENT.LastPos = Vector(0, 0, 0)
-- 射线扫描节流时间
ENT.NextTrace = 0

-- ==== Initialize - 初始化：扩大渲染包围盒以容纳激光绘制 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-self.Range, -self.Range, -self.Range), Vector(self.Range, self.Range, self.Range))
end

-- ==== Draw - 普通绘制：绘制地雷模型 ====
function ENT:Draw()
	self:DrawModel()
end

-- 激光束/发光点材质与配色
local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
local colBeam = Color(80, 80, 255, 255)
local colAlt = Color(80, 255, 120, 255)
local COLOR_WHITE = color_white
-- 复用射线参数表（遮罩为可命中世界与实体）
local trace = {mask = MASK_SHOT}
-- ==== DrawTranslucent - 半透明绘制：感应激光与端点发光 ====
function ENT:DrawTranslucent()
	-- 未激活时不做任何绘制
	if not self:IsActive() then return end

	-- GetDTBool(0) 为"焚毁强化"分支标记：true 时改为短距感应（绿色激光）
	local alt = self:GetDTBool(0)
	local beamcol = alt and colAlt or colBeam

	local pos = self:GetStartPos()
	-- 按节流间隔重新扫描，记录激光命中点
	if CurTime() >= self.NextTrace then
		self.NextTrace = CurTime() + 0.15

		local forward = self:GetForward()
		trace.start = pos
		-- 焚毁强化分支的感应激光更短
		trace.endpos = pos + forward * (alt and 64 or self.Range)
		trace.filter = self:GetCachedScanFilter()

		self.LastPos = util.TraceLine(trace).HitPos
	end

	-- 绘制内外双层激光束与起止发光点
	local hitpos = self.LastPos
	render.SetMaterial(matBeam)
	render.DrawBeam(pos, hitpos, 0.33, 0, 1, COLOR_WHITE)
	render.DrawBeam(pos, hitpos, 1.3, 0, 1, beamcol)
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 2, 2, COLOR_WHITE)
	render.DrawSprite(pos, 8, 8, beamcol)
	render.DrawSprite(hitpos, 1, 1, COLOR_WHITE)
	render.DrawSprite(hitpos, 4, 4, beamcol)
end
