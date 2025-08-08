AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.PrintName = ""..translate.Get("weapon_zs_sweepershotgun")
SWEP.Description = ""..translate.Get("weapon_zs_sweepershotgun_description")

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.M3_PARENT"
	SWEP.HUD3DPos = Vector(-1, -4, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

SWEP.ReloadDelay = 0.45

SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Damage = 14.75
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.87

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 5
SWEP.ConeMin = 3.75

SWEP.FireAnimSpeed = 1.2
SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 4
SWEP.MaxStock = 3

SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 1.8  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 1.2  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = true
SWEP.Recoil_Progressive_Max_Multiplier = 2
SWEP.Recoil_Progressive_Shot_Increment = 0.01
SWEP.Recoil_Progressive_Reset_Time = 0.2


-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 2.2 -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Percentage = 0.4 
SWEP.Recoil_Recovery_Speed  = 3.2 -- 自动恢复的速度
SWEP.Recoil_Recovery_Time   = 0.15 

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)
