AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_longarm")
SWEP.Description = ""..translate.Get("weapon_zs_longarm_description")
SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "Python"
	SWEP.HUD3DPos = Vector(0.85, 0, -2.5)
	SWEP.HUD3DScale = 0.015

	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_short.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(23, 1, -6.5), angle = Angle(0, -90, -5), size = Vector(0.2, 1, 0.2), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_lab/powerbox02c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 9, 3), angle = Angle(90, 90, 0), size = Vector(0.5, 0.2, 1), color = Color(155, 160, 165, 255), surpresslightning = false, material = "models/weapons/v_grenade/rim", skin = 0, bodygroup = {} }
	}

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_pipes/pipe02_straight01_short.mdl", bone = "Python", rel = "", pos = Vector(0, -1.5, 16), angle = Angle(0, 0, 90), size = Vector(0.2, 1, 0.2), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_lab/powerbox02c.mdl", bone = "Python", rel = "base", pos = Vector(0, 9, 3), angle = Angle(90, 90, 0), size = Vector(0.5, 0.2, 1), color = Color(155, 160, 165, 255), surpresslightning = false, material = "models/weapons/v_grenade/rim", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("weapons/zs_longarm/longarm_fire.ogg")
SWEP.Primary.Delay = 0.73
SWEP.Primary.Damage = 120
SWEP.Primary.NumShots = 1

SWEP.Primary.ClipSize = 10
SWEP.RequiredClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.WalkSpeed = SPEED_SLOW

SWEP.ConeMax = 3.75
SWEP.ConeMin = 1.65

SWEP.Tier = 4
SWEP.MaxStock = 3

SWEP.IronSightsPos = Vector(-4.65, 4, 0.25)
SWEP.IronSightsAng = Vector(0, 0, 1)

SWEP.WallDivide = 6

-- 全局开关
SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

-- 基础设置
SWEP.Recoil_Vertical        = 0.8  -- 基础垂直后坐力
SWEP.Recoil_Horizontal      = 0.2  -- 基础水平后坐力 (随机范围)
SWEP.Recoil_Smoothing_Factor = 20   -- 平滑度, 越高越"硬"

-- 累进后坐力 (Progressive Recoil)
SWEP.Recoil_Progressive_Enabled = false
SWEP.Recoil_Progressive_Max_Multiplier = 2
SWEP.Recoil_Progressive_Shot_Increment = 0.05
SWEP.Recoil_Progressive_Reset_Time = 0.2

-- 后坐力恢复 (Recoil Recovery)
SWEP.Recoil_Decay_Rate      = 5    -- 连射时的“压枪”手感
SWEP.Recoil_Recovery_Time   = 0.15 -- 停火后多久开始恢复
SWEP.Recoil_Recovery_Speed  = 8    -- 自动恢复的速度
SWEP.Recoil_Recovery_Percentage = 0.15 

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.468)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.206)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.075, 1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_longarm_r1"), ""..translate.Get("weapon_zs_longarm_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.7
	wept.Primary.Delay = wept.Primary.Delay * 0.68
	wept.Primary.ClipSize = 16
	wept.WallDivide = 8
end)

local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
	attacker.RicochetBullet = true
	if attacker:IsValid() then
		local aw = attacker:GetActiveWeapon()
		attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 5, 6, damage / aw.WallDivide, nil, nil, "tracer_rico", nil, nil, nil, nil, nil, aw)
	end
	attacker.RicochetBullet = nil
end
function SWEP.BulletCallback(attacker, tr, dmginfo)
	if SERVER and tr.HitWorld and not tr.HitSky then
		local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage()
		timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg) end)
	end
end
