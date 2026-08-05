-- ============================================================================
-- zs_boohouse.lua - 惊悚屋（Boo House）地图补丁
-- 负责：移除地图上所有弹药箱，防止无限补给弹药
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有弹药箱（item_ammo_crate）
	for _, ent in pairs(ents.FindByClass("item_ammo_crate")) do ent:Remove() end
end)
