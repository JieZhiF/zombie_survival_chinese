-- ============================================================================
-- prop_gunturret_assault - 突击自动炮塔
-- 负责：定义突击步枪型自动炮塔（weapon_zs_gunturret_assault）的
--       战斗参数（射速/伤害/散布/弹药/生命）；客户端侧创建并挂载
--       双枪管、底座与支架模型，随炮塔瞄准实时旋转，开火时播放音效
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 继承通用自动炮塔基类（索敌、开火、弹药管理等逻辑均在基类实现）
ENT.Base = "prop_gunturret"

-- 关联的部署武器（玩家持有该武器时放置炮塔）
ENT.SWEP = "weapon_zs_gunturret_assault"

-- 弹药类型（ar2 步枪弹）
ENT.AmmoType = "ar2"
-- 两次开火间隔（秒）
ENT.FireDelay = 0.17
-- 每次开火的子弹数（单发）
ENT.NumShots = 1
-- 单发伤害
ENT.Damage = 21
-- 不循环播放开火音效（改用单次音效）
ENT.PlayLoopingShootSound = false
-- 弹道散布（角度）
ENT.Spread = 2
-- 弹药上限
ENT.MaxAmmo = 1200
-- 炮塔生命值
ENT.MaxHealth = 225
-- 每次装填补充的弹药量
ENT.AmmoGivePerUse = 30

-- 客户端专属：炮塔外观模型的创建与渲染
if CLIENT then

-- ==== Initialize - 创建并挂载外观模型 ====
-- 构建两挺枪管、底座与支架共 4 个客户端模型，挂载在炮塔上
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 第一挺枪管（AUG 步枪模型）
	local ent = ClientsideModel("models/weapons/w_rif_aug.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		-- 深灰色贴图与着色
		ent:SetMaterial("phoenix_storms/torpedo")
		ent:SetColor(Color(70, 70, 70))

		-- 缩放矩阵（枪管被压扁拉长的科幻造型）
		matrix = Matrix()
		matrix:Scale(Vector(1.1, 0.9, 0.9))
		ent:EnableMatrix("RenderMultiply", matrix)

		ent:Spawn()
		self.GunAttachment = ent
	end

	-- 第二挺枪管（同一模型，镜像布置）
	ent = ClientsideModel("models/weapons/w_rif_aug.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:SetMaterial("phoenix_storms/torpedo")
		ent:SetColor(Color(70, 70, 70))

		matrix = Matrix()
		matrix:Scale(Vector(1.1, 0.9, 0.9))
		ent:EnableMatrix("RenderMultiply", matrix)

		ent:Spawn()
		self.GunAttachment2 = ent
	end

	-- 炮塔底座（火车站装饰件模型，竖直拉长）
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

	-- 支架（浮标模型，压扁拉高）
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

-- ==== DrawTranslucent - 更新外观模型姿态 ====
-- 每帧让两挺枪管跟随炮塔瞄准方向（±45° 旋转）、底座/支架固定在炮塔上；
-- 炮塔接近隐形或玩家手动控制时隐藏外观
function ENT:DrawTranslucent()
	-- 炮塔透明度过低（隐身形）时隐藏全部外观模型
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	-- 第一挺枪管：位于射击点前方偏右，绕自身轴向旋转 45 度
	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		local gunpos = self:ShootPos() + ang:Forward() * 4 + ang:Right() * 4
		ang:RotateAroundAxis(ang:Forward(), 45)

		atch:SetPos(gunpos)
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 第二挺枪管：对称布置，绕自身轴向旋转 -45 度
	atch = self.GunAttachment2
	if atch and atch:IsValid() then
		local ang = self:GetGunAngles()
		local gunpos = self:ShootPos() + ang:Forward() * 4 + ang:Right() * 4
		ang:RotateAroundAxis(ang:Forward(), -45)

		atch:SetPos(gunpos)
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 底座：固定在炮塔位置，绕竖直轴旋转 180 度
	atch = self.GunBase
	if atch and atch:IsValid() then
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:GetPos())
		atch:SetAngles(ang)

		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 支架：仅随炮塔位置移动
	atch = self.GunBase2
	if atch and atch:IsValid() then
		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	-- 调用基类绘制本体
	self.BaseClass.DrawTranslucent(self)
end

-- ==== OnRemove - 清理外观模型与音效 ====
function ENT:OnRemove()
	-- 移除 4 个挂载的外观模型
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	if self.GunAttachment2 and self.GunAttachment2:IsValid() then
		self.GunAttachment2:Remove()
	end

	if self.GunBase and self.GunBase:IsValid() then
		self.GunBase:Remove()
	end

	if self.GunBase2 and self.GunBase2:IsValid() then
		self.GunBase2:Remove()
	end

	-- 停止扫描/射击循环音效
	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end

end

-- ==== PlayShootSound - 开火音效 ====
-- 同时播放两段枪声（galil 主音 + m4a1 消音音），营造双管齐射感
function ENT:PlayShootSound()
	self:EmitSound("weapons/galil/galil-1.wav", 70, 125, 0.75, CHAN_AUTO)
	self:EmitSound("weapons/m4a1/m4a1_unsil-1.wav", 70, 145, 0.55, CHAN_WEAPON)
end
