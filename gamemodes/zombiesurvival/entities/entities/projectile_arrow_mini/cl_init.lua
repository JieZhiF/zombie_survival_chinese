-- ============================================================================
-- projectile_arrow_mini/cl_init.lua - 迷你箭矢投射物（客户端）
-- 负责：绘制箭矢本体、黄色激光拖尾与呼吸式发光点；记录飞行轨迹
--       用于拖尾渲染，停止飞行后切换为静态绘制
-- ============================================================================
INC_CLIENT()

-- 渲染缓存：拖尾材质/颜色与发光材质
local matTrail = Material("trails/laser")
local colTrail = Color(255, 255, 0)
local matGlow = Material("sprites/light_glow02_add")

local vector_origin = vector_origin

-- ==== Draw - 绘制箭矢模型、激光拖尾与发光点 ====
function ENT:Draw()
	self:DrawModel()

	-- 按轨迹点绘制激光拖尾，越旧的点透明度越低
	render.SetMaterial(matTrail)
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i+1] then
			colTrail.a = 255 - 255 * (i/#self.TrailPositions)

			render.DrawBeam(self.TrailPositions[i], self.TrailPositions[i+1], 6, 1, 0, colTrail)
		end
	end

	-- 箭尖发光点：尺寸随时间脉动（呼吸效果）
	render.SetMaterial(matGlow)
	local size = 5 + (CurTime() * 8.5 % 1) * 20
	render.DrawSprite(self:GetPos(), size, size, Color(250, 210, 70))
end

-- ==== Initialize - 初始化拖尾记录 ====
function ENT:Initialize()
	self.Trailing = CurTime() + 0.25
	self.TrailPositions = {}
end

-- ==== Think - 记录飞行轨迹；箭矢静止后切换为静态绘制 ====
function ENT:Think()
	-- 箭矢静止且过了记录期：停止追踪拖尾，只画模型
	if self:GetVelocity() == vector_origin and self.Trailing < CurTime() then
		-- 覆盖绘制方法：静止后只画模型不再画拖尾
		function self:Draw() self.Entity:DrawModel() end
		-- 覆盖 Think 方法：静止后停止轨迹记录
		function self:Think() end
	else
		-- 每秒记录最新位置到轨迹头部（最多保留 17 个点）
		table.insert(self.TrailPositions, 1, self:GetPos())
		if self.TrailPositions[18] then
			table.remove(self.TrailPositions, 18)
		end

		-- 扩大渲染边界以包含整个拖尾（防止拖尾被裁剪）
		local dist = 0
		local mypos = self:GetPos()
		for i=1, #self.TrailPositions do
			if self.TrailPositions[i]:DistToSqr(mypos) > dist then
				self:SetRenderBoundsWS(self.TrailPositions[i], mypos, Vector(16, 16, 16))
				dist = self.TrailPositions[i]:DistToSqr(mypos)
			end
		end
	end
end
