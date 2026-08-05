-- ============================================================================
-- cl_init.lua - 探照灯道具（客户端）：光柱光晕与耐久显示
-- 负责：按视距/视线可见度绘制体积光晕，并显示耐久条与持有者名字
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：扩大渲染边界并准备像素可见性检测 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 128))

	-- 像素可见性句柄（用于遮挡计算）
	self.PixVis = util.GetPixelVisibleHandle()
end

-- ==== SetObjectHealth - 写入耐久（覆盖父类避免客户端触发销毁逻辑） ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- 光晕材质（忽略深度）
local matLight = Material("sprites/light_ignorez")
-- ==== DrawTranslucent - 半透明绘制：视锥内的光柱光晕与耐久面板 ====
function ENT:DrawTranslucent()
	self:DrawModel()

	local epos = self:GetSpotLightPos()
	local LightNrm = self:GetSpotLightAngles():Forward()
	local ViewNormal = epos - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()
	local ViewDot = ViewNormal:Dot( LightNrm * -1 )

	-- 玩家位于光柱照射方向一侧时才绘制光晕
	if ViewDot >= 0 then
		local LightPos = epos + LightNrm * 5

		render.SetMaterial(matLight)
		local Visibile	= util.PixelVisible( LightPos, 16, self.PixVis )

		if not Visibile then return end

		-- 光晕大小随距离与可见度增长，透明度随距离衰减
		local Size = math.Clamp(Distance * Visibile * ViewDot * 1.8, 40, 420)

		Distance = math.Clamp(Distance, 32, 800)
		local Alpha = math.Clamp((1000 - Distance) * Visibile * ViewDot, 0, 100)
		local Col = self:GetColor()
		Col.a = Alpha

		-- 外圈彩色光晕 + 内圈白色高光
		render.DrawSprite(LightPos, Size, Size, Col, Visibile * ViewDot)
		render.DrawSprite(LightPos, Size*0.4, Size*0.4, Color(255, 255, 255, Alpha), Visibile * ViewDot)
	end

	-- 耐久条与持有者名字（3D 面板）
	local name
	local owner = self:GetObjectOwner()
	if owner:IsValidHuman() then
		name = owner:Name()
	end

	cam.Start3D2D(self:LocalToWorld(Vector(self:OBBMaxs().x, 0, 1)), self:LocalToWorldAngles(Angle(180, 270, 180)), 0.05)
		self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name)
	cam.End3D2D()
end
