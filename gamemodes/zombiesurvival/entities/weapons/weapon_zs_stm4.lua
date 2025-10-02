AddCSLuaFile()

DEFINE_BASECLASS("weapon_zs_base")
SWEP.PrintName = "'究极武器'SR-47"
SWEP.Description = "加油吧"

SWEP.SlotPos = 0

SWEP.Primary.BaseDamage = 25
SWEP.Primary.Damage = SWEP.Primary.BaseDamage
SWEP.Primary.Delay = 0.1
SWEP.Primary.ClipSize = 38
SWEP.ReloadSpeed = 1.21
SWEP.Tier = 5
SWEP.ConeMax = 2.0
SWEP.ConeMin = 1.0
SWEP.HeadshotMulti = 1.8

SWEP.Base = "weapon_zs_base"
SWEP.IdleActivity = ACT_VM_IDLE_SILENCED

SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)
end

function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_RELOAD_SILENCED)
end
 
function SWEP:Deploy()
    self.BaseClass.Deploy(self)
    self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
end

function SWEP:FinishReload()
	self.BaseClass.FinishReload(self)
	self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
end
SWEP.Primary.Automatic = true

SWEP.IronSightsPos = Vector(-3, 0, 2)
SWEP.Primary.Sound = Sound("weapons/m4a1/m4a1-1.wav")  -- CSS消音M4开火音效
SWEP.Primary.DefaultClip = 240

SWEP.GetAuraRange = nil

SWEP.HoldType = "ar2"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1_silencer.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.UseHands = true
SWEP.ViewModelBoneMods = {}
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.VElements = {
}
 
SWEP.WElements = {
}

if CLIENT then

    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
    SWEP.HoldType = "ar2"
	SWEP.HUD3DBone = "v_weapon.m4_Parent"
	SWEP.HoldType = "ar2"

	SWEP.HUD3DPos = Vector(-0.5, -5, -1.2)
	SWEP.HUD3DAng = Angle(0, -5, 0)
	SWEP.HUD3DScale = 0.015
end

function SWEP:FireAnimationEvent( pos, ang, event, options )

	-- Disables animation based muzzle event
	--if ( event == 21 ) then return true end
	--if ( event == 20 ) then return true end

	-- Disable thirdperson muzzle flash
	if ( event == 5001 ) then return true end
	if ( event == 5003 ) then return true end
	if ( event == 5011 ) then return true end
	if ( event == 5021 ) then return true end
	if ( event == 5031 ) then return true end
	if ( event == 6001 ) then return true end
    
end

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 2)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEADSHOT_MULTI, 0.3)
