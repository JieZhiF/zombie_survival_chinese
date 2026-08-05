-- ============================================================================
-- projectile_arrow/cl_init.lua - 弓箭投射物渲染（客户端）
-- 负责：以红色调绘制箭矢模型，飞行时绘制光晕与拖尾光束；记录最近
--       17 个轨迹点并按需扩展渲染边界，防止拖尾被裁剪
-- ============================================================================
INC_CLIENT()

-- 拖尾光束材质与红色尾迹颜色
local matTrail = Material("trails/physbeam")
local colTrail = Color(255, 20, 20)
-- 飞行光晕材质与白色底色材质
local matGlow = Material("sprites/light_glow02_add")
local matWhite = Material("models/debug/debugwhite")
local vector_origin = vector_origin

-- ==== Draw - 绘制箭矢：红色调模型 + 飞行光晕 + 拖尾光束 ====
function ENT:Draw()
	-- 以深红色纯色绘制箭矢模型（覆盖原材质）
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(0.6, 0.2, 0.2)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	-- 飞行中（速度足够大）时：箭矢朝飞行方向旋转并绘制红色光晕
	if self:GetVelocity():LengthSqr() > 100 then
		self:SetAngles(self:GetVelocity():Angle())

		render.SetMaterial(matGlow)
		render.DrawSprite(self:GetPos(), 15, 2, Color(250, 40, 40))
		render.DrawSprite(self:GetPos(), 2, 30, Color(250, 40, 40))
	end

	-- 依次连接轨迹点绘制拖尾光束，越旧的轨迹段越透明
	render.SetMaterial(matTrail)
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i+1] then
			colTrail.a = 255 - 255 * (i/#self.TrailPositions)

			render.DrawBeam(self.TrailPositions[i], self.TrailPositions[i+1], 7, 1, 0, colTrail)
		end
	end
end

-- ==== Initialize - 初始化轨迹记录状态 ====
function ENT:Initialize()
	-- 延迟 0.15 秒后开始记录轨迹（初始一段无轨迹）
	self.Trailing = CurTime() + 0.15
	self.TrailPositions = {}
	self.CreateTime = CurTime()
end

-- ==== Think - 记录轨迹点并扩展渲染边界覆盖整个拖尾 ====
function ENT:Think()
	-- 最新位置插入队首，超出 17 个点时移除最旧的点
	table.insert(self.TrailPositions, 1, self:GetPos())
	if self.TrailPositions[18] then
		table.remove(self.TrailPositions, 18)
	end

	-- 计算轨迹中最远点到当前位置的距离，据此扩展世界渲染边界
	local dist = 0
	local mypos = self:GetPos()
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i]:DistToSqr(mypos) > dist then
			self:SetRenderBoundsWS(self.TrailPositions[i], mypos, Vector(16, 16, 16))
			dist = self.TrailPositions[i]:DistToSqr(mypos)
		end
	end
end
