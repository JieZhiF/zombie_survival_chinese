INC_CLIENT()

SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false


SWEP.ViewModelFOV = 75

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ShowWorldModelOriginal = false -- 自定义变量避免覆盖
SWEP.VElements={
	["1"]={type="Model",model="models/props_foliage/driftwood_01a.mdl",bone="ValveBiped.Bip01_R_Hand",rel="",pos=Vector(2.674,2.345,1.289),angle=Angle(-100.454,180,88.791),size=Vector(0.019,0.054,0.043),color=Color(100,100,100,255),surpresslightning=false,material="models/shadertest/shader2",skin=0,bodygroup={}},
	["2"]={type="Model",model="models/XQM/cylinderx1.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(4.008,0,0.763),angle=Angle(0,0,0),size=Vector(0.045,0.4,0.3),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
	["2++"]={type="Model",model="models/hunter/tubes/circle2x2d.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(3.9,-0.713,0.769),angle=Angle(0,90,0),size=Vector(0.029,0.949,0.15),color=Color(50,106,255),surpresslightning=false,material="models/props/cs_office/snowmana",skin=0,bodygroup={}},
	["2+++"]={type="Model",model="models/hunter/plates/plate05x1.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(4.61,0,0.763),angle=Angle(90,-90,0.5),size=Vector(0.026,0.025,0.5),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
	["2++++"]={type="Model",model="models/hunter/misc/sphere1x1.mdl",bone="ValveBiped.Bip01_Spine4",rel="1",pos=Vector(-3.658,0,0.779),angle=Angle(90,-90,90),size=Vector(0.045,0.054,0.019),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}}
}
SWEP.WElements={
	["1"]={type="Model",model="models/props_foliage/driftwood_01a.mdl",bone="ValveBiped.Bip01_R_Hand",rel="",pos=Vector(2.674,2.345,0.3),angle=Angle(-100.454,180,88.791),size=Vector(0.019,0.054,0.043),color=Color(100,100,100,255),surpresslightning=false,material="models/shadertest/shader2",skin=0,bodygroup={}},
	["2"]={type="Model",model="models/XQM/cylinderx1.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(4.008,0,0.763),angle=Angle(0,0,0),size=Vector(0.045,0.4,0.3),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
	["2++"]={type="Model",model="models/hunter/tubes/circle2x2d.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(3.9,-0.713,0.769),angle=Angle(0,90,0),size=Vector(0.029,0.75,0.15),color=Color(50,135,255),surpresslightning=false,material="models/props/cs_office/snowmana",skin=0,bodygroup={}},
	["2+++"]={type="Model",model="models/hunter/plates/plate05x1.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(4.61,0,0.763),angle=Angle(90,-90,0.5),size=Vector(0.026,0.025,0.5),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}},
	["2++++"]={type="Model",model="models/hunter/misc/sphere1x1.mdl",bone="ValveBiped.Bip01_R_Hand",rel="1",pos=Vector(-3.658,0,0.779),angle=Angle(90,-90,90),size=Vector(0.045,0.054,0.019),color=Color(178,151,0,255),surpresslightning=false,material="models/player/shared/gold_player",skin=0,bodygroup={}}
}
SWEP.ViewModelBoneMods={["ValveBiped.Bip01_L_UpperArm"]={scale=Vector(1,1,1),pos=Vector(-1,0,0),angle=Angle(0,0,0)}}
SWEP.VMPos = Vector(0,-5, 0)
SWEP.VMAng = Angle(0, 0, 0)

SWEP.DVElements = SWEP.VElements

SWEP.DWElements = SWEP.WElements

local ghostlerp = 0
local lerp = 0
local blocklerp = 0
local attacklerp = 0
function SWEP:GetViewModelPosition(pos, ang)
	local owner = self:GetOwner()
	if self:IsSwinging() then
		local rot = self.SwingRotation
		local offset = self.SwingOffset
		local armdelay = owner:GetMeleeSpeedMul()
		local swingtime = (self:IsCharging() and self.SwingTimeSecondary or self.SwingTime) * (owner.MeleeSwingDelayMul or 1) * armdelay

		ang = Angle(ang.pitch, ang.yaw, ang.roll) -- Copy

		local swingend = self:GetSwingEnd()
		local delta = swingtime - math.Clamp(swingend - CurTime(), 0, swingtime)
		local power = CosineInterpolation(0, 1, delta / swingtime)

		if power >= 0.9 then
			power = (1 - power) ^ 0.4 * 2
		end

		pos = pos + offset.x * power * ang:Right() + offset.y * power * ang:Forward() + offset.z * power * ang:Up()

		ang:RotateAroundAxis(ang:Right(), rot.pitch * power)
		ang:RotateAroundAxis(ang:Up(), rot.yaw * power)
		ang:RotateAroundAxis(ang:Forward(), rot.roll * power)
	end

	if owner:GetBarricadeGhosting() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 5)
	end

	if ghostlerp > 0 then
		pos = pos + 3.5 * ghostlerp * ang:Up()
		ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
	end
    if self:IsBlocking() or self.BlockAnim and self.BlockAnim > CurTime() and self.BlockPos and self.BlockAng then
			--if IsFirstTimePredicted() then
				lerp = math.Approach(lerp, (self:IsBlocking() and 1) or 0, RealFrameTime()*1*((lerp + 1) ^ 3))
			--end
			local rot = self.BlockAng
			local offset = self.BlockPos
			
			ang = Angle(ang.pitch, ang.yaw, ang.roll)
			
			local power = lerp
			
			ang:RotateAroundAxis(ang:Right(), rot.pitch * power)
			ang:RotateAroundAxis(ang:Up(), rot.yaw * power)
			ang:RotateAroundAxis(ang:Forward(), rot.roll * power)
			
			pos = pos + offset.x * power * ang:Right() + offset.y * power * ang:Forward() + offset.z * power * ang:Up()
	end

	return pos, ang
end


function SWEP:PreDrawViewModel(vm)
	self.BaseClass.PreDrawViewModel(self, vm)
	--[[
	for mdl, tab in pairs(self.VElements) do
		tab.material = self:IsCharging() and "models/shiny" or self.DVElements[mdl].material
		tab.color = self:IsCharging() and Color(255, 255, 255, 255) or self.DVElements[mdl].color
	end
	]]
end

function SWEP:DrawWorldModel()
	self.BaseClass.DrawWorldModel(self)
	--[[
	for mdl, tab in pairs(self.WElements) do
		--tab.material = self:IsCharging() and "models/shiny" or self.DWElements[mdl].material
		--tab.color = self:IsCharging() and Color(255, 255, 255, 255) or self.DWElements[mdl].color
	end
	]]
	local owner = self:GetOwner()
	if owner:IsValid() and not owner.ShadowMan then

		local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			if pos then
				if self:IsValid() then
					local rdelta = math.min(0.5, CurTime() - self:GetCharge())

					local force = rdelta * 120
					local resist = force * 0.5
					--pos = pos + ang:Forward() * 15
					pos = pos + ang:Right() * 4
					pos = pos + ang:Up() * math.Rand(-10,-30)

					local curvel = owner:GetVelocity() * 0.5
					local emitter = ParticleEmitter(pos)
					emitter:SetNearClip(24, 48)

					for i=1, math.min(6, math.ceil(FrameTime() * 100)) do
						local particle = emitter:Add("particle/snow", pos)
						particle:SetVelocity(curvel + VectorRand():GetNormalized() * force)
						particle:SetDieTime(0.35)
						particle:SetStartAlpha(rdelta * 125 + 15)
						particle:SetEndAlpha(0)
						particle:SetStartSize(1)
						particle:SetEndSize(rdelta * 5 + 4)
						particle:SetAirResistance(resist)
					end
					emitter:Finish() emitter = nil collectgarbage("step", 64)
				end
			end
		end
	end
end


local texGradDown = surface.GetTextureID("VGUI/gradient_down")
