-- ============================================================================
-- weapon_zs_dronecontrol.lua - 无人机遥控器（Drone Control）
-- 负责：定义无人机控制器的槽位属性、无人机存活检测、模式切换音效
-- ============================================================================

AddCSLuaFile()

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_dronecontrol")
SWEP.Description = ""..translate.Get("weapon_zs_dronecontrol_description")

-- 武器在武器选择栏中的槽位序号
SWEP.SlotPos = 0

if CLIENT then
	-- 武器栏槽位（归类为部署物分类），减少手持晃动与摆动
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
	SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
	SWEP.BobScale = 0.5
	SWEP.SwayScale = 0.5
end

-- 第一人称与第三人称模型（使用 SLAM 遥控器模型），使用玩家的手部模型
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true

-- 左键无实际功能：无弹药、无弹匣、无开火延迟
SWEP.Primary.Delay = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

-- 右键为模式切换：无弹药，切换时可为无人机回复 10 点生命
SWEP.Secondary.Delay = 0
SWEP.Secondary.Heal = 10

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- 手持移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 无弹匣显示；不可丢弃；捡起时不显示提示
SWEP.NoMagazine = true
SWEP.Undroppable = true
SWEP.NoPickupNotification = true

-- 持握姿势（SLAM 姿势）
SWEP.HoldType = "slam"

-- 部署时不改变移动速度；不可转移给他人；不自动切走
SWEP.NoDeploySpeedChange = true
SWEP.NoTransfer = true
SWEP.AutoSwitchFrom	= false

-- ==== Initialize - 初始化：设置持握姿势并加快部署速度 ====
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(10)
end

-- ==== Think - 每帧逻辑：播放待机动画；无人机不存在时移除遥控器 ====
function SWEP:Think()
	-- 待机动画计时结束则重置为待机动作
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	-- 服务器端：若已无归属自己的无人机（prop_drone*），则收回遥控器
	if SERVER then
		for _, ent in pairs(ents.FindByClass("prop_drone*")) do
			if ent:IsValid() and ent:GetObjectOwner() == self:GetOwner() then
				return
			end
		end

		self:GetOwner():StripWeapon(self:GetClass())
	end
end

-- ==== GetResupplyAmmoType - 返回补给弹药类型（默认为 smg1） ====
function SWEP:GetResupplyAmmoType()
	local owner = self:GetOwner()
	-- 优先使用玩家记录的无人机弹药类型
	if owner:IsValid() and owner.DroneControlAmmo then
		return owner.DroneControlAmmo
	end
	return "smg1"
end

-- ==== PrimaryAttack - 左键无动作 ====
function SWEP:PrimaryAttack()
end

-- ==== SecondaryAttack - 右键切换无人机模式并播放提示音 ====
function SWEP:SecondaryAttack()
	-- 首次预测时翻转模式开关
	if IsFirstTimePredicted() then
		self:SetDTBool(0, not self:GetDTBool(0))

		-- 客户端播放模式开启/关闭提示音
		if CLIENT then
			MySelf:EmitSound(self:GetDTBool(0) and "buttons/button17.wav" or "buttons/button19.wav", 0)
		end
	end
end

-- ==== Reload - 换弹键无动作 ====
function SWEP:Reload()
end

-- ==== Deploy - 部署时通知游戏模式并启动待机动画计时 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== Holster - 收起武器时重置模式开关 ====
function SWEP:Holster()
	self:SetDTBool(0, false)

	return true
end

-- 以下为客户端专属逻辑
if not CLIENT then return end

-- ==== DrawWeaponSelection - 武器选择界面绘制（调用基础实现） ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
