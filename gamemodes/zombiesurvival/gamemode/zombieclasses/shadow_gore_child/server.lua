-- ============================================================================
-- shadow_gore_child/server.lua - 暗影血娃 (Shadow Child) 服务端逻辑
-- 负责：近战伤害减半、死亡时生成黑色尸体
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

-- ==== ProcessDamage - 受到的近战伤害减半 ====
function CLASS:ProcessDamage(pl, dmginfo)
	if dmginfo:GetInflictor().IsMelee then
		dmginfo:SetDamage(dmginfo:GetDamage() / 2)
	end
end

-- ==== OnKilled - 死亡时以随机死亡动画生成假尸体并染成纯黑色 ====
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
	local fd = pl:FakeDeath(pl:LookupSequence("death_0"..math.random(4)), self.ModelScale)
	if fd and fd:IsValid() then
		fd:SetColor(Color(0,0,0,255))
	end

	return true
end
