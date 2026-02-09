AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_owens")
SWEP.Description = ""..translate.Get("weapon_zs_owens_description")

SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true  

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 14.2
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.18

SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipMultiplier = 12/10
GAMEMODE:SetupDefaultClip(SWEP.Primary)


SWEP.ConeMax = 4
SWEP.ConeMin = 2.5

-- 全局开关
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.2  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.2  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 5    -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Time   = 0.15 -- 停火后多久开始恢复
SWEP.Recoil_Recovery_Speed  = 8    -- 自动恢复的速度
SWEP.Recoil_Recovery_Percentage = 0.15 
SWEP.ReloadSpeed = 0.85

SWEP.IronSightsPos = Vector(-5.401, 0, 2.4)

SWEP.IronSightsAng = Angle(0, 0, 0)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.46, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.22, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)
