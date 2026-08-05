-- ============================================================================
-- zm_mall_beta_b1.lua - 购物中心 地图补丁
-- 负责：生成两扇防爆门封堵高层通道，并移除厨房置物架道具
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 生成第一扇防爆门
	local ent = ents.Create("prop_dynamic_override")
	if ent:IsValid() then
		ent:SetPos(Vector(-1028.6432, -3061.5071, 812.0313))
		ent:SetModel("models/props_lab/blastdoor001a.mdl")
		ent:SetKeyValue("solid", "6")
		ent:Spawn()
	end

	-- 生成第二扇防爆门（上层高度）
	ent = ents.Create("prop_dynamic_override")
	if ent:IsValid() then
		ent:SetPos(Vector(-1028.39, -3062.3708, 918.0627))
		ent:SetModel("models/props_lab/blastdoor001a.mdl")
		ent:SetKeyValue("solid", "6")
		ent:Spawn()
	end

	-- 移除厨房置物架模型道具
	for _, ent in pairs(ents.FindByClass("prop_physics*")) do
		if ent:GetModel() == "models/props_wasteland/kitchen_shelf001a.mdl"then
			ent:Remove()
		end
	end
end)
