-- ============================================================================
-- zm_an_kapras.lua - 安卡普拉斯（An Kapras）地图补丁
-- 负责：移除传送触发器与门实体，开放通道
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有传送触发器，防止玩家被传送
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do ent:Remove() end
	-- 移除所有普通门，开放通道
	for _, ent in pairs(ents.FindByClass("func_door")) do ent:Remove() end
	-- 移除所有旋转门，开放通道
	for _, ent in pairs(ents.FindByClass("func_door_rotating")) do ent:Remove() end
end)
