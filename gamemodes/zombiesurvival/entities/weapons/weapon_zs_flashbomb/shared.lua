-- ============================================================================
-- weapon_zs_flashbomb/shared.lua - 闪光弹（投掷类武器，共享端定义）
-- 负责：闪光弹的基础属性、模型与音效预缓存
-- ============================================================================
-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_flashbomb")
SWEP.Description = ""..translate.Get("weapon_zs_flashbomb_description")

-- 继承投掷武器基础（提供投掷与引信逻辑）
SWEP.Base = "weapon_zs_basethrown"

-- 第一人称 / 第三人称模型（CS 闪光弹模型）
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"

-- 消耗的弹药类型 / 拉环音效
SWEP.Primary.Ammo = "flashbomb"
SWEP.Primary.Sound = Sound("weapons/pinpull.wav")

-- 携带上限（背包可存数量）
SWEP.MaxStock = 30

-- ==== Precache - 预缓存拉环音效 ====
function SWEP:Precache()
	util.PrecacheSound("weapons/pinpull.wav")
end
