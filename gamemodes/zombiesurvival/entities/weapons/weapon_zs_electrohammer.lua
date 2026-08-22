AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_electrohammer")

if CLIENT then
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRepairTools")
	SWEP.SlotGroup = WEPSELECT_REPAIR_TOOL
	SWEP.ViewModelFOV = 90
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VMPos = Vector(1, -10, 2)
	SWEP.VMAng = Angle(0,0,0)

	SWEP.VElements = {
		["hammer"] = { type = "Model", model = "models/weapons/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.048, 1.048, 1.048), color = Color(100, 100, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["hammer+"] = { type = "Model", model = "models/weapons/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.09, 1.09, 1.05), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/props_combine/portalball001_sheet", skin = 0, bodygroup = {} },
		["powerbox"] = { type = "Model", model = "models/props_lab/powerbox02d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0.431, 0.228, 10.017), angle = Angle(180, 0, 0), size = Vector(0.197, 0.197, 0.377), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["sprite"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(-1.094, 0.228, 9.793), size = { x = 4.635, y = 4.635 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["sprite+"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(-1.336, 0.247, 9.793), size = { x = 8.537, y = 8.537 }, color = Color(0, 0, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["teleport_ring"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(0, 0, 3.834), angle = Angle(0, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["teleport_ring+"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "hammer", pos = Vector(0, 0, 7.11), angle = Angle(180, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} }
	}
	
	SWEP.WElements = {
		["hammer"] = { type = "Model", model = "models/weapons/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.048, 1.048, 1.048), color = Color(100, 100, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["hammer+"] = { type = "Model", model = "models/weapons/w_hammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.351, 1.757, 0.265), angle = Angle(180, 180, -4.928), size = Vector(1.09, 1.09, 1.05), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/props_combine/portalball001_sheet", skin = 0, bodygroup = {} },
		["powerbox"] = { type = "Model", model = "models/props_lab/powerbox02d.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0.431, 0.228, 10.017), angle = Angle(180, 0, 0), size = Vector(0.197, 0.197, 0.377), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["sprite"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(-1.094, 0.228, 9.793), size = { x = 4.635, y = 4.635 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["sprite+"] = { type = "Sprite", sprite = "sprites/grav_flare", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(-1.336, 0.247, 9.793), size = { x = 8.537, y = 8.537 }, color = Color(0, 0, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["teleport_ring"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0, 0, 3.834), angle = Angle(0, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
		["teleport_ring+"] = { type = "Model", model = "models/props_lab/teleportring.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hammer", pos = Vector(0, 0, 7.11), angle = Angle(180, 0, 0), size = Vector(0.081, 0.081, 0.081), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_hammer"

SWEP.MeleeDamage = 15    --40
SWEP.HealStrength = 2.25
SWEP.Radius = 125
SWEP.Secondary.Delay = 20
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 100
SWEP.Secondary.Ammo = "pulse"

SWEP.ViewModel = "models/weapons/v_hammer/c_hammer.mdl"
SWEP.WorldModel = "models/weapons/w_hammer.mdl"

SWEP.AllowQualityWeapons = true


function SWEP:PostDrawViewModel(vm, pl, wep)
    local veles = self.VElements
    if not veles then return end

    local ring1ang = veles["teleport_ring"].angle
    local ring2ang = veles["teleport_ring+"].angle
    local rotatespeed = CurTime() * 200 -- velocidad de giro, ajusta el 200 a gusto

    -- Rotamos sobre Pitch (X)
    ring1ang.y = (rotatespeed) % 360
    ring2ang.y = (rotatespeed) % 360

    if self.BaseClass.PostDrawViewModel then
        self.BaseClass.PostDrawViewModel(self, vm, pl, wep)
    end
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if owner:IsValid() and owner.ShadowMan then return end

    local weles = self.WElements
    if not weles then return end

    local ring1ang = weles["teleport_ring"].angle
    local ring2ang = weles["teleport_ring+"].angle
    local rotatespeed = CurTime() * 200

    ring1ang.y = (rotatespeed) % 360
    ring2ang.y = (rotatespeed) % 360

    self:Anim_DrawWorldModel()
end
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)
if SERVER then

	util.AddNetworkString("zs_electrohammer_skill")

	local function RandomVectorInAABB(min, max)
		return Vector(
			math.Rand(min.x, max.x),
			math.Rand(min.y, max.y),
			math.Rand(min.z, max.z)
		)
	end

	function SWEP:OnMeleeHit(hitent, hitflesh, tr)
		local owner = self:GetOwner()
		if not IsValid(owner) then owner = self end

		-- Play hammer sound at random pitch
		--owner:EmitSound("ambient/machines/thumper_hit.wav", 400, math.random(160, 195))

		-- Calculate healing strength
		local healStrength = self.HealStrength * GAMEMODE.NailHealthPerRepair * (owner.RepairRateMul or 1)
		local pos = self:GetPos()
		local radius = self.Radius * (owner.CloudRadius or 1)

		-- Find all entities in range
		for _, target in pairs(ents.FindInSphere(pos, radius)) do
			if IsValid(target) and target ~= self and WorldVisible(pos, target:NearestPoint(pos)) then
				local healed = 0

				if target:IsNailed() then
					-- Repair barricade health
					local oldHealth = target:GetBarricadeHealth()
					if oldHealth > 0 and oldHealth < target:GetMaxBarricadeHealth() and target:GetBarricadeRepairs() > 0.01 then
						local repairAmount = math.min(target:GetBarricadeRepairs(), healStrength)
						target:SetBarricadeHealth(math.min(target:GetMaxBarricadeHealth(), oldHealth + repairAmount))
						healed = target:GetBarricadeHealth() - oldHealth
						target:SetBarricadeRepairs(math.max(target:GetBarricadeRepairs() - healed, 0))

						-- Spawn effect across the whole entity
						local min, max = target:WorldSpaceAABB()
						local effectData = EffectData()
						effectData:SetOrigin(hitent:GetPos()) -- Random point inside bounding box
						effectData:SetNormal(tr.HitNormal)
						effectData:SetMagnitude(1)
						util.Effect("explosion_electrohammer", effectData, true, true)

						gamemode.Call("PlayerRepairedObject", owner, hitent, healed, self)
						target:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
					end

				elseif target.GetObjectHealth then
					-- Repair generic object health
					if not (target.HitByWrench and target:HitByWrench(self, owner, nil)) then
						local oldHealth = target:GetObjectHealth()
						if oldHealth > 0 and oldHealth < target:GetMaxObjectHealth() and not (target.m_LastDamaged and CurTime() < target.m_LastDamaged + 4) then
							target:SetObjectHealth(math.min(target:GetMaxObjectHealth(), oldHealth + healStrength / 2))
							healed = target:GetObjectHealth() - oldHealth

							-- Spawn effect across the whole object
							local min, max = target:WorldSpaceAABB()
							local effectData = EffectData()
							effectData:SetOrigin(RandomVectorInAABB(min, max)) -- Random point inside bounding box
							effectData:SetNormal(tr.HitNormal)
							effectData:SetMagnitude(1)
							util.Effect("explosion_electrohammer", effectData, true, true)

							gamemode.Call("PlayerRepairedObject", owner, target, healed, self)
							target:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
						end
					end
				end
			end
		end
	end




	-- 技能: 纳米云 AoE 修复(客户端中键检测经 net 消息触发)
	function SWEP:UseSkill()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		-- Verify if you have enough ammo
		if owner:GetAmmoCount(self.Secondary.Ammo) <= 0 then
			owner:EmitSound("npc/scanner/combat_scan3.wav") -- Sonido de click vacío
			self:SetNextSecondaryFire(CurTime() + 0.5) -- Pequeña penalización
			return
		end

		if self:GetNextSecondaryFire() <= CurTime() and not owner:IsHolding() and not owner:GetBarricadeGhosting() then
			local tr = owner:CompensatedMeleeTrace(64, self.MeleeSize, nil, nil, nil, true)
			local trent = tr.Entity

			-- Animations
			self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
			self.Alternate = not self.Alternate
			owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

			local d = owner:GetViewModel()
			d:SendViewModelMatchingSequence(d:LookupSequence("hitkill1"))
			d:SetPlaybackRate(0.6)
			self.IdleAnimation = CurTime() + d:SequenceDuration()

			timer.Simple(0.5, function()
				if IsValid(owner) then
					local d = owner:GetViewModel()
					d:SendViewModelMatchingSequence(d:LookupSequence("draw"))
					d:SetPlaybackRate(1)
				end
			end)

			self:SetNextPrimaryFire(CurTime() + 2)
			self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

			-- Visual Effect
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(1)
			util.Effect("flechette_charge", effectdata, true, true)
			
			-- Create Nanite Entity
			local ent = ents.Create("env_nanitecloud")
			if ent:IsValid() then
				ent:SetPos(tr.HitPos)	
				ent:SetOwner(self.Owner or self:GetOwner())
				ent:Spawn()
				ent:EmitSound("ambient/machines/thumper_startup1.wav", 400, math.random(90, 115))
				ent:EmitSound("ambient/machines/thumper_hit.wav", 400, math.random(160, 195))
			end
			
			owner:RemoveAmmo(60, self.Secondary.Ammo)
		end
	end

	-- R 键拆钉子由基类 weapon_zs_hammer:Reload 提供, 这里不覆盖
	-- 中键技能: 客户端检测 MOUSE_MIDDLE 后经 net 消息触发 (参考 weapon_zs_nailplacer)
	net.Receive(NET_MSG.ELECTROHAMMER_SKILL, function(len, ply)
		if not IsValid(ply) or not ply:Alive() then return end

		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or wep:GetClass() ~= "weapon_zs_electrohammer" then return end

		wep:UseSkill()
	end)
end

if CLIENT then
	-- 原版 weapon_zsw_electrohammer 的 HUD (DrawMeleeHudGeneric 在本地基类不存在, 此处内联移植)
	local AmmoSprite = Material("zombiesurvival/killicons/medpower_ammo_icon", "noclamp smooth")
	local NailIcon = Material("zombiesurvival/killicons/nail_ammo_icon_2")

	-- 中键检测(参考 weapon_zs_nailplacer): 客户端轮询 MOUSE_MIDDLE, 按下沿发 net 给服务端
	function SWEP:Think()
		-- 链式调用基类 Think(近战摆动动画), 直接基类 weapon_zs_hammer 没有 Think
		local base = weapons.GetStored(self.Base)
		local depth = 0
		while base and not base.Think and depth < 10 do
			local parent = base.Base
			base = parent and weapons.GetStored(parent) or nil
			depth = depth + 1
		end
		if base and base.Think then
			base.Think(self)
		end

		local owner = self:GetOwner()
		if owner ~= MySelf then return end

		local middledown = not vgui.CursorVisible() and input.IsMouseDown(MOUSE_MIDDLE) or nil
		if middledown == self.m_MiddleDown then return end
		self.m_MiddleDown = middledown
		if not middledown then return end

		net.Start(NET_MSG.ELECTROHAMMER_SKILL)
		net.SendToServer()
	end

	function SWEP:DrawElectrohammerHud()
		local owner = self:GetOwner()
		local screenscale = BetterScreenScale()

		local nails = self:GetPrimaryAmmoCount()
		local nailsColor = nails > 0 and Color(50, 255, 50, 255) or Color(220, 100, 100, 255)

		local pulse = owner:GetAmmoCount(self.Secondary.Ammo)
		local ratio = math.max(self:GetNextSecondaryFire() - CurTime(), 0) / self.Secondary.Delay
		local isReady = (pulse > 0 and ratio <= 0)

		local skills = {
			{
				GetNext = function() return self:GetNextSecondaryFire() end,
				Delay = self.Secondary.Delay,
				Icon = AmmoSprite,
				IconColor = isReady and Color(70, 70, 255) or Color(255, 0, 0),
				GlowColor = isReady and Color(100, 100, 255) or Color(255, 50, 50),
				Label = translate.Get("meleehud_mmb"),
				Font = "GhoulishFrightAOE",
				LabelColor = isReady and Color(100, 100, 255) or Color(255, 50, 50)
			},
			{
				GetNext = function() return self:GetNextPrimaryFire() end,
				Delay = self.Primary.Delay + self.MeleeDelay,
				Icon = NailIcon,
				IconColor = Color(150, 255, 150),
				GlowColor = Color(150, 255, 150),
				Label = translate.Get("meleehud_rmb"),
				Font = "GhoulishFrightAOE",
				LabelColor = Color(150, 255, 150)
			},
			{
				GetNext = function() return self:GetNextPrimaryFire() end,
				Delay = self.Primary.Delay + self.MeleeDelay,
				Icon = AmmoSprite,
				IconColor = Color(100, 200, 255),
				GlowColor = Color(100, 220, 255),
				Label = translate.Get("meleehud_lmb"),
				Font = "GhoulishFrightAOE",
				LabelColor = Color(100, 200, 255)
			},
		}

		local extraText = {
			{
				Text = translate.Format("nails_x", nails),
				Font = "RemingtonNoiseless",
				X = ScrW() - 190 * 0.75 - 32 * screenscale,
				Y = ScrH() - 250 * screenscale,
				Color = nailsColor
			},
			{
				Text = pulse > 0 and translate.Format("electrohammer_pulse_ammo", pulse) or translate.Get("electrohammer_no_pulse"),
				Font = "GhoulishFrightAOE",
				X = ScrW() - 180 * screenscale,
				Y = ScrH() - 150,
				Color = pulse > 0 and Color(100, 100, 255) or Color(255, 50, 50)
			},
			{
				Text = ratio > 0 and translate.Format("electrohammer_skill_cooldown", math.floor(self:GetNextSecondaryFire() - CurTime())) or translate.Get("electrohammer_skill_ready"),
				Font = "GhoulishFrightAOE",
				X = ScrW() - 200 * 0.75 - 32 * screenscale,
				Y = ScrH() - 200,
				Color = ratio > 0 and Color(255, 50, 50) or Color(100, 100, 255)
			}
		}

		local size = 52
		local gap = 14
		local x = ScrW() - 36
		local y = ScrH() - size - 36
		local glowAlpha = 50 + math.sin(CurTime() * 5) * 50

		for _, skill in ipairs(skills) do
			local sratio = math.Clamp(math.max(skill.GetNext() - CurTime(), 0) / skill.Delay, 0, 1)

			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(x - size, y, size, size)

			local fillh = size * sratio
			surface.SetDrawColor(255, 255, 255, 90)
			surface.DrawRect(x - size, y + (size - fillh), size, fillh)

			if sratio <= 0 then
				DrawThickOutline(x - size, y, size, size, 3, Color(skill.GlowColor.r, skill.GlowColor.g, skill.GlowColor.b, glowAlpha))
			end

			surface.SetMaterial(skill.Icon)
			surface.SetDrawColor(skill.IconColor)
			surface.DrawTexturedRect(x - size + (size - 44) / 2, y + (size - 44) / 2, 44, 44)

			draw.SimpleText(skill.Label, skill.Font, x - size / 2, y + size + 2, skill.LabelColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			x = x - size - gap
		end

		for _, line in ipairs(extraText) do
			draw.SimpleText(line.Text, line.Font, line.X, line.Y, line.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	function SWEP:DrawHUD()
		if GetGlobalBool("classicmode") then return end

		self:DrawElectrohammerHud()

		if GetConVar("crosshair"):GetInt() ~= 1 then return end
		self:DrawLockCrosshair()
	end
end
