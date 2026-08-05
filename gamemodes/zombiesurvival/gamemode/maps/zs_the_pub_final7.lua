-- ============================================================================
-- zs_the_pub_final7.lua - zs_the_pub_final7 地图补丁 - 移除世界提示点
-- 负责：移除地图中所有世界提示点（point_worldhint），清除地图原生的
--       屏幕提示文字，避免干扰游戏模式的战斗界面
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 移除地图所有世界提示点（point_worldhint），去除地图原生的屏幕提示文字
	for _, ent in pairs(ents.FindByClass("point_worldhint")) do ent:Remove() end
end)
