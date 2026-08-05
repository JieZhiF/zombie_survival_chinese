-- ============================================================================
-- zs_coasthouse.lua - 海岸小屋 地图补丁
-- 负责：在坡道处生成两扇倾斜的防爆门作为障碍物，封堵通行路线
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成第一扇防爆门（-60 度倾斜）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-541.4225, 15.8781, 512.0313))
		ent2:SetAngles(Angle(-60, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001a.mdl"))
		ent2:Spawn()
	end

	-- 生成第二扇防爆门（位置略高，同为 -60 度倾斜）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-541.4225, -76.1219, 564.0313))
		ent2:SetAngles(Angle(-60, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001a.mdl"))
		ent2:Spawn()
	end
end)
