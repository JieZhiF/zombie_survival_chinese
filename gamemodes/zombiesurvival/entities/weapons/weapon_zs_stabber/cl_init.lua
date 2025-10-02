INC_CLIENT()
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
SWEP.WeaponType = "rifle"
SWEP.SlotGroup = WEPSELECT_RIFLE
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelFOV = 75
SWEP.HUD3DBone = "ValveBiped.garand_base"
SWEP.HUD3DPos = Vector(-2.79, -1.361, 5.834)
SWEP.HUD3DAng = Angle(180, 90, 0)
SWEP.HUD3DScale = 0.022
--[[
SWEP.HUD3DBone = "v_weapon.g3sg1_Parent"
SWEP.HUD3DPos = Vector(-1.5, -5.5, -5)
SWEP.HUD3DAng = Angle(0, 0, 0)
SWEP.HUD3DScale = 0.015


SWEP.VElements = {
	["base+++"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, -0.431, 9.47), angle = Angle(0, 90, 90), size = Vector(0.453, 0.247, 0.291), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/props_pipes/concrete_pipe001a.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, -0.401, -10.211), angle = Angle(90, 0, 0), size = Vector(0.048, 0.009, 0.009), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base+++++++"] = { type = "Model", model = "models/props_c17/signpole001.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, 0.402, -7.619), angle = Angle(0, 180, 180), size = Vector(0.4, 0.4, 0.045), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_c17/light_decklight01_on.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, 0.972, 6.742), angle = Angle(0, 90, -90), size = Vector(0.219, 0.799, 0.071), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base++++++++"] = { type = "Model", model = "models/items/ar2_grenade.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(-0.151, 1.45, -15.332), angle = Angle(-90, 88.5, 90), size = Vector(1.707, 0.69, 0.129), color = Color(180, 180, 200, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
	["base++++++++++++"] = { type = "Model", model = "models/gibs/manhack_gib05.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, 2.158, 13.34), angle = Angle(176.8, 90, 90), size = Vector(0.101, 0.115, 0.342), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++++"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, -0.091, 11.701), angle = Angle(0, 90, 0), size = Vector(0.012, 0.008, 0.026), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++++++"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, -0.826, 10.39), angle = Angle(-180, 90, 0), size = Vector(0.006, 0.006, 0.02), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base+++++++++"] = { type = "Model", model = "models/gibs/hgibs_spine.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, 1.36, 16.593), angle = Angle(180, -180, 179.335), size = Vector(0.791, 0.662, 0.561), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "v_weapon.g3sg1_Parent", rel = "", pos = Vector(0, -5.053, -14.992), angle = Angle(0, 0, 0), size = Vector(0.043, 0.078, 0.308), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base+++++++++++"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(-0.171, 1.807, 13.182), angle = Angle(-180, 90, 90), size = Vector(0.039, 0.035, 0.075), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++++++++++"] = { type = "Model", model = "models/gibs/helicopter_brokenpiece_03.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0.116, 3.184, 23.489), angle = Angle(96.251, -87.704, -53.169), size = Vector(0.159, 0.119, 0.119), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base+++++"] = { type = "Model", model = "models/props_c17/substation_transformer01c.mdl", bone = "v_weapon.g3sg1_Parent", rel = "base", pos = Vector(0, -0.494, 12.083), angle = Angle(0, 0, -26.507), size = Vector(0.014, 0.012, 0.012), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["base+++"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.431, 9.47), angle = Angle(0, 90, 90), size = Vector(0.453, 0.247, 0.291), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/props_pipes/concrete_pipe001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.401, -10.211), angle = Angle(90, 0, 0), size = Vector(0.048, 0.009, 0.009), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base+++++++"] = { type = "Model", model = "models/props_c17/signpole001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0.402, -7.619), angle = Angle(0, 180, 180), size = Vector(0.4, 0.4, 0.045), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/props_c17/light_decklight01_on.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0.972, 6.742), angle = Angle(0, 90, -90), size = Vector(0.219, 0.799, 0.071), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base+++++"] = { type = "Model", model = "models/props_c17/substation_transformer01c.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.494, 12.083), angle = Angle(0, 0, -26.507), size = Vector(0.014, 0.012, 0.012), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++++"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.091, 11.701), angle = Angle(0, 90, 0), size = Vector(0.012, 0.008, 0.026), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base++++++"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -0.826, 10.39), angle = Angle(-180, 90, 0), size = Vector(0.006, 0.006, 0.02), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base+++++++++++"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.171, 1.807, 13.182), angle = Angle(-180, 90, 90), size = Vector(0.039, 0.035, 0.075), color = Color(130, 158, 180, 255), surpresslightning = false, material = "models/props_pipes/guttermetal01a", skin = 0, bodygroup = {} },
	["base"] = { type = "Model", model = "models/props_borealis/bluebarrel001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(18.819, 0.592, -6.156), angle = Angle(0, 90, -79.467), size = Vector(0.043, 0.078, 0.308), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base+++++++++"] = { type = "Model", model = "models/gibs/hgibs_spine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 1.36, 16.593), angle = Angle(180, -180, 179.335), size = Vector(0.791, 0.662, 0.561), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base++++++++++"] = { type = "Model", model = "models/gibs/helicopter_brokenpiece_03.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.116, 3.184, 23.489), angle = Angle(96.251, -87.704, -53.169), size = Vector(0.159, 0.119, 0.119), color = Color(165, 100, 0, 255), surpresslightning = false, material = "models/props_wasteland/wood_fence01a", skin = 0, bodygroup = {} },
	["base++++++++"] = { type = "Model", model = "models/items/ar2_grenade.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.151, 1.45, -15.332), angle = Angle(-90, 88.5, 90), size = Vector(1.707, 0.69, 0.129), color = Color(180, 180, 200, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} }
}
]]
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(2.371, 2.433, 0) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-6.566, -10.653, 3.877) },
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(19.531, 0.202, -5.178) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-32.656, -1.759, -3.086) }
}

SWEP.VElements = {
	["bayonet"] = { type = "Model", model = "models/hunter/triangles/1x1.mdl", bone = "ValveBiped", rel = "bayonet_blade", pos = Vector(-0.289, -3.672, 0), angle = Angle(0, -90, 180), size = Vector(0.02, 0.012, 0.029), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
	["bayonet+"] = { type = "Model", model = "models/hunter/triangles/1x1.mdl", bone = "ValveBiped", rel = "bayonet_blade", pos = Vector(0.28, -3.68, 0), angle = Angle(0, -90, 0), size = Vector(0.02, 0.012, 0.029), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
	["bayonet_base_circle"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped", rel = "bayonet_inside_base", pos = Vector(0, 0, -0.08), angle = Angle(0, 0, 0), size = Vector(0.051, 0.051, 0.051), color = Color(114, 114, 114, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle+++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped", rel = "bayonet_inside_base", pos = Vector(0.014, 0.002, 4.262), angle = Angle(0, 0, 0), size = Vector(0.033, 0.033, 0.008), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped", rel = "bayonet_inside_base", pos = Vector(0.67, 0.001, 4.265), angle = Angle(0, 0, 0), size = Vector(0.04, 0.035, 0.007), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle+++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped", rel = "bayonet_inside_base", pos = Vector(0.014, 0.002, 3.291), angle = Angle(0, 0, 0), size = Vector(0.033, 0.033, 0.008), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle++++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped", rel = "bayonet_inside_base", pos = Vector(0.014, 0.002, 2.331), angle = Angle(0, 0, 0), size = Vector(0.033, 0.033, 0.008), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_blade"] = { type = "Model", model = "models/hunter/plates/plate1x3.mdl", bone = "ValveBiped.garand_base", rel = "", pos = Vector(-1.265, 0.6, 35.756), angle = Angle(0, 0, 90), size = Vector(0.025, 0.045, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
	["bayonet_inside_base"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.garand_base", rel = "", pos = Vector(-1.274, 0.645, 28.183), angle = Angle(-0.185, 0, 0), size = Vector(0.05, 0.05, 0.102), color = Color(205, 90, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/fender_wood", skin = 0, bodygroup = {} },
	["charm_behind"] = { type = "Model", model = "models/props_phx/gears/bevel9.mdl", bone = "ValveBiped", rel = "bayonet_base_circle", pos = Vector(0, 0, 0.164), angle = Angle(180, 0, 0), size = Vector(0.102, 0.102, 0.102), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} }
}
 
SWEP.WElements = {
	["bayonet"] = { type = "Model", model = "models/hunter/triangles/1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_blade", pos = Vector(-0.289, -3.672, 0), angle = Angle(0, -90, 180), size = Vector(0.02, 0.012, 0.029), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
	["bayonet+"] = { type = "Model", model = "models/hunter/triangles/1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_blade", pos = Vector(0.28, -3.68, 0), angle = Angle(0, -90, 0), size = Vector(0.02, 0.012, 0.029), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
	["bayonet_base_circle"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_inside_base", pos = Vector(0, 0, -0.08), angle = Angle(0, 0, 0), size = Vector(0.051, 0.051, 0.051), color = Color(114, 114, 114, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle+++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_inside_base", pos = Vector(0.014, 0.002, 4.262), angle = Angle(0, 0, 0), size = Vector(0.033, 0.033, 0.008), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_inside_base", pos = Vector(0.67, 0.001, 4.265), angle = Angle(0, 0, 0), size = Vector(0.04, 0.035, 0.007), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle+++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_inside_base", pos = Vector(0.014, 0.002, 3.291), angle = Angle(0, 0, 0), size = Vector(0.033, 0.033, 0.008), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_base_circle++++++++"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_inside_base", pos = Vector(0.014, 0.002, 2.331), angle = Angle(0, 0, 0), size = Vector(0.033, 0.033, 0.008), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["bayonet_blade"] = { type = "Model", model = "models/hunter/plates/plate1x3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(35.085, 1.303, -8.181), angle = Angle(-102.036, 0, 90), size = Vector(0.025, 0.045, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
	["bayonet_inside_base"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(28.046, 1.313, -6.659), angle = Angle(77.625, 0, 180), size = Vector(0.05, 0.05, 0.102), color = Color(205, 90, 0, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/fender_wood", skin = 0, bodygroup = {} },
	["charm_behind"] = { type = "Model", model = "models/props_phx/gears/bevel9.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bayonet_base_circle", pos = Vector(0, 0, 0.164), angle = Angle(180, 0, 0), size = Vector(0.102, 0.102, 0.102), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} }
}


local ghostlerp = 0
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	local owner = self:GetOwner()
	if self:IsSwinging() then
		local rot = self.SwingRotation
		local offset = self.SwingOffset
		local armdelay = owner:GetMeleeSpeedMul()
		local swingtime = self.SwingTime * (owner.MeleeSwingDelayMul or 1) * armdelay

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
	elseif CurTime() < self:GetNextSecondaryFire() then
		local rot = -self.SwingRotation * 0.6
		local offset = -self.SwingOffset * 0.5
		local swingtime = 0.2

		ang = Angle(ang.pitch, ang.yaw, ang.roll) -- Copy

		local swingend = self:GetNextSecondaryFire() - 1.25
		local delta = swingtime - math.Clamp(swingend - CurTime(), 0, swingtime)
		local power = math.Clamp(delta / swingtime, 0, 1)

		if power >= 0.85 then
			power = (1 - power) ^ 0.4 * 2
		end

		pos = pos + offset.x * power * ang:Right() + offset.y * power * ang:Forward() + offset.z * power * ang:Up()

		ang:RotateAroundAxis(ang:Right(), rot.pitch * power)
		ang:RotateAroundAxis(ang:Up(), rot.yaw * power)
		ang:RotateAroundAxis(ang:Forward(), rot.roll * power)
	end

	if self:GetOwner():GetBarricadeGhosting() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
	elseif self:GetReloadFinish() > 0 then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 1.2)
	elseif ghostlerp > 0 then
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 4)
	end

	if ghostlerp > 0 and self:GetReloadFinish() > 0 then
		ang:RotateAroundAxis(ang:Right(), -16 * ghostlerp)
	elseif ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
	end

	return pos, ang
end
