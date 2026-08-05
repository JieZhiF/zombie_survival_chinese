-- ============================================================================
-- zs_abandoned_mall_v5b.lua - 废弃商场 地图补丁
-- 负责：移除地图上所有 func_button 按钮，防止触发机关
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 遍历并移除所有按钮实体
	for _, ent in pairs(ents.FindByClass("func_button")) do ent:Remove() end
end)
