-- ============================================================================
-- cl_init.lua - 冰冻炮塔（客户端）：炮管模型 + 冰蓝冷冻激光
-- 负责：炮管模型的附加/转向/显隐控制，以及始终显示的冰蓝激光
--       （仿 gunturret 基类的 BeamColor 机制：炮口射线 + 枪口/命中点光晕）
-- ============================================================================
INC_CLIENT()

local matBeam = Material("trails/laser")
local matGlow = Material("sprites/glow04_noz")

-- ==== Initialize - 客户端初始化：设置光束颜色并附加炮管模型 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 冰冻激光颜色（冰蓝），后续如需变色可在此调整
	self.BeamColor = Color(150, 210, 255, 255)

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

-- ==== DrawTranslucent - 渲染炮管与冰蓝冷冻激光 ====
function ENT:DrawTranslucent()
	if self:GetMaterial() ~= "" then return end

	-- 炮管：根据开火角度旋转并控制显隐
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:ShootPos() + ang:Forward() * -8)
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 冷冻激光：始终从炮口沿炮管方向射出（仿 gunturret 基类）
	local lightpos = self:LightPos()
	local ang = self:GetGunAngles()
	local alpha = self:TransAlphaToMe()

	local owner = self:GetObjectOwner()
	local hasowner = owner:IsValid()
	local hasammo = self:GetAmmo() > 0
	local manualcontrol = self:GetManualControl()

	-- 射线检测激光落点
	local tr = util.TraceLine({
		start = lightpos,
		endpos = lightpos + ang:Forward() * (manualcontrol and 4096 or self.SearchDistance * (hasowner and owner.TurretRangeMul or 1)),
		mask = MASK_SHOT,
		filter = self:GetCachedScanFilter()
	})

	-- 目标完全冻结时激光变亮（白蓝），否则保持冰蓝
	local colBeam = self.BeamColor
	local target = self:GetTarget()
	if target:IsValid() and target:IsPlayer() and target:GetStatus("freeze") and target:GetStatus("freeze"):IsFullyFrozen() then
		colBeam = Color(235, 245, 255, 255)
	end

	if hasowner and hasammo then
		render.SetMaterial(matBeam)
		if alpha > 0.5 then
			render.DrawBeam(lightpos, tr.HitPos, 1 * self.ModelScale, 0, 1, COLOR_WHITE)
		end
		render.DrawBeam(lightpos, tr.HitPos, 4 * self.ModelScale, 0, 1, colBeam)

		render.SetMaterial(matGlow)
		if alpha > 0.5 then
			render.DrawSprite(lightpos, 4 * self.ModelScale, 4 * self.ModelScale, COLOR_WHITE)
		end
		render.DrawSprite(lightpos, 16 * self.ModelScale, 16 * self.ModelScale, colBeam)
		render.DrawSprite(tr.HitPos, 2, 2, COLOR_WHITE)
		render.DrawSprite(tr.HitPos, 8, 8, colBeam)
	else
		render.SetMaterial(matGlow)
		render.DrawSprite(lightpos, 4 * self.ModelScale, 4 * self.ModelScale, COLOR_WHITE)
		render.DrawSprite(lightpos, 16 * self.ModelScale, 16 * self.ModelScale, colBeam)
	end
end

-- ==== OnRemove - 清理：移除炮管模型并停止炮塔音效 ====
function ENT:OnRemove()
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end
