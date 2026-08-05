-- ============================================================================
-- zs_vault_106_v5.lua - 106 号避难所 地图补丁
-- 负责：移除厨房置物架模型道具，避免其形成阻挡或卡人位置
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 遍历所有物理道具，移除模型为厨房置物架的实体
	for _, ent in pairs(ents.FindByClass("prop_physics")) do
		if ent:GetModel() == "models/props_wasteland/kitchen_shelf001a.mdl"then
			ent:Remove()
		end
	end
end)
