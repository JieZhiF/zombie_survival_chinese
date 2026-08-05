-- ============================================================================
-- prop_ffemitter - 力场发射器实体（客户端）
-- 负责：绘制发射器模型，并在其上方渲染弹药数量、拥有者名字与血量条的 3D2D 信息面板
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 扩大渲染边界，确保力场区域完整可见 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 128))
end

-- ==== SetObjectHealth - 将服务端血量同步到网络变量 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- 3D2D 信息面板相对发射器的位置偏移与角度偏移
local vOffset = Vector(-1, 0, 8)
local aOffset = Angle(180, 90, 90)

-- ==== RenderInfo - 在指定位置绘制 3D2D 信息面板：弹药数（或空弹药提示）与血量条、拥有者名字 ====
function ENT:RenderInfo(pos, ang, owner)
	local ammo = self:GetAmmo()

	cam.Start3D2D(pos, ang, 0.075)
		local name = ""
		if owner:IsValid() and owner:IsPlayer() then
			name = owner:ClippedName()
		end

		-- 有弹药时显示弹药余量，否则显示"空"红色提示
		if ammo > 0 then
			draw.SimpleTextBlurry("["..ammo.." / "..self.MaxAmmo.."]", "ZS3D2DFontSmall", 0, 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleTextBlurry(translate.Get("empty"), "ZS3D2DFontSmall", 0, 120, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- 绘制血量条（按当前血量比例）
		self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name)
	cam.End3D2D()
end

-- ==== Draw - 绘制模型；人类玩家视角下额外叠加弹药与血量信息面板 ====
function ENT:Draw()
	self:DrawModel()

	if not MySelf:IsValid() or MySelf:Team() ~= TEAM_HUMAN then return end

	local owner = self:GetObjectOwner()
	local ang = self:LocalToWorldAngles(aOffset)

	self:RenderInfo(self:LocalToWorld(vOffset), ang, owner)
end
