-- ============================================================================
-- zs_ambush_v3.lua - 伏击 地图补丁
-- 负责：在指定位置生成两扇实验舱防爆门作为障碍物，封堵人类可躲藏/进攻的路线
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成第一扇防爆门（实验室防爆门模型，solid=6 启用物理碰撞）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-746, -122, 704))
		ent2:SetAngles(Angle(0, 90, -90))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001b.mdl"))
		ent2:Spawn()
	end

	-- 生成第二扇防爆门（位置与角度不同的另一侧）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-710, -116, 704))
		ent2:SetAngles(Angle(0, 0, -90))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001b.mdl"))
		ent2:Spawn()
	end

end)
