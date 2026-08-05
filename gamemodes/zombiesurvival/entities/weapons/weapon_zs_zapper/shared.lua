-- ============================================================================
-- shared.lua - 电击器（可部署陷阱武器，放置后自动电击亡灵）共享属性
-- 负责：部署道具属性（弹药/幽灵预览/移动速度限制）、DT 弹药同步、
--       开火许可判定（手持物与路障幽灵时禁用）
-- ============================================================================

-- 武器显示名与描述（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_zapper")
SWEP.Description = ""..translate.Get("weapon_zs_zapper_description")

-- 使用手枪视图模型；世界模型为电线连接器道具（本体由 SCK 元素呈现）
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = Model("models/props_c17/utilityconnecter006c.mdl")

-- 拥有弹药时自动切换为攻击状态（无弹药时不部署）
SWEP.AmmoIfHas = true

-- 主攻击：单发"弹药"用于部署，延迟 1 秒（自动开火模式）
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "zapper"
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 25

-- 副攻击：占位定义（无实际功能）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

-- 部署物的视觉缩放；武器等级 2
SWEP.ModelScale = 0.75
SWEP.Tier = 2

-- 商店/库存中最大持有数量
SWEP.MaxStock = 5

-- 正常持枪速度；弹药充足（可部署）时降为最慢
SWEP.WalkSpeed = SPEED_NORMAL
SWEP.FullWalkSpeed = SPEED_SLOWEST

-- 弹药补充类型（脉冲弹供应）
SWEP.ResupplyAmmoType = "pulse"

-- 放置预览用的幽灵状态与部署实体类
SWEP.GhostStatus = "ghost_zapper"
SWEP.DeployClass = "prop_zapper"

-- 部署状态下不改变移动速度；允许武器强化
SWEP.NoDeploySpeedChange = true
SWEP.AllowQualityWeapons = true

-- 部署物附加腿部伤害（+修饰器加成）
SWEP.LegDamage = 10

-- 武器强化修饰器：腿部伤害 +2
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_LEG_DAMAGE, 2)

-- ==== Initialize - 初始化：设置持枪姿势、部署速度并隐藏模型 ====
function SWEP:Initialize()
	-- 使用放置类（slam）持枪姿势
	self:SetWeaponHoldType("slam")
	-- 加快部署速度
	self:SetDeploySpeed(1.1)
	-- 隐藏视图/世界模型（外观由 SCK 元素呈现）
	self:HideViewAndWorldModel()
end

-- ==== SetReplicatedAmmo - 将弹药数写入 DT 供客户端显示 ====
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取复制的弹药数 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 有弹药（可部署）时切换为最慢速度 ====
function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== SecondaryAttack - 副攻击无功能 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹无功能 ====
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 开火许可：手持物/路障幽灵或弹药耗尽时禁止 ====
function SWEP:CanPrimaryAttack()
	-- 手持物体或正在放置路障时禁止部署
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 无弹药时延迟冷却并拒绝开火
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
