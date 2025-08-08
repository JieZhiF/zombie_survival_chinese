AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_glock3")
SWEP.Description = ""..translate.Get("weapon_zs_glock3_description")

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFOV = 50
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	SWEP.HUD3DPos = Vector(5, 0.25, -0.8)
	SWEP.HUD3DAng = Angle(90, 0, 0)
end

SWEP.ViewModelBoneMods_Reload={

}
SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
SWEP.Primary.Damage = 15.5
SWEP.Primary.NumShots = 3
SWEP.Primary.Delay = 0.3

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4.5
SWEP.ConeMin = 3

SWEP.Tier = 2
-- 全局开关
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.4  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.2  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

SWEP.IronSightsPos = Vector(-5.75, 10, 2.7)
SWEP.ViewModelBoneMods={
    ["ValveBiped.Bip01_L_UpperArm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_L_Forearm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_R_UpperArm"]={scale=Vector(1,1,1),pos=Vector(0,0,0),angle=Angle(0,0,0)},
    ["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0,0,0), angle = Angle(0,0,0) },
	["v_weapon.Glock_Parent"] = { scale = Vector(1,1,1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
	
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.9, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.5, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_glock3_r1"), ""..translate.Get("weapon_zs_glock3_r1_description"), function(wept)
	wept.Primary.NumShots = 2
	wept.Primary.Damage = wept.Primary.Damage * 1.2
	wept.ConeMin = wept.ConeMin * 0.65
	wept.ConeMax = wept.ConeMax * 0.65

	wept.BulletCallback = function(attacker, tr, dmginfo)
		if SERVER and tr.Entity:IsValidLivingZombie() and math.random(20) == 1 then
			local status = attacker:GiveStatus("reaper", 14)
			if status and status:IsValid() then
				status:SetDTInt(1, math.min(status:GetDTInt(1) + 1, 3))
				attacker:EmitSound("hl1/ambience/particle_suck1.wav", 55, 150 + status:GetDTInt(1) * 30, 0.45)
			end
		end
	end
end)
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 2, ""..translate.Get("weapon_zs_glock3_r2"), ""..translate.Get("weapon_zs_glock3_r2_description"), function(wept)
	wept.Primary.NumShots = 1
	wept.Primary.Damage = wept.Primary.Damage * 2.3
	wept.Primary.Delay = 0.2
	wept.ConeMin = wept.ConeMin * 0.3
	wept.ConeMax = wept.ConeMax * 0.4
	wept.Primary.Sound = Sound("weapons/usp/usp1.wav")

	wept.VElements = {
		["detail"] = { type = "Model", model = "models/Mechanics/wheels/wheel_extruded_48.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0, -1.64, 0), angle = Angle(0, 0, -90), size = Vector(0.014, 0.014, 0.014), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2+"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0, 0.889, 0.976), angle = Angle(0, 0, 0), size = Vector(0.15, 0.268, 0.029), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0.039, -2.02, -1.951), angle = Angle(-90, -90, 0), size = Vector(0.041, 0.041, 0.013), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["spikes"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(1.583, -0.04, -0.08), angle = Angle(102.149, -90, 0), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["silencer2"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom2", pos = Vector(0.039, -2.26, -1.951), angle = Angle(90, -90, 0), size = Vector(0.043, 0.043, 0.101), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["spikes+"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(5.008, -0.035, -0.08), angle = Angle(102.149, -90, 0), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["topmetal"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(3.078, 0.217, -0.029), angle = Angle(76.47, 90, 0), size = Vector(0.035, 0.219, 0.034), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "v_weapon.Glock_Parent", rel = "", pos = Vector(-3.201, -2.156, 0.246), angle = Angle(102.806, 84.778, -11.667), size = Vector(0.133, 0.172, 0.068), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}
	wept.WElements = {
		["detail"] = { type = "Model", model = "models/Mechanics/wheels/wheel_extruded_48.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, -1.64, 0), angle = Angle(0, 0, -90), size = Vector(0.014, 0.014, 0.014), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom"] = { type = "Model", model = "models/mechanics/solid_steel/crossbeam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.513, 1.929, -2.32), angle = Angle(40.83, -4.801, 90), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/combine_citadel001", skin = 0, bodygroup = {} },
		["spikes"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0.009, 0.732, -2.25), angle = Angle(180, 0, -1.56), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom", pos = Vector(0.241, -0.242, 0), angle = Angle(90, -135, 0), size = Vector(0.133, 0.172, 0.083), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, -2.29, -1.851), angle = Angle(-92, -90, 0), size = Vector(0.041, 0.041, 0.013), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["topmetal"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(-0.01, 2.589, -1.861), angle = Angle(0, -0.181, 1.6), size = Vector(0.037, 0.223, 0.034), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["silencer2"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, -2.471, -1.841), angle = Angle(88, -90, 0), size = Vector(0.043, 0.043, 0.101), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom2+"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0, 0.889, 1.049), angle = Angle(0, 0, 0), size = Vector(0.15, 0.268, 0.029), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["spikes+"] = { type = "Model", model = "models/props_phx/gears/rack9.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom2", pos = Vector(0.009, 4.179, -2.35), angle = Angle(180, 0, -1.56), size = Vector(0.072, 0.082, 0.063), color = Color(190, 190, 190, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}

	wept.GetAuraRange = function()
		return 512
	end
end)
branch.Colors = {Color(170, 170, 170), Color(120, 120, 120), Color(70, 70, 70)}
branch.NewNames = {""..translate.Get("weapon_zs_glock3_r2_l1"), ""..translate.Get("weapon_zs_glock3_r2_l2"), ""..translate.Get("weapon_zs_glock3_r2_l3")}
branch.Killicon = "weapon_zs_shroud"
