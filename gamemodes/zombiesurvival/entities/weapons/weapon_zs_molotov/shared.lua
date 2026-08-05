-- ============================================================================
-- weapon_zs_molotov/shared.lua - 投掷武器「燃烧瓶」（Molotov）共享端
-- 负责：定义燃烧瓶的名称、弹药与投掷音效
-- ============================================================================

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_molotov")
SWEP.Description = ""..translate.Get("weapon_zs_molotov_description")

-- 继承投掷武器基础模板
SWEP.Base = "weapon_zs_basethrown"

-- 第一人称与第三人称模型（昆虫诱饵模型/玻璃瓶模型）
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props_junk/glassbottle01a.mdl"

-- 隐藏官方模型（投掷武器外观由投射物呈现）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 消耗燃烧瓶专用弹药；投掷时的火焰音效
SWEP.Primary.Ammo = "molotov"
SWEP.Primary.Sound = Sound("ambient/fire/mtov_flame2.wav")

-- 商店最大库存 15
SWEP.MaxStock = 15
