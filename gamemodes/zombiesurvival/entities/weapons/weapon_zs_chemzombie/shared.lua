-- ============================================================================
-- weapon_zs_chemzombie/shared.lua - 化学僵尸喷吐武器（共享）
-- 负责：声明该武器仅供僵尸使用；用撬棍模型充当僵尸双手占位，
--       隐藏武器模型（伤害/喷射逻辑在服务器端 init.lua，特效在 cl_init.lua）
-- ============================================================================
-- 仅限僵尸购买/使用
SWEP.ZombieOnly = true

-- 使用撬棍模型作为僵尸手臂的占位（实际外观被隐藏）
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

-- 主攻击：无限弹药（-1 = 无弹匣/无弹药类型），按住自动
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

-- 副攻击：同样无限且自动（由服务器端逻辑区分用途）
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

-- ==== Deploy - 切换出武器时记录闲置动画结束时间 ====
function SWEP:Deploy()
	-- 记录出枪动画的结束时刻，用于后续播放闲置动画
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== Initialize - 初始化：隐藏视模型与世界模型 ====
function SWEP:Initialize()
	-- 武器本体不可见（喷吐表现由特效承担）
	self:HideViewAndWorldModel()
end

-- ==== PrimaryAttack - 主攻击（空实现，服务器端另行处理） ====
function SWEP:PrimaryAttack()
end

-- ==== SecondaryAttack - 副攻击（空实现，服务器端另行处理） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（空实现，无需换弹） ====
function SWEP:Reload()
end
