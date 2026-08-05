-- ============================================================================
-- zs_xccr_lite.lua - XCCR 精简版（XCCR Lite）地图补丁
-- 负责：移除所有护甲充电器，防止无限补充护甲
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有护甲充电器（item_suitcharger）
	for _, ent in pairs(ents.FindByClass("item_suitcharger")) do ent:Remove() end
end)
