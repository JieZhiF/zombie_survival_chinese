-- ============================================================================
-- zs_storm_v1.lua - 风暴 v1（Storm v1）地图补丁
-- 负责：移除地图上所有传送触发器
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有传送触发器，防止玩家被传送到非预期区域
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		-- 删除传送触发器
		ent:Remove()
	end
end)
