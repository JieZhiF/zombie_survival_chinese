CLASS.Base = "boss_nightmare"

CLASS.Name = "Ancient Nightmare"
CLASS.TranslationName = "class_ancient_nightmare"
CLASS.Description = "description_ancient_nightmare"
CLASS.Help = "controls_ancient_nightmare"

CLASS.Boss = true

CLASS.Health = 3500
CLASS.Speed = 170

CLASS.Points = 30

CLASS.SWEP = "weapon_zs_anightmare"

CLASS.Model = Model("models/player/skeleton.mdl")
CLASS.OverrideModel = false

CLASS.Skeletal = true

local math_random = math.random

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random(2) == 1 then
		pl:EmitSound("npc/barnacle/neck_snap1.wav", 65, math_random(115, 130), 0.27)
	else
		pl:EmitSound("npc/barnacle/neck_snap2.wav", 65, math_random(115, 130), 0.27)
	end

	return true
end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/ancient_nightmare"

if SERVER then
    -- 当僵尸被杀死时
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)

        -- 掉落武器
        local pos = pl:LocalToWorld(pl:OBBCenter())
        local ent = ents.Create("prop_weapon")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:SetAngles(AngleRand())
            ent:SetWeaponType("weapon_zs_box")
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
                phys:AddAngleVelocity(VectorRand() * 200)
            end
        end

        return true
    end
end
