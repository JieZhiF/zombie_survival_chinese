-- ============================================================================
-- shared.lua - 余烬棒（爆破型能量武器，开火会点燃目标并自伤）共享属性
-- 负责：基础伤害/扩散/换弹数值与武器强化修饰器注册
-- ============================================================================

-- 武器显示名（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_cinderrod")

-- 继承爆破武器基类（weapon_zs_blareduct）
SWEP.Base = "weapon_zs_blareduct"

-- 单发伤害 54，一次 1 发弹丸，开火间隔 1.5 秒
SWEP.Primary.Damage = 54
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.5

-- 扩散范围：最大 7.5 / 最小 6.5（散布较大的爆破武器）
SWEP.ConeMax = 7.5
SWEP.ConeMin = 6.5

-- 换弹速度与换弹延迟
SWEP.ReloadSpeed = 0.35
SWEP.ReloadDelay = 0.45

-- 武器强化修饰器：换弹速度 +15%（第一级），后坐力 -32.5，最小扩散 -1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.15, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RECOIL, -32.5)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -1)
