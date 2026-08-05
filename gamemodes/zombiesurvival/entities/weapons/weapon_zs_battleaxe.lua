-- ============================================================================
-- weapon_zs_battleaxe.lua - 战斧（人类武器）
-- 负责：定义战斧（手枪外形的斧头）的基础射击属性
-- ============================================================================
AddCSLuaFile()

-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_battleaxe")
SWEP.Description = ""..translate.Get("weapon_zs_battleaxe_description")

-- 武器选择栏内位置
SWEP.SlotPos = 0

if CLIENT then
	-- 武器选择栏位（手枪类）与武器类型
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 视图模型设置
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- HUD 3D 预览位置、角度与骨骼
	SWEP.HUD3DPos = Vector(-0.95, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DBone = "v_weapon.USP_Slide"
end

-- 基于通用武器母本
SWEP.Base = "weapon_zs_base"

-- 持握姿势
SWEP.HoldType = "pistol"

-- 视图模型与第三人称模型（借用 USP 手枪模型）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.UseHands = true

-- 主攻击：开火音效、伤害、弹数与射击间隔
SWEP.Primary.Sound = Sound("Weapon_USP.Single")
SWEP.Primary.Damage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

-- 弹匣容量、半自动与弹药类型
SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
-- 按游戏模式规则初始化默认弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 机瞄位置
SWEP.IronSightsPos = Vector(-5.9, 12, 2.3)

-- 武器扩散（最大/最小）
SWEP.ConeMax = 2.5
SWEP.ConeMin = 0.75



-- 附加武器修正：弹匣 +1 发、射击间隔 -0.0175 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)
