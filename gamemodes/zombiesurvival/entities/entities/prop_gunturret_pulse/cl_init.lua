-- ============================================================================
-- cl_init.lua - 脉冲炮塔（客户端）：附加步枪模型作炮管，渲染时对齐开火方向
-- 负责：炮管模型的附加/转向/显隐控制，以及移除时的模型与音效清理
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 客户端初始化：附加步枪模型作为炮管 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	local ent = ClientsideModel("models/weapons/w_IRifle.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:Spawn()
		self.GunAttachment = ent
	end
end

-- ==== DrawTranslucent - 渲染炮管：根据开火角度旋转并控制显隐 ====
function ENT:DrawTranslucent()
	-- 自身接近透明（隐身/虚影）时也隐藏炮管
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		-- 绕自身上方轴旋转 180 度，使枪口朝向开火方向
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:ShootPos() + ang:Forward() * -8)
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	self.BaseClass.DrawTranslucent(self)
end

-- ==== OnRemove - 清理：移除炮管模型并停止炮塔音效 ====
function ENT:OnRemove()
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end