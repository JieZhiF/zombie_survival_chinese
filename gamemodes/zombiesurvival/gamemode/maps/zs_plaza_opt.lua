-- ============================================================================
-- zs_plaza_opt.lua - 广场优化版（Plaza Opt）地图补丁
-- 负责：移除指定名称的商店门实体，开放通道
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除枪店门（Gunstoredoor）
	for _, ent in pairs(ents.FindByName("Gunstoredoor")) do ent:Remove() end
	-- 移除三楼商店门（Store3F2）
	for _, ent in pairs(ents.FindByName("Store3F2")) do ent:Remove() end
	-- 移除一楼商店门（Store1F2）
	for _, ent in pairs(ents.FindByName("Store1F2")) do ent:Remove() end
end)
