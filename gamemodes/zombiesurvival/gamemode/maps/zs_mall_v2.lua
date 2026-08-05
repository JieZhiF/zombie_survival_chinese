-- ============================================================================
-- zs_mall_v2.lua - zs_mall_v2 地图补丁 - 移除全部物理道具
-- 负责：地图加载完成后移除地图中所有 prop_physics 物理道具，防止散落的
--       购物推车/杂物等被玩家堆叠利用或造成服务器性能负担
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 移除地图中所有物理道具（prop_physics），防止杂物被当作路障或造成卡顿
	for _, ent in pairs(ents.FindByClass("prop_physics")) do ent:Remove() end
end)
