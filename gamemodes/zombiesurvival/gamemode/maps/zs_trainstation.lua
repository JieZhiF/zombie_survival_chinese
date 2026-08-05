-- ============================================================================
-- zs_trainstation.lua - zs_trainstation 地图补丁 - 移除厨房置物架道具
-- 负责：移除地图中厨房置物架（kitchen_shelf001a）模型的物理道具，
--       防止该模型被堆叠成不合理掩体或卡住玩家
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
		-- 移除厨房置物架（kitchen_shelf001a）物理道具，防止堆叠成不合理掩体
	for _, ent in pairs(ents.FindByClass("prop_physics")) do
		if ent:GetModel() == "models/props_wasteland/kitchen_shelf001a.mdl"then
			ent:Remove()
		end
	end
end)
