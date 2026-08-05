-- ============================================================================
-- boss_doomcrab/server.lua - 末日蟹 (Doom Crab) BOSS 服务端逻辑
-- 负责：死亡时爆出大量玩家碎尸并触发末日死亡特效
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

-- ==== OnKilled - 死亡时产生 20 块随机飞散的碎尸并播放末日死亡特效 ====
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
	local pos = pl:WorldSpaceCenter()

	-- 在死亡位置周围生成 20 块带随机朝向和爆散力的玩家碎尸
	for i=1, 20 do
		local ent = ents.CreateLimited("prop_playergib")
		if ent:IsValid() then
			ent:SetPos(pos + VectorRand() * 12)
			ent:SetAngles(VectorRand():Angle())
			ent:SetGibType(math.random(3, #GAMEMODE.HumanGibs))
			ent:Spawn()

			-- 施加随机方向的爆散力，让碎尸四散飞出
			local phys = ent:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:ApplyForceOffset(VectorRand():GetNormalized() * math.Rand(8000, 13000), pos)
			end
		end
	end

	-- 触发末日蟹专用死亡特效
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(pl:GetUp())
		effectdata:SetEntity(pl)
	util.Effect("death_doomcrab", effectdata, nil, true)

	return true
end
