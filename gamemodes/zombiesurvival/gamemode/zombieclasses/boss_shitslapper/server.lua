-- ============================================================================
-- boss_shitslapper/server.lua - 屎掌拍 (Shit Slapper) 小BOSS 服务端逻辑
-- 负责：死亡时以"释放猎头蟹"动画生成假尸体
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

-- ==== OnKilled - 死亡时以释放猎头蟹动画生成带体型缩放的假尸体 ====
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
	pl:FakeDeath(pl:LookupSequence("releasecrab"), self.ModelScale)

	return true
end
