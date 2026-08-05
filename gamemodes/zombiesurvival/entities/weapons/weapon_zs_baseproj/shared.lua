-- ============================================================================
-- weapon_zs_baseproj/shared.lua - 投射物武器基础模板（共享端）
-- 负责：定义所有发射投射物武器的通用属性（模型/扩散/投射物初速）
-- ============================================================================

-- 继承枪械基础模板
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（弩姿势）
SWEP.HoldType = "crossbow"

-- 第一人称与第三人称模型（十字弩），使用玩家的手部模型
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true

-- 扩散范围（最大/最小准星扩散）与冷却期间的额外扩散
SWEP.ConeMax = 2
SWEP.ConeMin = 1
SWEP.CooldownExtraSize = 1

-- 投射物默认初速度（3200 单位/秒）
SWEP.Primary.ProjVelocity = 3200
