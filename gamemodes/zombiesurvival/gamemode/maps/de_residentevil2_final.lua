-- ============================================================================
-- de_residentevil2_final.lua - 生化危机 2 地图补丁
-- 负责：解锁全部僵尸职业（服务端与客户端同步），并启用所有物理道具运动
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 服务端：将所有僵尸职业标记为已解锁
	for _, class in pairs(GAMEMODE.ZombieClasses) do
		class.Unlocked = true
	end

	-- 玩家出生时通过 SendLua 同步客户端侧的解锁状态
	hook.Add("PlayerInitialSpawn", "GiveAllClasses", function(pl)
		pl:SendLua("for _,class in pairs(GAMEMODE.ZombieClasses) do class.Unlocked=true end")
	end)

	-- 启用所有物理道具的运动
	for _, ent in pairs(ents.FindByClass("prop_physics*")) do
		ent:GetPhysicsObject():EnableMotion(true)
	end
end)
