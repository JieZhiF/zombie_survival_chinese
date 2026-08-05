-- ============================================================================
-- status_arsenalpack - 军械包（Arsenal Pack）状态实体（客户端）
-- 负责：将军械包模型绑定到持有者背部骨骼跟随移动，并按设置绘制 3D2D 的"军械箱"标签
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化模型缩放与渲染包围盒 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(0.4, 0)

	self:SetRenderBounds(Vector(-26, -26, -26), Vector(26, 26, 45))
end

-- ==== Draw - 跟随持有者 Spine2 骨骼摆放模型，必要时绘制 3D2D 标签 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 持有者无效，或持有者为本地玩家且未开启显示自身模型时跳过绘制
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end

	local boneid = owner:LookupBone("ValveBiped.Bip01_Spine2")
	if not boneid or boneid <= 0 then return end

	local bonepos, boneang = owner:GetBonePositionMatrixed(boneid)

	-- 将实体摆放到背部骨骼位置，旋转角度以贴合角色背部
	self:SetPos(bonepos + boneang:Forward() + boneang:Right() * 4)
	boneang:RotateAroundAxis(boneang:Right(), 270)
	boneang:RotateAroundAxis(boneang:Forward(), 90)
	self:SetAngles(boneang)

	local shadowman = owner.ShadowMan
	local hidepacks = not GAMEMODE.HidePacks

	-- 隐藏背包模式且持有者为影人时，将模型混合设为全透明
	if hidepacks and shadowman then
		render.SetBlend(0)
	end

	self:DrawModel()

	if hidepacks and shadowman then
		render.SetBlend(1)
	end

	-- 非隐藏模式下，在模型上方绘制 3D2D 的"军械箱"标签（圆角底框 + 居中文字）
	if not hidepacks or not shadowman then
		local w, h = 420, 200
		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, self:OBBMaxs().z)), self:GetAngles(), 0.025)
			draw.RoundedBox(64, w * -0.5, h * -0.5, w, h, color_black_alpha120)
			draw.SimpleText(translate.Get("arsenal_crate"), "ZS3D2DFont2", 0, 0, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end
