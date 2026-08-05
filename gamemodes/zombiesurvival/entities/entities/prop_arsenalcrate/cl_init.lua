-- ============================================================================
-- cl_init.lua - 武器箱道具（客户端）：3D 购买提示与耐久显示
-- 负责：为人类玩家绘制武器箱名称、耐久条、"可购买"闪烁提示与持有者名字
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：扩大渲染边界以完整显示 3D 面板 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 128))
end

-- ==== SetObjectHealth - 写入耐久（覆盖父类避免客户端触发碎裂逻辑） ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- 闪烁提示颜色（绿色呼吸效果）
local colFlash = Color(30, 255, 30)
-- ==== Draw - 绘制：人类视角在箱顶绘制名称/耐久/购买提示面板 ====
function ENT:Draw()
	self:DrawModel()

	-- 仅人类玩家可见面板
	if not MySelf:IsValid() or MySelf:Team() ~= TEAM_HUMAN then return end

	local owner = self:GetObjectOwner()

	local w, h = 600, 420

	cam.Start3D2D(self:LocalToWorld(Vector(1, 0, self:OBBMaxs().z)), self:GetAngles(), 0.05)

		-- 半透明黑底面板
		draw.RoundedBox(64, w * -0.5, h * -0.5, w, h, color_black_alpha120)

		draw.SimpleText(translate.Get("arsenal_crate"), "ZS3D2DFont2", 0, 0, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- 耐久条
		self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1))

		-- 处于可购买阶段时显示闪烁的"现在购买"提示
		if MySelf:Team() == TEAM_HUMAN and GAMEMODE:PlayerCanPurchase(MySelf) then
			colFlash.a = math.abs(math.sin(CurTime() * 5)) * 255
			draw.SimpleText(translate.Get("purchase_now"), "ZS3D2DFont2", 0, 32, colFlash, TEXT_ALIGN_CENTER)
		end

		-- 持有者名字（自己显示蓝色）
		if owner:IsValid() and owner:IsPlayer() then
			draw.SimpleText("("..owner:ClippedName()..")", "ZS3D2DFont2Small", 0, 120, owner == MySelf and COLOR_LBLUE or COLOR_GRAY, TEXT_ALIGN_CENTER)
		end

	cam.End3D2D()
end
