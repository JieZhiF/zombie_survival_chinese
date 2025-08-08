AddCSLuaFile()

SWEP.Slot = 3
SWEP.SlotPos = 0

if CLIENT then
    SWEP.ViewModelFOV = 60
    SWEP.ViewModelFlip = false
    SWEP.PrintName = ""..translate.Get("weapon_zs_hammerdown")
    SWEP.Description = ""..translate.Get("weapon_zs_hammerdown_desc")
    
    -- 可选项：如果不需要自定义HUD元素可删除以下内容
    SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
    SWEP.HUD3DPos = Vector(-1.6, 0, -1.4)
    SWEP.HUD3DAng = Angle(0, 0, 0)
    SWEP.HUD3DScale = 0.020
	 
	SWEP.VElements = {
	    ["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(0.136, 2.595, -4.831), angle = Angle(180, 89.901, 180), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["battery5"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(0.082, 0, -3.708), angle = Angle(0, 180, 0), size = Vector(0.354, 0.354, 0.574), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["battery4"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(0.054, 0.041, 0.414), angle = Angle(180, 180, 3.506), size = Vector(0.335, 0.335, 0.335), color = Color(255, 0, 0, 75), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["extrabattery2"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(0.991, -0.073, 6.4), angle = Angle(-11.242, -90, 85.324), size = Vector(0.12, 0.12, 0.12), color = Color(255, 0, 0, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	    ["forcefield2"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(-0.5, -1.55, -6.5), angle = Angle(0, -1.17, 180), size = Vector(0.078, 0.078, 0.078), color = Color(0, 200, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["battery2"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(0.347, 2.69, -1.619), angle = Angle(-130.5, 180, 40), size = Vector(0.211, 0.211, 0.211), color = Color(0, 255, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["extrabattery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(-0.024, 0.243, 6.885), angle = Angle(13.309, 86.597, -180), size = Vector(0.301, 0.301, 0.301), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["forcefield"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "v_weapon.xm1014_Bolt", rel = "", pos = Vector(-0.801, 1.799, -13.5), angle = Angle(180, 180, 180), size = Vector(0.07, 0.07, 0.07), color = Color(0, 200, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["+00"] = { type = "Model", model = "models/items/battery.mdl", bone = "v_weapon.xm1014_Shell", rel = "", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.065, 0.065, 0.065), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
    }

    SWEP.WElements = {
        ["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.963, 0.791, -1.558), angle = Angle(78.31, 3.506, 180), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["battery5"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11.916, 1.19, -4.516), angle = Angle(1.325, -89.468, 80.5), size = Vector(0.349, 0.349, 0.565), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["forcefield2+"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(19.659, -0.047, -8.200), angle = Angle(0, 90, 95), size = Vector(0.09, 0.09, 0.09), color = Color(0, 200, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["forcefield2"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(18.986, 0.104, -4.619), angle = Angle(-180, 90, 80), size = Vector(0.09, 0.09, 0.09), color = Color(0, 255, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["forcefield+"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(19.683, 1.549, -8.200), angle = Angle(0, 89, 95), size = Vector(0.09, 0.09, 0.09), color = Color(0, 200, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["battery2"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(30.548, 0.897, -7.802), angle = Angle(-10.379, 0, 0), size = Vector(0.225, 0.225, 0.225), color = Color(0, 255, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["extrabattery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-0.801, 0.893, -3.843), angle = Angle(-80, -180, 180), size = Vector(0.307, 0.307, 0.657), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	    ["forcefield"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(19.486, 1.996, -4.534), angle = Angle(-180, 89, 80), size = Vector(0.09, 0.09, 0.09), color = Color(0, 255, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }  
    }
end

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.HoldType = "shotgun"
SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands = true

-- 武器参数
SWEP.Primary.Sound = Sound("Weapon_XM1014.Single")
SWEP.Primary.Damage = 16.5
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.66
SWEP.Primary.Recoil = 6.5
SWEP.Primary.ClipSize = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
SWEP.ReloadDelay = 0.38
SWEP.TracerName = "tracer_laserstick"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 精度设置
SWEP.ConeMax = 6
SWEP.ConeMin = 4

-- 移动速度
SWEP.WalkSpeed = SPEED_FAST

function SWEP:SecondaryAttack()
    if self:CanPrimaryAttack() then
        self:FireSpecialShot()
    end
end
SWEP.Knockback = 60
SWEP.ReloadSound = Sound("items/ammo_pickup.wav")

function SWEP:FireSpecialShot()
    local owner = self:GetOwner()
    local clip = self:Clip1()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    --self:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")

    self:EmitFireSound()
    self:TakePrimaryAmmo(clip)
    self:ShootBullets(self.Primary.Damage, self.Primary.NumShots * clip, self:GetCone())

    self.Owner:ViewPunch(clip * 2 * self.Primary.Recoil * Angle(math.Rand(-0.1, -0.1), math.Rand(-0.1, 0.1), 0))

	owner:SetGroundEntity(NULL)
	owner:SetVelocity(-self.Knockback * clip * owner:GetAimVector())
    self.IdleAnimation = CurTime() + self:SequenceDuration()

end

function SWEP:HandleEmpty()
    self:EmitSound("buttons/combine_button1.wav")
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	dmginfo:SetDamageType(DMG_DISSOLVE)--Remove this if you don't want zombies to dissolve.

	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
	util.Effect("hit_xm", effectdata)
end