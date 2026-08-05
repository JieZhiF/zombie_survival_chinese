-- ============================================================================
-- cl_init.lua - 混沌之箭投射物（客户端）：蓝色染色、发光与拖尾绘制
-- 负责：以蓝色渲染箭矢，高速飞行时发光，并绘制由历史位置构成的拖尾
-- ============================================================================
INC_CLIENT()

-- 拖尾光束材质与颜色（淡蓝色，透明度渐变）
local matTrail = Material("trails/physbeam")
local colTrail = Color(140, 190, 250)
-- 发光点材质
local matGlow = Material("sprites/light_glow02_add")
-- 纯白材质（配合染色绘制）
local matWhite = Material("models/debug/debugwhite")
local vector_origin = vector_origin

-- ==== Draw - 绘制：蓝色染色模型、高速发光点与拖尾光束 ====
function ENT:Draw()
	-- 以纯白材质覆盖后染成淡蓝色绘制本体
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(0.5, 0.7, 1)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	-- 高速飞行时：朝向速度方向并点亮发光点
	if self:GetVelocity():LengthSqr() > 100 then
		self:SetAngles(self:GetVelocity():Angle())

		render.SetMaterial(matGlow)
		render.DrawSprite(self:GetPos(), 11, 11, Color(140, 190, 250))
	end

	-- 依次连接拖尾历史位置，透明度随距离衰减
	render.SetMaterial(matTrail)
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i+1] then
			colTrail.a = 255 - 255 * (i/#self.TrailPositions)

			render.DrawBeam(self.TrailPositions[i], self.TrailPositions[i+1], 3, 1, 0, colTrail)
		end
	end
end

-- ==== Initialize - 初始化：延迟记录拖尾并清空位置历史 ====
function ENT:Initialize()
	self.Trailing = CurTime() + 0.15
	self.TrailPositions = {}
end

-- ==== Think - 每帧更新：记录当前位置到拖尾历史（最多 11 段）并扩展渲染范围 ====
function ENT:Think()
	table.insert(self.TrailPositions, 1, self:GetPos())
	if self.TrailPositions[1] then
		table.remove(self.TrailPositions, 12)
	end

	-- 根据拖尾最远点扩展渲染边界，避免拖尾被视锥剔除
	local dist = 0
	local mypos = self:GetPos()
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i]:DistToSqr(mypos) > dist then
			self:SetRenderBoundsWS(self.TrailPositions[i], mypos, Vector(16, 16, 16))
			dist = self.TrailPositions[i]:DistToSqr(mypos)
		end
	end
end
