AddCSLuaFile()

SWEP.PrintName = "ATTACKER"
SWEP.Description = "OMG"

SWEP.Base = "weapon_zs_base"

SWEP.SlotPos = 0

if CLIENT then
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRilfe")
    SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 50

    SWEP.HUD3DAng = Angle(0, 0, 0)
    SWEP.HUD3DBone = "v_weapon.AK47_Parent"
    SWEP.HUD3DPos = Vector(-1, -4.5, -4)
    SWEP.HUD3DScale = 0.015
end

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true

SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.Primary.Damage = 70

SWEP.Primary.Delay = 0.07

SWEP.Primary.ClipSize = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"

SWEP.Recoil_Enabled = true
SWEP.Recoil_Vertical        = 0.3  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.1  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

SWEP.ConeMax = 2.5
SWEP.ConeMin = 2.25
SWEP.WalkSpeed = SPEED_SLOWER
