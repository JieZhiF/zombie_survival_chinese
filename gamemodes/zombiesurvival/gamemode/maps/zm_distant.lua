-- ============================================================================
-- zm_distant.lua - 遥远 地图补丁
-- 负责：移除地图上所有传送触发器，禁用全部传送点
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 遍历并移除所有传送触发器
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Remove()
	end
end)
