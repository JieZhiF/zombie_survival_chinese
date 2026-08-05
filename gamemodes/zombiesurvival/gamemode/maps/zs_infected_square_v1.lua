-- ============================================================================
-- zs_infected_square_v1.lua - 感染广场 v1（Infected Square）地图补丁
-- 负责：移除地图上所有按钮实体
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有按钮实体，防止触发地图机关
	for _, ent in pairs(ents.FindByClass("func_button")) do ent:Remove() end
end)
