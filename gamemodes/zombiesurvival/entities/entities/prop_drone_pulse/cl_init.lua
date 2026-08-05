-- ============================================================================
-- prop_drone_pulse/cl_init.lua - 脉冲无人机炮塔（客户端）
-- 负责：扫描音效与附加步枪模型（武器外观），并对准炮塔射击方向
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：渲染边界、环境音效、视角钩子与武器模型 ====
function ENT:Initialize()
	-- 扩大渲染边界，保证旋转/缩放动画完整显示
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 72))

	-- 创建并立即播放扫描循环音效
	self.AmbientSound = CreateSound(self, "npc/scanner/scanner_scan_loop2.wav")
	self.AmbientSound:Play()

	-- 像素可见性句柄：供基类警告灯遮挡检测使用
	self.PixVis = util.GetPixelVisibleHandle()

	-- 注册输入重映射、本地玩家绘制与相机视角钩子（控制模式下生效）
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
	hook.Add("CalcView", self, self.CalcView)

	-- 附加步枪模型作为炮塔武器外观
	local ent, matrix = ClientsideModel("models/weapons/w_IRifle.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		-- 覆盖材质为深色金属并染灰，模拟无人机枪械
		ent:SetMaterial("phoenix_storms/torpedo")
		ent:SetColor(Color(150, 150, 150))

		-- 非等比缩放模型（拉长枪身，压扁截面）
		matrix = Matrix()
		matrix:Scale(Vector(0.9, 0.65, 0.65))
		ent:EnableMatrix("RenderMultiply", matrix)

		ent:Spawn()
		-- 保存武器模型引用，绘制阶段使用
		self.GunAttachment = ent
	end
end

-- ==== Think - 每帧更新扫描音效：音调随飞行速度升高 ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.5, math.Clamp(75 + self:GetVelocity():Length() * 0.5, 75, 150))
end

-- ==== DrawTranslucent - 调整武器模型朝向炮口方向，再调用基类绘制 ====
function ENT:DrawTranslucent()
	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		-- 将武器模型摆放在炮口（红光位）前方的固定偏移处
		atch:SetPos(self:GetRedLightPos() + ang:Forward() * -12 + ang:Right() * 1 + ang:Up() * -5)
		atch:SetAngles(ang)

		-- 控制模式下隐藏武器模型（避免遮挡第一视角视野）
		atch:SetNoDraw(self:GetObjectOwner() == MySelf and self:BeingControlled())
	end

	self.BaseClass.DrawTranslucent(self)
end

-- ==== OnRemove - 移除时停止扫描音效并清理武器模型 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()

	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end
end
