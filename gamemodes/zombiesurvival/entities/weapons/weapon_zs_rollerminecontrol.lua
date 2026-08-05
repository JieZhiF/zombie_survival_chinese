-- ============================================================================
-- weapon_zs_rollerminecontrol.lua - 滚筒地雷遥控器
-- 负责：遥控已放置的滚筒地雷（切换开关）、无弹药限制及自动移除机制
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_rollerminecontrol")
SWEP.Description = ""..translate.Get("weapon_zs_rollerminecontrol_description")

if CLIENT then
	-- 客户端：第一人称视野与武器晃动幅度
	SWEP.ViewModelFOV = 50

	SWEP.BobScale = 0.5
	SWEP.SwayScale = 0.5


	-- 归类到部署物选择栏
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
	SWEP.SlotGroup = WEPSELECT_DEPLOYABLES	
	SWEP.SlotPos = 0
end

-- 第一人称与第三人称模型（SLAM 遥控器），使用玩家手部模型
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true

-- 遥控器控制的实体类型：滚筒地雷
SWEP.EntityClass = "prop_rollermine"

-- 主攻击：无冷却、无弹药、单次触发
SWEP.Primary.Delay = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

-- 副攻击：冷却 20 秒，恢复 10 点（地雷耐久）
SWEP.Secondary.Delay = 20
SWEP.Secondary.Heal = 10

-- 副攻击：无弹药、单次触发
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- 持枪移动速度：快速
SWEP.WalkSpeed = SPEED_FAST

-- 无弹匣概念、不可丢弃、捡起不提示
SWEP.NoMagazine = true
SWEP.Undroppable = true
SWEP.NoPickupNotification = true

-- 持握姿势：SLAM 遥控器
SWEP.HoldType = "slam"

-- 部署不改变移动速度、不可转让、不被自动切换走
SWEP.NoDeploySpeedChange = true
SWEP.NoTransfer = true
SWEP.AutoSwitchFrom	= false

-- ==== Initialize - 设置持握姿势与快速部署速度 ====
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(10)
end

-- ==== Think - 待机动画循环；场上没有属于自己的地雷时自动移除遥控器 ====
function SWEP:Think()
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if SERVER then
		-- 检查场上是否存在归属自己的滚筒地雷，没有则移除本武器
		for _, ent in pairs(ents.FindByClass(self.EntityClass)) do
			if ent:IsValid() and ent:GetObjectOwner() == self:GetOwner() then
				return
			end
		end

		self:GetOwner():StripWeapon(self:GetClass())
	end
end

-- ==== PrimaryAttack - 切换地雷开关（引爆/关闭），并播放按钮音效 ====
function SWEP:PrimaryAttack()
	if IsFirstTimePredicted() then
		self:SetDTBool(0, not self:GetDTBool(0))

		if CLIENT then
			MySelf:EmitSound(self:GetDTBool(0) and "buttons/button17.wav" or "buttons/button19.wav", 0)
		end
	end
end

-- ==== SecondaryAttack - 占位：无副攻击逻辑 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 禁止换弹 ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 部署时触发武器部署事件并播放待机动画 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== Holster - 收起武器时关闭地雷开关 ====
function SWEP:Holster()
	self:SetDTBool(0, false)

	return true
end

-- ==== Reload - 占位覆盖：客户端换弹无操作 ====
function SWEP:Reload()
end

if not CLIENT then return end

-- ==== DrawWeaponSelection - 绘制武器选择栏图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
