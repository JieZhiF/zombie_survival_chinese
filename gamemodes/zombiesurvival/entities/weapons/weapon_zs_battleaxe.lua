AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_battleaxe")
SWEP.Description = ""..translate.Get("weapon_zs_battleaxe_description")

SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DPos = Vector(-0.95, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DBone = "v_weapon.USP_Slide"
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_USP.Single")
SWEP.Primary.Damage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.IronSightsPos = Vector(-5.9, 12, 2.3)

SWEP.ConeMax = 2.5
SWEP.ConeMin = 0.75

-- 全局开关
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.2  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.2  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"


GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)
