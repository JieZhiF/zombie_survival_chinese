-- ============================================================================
-- zs_farmhouse_v2.lua - 农舍 地图补丁
-- 负责：移除弹药箱与伤害触发器，并清理出生点附近的杂物实体
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有弹药箱，禁止免费补给
	for _, ent in pairs(ents.FindByClass("item_ammo_crate")) do ent:Remove() end

	-- 移除所有伤害触发器（消除无差别区域伤害）
	for _, ent in pairs(ents.FindByClass("trigger_hurt")) do ent:Remove() end

	-- 移除 (447.7879, -630, 0) 半径 32 单位内的所有实体（清理出生点杂物）
	for _, ent in pairs(ents.FindInSphere(Vector(447.7879, -630.0, 0), 32)) do ent:Remove() end
end)
