-- ============================================================================
-- weapon_zs_ffemitter/shared.lua - 火焰发射器建造装置（人类部署武器）
-- 负责：定义建造器的弹药、移动速度与放置相关状态
-- ============================================================================
-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_ffemitter")
SWEP.Description = ""..translate.Get("weapon_zs_ffemitter_description")

-- 视图模型与第三人称模型（第三人称借用荧光灯管模型）
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = Model("models/props_lab/lab_flourescentlight002b.mdl")

-- 持有本武器时保留备用弹药（不因切枪而清空）
SWEP.AmmoIfHas = true

-- 主攻击：单发弹匣、全自动、消耗 slam 弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "slam"
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true

-- 副攻击：占位配置（无实际用途）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

-- 普通移动速度与持有建造弹药时的移动速度
SWEP.WalkSpeed = SPEED_NORMAL
SWEP.FullWalkSpeed = SPEED_SLOWEST

-- 部署时不改变移动速度（由本武器自行控制）
SWEP.NoDeploySpeedChange = true

-- ==== Initialize - 初始化：设置持握姿势并隐藏模型 ====
function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
	GAMEMODE:DoChangeDeploySpeed(self)
	self:HideViewAndWorldModel()
end

-- ==== SetReplicatedAmmo - 将剩余建造弹药同步到客户端 ====
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取同步的建造弹药数 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 移动速度：剩余弹药大于 0 时使用最慢速度 ====
function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== SecondaryAttack - 副攻击：无操作 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹键：无操作（部署武器不换弹） ====
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 攻击检查：持有物体/建造幽灵中或弹药不足时禁止 ====
function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Holster - 收枪：始终允许 ====
function SWEP:Holster()
	return true
end
