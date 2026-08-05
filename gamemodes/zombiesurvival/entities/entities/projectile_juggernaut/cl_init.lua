-- ============================================================================
-- cl_init.lua - 重装兵投射物（客户端）
-- 负责：半透明绘制模型、按历史轨迹绘制红色拖尾光束，并在静止后转为普通模型渲染
-- ============================================================================
INC_CLIENT()

-- 拖尾光束材质（红色）与中心发光材质
local matTrail = Material("trails/physbeam")
local colTrail = Color(230, 35, 45)
local matGlow = Material("sprites/light_glow02_add")

local vector_origin = vector_origin

-- ==== Draw - 自定义绘制 ====
-- 半透明绘制模型，沿轨迹点绘制渐隐拖尾光束，并在中心绘制发光点
function ENT:Draw()
	-- 模型半透明渲染
	render.SetBlend(0.4)
	self:DrawModel()
	render.SetBlend(1)

	-- 按轨迹点依次绘制拖尾光束，越旧的段越透明
	render.SetMaterial(matTrail)
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i+1] then
			colTrail.a = 255 - 255 * (i/#self.TrailPositions)

			render.DrawBeam(self.TrailPositions[i], self.TrailPositions[i+1], 5, 1, 0, colTrail)
		end
	end

	-- 中心发光点
	local pos = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 5, 5, Color(230, 55, 35))
end

-- ==== Initialize - 初始化轨迹记录 ====
-- 记录首次记录轨迹的时刻，并初始化轨迹点表
function ENT:Initialize()
	self.Trailing = CurTime() + 0.25
	self.TrailPositions = {}
end

-- ==== Think - 记录飞行轨迹 ====
-- 飞行中把最新位置插入轨迹表头（保留 15 个点）；静止超过 0.25 秒后改为普通模型绘制
function ENT:Think()
	-- 已静止：恢复默认绘制与思考，不再记录轨迹
	if self:GetVelocity() == vector_origin and self.Trailing < CurTime() then
		function self:Draw() self.Entity:DrawModel() end
		function self:Think() end
	else
		-- 轨迹表头插入当前位置，超出 15 个点时移除最旧点
		table.insert(self.TrailPositions, 1, self:GetPos())
		if self.TrailPositions[16] then
			table.remove(self.TrailPositions, 16)
		end

		-- 依据离当前位置最远的轨迹点动态扩展渲染包围盒，保证拖尾可见
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
