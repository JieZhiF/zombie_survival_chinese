-- ============================================================================
-- weapon_zs_arsenalcrate/shared.lua - 军械箱部署武器（共享定义与逻辑）
-- 负责：定义军械箱的属性（弹药、移动速度、库存），以及放置判定逻辑；
--       携带军械箱时移动极慢
-- ============================================================================
-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_arsenalcrate")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_arsenalcrate_description")

-- 第一人称模型（手枪模型仅作占位）
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
-- 世界模型：物资箱
SWEP.WorldModel = Model("models/Items/item_item_crate.mdl")

-- 拥有弹药时自动切换到这个武器（有军械箱可放时自动拿出）
SWEP.AmmoIfHas = true

SWEP.Primary.ClipSize = 1 -- 主弹匣容量：1 个军械箱
SWEP.Primary.DefaultClip = 1 -- 默认数量：1
SWEP.Primary.Ammo = "airboatgun" -- 使用特殊弹药类型（军械箱数量）
SWEP.Primary.Delay = 1 -- 两次放置之间的延迟
SWEP.Primary.Automatic = true -- 按住左键可连续放置

SWEP.Secondary.ClipSize = 1 -- 副弹匣容量
SWEP.Secondary.DefaultClip = 1 -- 副弹匣默认数量
SWEP.Secondary.Ammo = "dummy" -- 占位弹药类型（不使用）

SWEP.MaxStock = 5 -- 商店中的最大库存量

SWEP.WalkSpeed = SPEED_NORMAL -- 正常手持时的移动速度
SWEP.FullWalkSpeed = SPEED_SLOWEST -- 携带军械箱时的移动速度（极慢）

-- 展开/收起该武器时不做移动速度变化切换（速度由军械箱数量决定）
SWEP.NoDeploySpeedChange = true

-- ==== Initialize - 武器初始化 ====
-- 设置手持姿势、极快的展开速度并隐藏模型
function SWEP:Initialize()
	self:SetWeaponHoldType("slam") -- 手持姿势：贴地安放姿势
	self:SetDeploySpeed(10) -- 展开速度（快速拿出）
	self:HideViewAndWorldModel() -- 隐藏第一人称与第三人称模型
end

-- ==== SetReplicatedAmmo - 同步军械箱数量到客户端 ====
-- 通过数据表（DTInt 0）把军械箱数量复制给客户端显示
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取客户端同步的军械箱数量 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 根据军械箱数量返回移动速度 ====
-- 手中还有军械箱时移动极慢，没有时返回 nil 使用默认速度
function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== SecondaryAttack - 右键（空实现） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（空实现） ====
-- 军械箱不需要换弹
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 判断是否允许放置军械箱 ====
function SWEP:CanPrimaryAttack()
	-- 持握其他东西或正在预览路障时禁止放置
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 军械箱数量为 0 时重置下次开火时间并禁止攻击（相当于空仓）
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Holster - 武器收起时 ====
function SWEP:Holster()
	return true
end
