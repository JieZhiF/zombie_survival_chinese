-- ============================================================================
-- boss_red_marrow/server.lua - 红髓 (Red Marrow) BOSS 服务端逻辑
-- 负责：生成时授予 9 个血液词缀（bloodth1~9）天赋
-- ============================================================================

AddCSLuaFile("shared.lua")
include("shared.lua")

-- ==== OnSpawned - 生成时为玩家设置 9 个血液天赋标记 ====
function CLASS:OnSpawned(pl)
	for i=1,9 do
		pl["bloodth"..i] = true
	end
end
