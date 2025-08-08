AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = ""..translate.Get("weapon_zs_quasar")
SWEP.Description = ""..translate.Get("weapon_zs_quasar_description")

if CLIENT then
	SWEP.Slot = 3
	SWEP.SlotPos = 0

	SWEP.ViewModelFlip = false
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "v_weapon.awm_parent", rel = "", pos = Vector(0, -1, -8.697), angle = Angle(90, 0,-90), size = Vector(0.045, 0.02, 0.022), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(3.846, -0.038, 3.254), angle = Angle(0, -90, 90), size = Vector(0.5, 0.5, 1.8), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["bolt"] = { type = "Model", model = "models/props_combine/tprotato1_chunk01.mdl", bone = "v_weapon.awm_bolt_action", rel = "", pos = Vector(-1.559, -0.168, 0.716), angle = Angle(32.335, 0, 0), size = Vector(0.045, 0.045, 0.045), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["mag"] = { type = "Model", model = "models/Items/combine_rifle_cartridge01.mdl", bone = "v_weapon.awm_clip", rel = "", pos = Vector(0.034, 0.089, -1.914), angle = Angle(-90, 0, -90), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["rail"] = { type = "Model", model = "models/props_combine/combinecrane002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-28.77, -1.531, 4.38), angle = Angle(90, 180, 0), size = Vector(0.04, 0.04, 0.085), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["rail+"] = { type = "Model", model = "models/props_combine/combinecrane002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "rail", pos = Vector(-3.627, -3.108, 0), angle = Angle(0, 180, 0), size = Vector(0.04, 0.04, 0.085), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["scope"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(13.413, 0, 5.749), angle = Angle(-90, 180, 0), size = Vector(0.2, 0.2, 0.7), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["scopelens"] = { type = "Model", model = "models/props_combine/breenlight.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-1.031, -0.147, 3.012), angle = Angle(0, 180, 0), size = Vector(0.26, 0.23, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["stock"] = { type = "Model", model = "models/props_combine/combine_binocular01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(18.17, 0, 2.874), angle = Angle(90, 0, 0), size = Vector(0.6, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_combine/CombineTrain01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.042, 0.843, -1.653), angle = Angle(170.299, 0, 0), size = Vector(0.045, 0.02, 0.022), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["battery"] = { type = "Model", model = "models/Items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(3.846, -0.038, 3.254), angle = Angle(0, -90, 90), size = Vector(0.5, 0.5, 1.8), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["mag"] = { type = "Model", model = "models/Items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.264, 0.157, 0.259), angle = Angle(0, 0, 0), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["rail"] = { type = "Model", model = "models/props_combine/combinecrane002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-28.77, -1.531, 4.38), angle = Angle(90, 180, 0), size = Vector(0.04, 0.04, 0.085), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["rail+"] = { type = "Model", model = "models/props_combine/combinecrane002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(-3.627, -3.108, 0), angle = Angle(0, 180, 0), size = Vector(0.04, 0.04, 0.085), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["scope"] = { type = "Model", model = "models/props_combine/combine_light002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(13.413, 0, 5.749), angle = Angle(-90, 180, 0), size = Vector(0.2, 0.2, 0.7), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["scopelens"] = { type = "Model", model = "models/props_combine/breenlight.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-1.031, -0.147, 3.012), angle = Angle(0, 180, 0), size = Vector(0.26, 0.23, 0.25), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["stock"] = { type = "Model", model = "models/props_combine/combine_binocular01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(18.17, 0, 2.874), angle = Angle(90, 0, 0), size = Vector(0.6, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.ViewModelBoneMods = {
		["v_weapon.awm_parent"] = { scale = Vector(0.015, 0.015, 0.015), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}

	SWEP.HUD3DBone = "v_weapon.awm_parent"
	SWEP.HUD3DPos = Vector(-1.4, -5.35, -2.5)--Vector(-1.4, -5.35, -2.5)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end


SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"
SWEP.ZoomInSound			= Sound("weapons/weaponfx/zoom_in.ogg")
SWEP.ZoomOutSound			= Sound("weapons/weaponfx/zoom_out.ogg")
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_AWP.ClipOut")
SWEP.Primary.Sound			= Sound("weapons/colossus_fire.wav")
SWEP.Primary.Damage = 110
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.05
SWEP.ReloadDelay = SWEP.Primary.Delay
SWEP.RequiredClip = 4

SWEP.Primary.ClipSize = 24
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pulse"
SWEP.Primary.DefaultClip = 25

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

SWEP.ConeMax = 3
SWEP.ConeMin = 0
SWEP.IronSightsPos          = Vector(20,20,-20)--Vector(-7.32, -8.78, 0.08)
SWEP.IronSightsAng          = Vector(0, 0, 0)

SWEP.WalkSpeed = SPEED_SLOW
SWEP.ViewModelFOV   = 60
SWEP.TracerName = "AirboatGunHeavyTracer"

SWEP.Recoil_Enabled         = true -- 设为 true 来为武器启用此系统

SWEP.Recoil_Vertical        = 2  -- 基础垂直后坐力
SWEP.Recoil_Smoothing_Factor = 25   -- 平滑度, 越高越"硬
SWEP.FireAnimSpeed = 1.3

SWEP.Tier = 4
SWEP.MaxStock = 3

SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 4)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_quasar_r1"), ""..translate.Get("weapon_zs_quasar_r1_description"), function(wept)
	wept.Primary.NumShots = 3
	wept.Primary.Damage = wept.Primary.Damage * 1.2/3

	wept.ConeMax = 5
	wept.ConeMin = 4
	wept.ShootBullets = function(self, dmg, numbul, cone)
		local owner = self:GetOwner()

		self:SendWeaponAnimation()
		owner:DoAttackEvent()

		owner:LagCompensation(true)
		for i = 1, numbul do
			local angle = owner:GetAimVector():Angle()
			angle:RotateAroundAxis(angle:Up(), (i - math.ceil(3/2)) * 2.75*cone/6)

			owner:FireBulletsLua(owner:GetShootPos(), angle:Forward(), cone/2, 1, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
		end
		owner:LagCompensation(false)
	end

	wept.EmitFireSound = function(self)
		self:EmitSound(self.Primary.Sound)
		--self:EmitSound("weapons/flaregun/fire.wav", 70, math.random(95, 105), 1, CHAN_WEAPON)
		--self:EmitSound("weapons/physcannon/superphys_launch1.wav", 72, 158, 0.75, CHAN_WEAPON + 1)
	end
end)

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound)
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
	if ( self:Clip1() == self.Primary.ClipSize or self:Ammo1() == 0 ) then return end

	self.Weapon:EmitSound( "weapons/colossus_start.wav")
	timer.Simple(3.1, function()
		if ( not IsValid( self ) ) then return end
		self.Weapon:EmitSound( "weapons/colossus_end.wav",500, 100, 1, 1 )
	end)
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValid() and ent:IsPlayer() and ent:Team() == TEAM_UNDEAD then
		ent:AddLegDamageExt(8, attacker, attacker:GetActiveWeapon(), SLOWTYPE_PULSE)
	end

	if IsFirstTimePredicted() then
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)
	end
end

if CLIENT then
	SWEP.IronsightsMultiplier = 0.25

	function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			return pos + ang:Up() * 256, ang
		end

		return BaseClass.GetViewModelPosition(self, pos, ang)
	end

	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end
		if not self:IsScoped() then return end

		self:DrawFuturisticScope()
	end
end
