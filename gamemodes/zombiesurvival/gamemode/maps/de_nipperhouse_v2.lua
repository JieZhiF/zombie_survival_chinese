-- ============================================================================
-- de_nipperhouse_v2.lua - 钳子屋 地图补丁
-- 负责：移除地图上所有门实体，防止玩家关门堵路
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 遍历并移除所有 func_door* 门实体
	for _, ent in pairs(ents.FindByClass("func_door*")) do ent:Remove() end
end)
