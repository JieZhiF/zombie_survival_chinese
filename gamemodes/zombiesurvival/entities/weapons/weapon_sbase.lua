AddCSLuaFile()

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378


	DESCRIPTION:
		This script is meant for experienced scripters
		that KNOW WHAT THEY ARE DOING. Dont come to me
		with basic Lua questions.

		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()
	// other initialize code goes here
	self:SetHoldType(self.HoldType)
	if CLIENT then

		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels

		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end
		end

	end

end

function SWEP:Holster()

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
		self:CleanupCLModels(self.VElements)
		if self.WElements~=nil then self:CleanupCLModels(self.WElements) end
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:CleanupCLModels(tbl)
	if SERVER then return end
	for k, v in pairs(tbl) do
		if v.modelEnt~=nil then
			SafeRemoveEntity(v.modelEnt)
		end
	end
end

if CLIENT then


	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()

		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.info = {pos=drawpos,angle=ang}
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we cant do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or youll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

end


SWEP.Base               = "weapon_base"
SWEP.WElements = {}
SWEP.VElements = {}
SWEP.offset = 0
SWEP.IronSightAng = Angle(0,0,0)
SWEP.IronSightPos = Vector(0,0,0)
SWEP.IronPos = Vector(0,0,0) -- dont edit this
SWEP.IronAng = Angle(0,0,0) -- dont edit this
SWEP.InspectSpeed = 1
SWEP.IronSpeed = 3
SWEP.InspectOnDeploy = false
SWEP.DeployInspectTime = 5
SWEP.Inspect = {
	{pos = Vector(0,0,0), ang = Angle(0,0,0), time = -1}, //default inspect position is the default position
}
SWEP.BoneInspect = {
	{
		{pos = Vector(0,0,0), ang = Angle(0,0,0),bone = "default"}, //allows you to manipulate the C model bones
	}
}
SWEP.Breath = 0
SWEP.Breathmult = 1
SWEP.IronEnable = true
SWEP.deploytime = 0
SWEP.Dist1Range = 500
SWEP.Dist2Range = 1000
SWEP.Dist3Range = 2000
SWEP.Dist4Range = 10000

function SWEP:PlayDRSound(sound1,distpath,pitch,range,overlap)
	if overlap == nil then
		overlap = false
	end
	local pos = self.Owner:GetPos()
	local distance = pos:Distance(self.Owner:GetPos())
	local dist = 1
	if distance > self.Dist1Range and distance < self.Dist2Range then dist = 2 end
	if distance > self.Dist2Range and distance < self.Dist3Range then dist = 3 end
	if distance > self.Dist3Range then dist = 4 end
	if CLIENT and IsFirstTimePredicted() then
		if overlap then
			sound.Play(Sound(sound1),self:GetPos(),85,pitch,1)
			sound.Play(Sound(distpath.."/dist1_"..math.random(1,3)..".wav"),self:GetPos(),85,pitch,1)
		end
		if !overlap then self:EmitSound(Sound(sound1),85,pitch) end
	end
	if SERVER then
		for k, v in pairs(player.GetAll()) do
			if v~=self.Owner then
				local distance = self.Owner:GetPos():Distance(v:GetPos())
				pos = v:GetPos()+(self.Owner:GetPos()-v:GetPos()):Angle():Forward()*(distance/8)
				if distance < 1000 then pos = self.Owner:GetPos() end
				--local dist = 1
				--if distance > self.Dist1Range and distance < self.Dist2Range then dist = 2 end
				--if distance > self.Dist2Range and distance < self.Dist3Range then dist = 3 end
				--if distance > self.Dist3Range then dist = 4 end
				local vol1 = 1
				local vol2 = 1
				local vol3 = 1
				local vol4 = 1
				vol1 = self.Dist1Range / (distance * 3)
				vol2 = self.Dist2Range / ((distance * 3) + self.Dist2Range)
				vol3 = self.Dist3Range / ((distance * 3) + self.Dist3Range)
				vol4 = self.Dist4Range / ((distance * 3) + self.Dist4Range)
				vol1 = math.Clamp(vol1,0,1)
				vol2 = math.Clamp(vol2,0,1)
				vol3 = math.Clamp(vol3,0,1)
				vol4 = math.Clamp(vol4,0,1)
				if v:Nick()=="Seris" then
					--print(math.Round(distance,3),math.Round(vol1,3),math.Round(vol2,3),math.Round(vol3,3),math.Round(vol4,3))
				end
				v:SendLua("local fsound = Sound('"..distpath.."/dist1_"..math.random(1,3)..".wav') sound.Play(fsound,Vector("..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z).."),"..range..","..pitch..","..vol1..")")
				v:SendLua("local fsound = Sound('"..distpath.."/dist2_"..math.random(1,3)..".wav') sound.Play(fsound,Vector("..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z).."),"..range..","..pitch..","..vol2..")")
				v:SendLua("local fsound = Sound('"..distpath.."/dist3_"..math.random(1,3)..".wav') sound.Play(fsound,Vector("..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z).."),"..range..","..pitch..","..vol3..")")
				v:SendLua("local fsound = Sound('"..distpath.."/dist4_"..math.random(1,3)..".wav') sound.Play(fsound,Vector("..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z).."),"..range..","..pitch..","..vol4..")")
			end
		end
	end
end

if CLIENT then
	local key = 1
	local keytime = 0
	local hands = nil

	hook.Add("PostDrawPlayerHands","UpdateSWEPHands",function(han,vm,ply,wpn)
		if ply:Alive() then
			if han ~= nil then
				hands = han
			end
		end
	end)



	for k ,v in pairs(SWEP.BoneInspect) do //add extra variables to all bones so that we dont have to modify the original bone positions
		for f, b in pairs(v) do
			b.modv = Vector(0,0,0)
			b.moda = Angle(0,0,0)
		end
	end

	function SWEP:Deploy()
		if self.InspectOnDeploy == true then
			self.deploytime = CurTime()+self.DeployInspectTime
		end
		self:CreateModels(self.VElements)
		return true
	end
	function SWEP:DoAnims() //call this function from the child sweps think hook to enable iron sights, inspecting, and 'breathing' viewmodel shifting
		//check to see if the models are valid or nil
		local check = true
		if self.VElements~=nil then
			for k, v in pairs(self.VElements) do
				if check == true then
					if v.modelEnt==nil then
						self:CreateModels(self.VElements)
						check = false
					end
				end
			end
		end
		check = true
		if self.WElements~=nil then
			for k, v in pairs(self.WElements) do
				if check == true then
					if v.modelEnt==nil then
						self:CreateModels(self.WElements)
						check = false
					end
				end
			end
		end

		if self.Owner:KeyDown(IN_ATTACK2) and self.IronEnable then //do ironsighting first to allow it to override inspecting
			self.IronPos.x = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.x,self.IronSightPos.x)
			self.IronPos.y = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.y,self.IronSightPos.y)
			self.IronPos.z = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.z,self.IronSightPos.z)
			self.IronAng = LerpAngle(RealFrameTime()*self.IronSpeed,self.IronAng,self.IronSightAng)
			self.Breath = math.sin(CurTime())/(self.Breathmult*80)
			self.SwayScale = 0.0 //decreases swep viewmodel sway while scoping
         	self.BobScale = 0.0 //decreases swep viewemodel bob while scoping
		elseif (input.IsKeyDown(KEY_G) or self.deploytime > CurTime()) and not input.IsMouseDown(MOUSE_LEFT) then //does inspecting while the G key is pressed down. this key is used because by default garrysmod does not bind G to any function.
			self.Breath = math.sin(CurTime())/(self.Breathmult*4) //simple sine function
			self:DoInspect() //calls inspecting
		else //reset to default position when doing nothing
			self.IronPos.x = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.x,0)
			self.IronPos.y = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.y,0)
			self.IronPos.z = Lerp(RealFrameTime()*self.IronSpeed,self.IronPos.z,0)
			self.IronAng = LerpAngle(RealFrameTime()*self.IronSpeed,self.IronAng,Angle(0,0,0))
			self.Breath = math.sin(CurTime())/(self.Breathmult*4)
			self.SwayScale = 1
         	self.BobScale = 1
			keytime = 0
			key = 1
		end
		local pos = self.Owner:GetViewModel(0):GetPos()
		local ang = self.Owner:GetViewModel(0):GetAngles()
		self:GetViewModelPosition(pos,ang)
	end

	function SWEP:GetViewModelPosition(Pos,Ang)
		local tmp = Ang
		Ang:RotateAroundAxis(EyeAngles():Forward(),self.IronAng.p) //rotate the shit
		Ang:RotateAroundAxis(EyeAngles():Up(),self.IronAng.y)
		Ang:RotateAroundAxis(EyeAngles():Right(),self.IronAng.r)

		return Pos+(tmp:Forward()*(self.offset+self.IronPos.x))+(tmp:Right()*self.IronPos.y)+(tmp:Up()*(self.IronPos.z+self.Breath)),Ang+Angle((self.offset+10)/3,0,0)
	end

	function SWEP:DoInspect()
		local info = self.Inspect[key]
		local Bones = self.BoneInspect[key]
		if keytime == 0 then
			keytime = CurTime()+self.Inspect[key].time
		end
		if CurTime() > keytime and info.time > 0 then
			key = key + 1
			keytime = CurTime()+self.Inspect[key].time
		end
		self.keyframe=key
		self.IronPos = self:LerpCurveVec(1,self.IronPos,info.pos)
		self.IronAng = self:LerpCurveAng(1,self.IronAng,info.ang)

	end

	function SWEP:LerpCurveVec(a,b,c)
		return LerpVector( self:inv_lerp( 1, -1, math.cos( ((CurTime()-(keytime-self.Inspect[key].time))/(self.Inspect[key].time)) / self.InspectSpeed)), b, c)
	end
	function SWEP:LerpCurveAng(a,b,c)
		return LerpAngle( self:inv_lerp( 1, -1, math.cos( ((CurTime()-(keytime-self.Inspect[key].time))/(self.Inspect[key].time)) / self.InspectSpeed)), b, c)
	end
	function SWEP:inv_lerp(a,b,c)
    	return (c-a)/(b-a)
	end
	hook.Remove("PostDrawPlayerHands","bonemanip")
	hook.Add("PostDrawPlayerHands","bonemanip",function(hands,vm,ply,wep)
		--print(hands:LookupBone("ValveBiped.Bip01_L_Hand"))
		--hands:ManipulateBoneAngles(3,Angle(90,0,0))
		--print(hands:HasBoneManipulations())
		if wep:IsScripted() then
			if wep.Base == "weapon_sbase" and IsValid(wep.BoneInspect) then
				for k, v in pairs(wep.BoneInspect) do
					for f, b in pairs(v) do
						local blookup = b.bone
						local binfo = wep.BoneInspect[k][f]
						if blookup ~= nil then
							if hands:LookupBone(blookup) ~= nil and #wep.BoneInspect > 1 and b.modv~=nil and b.moda~=nil then
								b.modv = wep:LerpCurveVec(1,b.modv,b.pos)
								b.moda = wep:LerpCurveAng(1,b.moda,b.ang)
								--hands:SetBonePosition(hands:LookupBone(b.bone),b.modv,b.moda)
								hands:SetBonePosition(hands:LookupBone(b.bone),b.modv,b.moda)
							end
						end
					end
				end
			end
		end
	end)
end


function SWEP:GetIronsights()
	return self:GetDTBool(0)
end
function SWEP:PreDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(0)
	end
end

function SWEP:PostDrawViewModel(vm)
	if self.ShowViewModel == false then
		render.SetBlend(1)
	end

	if self.HUD3DPos and GAMEMODE:ShouldDraw3DWeaponHUD() then
		local pos, ang = self:GetHUD3DPos(vm)
		if pos then
			self:Draw3DHUD(vm, pos, ang)
		end
	end
end
SWEP.NoDismantle = false
SWEP.PermitDismantle = true
SWEP.AllowQualityWeapons = true
function SWEP:GetHUD3DPos(vm)
	local bone = vm:LookupBone(self.HUD3DBone)
	if not bone then return end

	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	if self.ViewModelFlip then
		ang.r = -ang.r
	end

	local offset = self.HUD3DPos
	local aoffset = self.HUD3DAng

	pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z

	if aoffset.yaw ~= 0 then ang:RotateAroundAxis(ang:Up(), aoffset.yaw) end
	if aoffset.pitch ~= 0 then ang:RotateAroundAxis(ang:Right(), aoffset.pitch) end
	if aoffset.roll ~= 0 then ang:RotateAroundAxis(ang:Forward(), aoffset.roll) end

	return pos, ang
end

local colBG = Color(16, 16, 16, 90)
local colRed = Color(220, 0, 0, 230)
local colYellow = Color(220, 220, 0, 230)
local colWhite = Color(220, 220, 220, 230)
local colAmmo = Color(255, 255, 255, 230)
local function GetAmmoColor(clip, maxclip)
	if clip == 0 then
		colAmmo.r = 255 colAmmo.g = 0 colAmmo.b = 0
	else
		local sat = clip / maxclip
		colAmmo.r = 255
		colAmmo.g = sat ^ 0.3 * 255
		colAmmo.b = sat * 255
	end
end

function SWEP:GetDisplayAmmo(clip, spare, maxclip)
	if self.RequiredClip ~= 1 then
		clip = math.floor(clip / self.RequiredClip)
		spare = math.floor(spare / self.RequiredClip)
		maxclip = math.ceil(maxclip / self.RequiredClip)
	end

	if self.AmmoUse then
		clip = math.floor(clip / self.AmmoUse)
		spare = math.floor(spare / self.AmmoUse)
		maxclip = math.ceil(maxclip / self.AmmoUse)
	end

	return clip, spare, maxclip
end

function SWEP:Draw3DHUD(vm, pos, ang)
	local wid, hei = 180, 200
	local x, y = wid * -0.6, hei * -0.5
	local clip = self:Clip1()
	local spare = self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
	local maxclip = self.Primary.ClipSize

	local dclip, dspare, dmaxclip = self:GetDisplayAmmo(clip, spare, maxclip)

	cam.Start3D2D(pos, ang, self.HUD3DScale / 2)
		draw.RoundedBoxEx(32, x, y, wid, hei, colBG, true, false, true, false)

		local displayspare = dmaxclip > 0 and self.Primary.DefaultClip ~= 99999
		if displayspare then
			draw.SimpleTextBlurry(dspare, dspare >= 1000 and "ZS3D2DFontSmall" or "ZS3D2DFont", x + wid * 0.5, y + hei * 0.75, dspare == 0 and colRed or dspare <= dmaxclip and colYellow or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		GetAmmoColor(dclip, dmaxclip)
		draw.SimpleTextBlurry(dclip, dclip >= 100 and "ZS3D2DFont" or "ZS3D2DFontBig", x + wid * 0.5, y + hei * (displayspare and 0.3 or 0.5), colAmmo, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function SWEP:GetPrimaryClipSize()
	local owner = self:GetOwner() --获取持有者
	local multi = self.Primary.ClipSize/self.RequiredClip >= 8 and owner:HasTrinket("extendedmag") and 1.15 or 1 --倍数，这里要蛮赞两个条件，主弹匣数量除以需要的数量大于等于8和持有者有扩展弹匣的BUFF

	return math.floor(self:GetMaxClip1() * multi) --返回取整数
end



SWEP.DryFireSound = Sound("Weapon_Pistol.Empty") --没子弹时开火的声音
SWEP.RequiredClip = 1 --一次开火需要的子弹，数越高打一次子弹消耗越快
SWEP.ConeMax = 1.5 --最大准星扩散
SWEP.ConeMin = 0.5 --最小准星扩散
SWEP.ConeRamp = 2
SWEP.HoldType = "ar2"
SWEP.IronSightsHoldType = "ar2"
SWEP.WalkSpeed = SPEED_NORMAL --手持武器时的移动速度
SWEP.ReloadSpeed = 1
function SWEP:GetCone()
	local owner = self:GetOwner()

	local basecone = self.ConeMin
	local conedelta = self.ConeMax - basecone

	local orphic = not owner.Orphic and 1 or self:GetIronsights() and 0.9 or 1.1
	local tiervalid = (self.Tier or 1) <= 3
	local spreadmul = (owner.AimSpreadMul or 1) - ((tiervalid and owner:HasTrinket("refinedsub")) and 0.27 or 0)

	if owner.TrueWooism then
		return (basecone + conedelta * 0.5 ^ self.ConeRamp) * spreadmul * orphic
	end

	if not owner:OnGround() or self.ConeMax == basecone then return self.ConeMax end

	local multiplier = math.min(owner:GetVelocity():Length() / self.WalkSpeed, 1) * 0.5

	local ironsightmul = 0.25 * (owner.IronsightEffMul or 1)
	local ironsightdiff = 0.25 - ironsightmul
	multiplier = multiplier + ironsightdiff

	if not owner:Crouching() then multiplier = multiplier + 0.25 end
	if not self:GetIronsights() then multiplier = multiplier + ironsightmul end

	return (basecone + conedelta * (self.FixedAccuracy and 0.6 or multiplier) ^ self.ConeRamp) * spreadmul * orphic
end

function SWEP:SetIronsights(b)
	self:SetDTBool(0, b)

	if self.IronSightsHoldType then
		if b then
			self:SetWeaponHoldType(self.IronSightsHoldType)
		else
			self:SetWeaponHoldType(self.HoldType)
		end
	end

	gamemode.Call("WeaponDeployed", self:GetOwner(), self)
end
function SWEP:CanReload()
	return self:GetNextReload() <= CurTime() and self:GetReloadFinish() == 0 and
		(
			self:GetMaxClip1() > 0 and self:Clip1() < self:GetPrimaryClipSize() and self:ValidPrimaryAmmo() and self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) > 0
			or self:GetMaxClip2() > 0 and self:Clip1() < self:GetMaxClip2() and self:ValidSecondaryAmmo() and self:GetOwner():GetAmmoCount(self:GetSecondaryAmmoType()) > 0
		)
end

function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	if self:Clip1() < self.RequiredClip then
		self:EmitSound(self.DryFireSound)
		self:SetNextPrimaryFire(CurTime() + math.max(0.25, self.Primary.Delay))
		return false
	end

	return self:GetNextPrimaryFire() <= CurTime()
end


local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]      	= ACT_HL2MP_IDLE_DUEL,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA
}

function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ActIndex[ t ]

	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal) (from "..self:GetClass()..")\n" )
		t = "normal"
		index = ActIndex[ t ]
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM_IDLE ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= index+9

	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end

	-- these two aren't defined in ACTs for whatever reason
	if t == "knife" or t == "melee2" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = nil
	end
end

SWEP:SetWeaponHoldType("pistol")


function SWEP:TranslateActivity(act)
	if self:GetIronsights() and self.ActivityTranslateIronSights then
		return self.ActivityTranslateIronSights[act] or -1
	end

	return self.ActivityTranslate and self.ActivityTranslate[act] or -1
end



function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	owner:DoAttackEvent()

	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end

	owner:LagCompensation(true)
	owner:FireBulletsLua(owner:GetShootPos(), owner:GetAimVector(), cone, numbul, dmg, nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false)

	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end
end
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end


function SWEP:EmitReloadSound()
	if self.ReloadSound and IsFirstTimePredicted() then
		self:EmitSound(self.ReloadSound, 75, 100, 1, CHAN_WEAPON + 21)
	end
end

function SWEP:ProcessReloadEndTime()
	local reloadspeed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()

	self:SetReloadFinish(CurTime() + self:SequenceDuration() / reloadspeed)
	if not self.DontScaleReloadSpeed then
		self:GetOwner():GetViewModel():SetPlaybackRate(reloadspeed)
	end
end

function SWEP:DrawHUD()
	self:DrawWeaponCrosshair()

	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:Draw2DHUD()
	end
end

function SWEP:Draw2DHUD()
	local screenscale = BetterScreenScale()

	local wid, hei = 180 * screenscale, 64 * screenscale
	local x, y = ScrW() - wid - screenscale * 128, ScrH() - hei - screenscale * 72
	local clip = self:Clip1()
	local spare = self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
	local maxclip = self.Primary.ClipSize

	local dclip, dspare, dmaxclip = self:GetDisplayAmmo(clip, spare, maxclip)

	draw.RoundedBox(16, x, y, wid, hei, colBG)

	local displayspare = dmaxclip > 0 and self.Primary.DefaultClip ~= 99999
	if displayspare then
		draw.SimpleTextBlurry(dspare, dspare >= 1000 and "ZSHUDFontSmall" or "ZSHUDFont", x + wid * 0.75, y + hei * 0.5, dspare == 0 and colRed or dspare <= dmaxclip and colYellow or colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	GetAmmoColor(dclip, dmaxclip)
	draw.SimpleTextBlurry(dclip, dclip >= 100 and "ZSHUDFont" or "ZSHUDFontBig", x + wid * (displayspare and 0.25 or 0.5), y + hei * 0.5, colAmmo, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


function SWEP:FinishReload()
	self:SendWeaponAnim(ACT_VM_IDLE)
	self:SetNextReload(0)
	self:SetReloadStart(0)
	self:SetReloadFinish(0)
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local max1 = self:GetPrimaryClipSize()
	local max2 = self:GetMaxClip2()

	if max1 > 0 then
		local ammotype = self:GetPrimaryAmmoType()
		local spare = owner:GetAmmoCount(ammotype)
		local current = self:Clip1()
		local needed = max1 - current

		needed = math.min(spare, needed)

		self:SetClip1(current + needed)
		if SERVER then
			owner:RemoveAmmo(needed, ammotype)
		end
	end

	if max2 > 0 then
		local ammotype = self:GetSecondaryAmmoType()
		local spare = owner:GetAmmoCount(ammotype)
		local current = self:Clip2()
		local needed = max2 - current

		needed = math.min(spare, needed)

		self:SetClip2(current + needed)
		if SERVER then
			owner:RemoveAmmo(needed, ammotype)
		end
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()--获取武器持有者
	if owner:IsHolding() then return end

	if self:GetIronsights() then --如果换弹时有在机瞄就取消机瞄
		self:SetIronsights(false)
	end

	-- 自定义装填功能以更改装填速度。
	if self:CanReload() then
		self.IdleAnimation = CurTime() + self:SequenceDuration()
		self:SetNextReload(self.IdleAnimation)
		self:SetReloadStart(CurTime())

		self:SendReloadAnimation()
		self:ProcessReloadEndTime()

		owner:DoReloadEvent()

		self:EmitReloadSound() --播放换弹声音
	end
end

function SWEP:ProcessReloadEndTime()
	local reloadspeed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()

	self:SetReloadFinish(CurTime() + self:SequenceDuration() / reloadspeed)
	if not self.DontScaleReloadSpeed then
		self:GetOwner():GetViewModel():SetPlaybackRate(reloadspeed)
	end
end

function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:GetReloadSpeedMultiplier()
	local owner = self:GetOwner()
	local primstring = self:GetPrimaryAmmoTypeString()
	local reloadspecmulti = primstring and "ReloadSpeedMultiplier" .. string.upper(primstring) or nil

	local extramulti = 1
	if owner:HasTrinket("supasm") and (self.Tier or 1) <= 2 and not self.PrimaryRemantleModifier and self.QualityTier then
		extramulti = GAMEMODE.WeaponQualities[self.QualityTier][2]
	end

	return self:GetOwner():GetTotalAdditiveModifier("ReloadSpeedMultiplier", reloadspecmulti) * (owner:GetStatus("frost") and 0.7 or 1) * extramulti * (owner:GetStatus("fastreload") and 1.4 or 1)
end
