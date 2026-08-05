-- ============================================================================
-- weapon_zs_basetrinket/shared.lua - 饰品母本（共享端）
-- 负责：定义饰品类武器的通用约束（无攻击/换弹、不可拆解/丢弃/转移）与外观占位
-- ============================================================================

-- 母本：近战武器基础（仅继承基础生命周期，实际无攻击）
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称模型（手雷占位，实际由子类附加模型覆盖）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 禁用主武器弹药（无弹匣）
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

-- 禁用副武器弹药
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- 移动速度：常规
SWEP.WalkSpeed = SPEED_NORMAL

-- 非近战武器（不参与近战体系）
SWEP.IsMelee = false

-- 持枪姿势：放置姿势
SWEP.HoldType = "slam"

-- 掉落在地时模型颜色调制（橙色，便于识别）
SWEP.DroppedColorModulation = Color(1, 0.5, 0)

-- 禁止拆解（无法回收材料）
SWEP.NoDismantle = true
-- 禁止丢弃
SWEP.Undroppable = true
-- 捡起时不显示提示
SWEP.NoPickupNotification = true
-- 出枪时不改变移动速度
SWEP.NoDeploySpeedChange = true
-- 禁止转移（无法存入仓库/传递给他人）
SWEP.NoTransfer = true
-- 自动切换到本武器：禁用（不会自动切到饰品）
SWEP.AutoSwitchFrom	= false

-- ==== PrimaryAttack - 禁用左键攻击 ====
function SWEP:PrimaryAttack()
end

-- ==== SecondaryAttack - 禁用右键攻击 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 禁用换弹 ====
function SWEP:Reload()
end
