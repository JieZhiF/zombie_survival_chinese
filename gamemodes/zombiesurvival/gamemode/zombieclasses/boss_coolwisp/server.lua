-- ============================================================================
-- boss_coolwisp/server.lua - 寒冰鬼火 (Cool Wisp) BOSS 服务端逻辑
-- 负责：非自杀死亡时造成溺水爆炸伤害、冰冻与肢体伤害，并播放冰击特效
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

-- ==== OnKilled - 非自杀死亡时引爆冰霜：范围溺水伤害 + 冰冻 + 肢体伤害 ====
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
	if not suicide then
		-- 临时无敌后对周围造成溺水爆炸伤害（避免误伤自己）
		pl:GodEnable()
		util.BlastDamageEx(pl:GetActiveWeapon() or NULL, pl, pl:GetPos(), 100, 35, DMG_DROWN)
		pl:GodDisable()

		-- 对爆炸范围内的存活玩家施加冰冻状态与腿部/手臂伤害
		for _, ent in pairs(util.BlastAlloc(pl:GetActiveWeapon() or NULL, pl, pl:GetPos(), 100)) do
			if ent:IsValidLivingPlayer() and gamemode.Call("PlayerShouldTakeDamage", ent, pl) and ent ~= pl then
				ent:GiveStatus("frost", 8)
				ent:AddLegDamage(24)
				ent:AddArmDamage(24)
			end
		end

		-- 播放冰击特效
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(Vector(0, 0, 1))
		util.Effect("hit_ice", effectdata, true, true)
	end

	return true
end
