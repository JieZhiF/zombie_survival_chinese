-- ============================================================================
-- zs_forestofthedamned_v2.lua - zs_forestofthedamned_v2 地图补丁 - 移除全部门实体
-- 负责：移除地图中所有 func_door 门实体，防止门被玩家卡住、
--       堵死通路或干扰守点区域的通行
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 移除地图中所有 func_door 门实体，防止门被卡住或堵塞通路
	for _, ent in pairs(ents.FindByClass("func_door")) do
		ent:Remove()
	end
end)
