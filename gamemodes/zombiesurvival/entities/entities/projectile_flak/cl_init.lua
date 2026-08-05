-- ============================================================================
-- projectile_flak/cl_init.lua - 防空炮弹（高射炮）投射物（客户端）
-- 负责：以橙色自发光材质渲染弹体；飞行时绘制光点与逐段渐隐的
--       激光尾迹（最多记录 6 段轨迹，自动扩展渲染包围盒）
-- ============================================================================
INC_CLIENT()

-- 尾迹激光材质与橙色
local matTrail = Material("trails/laser")
local colTrail = Color(255, 205, 120)
-- 飞行光点与白色替代材质
local matGlow2 = Material("sprites/glow04_noz")
local matWhite = Material("models/debug/debugwhite")
local vector_origin = vector_origin

-- ==== Draw - 渲染：白色自发光弹体 + 飞行光点 + 渐隐尾迹光束 ====
function ENT:Draw()
	-- 用白色材质覆盖模型并关闭引擎光照，实现自发光效果
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(0.7, 0.5, 0.2)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	-- 弹体仍在飞行时绘制橙色光点
	if self:GetVelocity() ~= vector_origin then
		render.SetMaterial(matGlow2)
		render.DrawSprite(self:GetPos(), 10, 10, Color(255, 205, 100, 18))
	end

	-- 沿轨迹点绘制光束，越旧的段落透明度越低
	render.SetMaterial(matTrail)
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i+1] then
			colTrail.a = 255 - 255 * (i/#self.TrailPositions)

			render.DrawBeam(self.TrailPositions[i], self.TrailPositions[i+1], 5, 1, 0, colTrail)
		end
	end
end

-- ==== Initialize - 初始化：准备尾迹记录（0.1 秒后开始记录） ====
function ENT:Initialize()
	self.Trailing = CurTime() + 0.1
	self.TrailPositions = {}
end

-- ==== Think - 尾迹更新：每帧记录当前位置并扩展渲染包围盒 ====
function ENT:Think()
	-- 将当前位置插入轨迹列表头部，超出 6 段则丢弃最旧的
	table.insert(self.TrailPositions, 1, self:GetPos())
	if self.TrailPositions[1] then
		table.remove(self.TrailPositions, 7)
	end

	-- 以最远轨迹点为界扩展渲染包围盒，防止尾迹被裁剪
	local dist = 0
	local mypos = self:GetPos()
	for i=1, #self.TrailPositions do
		if self.TrailPositions[i]:DistToSqr(mypos) > dist then
			self:SetRenderBoundsWS(self.TrailPositions[i], mypos, Vector(16, 16, 16))
			dist = self.TrailPositions[i]:DistToSqr(mypos)
		end
	end
end
