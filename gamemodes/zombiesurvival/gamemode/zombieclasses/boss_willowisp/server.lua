-- ============================================================================
-- boss_willowisp/server.lua - 鬼火 (Will o' Wisp) BOSS 服务端逻辑
-- 负责：环境音效、死亡时爆炸并抛散屠夫刀、非自杀死亡触发溶解爆炸
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

if SERVER then
	-- ==== OnSpawned - 生成时创建屠夫环境音效 ====
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("butcherambience")
	end

	-- ==== MakeButcherKnife - 在指定位置生成一把旋转飞出的屠夫刀 ====
	local function MakeButcherKnife(pos)
		local ent = ents.Create("prop_weapon")
		if ent:IsValid() then
			ent:SetPos(pos)
			ent:SetAngles(AngleRand())
			ent:SetWeaponType("weapon_zs_theworld_humans")
			ent:Spawn()

			-- 赋予随机方向初速度与旋转角速度
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
				phys:AddAngleVelocity(VectorRand() * 200)
			end
		end
	end
	
	-- ==== OnKilled - 非自杀死亡时引爆溶解伤害并播放鬼火死亡爆炸特效 ====
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
	    if not suicide then
		    -- 临时无敌后对周围造成溶解爆炸伤害（避免误伤自己）
		    pl:GodEnable()
		    util.BlastDamageEx(pl:GetActiveWeapon() or NULL, pl, pl:GetPos(), 100, 35, DMG_DISSOLVE)
		    pl:GodDisable()

		-- 播放鬼火死亡爆炸特效
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(Vector(0, 0, 1))
		    util.Effect("explosion_wispdeath", effectdata, true, true)
	    end
	end

	return true
end
