-- ============================================================================
-- zs_hauntedbayou.lua - 闹鬼沼泽 地图补丁
-- 负责：移除地图上所有弹药箱，禁止免费补给弹药
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 遍历并移除所有弹药箱
	for _, ent in pairs(ents.FindByClass("item_ammo_crate")) do ent:Remove() end
end)
