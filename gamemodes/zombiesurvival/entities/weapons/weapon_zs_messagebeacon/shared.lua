-- ============================================================================
-- weapon_zs_messagebeacon/shared.lua - 消息信标武器（共享定义）
-- 负责：定义信标的属性（弹药、手持姿势、移动速度），以及放置信标的
--       初始化/攻击判定/换弹等基础逻辑
-- ============================================================================
-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_messagebeacon")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_messagebeacon_description")

-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

-- 第一人称模型（手枪模型作为手持外观）
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
-- 世界模型（反坦克地雷外观，对应信标的外形）
SWEP.WorldModel = Model("models/props_combine/combine_mine01.mdl")

-- 拥有弹药时自动切换到这个武器（有信标可放时自动拿出）
SWEP.AmmoIfHas = true

SWEP.Primary.ClipSize = 1 -- 主弹匣容量：1 发（1 个信标）
SWEP.Primary.DefaultClip = 1 -- 默认弹匣数：1
SWEP.Primary.Ammo = "striderminigun" -- 使用特殊弹药类型（信标数量）
SWEP.Primary.Delay = 1 -- 两次放置之间的延迟
SWEP.Primary.Automatic = true -- 按住左键可连续放置

SWEP.Secondary.ClipSize = 1 -- 副弹匣容量
SWEP.Secondary.DefaultClip = 1 -- 副弹匣默认数量
SWEP.Secondary.Automatic = false -- 右键非自动
SWEP.Secondary.Ammo = "dummy" -- 占位弹药类型（不使用）

SWEP.WalkSpeed = SPEED_NORMAL -- 正常手持时的移动速度
SWEP.FullWalkSpeed = SPEED_SLOW -- 携带信标时的移动速度（变慢）
-- 展开/收起该武器时不做移动速度变化切换（速度由信标数量决定）
SWEP.NoDeploySpeedChange = true

-- 商店中的最大库存量
SWEP.MaxStock = 10

-- ==== Initialize - 武器初始化 ====
-- 设置手持姿势、根据信标数量更新移动速度并隐藏模型
function SWEP:Initialize()
	self:SetWeaponHoldType("slam") -- 手持姿势：贴地安放姿势
	GAMEMODE:DoChangeDeploySpeed(self) -- 让游戏模式重新计算移动速度
	self:HideViewAndWorldModel() -- 隐藏第一人称与第三人称模型
end

-- ==== SetReplicatedAmmo - 同步信标数量到客户端 ====
-- 通过数据表（DTInt 0）把信标数量复制给客户端显示
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取客户端同步的信标数量 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 根据信标数量返回移动速度 ====
-- 手中还有信标时移动变慢，没有信标时返回 nil 使用默认速度
function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== Reload - 换弹（空实现） ====
-- 信标武器不需要换弹，直接禁止该行为
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 判断是否允许放置信标 ====
function SWEP:CanPrimaryAttack()
	-- 持握其他东西或正在预览路障时禁止放置
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 信标数量为 0 时重置下次开火时间并禁止攻击（相当于空仓）
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Deploy - 武器展开时 ====
-- 通知游戏模式该武器已部署（用于更新携带速度等）
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- ==== Holster - 武器收起时 ====
function SWEP:Holster()
	return true
end
