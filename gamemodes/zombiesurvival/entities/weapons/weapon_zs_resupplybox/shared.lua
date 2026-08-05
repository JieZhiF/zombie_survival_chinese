-- ============================================================================
-- weapon_zs_resupplybox/shared.lua - 补给箱部署武器（共享）
-- 负责：定义补给箱的基本属性，部署后生成 prop_resupplybox 实体为玩家补给弹药
-- ============================================================================
-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_resupplybox")
-- 武器描述文本（本地化键）
SWEP.Description = ""..translate.Get("weapon_zs_resupplybox_description")

-- 第一人称/世界模型
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = Model("models/Items/ammocrate_ar2.mdl")

-- 拥有弹药时才计入携带（部署物类武器通用属性）
SWEP.AmmoIfHas = true

-- 主攻击（部署）弹药设置
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "helicoptergun"
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true

-- 副攻击设置（本武器无副攻击功能，使用占位弹药）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

-- 最大库存数量
SWEP.MaxStock = 5

-- 持有时的移动速度
SWEP.WalkSpeed = SPEED_NORMAL
-- 携带部署物时的满载移动速度（大幅减速）
SWEP.FullWalkSpeed = SPEED_SLOWEST

-- 部署时不改变移动速度（避免部署瞬间速度突变）
SWEP.NoDeploySpeedChange = true

-- ==== Initialize - 武器初始化 ====
function SWEP:Initialize()
	-- 设置武器持握类型为 SLAM（C4 炸弹样式）
	self:SetWeaponHoldType("slam")
	-- 应用部署速度设置
	GAMEMODE:DoChangeDeploySpeed(self)
	-- 隐藏第一人称和世界模型（部署物武器不显示枪械模型）
	self:HideViewAndWorldModel()
end

-- ==== SetReplicatedAmmo - 同步弹药数量到客户端 ====
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 获取同步的弹药数量 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 根据弹药数量返回移动速度 ====
function SWEP:GetWalkSpeed()
	-- 携带部署物（弹药>0）时使用满载减速速度
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== SecondaryAttack - 副攻击（空实现，无副攻击功能） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（空实现，部署物不可换弹） ====
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 检查是否可以执行主攻击（部署） ====
function SWEP:CanPrimaryAttack()
	-- 搬运物体或处于路障穿透状态时禁止部署
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 弹药耗尽时设置冷却并返回 false
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Holster - 收枪 ====
function SWEP:Holster()
	return true
end
