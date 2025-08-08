AddCSLuaFile()

SWEP.PrintName = "VEPR12"
SWEP.Description = "一柱擎天！."

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
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 7
SWEP.Primary.Delay = 0.17

SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 3
SWEP.ConeMin = 2

SWEP.ReloadSpeed = 1.75

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 5
SWEP.Recoil_Enabled = true
SWEP.Recoil_Vertical        = 1.2  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.42  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 17   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = false
SWEP.Recoil_Progressive_Max_Multiplier = 1.85
SWEP.Recoil_Progressive_Shot_Increment = 0.01
SWEP.Recoil_Progressive_Reset_Time = 0.2


-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 2.3 -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Percentage = 0.2 -- 恢复70%的后坐力, 剩下30%需要手动压
SWEP.Recoil_Recovery_Speed  = 4.6 -- 自动恢复的速度
SWEP.Recoil_Recovery_Time   = 0.1 -- 

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)

function SWEP:SecondaryAttack()
end
