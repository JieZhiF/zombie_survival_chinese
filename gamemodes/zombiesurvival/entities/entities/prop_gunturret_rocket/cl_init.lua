-- ============================================================================
-- prop_gunturret_rocket/cl_init.lua - 火箭炮塔（客户端）
-- 负责：创建炮管/底座客户端模型并随炮塔同步姿态；半透明或手动控制时隐藏
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 客户端初始化：装配炮管与双层底座模型 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 炮管模型：火箭发射器，缩放为细长管状并附深灰色材质
	local ent, matrix = ClientsideModel("models/weapons/w_rocket_launcher.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:SetMaterial("phoenix_storms/torpedo")
		ent:SetColor(Color(150, 150, 150))

		-- 沿 Z 轴拉长 2 倍、横向压缩，模拟炮管外形
		matrix = Matrix()
		matrix:Scale(Vector(0.9, 2, 2))
		ent:EnableMatrix("RenderMultiply", matrix)

		ent:Spawn()
		self.GunAttachment = ent
	end

	-- 下层底座模型：车站装饰件，灰色并缩放为扁圆基座
	ent = ClientsideModel("models/props_trainstation/trainstation_ornament002.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:SetMaterial("phoenix_storms/torpedo")
		ent:SetColor(Color(100, 100, 100))

		matrix = Matrix()
		matrix:Scale(Vector(0.65, 0.65, 1.5))
		ent:EnableMatrix("RenderMultiply", matrix)

		ent:Spawn()
		self.GunBase = ent
	end

	-- 上层底座模型：浮标，细长圆柱，作为炮塔中心支柱
	ent = ClientsideModel("models/props_wasteland/buoy01.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:SetMaterial("phoenix_storms/torpedo")
		ent:SetColor(Color(100, 100, 100))

		matrix = Matrix()
		matrix:Scale(Vector(0.25, 0.15, 0.7))
		ent:EnableMatrix("RenderMultiply", matrix)

		ent:Spawn()
		self.GunBase2 = ent
	end
end

-- ==== DrawTranslucent - 半透明绘制：同步炮管指向与底座位置 ====
function ENT:DrawTranslucent()
	-- 炮塔整体透明度过低（拆解/建造中）时隐藏所有部件
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	-- 炮管：跟随射击方向角，并偏移到枪口后方（贴近基座）
	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:ShootPos() + ang:Forward() * -8 + ang:Right() * 1 + ang:Up() * -5)
		atch:SetAngles(ang)

		-- 自己手动控制的炮塔也隐藏部件（避免遮挡视角）
		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 下层底座：跟随炮塔本体位置与朝向
	atch = self.GunBase
	if atch and atch:IsValid() then
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:GetPos())
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 上层底座：仅同步显隐，位置由父级自动跟随
	atch = self.GunBase2
	if atch and atch:IsValid() then
		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	self.BaseClass.DrawTranslucent(self)
end

-- ==== OnRemove - 移除时清理客户端模型与循环音效 ====
function ENT:OnRemove()
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	if self.GunBase and self.GunBase:IsValid() then
		self.GunBase:Remove()
	end

	if self.GunBase2 and self.GunBase2:IsValid() then
		self.GunBase2:Remove()
	end

	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end
