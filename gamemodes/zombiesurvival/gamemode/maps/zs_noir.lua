-- ============================================================================
-- zs_noir.lua - 黑色电影（Noir）地图补丁
-- 负责：移除地图上所有普通门，开放通道
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有 func_door 门实体，开放通道
	for _, ent in pairs(ents.FindByClass("func_door")) do
		-- 删除门实体
		ent:Remove()
	end
end)
