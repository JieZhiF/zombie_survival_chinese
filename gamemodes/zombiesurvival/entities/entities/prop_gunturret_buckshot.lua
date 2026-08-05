-- ============================================================================
-- prop_gunturret_buckshot.lua - 霰弹炮塔（共享/客户端）
-- 负责：继承通用炮塔逻辑，配置霰弹参数，客户端挂载霰弹枪模型并播放开火音效
-- ============================================================================
AddCSLuaFile()

-- 基于通用炮塔实体
ENT.Base = "prop_gunturret"

-- 对应武器 SWEP（炮塔使用的武器类）
ENT.SWEP = "weapon_zs_gunturret_buckshot"

-- 弹药类型：霰弹
ENT.AmmoType = "buckshot"
-- 射击间隔（秒）
ENT.FireDelay = 0.85
-- 每次射击的弹片数量
ENT.NumShots = 7
-- 单发弹片伤害
ENT.Damage = 6.35
-- 是否循环播放射击音效（霰弹为单发音效）
ENT.PlayLoopingShootSound = false
-- 散射角度
ENT.Spread = 5
-- 索敌距离（单位）
ENT.SearchDistance = 225
-- 最大弹药量
ENT.MaxAmmo = 400
-- 每次装填补给给予的弹药量
ENT.AmmoGivePerUse = 20

if CLIENT then

-- ==== Initialize - 客户端初始化：挂载霰弹枪模型 ====
-- 创建客户端模型作为炮管附件，绑定到炮塔上
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 创建霰弹枪客户端模型并作为炮塔的子附件
	local ent = ClientsideModel("models/weapons/w_shotgun.mdl")
	if ent:IsValid() then
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:SetLocalPos(vector_origin)
		ent:SetLocalAngles(angle_zero)
		ent:Spawn()
		self.GunAttachment = ent
	end
end

-- ==== DrawTranslucent - 绘制炮管附件 ====
-- 依据炮塔射击朝向旋转枪口附件，并随炮塔透明/隐藏状态同步
function ENT:DrawTranslucent()
	-- 炮塔过透明时隐藏枪管附件
	local nodrawattachs = self:TransAlphaToMe() < 0.4

	local atch = self.GunAttachment
	if atch and atch:IsValid() then
		-- 将附件对准炮塔射击角度（绕上轴翻转 180 度对准枪口方向）
		local ang = self:GetGunAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		atch:SetPos(self:ShootPos() + ang:Forward() * -8)
		atch:SetAngles(ang)

		-- 透明或本人手动操控时不绘制附件（避免遮挡视角）
		atch:SetNoDraw(nodrawattachs or self:GetObjectOwner() == MySelf and self:GetManualControl())
	end

	self.BaseClass.DrawTranslucent(self)
end

-- ==== OnRemove - 移除时清理附件与音效 ====
function ENT:OnRemove()
	if self.GunAttachment and self.GunAttachment:IsValid() then
		self.GunAttachment:Remove()
	end

	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end

end

-- ==== PlayShootSound - 播放单发霰弹开火音效 ====
function ENT:PlayShootSound()
	self:EmitSound("Weapon_Shotgun.NPC_Single")
end
