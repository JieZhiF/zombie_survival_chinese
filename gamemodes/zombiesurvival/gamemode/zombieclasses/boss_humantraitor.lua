CLASS.Name = "humantraitor"
CLASS.TranslationName = "class_humantraitor"
CLASS.Description = "description_humantraitor"
CLASS.Help = "controls_humantraitor"

CLASS.Boss = false
CLASS.Hidden = true
CLASS.Unlocked = false
CLASS.KnockbackScale = 0

CLASS.Health = 700
CLASS.Speed = 265

CLASS.CanTaunt = true

CLASS.FearPerInstance = 1

CLASS.Points = 50

CLASS.SWEP = "weapon_zs_boss_longsword"

CLASS.Model = Model("models/player/riot.mdl")

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

CLASS.CanFeignDeath = false

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return false
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return false
end

function CLASS:CalcMainActivity(pl, velocity)
	return false
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	return false
end

function CLASS:DoAnimationEvent(pl, event, data)

end

function CLASS:DoesntGiveFear(pl)

end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/zombie"
end

if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("butcherambience")
	end

	local function MakeButcherKnife(pos)
		local ent = ents.Create("prop_weapon")
		if ent:IsValid() then
			ent:SetPos(pos)
			ent:SetAngles(AngleRand())
			ent:SetWeaponType("weapon_zs_box") --weapon_zs_boss_longsword
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
				phys:AddAngleVelocity(VectorRand() * 200)
			end
		end
	end

	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local pos = pl:LocalToWorld(pl:OBBCenter())
		timer.Simple(0, function()
			MakeButcherKnife(pos)
		end)
	end
end