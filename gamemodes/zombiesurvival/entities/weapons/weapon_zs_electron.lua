AddCSLuaFile()


if CLIENT then
   SWEP.PrintName = "'青峰'电子加速器"
end
SWEP.Description = "瞄准状态下，E键可以特殊射击子弹"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

SWEP.Slot = 2
SWEP.Base = "weapon_sbase"
SWEP.VElements = {

	["b1"] = { type = "Model", model = "models/combine_turrets/ground_turret.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -2.52, -5.335), angle = Angle(90, -90, 0), size = Vector(0.5, 0.107, 0.131), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["top1"] = { type = "Model", model = "models/props_combine/tprotato1.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -1.754, -7.974), angle = Angle(6.631, 90, -180), size = Vector(0.07, 0.028, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },

	["top2"] = { type = "Model", model = "models/combine_room/combine_monitor002.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -2.698, -7.529), angle = Angle(0, -90, 180), size = Vector(0.039, 0.018, 0.059), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b3"] = { type = "Model", model = "models/props_combine/combine_booth_med01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(-0.075, -0.306, -23.323), angle = Angle(0, 45, 0), size = Vector(0.027, 0.025, 0.129), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_combine/combinethumper001a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -1.719, -18.504), angle = Angle(0, 0, 0), size = Vector(0.029, 0.019, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },

	["base"] = { type = "Model", model = "", bone = "ValveBiped.base", rel = "", pos = Vector(0.174, 0.643, 1.771), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["prong"] = { type = "Model", model = "models/props_combine/tprotato1_chunk01.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(-0.576, 0.312, 20.052), angle = Angle(0, 0, 0), size = Vector(0.05, 0.056, 0.279), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["vent"] = { type = "Model", model = "models/props_combine/combine_barricade_med01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, -0.245, -10.36), angle = Angle(0, -4.711, 0), size = Vector(0.05, 0.029, 0.079), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b2"] = { type = "Model", model = "models/props_combine/tprotato1_chunk04.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, 0.016, 0), angle = Angle(5.502, -90, 180), size = Vector(0.187, 0.114, 0.259), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip+"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, 1.858, -3.029), angle = Angle(0, 90, 180), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["grip"] = { type = "Model", model = "models/props_combine/combinetrain01a.mdl", bone = "ValveBiped.base", rel = "base", pos = Vector(0, 2.757, 6.798), angle = Angle(0, 90, 180), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["reflexfront"] = { type = "Quad", bone = "ValveBiped.base", rel = "top2", pos = Vector(-2.661, -0.276, 2.413), angle = Angle(0, 90, 0), size = 0.0025, draw_func = nil},
	["reflexback"] = { type = "Quad", bone = "ValveBiped.base", rel = "top2", pos = Vector(-2.661, -0.276, -2.633), angle = Angle(0, 90, 0), size = 0.0025, draw_func = nil},
}

SWEP.WElements = {
	["top2"] = { type = "Model", model = "models/combine_room/combine_monitor002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -2.698, -7.529), angle = Angle(0, -73.056, 180), size = Vector(0.039, 0.018, 0.059), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b3"] = { type = "Model", model = "models/props_combine/combine_booth_med01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(0.118, 0.34, 3.437), angle = Angle(0, 45, 0), size = Vector(0.027, 0.025, 0.079), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["barrel"] = { type = "Model", model = "models/props_combine/combinethumper001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -1.719, -18.504), angle = Angle(0, 0, 0), size = Vector(0.029, 0.019, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b1"] = { type = "Model", model = "models/combine_turrets/ground_turret.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -2.52, -5.335), angle = Angle(90, -90, 0), size = Vector(0.5, 0.107, 0.131), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(9.164, 1.751, -5.377), angle = Angle(0, -90, -101.689), size = Vector(0.009, 0.009, 0.009), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["prong"] = { type = "Model", model = "models/props_combine/tprotato1_chunk01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.576, 0.312, 20.052), angle = Angle(0, 0, 0), size = Vector(0.05, 0.056, 0.279), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["top1"] = { type = "Model", model = "models/props_combine/tprotato1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -1.754, -7.974), angle = Angle(6.631, 90, -180), size = Vector(0.07, 0.028, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["b2"] = { type = "Model", model = "models/props_combine/tprotato1_chunk04.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0.016, 0), angle = Angle(5.502, -90, 180), size = Vector(0.187, 0.114, 0.259), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.HUD3DScale = 0.022
SWEP.HUD3DBone = "ValveBiped.base"
SWEP.HUD3DPos = Vector(2.3,0.2,1)
SWEP.HUD3DAng = Angle(180, 0, -20)

SWEP.RPM = 650

SWEP.RotSpeed = 3
SWEP.Mult = 0.25
SWEP.Spin = 0
SWEP.Tier = 5
SWEP.MaxStock = 2

SWEP.Primary.Recoil	= 0.1
SWEP.Recoil = 0
SWEP.Primary.Damage = 27 --1颗子弹的伤害
SWEP.Primary.KnockbackScale = 1 --击退，这玩意似乎没啥用
SWEP.Primary.NumShots = 1 --左键一次射出的子弹数量
SWEP.Primary.ClipSize = 40

SWEP.Primary.Delay = 0.092
SWEP.Primary.Cone = 0.018
SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip = 240
SWEP.Primary.Ammo = "pulse"

SWEP.reloadoffset = 0
SWEP.targetoffset = 0
SWEP.reloadoffset2 = 0
SWEP.targetoffset2 = 0
SWEP.SightOffset = 0
SWEP.SightOffset2 = 0
SWEP.RSO1 = 0
SWEP.RSO2 = 0
SWEP.Sighting = false

SWEP.IronSightPos = Vector(0, -6.75, -1)
SWEP.IronSightAng = Angle(0, 0, 0)


SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier --这是武器点数获取
SWEP.ConeMax = 3.2 --最大准星扩散
SWEP.ConeMin = 1.6 --最小准星扩散
SWEP.ConeRamp = 2

--override weapon_base giving us useless pistol ammo
SWEP.Secondary.ClipSize		= 1					-- Size of a clip
SWEP.Secondary.DefaultClip	= 1				-- Default number of bullets in a clip
SWEP.Secondary.Ammo			= "ar2"
SWEP.Secondary.Delay = 1.25
SWEP.Secondary.Automatic = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 75
SWEP.ViewModel  = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.FN = 0
SWEP.VO = 0
SWEP.VX = 0
SWEP.REC = 0
SWEP.Breathmult = 1
SWEP.InspectSpeed = 0.8
SWEP.IronEnable = true
SWEP.IronSpeed = 9.5

SWEP.Inspect = {
	{pos = Vector(0,0,0),ang = Angle(0,0,0),time = -1},
}

SWEP.Recoil = 0
SWEP.IdleActivity = ACT_IDLE --闲置时的武器动画

SWEP.A1 = 0
SWEP.A2 = 0
SWEP.A = 0
SWEP.RR = 0
SWEP.RG = 0
SWEP.RB = 0
SWEP.LastFire = 0
SWEP.ConeMod = 0
SWEP.crosshairang = Angle(0,0,0)
SWEP.punch = 0
SWEP.Full = true
SWEP.acc = 1

--recoil settings
SWEP.upmax = -0.1
SWEP.lmax = 0.04
SWEP.lmin = -0.01
--default values
SWEP.defupmax = -0.07
SWEP.deflmax = 0.05
SWEP.deflmin = -0.02
SWEP.Iterator = 0
SWEP.TracerName = "dmr4"
SWEP.WalkSpeed = SPEED_NORMAL --手持武器时的移动速度
--recoil stages

SWEP.HoldType = "ar2" --武器第三人称的持枪动画
SWEP.IronSightsHoldType = "ar2" --机瞄的持枪动画

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
	inconemax = self.ConeMax --这个是用来记录使用镭射瞄准前的武器扩散数据
	inconemin = self.ConeMin --同上
    
	self:SetWeaponHoldType(self.HoldType) --设置武器持枪
    if CLIENT then

        // Create a new table for every weapon instance
        self.VElements = table.FullCopy( self.VElements )
        self.WElements = table.FullCopy( self.WElements )
        self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
        self:CreateModels(self.VElements) // create viewmodels
        self:CreateModels(self.WElements) // create worldmodels
         if IsValid(self.Owner) then
            local vm = self.Owner:GetViewModel()
            if IsValid(vm) then
                self:ResetBonePositions(vm)
            end
        end
    end
	GAMEMODE:DoChangeDeploySpeed(self)
	-- 高阶枪自动交换为优先级高于低等级的枪。
	
	if self.Weight and self.Tier then
		self.Weight = self.Weight + self.Tier
	end

	-- 也许我们不想将武器转换为新系统...
	if self.Cone then
		self.ConeMin = self.ConeIronCrouching
		self.ConeMax = self.ConeMoving
		self.ConeRamp = 2
	end
end


function SWEP:Reload()
    local owner = self:GetOwner()--获取武器持有者
    if not self:CanReload() then return end
	if owner:IsHolding() then return end
	if self.FN < CurTime() and self:Clip1()<self.Primary.ClipSize then
        self.A = 0
        self:EmitSound(Sound("weapons/plasma/laserChargeNew.wav"),50,100)
        self.FN = CurTime()+2.1
        timer.Simple(0.1,function()
            self.targetoffset = -5
            self.Owner:ViewPunch(Angle(1,0,0))
        end)
        timer.Simple(0.2,function()
            self.targetoffset2 = -5
            self.Owner:ViewPunch(Angle(-1,-2,0))
        end)
        timer.Simple(0.9,function()
            self.targetoffset2 = 0
            self.Owner:ViewPunch(Angle(0.5,0.5,0))
        end)
        timer.Simple(1.1,function()
            self.targetoffset = 0
            self.Owner:ViewPunch(Angle(-1,0,0))
        end)
        self.Spin = self.Spin /2
        self.Owner:SetFOV(0,0.1)
        self.REC = 0
        self.Weapon:DefaultReload( ACT_VM_RELOAD )
    end
end

function SWEP:ShootEffects()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		-- View model animation						-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				-- 3rd Person Animation
end

function SWEP:Think()
	if self.Spin > 0 then
		self.Spin = self.Spin - 0.009
	end
	if self.Owner:KeyDown(IN_ATTACK2) then
		self.acc = 2
		self.Owner:SetFOV(60,0.1)
	else
		self.acc = 1
		self.Owner:SetFOV(0,0.1)
	end
	if self.Owner:KeyReleased(IN_ATTACK) and self:Clip1()>0 then self:EmitSound(Sound("weapons/laserrifle/end2.wav"),85,100) end
	if self:Clip1()>0 then 
		self.Full = true 
	end
	if self.Full == true and self:Clip1()==0 then 
		self:EmitSound(Sound("weapons/laserrifle/end2.wav"),85,100)
		self.Full = false 
	end
	if self.Full then end
	self.VElements["barrel"].material = self:GetMaterial()
	self.VElements["b3"].material = self:GetMaterial()
	self.WElements["barrel"].material = self:GetMaterial()
	self.WElements["b3"].material = self:GetMaterial()

	self.VElements["vent"].pos = Vector(0, -0.245, -10.36-self.VO)
	self.VElements["prong"].pos = Vector(-0.576, 0.312, 20.052-self.VX)

	if self.A < 0 then 
        self.A = 0 
    end
	if self.A > 0 then 
        self.A = self.A - 20 
    end
	if self.VO > 0 then 
        self.VO = self.VO - 2.1 
    end
	if self.VX > 0 then 
        self.VX = self.VX - 0.13 
    end
	if CLIENT then
		self:DoAnims()
		self.punch = Lerp(RealFrameTime()*2,self.punch,self.REC*10)
	end
	if CurTime()>(self.LastFire+0.3) then
		self.REC = 0
		self.Iterator = 0
		self.upmax = self.defupmax
		self.lmax = self.deflmax
		self.lmin = self.deflmin
	end
end


function SWEP:SecondaryAttack()
	if(!self:CanSecondaryAttack()) or self.Owner:KeyDown(IN_USE)~=true then return end
	if self:Clip1() < 6 then return end

	self:TakePrimaryAmmo(6)
	self:ShootEffects()
	local ang = Angle( math.Rand(-0.2,-0.2) * (1), math.Rand(-0.1,0.1), math.Rand(-0.5,0.5) )
	local muzzlepos = self.Owner:GetShootPos() + (self.Owner:GetForward()*50)
	self:EmitSound(Sound("weapons/carbine_long/fire"..math.random(1,5)..".wav"),88,math.Rand(110,120))
	--[[
	if SERVER then
		local plasma = ents.Create("bolt2")
		plasma:SetPos(muzzlepos)
		plasma:SetOwner(self:GetOwner())

		plasma:Spawn()
		local phys = plasma:GetPhysicsObject()
		if self.Owner:IsOnGround() then 
            phys:ApplyForceCenter((self.Owner:GetAimVector()+Vector(math.Rand(0.05,-0.05),math.Rand(0.05,-0.05),0.07+(self.Owner:GetViewPunchAngles().pitch*-1)/50)) * 7900 ) 
        end
		if not self.Owner:IsOnGround() then 
            phys:ApplyForceCenter((self.Owner:GetAimVector()+Vector(math.Rand(0.15,-0.15),math.Rand(0.15,-0.15),(math.Rand(0.1,-0.1)+0.07)+(self.Owner:GetViewPunchAngles().pitch*-1)/50)) * 7900 ) 
        end

	end
	]]
	self:ShootBullets(self.Primary.Damage * 9, self.Primary.NumShots, self:GetCone()) --射出子弹，里面的参数为伤害，子弹数量，瞄准的位置
	self.Owner:ViewPunch(ang * 6.65)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self.Owner:MuzzleFlash()
	local ch = math.Round(math.Rand(0,1))

	self.RR = math.Rand(100,155)
	self.RG = math.Rand(100,155)
	self.RB = math.Rand(200,255)
	if self.Spin < 2 then
		self.Spin = self.Spin + 0.55
	end
	self.A = 240
	self.VO = 7
	self.VX = 9
	self.punch = 30
end

function SWEP:EmitFireSound()
	self:EmitSound(Sound("weapons/laserrifle/fire2.wav"),85,100)  
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end --防止不能开火时开火
	if self.FN > CurTime() then return end

	local ang = Angle( math.Rand(-0.2,-0.2) * (self.Primary.Recoil/self.acc), math.Rand(-0.1,0.1)/self.acc, math.Rand(-0.5,0.5)/self.acc )
	

	self:EmitFireSound() --播放武器开火声音
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone()) --射出子弹，里面的参数为伤害，子弹数量，瞄准的位置

	if self.Owner:KeyDown(IN_ATTACK2)==false then
		self:ShootEffects()
	else
		self.offset = -1.5
	end

	if SERVER then
		for k, v in pairs(player.GetAll()) do
			if v~=self.Owner then
				pos = self.Owner:GetPos()
			end
		end
	end

	
    if self.Owner:Crouching() then 
        self.Owner:ViewPunch( ang * (0.55+0)) 
    end
	if not self.Owner:Crouching() then 
        self.Owner:ViewPunch(ang * math.Clamp((0.68+0),0,1.75)) 
    end
    
	if SERVER then
		self:TakePrimaryAmmo(1)
	end
	if CLIENT and IsFirstTimePredicted() then
		self:TakePrimaryAmmo(1)
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:MuzzleFlash()
	local ch = math.Round(math.Rand(0,1))

	self.RR = math.Rand(100,155)
	self.RG = math.Rand(100,155)
	self.RB = math.Rand(200,255)
	if self.Spin < 2 then
		self.Spin = self.Spin + 0.55
	end
	self.Owner:LagCompensation(false)
	self.A = 240
	self.VO = 7
	if CLIENT and IsFirstTimePredicted() then
		self.Iterator = self.Iterator+1
		self.REC = self.REC + 0.5
	end
	self.LastFire = CurTime()
	self.punch = 1 + self.REC * 2
end

function SWEP:FireAnimationEvent( pos, ang, event, options )

	-- Disables animation based muzzle event
	if ( event == 21 ) then return true end
	if ( event == 20 ) then return true end

	-- Disable thirdperson muzzle flash
	if ( event == 5001 ) then return true end
	if ( event == 5003 ) then return true end
	if ( event == 5011 ) then return true end
	if ( event == 5021 ) then return true end
	if ( event == 5031 ) then return true end
	if ( event == 6001 ) then return true end

end


function SWEP:DoDrawCrosshair( x, y )
	if self.Sighting == false and self.Owner:KeyDown(IN_ATTACK2) then
		self.Sighting = true

		self.Owner:EmitSound(Sound("weapons/player_archer_ads_up.wav"),60,100)
		timer.Simple(0.13,function() self.SightOffset=-0.6 end)
		timer.Simple(0.32,function() self.SightOffset2=-9 end)
	end
	if self.Sighting == true and self.Owner:KeyDown(IN_ATTACK2)==false then
		self.Sighting = false
		self.Owner:EmitSound(Sound("weapons/player_archer_ads_down.wav"),60,100)
		timer.Simple(0.256,function() self.SightOffset=0 end)
		timer.Simple(0.1,function() self.SightOffset2=0 end)
	end
	--surface.SetDrawColor( 0, 250, 255, 255 )
	self.reloadoffset = Lerp(RealFrameTime()*15,self.reloadoffset,self.targetoffset)
	self.reloadoffset2 = Lerp(RealFrameTime()*15,self.reloadoffset2,self.targetoffset2)
	self.RSO1 = Lerp(RealFrameTime()*20,self.RSO1,self.SightOffset)
	self.RSO2 = Lerp(RealFrameTime()*20,self.RSO2,self.SightOffset2)
	self.VElements["barrel"].pos = Vector(0, -1.719, -18.504)+Vector(0,self.reloadoffset/4,self.reloadoffset2*2)
	self.VElements["top2"].pos = Vector(0, -2.698, -7.529)+Vector(0,self.reloadoffset/4,self.reloadoffset2*-2)+Vector(0,self.RSO1,self.RSO2)
	self.VElements["vent"].pos = Vector(0, -0.245, -10.36)+Vector(0,0,self.reloadoffset)
	self.VElements["b1"].pos = Vector(0, -2.52, -5.335)+Vector(0,self.reloadoffset*-0.2,0)
	self.VElements["b3"].pos = Vector(-0.075, -0.306, -23.323)+Vector(0,0,self.reloadoffset2)
	local reflex = self.VElements["relexfront"]
	self.VElements["reflexfront"].draw_func = function(weapon)
		local accusight = util.IntersectRayWithPlane(EyePos(),EyeAngles():Forward(),self.VElements["reflexfront"].info.pos,EyeAngles():Forward()*-1)
		accusight = WorldToLocal(accusight,Angle(0,0,0),self.VElements["reflexfront"].info.pos,EyeAngles())
		--draw.DrawText(util.TypeToString(accusight),"DermaDefault",0,0,Color(255,255,255,255))
		draw.RoundedBox(0,math.Clamp(accusight.y*-400,0,90)-140,math.Clamp(accusight.z*-400,0,180)-90,280,180,Color(10,10,10,70))
		draw.RoundedBox(0,math.Clamp(accusight.y*-400,0,90)-140,math.Clamp(accusight.z*-400,0,180)-90,80,35,Color(10,10,10,140))
		draw.DrawText("弹容: "..self:Clip1(),"DermaDefault",math.Clamp(accusight.y*-400,0,90)-130,math.Clamp(accusight.z*-400,0,180)-80,Color(200,200,200,220))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),30,Color(0,255,0,200))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),31,Color(0,255,0,200))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),32,Color(0,255,0,200))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),40,Color(0,255,0,100))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),41,Color(0,255,0,100))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),42,Color(0,255,0,100))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),50,Color(0,255,0,30))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),51,Color(0,255,0,30))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,90),math.Clamp(accusight.z*-400,0,180),52,Color(0,255,0,30))
	end
	reflex = self.VElements["relexback"]
	self.VElements["reflexback"].draw_func = function(weapon)
		local accusight = util.IntersectRayWithPlane(EyePos(),EyeAngles():Forward(),self.VElements["reflexback"].info.pos,EyeAngles():Forward()*-1)
		accusight = WorldToLocal(accusight,Angle(0,0,0),self.VElements["reflexback"].info.pos,EyeAngles())
		draw.RoundedBox(0,math.Clamp(accusight.y*-400,0,120)-90,math.Clamp(accusight.z*-400,-120,180)-90,180,180,Color(50,150,50,10))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,120),math.Clamp(accusight.z*-400,-120,120),14,Color(50,255,50,130))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,120),math.Clamp(accusight.z*-400,-120,120),15,Color(50,255,50,130))
		surface.DrawCircle(math.Clamp(accusight.y*-400,0,120),math.Clamp(accusight.z*-400,-120,120),16,Color(50,255,50,130))
	end
	self.ConeMod = Lerp(RealFrameTime()*3,self.ConeMod,self.Primary.Cone+(self.Owner:GetVelocity():Length()/7000)*400)
	local xoff = self.crosshairang.y
	local yoff = self.crosshairang.p
	--[[
    if not self.Sighting then
		draw.RoundedBox(0,(x+xoff)-((11+(self.ConeMod+1))+self.punch),(y+yoff)-2,7,4,Color(0,0,0,255))
		draw.RoundedBox(0,(x+xoff)+((3+(self.ConeMod+1))+self.punch),(y+yoff)-2,7,4,Color(0,0,0,255))
		draw.RoundedBox(0,(x+xoff)-2,(y+yoff)-((11+(self.ConeMod+1))+self.punch),4,7,Color(0,0,0,255))
		draw.RoundedBox(0,(x+xoff)-2,(y+yoff)+((3+(self.ConeMod+1))+self.punch),4,7,Color(0,0,0,255))
		draw.RoundedBox(0,(x+xoff)-((10+(self.ConeMod+1))+self.punch),(y+yoff)-1,5,2,Color(0,220,255,255))
		draw.RoundedBox(0,(x+xoff)+((4+(self.ConeMod+1))+self.punch),(y+yoff)-1,5,2,Color(0,220,255,255))
		draw.RoundedBox(0,(x+xoff)-1,(y+yoff)-((10+(self.ConeMod+1))+self.punch),2,5,Color(0,220,255,255))
		draw.RoundedBox(0,(x+xoff)-1,(y+yoff)+((4+(self.ConeMod+1))+self.punch),2,5,Color(0,220,255,255))
		draw.DrawText("CLIP: "..self:Clip1(),"DermaDefault",(x+xoff+20),y+yoff+20,Color(255,255,255,255))
	end
    ]]
	self:DoAnims()
	self.offset = Lerp(RealFrameTime()*10,self.offset,0)
    if not self.Sighting then
        self:DrawWeaponCrosshair()
    end
	--self.Owner:GetViewModel(0):SetMaterial("models/weapons/v_smg1/texture5")
	return true
end
