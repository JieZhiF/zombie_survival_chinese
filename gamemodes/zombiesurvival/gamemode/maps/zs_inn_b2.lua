-- ============================================================================
-- zs_inn_b2.lua - zs_inn_b2 地图补丁 - 生成文件柜封堵点位
-- 负责：在坐标 (2702, 377, 47) 生成一个文件柜（controlroom_filecabinet001a）
--       作为固体障碍物，封堵玩家可钻入或卡位的空隙
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 在坐标 (2702, 377, 47) 生成文件柜，作为固体障碍物封堵可钻的空隙
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(2702, 377, 47))
		ent2:SetAngles(Angle(0, 0, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_wasteland/controlroom_filecabinet001a.mdl"))
		ent2:Spawn()
	end
end)
