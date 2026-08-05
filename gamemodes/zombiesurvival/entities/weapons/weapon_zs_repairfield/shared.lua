-- ============================================================================
-- weapon_zs_repairfield/shared.lua - 修理场部署器（共享端定义）
-- 负责：部署修理场的属性、弹药/速度规则与基础交互限制
-- ============================================================================
-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_repairfield")
SWEP.Description = ""..translate.Get("weapon_zs_repairfield_description")

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = Model("models/props/de_nuke/smokestack01.mdl")

-- 拥有弹药时才显示 HUD
SWEP.AmmoIfHas = true

-- 主弹药：部署器充能（每部署一个修理场消耗 1 发）
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "repairfield"
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true

-- 副弹药：占位（不使用）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

-- 世界模型缩放
SWEP.ModelScale = 0.55

-- 携带上限（背包可存数量）
SWEP.MaxStock = 5

-- 修理场每次脉冲的修复量 / 离开该距离后修理场失效
SWEP.Repair = 8
SWEP.MaxDistance = 75

-- 正常移动速度 / 携带修理场时的移动速度（最慢）
SWEP.WalkSpeed = SPEED_NORMAL
SWEP.FullWalkSpeed = SPEED_SLOWEST

-- 部署时向修理场充入的弹药类型
SWEP.ResupplyAmmoType = "pulse"

-- 放置预览幽灵状态 / 部署出的实体
SWEP.GhostStatus = "ghost_repairfield"
SWEP.DeployClass = "prop_repairfield"

-- 部署时不改变移动速度 / 允许强化
SWEP.NoDeploySpeedChange = true
SWEP.AllowQualityWeapons = true

-- 强化词条：修理量 +0.75 / 最大距离 +4
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_REPAIR, 0.75)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_DISTANCE, 4)

-- ==== Initialize - 武器初始化 ====
function SWEP:Initialize()
	-- 使用手雷持枪姿势（手持部署器）
	self:SetWeaponHoldType("slam")
	-- 加快切换武器速度
	self:SetDeploySpeed(1.1)
	-- 隐藏第一/第三人称模型
	self:HideViewAndWorldModel()
end

-- ==== SetReplicatedAmmo - 同步弹药剩余量到客户端 ====
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取客户端同步的弹药量 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 根据弹药决定移动速度 ====
function SWEP:GetWalkSpeed()
	-- 还有弹药时减速（表示正在携带修理场）
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== SecondaryAttack - 禁用右键功能 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 禁用换弹功能 ====
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 判断是否允许部署 ====
function SWEP:CanPrimaryAttack()
	-- 正在搬运/放置路障时禁止
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 没有弹药时禁止（并设置冷却，防止连点刷音效）
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Holster - 允许收起武器 ====
function SWEP:Holster()
	return true
end
