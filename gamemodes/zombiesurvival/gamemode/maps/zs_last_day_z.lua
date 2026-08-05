-- ============================================================================
-- zs_last_day_z.lua - 最后之日（Last Day Z）地图补丁
-- 负责：移除传送触发器与按钮实体，防止玩家利用地图机关
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 移除所有传送触发器，防止玩家被传送到非预期区域
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		-- 删除传送触发器
		ent:Remove()
	end
	-- 移除所有按钮实体，防止触发地图机关
	for _, ent in pairs(ents.FindByClass("func_button")) do
		-- 删除按钮实体
		ent:Remove()
	end
end)
