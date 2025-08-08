AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_ender")
SWEP.Description = ""..translate.Get("weapon_zs_ender_description")

SWEP.Slot = 3
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.galil"
	SWEP.HUD3DPos = Vector(1, 0, 6)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
SWEP.Primary.Damage = 9.5
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.4

SWEP.Primary.ClipSize = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 5.625
SWEP.ConeMin = 4.875

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 3

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.51, 1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_ender_r1"), ""..translate.Get("weapon_zs_ender_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 5.5
	wept.Primary.NumShots = 1
	wept.ConeMin = wept.ConeMin * 0.15
	wept.ConeMax = wept.ConeMax * 0.3
end)

function SWEP:SecondaryAttack()
end
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 1.2  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.5  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 17   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = true
SWEP.Recoil_Progressive_Max_Multiplier = 1.85
SWEP.Recoil_Progressive_Shot_Increment = 0.01
SWEP.Recoil_Progressive_Reset_Time = 0.2


-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 2.3 -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Percentage = 0.2 -- 恢复70%的后坐力, 剩下30%需要手动压
SWEP.Recoil_Recovery_Speed  = 3.8 -- 自动恢复的速度
SWEP.Recoil_Recovery_Time   = 0.1 -- 