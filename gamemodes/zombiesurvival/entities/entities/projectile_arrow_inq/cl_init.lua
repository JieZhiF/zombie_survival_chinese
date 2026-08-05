-- ============================================================================
-- projectile_arrow_inq/cl_init.lua - 审判者之箭投射物（客户端）
-- 负责：绘制箭矢模型、飞行时的发光点与拖尾光束特效；
--       记录历史轨迹点并据此扩展渲染边界，防止投射物提前被裁剪
-- ============================================================================

-- 客户端加载入口（INC_CLIENT 系列约定写法）
INC_CLIENT()

-- 拖尾光束材质
local matTrail = Material("trails/laser")
-- 发光点材质
local matGlow = Material("sprites/light_glow02_add")
-- 缓存零向量
local vector_origin = vector_origin

-- ==== Draw - 绘制箭矢与拖尾特效 ====
function ENT:Draw()
	self:DrawModel()
	-- 读取替代射击标记（重击蓄力箭为偏橙色调）
	local alt = self:GetDTBool(0)
	local col = Color(250, alt and 230 or 178, alt and 170 or 70)

	-- 飞行中（速度较快）时调整朝向并绘制发光点
	if self:GetVelocity():LengthSqr() > 100 then
		self:SetAngles(self:GetVelocity():Angle())

		render.SetMaterial(matGlow)
		render.DrawSprite(self:GetPos(), 10, 10, col)
	end

	-- 依次连接历史轨迹点绘制光束拖尾，越旧的点越透明
	render.SetMaterial(matTrail)
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i+1] then
			col.a = 255 - 255 * (i/#self.TrailPositions)

			render.DrawBeam(self.TrailPositions[i], self.TrailPositions[i+1], 2, 1, 0, col)
		end
	end
end

-- ==== Initialize - 客户端初始化 ====
function ENT:Initialize()
	-- 拖尾记录开始时刻
	self.Trailing = CurTime() + 0.15
	-- 历史轨迹点数组
	self.TrailPositions = {}
end

-- ==== Think - 每帧记录轨迹点并扩展渲染边界 ====
function ENT:Think()
	-- 最新位置插入队首，最多保留 11 个点
	table.insert(self.TrailPositions, 1, self:GetPos())
	if self.TrailPositions[12] then
		table.remove(self.TrailPositions, 12)
	end

	-- 遍历所有轨迹点，将渲染边界扩展到最远的点，保证拖尾完整可见
	local dist = 0
	local mypos = self:GetPos()
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i]:DistToSqr(mypos) > dist then
			self:SetRenderBoundsWS(self.TrailPositions[i], mypos, Vector(16, 16, 16))
			dist = self.TrailPositions[i]:DistToSqr(mypos)
		end
	end
end
