-- ============================================================================
-- weapon_zs_manhackcontrol.lua - 猎头者遥控器（召唤猎头者）
-- 负责：召唤/收回猎头者机器人，左键切换开关状态，无猎头者时自动移除
-- ============================================================================
AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_manhackcontrol") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_manhackcontrol_description") -- 武器描述

if CLIENT then
	SWEP.ViewModelFOV = 50 -- 第一人称镜头大小

	SWEP.BobScale = 0.5 -- 走路晃动幅度
	SWEP.SwayScale = 0.5 -- 视角摆动幅度


	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables") -- 部署物武器栏
	SWEP.SlotGroup = WEPSELECT_DEPLOYABLES	-- 武器选择组（部署物）
	SWEP.SlotPos = 0 -- 武器栏中的槽位
end

SWEP.ViewModel = "models/weapons/c_slam.mdl" -- 第一人称模型（激光绊雷外观）
SWEP.WorldModel = "models/weapons/w_slam.mdl" -- 第三人称模型
SWEP.UseHands = true -- 使用玩家手部模型

SWEP.EntityClass = "prop_manhack" -- 遥控的实体类型（猎头者机器人）

SWEP.Primary.Delay = 0 -- 左键间隔
SWEP.Primary.ClipSize = -1 -- 无限弹匣
SWEP.Primary.DefaultClip = -1 -- 无限默认弹药
SWEP.Primary.Automatic = false -- 单发
SWEP.Primary.Ammo = "none" -- 不消耗弹药

SWEP.Secondary.Delay = 20 -- 右键冷却（秒）
SWEP.Secondary.Heal = 10 -- 右键恢复猎头者生命值

SWEP.Secondary.ClipSize = -1 -- 无限弹匣
SWEP.Secondary.DefaultClip = -1 -- 无限默认弹药
SWEP.Secondary.Automatic = false -- 单发
SWEP.Secondary.Ammo = "none" -- 不消耗弹药

SWEP.WalkSpeed = SPEED_FAST -- 持枪移动速度（快速）

SWEP.NoMagazine = true -- 无弹匣 HUD
SWEP.Undroppable = true -- 禁止丢弃
SWEP.NoPickupNotification = true -- 拾取时无提示

SWEP.HoldType = "slam" -- 持枪姿势（激光绊雷）

SWEP.NoDeploySpeedChange = true -- 部署不改变移动速度
SWEP.NoTransfer = true -- 不可转移给他人
SWEP.AutoSwitchFrom	= false -- 不自动切换出

-- ==== Initialize - 初始化持枪姿势与快速部署速度 ====
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(10)
end

-- ==== Think - 闲置动画计时与检测猎头者存在（消失则移除遥控器） ====
function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if SERVER then
		-- 检查场景中是否还有属于持有者的猎头者
		for _, ent in pairs(ents.FindByClass(self.EntityClass)) do
			if ent:IsValid() and ent:GetObjectOwner() == self:GetOwner() then
				return
			end
		end

		-- 猎头者已不存在：移除遥控器
		self:GetOwner():StripWeapon(self:GetClass())
	end
end

-- ==== PrimaryAttack - 左键切换召唤/收回猎头者开关 ====
function SWEP:PrimaryAttack()
	if IsFirstTimePredicted() then
		self:SetDTBool(0, not self:GetDTBool(0))

		if CLIENT then
			MySelf:EmitSound(self:GetDTBool(0) and "buttons/button17.wav" or "buttons/button19.wav", 0)
		end
	end
end

-- ==== SecondaryAttack - 禁用右键 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 禁用换弹 ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 部署时广播事件并开始闲置动画计时 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== Holster - 收起武器时关闭召唤开关 ====
function SWEP:Holster()
	self:SetDTBool(0, false)

	return true
end

-- ==== Reload - 空实现（覆盖基类换弹逻辑） ====
function SWEP:Reload()
end

if not CLIENT then return end

-- ==== DrawWeaponSelection - 使用基类绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
