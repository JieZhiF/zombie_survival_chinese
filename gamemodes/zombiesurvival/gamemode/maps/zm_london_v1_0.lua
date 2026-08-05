-- ============================================================================
-- zm_london_v1_0.lua - 伦敦 地图补丁
-- 负责：按索引移除 6 个传送触发器，禁用部分传送点
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 获取地图上所有传送触发器
	local ent = ents.FindByClass("trigger_teleport")

	-- 按索引移除指定传送触发器（第 1、3、7、11、13、14 个），保留其余传送点
	ent[1]:Remove()
	ent[3]:Remove()
	ent[7]:Remove()
	ent[11]:Remove()
	ent[13]:Remove()
	ent[14]:Remove()
end)
