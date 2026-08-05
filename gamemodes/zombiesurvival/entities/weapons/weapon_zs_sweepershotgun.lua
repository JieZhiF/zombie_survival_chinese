-- ============================================================================
-- weapon_zs_sweepershotgun.lua - 扫帚霰弹枪（M3 Super90 改造，全自动扫射）
-- 负责：霰弹属性定义（8 弹片/单发装填）、3D 图标配置、弹匣强化修饰器
-- ============================================================================

-- 共享文件：客户端也需要下载本文件
AddCSLuaFile()

-- 继承霰弹枪基类（基类提供泵动装填/换弹逻辑）
SWEP.Base = "weapon_zs_baseshotgun"

-- 武器显示名与描述（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_sweepershotgun")
SWEP.Description = ""..translate.Get("weapon_zs_sweepershotgun_description")

-- 客户端专属属性（3D 图标）
if CLIENT then
	-- 不翻转视图模型
	SWEP.ViewModelFlip = false

	-- 3D 图标（HUD 商店展示）挂在 M3 枪身父骨骼上
	SWEP.HUD3DBone = "v_weapon.M3_PARENT"
	SWEP.HUD3DPos = Vector(-1, -4, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

-- 继承霰弹枪基类
SWEP.Base = "weapon_zs_baseshotgun"

-- 持枪姿势（霰弹枪姿势）
SWEP.HoldType = "shotgun"

-- 使用 M3 Super90 的视图/世界模型
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

-- 单发装填间隔
SWEP.ReloadDelay = 0.45

-- 主攻击：M3 枪声、每发 8 弹片 × 14.75 伤害、0.87 秒开火间隔
SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Damage = 14.75
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.87

-- 弹匣 6 发、半自动、使用霰弹弹药；默认弹量由 SetupDefaultClip 按规则补满
SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散：最大 5 / 最小 3.75
SWEP.ConeMax = 5
SWEP.ConeMin = 3.75

-- 开火动画速度；持枪移动速度（慢速）
SWEP.FireAnimSpeed = 1.2
SWEP.WalkSpeed = SPEED_SLOWER

-- 武器等级 4；商店/库存中最大持有数量
SWEP.Tier = 4
SWEP.MaxStock = 3



-- 武器强化修饰器：弹匣容量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)
