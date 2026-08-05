-- ============================================================================
-- weapon_zs_owens.lua - 欧文斯双发手枪
-- 负责：一次扣扳机打出两发的手枪属性、扩散与强化模组
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_owens")
SWEP.Description = ""..translate.Get("weapon_zs_owens_description")

-- 武器栏内位置
SWEP.SlotPos = 0

if CLIENT then
-- 武器栏：手枪槽
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型：手枪
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- HUD 3D 图标（大图标预览）参数
	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

-- 持枪姿势
SWEP.HoldType = "pistol"

-- 模型与手臂
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true  

-- 关闭 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 换弹/开火音效与伤害（每次打出 2 发弹丸）
SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 14.2
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.18

-- 弹匣与弹药
SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
-- 弹药换算倍率（10 发弹匣按 12 发备弹计算）
SWEP.Primary.ClipMultiplier = 12/10
GAMEMODE:SetupDefaultClip(SWEP.Primary)


-- 扩散
SWEP.ConeMax = 4
SWEP.ConeMin = 2.5

-- 换弹速度倍率
SWEP.ReloadSpeed = 1

-- 机瞄位置
SWEP.IronSightsPos = Vector(-5.401, 0, 2.4)

-- 机瞄角度
SWEP.IronSightsAng = Angle(0, 0, 0)

-- 强化：最大/最小扩散降低 + 射速提升
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.46, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.22, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)
