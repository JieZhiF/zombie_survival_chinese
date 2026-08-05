-- ============================================================================
-- zs_stormier_b1.lua - zs_stormier_b1 地图补丁 - 移除传送触发器
-- 负责：移除地图中的传送触发器（trigger_teleport），防止玩家利用传送点
--       卡位或跳过守点区域，保证对局公平
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 移除地图的传送触发器，防止玩家利用传送点卡位
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Remove()
	end
end)
